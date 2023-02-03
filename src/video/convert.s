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
; - Benedikt Freisen
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

; NOTE: Some conversion code lives in files dedicated to the respective
;       graphics card rather then here.

; description:
;       Does a single "movsb".
wrapped_movsb:
        movsb
        ret

; description:
;       Dummy function for function pointer tables.
dummy_func:
        ret

; description:
;       Prepare the color variables for CGA mode.
; parameters:
;       si: block of 2-byte color variables
prepare_color_vars_cga:
        mov     si,font_bg_black
        ; font background colors
        ; and radar colors
        mov     cx,12
        .l1:
        lodsw
        ; handle /i
        cmp     byte [cmd_arg_i],1
        jne     .not_inverted
        mov     dx,ax
        and     ax,05555h
        and     dx,0aaaah
        shl     ax,1
        shr     dx,1
        or      ax,dx
        .not_inverted:
        mov     [si-2],ax
        loop    .l1
        ret

; description:
;       Prepare the color variables for (low/medium-res.) Tandy mode.
; parameters:
;       si: block of 2-byte color variables
prepare_color_vars_tdy:
        mov     si,font_bg_black
        ; font background colors
        ; and radar colors
        mov     cx,12
        .l1:
        lodsw
        ; table lookup
        mov     bx,irgb_to_pal_lut
        xlatb
        mov     bx,VGA_TO_IRGB_LUT
        xlatb
        shr     al,4
        ; adjust format
        mov     ah,al
        shl     al,4
        or      al,ah
        mov     ah,al
        mov     [si-2],ax
        loop    .l1
        ret


INVERT_COLORS:
        ret

INVERT_TILES_BW:
        push    es,di,cx
        push    ds
        mov     ds,[TILESEG]
        xor     si,si
        push    ds
        pop     es
        mov     di,si
        mov     cx,(16384 / 2)
.L1:
        lodsw
        not     ax
        stosw
        loop    .L1
        pop     ds
        pop     cx,di,es
        ret

INVERT_SCREEN_BW:
        push    ds,di,cx
        mov     cx,(16384 / 2)
        xor     si,si
        mov     di,si
        push    es
        pop     ds
.L1:
        lodsw
        not     ax
        stosw
        loop    .L1
        pop     cx,di,ds
        ret


INVERT_SCREEN:
        push    ax,bx,cx,ds,es,di       ; save what we'll be trashing
        mov     cx,(16384 / 2)          ; 8192 words
        xor     di,di                   ; es:di = b800:0000
        mov     si,di
        push    es
        pop     ds                      ; ds:si = es:di = b800:0000

.L1:
        ; Rotate four nybbles one bit to the left, in parallel
        lodsw                           ; AX = ds:si
        mov     bx,ax                   ; ponmlkjihgfedcba
        shr     bx,3                    ; 000ponmlkjihgfed
        and     bx,0001000100010001b    ; 000p000l000h000d
        shl     ax,1                    ; onmlkjihgfedcba0
        and     ax,1110111011101110b    ; onm0kji0gfe0cba0
        or      ax,bx                   ; onmpkjilgfehcbad
        stosw                           ; AX = es:di
        loop    .L1

        pop     di,es,ds,cx,bx,ax       ; restore what we trashed
        ret
