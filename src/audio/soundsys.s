; Engine of Planet X3, a real-time strategy game originally for MS-DOS.
; Copyright (C) 2018-2023  8-Bit Productions LLC and contributors
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.
;
; -----
;
; AUTHORS of this file (in chronological order)
;
; - Alex Semenov*
; - Benedikt Freisen
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

; sound system for Planet X3 game, ©2018 David Murray
; developed by shiru8bit


; plays music for PC Speaker, Tandy, or Adlib
; uses separate music data files for each of devices
; can also play Adlib music via OPL2LPT
; also plays sound effects via PC Speaker


; interface calls:

; ssy_init       - init system
; ssy_shut       - shutdown system
; ssy_opl_output - select device to play Adlib music, DX=0 sets normal Adlib,
;                  otherwise it is LPT port base address for OPL2LPT device

; ssy_timer_isr  - update sound system state, has to be called via timer ISR
;                  at 72.8 Hz (divider for 8253 is 16384)

; ssy_music_play - play music that is loaded into SSY_MUS_DATA buffer, sound
;                  device gets selected automatically depending on the data
; ssy_music_stop - stop music

; ssy_sound_play - play sound effect that is loaded into SSY_SFX_DATA buffer,
;                  AL=number of effect in the sound effect bank
;                  AH=priority, any number 0..255, if there is effect with
;                     higher priority number is active, an attempt to play a
;                     lower priority effect will be ignored



; internal defines

DEVICE_NONE             equ 0
DEVICE_SPEAKER          equ 1
DEVICE_TANDY            equ 2
DEVICE_ADLIB            equ 3

PP_NOT_STROBE           equ 001h
PP_NOT_AUTOFD           equ 002h
PP_INIT                 equ 004h
PP_NOT_SELECT           equ 008h



; song data format:
;
; header
;
; $00 - byte, 0:speaker, 1:tandy, 2:adlib
; $01 - number of separate streams, normally 4 for Speaker and Tandy, 6 for Adlib
; $02 - word, pointer to first stream (relative to beginning of song data)
; $04 - word, pointer to second stream, and so forth for all streams
; ..
; $NN - stream data
; ..
;
; stream data
;
; $00       not used
; $01..bf   wait N frames
;
; $c0..$cf  set volume 0..15
; $d0,NN    set pitch 1 lsb,  also sets volume to 15 (for PC Speaker)
; $d1,NN    set pitch 1 msb,  also sets volume to 15
; $d2,NNNN  set pitch 1 word, also sets volume to 15
; $d3,NN    short backwards reference, -1..255 bytes
;           (relative to address of $d3)
; $d4,NN    set pitch 2 lsb,  for Tandy and FM tone channels
; $d5,NN    set pitch 2 msb
; $d6,NNNN  set pitch 2 word
; $d7       repeat previously repeated (with $fc) block
;
; $d8..$f3,NN   write a byte into virtual register array (36 registers)
;
;  $d8  tandy noise mode
;
;  $d8  modulator multiple  (ch 1 group)
;  $d9  carrier multiple
;  $da  modulator total level
;  $db  feedback and algorithm
;  $dc  modulator waveform
;  $dd  carrier waveform
;  $de..$e3 ch 2 group
;  $e4..$e9 ch 3 group
;  $ea..$ef ch 4 group
;  $f0..$f5 ch 5 group
;  $f6..$fb ch 6 group
;
; $fc       end of part (packing block), ignored if no reference is active
; $fd,NNNN  long backwards reference, followed by 16-bit pointer relative
;           to data start (repeats until $fc met)
; $fe       loop start
; $ff       end of data

;------------------------------------------------------------------------------
; sound system variables and data


; SSY_MUS_DATA_SIZE       equ 32768
SSY_SFX_DATA_SIZE       equ 1536

; channel structure offsets and size

CH_MAX                  equ 7           ; 1 for sound effects, 4-6 for music
CH_STRUCT_SIZE          equ 16
CH_REGS_SIZE            equ 36

CH_WAIT                 equ 0           ; byte
CH_VOLUME               equ 1           ; byte
CH_RET                  equ 2           ; word
CH_PTR                  equ 4           ; word
CH_LOOP                 equ 6           ; word
CH_PITCH_1              equ 8           ; word
CH_PITCH_2              equ 10          ; word
CH_VOLPREV              equ 12          ; byte
CH_PRIORITY             equ 13          ; byte
CH_REFPREV              equ 14          ; word

SSY_CHANNELS            equ 0           ; number of active data streams

SSY_PCSPE_PERIOD        equ 2           ; temporary variables for PC Speaker state
SSY_PCSPE_ENABLE        equ 4

SSY_MUS_ENABLE          equ 6           ; music enable flag

SSY_DEV_INIT            equ 8           ; device specific init subroutine
SSY_DEV_SHUT            equ 10          ; device specific shut
SSY_DEV_UPDATE          equ 12          ; device specific update

SSY_ADLIB_WR            equ 14          ; adlib write subroutine pointer, it may vary between Adlib/OPL2LPT
SSY_OPL2LPT_BASE        equ 16          ; port address for opl2lpt

SSY_CH_VARS             equ 18                                  ; reserve CH_STRUCT_SIZE*CH_MAX bytes
SSY_CH_REGS             equ SSY_CH_VARS+CH_STRUCT_SIZE*CH_MAX   ; extra variables, shared between channels
SSY_CH_REGS_PREV        equ SSY_CH_REGS+CH_REGS_SIZE            ; previous state, needed for Adlib writes


; buffers to load music and sfx data

SSY_MUS_DATA            equ SSY_CH_REGS_PREV+CH_REGS_SIZE
; SSY_SFX_DATA            equ SSY_MUS_DATA_SIZE




;------------------------------------------------------------------------------
; initialize sound system
; call it at start of the program, before setting up the timer ISR
; IN: none

ssy_init:

        push    ds
        mov     ax,word [cs:SSY_SEG]
        mov     ds,ax

        mov     ax,ssy_adlib_write
        mov     word [SSY_ADLIB_WR],ax

        mov     byte [SSY_MUS_ENABLE],0
        mov     word [SSY_OPL2LPT_BASE],0

        mov     al,DEVICE_SPEAKER
        call    _ssy_set_device

        mov     dx,0
        call    ssy_opl_output

        pop     ds
        ret



;------------------------------------------------------------------------------
; shutdown sound system
; call it at end of the program, after shutting down the timer ISR
; IN: none

ssy_shut:

        call    ssy_music_stop

        ret



;------------------------------------------------------------------------------
; set Adlib music output device, music gets stopped
; IN: DX=0 for normal Adlib (default)
;     DX=LPT port base (3BCh, 278h, 378h) for opl2lpt

ssy_opl_output:

        push    ds
        mov     ax,word [cs:SSY_SEG]
        mov     ds,ax

        push    dx
        call    ssy_music_stop
        pop     dx

        or      dx,dx
        jne     _ssy_sao_lpt

        mov     ax,ssy_adlib_write
        mov     word [SSY_ADLIB_WR],ax

        pop     ds
        ret

_ssy_sao_lpt:

        mov     word [SSY_OPL2LPT_BASE],dx

        mov     ax,ssy_opl2lpt_write
        mov     word [SSY_ADLIB_WR],ax

        pop     ds
        ret



;------------------------------------------------------------------------------
; internal function to set up device specific routine pointers
; not to meant to be called from game code!
; it assumes correct data segment is set
; IN: AL=device id

_ssy_set_device:

        cmp     al,DEVICE_SPEAKER
        jne     .L1

        mov     ax,ssy_pcspe_init
        mov     bx,ssy_pcspe_shut
        mov     cx,ssy_pcspe_update
        jmp     _ss_mp_set_device

.L1:

        cmp     al,DEVICE_TANDY
        jne     .L2

        mov     ax,ssy_tandy_init
        mov     bx,ssy_tandy_shut
        mov     cx,ssy_tandy_update
        jmp     _ss_mp_set_device

.L2:

        mov     ax,ssy_adlib_init
        mov     bx,ssy_adlib_shut
        mov     cx,ssy_adlib_update

_ss_mp_set_device:

        mov     word [SSY_DEV_INIT],ax
        mov     word [SSY_DEV_SHUT],bx
        mov     word [SSY_DEV_UPDATE],cx

        ret



;------------------------------------------------------------------------------
; start playing a song
; the song data must be loaded into SSY_MUS_DATA buffer
; sound device will get selected automatically depending on the file contents
; IN: none

ssy_music_play:

        call    ssy_music_stop

        push    ds
        mov     ax,word [cs:SSY_SEG]
        mov     ds,ax

        mov     al,byte [SSY_MUS_DATA]

        cmp     al, 5
        jl      .no_midi
        pop     ds

        ; TODO: only for MIDI
        call    InitializeSong

        ret

.no_midi:

        call    _ssy_set_device

        mov     di,SSY_CH_VARS                  ; reset all channel variables to 0
        mov     cx,(CH_STRUCT_SIZE*CH_MAX)/2
        mov     ax,0

.t0:
        mov     word [di],ax
        add     di,2
        loop    .t0

        mov     si,SSY_CH_REGS                  ; reset channel registers to 0, force update
        mov     di,SSY_CH_REGS_PREV
        mov     cx,CH_REGS_SIZE/2
        mov     bx,5555h

.t0a:
        mov     word [si],ax
        mov     word [di],bx
        add     si,2
        add     di,2
        loop    .t0a

        mov     cl,byte [SSY_MUS_DATA+1]
        mov     ch,0
        inc     cx                              ; extra channel for sound effects
        mov     word [SSY_CHANNELS],cx

        mov     di,SSY_CH_VARS+(1*CH_STRUCT_SIZE)       ; start from channel 1
        mov     si,SSY_MUS_DATA+2

_ss_mp_ch_loop:

        mov     ax,word [si]

        add     ax,SSY_MUS_DATA

        mov     word [di+CH_PTR ],ax            ; ptr
        mov     word [di+CH_LOOP],ax            ; loop

        mov     al,0ffh                         ; force volume update
        mov     byte [di+CH_VOLPREV],al

        add     di,CH_STRUCT_SIZE
        add     si,2

        loop    _ss_mp_ch_loop

        mov     bx,word [SSY_DEV_INIT]
        call    bx

        mov     byte [SSY_MUS_ENABLE],1

        pop     ds
        ret



;------------------------------------------------------------------------------
; stop playing current song if any
; IN: none

ssy_music_stop:

        push    ds
        mov     ax,word [cs:SSY_SEG]
        mov     ds,ax

        mov     byte [SSY_MUS_ENABLE],0
        mov     byte [SSY_CHANNELS],1

        pop     ds

        call    [cs:ssy_device_shut]

        ret



;------------------------------------------------------------------------------
; play sound effect
; IN: AL=sound effect number, AH=priority 0..255
; preserves si

ssy_sound_play:

        mov     bx,ax
        push    si
        push    ds
        mov     ax,word [cs:SSY_SEG]
        mov     ds,ax

        mov     si,[cs:ssy_mus_data_size]
        cmp     bl,byte [si+1]                          ; check if effect number is in range
        jnc     _ssy_sp_done

        cmp     bh,byte [SSY_CH_VARS+CH_PRIORITY]       ; check effect priority against an active effect (if any)
        jc      _ssy_sp_done

        mov     byte [SSY_CH_VARS+CH_PRIORITY],bh

        mov     bh,0                                    ; load sound effect pointer
        shl     bl,1
        add     bx,si
        add     bx,2

        mov     ax,0
        mov     byte [SSY_CH_VARS+CH_WAIT],al
        mov     byte [SSY_CH_VARS+CH_VOLUME],al
        mov     word [SSY_CH_VARS+CH_PITCH_1],ax

        mov     ax,word [bx]
        add     ax,si

        mov     word [SSY_CH_VARS+CH_PTR],ax


_ssy_sp_done:

        pop     ds
        pop     si
        ret



;------------------------------------------------------------------------------
; sound system update
; call it from timer ISR, at 72.8 HZ rate (8253 divider 16384, 1193180/16384=72.8)
; IN: none

ssy_timer_isr:

        call    [cs:ssy_device_isr]             ; optional additional device specific ISR code

        push    ds
        mov     ax,word [cs:SSY_SEG]
        mov     ds,ax

        ; process channels

        mov     di,SSY_CH_VARS
        mov     cx,word [SSY_CHANNELS]          ; channel 0 is for sound effects, 1..6 for music

        cmp     byte [SSY_MUS_DATA],6           ; Is a MIDI file loaded?
        jl      _no_channels

        mov     cx,1                            ; Force only the sound effect channel


_no_channels:

_ss_ti_ch_loop:

        mov     al,byte [di+CH_WAIT]            ; wait counter, decrease if non zero, update channel if zero
        or      al,al
        je      _ss_ti_ch_upd
        dec     al
        mov     byte [di+CH_WAIT],al
        jne     _ss_ti_ch_skip

_ss_ti_ch_upd:

        mov     si,word [di+CH_PTR]             ; read channel data pointer
        or      si,si
        je      _ss_ti_ch_skip                  ; skip channel update if pointer is zero

_ss_ti_ch_read:

        mov     al,byte [si]                    ; read next byte from channel data
        inc     si                              ; advance channel data pointer

        cmp     al,0C0h                         ; check if it is a wait value
        jnc _ss_ti_ch_tag


_ss_ti_ch_set_wait:

        mov     byte [di+CH_WAIT],al            ; set new wait

_ss_ti_ch_next:

        mov     word [di+CH_PTR],si             ; remember data pointer

_ss_ti_ch_skip:

        add     di,CH_STRUCT_SIZE               ; next channel

        loop    _ss_ti_ch_loop
        jmp     _ss_ti_channels_done

_ss_ti_ch_tag:

        mov     bh,0                            ; invoke tag handler via jump table
        mov     bl,al
        shl     bx,1
        mov     dx,word [cs:(_ss_ti_jump_table-0C0h*2)+bx]
        jmp     dx



_ss_ti_channels_done:


        mov     ax,0                            ; reset PC Speaker state
        mov     word [SSY_PCSPE_PERIOD],ax
        mov     byte [SSY_PCSPE_ENABLE],al

        mov     al,byte  [SSY_MUS_ENABLE]
        or      al,al
        je      _ss_ti_add_effects

        mov     bx,word [SSY_DEV_UPDATE]        ; perform device-dependent update
        call    bx

_ss_ti_add_effects:

        mov     al,byte [SSY_CH_VARS+CH_VOLUME]
        or      al,al
        je      _ss_ti_speaker_output

        mov     byte [SSY_PCSPE_ENABLE],al

        mov     ax,word [SSY_CH_VARS+CH_PITCH_1]
        mov     word [SSY_PCSPE_PERIOD],ax

_ss_ti_speaker_output:

        mov     al,byte [SSY_PCSPE_ENABLE]
        or      al,al
        jne     _ss_ti_speaker_en

        in      al,061h                         ; disable speaker
        and     al,0fch
        out     061h,al

        jmp     _ss_ti_speaker_done

_ss_ti_speaker_en:

        in      al,061h                         ; enable speaker and set pitch
        or      al,003h
        out     061h,al

        mov     ax,word [SSY_PCSPE_PERIOD]

        out     042h,al
        mov     al,ah
        out     042h,al

_ss_ti_speaker_done:

        pop     ds
        ret




_ss_ti_set_volume:

        and     al,15
        mov     byte [di+CH_VOLUME],al

        jmp     _ss_ti_ch_read


_ss_ti_set_pitch_1_lsb:

        mov     byte [di+CH_VOLUME],al          ; non-zero volume

        mov     al,byte [si]
        inc     si
        mov     byte [di+CH_PITCH_1+0],al

        jmp     _ss_ti_ch_next                  ; any pitch change also ends frame


_ss_ti_set_pitch_1_msb:

        mov     byte [di+CH_VOLUME],al          ; non-zero volume

        mov     al,byte [si]
        inc     si
        mov     byte [di+CH_PITCH_1+1],al

        jmp     _ss_ti_ch_next


_ss_ti_set_pitch_1_word:

        mov     byte [di+CH_VOLUME],al          ; non-zero volume

        mov     ax,word [si]
        add     si,2
        mov     word [di+CH_PITCH_1],ax

        jmp     _ss_ti_ch_next


_ss_ti_set_pitch_2_lsb:

        mov     al,byte [si]
        inc     si
        mov     byte [di+CH_PITCH_2+0],al

        jmp     _ss_ti_ch_next


_ss_ti_set_pitch_2_msb:

        mov     al,byte [si]
        inc     si
        mov     byte [di+CH_PITCH_2+1],al

        jmp     _ss_ti_ch_next


_ss_ti_set_pitch_2_word:

        mov     ax,word [si]
        add     si,2
        mov     word [di+CH_PITCH_2],ax

        jmp     _ss_ti_ch_next


_ss_ti_set_register:

        mov     bh,0                            ; get virtual register offset
        mov     bl,al

        mov     al,byte [si]                    ; get byte to write
        inc     si

        mov     byte [bx+(SSY_CH_REGS-0D8h)],al ; write byte to virtual register array

        jmp     _ss_ti_ch_read


_ss_ti_ref_ret:

        cmp     di,SSY_CH_VARS                  ; check if it is channel 0
        jne .t0

        mov     si,0                            ; stop channel
        mov     ax,si
        mov     byte [di+CH_VOLUME],al          ; reset volume
        mov     byte [di+CH_PRIORITY],al        ; reset channel priority, for sound effects

        jmp     _ss_ti_ch_next

.t0:

        mov     ax,word [di+CH_RET]             ; read reference return pointer
        or      ax,ax
        je      .t0a                            ; just go next data byte if no reference is active

        mov     si,ax                           ; restore pointer
        mov     word [di+CH_RET],0              ; clear reference

.t0a:

        jmp     _ss_ti_ch_read


_ss_ti_call_ref_short:

        mov     al,byte [si]                    ; read reference short pointer
        inc     si

        mov     word [di+CH_RET],si             ; remember pointer as reference return

        mov     ah,0
        sub     si,2
        sub     si,ax

        mov     word [di+CH_REFPREV],si         ; also remember it in case it is has to be repeated

        jmp     _ss_ti_ch_read


_ss_ti_call_ref_long:

        mov     ax,word [si]                    ; read reference long pointer
        add     si,2

        mov     word [di+CH_RET],si             ; remember pointer as reference return

        add     ax,SSY_MUS_DATA                 ; turn into absolute pointer
        mov     si,ax

        mov     word [di+CH_REFPREV],si         ; also remember it in case it is has to be repeated

        jmp     _ss_ti_ch_read


_ss_ti_ref_repeat:

        mov     word [di+CH_RET],si             ; remember pointer as reference return
        mov     si,word [di+CH_REFPREV]

        jmp _ss_ti_ch_read


_ss_ti_start_loop:

        mov word [di+CH_LOOP],si

        jmp _ss_ti_ch_read


_ss_ti_take_loop:

        mov si,word [di+CH_LOOP]

        jmp _ss_ti_ch_read



_ss_ti_jump_table:

        times 16 dw _ss_ti_set_volume           ; c0..cf
        dw _ss_ti_set_pitch_1_lsb               ; d0
        dw _ss_ti_set_pitch_1_msb               ; d1
        dw _ss_ti_set_pitch_1_word              ; d2
        dw _ss_ti_call_ref_short                ; d3
        dw _ss_ti_set_pitch_2_lsb               ; d4
        dw _ss_ti_set_pitch_2_msb               ; d5
        dw _ss_ti_set_pitch_2_word              ; d6
        dw _ss_ti_ref_repeat                    ; d7
        times 36 dw _ss_ti_set_register         ; d8..fb
        dw _ss_ti_ref_ret                       ; fc
        dw _ss_ti_call_ref_long                 ; fd
        dw _ss_ti_start_loop                    ; fe
        dw _ss_ti_take_loop                     ; ff



;------------------------------------------------------------------------------
; PC Speaker stuff


ssy_pcspe_init:

        mov     al,0b6h
        out     043h,al

        ret



ssy_pcspe_shut:

        in      al,061h
        and     al,0FCh
        out     061h,al

        ret



ssy_pcspe_update:

        mov     si,SSY_CH_VARS+4*CH_STRUCT_SIZE ; channels 4..1
        mov     al,byte [si+CH_VOLUME]          ; check volume channels 3 to 0
        or      al,al
        jne     _ss_speaker_output_en
        sub     si,CH_STRUCT_SIZE
        mov     al,byte [si+CH_VOLUME]
        or      al,al
        jne     _ss_speaker_output_en
        sub     si,CH_STRUCT_SIZE
        mov     al,byte [si+CH_VOLUME]
        or      al,al
        jne     _ss_speaker_output_en
        sub     si,CH_STRUCT_SIZE
        mov     al,byte [si+CH_VOLUME]

_ss_speaker_output_en:

        mov     byte [SSY_PCSPE_ENABLE],al

        mov     ax,word [si+CH_PITCH_1]
        mov     word [SSY_PCSPE_PERIOD],ax

        ret



;------------------------------------------------------------------------------
; Tandy stuff


ssy_tandy_init:

        ; configure multiplexer in PCJr. to enable PC Speaker and PSG
        ; NOTE: this relies on the video hardware detection and thus
        ;       has to run after video mode initialization
        test    word [cs:video_hw],VIDEO_HW_PCJR_OR_TANDY
        jz      .end
        cmp     word [cs:ssy_base_port],0c0h    ; proper internal PSG?
        jne     .end
        in      al,61h
        or      al,60h
        out     61h,al
.end:
        ret


ssy_tandy_shut:

        mov     bx,[cs:ssy_wr]
        mov     al,9fh
        call    bx
        mov     al,0bfh
        call    bx
        mov     al,0dfh
        call    bx
        mov     al,0ffh
        call    bx

        ret



ssy_tandy_update:

        mov     bx,[cs:ssy_wr]

        mov     al,[SSY_CH_VARS+(1*CH_STRUCT_SIZE)+CH_VOLUME]
        or      al,90h+0*32
        call    bx

        mov     ax,[SSY_CH_VARS+(1*CH_STRUCT_SIZE)+CH_PITCH_2]
        call    bx
        mov     al,ah
        call    bx

        mov     al,[SSY_CH_VARS+(2*CH_STRUCT_SIZE)+CH_VOLUME]
        or      al,90h+1*32
        call    bx

        mov     ax,[SSY_CH_VARS+(2*CH_STRUCT_SIZE)+CH_PITCH_2]
        call    bx
        mov     al,ah
        call    bx

        mov     al,[SSY_CH_VARS+(3*CH_STRUCT_SIZE)+CH_VOLUME]
        or      al,90h+2*32
        call    bx

        mov     ax,[SSY_CH_VARS+(3*CH_STRUCT_SIZE)+CH_PITCH_2]
        call    bx
        mov     al,ah
        call    bx

        mov     al,[SSY_CH_VARS+(4*CH_STRUCT_SIZE)+CH_VOLUME]
        or      al,90h+3*32
        call    bx

        mov     al,[SSY_CH_REGS]                ; noise mode
        call    bx

        ret



; destroys dx
ssy_tandy_write:
        mov     dx,[cs:ssy_base_port]
        out     dx,al
        ret


; destroys dx, flags
ssy_tndlpt_write:
        push    ax
        mov     dx,[cs:ssy_base_port]
        out     dx,al
        inc     dx
        inc     dx
        mov     al,0ch
        out     dx,al
        dec     dx
        mov     ah,24
.l1:    dec     ah
        js      .l2
        in      al,dx
        and     al,40h
        jnz     .l1
.l2:    dec     ah
        js      .l2end
        in      al,dx
        and     al,40h
        jz      .l2
.l2end: inc     dx
        mov     al,9
        out     dx,al
        pop     ax
        ret


;------------------------------------------------------------------------------
; Adlib stuff


ssy_adlib_operator_order:

        db 00h,01h,02h,08h,09h,0Ah,10h,11h,12h

ssy_adlib_volume_table:

        db 63,48,40,34,30,27,24,22,19,16,14,11,8,6,3,0

ssy_adlib_instrument_regs:

        db 020h,023h,040h,0C0h,0E0h,0E3h
        db 021h,024h,041h,0C1h,0E1h,0E4h
        db 022h,025h,042h,0C2h,0E2h,0E5h
        db 028h,02Bh,048h,0C3h,0E8h,0EBh
        db 029h,02Ch,049h,0C4h,0E9h,0ECh
        db 02Ah,02Dh,04Ah,0C5h,0EAh,0EDh


ssy_adlib_init:

        ret



ssy_adlib_shut:

        mov     bx,word [cs:ssy_wr]

        mov     al,01h                          ; enable waveform selection
        mov     cl,20h
        call    bx

        mov     al,02h

        ; 02..3f = 0
        ; 20..9f = 255
        ; a0..f6 = 0
        ; this includes $bd=0 (disable drums) and $08=0 (CSW disable)

_ss_ad_sh_clear:

        push    ax

        mov     cl,0
        cmp     al,020h
        jc      .t0
        cmp     al,0a0h
        jnc     .t0
        dec     cl
.t0:
        call    bx

        pop     ax

        inc     al
        cmp     al,0F6h
        jc      _ss_ad_sh_clear


        mov     si,0

_ss_ad_sh_setup:

        mov     ch,byte [cs:ssy_adlib_operator_order+si]

        mov     al,060h                         ; quick attack, longest decay
        add     al,ch
        mov     cl,0E0h
        call    bx

        mov     al,063h                         ; the same for operator 1 and 2
        add     al,ch
        mov     cl,0E0h
        call    bx

        mov     al,080h                         ; max sustain, quick release
        add     al,ch
        mov     cl,00Eh
        call    bx

        mov     al,083h                         ; these settings remain unchanged
        add     al,ch
        mov     cl,00Eh
        call    bx

        inc     si
        cmp     si,9
        jne     _ss_ad_sh_setup

        ret



ssy_adlib_update:

        mov     bx,word [cs:ssy_wr]

        mov     di,SSY_CH_VARS+CH_STRUCT_SIZE
        mov     si,0
        mov     cx,6

_ssy_au_loop:

        push    cx

        mov     al,byte [di+CH_VOLUME]
        or      al,al
        jne     _ssy_au_set_vol

_ssy_au_keyoff:

        cmp     al,byte [di+(CH_PITCH_1+1)]
        je      _ssy_au_next
        mov     byte [di+(CH_PITCH_1+1)],al

        mov     cl,al                           ; key off
        mov     ax,si
        add     al,0B0h

        call    bx

        jmp     _ssy_au_next

_ssy_au_set_vol:

        cmp     al,byte [di+CH_VOLPREV]
        je      _ssy_au_keyon
        mov     byte [di+CH_VOLPREV],al

        push    si
        mov     ah,0                            ; convert volume from 0..15 to Adlib range
        mov     si,ax

        mov     cl,byte [cs:ssy_adlib_volume_table+si]
        pop     si

        mov     al,byte [cs:ssy_adlib_operator_order+si]
        add     al,043h                         ; set volume
        call    bx

_ssy_au_keyon:

        mov     cx,word [di+CH_PITCH_2]
        cmp     cx,word [di+CH_PITCH_1]
        je      _ssy_au_next
        mov     word [di+CH_PITCH_1],cx

        mov     ax,si
        add     al,0A0h                         ; set lsb
        call    bx

        mov     cl,ch                           ; set msb and key on
        mov     ax,si
        add     al,0B0h
        call    bx

_ssy_au_next:

        inc     si
        add     di,CH_STRUCT_SIZE

        pop     cx
        loop    _ssy_au_loop



        mov     si,0

_ssy_au_reg_loop:

        mov     cl,byte [SSY_CH_REGS+si]
        cmp     cl,byte [SSY_CH_REGS_PREV+si]

        je      _ssy_au_reg_next

        mov     byte [SSY_CH_REGS_PREV+si],cl

        mov     al,byte [cs:ssy_adlib_instrument_regs+si]

        call    bx

_ssy_au_reg_next:

        inc     si
        cmp     si,6*6
        jc      _ssy_au_reg_loop

        ret



; write to adlib register
; IN: AL=register number, CL=register value

ssy_adlib_write:

        mov     dx,[cs:ssy_base_port]

        out     dx,al                           ; select register

        in      al,dx                           ; delay 1
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx

        inc     dx                              ; data register

        mov     al,cl
        out     dx,al                           ; write value

        mov     ah,22h                          ; delay 2
.t0:
        in      al,dx
        dec     ah
        jne     .t0

        ret



; write to OPL2 register via opl2lpt
; IN: AL=register number, CL=register value

ssy_opl2lpt_write:

        mov     dx,word [cs:ssy_base_port]      ; LPT data

        out     dx,al                           ; write register number to LPT data

        add     dx,2                            ; LPT ctrl

        mov     al,PP_NOT_SELECT+PP_NOT_STROBE+PP_INIT  ; toggle the init bit on/off/on
        out     dx,al
        xor     al,PP_INIT
        out     dx,al
        xor     al,PP_INIT
        out     dx,al

        in      al,dx                           ; delay 1
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx

        sub     dx,2                            ; LPT data

        mov     al,cl                           ; write register data to LPT data
        out     dx,al

        add     dx,2                            ; ctrl

        mov     al,PP_NOT_SELECT+PP_INIT        ; toggle the init bit on/off/on
        out     dx,al
        xor     al,PP_INIT
        out     dx,al
        xor     al,PP_INIT
        out     dx,al

        mov     ah,22h                          ; delay 2
.t0:
        in      al,dx
        dec     ah
        jne     .t0

        ret
