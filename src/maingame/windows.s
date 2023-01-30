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

DRAW_UNIT_WORKING:
        mov     di,[textpos_stat5w]
        mov     si,TEXT_WORKING
        call    WRITE_TEXT_COLOR
        mov     di,[textpos_stat6w]
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     cl,UNIT_WORKING[si]
        dec     cl
        mov     al,0
        .L1:
        cmp     al,cl
        jb      .L2
        mov     bl,45                   ; minus sign
        jmp     .L3
        .L2:
        mov     bl,38                   ; block character
        .L3:
        push    ax
        push    cx
        call    PLOT_CHAR
        pop     cx
        pop     ax
        inc     al
        cmp     al,10
        jne     .L1
        ret

DRAW_STATUS_WINDOW:
        call    CLEAR_STATUS_WINDOW
        cmp     byte [BROWSE_MODE],0
        je      .L1
        call    DRAW_STATUS_BROWSE
        ret
        .L1:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],0    ; is unit dead?
        jne     .L2
        ret
        .L2:
        mov     al,UNIT_TILE[si]
        mov     [SELECTED_TILE],al
        mov     di,[textpos_stat1]
        call    WRITE_TILE_NAME
        mov     di,[tilepos_stat2]
        mov     al,[SELECTED_TILE]
        call    plot_tile_in_gui
        mov     di,[textpos_stat2]
        mov     si,TEXT_HEALTH          ; health
        call    WRITE_TEXT
        mov     di,[textpos_stat3]
        mov     si,TEXT_UNIT            ; unit #
        call    WRITE_TEXT
        mov     di,[numpos_stat2]
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_HEALTH[si]
        mov     [HEXNUM],al
        mov     ax,[font_bg_black]
        mov     word [font_bg_color],ax
        call    WRITE_DECNUM            ; write health
        mov     di,[numpos_stat3]
        mov     al,[SELECTED_UNIT]
        mov     [HEXNUM],al
        call    WRITE_DECNUM            ; write unit#
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_WORKING[si],0
        je      .L3
        call    DRAW_UNIT_WORKING
        ret
        .L3:
        mov     al,UNIT_TYPE[si]
        cmp     al,1                    ; builder
        jne     .L5
        call    DRAW_STATUS_BUILDER
        ret
        .L5:
        cmp     al,22                   ; power station
        jne     .L6
        call    DRAW_STATUS_POWER_STATION
        ret
        .L6:
        cmp     al,23                   ; solar panel
        jne     .L7
        call    DRAW_STATUS_SOLAR_PANEL
        ret
        .L7:
        cmp     al,26                   ; missile silo
        jne     .L8
        call    DRAW_STATUS_MISSILE_SILO
        ret
        .L8:
        cmp     al,20                   ; headquarters
        jne     .L9
        call    DRAW_STATUS_HEADQUARTERS
        ret
        .L9:
        cmp     al,27                   ; smelter
        jne     .L10
        call    DRAW_STATUS_SMELTER
        ret
        .L10:
        ret

DRAW_STATUS_SMELTER:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],8
        jne     .L2
        mov     si,TEXT_SMELTER1
        mov     di,[textpos_stat5]
        call    WRITE_TEXT
        mov     si,TEXT_SMELTER2
        mov     di,[textpos_stat6]
        call    WRITE_TEXT
        .L2:
        ret

DRAW_STATUS_HEADQUARTERS:
        mov     si,TEXT_COMCEN1
        mov     di,[textpos_stat5]
        call    WRITE_TEXT
        mov     si,TEXT_COMCEN2
        mov     di,[textpos_stat6]
        call    WRITE_TEXT
        ; display number of units
        mov     al,[UNIT_COUNT_PLUNITS]
        mov     [HEXNUM],al
        mov     di,[numpos_stat5]
        call    WRITE_DECNUM
        ; display number of buildings
        mov     al,[UNIT_COUNT_PLBLDG]
        mov     [HEXNUM],al
        mov     di,[numpos_stat6]
        call    WRITE_DECNUM
        ret

DRAW_STATUS_MISSILE_SILO:
        mov     si,TEXT_MISSILE6
        mov     di,[textpos_stat5c2]
        call    WRITE_TEXT
        mov     si,TEXT_MISSILE7
        mov     di,[textpos_stat6c2]
        call    WRITE_TEXT
        ; find target X cordinate
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_DEST_X[si]
        mov     [HEXNUM],al
        mov     di,[numpos_stat6ll]
        mov     ax,[font_bg_black]
        mov     word [font_bg_color],ax
        call    WRITE_DECNUM
        ; find target Y cordinate
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_DEST_Y[si]
        mov     [HEXNUM],al
        mov     di,[numpos_stat6r]
        call    WRITE_DECNUM
        ; check if armed
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_GEN_A[si],0
        je      .L1
        mov     di,[textpos_stat4]
        mov     si,TEXT_MISSILE8
        mov     ax,[font_bg_alt]
        mov     word [font_bg_color],ax
        call    WRITE_TEXT_COLOR
        .L1:
        ret

DRAW_STATUS_SOLAR_PANEL:
        mov     al,UNIT_GEN_A[si]
        cmp     al,0
        je      .L1
        mov     [HEXNUM],al
        mov     di,[numpos_stat6l]
        call    WRITE_DECNUM
        mov     si,TEXT_CONPANEL3
        mov     di,[textpos_stat5]
        call    WRITE_TEXT
        mov     si,TEXT_CONPANEL4
        mov     di,[textpos_stat6]
        call    WRITE_TEXT
        ret
        .L1:     ; not connnected
        mov     ax,[font_bg_alt]
        mov     word [font_bg_color],ax
        mov     si,TEXT_CONPANEL5
        mov     di,[textpos_stat5r]
        call    WRITE_TEXT_COLOR
        mov     si,TEXT_CONPANEL6
        mov     di,[textpos_stat6c3]
        call    WRITE_TEXT_COLOR
        ret

DRAW_STATUS_POWER_STATION:
        mov     al,UNIT_GEN_A[si]
        mov     [HEXNUM],al
        mov     di,[numpos_stat6l]
        call    WRITE_DECNUM
        mov     si,TEXT_CONPANEL1
        mov     di,[textpos_stat5]
        call    WRITE_TEXT
        mov     si,TEXT_CONPANEL2
        mov     di,[textpos_stat6]
        call    WRITE_TEXT
        ret

DRAW_STATUS_BUILDER:
        mov     al,UNIT_GEN_C[si]
        cmp     al,0
        je      .L5
        push    ax
        mov     si,TEXT_CARRYING
        mov     di,[textpos_stat5]
        call    WRITE_TEXT
        mov     di,[tilepos_stat4]
        pop     ax
        call    plot_tile_in_gui
        .L5:
        ret

DRAW_STATUS_BROWSE:
        mov     di,[textpos_stat1]
        mov     si,TEXT_BROWSEMODE
        call    WRITE_TEXT
        mov     di,[textpos_stat5]
        call    WRITE_TILE_NAME
        mov     di,[tilepos_stat2r]
        mov     al,[SELECTED_TILE]
        call    plot_tile_in_gui
        ret

DRAW_COMMAND_WINDOW:
        call    CLEAR_COMMAND_WINDOW
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],0    ; is unit dead?
        jne     .B0
        ret
        .B0:
        cmp     byte UNIT_AI[si],0
        je      .L1
        cmp     byte UNIT_AI[si],38     ; recharging
        je      .L1
        cmp     byte UNIT_AI[si],23     ; sentry tank
        je      .B1
        mov     bl,UNIT_AI[si]
        mov     bh,0
        mov     di,bx
        cmp     byte CANABORT[di],1
        je      .B2
        cmp     bl,8                    ; smelter searching for minerals
        jne     .B3
        call    DRAW_COMMAND_SMELTER
        .B3:
        ret
        .B2:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_ABORT
        call    WRITE_TEXT
        ret
        .B1:
        call    DRAW_COMMAND_SENTRY_TANK
        ret
        .L1:
        mov     al,UNIT_TYPE[si]        ; What kind of unit is active?
        cmp     al,1                    ; builder
        jne     .L2
        call    DRAW_COMMAND_BUILDER
        ret
        .L2:
        cmp     al,2                    ; tank
        jne     .L3
        call    DRAW_COMMAND_TANK
        ret
        .L3:
        cmp     al,25                   ; factory
        jne     .L4
        call    DRAW_COMMAND_FACTORY
        ret
        .L4:
        cmp     al,21                   ; radar station
        jne     .L5
        call    DRAW_COMMAND_RADAR
        ret
        .L5:
        cmp     al,26                   ; missile silo
        jne     .L6
        call    DRAW_COMMAND_MISSILE_SILO
        ret
        .L6:
        cmp     al,3                    ; heavy tank
        jne     .L8
        call    DRAW_COMMAND_HEAVY_TANK
        ret
        .L8:
        cmp     al,4                    ; frigate
        jne     .L9
        call    DRAW_COMMAND_FRIGATE
        .L9:
        ret

DRAW_COMMAND_SMELTER:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_SMELTER3
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_SMELTER4
        call    WRITE_TEXT
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_SMELTER5
        call    WRITE_TEXT
        mov     di,[textpos_cmd4l]
        mov     si,TEXT_SMELTER6
        call    WRITE_TEXT
        ret

DRAW_COMMAND_MISSILE_SILO:
        cmp     byte UNIT_GEN_A[si],0
        jne     .L1
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_MISSILE1
        call    WRITE_TEXT
        jmp     .L2
        .L1:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_MISSILE2
        call    WRITE_TEXT
        .L2:
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_MISSILE3
        call    WRITE_TEXT
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_MISSILE4
        call    WRITE_TEXT
        mov     di,[textpos_cmd4l]
        mov     si,TEXT_MISSILE5
        call    WRITE_TEXT
        ret

DRAW_COMMAND_RADAR:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_RADAR001
        mov     ax,[font_bg_norm]
        mov     word [font_bg_color],ax
        call    WRITE_TEXT_COLOR
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_RADAR002
        call    WRITE_TEXT
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_RADAR003
        call    WRITE_TEXT
        mov     di,[textpos_cmd4l]
        mov     si,TEXT_RADAR004
        call    WRITE_TEXT
        mov     di,[textpos_cmd5l]
        mov     si,TEXT_RADAR005
        call    WRITE_TEXT
        ret

DRAW_COMMAND_FRIGATE:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_TANK001
        call    WRITE_TEXT
        ret

DRAW_COMMAND_TANK:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_TANK007
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_TANK008
        call    WRITE_TEXT
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_TANK009
        call    WRITE_TEXT
        mov     di,[textpos_cmd4l]
        mov     si,TEXT_TANK008
        call    WRITE_TEXT
        mov     di,[textpos_cmd5l]
        mov     si,TEXT_TANK002
        call    WRITE_TEXT
        mov     di,[textpos_cmd6l]
        mov     si,TEXT_TANK003
        call    WRITE_TEXT
        ret

DRAW_COMMAND_HEAVY_TANK:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_TANK001
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_TANK004
        call    WRITE_TEXT
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_TANK006
        call    WRITE_TEXT
        ret

DRAW_COMMAND_SENTRY_TANK:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_TANK005
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_TANK006
        call    WRITE_TEXT
        ret

DRAW_COMMAND_FACTORY:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0
        je      .L1
        ret
        .L1:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_FACTORY001
        call    WRITE_TEXT_COLOR
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_FACTORY002
        call    WRITE_TEXT
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_FACTORY003
        call    WRITE_TEXT
        mov     di,[textpos_cmd4l]
        mov     si,TEXT_FACTORY004
        call    WRITE_TEXT
        mov     al,[SELECTED_UNIT]
        mov     [UNIT_SCAN],al
        call    FIND_WATER_DELIVERY_LOCATION    ; success: zf=1
        ; can it build ships?
        jnz     .L2
        mov     si,TEXT_FACTORY005
        jmp     .L3
        .L2:
        mov     si,TEXT_FACTORY007
        .L3:
        mov     di,[textpos_cmd5l]
        call    WRITE_TEXT
        mov     di,[textpos_cmd6l]
        mov     si,TEXT_FACTORY006
        call    WRITE_TEXT
        ret

DRAW_COMMAND_BUILDER:
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER001
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER002
        call    WRITE_TEXT
        mov     di,[textpos_cmd4l]
        mov     si,TEXT_BUILDER027
        call    WRITE_TEXT
        mov     di,[textpos_cmd5l]
        mov     si,TEXT_BUILDER028
        call    WRITE_TEXT
        ; check if builder is carrying anything.
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_GEN_C[si]
        mov     [TEMP_A],al
        cmp     al,0
        jne     .L1
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_BUILDER003
        call    WRITE_TEXT
        ret
        .L1:
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_BUILDER004
        call    WRITE_TEXT
        ret

UPDATE_CLOCK:
        mov     ax,word [cs:GAME_CLOCK_TICKS]
        shl     ax,2                            ; multiply by 4
        add     ax,word [cs:GAME_CLOCK_TICKS]   ; add it again to mult by 5
        mov     bx,91
        div     bl
        cmp     al,[GAME_CLOCK_SECONDS]
        jne     .L5
        ret
        .L5:
        mov     byte [cs:GAME_CLOCK_SECONDS],al
        mov     al,byte [cs:GAME_CLOCK_HOURS]
        mov     [HEXNUM],al
        mov     di,[textpos_clock]              ; position of clock on screen
        mov     ax,[font_bg_frame]
        mov     word [font_bg_color],ax
        call    WRITE_DECNUM_2DIGIT
        mov     bl,":"
        call    PLOT_CHAR_COLOR
        mov     al,byte [cs:GAME_CLOCK_MINUTES]
        mov     [HEXNUM],al
        call    WRITE_DECNUM_2DIGIT
        mov     bl,":"
        call    PLOT_CHAR_COLOR
        mov     al,byte [cs:GAME_CLOCK_SECONDS]
        mov     [HEXNUM],al
        call    WRITE_DECNUM_2DIGIT
        ret

WRITE_NEW_MESSAGE:
        ; location and si must be defined with the memory location of the text,
        ; which should always be 14 characters long.
        mov     byte [INFO_TIMER1],50   ; reset info timer
        mov     byte [INFO_TIMER2],0    ; reset timer
        ; scroll up
        mov     di,[rect_msg]
        mov     cx,56
        mov     bx,17
        call    [scroll_up]
        ; write new text on bottom line
        mov     di,[textpos_msg6]       ; where to write bottom line of text.
        mov     byte [TEMP_X],0
        .L4:
        mov     bl,byte [si]
        cmp     bl,96
        jbe     .L5
        sub     bl,32
        .L5:
        push    si
        call    PLOT_CHAR
        pop     si
        inc     si
        inc     byte [TEMP_X]
        cmp     byte [TEMP_X],14
        jne     .L4
        ret

WRITE_TEXT:
        ; Before using this routine, di must be defined with the screen
        ; location and si must be defined with the memory location of the text.
        mov     cx,0ffffh
.L1:
        lodsb
        or      al,al
        loopnz  .L1
        not     cx
        sub     si,cx
        dec     cx
        jz      .L2
        tcall   [plot_string]           ; tail call
.L2:
        ret

WRITE_TEXT_COLOR:
        ; Same as other text routine, but with colored background.
        ; Before using this routine, di must be defined with the screen
        ; location and si must be defined with the memory location of the text.
        mov     cx,0ffffh
.L1:
        lodsb
        or      al,al
        loopnz  .L1
        not     cx
        sub     si,cx
        dec     cx
        jz      .L2
        tcall   [plot_string_color]     ; tail call
.L2:
        ret

WRITE_TILE_NAME:
        mov     al,[SELECTED_TILE]
        mov     ah,0
        mov     bl,12
        mul     bl
        mov     si,ax

        add     si,TILENAMES
        mov     cx,12
        tcall   [plot_string]           ; tail call

CLEAR_STATUS_WINDOW:
        mov     di,[rect_stat]
        mov     cx,50
        mov     bx,35
        tcall   [clear_rect]            ; tail call

CLEAR_COMMAND_WINDOW:
        mov     di,[rect_cmd]
        mov     cx,48
        mov     bx,35
        tcall   [clear_rect]            ; tail call

CLEAR_PLAYFIELD_WINDOW:
        mov     di,[rect_playfield]
        mov     cx,152
        mov     bx,144
        tcall   [clear_rect]            ; tail call

CLEAR_PLAYFIELD_WINDOW_WHITE:
        mov     di,[rect_playfield]
        mov     cx,152
        mov     bx,144
        tcall   [clear_rect_white]      ; tail call
