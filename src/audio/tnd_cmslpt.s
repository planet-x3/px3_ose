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
; - Benedikt Freisen
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

; description:
;       Select a register of the first SAA1099 chip.
; parameters:
;       dx: base port
;       al: register address
; clobbers:
;       al
cmslpt_output_first_address:
        out     dx,al
        add     dx,2
        mov     al,0ch
        out     dx,al
        mov     al,08h
        out     dx,al
        in      al,dx
        mov     al,0ch
        out     dx,al
        sub     dx,2
        ret

; description:
;       Write a previously selected register of the first SAA1099 chip.
; parameters:
;       dx: base port
;       al: register value
; clobbers:
;       al
cmslpt_output_first_data:
        out     dx,al
        add     dx,2
        mov     al,0dh
        out     dx,al
        mov     al,09h
        out     dx,al
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        mov     al,0dh
        out     dx,al
        sub     dx,2
        ret

; description:
;       Initialize the CMSLPT.
cmslpt_init:
        mov     dx,[cs:ssy_base_port]
        ; reset voices
        mov     al,1ch
        call    cmslpt_output_first_address
        mov     al,02h
        call    cmslpt_output_first_data
        ; disable noise
        mov     al,15h
        call    cmslpt_output_first_address
        mov     al,00h
        call    cmslpt_output_first_data
        ; enable voices
        mov     al,1ch
        call    cmslpt_output_first_address
        mov     al,01h
        call    cmslpt_output_first_data
        ; enable tone generators
        mov     al,14h
        call    cmslpt_output_first_address
        mov     al,15h  ; voices 4, 2, 0
        call    cmslpt_output_first_data
        ; enable noise generators
        mov     al,15h
        call    cmslpt_output_first_address
        mov     al,02h  ; voice 1
        call    cmslpt_output_first_data
        ret

; description:
;       Emulate the Tandy's "out 0c0h,al" on a CMSLPT
cmslpt_out_c0_emu:
        ; save state
        pushf
        push    ax
        push    bx
        push    cx
        push    dx

        test    al,80h
        jnz     .is_first_byte
        jmp     .is_second_byte
.is_first_byte:
        mov     [cs:.first_byte],al
        mov     ah,al
        ; handle single-byte commands
        mov     dx,[cs:ssy_base_port]
        and     al,70h
        cmp     al,10h
        jne     .not_tone_1_attenuation
        ; tone 1 attenuation (mapped to channel 4 amplitude)
        mov     al,04h
        call    cmslpt_output_first_address
        not     ah
        and     ah,0fh
        mov     al,ah
        shl     ah,4
        or      al,ah
        call    cmslpt_output_first_data
        jmp     .done
.not_tone_1_attenuation:
        cmp     al,30h
        jne     .not_tone_2_attenuation
        ; tone 2 attenuation (mapped to channel 2 amplitude)
        mov     al,02h
        call    cmslpt_output_first_address
        not     ah
        and     ah,0fh
        mov     al,ah
        shl     ah,4
        shr     al,1
        or      al,ah
        call    cmslpt_output_first_data
        jmp     .done
.not_tone_2_attenuation:
        cmp     al,50h
        jne     .not_tone_3_attenuation
        ; tone 3 attenuation (mapped to channel 0 amplitude)
        mov     al,00h
        call    cmslpt_output_first_address
        not     ah
        and     ah,0fh
        mov     al,ah
        shl     ah,3
        and     ah,0f0h
        or      al,ah
        call    cmslpt_output_first_data
        jmp     .done
.not_tone_3_attenuation:
        cmp     al,60h
        jne     .not_noise_control
        ; noise control (mapped to noise generator 0 control -- lower nibble)
        mov     al,16h
        call    cmslpt_output_first_address
        mov     al,ah
        and     al,03h
        call    cmslpt_output_first_data
        jmp     .done
.not_noise_control:
        cmp     al,70h
        jne     .not_noise_attenuation
        ; noise attenuation (mapped to channel 1 amplitude)
        mov     al,01h
        call    cmslpt_output_first_address
        not     ah
        and     ah,0fh
        mov     al,ah
        shl     ah,4
        or      al,ah
        call    cmslpt_output_first_data
        jmp     .done
.not_noise_attenuation:
        jmp     .done
.is_second_byte:
        mov     ah,al
        mov     al,[cs:.first_byte]
        cmp     al,0c0h
        jb      .not_tone_3_freq
        ; tone 3 frequency (mapped to channel 0 frequency/octave)
        mov     bx,1008h
        jmp     .do_convert
.not_tone_3_freq:
        cmp     al,0a0h
        jb      .not_tone_2_freq
        ; tone 2 frequency (mapped to channel 2 frequency/octave)
        mov     bx,110ah
        jmp     .do_convert
.not_tone_2_freq:
        ; tone 1 frequency (mapped to channel 4 frequency/octave)
        mov     bx,120ch
.do_convert:
        shl     al,4

        mov     cl,7
        mov     dx,512
        cmp     ax,dx
        jb      .conversion_done
        dec     cl
        shr     ax,1
        cmp     ax,dx
        jb      .conversion_done
        dec     cl
        shr     ax,1
        cmp     ax,dx
        jb      .conversion_done
        dec     cl
        shr     ax,1
        cmp     ax,dx
        jb      .conversion_done
        dec     cl
        shr     ax,1
        cmp     ax,dx
        jb      .conversion_done
        dec     cl
        shr     ax,1
        cmp     ax,dx
        jb      .conversion_done
        dec     cl
        shr     ax,1
.conversion_done:
        not     ax

        ; write CMS frequency and octave registers
        mov     dx,[cs:ssy_base_port]
        push    ax
        mov     al,bl   ; write frequency address
        call    cmslpt_output_first_address
        pop     ax      ; write frequency value
        call    cmslpt_output_first_data
        mov     al,bh   ; write octave address
        call    cmslpt_output_first_address
        mov     al,cl   ; write octave value
        call    cmslpt_output_first_data
.done:
        ; restore state
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret

.first_byte     db      0
