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

radar_h_counter db      0
radar_mask      db      0
radar_color     dw      0
radar_str       dw      0

RADAR_HYDRO_SCAN:
        mov     ax,[radar_color_hydro]
        mov     [radar_color],ax
        mov     byte [radar_mask],1     ; water
        mov     word [radar_str],TEXT_RADARSCAN3
        call    generic_scan
        ret

RADAR_OSC_SCAN:
        mov     ax,[radar_color_osc]
        mov     [radar_color],ax
        mov     byte [radar_mask],2     ; minerals
        mov     word [radar_str],TEXT_RADARSCAN5
        call    generic_scan
        ret

RADAR_THERMAL_SCAN:
        mov     ax,[radar_color_thermal]
        mov     [radar_color],ax
        mov     byte [radar_mask],4     ; lava/volcano
        mov     word [radar_str],TEXT_RADARSCAN4
        call    generic_scan
        ret

RADAR_METAL_SCAN:
        mov     ax,[radar_color_metal]
        mov     [radar_color],ax
        mov     byte [radar_mask],8     ; all structures and units
        mov     word [radar_str],TEXT_RADARSCAN2
        call    generic_scan
        ret


generic_scan:
        ; check for resources
        mov     byte [TEMP_A],15        ; radar-scan
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        jne     .L1
        ret
        .L1:
        call    RADAR_SETUP_SCREEN

        mov     si,[radar_str]
        mov     di,[textpos_radar2]
        call    WRITE_TEXT

        mov     di,[cs:radar_map_pos]
        xor     si,si
.yloop:
        push    di
        call    [cs:calc_screen_offset]
        mov     bx,radar_lut
        mov     bp,[cs:radar_color]
        mov     byte [cs:radar_h_counter],32
.xloop:
        mov     ah,[cs:radar_mask]
        mov     cl,8
.loop8pix:
        GET_MAP_BYTE    si
        inc     si
        cs xlatb
        and     al,ah                   ; radar bit mask in ah
        add     al,0ffh                 ; overflows if al!=0
        rcl     ch,1
        dec     cl
        jnz     .loop8pix
        call    [cs:plot8pix]
        dec     byte [cs:radar_h_counter]
        jnz     .xloop
        pop     di
        add     di,256                  ; increment y-coordinate
        or      si,si
        jns     .yloop
        call    RADAR_PLOT_SELF
        call    RADAR_WAIT_FOR_KEY
        ret

RADAR_PLOT_SELF:
        ; plot white color for current radar station
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,[UNIT_LOCATION_X+si]
        shr     al,1
        and     al,0fch
        mov     ah,[UNIT_LOCATION_Y+si]
        mov     di,ax
        add     di,[radar_map_pos]
        call    [calc_screen_offset]
        mov     ch,0ffh
        mov     bp,[radar_color_marker]
        call    [plot8pix]
        ret

; The following routine is designed so that when the radar is done
; with a scan, it waits for a key.  However, during this time the
; background routines must still keep going.

RADAR_WAIT_FOR_KEY:
        cmp     byte [cs:BG_TIMER_MAIN],1
        jne     .L1
        call    BACKGROUND_ROUTINE
        .L1:
        mov     ah,1
        int     16H                     ; check keyboard buffer
        jz      RADAR_WAIT_FOR_KEY
        xor     ah,ah                   ; ah = 0
        int     16h                     ; grab key from buffer
        mov     byte [RADAR_ACTIVE],0
        cmp     byte [SCREEN_WIDTH],11  ; Is screen width reduced?
        jne     .L2
        call    CLEAR_PLAYFIELD_WINDOW
        .L2:
        call    force_draw_entire_screen
        mov     al,18                   ; short beep
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        ret

RADAR_SETUP_SCREEN:
        mov     al,20                   ; radar sound
        mov     ah,128                  ; sound priority
        call    m_playSFX               ; play sound effect
        mov     byte [HILITE_MODE],0    ; disable highlite
        mov     byte [RADAR_ACTIVE],1
        call    CLEAR_PLAYFIELD_WINDOW
        mov     di,[textpos_radar1]
        mov     si,TEXT_RADARSCAN1
        mov     ax,[font_bg_norm]
        mov     word [font_bg_color],ax
        call    WRITE_TEXT_COLOR

        mov     di,[radar_map_pos]
        sub     di,0204h
        call    radar_hline
        mov     di,[radar_map_pos]
        sub     di,7f04h
        call    radar_hline
        mov     di,[radar_map_pos]
        sub     di,0104h
        call    radar_vline_l
        mov     di,[radar_map_pos]
        add     di,0ff80h
        call    radar_vline_r
        ret

radar_hline:
        call    [calc_screen_offset]
        mov     bp,[radar_color_frame]
        mov     ch,03h
        call    [plot8pix]
        mov     si,32
.xloop:
        mov     ch,0ffh
        call    [plot8pix]
        dec     si
        jnz     .xloop
        mov     ch,0c0h
        call    [plot8pix]
        ret

radar_vline_l:
        mov     bp,[radar_color_frame]
        mov     si,130
.yloop:
        push    di
        call    [calc_screen_offset]
        mov     ch,02h
        call    [plot8pix]
        pop     di
        add     di,0100h
        dec     si
        jnz     .yloop
        ret

radar_vline_r:
        mov     bp,[radar_color_frame]
        mov     si,130
.yloop:
        push    di
        call    [calc_screen_offset]
        mov     ch,40h
        call    [plot8pix]
        pop     di
        add     di,0100h
        dec     si
        jnz     .yloop
        ret

radar_lut:
        db      0
        db      0
        db      0
        db      0
        db      0
        db      0
        db      2       ; 06h - crystal blue
        db      2       ; 07h - crystal purple
        db      1       ; 08h - water tile
        db      1       ; 09h - water tile
        db      0
        db      0
        db      2       ; 0ch - smaller rock
        db      2       ; 0dh - group cracked rock
        db      2       ; 0eh - big cracked rock
        db      2       ; 0fh - big solid rock
        db      1       ; 10h - water tile
        db      1       ; 11h - water tile
        db      0
        db      0
        db      0
        db      0
        db      0
        db      0
        db      1       ; 18h - water tile
        db      1       ; 19h - water tile
        db      1       ; 1ah - water tile
        db      0
        db      0
        db      0
        db      0
        db      0
        db      0
        db      0
        db      0
        db      0
        db      4       ; 24h - volcano
        db      4       ; 25h - volcano
        db      0
        db      0
        db      0
        db      0
        db      4       ; 2ah - lava tile
        db      4       ; 2bh - lava tile
        db      4       ; 2ch - volcano
        db      4       ; 2dh - volcano
        db      0
        db      0
        db      0
        db      0
        db      4       ; 32h - lava tile
        db      4       ; 33h - lava tile
        db      4       ; 34h - lava tile
        db      4       ; 35h - lava tile
        db      4       ; 36h - lava tile
        db      4       ; 37h - lava tile
        times   50h-38h         db      0
        times   63h-50h         db      8
        times   68h-63h         db      0
        times   6eh-68h         db      8
        db      0
        db      2       ; 6fh - brick walL
        times   76h-70h         db      8
        times   98h-78h         db      8
        times   0a8h-98h        db      0
        times   0b4h-0a8h       db      8
        times   0b8h-0b4h       db      0
        times   0beh-0b8h       db      8
        times   0c0h-0beh       db      0
        times   0c6h-0c0h       db      8
        times   0c8h-0c6h       db      0
        times   0d2h-0c8h       db      8
        times   0d4h-0d2h       db      0
        times   0d8h-0d4h       db      8
        times   0dfh-0d8h       db      0
        db      8
        times   100h-0e0h       db      0
