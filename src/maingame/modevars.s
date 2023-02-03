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

FADESTEPS       EQU     (16*4)  ; 72Hz ticks, this is 64, close enough

;----------------------------------------

align   2
mode_vars:

video_hw_needed         dw      VIDEO_HW_CGA_OR_BETTER
VIDEO_SEG               dw      0b800h  ; Segment for video output

; colors for GUI elements
font_bg_black           dw      0
font_bg_norm            dw      0aaaah
font_bg_norm_bright     dw      0aaaah
font_bg_alt             dw      0aaaah
font_bg_alt_bright      dw      0aaaah
font_bg_frame           dw      0
radar_color_hydro       dw      0aaaah
radar_color_thermal     dw      0aaaah
radar_color_osc         dw      0aaaah
radar_color_metal       dw      0aaaah
radar_color_marker      dw      0ffffh
radar_color_frame       dw      0ffffh

stride_tile             dw      4
framebuf_size           dw      16384
font_size               dw      610
tileset_size            dw      16384
tileseg_paragraphs      dw      400h
tile_offset_shift_val   dw      2
tile_row_offset         dw      640

fadestep_chunks         dw      (4000h / FADESTEPS)     ; FADESTEP chunks totaling CGA RAM size
lfsr_tap_bits           dw      0010000000010101B       ; optimal 2^14 tap bits are 14,5,3,1

file_exts               db      "CGACGACGACGA"

plot_cursor             dw      plot_cursor_cga
plot_cursor_big         dw      plot_cursor_big_cga
i_plot_tile             dw      i_plot_tile_cga
plot_string             dw      plot_string_cga
plot_string_color       dw      plot_string_color_cga
plot8pix                dw      plot8pix_cga
scroll_up               dw      scroll_up_cga
clear_rect              dw      clear_rect_cga
clear_rect_white        dw      clear_rect_white_cga
calc_screen_offset      dw      calc_screen_offset_cga
mode_specific_entry     dw      ROTATE_CGA_PALETTE
mode_specific_string    dw      menu_string_cga_palette
set_video_mode          dw      set_video_mode_cga
restore_old_mode        dw      restore_old_mode_generic

converting_sys_to_vid_movsb     dw      wrapped_movsb
convert_tiles           dw      dummy_func
convert_screen          dw      dummy_func

align   2
mode_vars_end:

;----------------------------------------

align   2
mode_vars_ltdy:

.video_hw_needed        dw      VIDEO_HW_PCJR_OR_BETTER
.VIDEO_SEG              dw      0b800h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      1
.font_bg_norm_bright    dw      9
.font_bg_alt            dw      4
.font_bg_alt_bright     dw      12
.font_bg_frame          dw      0
.radar_color_hydro      dw      1
.radar_color_thermal    dw      12
.radar_color_osc        dw      8
.radar_color_metal      dw      14
.radar_color_marker     dw      15
.radar_color_frame      dw      15

.stride_tile            dw      4
.framebuf_size          dw      16384
.font_size              dw      610
.tileset_size           dw      16384
.tileseg_paragraphs     dw      400h
.tile_offset_shift_val  dw      2
.tile_row_offset        dw      640

.fadestep_chunks        dw      (4000h / FADESTEPS)     ; FADESTEP chunks totaling CGA RAM size
.lfsr_tap_bits          dw      0010000000010101B       ; optimal 2^14 tap bits are 14,5,3,1

.file_exts              db      "CMPTDYTDYTDY"

.plot_cursor            dw      plot_cursor_cga
.plot_cursor_big        dw      plot_cursor_big_cga
.i_plot_tile            dw      i_plot_tile_cga
.plot_string            dw      plot_string_cga
.plot_string_color      dw      plot_string_color_cga
.plot8pix               dw      plot8pix_ltdy
.scroll_up              dw      scroll_up_cga
.clear_rect             dw      clear_rect_cga
.clear_rect_white       dw      clear_rect_white_cga
.calc_screen_offset     dw      calc_screen_offset_cga
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_fixed_palette
.set_video_mode         dw      set_video_mode_ltdy
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      wrapped_movsb
.convert_tiles          dw      dummy_func
.convert_screen         dw      dummy_func

;----------------------------------------

; description:
;       Copy block of mode-specific variables to mode_vars.
; parameters:
;       si: source pointer
set_mode_vars:
        push    es
        push    ds
        pop     es
        ; copy mode vars
        mov     di,mode_vars
.L1:
        movsw
        cmp     di,mode_vars_end
        jne     .L1
        ; fill in file extensions
        mov     si,file_exts
        mov     di,FILENAME_FONT+5
        movsw
        movsb
        mov     di,FILENAME_MENU+5
        movsw
        movsb
        mov     di,FILENAME_IN+8
        movsw
        movsb
        mov     di,FILENAME_TILES+6
        movsw
        movsb
        ; copy pointers for mode specific menu entry to menu structure
        mov     si,[mode_specific_string]
        mov     [game_menu_items+40],si
        mov     si,[mode_specific_entry]
        mov     [game_menu_items+42],si
        ; enable transparency where available
        cmp     word [mode_specific_string],menu_string_transparency_on
        jne     .L2
        mov     byte [VIDEO_TRANS],1
.L2:
        pop     es
        ret

menu_string_cga_palette         db      "  CGA PALETTE   "
menu_string_fixed_palette       db      " FIXED PALETTE  "
menu_string_invert_screen       db      " INVERT SCREEN  "
menu_string_transparency_on     db      "TRANSPARENCY-ON "
menu_string_transparency_n_a    db      "TRANSPARENCY-N/A"

;----------------------------------------
;----------------------------------------
;----------------------------------------

align   2
music_mode_vars:
ssy_seg_paragraphs      dw      860h     ; FIXME: should be 0 + 1536 bytes
ssy_mus_data_size       dw      32768    ; FIXME: apparently still hardcoded somewhere; shoud be 0 here
ssy_base_port           dw      0
ssy_wr                  dw      dummy_func
ssy_device_init_func    dw      dummy_func
ssy_device_shut         dw      dummy_func
ssy_device_isr          dw      dummy_func
ssy_init_in_menu        dw      dummy_func
ssy_uses_lpt            db      0
ssy_default_music_on    db      0
ssy_file_name_marker    db      0

align   2
music_mode_vars_end:

;----------------------------------------

align   2
music_mode_vars_speaker:
.ssy_seg_paragraphs     dw      860h    ; 32768 + 1536 bytes
.ssy_mus_data_size      dw      32768
.ssy_base_port          dw      0
.ssy_wr                 dw      dummy_func
.ssy_device_init_func   dw      dummy_func
.ssy_device_shut        dw      ssy_pcspe_shut
.ssy_device_isr         dw      dummy_func
.ssy_init_in_menu       dw      dummy_func
.ssy_uses_lpt           db      0
.ssy_default_music_on   db      0
.ssy_file_name_marker   db      'S'

;----------------------------------------

align   2
music_mode_vars_tandy:
.ssy_seg_paragraphs     dw      860h    ; 32768 + 1536 bytes
.ssy_mus_data_size      dw      32768
.ssy_base_port          dw      0c0h
.ssy_wr                 dw      ssy_tandy_write
.ssy_device_init_func   dw      dummy_func
.ssy_device_shut        dw      ssy_tandy_shut
.ssy_device_isr         dw      dummy_func
.ssy_init_in_menu       dw      dummy_func
.ssy_uses_lpt           db      0
.ssy_default_music_on   db      1
.ssy_file_name_marker   db      'T'

;----------------------------------------

align   2
music_mode_vars_tndlpt:
.ssy_seg_paragraphs     dw      860h    ; 32768 + 1536 bytes
.ssy_mus_data_size      dw      32768
.ssy_base_port          dw      0
.ssy_wr                 dw      ssy_tndlpt_write
.ssy_device_init_func   dw      dummy_func
.ssy_device_shut        dw      ssy_tandy_shut
.ssy_device_isr         dw      dummy_func
.ssy_init_in_menu       dw      dummy_func
.ssy_uses_lpt           db      1
.ssy_default_music_on   db      1
.ssy_file_name_marker   db      'T'

;----------------------------------------

align   2
music_mode_vars_adlib:
.ssy_seg_paragraphs     dw      860h    ; 32768 + 1536 bytes
.ssy_mus_data_size      dw      32768
.ssy_base_port          dw      388h
.ssy_wr                 dw      ssy_adlib_write
.ssy_device_init_func   dw      dummy_func
.ssy_device_shut        dw      ssy_adlib_shut
.ssy_device_isr         dw      dummy_func
.ssy_init_in_menu       dw      dummy_func
.ssy_uses_lpt           db      0
.ssy_default_music_on   db      1
.ssy_file_name_marker   db      'A'

;----------------------------------------

align   2
music_mode_vars_opl2lpt:
.ssy_seg_paragraphs     dw      860h    ; 32768 + 1536 bytes
.ssy_mus_data_size      dw      32768
.ssy_base_port          dw      0
.ssy_wr                 dw      ssy_opl2lpt_write
.ssy_device_init_func   dw      dummy_func
.ssy_device_shut        dw      ssy_adlib_shut
.ssy_init_in_menu       dw      dummy_func
.ssy_device_isr         dw      dummy_func
.ssy_uses_lpt           db      1
.ssy_default_music_on   db      1
.ssy_file_name_marker   db      'A'

;----------------------------------------

align   2
music_mode_vars_gm:
.ssy_seg_paragraphs     dw      1000h   ; 64000 + 1536 bytes
.ssy_mus_data_size      dw      64000
.ssy_base_port          dw      MPU_DataPort
.ssy_wr                 dw      dummy_func
.ssy_device_init_func   dw      MPU_Init
.ssy_device_shut        dw      StopSong
.ssy_device_isr         dw      interrupt
.ssy_init_in_menu       dw      dummy_func
.ssy_uses_lpt           db      0
.ssy_default_music_on   db      1
.ssy_file_name_marker   db      'G'

;----------------------------------------

align   2
music_mode_vars_mt32:
.ssy_seg_paragraphs     dw      1000h   ; 64000 + 1536 bytes
.ssy_mus_data_size      dw      64000
.ssy_base_port          dw      MPU_DataPort
.ssy_wr                 dw      dummy_func
.ssy_device_init_func   dw      MPU_Init
.ssy_device_shut        dw      StopSong
.ssy_device_isr         dw      interrupt
.ssy_init_in_menu       dw      MPU_InitMT32
.ssy_uses_lpt           db      0
.ssy_default_music_on   db      1
.ssy_file_name_marker   db      'M'

;----------------------------------------

; description:
;       Copy block of mode-specific variables to music_mode_vars.
; parameters:
;       si: source pointer
set_music_mode_vars:
        push    es
        push    ds
        pop     es
        ; copy music mode vars
        mov     di,music_mode_vars
.L1:
        movsw
        cmp     di,music_mode_vars_end
        jne     .L1
        pop     es
        ret
