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

; NOTE:
; AY-LPT wiring: BC1 on pin 17, BDIR on pin 1, RST on pin 16
; parallel port "control" reg.:
; port: Base+2   pins: (MSB) -, -, -, -, ~17, 16, ~14, ~1 (LSB)
; 1111: inactive
; 0111: read from PSG (avoid this!)
; 1110: write to PSG
; 0110: latch address

; description:
;       Select a register of the first AY-3-891x chip.
; parameters:
;       dx: base port
;       al: register address
; clobbers:
;       al
aylpt_output_first_address:
        out     dx,al
        add     dx,2
        mov     al,1111b
        out     dx,al
        mov     al,0110b
        out     dx,al
        in      al,dx
        mov     al,1111b
        out     dx,al
        sub     dx,2
        ret

; description:
;       Write a previously selected register of the first AY-3-891x chip.
; parameters:
;       dx: base port
;       al: register value
; clobbers:
;       al
aylpt_output_first_data:
        out     dx,al
        add     dx,2
        mov     al,1111b
        out     dx,al
        mov     al,1110b
        out     dx,al
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        mov     al,1111b
        out     dx,al
        sub     dx,2
        ret

; description:
;       Initialize the AY-LPT.  TODO
aylpt_init:
        mov     dx,[cs:ssy_base_port]
        ; reset device
        add     dx,2
        mov     al,1011b
        out     dx,al
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        mov     al,1111b
        out     dx,al
        sub     dx,2
        ; enable tone, disable noise (for A, B, C, respectively)
        mov     al,07h
        call    aylpt_output_first_address
        mov     al,00111000b
        call    aylpt_output_first_data
        ; ; reset voices
        ; mov     al,1ch
        ; call    aylpt_output_first_address
        ; mov     al,02h
        ; call    aylpt_output_first_data
        ; ; disable noise
        ; mov     al,15h
        ; call    aylpt_output_first_address
        ; mov     al,00h
        ; call    aylpt_output_first_data
        ; ; enable voices
        ; mov     al,1ch
        ; call    aylpt_output_first_address
        ; mov     al,01h
        ; call    aylpt_output_first_data
        ; ; enable tone generators
        ; mov     al,14h
        ; call    aylpt_output_first_address
        ; mov     al,15h  ; voices 4, 2, 0
        ; call    aylpt_output_first_data
        ; ; enable noise generators
        ; mov     al,15h
        ; call    aylpt_output_first_address
        ; mov     al,02h  ; voice 1
        ; call    aylpt_output_first_data
        ret

; description:
;       Emulate the Tandy's "out 0c0h,al" on an AY-LPT
aylpt_out_c0_emu:
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
        call    aylpt_output_first_address
        not     ah
        and     ah,0fh
        mov     al,ah
        call    aylpt_output_first_data
        jmp     .done
.not_tone_1_attenuation:
        cmp     al,30h
        jne     .not_tone_2_attenuation
        ; tone 2 attenuation (mapped to channel B amplitude)
        mov     al,09h
        call    aylpt_output_first_address
        not     ah
        and     ah,0fh
        mov     al,ah
        call    aylpt_output_first_data
        jmp     .done
.not_tone_2_attenuation:
        cmp     al,50h
        jne     .not_tone_3_attenuation
        ; tone 3 attenuation (mapped to channel C amplitude)
        mov     al,0a0h
        call    aylpt_output_first_address
        not     ah
        and     ah,0fh
        mov     al,ah
        call    aylpt_output_first_data
        jmp     .done
.not_tone_3_attenuation:
        cmp     al,60h
        jne     .not_noise_control
        ; ; noise control (mapped to noise generator 0 control -- lower nibble)
        ; mov     al,16h
        ; call    aylpt_output_first_address
        ; mov     al,ah
        ; and     al,03h
        ; call    aylpt_output_first_data
        jmp     .done
.not_noise_control:
        cmp     al,70h
        jne     .not_noise_attenuation
        ; ; noise attenuation (mapped to channel 1 amplitude)
        ; mov     al,01h
        ; call    aylpt_output_first_address
        ; not     ah
        ; and     ah,0fh
        ; mov     al,ah
        ; shl     ah,4
        ; or      al,ah
        ; call    aylpt_output_first_data
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
        push    ax
        mov     al,bl   ; write fine tune address
        call    aylpt_output_first_address
        pop     ax      ; write fine tune value
        call    aylpt_output_first_data
        mov     al,bh   ; write coarse tune address
        call    aylpt_output_first_address
        mov     al,ah   ; write coarse tune value
        call    aylpt_output_first_data
.done:
        ; restore state
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret

.first_byte     db      0
