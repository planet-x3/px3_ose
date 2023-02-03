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
