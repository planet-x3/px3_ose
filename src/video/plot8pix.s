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
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_ltdy:
        mov     cl,ch
        and     cl,0aah
        shr     cl,1
        or      ch,cl
        mov     cl,ch
        and     cl,55h
        shl     cl,1
        or      ch,cl
plot8pix_cga:
        shr     ch,1
        rcr     ax,1
        sar     ax,1
        shr     ch,1
        rcr     ax,1
        sar     ax,1
        shr     ch,1
        rcr     ax,1
        sar     ax,1
        shr     ch,1
        rcr     ax,1
        sar     ax,1
        shr     ch,1
        rcr     ax,1
        sar     ax,1
        shr     ch,1
        rcr     ax,1
        sar     ax,1
        shr     ch,1
        rcr     ax,1
        sar     ax,1
        shr     ch,1
        rcr     ax,1
        sar     ax,1
        xchg    al,ah
        and     ax,bp
        stosw
        ret
