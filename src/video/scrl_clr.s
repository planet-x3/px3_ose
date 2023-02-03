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
;       Scrolls the contents of a rectangle up by one text line (= six logical pixels).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen, excluding the last text line
scroll_up_cga:
        push    cx
        push    si
        shr     cx,2
        mov     dx,80
        sub     dx,cx
        sub     dx,cx
        push    ds
        push    es
        pop     ds
        mov     si,di
        add     si,80*3
.L1:
        push    cx
        rep     movsw
        pop     cx
        add     si,dx
        add     di,dx
        add     si,8192-80
        add     di,8192-80
        dec     bx
        jz      .L2
        push    cx
        rep     movsw
        pop     cx
        add     si,dx
        add     di,dx
        sub     si,8192
        sub     di,8192
        dec     bx
        jnz     .L1
.L2:
        pop     ds
        pop     si
        pop     cx
        mov     bx,6
        tcall   clear_rect_cga

; description:
;       Clears a rectangle on screen (nominally white) on CGA.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_white_cga:
        not     word [cs:screen_xor]
        call    clear_rect_cga
        not     word [cs:screen_xor]
        ret

; description:
;       Clears a rectangle on screen (nominally black) on CGA.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_cga:
        mov     ax,[cs:screen_xor]
        shr     cx,1
.yloop:
        push    cx
        push    di
        shr     cx,1
        jnc     .even_width
        stosb
.even_width:
        rep     stosw
        pop     di
        pop     cx
        test    di,2000h
        jz      .even_line
        sub     di,8192+8192-80
.even_line:
        add     di,8192
        dec     bx
        jnz     .yloop
        ret

; description:
;       Calculate offset in video memory from coordinates on a logical 160x200 screen.
; parameters:
;       di: logical coordinates (Y in upper byte, X in lower byte)
; returns:
;       di: offset in video memory (es)
calc_screen_offset_cga:
        mov     cx,di
        and     ch,0feh
        mov     bl,ch
        mov     al,40
        mov     ch,0
        mul     bl
        shr     cl,1
        add     ax,cx
        test    di,100h
        jz      .L1
        or      ah,20h
.L1:
        mov     di,ax
        ret
