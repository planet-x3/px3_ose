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

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_cga:
        mov     ax,0f0f0h
        mov     dx,00f0fh
.skip:
        stosw
        stosw
        add     di,8748
        not     ax
        stosw
        stosw

        sub     di,564
        mov     cx,7
.l1:
        and     [es:di],dh
        or      [es:di+3],dl
        add     di,80
        loop    .l1

        sub     di,8672
        not     dx
        mov     cx,7
.l2:
        or      [es:di],dh
        and     [es:di+3],dl
        add     di,80
        loop    .l2
        ret

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_cga:
        mov     ax,0f0f0h
        mov     dx,00f0fh
.skip:
        stosw
        stosw
        stosw
        stosw
        add     di,9384
        not     ax
        stosw
        stosw
        stosw
        stosw

        sub     di,1208
        mov     cx,15
.l1:
        and     [es:di],dh
        or      [es:di+7],dl
        add     di,80
        loop    .l1

        sub     di,9312
        not     dx
        mov     cx,15
.l2:
        or      [es:di],dh
        and     [es:di+7],dl
        add     di,80
        loop    .l2
        ret

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_cga_2:
        mov     ax,0cccch
        mov     dx,03f03h
        tcall   plot_cursor_cga.skip

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_cga_2:
        mov     ax,0cccch
        mov     dx,03f03h
        tcall   plot_cursor_big_cga.skip

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_plantronics:
        push    di
        add     di,16384
        call    plot_cursor_cga
        pop     di
        tcall   plot_cursor_cga

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_plantronics:
        push    di
        add     di,16384
        call    plot_cursor_big_cga
        pop     di
        tcall   plot_cursor_big_cga

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_plantronics_2:
        push    di
        add     di,16384
        call    plot_cursor_cga_2
        pop     di
        tcall   plot_cursor_cga_2

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_plantronics_2:
        push    di
        add     di,16384
        call    plot_cursor_big_cga_2
        pop     di
        tcall   plot_cursor_big_cga_2

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_pc1512:
        mov     dx,3ddh
        mov     al,1
        out     dx,al
        push    di
        call    plot_cursor_cga_2
        pop     di
        mov     dx,3ddh
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,1
        out     dx,al
        push    di
        call    plot_cursor_cga_2
        pop     di
        mov     dx,3ddh
        mov     al,4
        out     dx,al
        inc     dx
        mov     al,2
        out     dx,al
        push    di
        call    plot_cursor_cga_2
        pop     di
        mov     dx,3ddh
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,3
        out     dx,al
        call    plot_cursor_cga_2
        mov     dx,3ddh
        mov     al,0fh
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        ret

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_pc1512:
        mov     dx,3ddh
        mov     al,1
        out     dx,al
        push    di
        call    plot_cursor_big_cga_2
        pop     di
        mov     dx,3ddh
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,1
        out     dx,al
        push    di
        call    plot_cursor_big_cga_2
        pop     di
        mov     dx,3ddh
        mov     al,4
        out     dx,al
        inc     dx
        mov     al,2
        out     dx,al
        push    di
        call    plot_cursor_big_cga_2
        pop     di
        mov     dx,3ddh
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,3
        out     dx,al
        call    plot_cursor_big_cga_2
        mov     dx,3ddh
        mov     al,0fh
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        ret

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_text:
        mov     ax,0f0b1h
        stosw
        stosw
        add     di,556
        stosw
        stosw
        ret

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_text:
        mov     ax,0f0b1h
        stosw
        stosw
        stosw
        stosw
        add     di,1192
        stosw
        stosw
        stosw
        stosw
        ret

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_ega:
        ; draw the top line
        mov     al,11001100b
        mov     cx,4
        rep     stosb
        sub     di,4
        mov     bl,0

        ; draw the left line
        mov     dx,3ceh
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,11000000b
        out     dx,al
.left:
        add     di,80
        mov     al,byte [es:di]
        mov     al,bl
        ror     al,1
        sar     al,1
        mov     byte [es:di],al
        inc     bl
        cmp     bl,15
        jne     .left

        ; draw the right line
        dec     dx
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,11b
        out     dx,al
        sub     di,1277
        mov     bl,0
.right:
        add     di,80
        mov     al,byte [es:di]
        mov     al,bl
        ror     al,1
        sar     al,1
        rol     al,2
        mov     byte [es:di],al
        inc     bl
        cmp     bl,15
        jne     .right

        ; draw the bottom line
        dec     dx
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,11111111b
        out     dx,al
        add     di,77
        mov     al,00110011b
        mov     cx,4
        rep     stosb
        ret

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_ega:
        ; draw the top line
        mov     al,11001100b
        mov     cx,8
        rep     stosb
        sub     di,8
        mov     bl,0

        ; draw the left line
        mov     dx,3ceh
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,11000000b
        out     dx,al
.left:
        add     di,80
        mov     al,byte [es:di]
        mov     al,bl
        ror     al,1
        sar     al,1
        mov     byte [es:di],al
        inc     bl
        cmp     bl,31
        jne     .left

        ; draw the right line
        dec     dx
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,11b
        out     dx,al
        sub     di,2553
        mov     bl,0
.right:
        add     di,80
        mov     al,byte [es:di]
        mov     al,bl
        ror     al,1
        sar     al,1
        rol     al,2
        mov     byte [es:di],al
        inc     bl
        cmp     bl,31
        jne     .right

        ; draw the bottom line
        dec     dx
        mov     al,8
        out     dx,al
        inc     dx
        mov     al,11111111b
        out     dx,al
        add     di,73
        mov     al,00110011b
        mov     cx,8
        rep     stosb
        ret

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_mtdy:
        push    di

        ; draw top line
        mov     ax,0f0f0h
        stosw
        stosw
        stosw
        stosw
        sub     di,8

        ; draw pixel of left and right line
        mov     cx,7
        .L1:
        add     di,2000h
        jno     .nowrap1
        sub     di,8000h-160
        .nowrap1:
        mov     al,byte [es:di]
        and     al,0fh
        stosb
        add     di,6
        mov     al,byte [es:di]
        or      al,0fh
        stosb
        add     di,2000h-8
        jno     .nowrap2
        sub     di,8000h-160
        .nowrap2:
        mov     al,byte [es:di]
        or      al,0f0h
        stosb
        add     di,6
        mov     al,byte [es:di]
        and     al,0f0h
        stosb
        sub     di,8
        loop    .L1

        ; draw bottom line
        add     di,2000h
        jno     .nowrap3
        sub     di,8000h-160
        .nowrap3:
        mov     ax,0f0fh
        stosw
        stosw
        stosw
        stosw

        pop     di
        ret

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_mtdy:
        push    di

        ; draw top line
        mov     ax,0f0f0h
        mov     cx,8
        rep     stosw
        sub     di,16

        ; draw pixel of left and right line
        mov     cx,15
        .L1:
        add     di,2000h
        jno     .nowrap1
        sub     di,8000h-160
        .nowrap1:
        mov     al,byte [es:di]
        and     al,0fh
        stosb
        add     di,14
        mov     al,byte [es:di]
        or      al,0fh
        stosb
        add     di,2000h-16
        jno     .nowrap2
        sub     di,8000h-160
        .nowrap2:
        mov     al,byte [es:di]
        or      al,0f0h
        stosb
        add     di,14
        mov     al,byte [es:di]
        and     al,0f0h
        stosb
        sub     di,16
        loop    .L1

        ; draw bottom line
        add     di,2000h
        jno     .nowrap3
        sub     di,8000h-160
        .nowrap3:
        mov     ax,0f0fh
        mov     cx,8
        rep     stosw

        pop     di
        ret

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_atigs:
        mov     ax,es
        add     ax,800h
        mov     es,ax
        call    plot_cursor_mtdy
        mov     ax,es
        sub     ax,800h
        mov     es,ax
        tcall   plot_cursor_mtdy

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_atigs:
        mov     ax,es
        add     ax,800h
        mov     es,ax
        call    plot_cursor_big_mtdy
        mov     ax,es
        sub     ax,800h
        mov     es,ax
        tcall   plot_cursor_big_mtdy

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_vga:
        ; draw top line
        mov     ax,000fh
.skip_load_ax:
        mov     cx,8
        rep     stosw
        ; draw pixel of left and right line
        mov     cx,14
        xchg    al,ah
.L1:
        add     di,304
        stosb
        add     di,14
        xchg    al,ah
        stosb
        loop    .L1
        ; draw bottom line
        add     di,304
        mov     cx,8
        rep     stosw
        ret

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_vga:
        ; draw top line
        mov     ax,000fh
.skip_load_ax:
        mov     cx,16
        rep     stosw
        ; draw pixel of left and right line
        mov     cx,30
        xchg    al,ah
.L1:
        add     di,288
        stosb
        add     di,30
        xchg    al,ah
        stosb
        loop    .L1
        ; draw bottom line
        add     di,288
        mov     cx,16
        rep     stosw
        ret

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_etga:
        mov     ax,00ffh
        tcall   plot_cursor_vga.skip_load_ax

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_etga:
        mov     ax,00ffh
        tcall   plot_cursor_big_vga.skip_load_ax

; description:
;       Plot a graphical unit selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_vga_y:
        ; draw left line
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,1
        out     dx,al

        mov     cx,14
        mov     ax,0f00h
        add     di,80
.L1:
        stosb
        add     di,79
        xchg    al,ah
        loop    .L1

        ; draw right line
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,8
        out     dx,al

        mov     cx,14
        sub     di,1117
        mov     ax,000fh
.L2:
        stosb
        add     di,79
        xchg    al,ah
        loop    .L2

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0ah
        out     dx,al

        ; draw bottom line white pixels
        sub     di,3
        mov     ax,0f0fh
        stosw
        stosw
        ; draw top line black pixels
        sub     di,1204
        xor     ax,ax
        stosw
        stosw

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,05h
        out     dx,al

        ; draw bottom line black pixels
        add     di,1196
        xor     ax,ax
        stosw
        stosw
        ; draw top line white pixels
        sub     di,1204
        mov     ax,0f0fh
        stosw
        stosw

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al

        ret

; description:
;       Plot a big graphical building selection cursor.
; parameters:
;       di: destination offset in video memory (es)
plot_cursor_big_vga_y:
        ; draw left line
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,1
        out     dx,al

        mov     cx,30
        mov     ax,0f00h
        add     di,80
.L1:
        stosb
        add     di,79
        xchg    al,ah
        loop    .L1

        ; draw right line
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,8
        out     dx,al

        mov     cx,30
        sub     di,2393
        mov     ax,000fh
.L2:
        stosb
        add     di,79
        xchg    al,ah
        loop    .L2

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0ah
        out     dx,al

        ; draw bottom line white pixels
        sub     di,7
        mov     ax,0f0fh
        stosw
        stosw
        stosw
        stosw
        ; draw top line black pixels
        sub     di,2488
        xor     ax,ax
        stosw
        stosw
        stosw
        stosw

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,05h
        out     dx,al

        ; draw bottom line black pixels
        add     di,2472
        xor     ax,ax
        stosw
        stosw
        stosw
        stosw
        ; draw top line white pixels
        sub     di,2488
        mov     ax,0f0fh
        stosw
        stosw
        stosw
        stosw

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al

        ret
