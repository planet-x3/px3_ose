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
; - Jim Leonard**
; - Benedikt Freisen
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

FIND_MAP_OFFSET:
        ; test if in browse mode, in which case the map offset doesn't move
        cmp     byte [BROWSE_MODE],1
        jne     .L1
        ret
        .L1:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,UNIT_LOCATION_X[di]
        cmp     byte [SCREEN_WIDTH],19
        jne     FMO10

        ; screen width standard 19
        cmp     al,9    ; if X is greater than 9, skip to FMO2
        jae     FMO2
        mov     al,0    ; Otherwise set map offset to zero
        jmp     FMO4
        FMO2:
        cmp     al,246  ; If X is less than 246, skip to FMO3
        jbe     FMO3
        mov     al,237  ; Otherwise set map offset to 237
        jmp     FMO4
        FMO3:
        sub     al,9
        FMO4:
        mov     [MAP_OFFS_X],al
        jmp     FMO15
        FMO10:
        ; screen width reduced 11
        cmp     al,5    ; if X is greater than 9, skip to FMO12
        jae     FMO12
        mov     al,0    ; Otherwise set map offset to zero
        jmp     FMO4
        FMO12:
        cmp     al,250  ; If X is less than 246, skip to FMO13
        jbe     FMO13
        mov     al,245  ; Otherwise set map offset to 237
        jmp     FMO14
        FMO13:
        sub     al,5
        FMO14:
        mov     [MAP_OFFS_X],al

        FMO15:
        ; find Y offset
        mov     al,UNIT_LOCATION_Y[di]
        cmp     al,4    ; if Y is greater than 4, skip to FMO5
        jae     FMO5
        mov     al,0    ; otherwise set map offset to 0
        jmp     FMO7
        FMO5:
        cmp     al,123
        jbe     FMO6
        mov     al,119
        jmp     FMO7
        FMO6:
        sub     al,4
        FMO7:
        mov     [MAP_OFFS_Y],al
        ret

invalidate_lazy_redraw_buffer:
        ; initialize lazy redraw buffer with a very rare tile
        mov     al,0a7h         ; tile: final step of nuclear explosion
        xor     bx,bx
        .l1:
        mov     byte [tiles_to_overwrite+bx],al
        inc     bx
        cmp     bx,19*9
        jne     .l1
        ret

force_draw_entire_screen:
        call    invalidate_lazy_redraw_buffer
        ; fall through to DRAW_ENTIRE_SCREEN

DRAW_ENTIRE_SCREEN: ; faster routine
        cmp     byte [VIDEO_TRANS],1
        jne     .nontransp
        tcall   draw_entire_screen_with_transparency
        .nontransp:
        tcall   draw_entire_screen_without_transparency

draw_entire_screen_without_transparency:
        mov     word [tile_to_overwrite],tiles_to_overwrite
        mov     byte [CURSOR_X],0
        mov     byte [CURSOR_Y],0
        .DES01: ; we do all this stuff one time.
        mov     ah,[CURSOR_Y]
        add     ah,[MAP_OFFS_Y]
        mov     al,[CURSOR_X]
        add     al,[MAP_OFFS_X]
        mov     si,ax
        mov     [TEMP_MAP_LOC],ax
        call    find_screen_location
        GET_MAP_BYTE    si
        mov     [TEMP_A],al
        call    plot_tile_lazy
        inc     byte [CURSOR_X]
        .DES02: ; and now we just adjust as we draw across the screen.
        inc     word [TEMP_MAP_LOC]
        mov     si,[TEMP_MAP_LOC]
        GET_MAP_BYTE    si
        mov     [TEMP_A],al
        call    plot_tile_lazy
        inc     byte [CURSOR_X]
        mov     cl,[SCREEN_WIDTH]
        cmp     [CURSOR_X],cl
        jne     .DES02
        mov     byte [CURSOR_X],0
        inc     byte [CURSOR_Y]
        cmp     byte [CURSOR_Y],9
        jne     .DES01
        ret

tile_to_overwrite       dw      0
tiles_to_overwrite      resb    19*9

draw_entire_screen_with_transparency:
        ret

BROWSE_ERASE_CURSOR:
        call    find_cursor_location
        mov     al,[BROWSE_CURSOR_X]    ; Do this so that the transparent
        mov     [CURSOR_X],al           ; tile routine will know where to look
        mov     al,[BROWSE_CURSOR_Y]    ; for the background tile.
        mov     [CURSOR_Y],al           ;
        call    plot_tile_on_bg
        cmp     byte [BIG_CURSOR_MODE],0
        jne     .L2
        ret
        .L2:
        inc     byte [BROWSE_CURSOR_X]
        call    find_cursor_location
        call    plot_tile_on_bg
        inc     byte [BROWSE_CURSOR_Y]
        call    find_cursor_location
        call    plot_tile_on_bg
        dec     byte [BROWSE_CURSOR_X]
        call    find_cursor_location
        call    plot_tile_on_bg
        dec     byte [BROWSE_CURSOR_Y]
        ret

UNHILITE_UNIT:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,UNIT_LOCATION_X[di]
        sub     al,[MAP_OFFS_X]
        mov     [CURSOR_X],al
        mov     al,UNIT_LOCATION_Y[di]
        sub     al,[MAP_OFFS_Y]
        mov     [CURSOR_Y],al
        cmp     byte [SELECTED_UNIT],20
        jae     .L5
        call    plot_tile_XY_on_bg
        ret
        .L5:
        call    plot_tile_XY_on_bg
        inc     byte [CURSOR_X]
        call    plot_tile_XY_on_bg
        dec     byte [CURSOR_X]
        inc     byte [CURSOR_Y]
        call    plot_tile_XY_on_bg
        inc     byte [CURSOR_X]
        call    plot_tile_XY_on_bg
        ret

DRAW_FLYING_OBJECTS:
        cmp     byte [RADAR_ACTIVE],0
        je      .L1
        ret
        .L1:
        mov     si,196  ; start of projectiles/explosions
        DFO08:
        mov     al,UNIT_TYPE[si]
        cmp     al,31   ; nuclear missile
        je      DFO09
        cmp     al,0
        jne     DFO10
        DFO09:
        inc     si
        cmp     si,212
        jne     DFO08
        ret             ; finished scanning
        DFO10:
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,[MAP_OFFS_X]
        jae     DFO11
        jmp     DFO09   ; OUTSIDE WINDOW AREA (to the left)
        DFO11:
        mov     ah,[MAP_OFFS_X]
        add     ah,[SCREEN_WIDTH]
        dec     ah
        cmp     al,ah
        jbe     DFO12
        jmp     DFO09   ; OUTSIDE WINDOW AREA (to the right)
        DFO12:
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,[MAP_OFFS_Y]
        jae     DFO13
        jmp     DFO09   ; OUTSIDE WINDOW AREA (to the top)
        DFO13:
        mov     ah,[MAP_OFFS_Y]
        add     ah,8
        cmp     al,ah
        jbe     DFO14
        jmp     DFO09   ; outside window area
        DFO14:
        ; if we've come this far, then the object is in
        ; the window area, so we need to draw it.
        mov     al,UNIT_LOCATION_X[si]
        sub     al,[MAP_OFFS_X]
        mov     [CURSOR_X],al
        mov     al,UNIT_LOCATION_Y[si]
        sub     al,[MAP_OFFS_Y]
        mov     [CURSOR_Y],al
        mov     al,[CURSOR_Y]
        mul     byte [SCREEN_WIDTH]
        add     al,[CURSOR_X]
        add     ax,tiles_to_overwrite
        mov     [tile_to_overwrite],ax
        mov     al,UNIT_TILE[si]
        mov     [TEMP_A],al
        push    si
        call    find_screen_location
        cmp     byte [VIDEO_TRANS],1
        jne     .L15
        call    plot_tile_transparent_vga
        pop     si
        jmp     DFO09
        .L15:
        call    plot_tile_lazy
        pop     si
        jmp     DFO09

;-----------------------------------------------------------------------

; description:
;       Calculates an offset in video memory from browse cursor and map offset.
; parameters:
;       BROWSE_CURSOR_X
;       BROWSE_CURSOR_Y
;       MAP_OFFS_X
;       MAP_OFFS_Y
;       [out] TEMP_A: tile under cursor
; returns:
;       di: location in video memory
find_cursor_location:
        mov     si,[BROWSE_CURSOR_X]    ; loads both, x and y
        add     si,[MAP_OFFS_X]         ; loads and adds both, x and y
        GET_MAP_BYTE    si
        mov     byte [TEMP_A],al
        mov     ax,[BROWSE_CURSOR_X]    ; loads both, x and y
        tcall   find_screen_location.skip_load_ax

; description:
;       Calculates an offset in video memory from the cursor location.
; parameters:
;       CURSOR_X
;       CURSOR_Y
;       SCREEN_WIDTH
; returns:
;       di: location in video memory
find_screen_location:
        mov     ax,[CURSOR_X]           ; loads both, x and y
.skip_load_ax:
        shl     ah,4
        shl     al,3
        mov     di,256*10+4
        add     di,ax
        cmp     byte [SCREEN_WIDTH],19
        je      .full_width
        add     di,32
.full_width:
        tcall   [calc_screen_offset]

; description:
;       Plot the appropriate tile from the map at the current cursor location.
; parameters:
;       CURSOR_X
;       CURSOR_Y
;       MAP_OFFS_X
;       MAP_OFFS_Y
; returns:
;       di: next destination offset in video memory
plot_tile_XY_on_bg:
        ; find correct tile
        mov     si,[CURSOR_X]           ; loads both, x and y
        add     si,[MAP_OFFS_X]         ; loads and adds both, x and y
        GET_MAP_BYTE    si
        mov     byte [TEMP_A],al
        call    find_screen_location
plot_tile_on_bg:
        cmp     byte [VIDEO_TRANS],1
        je      .transparent
        tcall   plot_tile
        .transparent:
        tcall   plot_tile_on_bg_vga

plot_tile_on_bg_vga:
        ret

; description:
;       Plot the tile with the provided index at the provided offset in
;       video memory offset.  Skip this if the tile stayed the same.
; parameters:
;       di: destination offset in video memory
;       TEMP_A: the tile index
; returns:
;       di: next destination offset in video memory
plot_tile_lazy:
        mov     bx,[tile_to_overwrite]
        cmp     al,[ds:bx]
        je      plot_tile.lazy
        mov     [ds:bx],al
        inc     bx
        mov     word [tile_to_overwrite],bx
plot_tile:                                      ; used for plotting tile elsewhere
        ; find tile location
        mov     si,word [TEMP_A_TIMES_256]      ; get pre-multiplied tile number
        mov     cl,[tile_offset_shift_val]      ; adjust for current mode
        shr     si,cl
        push    ds
        mov     ds,[TILESEG]

        call    [cs:i_plot_tile]

        pop     ds
        ret
        .lazy:
        inc     bx
        mov     word [tile_to_overwrite],bx
        add     di,[stride_tile]
        ret

; description:
;       Internal tile plotting routine for CGA.
; parameters:
;       si: tile bitmap
;       di: destination offset in video memory
; returns:
;       di: next destination offset in video memory
i_plot_tile_cga:
        mov     ax,76
        mov     bx,7628
        mov     cx,2
        mov     dx,-16380
.L1:
        movsw
        movsw
        add     di,ax
        movsw
        movsw
        add     di,ax
        movsw
        movsw
        add     di,ax
        movsw
        movsw
        add     di,ax
        movsw
        movsw
        add     di,ax
        movsw
        movsw
        add     di,ax
        movsw
        movsw
        add     di,ax
        movsw
        movsw
        add     di,bx
        loop    .L1
        add     di,dx
        ret

; description:
;       Tile plotting routine for menus.
; parameters:
;       al: tile index
;       di: destination offset in video memory
plot_tile_in_gui:
        mov     byte [TEMP_A],al
        tcall   plot_tile

; description:
;       Big tile (2x2) plotting routine for menus.
; parameters:
;       al: top left tile index
;       di: destination offset in video memory
plot_tile_in_gui_big:
        push    di
        push    ax
        call    plot_tile_in_gui
        pop     ax
        inc     al
        push    ax
        call    plot_tile_in_gui
        pop     ax
        pop     di
        add     al,7
        add     di,[tile_row_offset]
        push    ax
        call    plot_tile_in_gui
        pop     ax
        inc     al
        call    plot_tile_in_gui
        ret

; description:
;       Gets the tile index of the tile below the unit the cursor points at.
; parameters:
;       CURSOR_X
;       CURSOR_Y
;       MAP_OFFS_X
;       MAP_OFFS_Y
; returns:
;       bx: pre-multiplied tile number
; clobbers:
;       ax
get_tile_under_unit:
        xor     bx,bx                   ; find what unit# this is we're drawing
        .L3:
        cmp     byte UNIT_TYPE[bx],0
        je      .L4
        mov     al,UNIT_LOCATION_X[bx]
        mov     ah,UNIT_LOCATION_Y[bx]
        sub     ax,[CURSOR_X]           ; loads and subtracts both, x and y
        sub     ax,[MAP_OFFS_X]         ; loads and subtracts both, x and y
        jz      .L10
        .L4:
        inc     bx
        cmp     bx,127                  ; highest unit number that should be transparent
        jne     .L3
        .L10:
        ; unit number should now be in si
        mov     bh,UNIT_TILE_UNDER[bx]  ; ax=TILE NUMBER * 256
        mov     bl,0
        ret

; description:
;       Internal transparent tile plotting routine for VGA.
; parameters:
;       si: tile bitmap (foreground)
;       bx: tile bitmap (background)
;       di: destination offset in video memory
; returns:
;       di: next destination offset in video memory
i_plot_tile_on_bg_vga:
        sub     bx,si
        dec     bx
        mov     dx,304
        mov     ah,16
.yloop:
        mov     cx,16
.xloop:
        lodsb
        cmp     al,14
        je      .read_bg_pix
        stosb
        loop    .xloop
        jmp     .xloop_end
.read_bg_pix:
        mov     al,[bx+si]
        stosb
        loop    .xloop
.xloop_end:
        add     di,dx
        dec     ah
        jnz     .yloop
        sub     di,4800+304
        ret

plot_tile_transparent_vga:
        push    ds
        xor     ax,ax
        mov     ah,[TEMP_A]             ; ax=tile * 256
        xchg    si,ax                   ; si points to tile data
        mov     ah,16                   ; ah = number of tile rows
        mov     ds,[TILESEG]
.L2:
        mov     cx,16
.T0:
        lodsb                           ; load pixel into al, inc si
        cmp     al,14                   ; is pixel transparent?
        je      .L5                     ; if so, do not plot
        mov     [es:di],al              ; otherwise, plot
.L5:
        inc     di
        loop    .T0                     ; repeat cx times
        add     di,320-16               ; skip to next line
        dec     ah
        jnz     .L2                     ; if ah not 0, do next row
        pop     ds
        ret
