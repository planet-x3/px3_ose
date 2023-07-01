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

%define BYTES_PER_LINE  80
%define BYTES_PER_PLANE 6000h

convert_screen_cga_to_ega_mono:
        pusha
        push    es
        push    ds
        pop     es

        xor     si,si
        mov     di,4000h

        mov     bp,100
        .yloop:
        mov     cx,80
        .xloop:

        mov     ah,[si+8192]            ; read i1 (al) and i2 (ah)
        lodsb

        mov     dl,al
        mov     dh,al
        and     dx,0101010110101010b    ; dl: t1a, dh: t1b
        shl     dh,1                    ; dh: o2v_ = t1b << 1
        or      al,dh                   ; al: o1v

        mov     [es:di],al              ; write o1v (al)

        mov     al,dh
        and     al,dl                   ; al: o2i_ = t1a & (t1b >> 1)
        or      dh,dl                   ; dh: o2v_ (avoid stripes in dark gray)
        mov     dl,al
        shr     dl,1
        or      dl,al                   ; dl: o1i

        mov     [es:di+BYTES_PER_PLANE],dl      ; write o1i (dl)

        mov     bl,ah
        mov     bh,ah
        and     bx,0101010110101010b    ; bl: t2a, bh: t2b
        or      dh,bh                   ; dh: o2v = o2v_ | t2b
        shl     bh,1
        or      ah,bh                   ; ah: o3v = i2 | (t2b << 1)
        and     bl,bh                   ; bl: temp_ = t2a & (t2b << 1)
        mov     dl,bl
        shr     dl,1                    ; dl: temp = (t2a >> 1) & t2b
        or      al,dl                   ; al: o2i
        or      dl,bl                   ; dl: o3i = temp_ | temp

        mov     [es:di+BYTES_PER_LINE],dh                       ; write o2v (dh)
        mov     [es:di+BYTES_PER_PLANE+BYTES_PER_LINE],al       ; write o2i (al)
        mov     [es:di+(2*BYTES_PER_LINE)],ah                   ; write o3v (ah)
        mov     [es:di+BYTES_PER_PLANE+(2*BYTES_PER_LINE)],dl   ; write o3i (dl)
        inc     di

        loop    .xloop
        add     di,160
        dec     bp
        jnz     .yloop

        pop     es
        popa
        ret

convert_tiles_cga_to_ega_mono:
        pusha
        push    es
        push    ds
        pop     es

        xor     si,si
        mov     di,4000h

        mov     ch,0                    ; 256
        .tileloop:
        mov     bp,8
        .yloop:
        mov     cl,4
        .xloop:

        mov     ah,[si+4*8]             ; read i1 (al) and i2 (ah)
        lodsb

        mov     dl,al
        mov     dh,al
        and     dx,0101010110101010b    ; dl: t1a, dh: t1b
        shl     dh,1                    ; dh: o2v_ = t1b << 1
        or      al,dh                   ; al: o1v

        mov     [es:di],al              ; write o1v (al)

        mov     al,dh
        and     al,dl                   ; al: o2i_ = t1a & (t1b >> 1)
        or      dh,dl                   ; dh: o2v_ (avoid stripes in dark gray)
        mov     dl,al
        shr     dl,1
        or      dl,al                   ; dl: o1i

        mov     [es:di+BYTES_PER_PLANE],dl      ; write o1i (dl)

        mov     bl,ah
        mov     bh,ah
        and     bx,0101010110101010b    ; bl: t2a, bh: t2b
        or      dh,bh                   ; dh: o2v = o2v_ | t2b
        shl     bh,1
        or      ah,bh                   ; ah: o3v = i2 | (t2b << 1)
        and     bl,bh                   ; bl: temp_ = t2a & (t2b << 1)
        mov     dl,bl
        shr     dl,1                    ; dl: temp = (t2a >> 1) & t2b
        or      al,dl                   ; al: o2i
        or      dl,bl                   ; dl: o3i = temp_ | temp

        mov     [es:di+4],dh                            ; write o2v (dh)
        mov     [es:di+BYTES_PER_PLANE+4],al            ; write o2i (al)
        mov     [es:di+(2*4)],ah                        ; write o3v (ah)
        mov     [es:di+BYTES_PER_PLANE+(2*4)],dl        ; write o3i (dl)
        inc     di

        dec     cl
        jnz     .xloop
        add     di,2*4
        dec     bp
        jnz     .yloop
        add     si,8*4
        dec     ch
        jnz     .tileloop

        pop     es
        popa
        ret

fadein_pixel_xfer_ega_mono:
        cmp     si,24000
        jae     .end
        pusha
        add     si,4000h
        add     di,2000

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,01h
        out     dx,al

        mov     al,[si]
        mov     [es:di],al

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,04h
        out     dx,al

        add     si,6000h
        movsb

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al

        popa
        .end:
        inc     si
        inc     di
        ret
