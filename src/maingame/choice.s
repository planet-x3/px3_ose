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
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

;==========================================================================
; Function askchoice
;
; Prints out a DOS-terminated string and gets keypress from user, then
; returns the scancode and ASCII value. Checks input for validity, and
; exits program if ESCAPE pressed.
;
; Input:
;   DS:SI = pointer to menu parameters
;
; Output:
;   AH = scancode of keypress
;   AL = ASCII value of keypress
;
; Menu string structure:
; MESSAGESTRING   DB "1"                          ; lowest value accepted
;                 DB "3"                          ; highest value accepted
;                 DB "Pick a number:",13,10       ; DOS-terminated string
;                 DB "1. Cheese",13,10
;                 DB "2. Grapes",13,10
;                 DB "3. Pringles",13,10,10,"$"
;
; ANOTHERMESSAGE  DB "a"                          ; lowest value accepted
;                 DB "c"                          ; highest value accepted
;                 DB "Choose your weapon!",13,10  ; DOS-terminated string
;                 DB "a. Cheese",13,10
;                 DB "b. Grapes",13,10
;                 DB "c. Pringles",13,10,10,"$"
;
;==========================================================================

askchoice:
        lodsw
        xchg    bx,ax                   ; BH=high bound, BL=low bound
        mov     dx,si                   ; ds:dx points to string
        mov     ah,09
        int     21h
K0:
        xor     ax,ax
        int     16h
        cmp     ah,01                   ; did user hit escape?
        je      key_escape              ; if so, abort
        cmp     al,bl                   ; below threshold?
        jb      K0                      ; if below, get another key
        cmp     al,bh                   ; above threshold?
        ja      K0                      ; if above, get another key
        ret
key_escape:
        call    EXITPROG
        db      "User hit <ESC> key",13,10,0


