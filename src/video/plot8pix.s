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
plot8pix_mcga:
        mov     cl,ch
        shl     cl,1
        sbb     al,al
        shl     cl,1
        sbb     ah,ah
        and     ax,bp
        stosw
        shl     cl,1
        sbb     al,al
        shl     cl,1
        sbb     ah,ah
        and     ax,bp
        stosw
        shl     cl,1
        sbb     al,al
        shl     cl,1
        sbb     ah,ah
        and     ax,bp
        stosw
        shl     cl,1
        sbb     al,al
        shl     cl,1
        sbb     ah,ah
        and     ax,bp
        stosw
        ret

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_vga_y:
        mov     cl,8
.l1:
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,cl
        out     dx,al

        ror     ch,1
        sbb     ah,ah
        ror     ch,1
        ror     ch,1
        ror     ch,1
        ror     ch,1
        sbb     al,al
        and     ax,bp
        mov     [es:di],ax

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,4
        out     dx,al

        ror     ch,1
        ror     ch,1
        ror     ch,1
        ror     ch,1

        shr     cl,1
        jnz     .l1

        add     di,2

        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al

        ret

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_text:
        mov     ax,bp
        mov     al,0
        test    ch,0ffh
        jz      .output
        test    ch,0f0h
        jz      .l1
        mov     al,0ddh         ; left half block character
        test    ch,0fh
        jz      .output
        mov     al,0dbh         ; full block character
        jmp     .output
.l1:
        mov     al,0deh         ; right half block character
.output:
        test    di,2000h        ; is this an odd line?
        jnz     .combine        ; => combine with previously written even line
        stosw
        ret
.combine:
        or      ax,[es:di-2000h]
        cmp     al,0bfh         ; should be full block character, instead
        jne     .output_combined
        mov     al,0bbh         ; full block character
.output_combined:
        mov     [es:di-2000h],ax
        add     di,2
        ret

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

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_cga_inverted:
        call    plot8pix_cga
        not     word [es:di-2]
        ret

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_plantronics:
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
        mov     dx,bp
        mov     dl,dh
        and     dx,ax
        mov     [es:di+4000h],dx
        mov     dx,bp
        mov     dh,dl
        and     ax,dx
        stosw
        ret

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_ega:
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     ax,bp
        out     dx,al
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
        stosw
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al
        ret

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_ega_low:
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     ax,bp
        out     dx,al
        mov     al,ch
        stosb
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        inc     dx
        mov     al,0fh
        out     dx,al
        ret

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_pc1512:
        mov     dx,3ddh
        mov     ax,bp
        out     dx,al
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
        stosw
        mov     dx,3ddh
        mov     al,0fh
        out     dx,al
        ret

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_mtdy:
        shl     ch,1
        sbb     al,al
        and     al,0f0h
        shl     ch,1
        sbb     cl,cl
        and     cl,0fh
        or      al,cl
        shl     ch,1
        sbb     ah,ah
        and     ah,0f0h
        shl     ch,1
        sbb     cl,cl
        and     cl,0fh
        or      ah,cl
        and     ax,bp
        stosw
        shl     ch,1
        sbb     al,al
        and     al,0f0h
        shl     ch,1
        sbb     cl,cl
        and     cl,0fh
        or      al,cl
        shl     ch,1
        sbb     ah,ah
        and     ah,0f0h
        shl     ch,1
        sbb     cl,cl
        and     cl,0fh
        or      ah,cl
        and     ax,bp
        stosw
        ret

; description:
;       Plotting routine for a horizontally aligned group of nominally
;       eight pixels on nominally black background.
; parameters:
;       ch: bitmask
;       di: destination offset in video memory (es)
;       bp: color
; returns:
;       di: next destination offset in video memory (es)
plot8pix_atigs:
        shl     ch,1
        sbb     al,al
        and     al,0f0h
        shl     ch,1
        sbb     cl,cl
        and     cl,0fh
        or      al,cl
        shl     ch,1
        sbb     ah,ah
        and     ah,0f0h
        shl     ch,1
        sbb     cl,cl
        and     cl,0fh
        or      ah,cl
        mov     dx,bp
        mov     dl,dh
        and     dx,ax
        mov     [es:di+8000h],dx
        mov     dx,bp
        mov     dh,dl
        and     ax,dx
        stosw
        shl     ch,1
        sbb     al,al
        and     al,0f0h
        shl     ch,1
        sbb     cl,cl
        and     cl,0fh
        or      al,cl
        shl     ch,1
        sbb     ah,ah
        and     ah,0f0h
        shl     ch,1
        sbb     cl,cl
        and     cl,0fh
        or      ah,cl
        mov     dx,bp
        mov     dl,dh
        and     dx,ax
        mov     [es:di+8000h],dx
        mov     dx,bp
        mov     dh,dl
        and     ax,dx
        stosw
        ret
