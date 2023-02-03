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

; description:
;       Sets a 4-color CGA mode, respecting various command line options.
set_video_mode_cga:
        call    prepare_color_vars_cga
        cmp     byte [cmd_arg_g],0
        je      .normal_cga
        mov     ax,[font_bg_norm]
        mov     [font_bg_frame],ax
        tcall   set_video_mode_cga_g
        .normal_cga:
        mov     ax,0004h                ; Set graphics mode 4 (320x200x4)
        int     10h                     ; Do it!
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

set_fg_bg_overscan_color:
        ret

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
        ; does the EGA have at least 128KiB of RAM?
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
