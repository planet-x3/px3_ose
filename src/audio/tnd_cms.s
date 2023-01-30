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
;       Initialize the Creative Music System / Game Blaster.
cms_init:
        mov     dx,[cs:ssy_base_port]
        ; reset voices
        inc     dx
        mov     al,1ch
        out     dx,al
        dec     dx
        mov     al,02h
        out     dx,al
        ; disable noise
        inc     dx
        mov     al,15h
        out     dx,al
        dec     dx
        mov     al,00h
        out     dx,al
        ; enable voices
        inc     dx
        mov     al,1ch
        out     dx,al
        dec     dx
        mov     al,01h
        out     dx,al
        ; enable tone generators
        inc     dx
        mov     al,14h
        out     dx,al
        dec     dx
        mov     al,15h  ; voices 4, 2, 0
        out     dx,al
        ; enable noise generators
        inc     dx
        mov     al,15h
        out     dx,al
        dec     dx
        mov     al,02h  ; voice 1
        out     dx,al
        ret

; description:
;       Emulate the Tandy's "out 0c0h,al" on a CMS
cms_out_c0_emu:
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
        inc     dx
        and     al,70h
        cmp     al,10h
        jne     .not_tone_1_attenuation
        ; tone 1 attenuation (mapped to channel 4 amplitude)
        mov     al,04h
        out     dx,al
        not     ah
        and     ah,0fh
        mov     al,ah
        shl     ah,4
        or      al,ah
        dec     dx
        out     dx,al
        jmp     .done
.not_tone_1_attenuation:
        cmp     al,30h
        jne     .not_tone_2_attenuation
        ; tone 2 attenuation (mapped to channel 2 amplitude)
        mov     al,02h
        out     dx,al
        not     ah
        and     ah,0fh
        mov     al,ah
        shl     ah,4
        shr     al,1
        or      al,ah
        dec     dx
        out     dx,al
        jmp     .done
.not_tone_2_attenuation:
        cmp     al,50h
        jne     .not_tone_3_attenuation
        ; tone 3 attenuation (mapped to channel 0 amplitude)
        mov     al,00h
        out     dx,al
        not     ah
        and     ah,0fh
        mov     al,ah
        shl     ah,3
        and     ah,0f0h
        or      al,ah
        dec     dx
        out     dx,al
        jmp     .done
.not_tone_3_attenuation:
        cmp     al,60h
        jne     .not_noise_control
        ; noise control (mapped to noise generator 0 control -- lower nibble)
        mov     al,16h
        out     dx,al
        mov     al,ah
        and     al,03h
        dec     dx
        out     dx,al
        jmp     .done
.not_noise_control:
        cmp     al,70h
        jne     .not_noise_attenuation
        ; noise attenuation (mapped to channel 1 amplitude)
        mov     al,01h
        out     dx,al
        not     ah
        and     ah,0fh
        mov     al,ah
        shl     ah,4
        or      al,ah
        dec     dx
        out     dx,al
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
        inc     dx
        push    ax
        mov     al,bl   ; write frequency address
        out     dx,al
        pop     ax      ; write frequency value
        dec     dx
        out     dx,al
        inc     dx
        mov     al,bh   ; write octave address
        out     dx,al
        dec     dx
        mov     al,cl   ; write octave value
        out     dx,al
.done:
        ; restore state
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret

.first_byte     db      0
