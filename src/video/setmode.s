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

; simple gray ramp (identity transform)
; gray_ramp db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

; composite gray ramp of the ATI Graphics Solution
; gray_ramp db 0,1,2,3,8,9,10,11,4,5,6,7,12,13,14,15

; PCem's default gray ramp for monochrome CGA screens
gray_ramp db 0,1,2,3,4,8,5,9,6,10,7,11,12,13,14,15

; description:
;       Converts the VGA palette to grayscale, if grayscale mode is enabled.
palette_to_gray:
        ; abort if grayscale mode is not enabled
        cmp     byte [cmd_arg_g],1
        je      .continue
        ret
.continue:
        mov     cx,256
        mov     si,VGA_PALETTE
.loop256:
        ; 77*R, 150*G, 29*B
        ; 19635+38250+7395
        ; 72,76*R, 140,88*G, 27,36*B
        ; 18615+35955+6885
        lodsb
        mov     ah,73
        mul     ah
        mov     dx,ax
        lodsb
        mov     ah,141
        mul     ah
        add     dx,ax
        lodsb
        mov     ah,27
        mul     ah
        add     dx,ax
        mov     [ds:si-3],dh
        mov     [ds:si-2],dh
        mov     [ds:si-1],dh

        loop    .loop256
        ret

; description:
;       Generates grayscale LUTs for 320x200 and 640x200 pixel 16-color modes,
;       if grayscale mode is enabled.
gen_gray_luts_if_needed:
        ; abort if grayscale mode is not enabled
        cmp     byte [cmd_arg_g],1
        je      .continue
        ret
.continue:
        call    palette_to_gray
        mov     cx,256
        mov     si,VGA_PALETTE+1
        xor     di,di
        mov     bx,gray_ramp
.loop256:
        lodsb
        add     si,2
        mov     dh,al

        shr     dh,3
        shr     dh,1
        mov     dl,dh
        adc     dl,0
        mov     al,dl
        xlatb
        mov     ah,0
        ror     ax,4
        mov     al,dh
        xlatb
        or      al,ah

        mov     [ds:di+VGA_TO_ETGA_LUT],al
        and     al,0f0h
        mov     [ds:di+VGA_TO_IRGB_LUT],al
        inc     di

        loop    .loop256
        ret

; description:
;       Converts the 256-entry color LUT from IRGBIRGB to RGRGBIBI format.
convert_lut_to_rgrgbibi:
        mov     si,VGA_TO_ETGA_LUT
        mov     cx,256
        .loop256:
        lodsb
        mov     ah,al
        mov     dx,ax
        shr     ah,5
        shl     al,5
        shl     ax,6
        and     ah,0f0h
        and     dx,1188h
        shl     dh,2
        shr     dl,2
        or      dl,dh
        mov     dh,dl
        shr     dh,5
        shl     dl,5
        shl     dx,2
        and     dh,0fh
        or      ah,dh
        mov     [si-1],ah
        loop    .loop256
        ret

; description:
;       Sets the freely selectable CGA color to the one requested via command line.
set_fg_bg_overscan_color:
        cmp     byte [cmd_arg_c],1
        jne     .end
        mov     ah,0bh
        mov     bh,0
        mov     bl,[cga_color_override]
        int     10h
        .end:
        ret

; description:
;       Sets a 4-color CGA mode, respecting various command line options.
set_video_mode_cga:
        cmp     byte [cmd_arg_i],0
        je      .not_inverted
        mov     word [converting_sys_to_vid_movsb],converting_sys_to_vid_movsb_altcga
        mov     word [convert_tiles],convert_tiles_altcga
        .not_inverted:
        call    prepare_color_vars_cga
        cmp     byte [cmd_arg_g],0
        je      .normal_cga
        mov     ax,[font_bg_norm]
        mov     [font_bg_frame],ax
        tcall   set_video_mode_cga_g
        .normal_cga:
        mov     ax,0004h                ; Set graphics mode 4 (320x200x4)
        int     10h                     ; Do it!
        call    set_fg_bg_overscan_color
        ret

; description:
;       Sets composite color CGA mode.
set_video_mode_cmp:
        mov     ax,0006h                ; Set graphics mode 6 (640x200x2)
        int     10h                     ; Do it!
        mov     al,1ah
        mov     dx,03d8h
        out     dx,al                   ; enable color burst
        call    prepare_color_vars_tdy
        ; pre-rotate colors according to /r command line option
        mov     ch,0
        mov     cl,[cmd_arg_r]
        .l1:
        push    cx
        mov     si,font_bg_black
        mov     cx,12
        call    block_rol4              ; rotate color variables
        mov     si,identity_16
        mov     cx,8
        call    block_rol4              ; rotate identity_16
        mov     si,tdy2cmp_16
        mov     cx,8
        call    block_rol4              ; rotate identity_16
        pop     cx
        loop    .l1

        call    prepare_cmp_luts
        ret

; description:
;       Sets 2-color CGA mode.
set_video_mode_cg2:
        mov     ax,0006h                ; Set graphics mode 6 (640x200x2)
        int     10h                     ; Do it!
        call    set_fg_bg_overscan_color
        cmp     byte [cmd_arg_i],1
        jne     .end
        call    toggle_inverted
        .end:
        ret

; description:
;       Sets low-resolution Tandy mode.
set_video_mode_ltdy:
        mov     ax,0008h                ; Set graphics mode 8 (160x200x16)
        int     10h                     ; Do it!
        call    prepare_color_vars_tdy
        ret

; description:
;       Tries to set a CGA mode with four shades of gray.
set_video_mode_cga_g:
        mov     ax,0005h                ; Set graphics mode 5 (320x200x4 gray)
        int     10h                     ; Do it!
        mov     ax,1000h                ; Set palette register (on PCjr, Tandy)
        mov     bx,070bh                ; Remap light cyan to light gray
        int     10h
        mov     bx,080ch                ; Remap light red to dark gray
        int     10h
        cli                             ; Do the same on EGA and above
        mov     dx,3dah                 ; (Attribute controller)
        in      al,dx                   ; Reset write mode to 'address'
        mov     dl,0c0h                 ; (dx = 3c0h, palette reg.)
        mov     al,1
        out     dx,al                   ; Set color 1...
        mov     al,7
        out     dx,al                   ; ...to light gray
        mov     al,2
        out     dx,al                   ; Set color 2...
        mov     al,56
        out     dx,al                   ; ...to dark gray
        mov     al,3
        out     dx,al                   ; Set color 3...
        mov     al,63
        out     dx,al                   ; ...to white
        mov     dl,0dah                 ; (dx = 3dah, attr. contr. reg.)
        in      al,dx                   ; Reset write mode to 'address'
        mov     dl,0c0h                 ; (dx = 3c0h, palette reg.)
        mov     al,20h                  ; Set bit 5 of address register
        out     dx,al
        sti
        call    set_fg_bg_overscan_color
        ret

; description:
;       Sets a heavily modified text mode with a memory layout similar to low-resolution Tandy.
set_video_mode_text:
        mov     ax,0001h                ; 40x25 text mode
        int     10h
        mov     dx,3d8h
        mov     al,00h
        out     dx,al
        mov     dx,3d4h
        mov     al,4                    ; Vertical total
        out     dx,al
        inc     dx
        mov     al,124
        out     dx,al
        dec     dx
        mov     al,5                    ; Vertical total adjust
        out     dx,al
        inc     dx
        mov     al,6
        out     dx,al
        dec     dx
        mov     al,6                    ; Vertical displayed
        out     dx,al
        inc     dx
        mov     al,100
        out     dx,al
        dec     dx
        mov     al,7                    ; Vertical sync position
        out     dx,al
        inc     dx
        mov     al,112
        out     dx,al
        dec     dx
        mov     al,9                    ; Max scan line address
        out     dx,al
        inc     dx
        mov     al,1
        out     dx,al
        mov     dx,3d8h
        mov     al,08h
        out     dx,al
        call    prepare_color_vars_text
        ret

; description:
;       Sets the 640x200x16 mode of the Enhanced Tandy Graphics Adapter.
set_video_mode_etga:
        call    set_etga_640x200x16
        call    gen_gray_luts_if_needed
        call    prepare_color_vars_etga
        cmp     byte [cmd_arg_o],'4'
        je      .do_not_restore_transparency_color
        mov     byte [VGA_TO_ETGA_LUT+14],14
        .do_not_restore_transparency_color:
        ret

; description:
;       Sets the ordinary 256-color VGA (MCGA) mode.
set_video_mode_vga:
        ; set VGA mode
        mov     ax,0013h
        int     10h                     ; Do it!
        call    palette_to_gray
        call    SET_VGA_PALETTE
        ret

; description:
;       Sets the acceleraded "mode Y" with 320x200 pixels and 256 colors.
set_video_mode_vga_y:
        ; set VGA mode
        mov     ax,0013h
        int     10h                     ; Do it!
        call    palette_to_gray
        call    SET_VGA_PALETTE
        ; reconfigure to planar VGA
        mov     dx,3d4h
        mov     al,14h
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        dec     dx
        mov     al,17h
        out     dx,al
        inc     dx
        mov     al,0e3h
        out     dx,al
        mov     dx,3c4h
        mov     al,4
        out     dx,al
        inc     dx
        mov     al,6
        out     dx,al
        ; clear screen
        xor     ax,ax
        mov     cx,8000
        xor     di,di
        rep     stosw
        ; adjust memory layout
        mov     ax,[SCRATCHSEG]
        mov     [TILELOADSEG],ax
        mov     word [TILESEG],0a400h
        ret

; description:
;       Sets medium-resolution Tandy mode.
set_video_mode_mtdy:
        ; set medium-resolution Tandy mode
        mov     ax,0009h
        int     10h                     ; Do it!
        call    gen_gray_luts_if_needed
        call    prepare_color_vars_tdy
        ; set the correct LUT
        push    es,di
        push    ds
        pop     es
        mov     di,VGA_TO_GS_LUT
        mov     si,VGA_TO_IRGB_LUT
        mov     cx,128
        rep     movsw
        pop     di,es
        ; convert font
        tcall   convert_vga_font_for_mtdy_and_atigs

; description:
;       Sets the ATI Graphics Solution's 640x200x16 mode.
set_video_mode_atigs:
        ; first stage sanity check: b000h must be free
        push    es
        mov     ax,0b000h
        mov     es,ax
        mov     bx,[es:0]
        mov     byte [es:0],0           ; paranoid test writes
        mov     byte [es:1],1
        cmp     byte [es:0],0           ; read back 1st byte written
        jne     .b000_free
        cmp     byte [es:1],1           ; read back 2nd byte written
        jne     .b000_free
        ; success = failure: there is presumably an MDA or HGC there
        mov     [es:0],bx               ; restore previous content
        call    EXITPROG
        db      "Error: Segment b000h already occupied!",13,10,0
        .b000_free:
        pop     es
        ; proceed to mode setting, which can do further sanity checks
        call    set_gs_640x200x16
        call    gen_gray_luts_if_needed
        call    prepare_color_vars_plantronics
        call    convert_lut_to_rgrgbibi
        tcall   convert_vga_font_for_mtdy_and_atigs

; description:
;       Sets the 640x200x16 EGA mode.
set_video_mode_ega:
        ; set EGA mode 0eh (640x200x16)
        mov     ax,000eh
        int     10h
        call    gen_gray_luts_if_needed
        call    prepare_color_vars_ega
        ; adjust memory layout
        mov     ax,[SCRATCHSEG]
        mov     [TILELOADSEG],ax
        mov     word [TILESEG],0a400h
        ret

; description:
;       Sets the 640x350x3 EGA mode.
set_video_mode_ega_mono:
        ; set EGA mode 0fh (640x350x3)
        mov     ax,000fh
        int     10h
        call    gen_gray_luts_if_needed
        call    prepare_color_vars_ega
        ; adjust memory layout
        mov     ax,[SCRATCHSEG]
        mov     [TILELOADSEG],ax
        mov     word [TILESEG],0a800h
        ret

; description:
;       Sets Plantronics ColorPlus mode for use with Tandy artwork.
set_video_mode_plantronics:
        call    set_plantronics_320x200x16
        call    prepare_color_vars_plantronics
        ret

; description:
;       Sets Plantronics ColorPlus mode for use with VGA artwork.
set_video_mode_plantronics_2:
        call    set_plantronics_320x200x16
        call    gen_gray_luts_if_needed
        call    prepare_color_vars_plantronics
        ; adjust memory layout
        mov     ax,[SCRATCHSEG]
        mov     [TILELOADSEG],ax
        ret

; description:
;       Sets the Amstrad PC1512's 640x200x16 mode.
set_video_mode_pc1512:
        mov     ax,0006h                ; 640x200 CGA mode
        int     10h
        mov     dx,3ddh                 ; bit plane write enable register
        cmp     byte [cmd_arg_f],1
        je      .skip_check
        ; Sanity check: If a byte written to the red plane comes back
        ; via the (default) blue plane, this is not a PC1512 VDU!
        mov     byte [es:0],0           ; write a 0 to all planes
        mov     al,4                    ; select red plane for writes
        out     dx,al
        mov     byte [es:0],1           ; write a 0 to the red plane
        cmp     byte [es:0],1           ; compare to blue plane
        je      .error                  ; not a PC1512 VDU
        mov     byte [es:0],0           ; get rid of the red pixel
        .skip_check:
        mov     al,0fh
        out     dx,al                   ; select all planes, again
        mov     dl,0d9h
        out     dx,al                   ; also make all planes visible
        call    gen_gray_luts_if_needed
        call    prepare_color_vars_ega
        ; adjust memory layout
        mov     ax,[SCRATCHSEG]
        mov     [TILELOADSEG],ax
        ret
        .error:
        tcall   video_error

; description:
;       Tries to detect the type of video hardware in a safe manner.
; variables:
;       video_hw [out]
detect_video_hw:
        ; check whether it supports VGA's "read combination code"
        mov     ax,1a00h
        int     10h
        ; if this is not a VGA (or MCGA), check EGA next
        cmp     al,1ah
        jne     .check_for_ega
        mov     word [video_hw],VIDEO_HW_VGA
        ; check whether this was actually an MCGA
        cmp     bl,0ah
        jb      .not_mcga
        cmp     bl,0ch
        ja      .not_mcga
        mov     word [video_hw],VIDEO_HW_MCGA
        .not_mcga:
        jmp     .end
        .check_for_ega:
        ; if this is not an EGA, check MDA next
        mov     ah,12h
        mov     bl,10h
        int     10h
        cmp     bl,10h
        je      .check_for_mda
        mov     word [video_hw],VIDEO_HW_EGA
        ; does the EGA have at least 256KiB/128KiB of RAM?
        cmp     bl,3
        jb      .ega_128k
        mov     word [video_hw],VIDEO_HW_EGA256
        jmp     .end
        .ega_128k:
        cmp     bl,1
        jb      .ega_64k
        mov     word [video_hw],VIDEO_HW_EGA128
        .ega_64k:
        jmp     .end
        .check_for_mda:
        ; if it is neither VGA nor EGA and runs in mode 7, it must be in an MDA-like mode
        mov     ax,0f00h
        int     10h
        cmp     al,7
        jne     .check_for_pcjr_or_old_tandy
        mov     word [video_hw],VIDEO_HW_MDA_LIKE
        jmp     .end
        .check_for_pcjr_or_old_tandy:
        ; check magic numbers in BIOS area to rule out PCjr and older Tandy 1000
        push    es
        mov     ax,0fc00h
        mov     es,ax
        mov     ah,[es:3ffeh]
        mov     al,[es:0]
        pop     es
        cmp     ax,0ff21h
        je      .check_for_newer_tandy ; i.e. is at least older Tandy or PCjr
        ; CGA stuff goes here
        mov     word [video_hw],VIDEO_HW_CGA_LIKE
        jmp     .end
        .check_for_newer_tandy:
        ; newer Tandy 1000 detected
        mov     word [video_hw],VIDEO_HW_PCJR_OR_TANDY
        ; check whether it supports "get configuration"
        push    es
        mov     ah,0c0h
        int     15h
        pop     es
        jc      .is_newer_non_etga_tandy
        ; it does => Tandy Video II detected (RL, SL and TL series)
        mov     word [video_hw],VIDEO_HW_ETGA
        jmp     .end
        .is_newer_non_etga_tandy:
        mov     word [video_hw],VIDEO_HW_TANDY
        jmp     .end
        .end:
        ret

; description:
;       Aborts with an error message that says that the video hardware is not compatible.
; returns:
;       DOES NOT RETURN
video_error:
        call    EXITPROG
        db      "No compatible hardware detected.",13,10
        db      "Choose a different video mode or skip checks with /f.",13,10,0

; description:
;       Initialize the configured video mode using the mode variables and prepare the environment.
set_video:
        cmp     byte [cmd_arg_f],1
        je      .hw_detection_successful_or_skipped
        call    detect_video_hw
        mov     ax,[video_hw_needed]
        test    ax,[video_hw]
        jnz     .hw_detection_successful_or_skipped
        tcall   video_error
        .hw_detection_successful_or_skipped:
        call    [set_video_mode]
        cmp     word [tileset_size],16384
        jne     .skip_coord_override
        mov     word [numpos_xcoord],xy(28,158)
        mov     word [numpos_ycoord],xy(80,158)
        .skip_coord_override:
        tcall   transform_screen_coords

; description:
;       Restore the old video mode in a generic manner.
restore_old_mode_generic:
        mov     ah,0                    ; subfunction 0 sets video mode
        mov     al,[cs:old_mode]        ; mode saved at program start
        int     10h
        ret

; description:
;       Restore the old video mode, disabling Plantronics ColorPlus mode.
restore_old_mode_plantronics:
        call    unset_320x200x16
        mov     ah,0                    ; subfunction 0 sets video mode
        mov     al,[cs:old_mode]        ; mode saved at program start
        int     10h
        ret

; description:
;       Restore the old video mode, disabling ETGA mode.
restore_old_mode_etga:
        call    exit_etga_640x200x16
        mov     ah,0                    ; subfunction 0 sets video mode
        mov     al,[cs:old_mode]        ; mode saved at program start
        int     10h
        ret

; description:
;       Restore the old video mode, disabling the ATI-GS mode.
restore_old_mode_gs:
        call    switch_from_gs_to_mode_3
        mov     ah,0                    ; subfunction 0 sets video mode
        mov     al,[cs:old_mode]        ; mode saved at program start
        int     10h
        ret
