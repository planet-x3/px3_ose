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
;       Write SID register.
; parameters:
;       al:     address
;       ah:     value
lptsid_write:
        mov     dx,[cs:ssy_base_port]
        ; set register address
        out     dx,al
        ; latch open via AUTOFEED=0
        add     dx,2
        mov     al,0000b
        out     dx,al
        ; wait
        ; TODO: find out if waiting is necessary
        ; latch lock via AUTOFEED=1
        mov     al,0010b
        out     dx,al
        ; set register value
        sub     dx,2
        mov     al,ah
        out     dx,al
        ; chip select via STROBE=1
        add     dx,2
        mov     al,0011b
        out     dx,al
        ; wait
        ; TODO: find out if waiting is necessary
        ; chip deselect via STROBE=0
        mov     al,0010b
        out     dx,al
        ret

; description:
;       Initialize the Innovation LPTSID/ParaSID dongle.
lptsid_init:
        xor     ax,ax
        .clear_regs:
        push    ax
        call    lptsid_write
        pop     ax
        inc     al
        cmp     al,25
        jne     .clear_regs

        ; voice 1 pulse width
        mov     ax,0803h
        call    lptsid_write
        ; voice 1 control
        mov     ax,4004h
        call    lptsid_write
        ; voice 2 pulse width
        mov     ax,080ah
        call    lptsid_write
        ; voice 2 control
        mov     ax,400bh
        call    lptsid_write
        ; voice 3 pulse width
        mov     ax,0811h
        call    lptsid_write
        ; voice 3 control
        mov     ax,4012h
        call    lptsid_write
        ; filter cut-off (high byte)
        mov     ax,0c816h
        call    lptsid_write
        ; filter cannel selection
        mov     ax,0717h
        call    lptsid_write
        ; filter mode and output volume
        mov     ax,1f18h
        call    lptsid_write
        ret

; description:
;       Emulate the Tandy's "out 0c0h,al" on an LPTSID/ParaSID dongle  TODO: noise channel
lptsid_out_c0_emu:
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
        and     al,70h
        cmp     al,10h
        jne     .not_tone_1_attenuation
        ; tone 1 attenuation (mapped to voice 1 sustain level)
        mov     bl,ah
        and     bx,000fh
        mov     ah,[cs:bx+ssi_out_c0_emu.vol_lut]
        mov     al,6
        call    lptsid_write
        mov     ah,[cs:bx+ssi_out_c0_emu.conf_lut1]
        mov     al,4
        call    lptsid_write
        mov     ah,[cs:bx+ssi_out_c0_emu.conf_lut2]
        mov     al,4
        call    lptsid_write
        jmp     .done
.not_tone_1_attenuation:
        cmp     al,30h
        jne     .not_tone_2_attenuation
        ; tone 2 attenuation (mapped to voice 2 sustain level)
        mov     bl,ah
        and     bx,000fh
        mov     ah,[cs:bx+ssi_out_c0_emu.vol_lut]
        mov     al,13
        call    lptsid_write
        mov     ah,[cs:bx+ssi_out_c0_emu.conf_lut1]
        mov     al,11
        call    lptsid_write
        mov     ah,[cs:bx+ssi_out_c0_emu.conf_lut2]
        mov     al,11
        call    lptsid_write
        jmp     .done
.not_tone_2_attenuation:
        cmp     al,50h
        jne     .not_tone_3_attenuation
        ; tone 3 attenuation (mapped to voice 3 sustain level)
        mov     bl,ah
        and     bx,000fh
        mov     ah,[cs:bx+ssi_out_c0_emu.vol_lut]
        mov     al,20
        call    lptsid_write
        mov     ah,[cs:bx+ssi_out_c0_emu.conf_lut1]
        mov     al,18
        call    lptsid_write
        mov     ah,[cs:bx+ssi_out_c0_emu.conf_lut2]
        mov     al,18
        call    lptsid_write
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

        mov     dx,1cah
        mov     cx,ax
        mov     ax,2e87h
        cmp     cx,dx
        jbe     .conversion_done
        div     cx
.conversion_done:

        ; write appropriate LPTSID/ParaSID frequency register
        push    ax
        mov     ah,al
        mov     al,bl
        call    lptsid_write
        pop     ax
        mov     al,bl
        call    lptsid_write
.done:
        ; restore state
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret

.first_byte     db      0
; .vol_lut        db      0f0h,0e0h,0d0h,0c0h,0d0h,0c0h,0b0h,0a0h,90h,80h,0c0h,90h,60h,40h,20h,0
; .conf_lut1      db      40h,40h,40h,40h,20h,20h,20h,20h,20h,20h,10h,10h,10h,10h,10h,10h
; .conf_lut2      db      41h,41h,41h,41h,21h,21h,21h,21h,21h,21h,11h,11h,11h,11h,11h,10h
