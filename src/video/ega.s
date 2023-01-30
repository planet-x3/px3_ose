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

; EGA routines

; Note: The palette-specific VGA_TO_ETGA_LUT has to be defined by the including program

emulate_movsb_to_vga_on_planar_vga:
        push    ax,cx,dx,di

        mov     cx,di
        and     cl,3

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,1
        shl     al,cl
        out     dx,al

        shr     di,2
        movsb

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al

        pop     di,dx,cx,ax
        inc     di
        ret

; convert to IRGB pairs and reorder 8x(IRGB) to 8xI, 8xR, 8xG and 8xB
convert_to_irgb_pairs_and_reorder_for_ega:
        push    ax,bx,cx,dx,si,di,bp,es

        push    ds,si
        pop     di,es
        mov     bx,VGA_TO_ETGA_LUT
        shr     cx,2
        mov     [cs:ctiparfe_counter],cx
ctiparfe_loop:
        lodsw
        cs xlatb
        xchg    al,ah
        cs xlatb
        mov     dx,ax
        lodsw
        cs xlatb
        xchg    al,ah
        cs xlatb
        mov     bp,ax

        ; shortcut for black pixels
        test    dx,dx
        jnz     .not_black
        test    bp,bp
        jnz     .not_black
        xor     cx,cx
        xor     ax,ax
        jmp     .write_result

.not_black:
        shl     dx,1
        rcl     ch,1
        shl     dx,1
        rcl     cl,1
        shl     dx,1
        rcl     ah,1
        shl     dx,1
        rcl     al,1

        shl     dx,1
        rcl     ch,1
        shl     dx,1
        rcl     cl,1
        shl     dx,1
        rcl     ah,1
        shl     dx,1
        rcl     al,1

        shl     dx,1
        rcl     ch,1
        shl     dx,1
        rcl     cl,1
        shl     dx,1
        rcl     ah,1
        shl     dx,1
        rcl     al,1

        shl     dx,1
        rcl     ch,1
        shl     dx,1
        rcl     cl,1
        shl     dx,1
        rcl     ah,1
        shl     dx,1
        rcl     al,1

        shl     bp,1
        rcl     ch,1
        shl     bp,1
        rcl     cl,1
        shl     bp,1
        rcl     ah,1
        shl     bp,1
        rcl     al,1

        shl     bp,1
        rcl     ch,1
        shl     bp,1
        rcl     cl,1
        shl     bp,1
        rcl     ah,1
        shl     bp,1
        rcl     al,1

        shl     bp,1
        rcl     ch,1
        shl     bp,1
        rcl     cl,1
        shl     bp,1
        rcl     ah,1
        shl     bp,1
        rcl     al,1

        shl     bp,1
        rcl     ch,1
        shl     bp,1
        rcl     cl,1
        shl     bp,1
        rcl     ah,1
        shl     bp,1
        rcl     al,1

.write_result:
        stosw
        mov     ax,cx
        stosw

        dec     word [cs:ctiparfe_counter]
        jz      ctiparfe_end
        jmp     ctiparfe_loop

ctiparfe_end:
        pop     es,bp,di,si,dx,cx,bx,ax
        ret

        ctiparfe_counter dw 0

copy_interleaved_bytes_to_vram_bitplanes:
        push    ax,bx,dx
        xor     bx,bx
        mov     ah,01h

cibtvb_loop01:
        push    cx,si,di
        add     si,bx

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,ah
        out     dx,al

        shl     ah,1

cibtvb_loop02:
        lodsb
        add     si,3
        stosb
        loop    cibtvb_loop02

        pop     di,si,cx
        inc     bl
        cmp     bl,4
        jne     cibtvb_loop01

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al

        pop     dx,bx,ax
        ret

; description:
;       Fills transparent pixels (index 14) in a VGA tileset with a mixture
;       of two land tiles or two water tiles, depending on the tile number.
fill_transparent_pixels:
        push    ds
        mov     ds,[cs:TILELOADSEG]
        xor     si,si

        mov     ch,0
        ; iterate over all tiles
        .tile_loop:
        mov     cl,0
        ; skip tile if marked as transparent and we want transparency
        cmp     byte [cs:VIDEO_TRANS],0
        je      .marked_nontransp
        mov     bl,ch
        mov     bh,0
        cmp     byte [cs:TRANSPARENCY+bx],0
        je      .marked_nontransp
        add     si,256
        inc     ch
        jnz     .tile_loop
        jmp     .end
        .marked_nontransp:
        ; skip tile if first pixel is not transparent
        lodsb
        cmp     al,14
        jne     .firstnot14
        jmp     .firstis14
        .firstnot14:
        add     si,255
        inc     ch
        jnz     .tile_loop
        jmp     .end
        ; iterate over all pixels of this tile
        .pix_loop:
        lodsb
        cmp     al,14
        jne     .not14
        .firstis14:
        ; fill in a blend of tiles 24 and 26 for the frigate tiles
        ; and a blend of tiles 0 and 34 for everything else
        dec     si
        mov     bx,si
        mov     bh,0
        mov     dl,bl
        mov     dh,bl
        shr     dh,4
        xor     dl,dh
        and     dl,1
        sub     bh,dl
        cmp     ch,94
        jb      .nowater
        cmp     ch,97
        ja      .nowater
        and     bh,2
        add     bh,24
        jmp     .waswater
        .nowater:
        and     bh,34
        .waswater:
        mov     al,[bx]
        mov     [si],al
        inc     si
        .not14:
        inc     cl
        jnz     .pix_loop
        inc     ch
        jnz     .tile_loop

        .end:
        pop     ds
        ret
