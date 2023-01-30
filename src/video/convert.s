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

; NOTE: Some conversion code lives in files dedicated to the respective
;       graphics card rather then here.

; description:
;       Does a single "movsb".
wrapped_movsb:
        movsb
        ret

; description:
;       Acts like "movsb", but swaps the two middle colors of CGA pixel data.
converting_sys_to_vid_movsb_altcga:
        push    ax
        pushf
        lodsb
        mov     ah,al
        and     ax,55aah
        shl     ah,1
        shr     al,1
        or      al,ah
        stosb
        popf
        pop     ax
        ret

; description:
;       Acts like "movsb", but dithers 4-color to 2-color CGA pixel data.
converting_sys_to_vid_movsb_cg2:
        push    ax
        pushf
        lodsb
        mov     ah,al
        and     ah,55h
        shl     ah,1
        test    di,2000h
        jz      .L1
        or      ah,77h
        jmp     .L2
.L1:
        or      ah,0ddh
.L2:
        and     al,ah
        xor     al,[cs:screen_xor]
        stosb
        popf
        pop     ax
        ret

; description:
;       Dummy function for function pointer tables.
dummy_func:
        ret

; description:
;       Translates the full TDY tileset to a Plantronics-friendly format.
convert_tiles_plantronics:
        push    ds
        push    es
        mov     ds,[cs:TILESEG]
        mov     es,[cs:TILESEG]
        call    convert_tandy_to_plantronics_2
        pop     es
        pop     ds
        ret

; description:
;       Translates the full VGA tileset to a Plantronics-friendly format.
convert_tiles_plantronics_2:
        call    fill_transparent_pixels
        push    ds
        push    es
        mov     ds,[cs:TILELOADSEG]
        mov     es,[cs:TILESEG]
        call    convert_vga_to_plantronics
        pop     es
        pop     ds
        ret

; description:
;       Translates the full CGA tileset to a Hercules-friendly format.
convert_tiles_hgc:
        push    ds
        push    es
        mov     ds,[cs:TILESEG]
        mov     es,[cs:TILESEG]
        call    convert_cga_to_3_field_hgc
        pop     es
        pop     ds
        ret

; description:
;       Swaps the two middle colors of the CGA tileset.
convert_tiles_altcga:
        push    ds
        mov     si,[TILESEG]
        mov     ds,si
        xor     si,si
        xor     di,di
        push    es
        push    ds
        pop     es
        mov     cx,16384
        .ctloop:
        lodsb
        mov     ah,al
        and     ax,55aah
        shl     ah,1
        shr     al,1
        or      al,ah
        stosb
        loop    .ctloop
        pop     es
        pop     ds
        ret

; description:
;       Converts a 4-color CGA tileset to 2-color using dithering.
convert_tiles_cg2:
        cmp     byte [FILENAME_TILES+8],'A'
        je      .dither_dark_color
        cmp     word [screen_xor],0
        je      .end
        tcall   INVERT_TILES_BW
        .dither_dark_color:
        push    ds
        mov     si,[TILESEG]
        mov     ds,si
        xor     si,si
        xor     di,di
        push    es
        push    ds
        pop     es
        mov     cx,16384
        .ctloop:
        lodsb
        mov     ah,al
        and     ah,55h
        shl     ah,1
        test    di,20h
        jz      .L1
        or      ah,77h
        jmp     .L2
.L1:
        or      ah,0ddh
.L2:
        and     al,ah
        xor     al,[cs:screen_xor]
        stosb
        loop    .ctloop
        pop     es
        pop     ds
        .end:
        ret

; description:
;       Runs an entire CMP tileset through a color LUT.
convert_tiles_cmp:
        push    es
        push    ds
        mov     bx,VGA_TO_ETGA_LUT
        cmp     byte file_exts[9],'T'   ; use TDY tileset
        jne     .use_cmp_tileset
        mov     bx,VGA_TO_IRGB_LUT
        .use_cmp_tileset:
        mov     es,[TILESEG]
        mov     ds,[TILESEG]
        xor     si,si
        xor     di,di
        mov     cx,16384
        .l1:
        lodsb
        cs      xlatb
        stosb
        loop    .l1
        pop     ds
        pop     es
        ret

; description:
;       Acts like "movsb", but runs the pixel data through a color LUT.
converting_sys_to_vid_movsb_etga:
        push    ax
        lodsb                           ; load pixel
        push    bx
        mov     bx,VGA_TO_ETGA_LUT
        cs xlatb
        pop     bx
        stosb                           ; copy to screen
        pop     ax
        ret

; description:
;       Runs an entire VGA tileset through a color LUT.
convert_tiles_etga:
        call    fill_transparent_pixels
        mov     es,[TILESEG]
        xor     di,di                   ; es:di = tileseg:0
        mov     cx,0ffffh               ; 64KB
        call    vga2etga
        ret

; description:
;       Runs an entire VGA tileset through a color LUT and translates it to
;       an ATI Graphics Solution friendly format.
convert_tiles_gs:
        call    fill_transparent_pixels
        push    ds,si,es,di
        mov     es,[SCRATCHSEG]
        xor     di,di                   ; es:di = scratchseg:0
        mov     ds,[TILESEG]
        xor     si,si                   ; ds:si = tileseg:0
        call    convert_vga_to_gs
        pop     di,es,di,ds
        ret

; description:
;       Runs an entire VGA tileset through a color LUT, translates it to an
;       EGA-friendly format and takes care of storing it in VRAM bitplanes.
convert_tiles_ega:
        call    fill_transparent_pixels
        push    ds
        push    es
        mov     es,[TILESEG]
        mov     ds,[SCRATCHSEG]
        xor     si,si
        xor     di,di
        mov     cx,0ffffh
        call    convert_to_irgb_pairs_and_reorder_for_ega
        mov     cx,4000h
        call    copy_interleaved_bytes_to_vram_bitplanes
        pop     es
        pop     ds
        ret

; description:
;       Translates an entire VGA to a VGA "mode Y" friendly format and takes
;       care of storing it in VRAM bitplanes.
convert_tiles_vga_y:
        call    fill_transparent_pixels
        push    ds
        push    es
        mov     es,[TILESEG]
        mov     ds,[SCRATCHSEG]
        xor     si,si
        xor     di,di
        mov     cx,4000h
        call    copy_interleaved_bytes_to_vram_bitplanes
        pop     es
        pop     ds
        ret

rearrange_interleaved_bytes_for_pc1512:
        mov     bp,256
.tile_loop:
        mov     ah,2
.field_loop:
        mov     bl,8
.line_loop:
        mov     cx,4
.byte_loop:
        lodsb
        mov     [es:di],al
        lodsb
        mov     [es:di+64],al
        lodsb
        mov     [es:di+128],al
        lodsb
        mov     [es:di+192],al
        inc     di
        loop    .byte_loop

        add     si,16
        dec     bl
        jnz     .line_loop

        sub     si,256-16
        dec     ah
        jnz     .field_loop

        add     si,256-32
        add     di,192
        dec     bp
        jnz     .tile_loop
        ret

; description:
;       Runs an entire VGA tileset through a color LUT and translates it to
;        a PC1512-friendly format.
convert_tiles_pc1512:
        call    fill_transparent_pixels
        push    ds
        push    es
        mov     es,[TILESEG]
        mov     ds,[SCRATCHSEG]
        xor     si,si
        xor     di,di
        mov     cx,0ffffh
        call    convert_to_irgb_pairs_and_reorder_for_ega
        call    rearrange_interleaved_bytes_for_pc1512
        pop     es
        pop     ds
        ret

convert_screen_pc1512:
        call    convert_to_irgb_pairs_and_reorder_for_ega
        ret

; description:
;       Copy a group of pixels to PC1512 VRAM in a way that mimics what
;       other video modes do using "movsb" or an emulation.
fadein_pixel_xfer_pc1512:
        push    ax,dx,si

        mov     ax,si
        cmp     ax,2000h
        cmc
        rcr     si,1
        and     ax,0dfffh
        mov     dh,80
        div     dh
        mov     dl,ah
        shl     si,1
        rcl     al,1
        mul     dh
        mov     dh,0
        add     ax,dx
        mov     si,ax

        mov     dx,3ddh
        mov     al,1
        out     dx,al
        shl     si,2
        lodsb
        mov     [es:di],al
        mov     al,2
        out     dx,al
        lodsb
        mov     [es:di],al
        mov     al,4
        out     dx,al
        lodsb
        mov     [es:di],al
        mov     al,8
        out     dx,al
        movsb
        mov     al,0fh
        out     dx,al
        pop     si,dx,ax
        ret

; description:
;       Copy a group of pixels to EGA VRAM in a way that mimics what
;       other video modes do using "movsb" or an emulation.
fadein_pixel_xfer_ega:
        push    ax,dx,si
        mov     dx,3c4h
        mov     al,2
        out     dx,al
        mov     dl,0c5h
        mov     al,1
        out     dx,al
        shl     si,2
        lodsb
        mov     [es:di],al
        mov     al,2
        out     dx,al
        lodsb
        mov     [es:di],al
        mov     al,4
        out     dx,al
        lodsb
        mov     [es:di],al
        mov     al,8
        out     dx,al
        movsb
        mov     al,0fh
        out     dx,al
        pop     si,dx,ax
        ret

; description:
;       Convert the VGA font to a format better suited for medium-res. Tandy
;       and ATI Graphics Solution mode.
convert_vga_font_for_mtdy_and_atigs:
        push    es,di
        push    ds
        pop     es
        mov     cx,305
        std
        mov     si,FONT+304
        mov     di,FONT+1218
.L0:
        lodsb
        shr     al,1
        rcr     bx,1
        sar     bx,3
        shr     al,1
        rcr     bx,1
        sar     bx,3
        shr     al,1
        rcr     bx,1
        sar     bx,3
        shr     al,1
        rcr     bx,1
        sar     bx,3
        shr     al,1
        rcr     dx,1
        sar     dx,3
        shr     al,1
        rcr     dx,1
        sar     dx,3
        shr     al,1
        rcr     dx,1
        sar     dx,3
        shr     al,1
        rcr     dx,1
        sar     dx,3
        mov     al,bh
        mov     ah,bl
        stosw
        mov     al,dh
        mov     ah,dl
        stosw
        loop    .L0
        cld
        pop     di,es
        ret

; description:
;       Prepare the color variables for text mode.
; parameters:
;       si: block of 2-byte color variables
prepare_color_vars_text:
        call    prepare_color_vars_tdy
        mov     byte [si-24],0
        mov     byte [si-22],0
        mov     byte [si-20],0
        mov     byte [si-18],0
        mov     byte [si-16],0
        mov     byte [si-14],0
        and     byte [si-12],0f0fh
        and     byte [si-10],0f0fh
        and     byte [si-8],0f0fh
        and     byte [si-6],0f0fh
        and     byte [si-4],0f0fh
        and     byte [si-2],0f0fh
        ret

; description:
;       Prepare the color variables for Plantronics ColorPlus mode.
; parameters:
;       si: block of 2-byte color variables
prepare_color_vars_plantronics:
        mov     si,font_bg_black
        ; font background colors
        ; and radar colors
        mov     cx,12
        .l1:
        lodsw
        ; table lookup
        mov     bx,irgb_to_pal_lut
        xlatb
        mov     bx,VGA_TO_IRGB_LUT
        xlatb
        shr     al,4
        ; adjust format
        mov     ah,al
        shl     al,4
        or      al,ah
        mov     ah,al
        shr     al,1
        shr     ah,3
        and     ax,0303h
        mov     dx,ax
        shl     dx,2
        or      ax,dx
        mov     dx,ax
        shl     dx,4
        or      ax,dx
        mov     [si-2],ax
        loop    .l1
        ret

; description:
;       Prepare the color variables for ETGA (high-res. Tandy) mode.
; parameters:
;       si: block of 2-byte color variables
prepare_color_vars_etga:
        call    prepare_color_vars_tdy
        mov     byte [si-24],0ffh
        mov     byte [si-22],0ffh
        mov     byte [si-20],0ffh
        mov     byte [si-18],0ffh
        mov     byte [si-16],0ffh
        mov     byte [si-14],0ffh
        ret

; description:
;       Prepare the color variables for CGA mode.
; parameters:
;       si: block of 2-byte color variables
prepare_color_vars_cga:
        mov     si,font_bg_black
        ; font background colors
        ; and radar colors
        mov     cx,12
        .l1:
        lodsw
        ; handle /i
        cmp     byte [cmd_arg_i],1
        jne     .not_inverted
        mov     dx,ax
        and     ax,05555h
        and     dx,0aaaah
        shl     ax,1
        shr     dx,1
        or      ax,dx
        .not_inverted:
        mov     [si-2],ax
        loop    .l1
        ret

; description:
;       Prepare the color variables for (low/medium-res.) Tandy mode.
; parameters:
;       si: block of 2-byte color variables
prepare_color_vars_tdy:
        mov     si,font_bg_black
        ; font background colors
        ; and radar colors
        mov     cx,12
        .l1:
        lodsw
        ; table lookup
        mov     bx,irgb_to_pal_lut
        xlatb
        mov     bx,VGA_TO_IRGB_LUT
        xlatb
        shr     al,4
        ; adjust format
        mov     ah,al
        shl     al,4
        or      al,ah
        mov     ah,al
        mov     [si-2],ax
        loop    .l1
        ret

; description:
;       Prepare the color variables for EGA mode.
; parameters:
;       si: block of 2-byte color variables
prepare_color_vars_ega:
        mov     si,font_bg_black
        ; font background colors
        ; and radar colors
        mov     cx,12
        .l1:
        lodsw
        ; table lookup
        mov     bx,irgb_to_pal_lut
        xlatb
        mov     bx,VGA_TO_IRGB_LUT
        xlatb
        shr     al,4
        mov     [si-2],ax
        loop    .l1
        ret


; description:
;       Prepares a LUT for composite CGA to simplify both, color rotation
;       and TDY to CMP translation.
prepare_cmp_luts:
        push    es
        push    ds
        pop     es

        ; create LUT for rotation only
        xor     bx,bx
        mov     di,VGA_TO_ETGA_LUT
        xor     cx,cx
        .l1:
        mov     bl,cl
        and     bl,0fh
        mov     al,identity_16[bx]
        mov     bl,cl
        shr     bl,4
        mov     ah,identity_16[bx]
        shl     ah,4
        or      al,ah
        stosb
        inc     cl
        jnz     .l1
        ; create LUT for rotation + TDY to CMP translation
        xor     bx,bx
        mov     di,VGA_TO_IRGB_LUT
        xor     cx,cx
        .l2:
        mov     bl,cl
        and     bl,0fh
        mov     al,tdy2cmp_16[bx]
        mov     bl,cl
        shr     bl,4
        mov     ah,tdy2cmp_16[bx]
        shl     ah,4
        or      al,ah
        stosb
        inc     cl
        jnz     .l2

        pop     es
        ret

identity_16     db      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
; cmp2tdy_16      db      0,2,1,9,4,3,5,7,6,10,8,11,12,14,13,15
tdy2cmp_16      db      0,2,1,5,4,6,8,7,10,3,9,11,12,14,13,15


; description:
;       Rotates all nybbles in a block of an even number of bytes left by one bit.
; parameters:
;       si: pointer to the block (ds)
;       cx: number of 2-byte words
block_rol4:
        push    es
        push    ds
        pop     es

        mov     di,si
        .l1:
        lodsw
        mov     bx,ax
        shl     bx,1
        and     bx,1110111011101110b
        shr     ax,3
        and     ax,0001000100010001b
        or      ax,bx
        stosw
        loop    .l1

        pop     es
        ret


INVERT_COLORS:
        push    ax,bx,cx,es,di          ; save what we'll be trashing
        mov     cx,(16384 / 2)          ; 8192 words
        push    ds
        mov     ds,[TILESEG]
        xor     si,si                   ; ds:si = start of tilearray
        call    block_rol4              ; rotate tileset data
        pop     ds
        mov     si,font_bg_black
        mov     cx,12
        call    block_rol4              ; rotate color variables
        mov     si,identity_16
        mov     cx,8
        call    block_rol4              ; rotate identity_16
        mov     si,tdy2cmp_16
        mov     cx,8
        call    block_rol4              ; rotate identity_16
        call    prepare_cmp_luts
        pop     di,es,cx,bx,ax          ; restore what we trashed
        ret

INVERT_TILES_BW:
        push    es,di,cx
        push    ds
        mov     ds,[TILESEG]
        xor     si,si
        push    ds
        pop     es
        mov     di,si
        mov     cx,(16384 / 2)
.L1:
        lodsw
        not     ax
        stosw
        loop    .L1
        pop     ds
        pop     cx,di,es
        ret

INVERT_SCREEN_BW:
        push    ds,di,cx
        mov     cx,(16384 / 2)
        xor     si,si
        mov     di,si
        push    es
        pop     ds
.L1:
        lodsw
        not     ax
        stosw
        loop    .L1
        pop     cx,di,ds
        ret


INVERT_SCREEN:
        push    ax,bx,cx,ds,es,di       ; save what we'll be trashing
        mov     cx,(16384 / 2)          ; 8192 words
        xor     di,di                   ; es:di = b800:0000
        mov     si,di
        push    es
        pop     ds                      ; ds:si = es:di = b800:0000

.L1:
        ; Rotate four nybbles one bit to the left, in parallel
        lodsw                           ; AX = ds:si
        mov     bx,ax                   ; ponmlkjihgfedcba
        shr     bx,3                    ; 000ponmlkjihgfed
        and     bx,0001000100010001b    ; 000p000l000h000d
        shl     ax,1                    ; onmlkjihgfedcba0
        and     ax,1110111011101110b    ; onm0kji0gfe0cba0
        or      ax,bx                   ; onmpkjilgfehcbad
        stosw                           ; AX = es:di
        loop    .L1

        pop     di,es,ds,cx,bx,ax       ; restore what we trashed
        ret
