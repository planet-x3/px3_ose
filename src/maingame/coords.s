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

; convert X-, Y-coordinates on a 320x200 screen to packed logical coordinates:
;       upper byte: Y-coordinate (0-199)
;       lower byte: X-coordinate (0-159)
%define xy(x,y) (((y)<<8) + ((x)>>1))

screen_coords_to_transform:
; variables for text positions
textpos_clock   dw      xy(248,2)
textpos_msg6    dw      xy(0,194)
textpos_stat1   dw      xy(120,164)
textpos_stat2   dw      xy(140,170)
textpos_stat3   dw      xy(140,176)
textpos_stat4   dw      xy(152,182)
textpos_stat5   dw      xy(120,188)     ; column 1
textpos_stat5c2 dw      xy(120,188)
textpos_stat5w  dw      xy(140,188)     ; column 4
textpos_stat5r  dw      xy(156,188)
textpos_stat6   dw      xy(120,194)     ; column 1
textpos_stat6c2 dw      xy(120,194)     ; column 2
textpos_stat6w  dw      xy(128,194)     ; column 2
textpos_stat6c3 dw      xy(128,194)
textpos_cmd1l   dw      xy(224,164)
textpos_cmd2l   dw      xy(224,170)
textpos_cmd3l   dw      xy(224,176)
textpos_cmd4l   dw      xy(224,182)
textpos_cmd5l   dw      xy(224,188)
textpos_cmd6l   dw      xy(224,194)
textpos_radar1  dw      xy(32,10)
textpos_radar2  dw      xy(32,16)
textpos_credits dw      xy(64,194)
textpos_ldsav1  dw      xy(104,80)
textpos_ldsav2  dw      xy(104,86)
textpos_hhg1    dw      xy(108,78)
textpos_hhg2    dw      xy(108,84)
textpos_hhg3    dw      xy(108,90)
textpos_mt32    dw      xy(104,154)

tilepos_stat2   dw      xy(120,170)
tilepos_stat2r  dw      xy(160,170)
tilepos_stat4   dw      xy(192,182)
tilepos_govr_hq dw      xy(16,40)
tilepos_govr_py dw      xy(168,40)
tilepos_govr_hu dw      xy(16,80)
tilepos_govr_pr dw      xy(168,80)

numpos_stat2    dw      xy(196,170)
numpos_stat3    dw      xy(196,176)
numpos_stat5    dw      xy(192,188)
numpos_stat6ll  dw      xy(136,194)
numpos_stat6l   dw      xy(176,194)
numpos_stat6    dw      xy(192,194)
numpos_stat6r   dw      xy(184,194)
numpos_govr_bch dw      xy(56,48)
numpos_govr_bcp dw      xy(208,48)
numpos_govr_uch dw      xy(40,88)
numpos_govr_ucp dw      xy(192,88)
numpos_minerals dw      xy(40,2)
numpos_gas      dw      xy(120,2)
numpos_energy   dw      xy(200,2)
numpos_xcoord   dw      xy(40,157)
numpos_ycoord   dw      xy(84,157)

clockpos_govr   dw      xy(120,120)

rect_msg        dw      xy(0,176)
rect_stat       dw      xy(120,164)
rect_cmd        dw      xy(224,164)
rect_playfield  dw      xy(8,10)
rect_credits    dw      xy(64,100)
rect_menu       dw      xy(92,58)

textpos_govr01  dw      xy(68,6)
textpos_govr02  dw      xy(60,6)
textpos_govr03  dw      xy(48,24)
textpos_govr04  dw      xy(200,24)
textpos_govr05l dw      xy(56,40)
textpos_govr05r dw      xy(208,40)
textpos_govr06l dw      xy(40,80)
textpos_govr06r dw      xy(192,80)
textpos_govr07  dw      xy(16,120)
textpos_govr08  dw      xy(16,136)
textpos_govr09  dw      xy(176,144)
textpos_govr10  dw      xy(216,152)
textpos_govr11  dw      xy(192,160)
textpos_govr80  dw      xy(16,180)

after_screen_coords_to_transform:

radar_map_pos   dw      xy(32,24)
error_pos_intro dw      xy(96,142)
error_pos_game  dw      xy(96,76)

; description:
;       Transforms all coordinates from the block between screen_coords_to_transform
;       and after_screen_coords_to_transform for the current video mode.
transform_screen_coords:
        mov     si,screen_coords_to_transform
        .L1:
        lodsw
        mov     di,ax
        call    [calc_screen_offset]
        mov     [si-2],di
        cmp     si,after_screen_coords_to_transform
        jne     .L1
        ret
