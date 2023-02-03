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

; This LUT converts VGA pixel values to packed pairs of IRGB pixel values.
; In VGA mode, it gets overwritten with an identity LUT.

VGA_TO_ETGA_LUT db 0,68,102,34,51,17,85,15,136,204,238,170,187,153,221,255
                db 4,68,76,108,108,78,110,238,238,126,239,239,239,238,238,238
                db 8,6,70,44,44,206,206,124,207,207,207,239,239,207,207,205
                db 8,8,24,72,108,108,124,94,94,79,61,121,105,23,136,8
                db 0,6,6,36,44,44,78,206,126,111,79,45,121,153,19,2
                db 4,6,104,44,44,39,138,58,58,171,187,187,191,191,63,120
                db 94,126,238,238,62,171,123,187,187,187,123,123,155,155,155,153
                db 204,78,78,110,106,58,43,187,155,155,27,57,57,57,25,25
                db 12,102,44,224,10,10,26,11,41,41,19,9,9,9,17,17
                db 4,6,6,36,40,2,40,3,3,24,24,24,24,1,1,1
                db 4,6,6,6,2,2,8,136,8,8,8,8,8,0,0,0
                db 1,24,24,137,105,87,140,108,108,206,206,206,126,239,239,255
                db 0,0,1,1,8,8,8,72,70,102,44,44,142,30,15,127
                db 0,0,0,0,1,1,1,24,136,40,40,138,30,126,239,239
                db 0,0,0,0,0,0,0,2,2,2,34,10,42,42,170,170
                db 0,0,8,136,104,44,103,30,111,111,15,119,119,121,23,56

; This LUT converts VGA pixel values to IRGB pixel values.
; Upper 4 bits are best match, lower 4 bits could be used for 2nd best match.

VGA_TO_IRGB_LUT db 0,64,96,32,48,16,80,112,128,192,224,160,176,144,208,240
                db 0,64,192,192,192,192,224,224,224,224,224,240,240,224,224,224
                db 0,96,96,208,192,192,192,192,112,112,224,224,224,240,112,192
                db 0,80,128,128,96,192,208,112,112,112,112,144,112,112,128,128
                db 0,0,128,96,96,96,224,224,240,240,112,112,144,144,48,32
                db 0,128,96,192,112,112,160,160,160,176,176,176,176,240,112,112
                db 192,224,224,224,224,160,176,176,176,240,240,176,176,112,144,144
                db 192,192,224,224,160,160,48,176,176,176,176,144,112,144,144,144
                db 96,96,96,224,32,160,48,48,48,48,48,48,144,16,16,16
                db 64,96,96,96,48,32,48,128,128,128,128,128,128,16,16,16
                db 0,0,128,128,0,32,32,128,128,128,0,128,0,0,0,0
                db 0,128,128,144,144,112,192,192,192,192,224,224,240,240,240,240
                db 0,0,0,0,128,128,128,64,96,192,96,96,112,112,112,112
                db 0,0,0,0,0,16,16,128,128,128,128,160,112,224,240,240
                db 0,0,0,0,0,96,0,0,32,32,160,160,160,160,224,160
                db 0,0,128,128,64,128,112,112,112,112,112,112,240,112,48,112

irgb_to_pal_lut db 00h,05h,03h,04h,01h,06h,02h,07h,08h,0dh,0bh,0ch,09h,0eh,0ah,0fh

; The following table is used to determine if
; a tile is to be drawn as transparent or not.

TRANSPARENCY    db      0,0,0,0,0,0,0,0 ; tile 0
                db      0,0,0,0,0,0,0,0 ; tile 8
                db      0,0,0,0,0,0,0,0 ; tile 10
                db      0,0,0,0,0,0,0,0 ; tile 18
                db      0,0,0,0,0,0,0,0 ; tile 20
                db      0,0,0,0,0,0,0,0 ; tile 28
                db      0,0,0,0,0,0,0,0 ; tile 30
                db      0,0,0,0,0,0,0,0 ; tile 38
                db      0,0,0,0,0,0,0,0 ; tile 40
                db      0,0,0,0,0,0,0,0 ; tile 48
                db      1,1,1,1,1,1,1,1 ; tile 50
                db      1,1,1,1,1,1,1,1 ; tile 58
                db      1,1,0,0,0,0,0,0 ; tile 60
                db      0,0,0,0,0,0,0,0 ; tile 68
                db      0,0,0,0,0,0,0,0 ; tile 70
                db      0,0,0,0,0,0,0,0 ; tile 78
                db      0,0,0,0,0,0,0,0 ; tile 80
                db      0,0,0,0,1,1,1,1 ; tile 88
                db      0,0,0,0,1,1,1,1 ; tile 90
                db      0,0,0,0,0,0,0,1 ; tile 98
                db      1,1,1,1,1,1,1,1 ; tile a0
                db      1,1,1,1,1,1,1,1 ; tile a8
                db      1,1,1,1,0,0,1,1 ; tile b0
                db      0,0,0,0,0,0,0,0 ; tile b8
                db      0,0,0,0,0,0,0,0 ; tile c0
                db      0,0,0,0,0,0,0,0 ; tile c8
                db      0,0,0,0,0,0,0,0 ; tile d0
                db      0,0,0,0,0,0,0,1 ; tile d8
                db      0,0,0,0,0,0,0,0 ; tile e0
                db      0,0,0,0,0,0,0,0 ; tile e8
                db      0,0,0,0,0,0,0,0 ; tile f0
                db      0,0,0,0,0,0,0,0 ; tile f8
