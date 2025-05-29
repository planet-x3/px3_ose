; Engine of Planet X3, a real-time strategy game originally for MS-DOS.
; Copyright (C) 2018-2025  8-Bit Productions LLC and contributors
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
;       Initialize the Covox Sound Master.
csm_init:
        mov     dx,[cs:ssy_base_port]
        ; enable tone, disable noise (for A, B, C, respectively)
        mov     al,07h
        out     dx,al
        mov     al,00111000b
        inc     dx
        out     dx,al
        dec     dx
        ret

; description:
;       Emulate the Tandy's "out 0c0h,al" on a Covox Sound Master
csm_out_c0_emu:
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
        ; tone 1 attenuation (mapped to channel A amplitude)
        mov     al,08h
        out     dx,al
        not     ah
        and     ah,0fh
        mov     al,ah
        inc     dx
        out     dx,al
        jmp     .done
.not_tone_1_attenuation:
        cmp     al,30h
        jne     .not_tone_2_attenuation
        ; tone 2 attenuation (mapped to channel B amplitude)
        mov     al,09h
        out     dx,al
        not     ah
        and     ah,0fh
        mov     al,ah
        inc     dx
        out     dx,al
        jmp     .done
.not_tone_2_attenuation:
        cmp     al,50h
        jne     .not_tone_3_attenuation
        ; tone 3 attenuation (mapped to channel C amplitude)
        mov     al,0a0h
        out     dx,al
        not     ah
        and     ah,0fh
        mov     al,ah
        inc     dx
        out     dx,al
        jmp     .done
.not_tone_3_attenuation:
        cmp     al,60h
        jne     .not_noise_control
        ; ; noise control (mapped to 2nd chip's noise period)
        ; mov     cl,ah
        ; and     cl,3
        ; cmp     cl,3
        ; je      .noise_period_custom
        ; ; set a fixed noise period as specified
        ; mov     al,6
        ; add     dx,2
        ; out     dx,al
        ; inc     dx
        ; out     dx,al
        ; mov     al,4
        ; shl     al,cl
        ; mov     byte [cs:.fixed_noise],1
        ; jmp     .done
        ; .noise_period_custom:
        ; ; let the frequency handler for tone 3 set the noise period
        ; mov     byte [cs:.fixed_noise],0
        jmp     .done
.not_noise_control:
        cmp     al,70h
        jne     .not_noise_attenuation
        ; ; noise attenuation (mapped to 2nd chip's channel A amplitude)
        ; mov     al,08h
        ; add     dx,2
        ; out     dx,al
        ; not     ah
        ; and     ah,0fh
        ; mov     al,ah
        ; inc     dx
        ; out     dx,al
        jmp     .done
.not_noise_attenuation:
        jmp     .done
.is_second_byte:
        mov     ah,al
        mov     al,[cs:.first_byte]
        cmp     al,0c0h
        jb      .not_tone_3_freq
        ; tone 3 frequency (mapped to channel C period)
        mov     bx,504h
        ; cmp     byte [cs:.fixed_noise],1
        ; je      .write_period
        ; ; update 2nd chip's noise period if noise mode is 3
        ; mov     cx,ax
        ; mov     al,6
        ; mov     dx,[cs:ssy_base_port]
        ; add     dx,2
        ; out     dx,al
        ; inc     dx
        ; mov     al,ch
        ; shr     al,1
        ; out     dx,al
        ; sub     dx,3
        ; mov     ax,cx
        jmp     .write_period
.not_tone_3_freq:
        cmp     al,0a0h
        jb      .not_tone_2_freq
        ; tone 2 frequency (mapped to channel B period)
        mov     bx,302h
        jmp     .write_period
.not_tone_2_freq:
        ; tone 1 frequency (mapped to channel A period)
        mov     bx,100h
.write_period:
        shl     al,4
        shr     ax,4

        ; write tone period to coarse and fine tune registers
        mov     dx,[cs:ssy_base_port]
        xchg    al,bl   ; write fine tune address
        out     dx,al
        xchg    al,bl   ; write fine tune value
        inc     dx
        out     dx,al
        dec     dx
        mov     al,bh   ; write coarse tune address
        out     dx,al
        mov     al,ah   ; write coarse tune value
        inc     dx
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
; .fixed_noise    db      0
