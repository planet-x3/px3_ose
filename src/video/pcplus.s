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

; Plantronics ColorPlus routines

; set 320x200 16-color Plantronics mode -- assumes that ES is b800h
set_plantronics_320x200x16:
        ; set 320x200 4-color mode, first
        ; use mode 5, if grayscale requested
        mov     ax,0004h
        add     al,[cmd_arg_g]
        int     10h
        mov     dx,3ddh
        mov     al,10h
        out     dx,al
        cmp     byte [cmd_arg_f],1
        je      .skip_check
        ; sanity check: Do we have Plantronics page flipping?
        mov     al,50h
        out     dx,al
        mov     byte [es:0],1
        mov     al,10h
        out     dx,al
        cmp     byte [es:0],0
        jne     .error
        .skip_check:
        ; clear the blue/intensity page
        mov     cx,8192
        mov     di,16384
        xor     ax,ax
        rep     stosw
        ret
        .error:
        mov     al,0
        out     dx,al
        tcall   video_error

; disable 16 colors, return to normal mode 4
unset_320x200x16:
        mov     dx,3ddh
        mov     al,00h
        out     dx,al
        ret

emulate_movsb_to_tandy_on_plantronics:
        push    ax
        lodsb
        push    ax
        ; irgb_to_rgrg_pixel
        and     al,66h
        mov     ah,al
        shl     al,1
        shr     ah,1
        or      al,ah
        stosb
        pop     ax
        ; irgb_to_bibi_pixel
        mov     ah,al
        and     al,88h
        shr     al,2
        and     ah,11h
        shl     ah,2
        or      al,ah
        mov     ah,al
        shl     al,1
        shr     ah,1
        or      al,ah
        mov     [es:di+16383],al
        pop     ax
        ret

emulate_movsb_to_vga_on_plantronics:
        push    ax,bx,cx,dx,di

        mov     ax,di
        xor     dx,dx
        mov     bx,320
        div     bx
        cmp     al,200
        jae     .end
        xor     di,di
        shr     ax,1
        rcr     di,1
        shr     di,2
        mov     bx,80
        mul     bl
        add     di,ax

        mov     cx,dx
        and     cl,3
        shl     cl,1
        shr     dx,2
        add     di,dx
        lodsb
        mov     bx,VGA_TO_IRGB_LUT
        cs      xlatb
        mov     ah,al

        mov     dl,[es:di+16384]
        mov     dh,11000000b
        shr     dh,cl
        not     dh
        and     dl,dh
        mov     bl,al
        mov     bh,al
        shr     bl,1
        shl     bh,3
        or      bl,bh
        and     bl,11000000b
        shr     bl,cl
        or      bl,dl
        mov     byte [es:di+16384],bl

        mov     dl,[es:di]
        mov     dh,11000000b
        shr     dh,cl
        not     dh
        and     dl,dh
        mov     bl,al
        shl     bl,1
        and     bl,11000000b
        shr     bl,cl
        or      bl,dl
        mov     byte [es:di],bl

.end:
        pop     di,dx,cx,bx,ax
        inc     di
        ret

convert_tandy_to_plantronics_2:
        mov     di,32768-1
        mov     si,16384-1
        std
        mov     bx,256
.tile_loop:
        mov     cx,64
.byte_loop:
        lodsb
        mov     ah,al
        mov     dx,ax
        ; irgb_to_rgrg_pixel
        and     ax,6666h
        shl     al,1
        shr     ah,1
        or      al,ah
        mov     [es:di-64],al
        ; irgb_to_bibi_pixel
        mov     ax,dx
        and     ax,1188h
        shr     al,2
        shl     ah,2
        or      al,ah
        mov     ah,al
        shl     al,1
        shr     ah,1
        or      al,ah
        stosb
        loop    .byte_loop
        sub     di,64
        dec     bx
        jnz     .tile_loop
        cld
        ret

convert_vga_to_plantronics:
        mov     di,0
        mov     si,0
        mov     bp,256
.tile_loop:
        mov     cx,64
.dword_loop:
        lodsw
        mov     bx,VGA_TO_IRGB_LUT
        cs      xlatb
        xchg    al,ah
        cs      xlatb
        mov     dx,ax
        lodsw
        cs      xlatb
        xchg    al,ah
        cs      xlatb

        shl     dh,1    ; i0
        rcl     bl,1
        shl     dh,1    ; r0
        rcl     bh,1
        shl     dh,1    ; g0
        rcl     bh,1
        shl     dh,1    ; b0
        rcl     bl,1
        shl     dl,1    ; i1
        rcl     bl,1
        shl     dl,1    ; r1
        rcl     bh,1
        shl     dl,1    ; g1
        rcl     bh,1
        shl     dl,1    ; b1
        rcl     bl,1
        shl     ah,1    ; i2
        rcl     bl,1
        shl     ah,1    ; r2
        rcl     bh,1
        shl     ah,1    ; g2
        rcl     bh,1
        shl     ah,1    ; b2
        rcl     bl,1
        shl     al,1    ; i3
        rcl     bl,1
        shl     al,1    ; r3
        rcl     bh,1
        shl     al,1    ; g3
        rcl     bh,1
        shl     al,1    ; b3
        rcl     bl,1
        mov     al,bl
        shl     al,1
        shr     bl,1
        and     al,10101010b
        and     bl,01010101b
        or      bl,al

        ;76543210
        ;76254310
        mov     ax,di
        mov     dl,al
        mov     dh,al
        and     al,11000011b
        shr     dl,1
        and     dl,00011100b
        shl     dh,3
        and     dh,00100000b
        or      al,dl
        or      al,dh
        xchg    ax,di
        mov     [es:di+64],bl
        mov     [es:di],bh
        mov     di,ax
        inc     di

        ;loop    .dword_loop
        dec     cx
        jz      .next
        jmp     .dword_loop
        .next:

        add     di,64
        dec     bp
        ;jnz     .tile_loop
        jz      .next2
        jmp     .tile_loop
        .next2:
        ret
