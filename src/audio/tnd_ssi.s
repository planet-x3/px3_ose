; Engine of Planet X3, a real-time strategy game originally for MS-DOS.
; Copyright (C) 2018-2024  8-Bit Productions LLC and contributors
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
;       Initialize the Innovation SSI-2001.
ssi_init:
        mov     dx,[cs:ssy_base_port]

        xor     ax,ax
        .clear_regs:
        out     dx,al
        inc     dx
        inc     ah
        cmp     ah,25
        jne     .clear_regs

        mov     dx,[cs:ssy_base_port]
        ; voice 1 pulse width
        add     dx,3
        mov     al,08h
        out     dx,al
        ; voice 1 control
        inc     dx
        mov     al,40h
        out     dx,al
        ; voice 2 pulse width
        add     dx,6
        mov     al,08h
        out     dx,al
        ; voice 2 control
        inc     dx
        mov     al,40h
        out     dx,al
        ; voice 3 pulse width
        add     dx,6
        mov     al,08h
        out     dx,al
        ; voice 3 control
        inc     dx
        mov     al,40h
        out     dx,al
        ; filter cut-off (high byte)
        add     dx,4
        mov     al,0c8h
        out     dx,al
        ; filter cannel selection
        inc     dx
        mov     al,07h
        out     dx,al
        ; filter mode and output volume
        inc     dx
        mov     al,1fh
        out     dx,al
        ret

; description:
;       Emulate the Tandy's "out 0c0h,al" on an SSI-2001  TODO: noise channel
ssi_out_c0_emu:
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
        ; tone 1 attenuation (mapped to voice 1 sustain level)
        mov     bl,ah
        and     bx,000fh
        mov     al,[cs:bx+.vol_lut]
        add     dx,6
        out     dx,al
        dec     dx
        dec     dx
        mov     al,[cs:bx+.conf_lut1]
        out     dx,al
        mov     al,[cs:bx+.conf_lut2]
        out     dx,al
        jmp     .done
.not_tone_1_attenuation:
        cmp     al,30h
        jne     .not_tone_2_attenuation
        ; tone 2 attenuation (mapped to voice 2 sustain level)
        mov     bl,ah
        and     bx,000fh
        mov     al,[cs:bx+.vol_lut]
        add     dx,13
        out     dx,al
        dec     dx
        dec     dx
        mov     al,[cs:bx+.conf_lut1]
        out     dx,al
        mov     al,[cs:bx+.conf_lut2]
        out     dx,al
        jmp     .done
.not_tone_2_attenuation:
        cmp     al,50h
        jne     .not_tone_3_attenuation
        ; tone 3 attenuation (mapped to voice 3 sustain level)
        mov     bl,ah
        and     bx,000fh
        mov     al,[cs:bx+.vol_lut]
        add     dx,20
        out     dx,al
        dec     dx
        dec     dx
        mov     al,[cs:bx+.conf_lut1]
        out     dx,al
        mov     al,[cs:bx+.conf_lut2]
        out     dx,al
        jmp     .done
.not_tone_3_attenuation:
        cmp     al,60h
        jne     .not_noise_control
        ; noise control (currently ignored)
        jmp     .done
.not_noise_control:
        cmp     al,70h
        jne     .not_noise_attenuation
        ; noise attenuation (currently ignored)
        jmp     .done
.not_noise_attenuation:
        jmp     .done
.is_second_byte:
        mov     ah,al
        mov     al,[cs:.first_byte]
        cmp     al,0c0h
        jb      .not_tone_3_freq
        ; tone 3 frequency (mapped to voice 3 frequency)
        mov     bx,14
        jmp     .do_convert
.not_tone_3_freq:
        cmp     al,0a0h
        jb      .not_tone_2_freq
        ; tone 2 frequency (mapped to voice 2 frequency)
        mov     bx,7
        jmp     .do_convert
.not_tone_2_freq:
        ; tone 1 frequency (mapped to voice 1 frequency)
        mov     bx,0
.do_convert:
        shl     al,4

        mov     dx,200h
        mov     cx,ax
        xor     ax,ax
        cmp     cx,dx
        jbe     .conversion_done
        div     cx
.conversion_done:

        ; write appropriate SSI-2001 frequency register
        mov     dx,[cs:ssy_base_port]
        add     dx,bx
        out     dx,al
        inc     dx
        mov     al,ah
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
.vol_lut        db      0f0h,0e0h,0d0h,0c0h,0d0h,0c0h,0b0h,0a0h,90h,80h,0c0h,90h,60h,40h,20h,0
.conf_lut1      db      40h,40h,40h,40h,20h,20h,20h,20h,20h,20h,10h,10h,10h,10h,10h,10h
.conf_lut2      db      41h,41h,41h,41h,21h,21h,21h,21h,21h,21h,11h,11h,11h,11h,11h,10h
