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
mode_vars_cmp:

.video_hw_needed        dw      VIDEO_HW_COMPOSITE
.VIDEO_SEG              dw      0b800h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      2
.font_bg_norm_bright    dw      2
.font_bg_alt            dw      12
.font_bg_alt_bright     dw      12
.font_bg_frame          dw      0
.radar_color_hydro      dw      2
.radar_color_thermal    dw      12
.radar_color_osc        dw      5
.radar_color_metal      dw      13
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

.file_exts              db      "CMPCMPCMPCMP"

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
.mode_specific_entry    dw      ROTATE_CGA_DATA
.mode_specific_string   dw      menu_string_cga_palette
.set_video_mode         dw      set_video_mode_cmp
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      converting_sys_to_vid_movsb_etga
.convert_tiles          dw      convert_tiles_cmp
.convert_screen         dw      dummy_func

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

align   2
mode_vars_text:

.video_hw_needed        dw      VIDEO_HW_CGA_LIKE | VIDEO_HW_PCJR_OR_BETTER
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

.file_exts              db      "CGTCGTCGTCGT"

.plot_cursor            dw      plot_cursor_text
.plot_cursor_big        dw      plot_cursor_big_text
.i_plot_tile            dw      i_plot_tile_text
.plot_string            dw      plot_string_cga
.plot_string_color      dw      plot_string_color_cga
.plot8pix               dw      plot8pix_text
.scroll_up              dw      scroll_up_cga
.clear_rect             dw      clear_rect_cga
.clear_rect_white       dw      clear_rect_white_cga
.calc_screen_offset     dw      calc_screen_offset_text
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_fixed_palette
.set_video_mode         dw      set_video_mode_text
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      wrapped_movsb
.convert_tiles          dw      dummy_func
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_plantronics:

.video_hw_needed        dw      VIDEO_HW_CGA_LIKE
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
.tileseg_paragraphs     dw      800h
.tile_offset_shift_val  dw      1
.tile_row_offset        dw      640

.fadestep_chunks        dw      (4000h / FADESTEPS)     ; FADESTEP chunks totaling CGA RAM size
.lfsr_tap_bits          dw      0010000000010101B       ; optimal 2^14 tap bits are 14,5,3,1

.file_exts              db      "CGATDYTDYTDY"

.plot_cursor            dw      plot_cursor_plantronics
.plot_cursor_big        dw      plot_cursor_big_plantronics
.i_plot_tile            dw      i_plot_tile_plantronics
.plot_string            dw      plot_string_plantronics
.plot_string_color      dw      plot_string_color_plantronics
.plot8pix               dw      plot8pix_plantronics
.scroll_up              dw      scroll_up_plantronics
.clear_rect             dw      clear_rect_plantronics
.clear_rect_white       dw      clear_rect_white_plantronics
.calc_screen_offset     dw      calc_screen_offset_cga
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_fixed_palette
.set_video_mode         dw      set_video_mode_plantronics
.restore_old_mode       dw      restore_old_mode_plantronics

.converting_sys_to_vid_movsb    dw      emulate_movsb_to_tandy_on_plantronics
.convert_tiles          dw      convert_tiles_plantronics
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_hercules:

.video_hw_needed        dw      VIDEO_HW_MDA_LIKE       ; FIXME
.VIDEO_SEG              dw      0b000h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      0aaaah
.font_bg_norm_bright    dw      0aaaah
.font_bg_alt            dw      0aaaah
.font_bg_alt_bright     dw      0aaaah
.font_bg_frame          dw      0
.radar_color_hydro      dw      0aaaah
.radar_color_thermal    dw      0aaaah
.radar_color_osc        dw      0aaaah
.radar_color_metal      dw      0aaaah
.radar_color_marker     dw      0ffffh
.radar_color_frame      dw      0ffffh

.stride_tile            dw      4
.framebuf_size          dw      16384
.font_size              dw      610
.tileset_size           dw      16384
.tileseg_paragraphs     dw      800h
.tile_offset_shift_val  dw      1
.tile_row_offset        dw      640

.fadestep_chunks        dw      (4000h / FADESTEPS)     ; FADESTEP chunks totaling CGA RAM size
.lfsr_tap_bits          dw      0010000000010101B       ; optimal 2^14 tap bits are 14,5,3,1

.file_exts              db      "CGACGACGACGA"

.plot_cursor            dw      plot_cursor_cga
.plot_cursor_big        dw      plot_cursor_big_cga
.i_plot_tile            dw      i_plot_tile_hercules
.plot_string            dw      plot_string_hercules
.plot_string_color      dw      plot_string_reverse_hercules
.plot8pix               dw      plot8pix_cga
.scroll_up              dw      scroll_up_plantronics
.clear_rect             dw      clear_rect_plantronics
.clear_rect_white       dw      clear_rect_white_plantronics
.calc_screen_offset     dw      calc_screen_offset_cga
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_fixed_palette
.set_video_mode         dw      set_hercules_640x300x2
.restore_old_mode       dw      restore_old_mode_hercules

.converting_sys_to_vid_movsb    dw      emulate_movsb_to_cga_on_hgc
.convert_tiles          dw      convert_tiles_hgc
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_cg2:

.video_hw_needed        dw      VIDEO_HW_CGA_OR_BETTER
.VIDEO_SEG              dw      0b800h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      0aaaah
.font_bg_norm_bright    dw      0aaaah
.font_bg_alt            dw      0aaaah
.font_bg_alt_bright     dw      0aaaah
.font_bg_frame          dw      0
.radar_color_hydro      dw      0aaaah
.radar_color_thermal    dw      0aaaah
.radar_color_osc        dw      0aaaah
.radar_color_metal      dw      0aaaah
.radar_color_marker     dw      0ffffh
.radar_color_frame      dw      0ffffh

.stride_tile            dw      4
.framebuf_size          dw      16384
.font_size              dw      610
.tileset_size           dw      16384
.tileseg_paragraphs     dw      400h
.tile_offset_shift_val  dw      2
.tile_row_offset        dw      640

.fadestep_chunks        dw      (4000h / FADESTEPS)     ; FADESTEP chunks totaling CGA RAM size
.lfsr_tap_bits          dw      0010000000010101B       ; optimal 2^14 tap bits are 14,5,3,1

.file_exts              db      "CGACGACGACG2"

.plot_cursor            dw      plot_cursor_cga
.plot_cursor_big        dw      plot_cursor_big_cga
.i_plot_tile            dw      i_plot_tile_cga
.plot_string            dw      plot_string_cga
.plot_string_color      dw      plot_string_color_cg2
.plot8pix               dw      plot8pix_cga
.scroll_up              dw      scroll_up_cga
.clear_rect             dw      clear_rect_cga
.clear_rect_white       dw      clear_rect_white_cga
.calc_screen_offset     dw      calc_screen_offset_cga
.mode_specific_entry    dw      INVERT_CGA_DATA
.mode_specific_string   dw      menu_string_invert_screen
.set_video_mode         dw      set_video_mode_cg2
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      converting_sys_to_vid_movsb_cg2
.convert_tiles          dw      convert_tiles_cg2
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_vga:

.video_hw_needed        dw      VIDEO_HW_MCGA | VIDEO_HW_VGA
.VIDEO_SEG              dw      0a000h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0000fh
.font_bg_norm           dw      0050fh
.font_bg_norm_bright    dw      00d0fh
.font_bg_alt            dw      0010fh
.font_bg_alt_bright     dw      0090fh
.font_bg_frame          dw      0a70fh
.radar_color_hydro      dw      00505h
.radar_color_thermal    dw      00909h
.radar_color_osc        dw      00808h
.radar_color_metal      dw      00a0ah
.radar_color_marker     dw      00f0fh
.radar_color_frame      dw      0ffffh

.stride_tile            dw      16
.framebuf_size          dw      64000
.font_size              dw      305
.tileset_size           dw      65535   ; we cannot get closer to 64 KiB
.tileseg_paragraphs     dw      1000h
.tile_offset_shift_val  dw      0
.tile_row_offset        dw      5120

.fadestep_chunks        dw      (10000h / FADESTEPS)    ; FADESTEP chunks totaling VGA RAM size
.lfsr_tap_bits          dw      1101000000001000B       ; optimal 2^16 tap bits are 16,15,13,4

.file_exts              db      "VGAVGAVGAVGA"

.plot_cursor            dw      plot_cursor_vga
.plot_cursor_big        dw      plot_cursor_big_vga
.i_plot_tile            dw      i_plot_tile_vga
.plot_string            dw      plot_string_vga
.plot_string_color      dw      plot_string_color_vga
.plot8pix               dw      plot8pix_mcga
.scroll_up              dw      scroll_up_vga
.clear_rect             dw      clear_rect_vga
.clear_rect_white       dw      clear_rect_white_vga
.calc_screen_offset     dw      calc_screen_offset_vga
.mode_specific_entry    dw      TOGGLE_TRANS
.mode_specific_string   dw      menu_string_transparency_on
.set_video_mode         dw      set_video_mode_vga
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      wrapped_movsb
.convert_tiles          dw      fill_transparent_pixels
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_etga:

.video_hw_needed        dw      VIDEO_HW_ETGA
.VIDEO_SEG              dw      0a000h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      1
.font_bg_norm_bright    dw      9
.font_bg_alt            dw      4
.font_bg_alt_bright     dw      12
.font_bg_frame          dw      8
.radar_color_hydro      dw      1
.radar_color_thermal    dw      12
.radar_color_osc        dw      8
.radar_color_metal      dw      14
.radar_color_marker     dw      15
.radar_color_frame      dw      15

.stride_tile            dw      16
.framebuf_size          dw      64000
.font_size              dw      305
.tileset_size           dw      65535   ; we cannot get closer to 64 KiB
.tileseg_paragraphs     dw      1000h
.tile_offset_shift_val  dw      0
.tile_row_offset        dw      5120

.fadestep_chunks        dw      (10000h / FADESTEPS)    ; FADESTEP chunks totaling VGA RAM size
.lfsr_tap_bits          dw      1101000000001000B       ; optimal 2^16 tap bits are 16,15,13,4

.file_exts              db      "VGAVGAVGAVGA"

.plot_cursor            dw      plot_cursor_etga
.plot_cursor_big        dw      plot_cursor_big_etga
.i_plot_tile            dw      i_plot_tile_vga
.plot_string            dw      plot_string_vga
.plot_string_color      dw      plot_string_color_vga
.plot8pix               dw      plot8pix_mcga
.scroll_up              dw      scroll_up_vga
.clear_rect             dw      clear_rect_vga
.clear_rect_white       dw      clear_rect_white_vga
.calc_screen_offset     dw      calc_screen_offset_vga
.mode_specific_entry    dw      TOGGLE_TRANS
.mode_specific_string   dw      menu_string_transparency_on
.set_video_mode         dw      set_video_mode_etga
.restore_old_mode       dw      restore_old_mode_etga

.converting_sys_to_vid_movsb    dw      converting_sys_to_vid_movsb_etga
.convert_tiles          dw      convert_tiles_etga
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_mtdy:

.video_hw_needed        dw      VIDEO_HW_PCJR_OR_TANDY | VIDEO_HW_ETGA
.VIDEO_SEG              dw      0b800h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      1
.font_bg_norm_bright    dw      9
.font_bg_alt            dw      4
.font_bg_alt_bright     dw      12
.font_bg_frame          dw      8
.radar_color_hydro      dw      1
.radar_color_thermal    dw      12
.radar_color_osc        dw      8
.radar_color_metal      dw      14
.radar_color_marker     dw      15
.radar_color_frame      dw      15

.stride_tile            dw      8
.framebuf_size          dw      64000
.font_size              dw      305
.tileset_size           dw      65535   ; we cannot get closer to 64 KiB
.tileseg_paragraphs     dw      1000h
.tile_offset_shift_val  dw      0
.tile_row_offset        dw      640

.fadestep_chunks        dw      (10000h / FADESTEPS)    ; FADESTEP chunks totaling VGA RAM size
.lfsr_tap_bits          dw      1101000000001000B       ; optimal 2^16 tap bits are 16,15,13,4

.file_exts              db      "VGAVGAVGAVGA"

.plot_cursor            dw      plot_cursor_mtdy
.plot_cursor_big        dw      plot_cursor_big_mtdy
.i_plot_tile            dw      i_plot_tile_mtdy
.plot_string            dw      plot_string_mtdy
.plot_string_color      dw      plot_string_color_mtdy
.plot8pix               dw      plot8pix_mtdy
.scroll_up              dw      scroll_up_mtdy
.clear_rect             dw      clear_rect_mtdy
.clear_rect_white       dw      clear_rect_white_mtdy
.calc_screen_offset     dw      calc_screen_offset_mtdy
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_transparency_n_a
.set_video_mode         dw      set_video_mode_mtdy
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      emulate_movsb_to_vga_on_gs
.convert_tiles          dw      convert_tiles_gs
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_atigs:

.video_hw_needed        dw      VIDEO_HW_CGA_LIKE
.VIDEO_SEG              dw      0b000h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      1
.font_bg_norm_bright    dw      9
.font_bg_alt            dw      4
.font_bg_alt_bright     dw      12
.font_bg_frame          dw      8
.radar_color_hydro      dw      1
.radar_color_thermal    dw      12
.radar_color_osc        dw      8
.radar_color_metal      dw      14
.radar_color_marker     dw      15
.radar_color_frame      dw      15

.stride_tile            dw      8
.framebuf_size          dw      64000
.font_size              dw      305
.tileset_size           dw      65535   ; we cannot get closer to 64 KiB
.tileseg_paragraphs     dw      1000h
.tile_offset_shift_val  dw      0
.tile_row_offset        dw      640

.fadestep_chunks        dw      (10000h / FADESTEPS)    ; FADESTEP chunks totaling VGA RAM size
.lfsr_tap_bits          dw      1101000000001000B       ; optimal 2^16 tap bits are 16,15,13,4

.file_exts              db      "VGAVGAVGAVGA"

.plot_cursor            dw      plot_cursor_atigs
.plot_cursor_big        dw      plot_cursor_big_atigs
.i_plot_tile            dw      i_plot_tile_atigs
.plot_string            dw      plot_string_atigs
.plot_string_color      dw      plot_string_color_atigs
.plot8pix               dw      plot8pix_atigs
.scroll_up              dw      scroll_up_atigs
.clear_rect             dw      clear_rect_atigs
.clear_rect_white       dw      clear_rect_white_atigs
.calc_screen_offset     dw      calc_screen_offset_mtdy
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_transparency_n_a
.set_video_mode         dw      set_video_mode_atigs
.restore_old_mode       dw      restore_old_mode_gs

.converting_sys_to_vid_movsb    dw      emulate_movsb_to_vga_on_gs
.convert_tiles          dw      convert_tiles_gs
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_ega:

.video_hw_needed        dw      VIDEO_HW_EGA128 | VIDEO_HW_VGA
.VIDEO_SEG              dw      0a000h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      1
.font_bg_norm_bright    dw      9
.font_bg_alt            dw      4
.font_bg_alt_bright     dw      12
.font_bg_frame          dw      8
.radar_color_hydro      dw      1
.radar_color_thermal    dw      12
.radar_color_osc        dw      8
.radar_color_metal      dw      14
.radar_color_marker     dw      15
.radar_color_frame      dw      15

.stride_tile            dw      4
.framebuf_size          dw      64000
.font_size              dw      610
.tileset_size           dw      65535   ; we cannot get closer to 64 KiB
.tileseg_paragraphs     dw      0
.tile_offset_shift_val  dw      2
.tile_row_offset        dw      1280

.fadestep_chunks        dw      (4000h / FADESTEPS)     ; FADESTEP chunks totaling CGA RAM size
.lfsr_tap_bits          dw      0010000000010101B       ; optimal 2^14 tap bits are 14,5,3,1

.file_exts              db      "CGAVGAVGAVGA"

.plot_cursor            dw      plot_cursor_ega
.plot_cursor_big        dw      plot_cursor_big_ega
.i_plot_tile            dw      i_plot_tile_ega
.plot_string            dw      plot_string_ega
.plot_string_color      dw      plot_string_color_ega
.plot8pix               dw      plot8pix_ega
.scroll_up              dw      scroll_up_ega
.clear_rect             dw      clear_rect_ega
.clear_rect_white       dw      clear_rect_white_ega
.calc_screen_offset     dw      calc_screen_offset_ega
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_transparency_n_a
.set_video_mode         dw      set_video_mode_ega
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      fadein_pixel_xfer_ega
.convert_tiles          dw      convert_tiles_ega
.convert_screen         dw      convert_to_irgb_pairs_and_reorder_for_ega

;----------------------------------------

align   2
mode_vars_vga_y:

.video_hw_needed        dw      VIDEO_HW_VGA
.VIDEO_SEG              dw      0a000h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0000fh
.font_bg_norm           dw      0050fh
.font_bg_norm_bright    dw      00d0fh
.font_bg_alt            dw      0010fh
.font_bg_alt_bright     dw      0090fh
.font_bg_frame          dw      0a70fh
.radar_color_hydro      dw      00505h
.radar_color_thermal    dw      00909h
.radar_color_osc        dw      00808h
.radar_color_metal      dw      00a0ah
.radar_color_marker     dw      00f0fh
.radar_color_frame      dw      0ffffh

.stride_tile            dw      4
.framebuf_size          dw      64000
.font_size              dw      610
.tileset_size           dw      65535   ; we cannot get closer to 64 KiB
.tileseg_paragraphs     dw      0
.tile_offset_shift_val  dw      2
.tile_row_offset        dw      1280

.fadestep_chunks        dw      (10000h / FADESTEPS)    ; FADESTEP chunks totaling VGA RAM size
.lfsr_tap_bits          dw      1101000000001000B       ; optimal 2^16 tap bits are 16,15,13,4

.file_exts              db      "VGAVGAVGAVGA"

.plot_cursor            dw      plot_cursor_vga_y
.plot_cursor_big        dw      plot_cursor_big_vga_y
.i_plot_tile            dw      i_plot_tile_ega
.plot_string            dw      plot_string_vga_y
.plot_string_color      dw      plot_string_color_vga_y
.plot8pix               dw      plot8pix_vga_y
.scroll_up              dw      scroll_up_ega
.clear_rect             dw      clear_rect_ega
.clear_rect_white       dw      clear_rect_white_ega
.calc_screen_offset     dw      calc_screen_offset_ega
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_transparency_n_a
.set_video_mode         dw      set_video_mode_vga_y
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      emulate_movsb_to_vga_on_planar_vga
.convert_tiles          dw      convert_tiles_vga_y
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_plantronics_2:

.video_hw_needed        dw      VIDEO_HW_CGA_LIKE
.VIDEO_SEG              dw      0b800h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      1
.font_bg_norm_bright    dw      9
.font_bg_alt            dw      4
.font_bg_alt_bright     dw      12
.font_bg_frame          dw      8
.radar_color_hydro      dw      1
.radar_color_thermal    dw      12
.radar_color_osc        dw      8
.radar_color_metal      dw      14
.radar_color_marker     dw      15
.radar_color_frame      dw      15

.stride_tile            dw      4
.framebuf_size          dw      64000
.font_size              dw      610
.tileset_size           dw      65535   ; we cannot get closer to 64 KiB
.tileseg_paragraphs     dw      800h
.tile_offset_shift_val  dw      1
.tile_row_offset        dw      640

.fadestep_chunks        dw      (10000h / FADESTEPS)    ; FADESTEP chunks totaling VGA RAM size
.lfsr_tap_bits          dw      1101000000001000B       ; optimal 2^16 tap bits are 16,15,13,4

.file_exts              db      "CGAVGAVGAVGA"

.plot_cursor            dw      plot_cursor_plantronics_2
.plot_cursor_big        dw      plot_cursor_big_plantronics_2
.i_plot_tile            dw      i_plot_tile_plantronics
.plot_string            dw      plot_string_plantronics
.plot_string_color      dw      plot_string_color_plantronics
.plot8pix               dw      plot8pix_plantronics
.scroll_up              dw      scroll_up_plantronics
.clear_rect             dw      clear_rect_plantronics
.clear_rect_white       dw      clear_rect_white_plantronics
.calc_screen_offset     dw      calc_screen_offset_cga
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_transparency_n_a
.set_video_mode         dw      set_video_mode_plantronics_2
.restore_old_mode       dw      restore_old_mode_plantronics

.converting_sys_to_vid_movsb    dw      emulate_movsb_to_vga_on_plantronics
.convert_tiles          dw      convert_tiles_plantronics_2
.convert_screen         dw      dummy_func

;----------------------------------------

align   2
mode_vars_pc1512:

.video_hw_needed        dw      VIDEO_HW_CGA_LIKE
.VIDEO_SEG              dw      0b800h  ; Segment for video output

; colors for GUI elements
.font_bg_black          dw      0
.font_bg_norm           dw      1
.font_bg_norm_bright    dw      9
.font_bg_alt            dw      4
.font_bg_alt_bright     dw      12
.font_bg_frame          dw      8
.radar_color_hydro      dw      1
.radar_color_thermal    dw      12
.radar_color_osc        dw      8
.radar_color_metal      dw      14
.radar_color_marker     dw      15
.radar_color_frame      dw      15

.stride_tile            dw      4
.framebuf_size          dw      64000
.font_size              dw      610
.tileset_size           dw      65535   ; we cannot get closer to 64 KiB
.tileseg_paragraphs     dw      1000h
.tile_offset_shift_val  dw      0
.tile_row_offset        dw      640

.fadestep_chunks        dw      (4000h / FADESTEPS)     ; FADESTEP chunks totaling CGA RAM size
.lfsr_tap_bits          dw      0010000000010101B       ; optimal 2^14 tap bits are 14,5,3,1

.file_exts              db      "CGAVGAVGAVGA"

.plot_cursor            dw      plot_cursor_pc1512
.plot_cursor_big        dw      plot_cursor_big_pc1512
.i_plot_tile            dw      i_plot_tile_pc1512
.plot_string            dw      plot_string_cga
.plot_string_color      dw      plot_string_color_pc1512
.plot8pix               dw      plot8pix_pc1512
.scroll_up              dw      scroll_up_pc1512
.clear_rect             dw      clear_rect_cga
.clear_rect_white       dw      clear_rect_white_cga
.calc_screen_offset     dw      calc_screen_offset_cga
.mode_specific_entry    dw      dummy_func
.mode_specific_string   dw      menu_string_transparency_n_a
.set_video_mode         dw      set_video_mode_pc1512
.restore_old_mode       dw      restore_old_mode_generic

.converting_sys_to_vid_movsb    dw      fadein_pixel_xfer_pc1512
.convert_tiles          dw      convert_tiles_pc1512
.convert_screen         dw      convert_screen_pc1512

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
music_mode_vars_cms:
.ssy_seg_paragraphs     dw      860h    ; 32768 + 1536 bytes
.ssy_mus_data_size      dw      32768
.ssy_base_port          dw      220h
.ssy_wr                 dw      cms_out_c0_emu
.ssy_device_init_func   dw      cms_init
.ssy_device_shut        dw      ssy_tandy_shut
.ssy_device_isr         dw      dummy_func
.ssy_init_in_menu       dw      dummy_func
.ssy_uses_lpt           db      0
.ssy_default_music_on   db      1
.ssy_file_name_marker   db      'T'

;----------------------------------------

align   2
music_mode_vars_cmslpt:
.ssy_seg_paragraphs     dw      860h    ; 32768 + 1536 bytes
.ssy_mus_data_size      dw      32768
.ssy_base_port          dw      0
.ssy_wr                 dw      cmslpt_out_c0_emu
.ssy_device_init_func   dw      cmslpt_init
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
