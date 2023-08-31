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
;       String plotting routine for Hercules.
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_hercules:
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
        movsw                   ; second scanline of character
        add     di,78
        movsw                   ; fourth scanline of character
        add     di,8110
        sub     si,4
        movsw                   ; doubled second scanline of character
        add     di,78
        movsw                   ; doubled fourth scanline of character
        sub     di,16464

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for Hercules (inverted colors).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_reverse_hercules:
        cmp     word [font_bg_color],0
        jne     .L1
        jmp     plot_string_hercules
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

        lodsw                   ; first scanline of character
        not     ax
        stosw
        add     di,78
        lodsw                   ; third scanline of character
        not     ax
        stosw
        add     di,78
        lodsw                   ; fifth scanline of character
        not     ax
        stosw
        add     di,8030
        lodsw                   ; second scanline of character
        not     ax
        stosw
        add     di,78
        lodsw                   ; fourth scanline of character
        not     ax
        stosw
        add     di,8110
        sub     si,4
        lodsw                   ; doubled second scanline of character
        not     ax
        stosw
        add     di,78
        lodsw                   ; doubled fourth scanline of character
        not     ax
        stosw
        sub     di,16464

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for 2-color CGA (color).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_cg2:
        cmp     word [font_bg_color],0
        jne     plot_string_cga_inverted
        tcall   plot_string_cga

; description:
;       String plotting routine for 2-color CGA (color, inverted).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_cg2_inverted:
        cmp     word [font_bg_color],0
        je      plot_string_cga_inverted
        tcall   plot_string_cga

; description:
;       String plotting routine for CGA (inverted).
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_cga_inverted:
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

        lodsw                   ; first scanline of character
        not     ax
        stosw
        add     di,78
        lodsw                   ; third scanline of character
        not     ax
        stosw
        add     di,78
        lodsw                   ; fifth scanline of character
        not     ax
        stosw
        add     di,8030
        lodsw                   ; second scanline of character
        not     ax
        stosw
        add     di,78
        lodsw                   ; fourth scanline of character
        not     ax
        stosw
        sub     di,8272

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for Plantronics ColorPlus.
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_plantronics:
        push    si
        push    di
        push    cx
        call    plot_string_cga
        pop     cx
        pop     di
        pop     si
        add     di,16384
        call    plot_string_cga
        sub     di,16384
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

; description:
;       String plotting routine for Plantronics ColorPlus (color).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_plantronics:
        mov     ax,[font_bg_color]
        mov     [.bg_color_backup],ax
        mov     ah,al
        mov     [font_bg_color],ax
        push    si
        push    di
        push    cx
        call    plot_string_color_cga
        pop     cx
        pop     di
        pop     si
        mov     ax,[.bg_color_backup]
        mov     al,ah
        mov     [font_bg_color],ax
        add     di,16384
        call    plot_string_color_cga
        sub     di,16384
        mov     ax,[.bg_color_backup]
        mov     [font_bg_color],ax
        ret

.bg_color_backup        dw      0

; description:
;       String plotting routine for EGA.
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_ega:
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
        add     di,158
        movsw                   ; third scanline of character
        add     di,158
        movsw                   ; fifth scanline of character
        sub     di,242
        movsw                   ; second scanline of character
        add     di,158
        movsw                   ; fourth scanline of character
        sub     di,240

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for EGA (color).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_ega:
        push    dx
        mov     dx,3ceh
        mov     al,0            ; set/reset
        out     dx,al
        inc     dx
        mov     al,byte [font_bg_color]
        out     dx,al
        dec     dx
        mov     al,1            ; enable set/reset
        out     dx,al
        inc     dx
        mov     al,byte [font_bg_color]
        out     dx,al
        call    plot_string_ega
        mov     dx,3ceh
        mov     al,1            ; enable set/reset
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        pop     dx
        ret

; description:
;       String plotting routine for EGA (low-res).
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_ega_low:
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 5
        shl     ax,2
        add     si,ax
        add     si,FONT         ; make index into font data

        movsb                   ; first scanline of character
        add     di,39
        movsb                   ; second scanline of character
        add     di,39
        movsb                   ; third scanline of character
        add     di,39
        movsb                   ; fourth scanline of character
        add     di,39
        movsb                   ; fifth scanline of character
        sub     di,160

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for EGA (low-res, color).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_ega_low:
        push    dx
        mov     dx,3ceh
        mov     al,0            ; set/reset
        out     dx,al
        inc     dx
        mov     al,byte [font_bg_color]
        out     dx,al
        dec     dx
        mov     al,1            ; enable set/reset
        out     dx,al
        inc     dx
        mov     al,byte [font_bg_color]
        out     dx,al
        call    plot_string_ega_low
        mov     dx,3ceh
        mov     al,1            ; enable set/reset
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        pop     dx
        ret

; description:
;       String plotting routine for EGA mono.
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_ega_mono:
        add     di,80
        call    plot_string_ega
        sub     di,80
        ret

; description:
;       String plotting routine for EGA mono (color, i.e. non-black bg).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_ega_mono:
        add     di,80
        call    plot_string_color_ega
        sub     di,80
        ret

; description:
;       String plotting routine for Amstrad PC1512 VDU (color).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_pc1512:
        push    si,di,cx
        call    plot_string_cga
        pop     cx,di,si
        mov     dx,3ddh
        mov     al,byte [font_bg_color]
        out     dx,al
        push    word [font_bg_color]
        mov     word [font_bg_color],0ffffh
        call    plot_string_color_cga
        pop     word [font_bg_color]
        push    dx
        mov     dx,3ddh
        mov     al,0fh
        out     dx,al
        pop     dx
        ret

; description:
;       String plotting routine for VGA mode-Y.
; parameters:
;       font_bg_color: foreground/background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_vga_y:
        mov     bp,[font_bg_color]
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 5
        shl     ax,2
        add     si,ax
        add     si,FONT         ; make index into font data

        mov     bl,5
.L2:
        mov     dl,[si]         ; load one scanline of character
        inc     si
        mov     bh,1
.L3:
        push    dx
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,bh
        out     dx,al
        pop     dx
        shl     dl,1
        sbb     al,al
        and     ax,bp
        mov     [es:di],al
        shl     bh,1
        test    bh,0fh
        jnz     .L3
        inc     di
        mov     bh,1
.L4:
        push    dx
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,bh
        out     dx,al
        pop     dx
        shl     dl,1
        sbb     al,al
        and     ax,bp
        mov     [es:di],al
        shl     bh,1
        test    bh,0fh
        jnz     .L4
        add     di,79
        dec     bl
        jnz     .L2
        sub     di,398

        pop     si
        loop    .L1
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al
        ret

; description:
;       String plotting routine for VGA mode-Y (color).
; parameters:
;       font_bg_color: foreground/background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_vga_y:
        mov     bp,[font_bg_color]
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 5
        shl     ax,2
        add     si,ax
        add     si,FONT         ; make index into font data

        mov     bl,5
.L2:
        mov     dl,[si]         ; load one scanline of character
        inc     si
        mov     bh,1
.L3:
        push    dx
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,bh
        out     dx,al
        pop     dx
        shl     dl,1            ; diff start
        sbb     ax,ax           ;
        not     ah              ; (see plot_string_vga_y)
        and     ax,bp           ;
        or      al,ah           ; diff end
        mov     [es:di],al
        shl     bh,1
        test    bh,0fh
        jnz     .L3
        inc     di
        mov     bh,1
.L4:
        push    dx
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,bh
        out     dx,al
        pop     dx
        shl     dl,1            ; diff start
        sbb     ax,ax           ;
        not     ah              ; (see plot_string_vga_y)
        and     ax,bp           ;
        or      al,ah           ; diff end
        mov     [es:di],al
        shl     bh,1
        test    bh,0fh
        jnz     .L4
        add     di,79
        dec     bl
        jnz     .L2
        sub     di,398

        pop     si
        loop    .L1
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al
        ret

; description:
;       String plotting routine for medium resolution Tandy mode.
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_mtdy:
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 20
        shl     ax,2
        add     si,ax
        shl     si,2
        add     si,FONT         ; make index into font data

        movsw
        movsw
        add     di,8192-4
        jno     .L2
        sub     di,32768-160
.L2:
        movsw
        movsw
        add     di,8192-4
        jno     .L3
        sub     di,32768-160
.L3:
        movsw
        movsw
        add     di,8192-4
        jno     .L4
        sub     di,32768-160
.L4:
        movsw
        movsw
        add     di,8192-4
        jno     .L5
        sub     di,32768-160
.L5:
        movsw
        movsw
        sub     di,160

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for ATI Graphics Solution.
; parameters:
;       si: string
;       di: screen pos
;       cx: length
plot_string_atigs:
        push    si
        push    di
        push    cx
        call    plot_string_mtdy
        pop     cx
        pop     di
        pop     si
        mov     ax,es
        add     ax,800h
        mov     es,ax
        call    plot_string_mtdy
        mov     ax,es
        sub     ax,800h
        mov     es,ax
        ret

; description:
;       String plotting routine for ATI Graphics Solution (color).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_atigs:
        mov     ax,[font_bg_color]
        mov     [.bg_color_backup],ax
        mov     ah,al
        mov     [font_bg_color],ax
        push    si
        push    di
        push    cx
        call    plot_string_color_mtdy
        pop     cx
        pop     di
        pop     si
        mov     ax,[.bg_color_backup]
        mov     al,ah
        mov     [font_bg_color],ax
        mov     ax,es
        add     ax,800h
        mov     es,ax
        call    plot_string_color_mtdy
        mov     ax,es
        sub     ax,800h
        mov     es,ax
        mov     ax,[.bg_color_backup]
        mov     [font_bg_color],ax
        ret

.bg_color_backup        dw      0

; description:
;       String plotting routine for medium resolution Tandy mode (color).
; parameters:
;       font_bg_color: background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_mtdy:
        mov     dx,[font_bg_color]
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 20
        shl     ax,2
        add     si,ax
        shl     si,2
        add     si,FONT         ; make index into font data

        lodsw
        or      ax,dx
        stosw
        lodsw
        or      ax,dx
        stosw
        add     di,8192-4
        jno     .L2
        sub     di,32768-160
        .L2:
        lodsw
        or      ax,dx
        stosw
        lodsw
        or      ax,dx
        stosw
        add     di,8192-4
        jno     .L3
        sub     di,32768-160
        .L3:
        lodsw
        or      ax,dx
        stosw
        lodsw
        or      ax,dx
        stosw
        add     di,8192-4
        jno     .L4
        sub     di,32768-160
        .L4:
        lodsw
        or      ax,dx
        stosw
        lodsw
        or      ax,dx
        stosw
        add     di,8192-4
        jno     .L5
        sub     di,32768-160
        .L5:
        lodsw
        or      ax,dx
        stosw
        lodsw
        or      ax,dx
        stosw
        sub     di,160

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for VGA.
; parameters:
;       font_bg_color: foreground/background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_vga:
        mov     bp,[font_bg_color]
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 5
        shl     ax,2
        add     si,ax
        add     si,FONT         ; make index into font data

        mov     bl,5
.L2:
        mov     dl,[si]         ; load one scanline of character
        inc     si
        mov     bh,8
.L3:
        shl     dl,1
        sbb     al,al
        and     ax,bp
        stosb
        dec     bh
        jnz     .L3
        add     di,312
        dec     bl
        jnz     .L2
        sub     di,1592

        pop     si
        loop    .L1
        ret

; description:
;       String plotting routine for VGA (color).
; parameters:
;       font_bg_color: foreground/background color in mode-specific format
;       si: string
;       di: screen pos
;       cx: length
plot_string_color_vga:
        mov     bp,[font_bg_color]
.L1:
        lodsb                   ; load character
        sub     al,32           ; make relative to whitespace
        mov     ah,0
        push    si
        mov     si,ax           ; multiply with 5
        shl     ax,2
        add     si,ax
        add     si,FONT         ; make index into font data

        mov     bl,5
.L2:
        mov     dl,[si]         ; load one scanline of character
        inc     si
        mov     bh,8
.L3:
        shl     dl,1
        sbb     ax,ax
        not     ah
        and     ax,bp
        or      al,ah
        stosb
        dec     bh
        jnz     .L3
        add     di,312
        dec     bl
        jnz     .L2
        sub     di,1592

        pop     si
        loop    .L1
        ret
