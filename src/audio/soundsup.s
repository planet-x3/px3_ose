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
; - David Murray*
; - Alex Semenov*
; - Benedikt Freisen
; - Michal Prochazka
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

; Supplimental sound variables and code

SSY_SEG                 dw      0

SOUNDMENU               db      "ah"
                        db      10,"Choose audio device for music: (/a)",13,10
                        db      "-----------------------------------",13,10
                        db      "a-None",13,10
                        db      "b-PC Speaker",13,10
                        db      "c-Tandy/PCjr",13,10
                        db      "d-TNDLPT",13,10
                        db      "e-AdLib",13,10
                        db      "f-OPL2LPT",13,10
                        db      "g-General MIDI (Roland SC-55, etc.)",13,10
                        db      "h-Roland MT-32 and compatibles",13,10
                        db      "$"
                        ; NOTE: The following letters are tentatively reserved for:
                        ;       k-Innovation SSI-2001
                        ;       l-LPTSID
                        ;       m-Mockingboard
                        ;       n-AY-LPT


LPTMENU                 db      "13"
                        db      10,"Choose LPT port:",13,10
                        db      "1-LPT1 (378h)",13,10
                        db      "2-LPT2 (278h)",13,10
                        db      "3-LPT3 (3BCh)",13,10,"$"


SOUND_INITIALIZED       db      0
ADLIB_PORT              dw      0 ; "0" = Adlib 388h, or LPT port for OPL2LPT

mname_sounds            db      "sounds.bin",0
mname_menu              db      "x_menu.bin",0

;========================================================================
; Music filename section -- add your music filenames here.
; Filenames must follow the template "?_xxxxxx.bin",0
; where "?" is "s" for speaker, "t" for tandy, or "a" for adlib versions,
; and "xxxxxx" is up to 6 characters for the music name.  So, you should
; have files included with the game that look like this:
;
;  s_happy.bin
;  t_happy.bin
;  a_happy.bin
;  s_murray.bin
;  t_murray.bin
;  a_murray.bin
;  s_menu.bin
;  t_menu.bin
;  a_menu.bin
;
; ...etc.
;
; Make sure you increase NUM_MUSIC_FILES when you add more.
; Also add to mname_offsets.

NUM_MUSIC_FILES         equ     15

; Music filenames go here:
mname_music0            db      "?_MENU.BIN",0
mname_music1            db      "?_MUS01.BIN",0
mname_music2            db      "?_MUS02.BIN",0
mname_music3            db      "?_MUS03.BIN",0
mname_music4            db      "?_MUS04.BIN",0
mname_music5            db      "?_MUS05.BIN",0
mname_music6            db      "?_MUS06.BIN",0
mname_music7            db      "?_MUS07.BIN",0
mname_music8            db      "?_WIN.BIN",0
mname_music9            db      "?_LOSE.BIN",0

mname_andrs1            db      "?_ANDRS1.BIN",0
mname_andrs2            db      "?_ANDRS2.BIN",0
mname_andrs3            db      "?_ANDRS3.BIN",0
mname_andrs4            db      "?_ANDRS4.BIN",0

mname_music_init        db      "?_INIT.BIN",0

; ALSO, update this music filename offsets table:
mname_offsets           dw      mname_music0
                        dw      mname_music1
                        dw      mname_music2
                        dw      mname_music3
                        dw      mname_music4
                        dw      mname_music5
                        dw      mname_music6
                        dw      mname_music7
                        dw      mname_music8
                        dw      mname_music9
                        dw      mname_andrs1
                        dw      mname_andrs2
                        dw      mname_andrs3
                        dw      mname_andrs4
                        dw      mname_music_init

MT32_INIT_INDEX         equ     14

;========================================================================
; Ask user for sound device they want to use for music.
ask_sound:
        ; Ask user for sound device
        push    si
        mov     si,SOUNDMENU
        ; if a valid mode has been requested via command line, use that one instead
        mov     al,[cmd_arg_a]
        cmp     al,[si]                 ; compare to start of allowed character range
        jb      .ask_anyway
        cmp     al,[si+1]               ; compare to end of allowed character range
        ja      .ask_anyway
        jmp     .skip
        .ask_anyway:
        call    askchoice
        .skip:
        pop     si
        mov     bh,0
        mov     bl,al
        sub     bx,'a'
        cmp     bx,10                   ; highest sound device number
        jnb     ask_sound
        shl     bx,1
        mov     si,[.block_addr_lut+bx]
        call    set_music_mode_vars
        cmp     word [cmd_arg_p],0      ; check for port override option
        je      .no_port_override
        mov     ax,[cmd_arg_p]
        mov     [ssy_base_port],ax
        .no_port_override:
        cmp     byte [ssy_uses_lpt],0
        je      .l1
        cmp     word [ssy_base_port],0
        jne     .l1                     ; ssy_base_port overridden by /p => no prompt
        call    LPTsetup
.l1:
        call    [ssy_device_init_func]
        ret

.block_addr_lut dw      music_mode_vars
                dw      music_mode_vars_speaker
                dw      music_mode_vars_tandy
                dw      music_mode_vars_tndlpt
                dw      music_mode_vars_adlib
                dw      music_mode_vars_opl2lpt
                dw      music_mode_vars_gm
                dw      music_mode_vars_mt32

LPTsetup:
        mov     si,LPTMENU
        call    askchoice
        mov     bx,ssy_base_port
        cmp     al,'1'
        jne     .A2
        mov     WORD [bx],0378h
        jmp     .E1
.A2:
        cmp     al,'2'
        jne     .A3
        mov     WORD [bx],0278h
        jmp     .E1
.A3:
        mov     WORD [bx],03BCh
.E1:
        RET

;========================================================================
; Initialize sound system
set_sound:
        ; load sound effects
        push    es
        push    di

        mov     si,mname_sounds         ; ds:si = filename
        mov     bp,[SSY_SEG]
        mov     es,bp
        mov     di,[ssy_mus_data_size]  ; es:di = SSY_SEG:SSY_SFX_DATA
        mov     cx,SSY_SFX_DATA_SIZE    ; maximum size of soundfx data
        call    loadfile

        ; cmp     byte [ssy_file_name_marker],0
        ; je      .no_sound

        ; init sound
        call    ssy_init
        mov     dx,[ADLIB_PORT]         ; 0=adlib, otherwise LPT port
        call    ssy_opl_output          ; enable OPL2LPT

        ; Start music playing
        call    ssy_music_play
        mov     BYTE [SOUND_INITIALIZED],1

        .no_sound:
        pop     di
        pop     es
        ret

;========================================================================
; loads the main menu music
m_loadmenu:
        push    ax
        xor     ax,ax                   ; al = 0 = our main menu music
        call    m_loadmusic
        pop     ax
        ret

;========================================================================
; loads the music file for whatever MAP_NUMBER is
m_loadmapmusic:
        push    ax
        push    bx

        xor     bx,bx
        mov     bl,[MAP_NUMBER]         ; bx = get table index to use
        mov     al,mapmusicset[bx]      ; al = translate into music # to load
        sub     al,'0'
        call    m_loadmusic             ; load music # al

        pop     bx
        pop     ax
        ret

;========================================================================
; INPUT: al = map music to load, where al is from 0 to NUM_MUSIC FILES-1
m_loadmusic:
        push    si
        push    bx
        mov     [active_track],al       ; keep track of the track number
        cmp     byte [ssy_file_name_marker],0
        je      .skip                   ; no audio device configured => skip
        xor     bx,bx
        mov     bl,al                   ; bl = number music filename to load
        cmp     bl,NUM_MUSIC_FILES      ; is it larger than what's availble?
        jb      .S0                     ; skip clamping if it is ok
        xor     bl,bl                   ; force to 0 if number was invalid
.S0:
        shl     bl,1                    ; adjust to word offset
        mov     si,mname_offsets[bx]    ; look up filename offset from table
        call    m_loadmusicfile         ; load the music file and play it
        .skip:
        pop     bx
        pop     si
        ret

;========================================================================
; sets music on or off based on MUSIC_ON
m_setmusicstate:
        cmp     BYTE [MUSIC_ON],1
        jne     .D0
        cmp     byte [track_not_loaded],1
        je      .D0
        call    ssy_music_play
        ret
.D0:
        call    ssy_music_stop
        ret


;========================================================================
; INPUT: al = sound effect to play.  Honors state of SOUNDFX_ON.
m_playSFX:
        cmp     BYTE [SOUNDFX_ON],1
        jne     .D0
        call    ssy_sound_play
.D0:
        ret

;========================================================================
; INPUT: ds:si = null-terminated filename template string
; Stops the current music file playing,
; loads the filename at ds:si,
; and starts the new music playing if initialized and not paused
m_loadmusicfile:
        ; adjust which file we're loading using marker character
        push    bx
        mov     bl,[ssy_file_name_marker]
        mov     [si],bl
        pop     bx

        ; stop current music playing before we load a new file
        cmp     BYTE [SOUND_INITIALIZED],1      ; sound initialzed?
        jne     .N0                             ; skip if not
        push    si
        call    ssy_music_stop                  ; stop music playing
        pop     si
.N0:
        ; load the new file
        push    es
        mov     es,[SSY_SEG]
        mov     di,SSY_MUS_DATA  ; es:di = SSY_SEG:SSY_SFX_DATA
        mov     cx,[ssy_mus_data_size]          ; maximum size of music data
        call    loadtrack                       ; will set track_not_loaded on failure
        pop     es

        ; start new music playing if initialized and not turned off
        cmp     BYTE [SOUND_INITIALIZED],1      ; sound initialzed?
        jne     .N1                             ; skip if not
        call    m_setmusicstate                 ; start music playing
.N1:
        ret


;==============================
; Clear an area of memory, to prevent repeated re-loads from confusing
; the music system and/or the main program
; input:  ax=segment to clear; cx=number of bytes to clear
clearmem:
        push    es,di,ax,cx             ; save everything we're mangling
        pushf                           ; ...including flags
        mov     es,ax
        xor     di,di                   ; es:di = area to clear
        mov     ax,di                   ; ax = 0 = our clear value
        shr     cx,1                    ; adjust cx for words
        rep     stosw                   ; bombs away
        adc     cx,0                    ; if cx was odd number, cx=1
        rep     stosw                   ; do either 0 or 1 more STOSWs
        popf
        pop     cx,ax,di,es
        ret

;==============================
; Make an engine sound, since this is a common operation

; sfx_engine:
;         push    ax
;         mov     al,2                    ; selects order "2" in SOUNDS.P3M
;         call    m_playSFX               ; play sound effect
;         pop     ax
;         ret


; SOUND EFFECT DESCRIPTIONS
; -------------------------
; A 00-error
; B 01-error
; C 02-explosion
; D 03-
; E 04-shoot something
; F 05-missile
; G 06-convert to/from sentry
; H 07-beep (change menu item)
; I 08-explosion
; J 09-beep
; K 10-beep
; L 11-bulldoze
; M 12-
; N 13-beep
; O 14-beep (set construction)
; P 15-
; Q 16-longer explosion
; R 17-movement
; S 18-short beep
; T 19-another beep
; U 20-radar scan
; V 21-self destruct
