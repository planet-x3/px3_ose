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

WRITE_RESOURCES:
        mov     ax,[font_bg_frame]
        mov     word [font_bg_color],ax
        ; First do Minerals
        mov     al,[QTY_MINERALS]
        mov     [HEXNUM],al
        mov     di,[numpos_minerals]
        call    WRITE_DECNUM
        ; Next do Gas
        mov     al,[QTY_GAS]
        mov     [HEXNUM],al
        mov     di,[numpos_gas]
        call    WRITE_DECNUM
        ; Next do Energy
        mov     al,[QTY_ENERGY]
        mov     [HEXNUM],al
        mov     di,[numpos_energy]
        call    WRITE_DECNUM
        ret

WRITE_COORDINATES:
        mov     ax,[font_bg_frame]
        mov     word [font_bg_color],ax
        ; First do the X coordinate
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_LOCATION_X[si]
        mov     [HEXNUM],al
        mov     di,[numpos_xcoord]
        call    WRITE_DECNUM
        ; Next do the Y coordinate
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_LOCATION_Y[si]
        mov     [HEXNUM],al
        mov     di,[numpos_ycoord]
        call    WRITE_DECNUM
        ret

WRITE_HEXNUM:
        mov     al,[HEXNUM]
        shr     al,4            ; shift over to the right
        mov     ah,0
        mov     si,ax
        mov     bl,HEXARRAY[si]
        call    PLOT_CHAR
        mov     al,[HEXNUM]
        and     al,15
        mov     ah,0
        mov     si,ax
        mov     bl,HEXARRAY[si]
        call    PLOT_CHAR
        ret

; The following routine inserts a decimal number into a string
; the variable HEXNUM should contain the byte to use
; and DI should contain the destination

INSERT_DECNUM:
        cmp     byte [HEXNUM],100
        jae     .L1
        mov     byte [cs:di],"0"
        inc     di
        cmp     byte [HEXNUM],10
        jae     .L1
        mov     byte [cs:di],"0"
        inc     di
        .L1:
        mov     dl,[HEXNUM]
        mov     dh,0
        mov     ax,dx           ; Assuming number to print starts in dx
        mov     si,10           ; decimal 10
        xor     cx,cx           ; Initialize count at 0
        .L2:
        xor     dx,dx           ; Clear last remainder
        div     si
        push    dx              ; Save digits in reverse order
        inc     cx
        or      ax,ax           ; Is original number down to 0 yet?
        jnz     .L2             ; No, continue looping
        mov     ah,02h
        .L3:
        pop     dx
        add     dx,"0"          ; Convert to ASCII
        mov     bl,dl
        mov     byte [cs:di],bl
        inc     di
        inc     si
        loop    .L3
        ret

; The following routine writes a decimal number onto the screen
; the variable HEXNUM should contain the byte to use

WRITE_DECNUM:
        cmp     byte [HEXNUM],100
        jae     WRITE_DECNUM_2DIGIT.L1
        mov     bl, "0"
        call    PLOT_CHAR_COLOR
        WRITE_DECNUM_2DIGIT:
        cmp     byte [HEXNUM],10
        jae     .L1
        mov     bl, "0"
        call    PLOT_CHAR_COLOR
        .L1:
        mov     dl,[HEXNUM]
        mov     dh,0
        mov     ax,dx           ; Assuming number to print starts in dx
        mov     si,10           ; decimal 10
        xor     cx,cx           ; Initialize count at 0
        .L2:
        xor     dx,dx           ; Clear last remainder
        div     si
        push    dx              ; Save digits in reverse order
        inc     cx
        or      ax,ax           ; Is original number down to 0 yet?
        jnz     .L2             ; No, continue looping
        mov     ah,02h
        .L3:
        pop     dx
        add     dx,"0"          ; Convert to ASCII
        mov     bl,dl
        push    ax              ; NOTE: these push/pop instructions appear to be needed by the VGA version
        push    bx
        push    cx
        call    PLOT_CHAR_COLOR
        pop     cx
        pop     bx
        pop     ax
        loop    .L3
        ret

PLOT_CHAR:
        push    si
        mov     [.temp],bl
        mov     si,.temp
        mov     cx,1
        call    [plot_string]
        pop     si
        ret

.temp   db      " "

PLOT_CHAR_COLOR:
        push    si
        mov     [.temp],bl
        mov     si,.temp
        mov     cx,1
        call    [plot_string_color]
        pop     si
        ret

.temp   db      " "

; --------------------------------------------------------------

; description:
;       String plotting routine for CGA.
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_cga:
        xor     bp,bp
        test    di,2000h
        jz      .L1
        mov     bp,16304
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 10
        shl     ax,2
        add     si,ax
        shl     si,1
        add     si,FONT         ; make index into font data

        movsw                   ; first scanline of character
        add     di,78
        movsw                   ; third scanline of character
        add     di,78
        movsw                   ; fifth scanline of character
        add     di,8030
        sub     di,bp
        movsw                   ; second scanline of character
        add     di,78
        movsw                   ; fourth scanline of character
        sub     di,8272
        add     di,bp

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for CGA (color).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_cga:
        xor     bp,bp
        test    di,2000h
        jz      .L1
        mov     bp,16304
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 10
        shl     ax,2
        add     si,ax
        shl     si,1
        add     si,FONT         ; make index into font data
        mov     bx,[font_bg_color]

        lodsw                   ; first scanline of character
        or      ax,bx
        stosw
        add     di,78
        lodsw                   ; third scanline of character
        or      ax,bx
        stosw
        add     di,78
        lodsw                   ; fifth scanline of character
        or      ax,bx
        stosw
        add     di,8030
        sub     di,bp
        lodsw                   ; second scanline of character
        or      ax,bx
        stosw
        add     di,78
        lodsw                   ; fourth scanline of character
        or      ax,bx
        stosw
        sub     di,8272
        add     di,bp

        pop     si
        loop    .L1
        ret
