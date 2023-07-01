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
;       Clears a rectangle on screen (nominally white) on Plantronics ColorPlus.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_white_plantronics:
        not     word [cs:screen_xor]
        call    clear_rect_plantronics
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
;       Clears a rectangle on screen (nominally black) on Plantronics ColorPlus.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_plantronics:
        push    di
        push    cx
        push    bx
        call    clear_rect_cga
        pop     bx
        pop     cx
        pop     di
        add     di,16384
        tcall   clear_rect_cga

; description:
;       Scrolls the contents of a rectangle up by one text line (= six logical pixels).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen, excluding the last text line
scroll_up_plantronics:
        push    di
        push    cx
        push    bx
        call    scroll_up_cga
        pop     bx
        pop     cx
        pop     di
        add     di,16384
        tcall   scroll_up_cga

; description:
;       Scrolls the contents of a rectangle up by one text line (= six logical pixels).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen, excluding the last text line
scroll_up_pc1512:
        push    di,cx,bx
        mov     dx,3ddh
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,3
        out     dx,al
        call    scroll_up_cga
        pop     bx,cx,di
        push    di,cx,bx
        mov     dx,3ddh
        mov     al,4
        out     dx,al
        inc     dx
        mov     al,2
        out     dx,al
        call    scroll_up_cga
        pop     bx,cx,di
        push    di,cx,bx
        mov     dx,3ddh
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,1
        out     dx,al
        call    scroll_up_cga
        pop     bx,cx,di
        mov     dx,3ddh
        mov     al,1
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        call    scroll_up_cga
        mov     dx,3ddh
        mov     al,0fh
        out     dx,al
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

; description:
;       Calculate offset in video memory from coordinates on a logical 160x200 screen.
; parameters:
;       di: logical coordinates (Y in upper byte, X in lower byte)
; returns:
;       di: offset in video memory (es)
calc_screen_offset_text:
        call    calc_screen_offset_cga
        and     di,0fffeh
        ret

; description:
;       Calculate offset in video memory from coordinates on a logical 160x200 screen.
; parameters:
;       di: logical coordinates (Y in upper byte, X in lower byte)
; returns:
;       di: offset in video memory (es)
calc_screen_offset_vga:
        mov     cx,di
        mov     bl,ch
        mov     al,160
        mov     ch,0
        mul     bl
        add     ax,cx
        shl     ax,1
        mov     di,ax
        ret

; description:
;       Clears a rectangle on screen (nominally white) on Tandy (medium resolution).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_white_mtdy:
        mov     ax,0ffffh
        tcall   clear_rect_mtdy.L1

; description:
;       Clears a rectangle on screen (nominally black) on Tandy (medium resolution).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_mtdy:
        xor     ax,ax
.L1:
        push    cx
        push    di
        rep     stosb
        pop     di
        pop     cx
        add     di,2000h
        jno     .nowrap
        sub     di,8000h-160
        .nowrap:
        dec     bx
        jnz     .L1
        ret

; description:
;       Scrolls the contents of a rectangle up by one text line (= six logical pixels).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen, excluding the last text line
scroll_up_mtdy:
        push    cx
        push    si
        shr     cx,1
        mov     dx,cx
        shl     dx,1
        push    ds
        push    es
        pop     ds
        mov     si,di
        add     si,4000h+160
        jno     .nowrap1
        sub     si,8000h-160
        .nowrap1:
.L1:
        push    cx
        rep     movsw
        pop     cx
        sub     si,dx
        sub     di,dx
        add     si,2000h
        jno     .nowrap2
        sub     si,8000h-160
        .nowrap2:
        add     di,2000h
        jno     .nowrap3
        sub     di,8000h-160
        .nowrap3:
        dec     bx
        jnz     .L1

        pop     ds
        pop     si
        pop     cx
        mov     bx,6
        tcall   clear_rect_mtdy

; description:
;       Calculate offset in video memory from coordinates on a logical 160x200 screen.
; parameters:
;       di: logical coordinates (Y in upper byte, X in lower byte)
; returns:
;       di: offset in video memory (es)
calc_screen_offset_mtdy:
        mov     cx,di
        mov     bl,ch
        shr     bl,2
        mov     al,160
        mul     bl
        mov     bl,ch
        mov     ch,0
        add     ax,cx
        and     bl,3
        shl     bl,5
        or      ah,bl
        mov     di,ax
        ret

; description:
;       Clears a rectangle on screen (nominally white) on ATI Graphics Solution.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_white_atigs:
        mov     ax,0ffffh
        tcall   clear_rect_atigs.L1

; description:
;       Clears a rectangle on screen (nominally black) on ATI Graphics Solution.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_atigs:
        xor     ax,ax
.L1:
        push    cx
        push    di
        rep     stosb
        pop     di
        pop     cx
        push    cx
        push    di
        add     di,32768
        rep     stosb
        pop     di
        pop     cx
        add     di,2000h
        jno     .nowrap
        sub     di,8000h-160
        .nowrap:
        dec     bx
        jnz     .L1
        ret

; description:
;       Scrolls the contents of a rectangle up by one text line (= six logical pixels).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen, excluding the last text line
scroll_up_atigs:
        push    di
        push    cx
        push    bx
        mov     ax,es
        add     ax,800h
        mov     es,ax
        call    scroll_up_mtdy
        mov     ax,es
        sub     ax,800h
        mov     es,ax
        pop     bx
        pop     cx
        pop     di
        tcall   scroll_up_mtdy

; description:
;       Scrolls the contents of a rectangle up by one text line (= six logical pixels).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen, excluding the last text line
scroll_up_ega:
        mov     dx,3ceh
        mov     al,8
        out     dx,al   ;select bit mask reg
        inc     dx
        mov     al,00h
        out     dx,al   ;write bit mask reg

        push    cx
        push    si
        shr     cx,1
        mov     dx,80
        sub     dx,cx
        push    ds
        push    es
        pop     ds
        mov     si,di
        add     si,80*6
.L1:
        push    cx
        rep     movsb
        pop     cx
        add     si,dx
        add     di,dx
        dec     bx
        jnz     .L1

        mov     dx,3ceh
        mov     al,8
        out     dx,al   ;select bit mask reg
        inc     dx
        mov     al,0ffh
        out     dx,al   ;write bit mask reg

        pop     ds
        pop     si
        pop     cx
        mov     bx,6
        tcall   clear_rect_ega

; description:
;       Clears a rectangle on screen (nominally white) on EGA.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_white_ega:
        mov     ax,0ffffh
        tcall   clear_rect_ega.L0

; description:
;       Clears a rectangle on screen (nominally black) on EGA.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_ega:
        xor     ax,ax
.L0:
        mov     dx,160
        sub     dx,cx
        inc     dx
        shr     dx,1
.L1:
        push    cx
        shr     cx,1
        shr     cx,1
        jnc     .L2
        stosb
.L2:
        rep     stosw
        add     di,dx
        pop     cx
        dec     bx
        jnz     .L1
        ret

; description:
;       Calculate offset in video memory from coordinates on a logical 160x200 screen.
; parameters:
;       di: logical coordinates (Y in upper byte, X in lower byte)
; returns:
;       di: offset in video memory (es)
calc_screen_offset_ega:
        mov     cx,di
        mov     bl,ch
        mov     al,160
        mov     ch,0
        mul     bl
        add     ax,cx
        shr     ax,1
        mov     di,ax
        ret

; description:
;       Scrolls the contents of a rectangle up by one text line (= six logical pixels).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen, excluding the last text line
scroll_up_ega_mono:
        mov     ax,bx
        shr     ax,1
        add     bx,ax
        mov     dx,3ceh
        mov     al,8
        out     dx,al   ;select bit mask reg
        inc     dx
        mov     al,00h
        out     dx,al   ;write bit mask reg

        push    cx
        push    si
        shr     cx,1
        mov     dx,80
        sub     dx,cx
        push    ds
        push    es
        pop     ds
        mov     si,di
        add     si,80*9
.L1:
        push    cx
        rep     movsb
        pop     cx
        add     si,dx
        add     di,dx
        dec     bx
        jnz     .L1

        mov     dx,3ceh
        mov     al,8
        out     dx,al   ;select bit mask reg
        inc     dx
        mov     al,0ffh
        out     dx,al   ;write bit mask reg

        pop     ds
        pop     si
        pop     cx
        mov     bx,6
        tcall   clear_rect_ega_mono

; description:
;       Calculate offset in video memory from coordinates on a logical 160x200 screen.
; parameters:
;       di: logical coordinates (Y in upper byte, X in lower byte)
; returns:
;       di: offset in video memory (es)
calc_screen_offset_ega_mono:
        mov     cx,di
        mov     bl,ch
        shr     bl,1
        sbb     bh,bh
        and     bh,80
        mov     al,240
        mov     ch,0
        mul     bl
        add     al,bh
        adc     ah,0
        shr     cx,1
        add     ax,cx
        add     ax,2000
        mov     di,ax
        ret

; description:
;       Clears a rectangle on screen (nominally white) on monochrome EGA.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_white_ega_mono:
        mov     ax,bx
        shr     ax,1
        add     bx,ax
        mov     ax,0ffffh
        tcall   clear_rect_ega.L0

; description:
;       Clears a rectangle on screen (nominally black) on monochrome EGA.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_ega_mono:
        mov     ax,bx
        shr     ax,1
        add     bx,ax
        tcall   clear_rect_ega

; description:
;       Scrolls the contents of a rectangle up by one text line (= six logical pixels).
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen, excluding the last text line
scroll_up_vga:
        push    si
        mov     dx,320
        sub     dx,cx
        sub     dx,cx
        push    ds
        push    es
        pop     ds
        mov     si,di
        add     si,320*6
.L1:
        push    cx
        rep     movsw
        pop     cx
        add     si,dx
        add     di,dx
        dec     bx
        jnz     .L1
        pop     ds
        pop     si
        mov     bx,6
        tcall   clear_rect_vga

; description:
;       Clears a rectangle on screen (nominally white) on VGA.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_white_vga:
        mov     ax,0f0fh
        tcall   clear_rect_vga.L0

; description:
;       Clears a rectangle on screen (nominally black) on VGA.
; parameters:
;       di: destination offset in video memory (es)
;       cx: width on a logical 160x200 screen
;       bx: height on a logical 160x200 screen
clear_rect_vga:
        xor     ax,ax
.L0:
        mov     dx,320
        sub     dx,cx
        sub     dx,cx
.L1:
        push    cx
        rep     stosw
        add     di,dx
        pop     cx
        dec     bx
        jnz     .L1
        ret
