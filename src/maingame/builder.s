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

AI_BUILD_BRIDGE:
        mov     byte UNIT_TIMER[si],10
        cmp     byte UNIT_WORKING[si],0
        je      .L9
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12
        je      .L9
        call    BUILD_BRIDGE_COMWIN_CLEANUP
        ret
        .L9:
        ; first check GEN-A for direction, if it is zero
        ; then we need to find and set the direction.
        cmp     byte UNIT_GEN_A[si],0
        jne     .L10
        call    AI_BUILD_BRIDGE_FIND_DIRECTION
        cmp     byte UNIT_GEN_A[si],0
        jne     .L10
        mov     byte UNIT_AI[si],0              ; something went wrong or bridge is finished.
        call    BUILD_BRIDGE_COMWIN_CLEANUP
        ret
        .L10:
        ; If we've made it this far, then a direction is set
        cmp     byte UNIT_GEN_A[si],1           ; west
        jne     .L20
        call    BUILD_BRIDGE_WEST
        ret
        .L20:
        cmp     byte UNIT_GEN_A[si],2           ; north
        jne     .L30
        call    BUILD_BRIDGE_NORTH
        ret
        .L30:
        cmp     byte UNIT_GEN_A[si],3           ; east
        jne     .L40
        call    BUILD_BRIDGE_EAST
        ret
        .L40:
        cmp     byte UNIT_GEN_A[si],4           ; south
        jne     .L50
        call    BUILD_BRIDGE_SOUTH
        ret
        .L50:
        mov     byte UNIT_AI[si],0              ; something went wrong, abort.
        mov     byte UNIT_GEN_A[si],0           ; something went wrong, abort.
        ret

BUILD_BRIDGE_WEST:
        cmp     byte UNIT_WORKING[si],0
        jne     .L5
        mov     byte [TEMP_A],12                ; bridge piece
        call    CHECK_RESOURCES
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        cmp     byte [TEMP_A],0
        jne     .L1
        call    BUILD_ABORT                     ; insuffecient resources
        ret
        .L1:
        cmp     byte UNIT_LOCATION_X[si],0
        jne     .L2
        call    BUILD_ABORT                     ; hit edge of map.
        ret
        .L2:
        call    ERASE_UNIT_FROM_MAP
        dec     byte UNIT_LOCATION_X[si]
        mov     byte UNIT_TILE[si],50h          ; ensure left-facing builder tile
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        inc     byte UNIT_WORKING[si]
        ret
        .L5:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_GEN_A[si],0
        call    BUILD_BRIDGE_ADD_VERTICAL_PIECES
        call    BUILD_BRIDGE_COMWIN_CLEANUP
        ret

BUILD_BRIDGE_EAST:
        cmp     byte UNIT_WORKING[si],0
        jne     .L5
        mov     byte [TEMP_A],12                ; bridge piece
        call    CHECK_RESOURCES
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        cmp     byte [TEMP_A],0
        jne     .L1
        call    BUILD_ABORT                     ; insuffecient resources
        ret
        .L1:
        cmp     byte UNIT_LOCATION_X[si],255
        jne     .L2
        call    BUILD_ABORT                     ; hit edge of map.
        ret
        .L2:
        call    ERASE_UNIT_FROM_MAP
        inc     byte UNIT_LOCATION_X[si]
        mov     byte UNIT_TILE[si],51h          ; ensure right-facing builder tile
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        inc     byte UNIT_WORKING[si]
        ret
        .L5:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_GEN_A[si],0
        call    BUILD_BRIDGE_ADD_VERTICAL_PIECES
        call    BUILD_BRIDGE_COMWIN_CLEANUP
        ret

BUILD_BRIDGE_NORTH:
        cmp     byte UNIT_WORKING[si],0
        jne     .L5
        mov     byte [TEMP_A],12                ; bridge piece
        call    CHECK_RESOURCES
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        cmp     byte [TEMP_A],0
        jne     .L1
        call    BUILD_ABORT                     ; insuffecient resources
        ret
        .L1:
        cmp     byte UNIT_LOCATION_Y[si],0
        jne     .L2
        call    BUILD_ABORT                     ; hit edge of map.
        ret
        .L2:
        call    ERASE_UNIT_FROM_MAP
        dec     byte UNIT_LOCATION_Y[si]
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        inc     byte UNIT_WORKING[si]
        ret
        .L5:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_GEN_A[si],0
        call    BUILD_BRIDGE_ADD_HORIZONTAL_PIECES
        call    BUILD_BRIDGE_COMWIN_CLEANUP
        ret

BUILD_BRIDGE_SOUTH:
        cmp     byte UNIT_WORKING[si],0
        jne     .L5
        mov     byte [TEMP_A],12                ; bridge piece
        call    CHECK_RESOURCES
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        cmp     byte [TEMP_A],0
        jne     .L1
        call    BUILD_ABORT                     ; insuffecient resources
        ret
        .L1:
        cmp     byte UNIT_LOCATION_Y[si],127
        jne     .L2
        call    BUILD_ABORT                     ; hit edge of map.
        ret
        .L2:
        call    ERASE_UNIT_FROM_MAP
        inc     byte UNIT_LOCATION_Y[si]
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        inc     byte UNIT_WORKING[si]
        ret
        .L5:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_GEN_A[si],0
        call    BUILD_BRIDGE_ADD_HORIZONTAL_PIECES
        call    BUILD_BRIDGE_COMWIN_CLEANUP
        ret


BUILD_ABORT:
        mov     byte UNIT_AI[si],0              ; abort
        mov     byte UNIT_GEN_A[si],0           ; abort
        mov     byte UNIT_WORKING[si],0         ; abort
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        call    AI_MOVELEFT
        cmp     byte [MOVE_RESULT],1
        jne     .L1
        ret
        .L1:
        call    AI_MOVERIGHT
        cmp     byte [MOVE_RESULT],1
        jne     .L2
        ret
        .L2:
        call    AI_MOVEUP
        cmp     byte [MOVE_RESULT],1
        jne     .L3
        ret
        .L3:
        call    AI_MOVEDOWN
        ret


BUILD_BRIDGE_COMWIN_CLEANUP:
        mov     al,[SELECTED_UNIT]
        cmp     al,[UNIT_SCAN]
        jne     .L1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L1:
        ret

; description:
;       Let the builder build the bridge tile underneath it and up to
;       two pieces of bridge railing matching the bridge's horizontal direction.
BUILD_BRIDGE_ADD_HORIZONTAL_PIECES:
        mov     byte UNIT_TILE_UNDER[si],1bh    ; bridge center
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        test    di,0ffh
        jz      .skip_left
        dec     di
        mov     al,1eh                          ; left bridge piece
        call    place_tile_on_water
        inc     di
        .skip_left:
        inc     di
        test    di,0ffh
        jz      .skip_right
        mov     al,1fh                          ; right bridge piece
        call    place_tile_on_water
        .skip_right:
        call    CHECK_WINDOW_FOR_ACTION
        ret

; description:
;       Let the builder build the bridge tile underneath it and up to
;       two pieces of bridge railing matching the bridge's vertical direction.
BUILD_BRIDGE_ADD_VERTICAL_PIECES:
        mov     byte UNIT_TILE_UNDER[si],1bh    ; bridge center
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        test    di,7f00h
        jz      .skip_top
        sub     di,256
        mov     al,1ch                          ; top bridge piece
        call    place_tile_on_water
        add     di,256
        .skip_top:
        add     di,256
        test    di,7f00h
        jz      .skip_bottom
        mov     al,1dh                          ; bottom bridge piece
        call    place_tile_on_water
        .skip_bottom:
        call    CHECK_WINDOW_FOR_ACTION
        ret

; description:
;       Place the provided tile at the specified location, if the latter qualifies
;       as water for bridge building purposes.
; parameters:
;       al: the tile
;       di: destination on map
place_tile_on_water:
        push    ax
        call    TEST_FOR_WATER
        pop     ax
        jne     .end
        SET_MAP_BYTE    di,al
        .end:
        ret

; description:
;       Check the destination location for water and then set the direction based
;       on the builder's relative location, which should be exactly one tile away.
; parameters:
;       UNIT_DEST_X
;       UNIT_DEST_Y
;       UNIT_LOCATION_X
;       UNIT_LOCATION_Y
; returns:
;       UNIT_GEN_A
AI_BUILD_BRIDGE_FIND_DIRECTION:
        mov     al,UNIT_DEST_X[si]
        mov     ah,UNIT_DEST_Y[si]
        mov     di,ax
        cmp     al,UNIT_LOCATION_X[si]
        je      .vertical
        jb      .west
        .east:
        call    TEST_FOR_WATER
        jne     .end
        mov     byte UNIT_GEN_A[si],3           ; east
        inc     byte UNIT_DEST_X[si]            ; advance destination to next tile
        ret
        .west:
        call    TEST_FOR_WATER
        jne     .end
        mov     byte UNIT_GEN_A[si],1           ; west
        dec     byte UNIT_DEST_X[si]            ; advance destination to next tile
        ret
        .vertical:
        cmp     ah,UNIT_LOCATION_Y[si]
        je      .end
        jb      .north
        .south:
        call    TEST_FOR_WATER
        jne     .end
        mov     byte UNIT_GEN_A[si],4           ; south
        inc     byte UNIT_DEST_Y[si]            ; advance destination to next tile
        ret
        .north:
        call    TEST_FOR_WATER
        jne     .end
        mov     byte UNIT_GEN_A[si],2           ; north
        dec     byte UNIT_DEST_Y[si]            ; advance destination to next tile
        .end:
        ret

; description:
;       Check the provided location on the map for water.
; parameters:
;       di: map offset
; returns:
;       zf: 1 if water, otherwise 0
TEST_FOR_WATER:
        GET_MAP_BYTE    di
        cmp     al,18h                          ; shallow water
        je      .end
        cmp     al,19h                          ; water medium
        je      .end
        cmp     al,1ah                          ; water deep
        .end:
        ret

BUILDER_BUILD_BRIDGE:
        cmp     byte UNIT_GEN_C[si],0
        je      .L5
        mov     si,INFO_CANT_BLD3
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_BLD4
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        ret
        .L5:
        call    CLEAR_COMMAND_WINDOW
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER025
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER026
        call    WRITE_TEXT
        mov     al,18                           ; selects short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    START_BROWSE_MODE
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L6
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L6:
        call    BROWSE_GET_TILE
        ; find tile and see if is water
        mov     al,[SELECTED_TILE]
        cmp     al,18h                          ; water shallow
        je      .L10
        cmp     al,19h                          ; water medium
        je      .L10
        cmp     al,1ah                          ; water deep
        je      .L10
        mov     si,INFO_ONWATER1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_ONWATER2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L10:
        ; ok, can build a bridge there
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,[BROWSE_CURSOR_X]
        add     al,[MAP_OFFS_X]
        mov     UNIT_DEST_X[di],al
        mov     al,[BROWSE_CURSOR_Y]
        add     al,[MAP_OFFS_Y]
        mov     UNIT_DEST_Y[di],al
        ; Builder needs to drive to tile first
        mov     byte UNIT_AI[di],13             ; traveller type 2
        mov     byte UNIT_ALTMOVE_X[di],0
        mov     byte UNIT_ALTMOVE_Y[di],0
        mov     byte UNIT_GEN_A[di],26          ; change to build bridge when arrive
        mov     byte UNIT_TIMER[di],1
        mov     al,14                           ; construction set sound
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

AI_BUILD_WALL:
        ; first check for resources
        cmp     byte UNIT_WORKING[si],0
        jne     .L1
        mov     byte [TEMP_A],11                ; brick wall
        call    CHECK_RESOURCES
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        cmp     byte [TEMP_A],0
        jne     .L1
        call    BUILD_ABORT
        ret
        .L1:
        ; build wall
        mov     byte UNIT_TIMER[si],3
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12
        je      .L5
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L4
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L4:
        ret
        .L5:
        ; finished progress, now build it.
        mov     byte UNIT_TILE_UNDER[si],06fh   ; wall tile
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_AI[si],0
        mov     al,[SELECTED_UNIT]
        cmp     al,[UNIT_SCAN]
        jne     .L10
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L10:
        call    AI_MOVELEFT
        cmp     byte [MOVE_RESULT],1
        jne     .L11
        ret
        .L11:
        call    AI_MOVERIGHT
        cmp     byte [MOVE_RESULT],1
        jne     .L12
        ret
        .L12:
        call    AI_MOVEUP
        cmp     byte [MOVE_RESULT],1
        jne     .L13
        ret
        .L13:
        call    AI_MOVEDOWN
        cmp     byte [MOVE_RESULT],1
        jne     .L14
        ret
        .L14:
        mov     si,INFO_BLOCKED3
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BLOCKED2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        ret

BUILDER_BUILD_WALL:
        cmp     byte UNIT_GEN_C[si],0
        je      .L5
        mov     si,INFO_CANT_BLD3
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_BLD4
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        ret
        .L5:
        call    CLEAR_COMMAND_WINDOW
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER025
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER026
        call    WRITE_TEXT
        mov     al,18                           ; selects short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    START_BROWSE_MODE
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L3
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L3:
        call    BROWSE_GET_TILE
        ; find tile and see if it can be moved
        mov     al,[SELECTED_TILE]
        mov     ah,0
        mov     si,ax
        mov     al,TILEATTRIB[si]
        and     al,00000010b                    ;
        cmp     al,00000010b                    ; Can it be BUILT ON?
        je      .L6
        mov     si,INFO_CANT_BLD1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_BLD2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L6:
        ; ok, can build a wall there
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,[BROWSE_CURSOR_X]
        add     al,[MAP_OFFS_X]
        mov     UNIT_DEST_X[di],al
        mov     al,[BROWSE_CURSOR_Y]
        add     al,[MAP_OFFS_Y]
        mov     UNIT_DEST_Y[di],al
        ; Builder needs to drive to tile first
        mov     byte UNIT_AI[di],5              ; traveller type 1
        mov     byte UNIT_ALTMOVE_X[si],0
        mov     byte UNIT_ALTMOVE_Y[si],0
        mov     byte UNIT_GEN_A[di],25          ; change to build wall when arrive
        mov     byte UNIT_TIMER[di],1
        mov     al,14                           ; construction set sound
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILDER_BULLDOZE:
        cmp     byte UNIT_GEN_C[si],0
        je      .L0
        mov     si,INFO_CANT_BLD3
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_BLD4
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        ret
        .L0:
        call    CLEAR_COMMAND_WINDOW
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER025
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER026
        call    WRITE_TEXT
        mov     al,18                           ; selects short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    START_BROWSE_MODE
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L1:
        call    BROWSE_GET_TILE
        ; find tile and see if it can be moved
        mov     al,[SELECTED_TILE]
        mov     ah,0
        mov     si,ax
        mov     al,TILEATTRIB[si]
        and     al,00010000b                    ;
        cmp     al,00010000b                    ; Can it be BULLDOZED?
        je      .L5
        mov     si,INFO_BULLDOZE1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BULLDOZE2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L5:
        ; ok, tile can be bulldozed
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,[BROWSE_CURSOR_X]
        add     al,[MAP_OFFS_X]
        mov     UNIT_DEST_X[di],al
        mov     al,[BROWSE_CURSOR_Y]
        add     al,[MAP_OFFS_Y]
        mov     UNIT_DEST_Y[di],al
        ; Builder needs to drive to tile first
        mov     byte UNIT_AI[di],13             ; traveller type 2
        mov     byte UNIT_ALTMOVE_X[si],0
        mov     byte UNIT_ALTMOVE_Y[si],0
        mov     byte UNIT_GEN_A[di],17          ; change to pick up when done
        mov     byte UNIT_TIMER[di],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILDER_BUILD_STRUCTURE:
        ; Check of builder is carrying anything first.
        cmp     byte UNIT_GEN_C[si],0
        je      .L0
        mov     si,INFO_CANT_BLD3
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_BLD4
        call    WRITE_NEW_MESSAGE
        mov     al,00                   ; error beep
        mov     ah,150                  ; priority
        call    m_playSFX               ; play sound effect
        ret
        .L0:
        mov     al,18                   ; selects short beep
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        mov     byte [cs:TEMP_TOGGLE],0
        BBS01:
        cmp     byte [cs:TEMP_TOGGLE],0
        jne     BBS03
        mov     byte [cs:TEMP_TOGGLE],1
        call    CLEAR_COMMAND_WINDOW
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER010
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER011
        call    WRITE_TEXT
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_BUILDER012
        call    WRITE_TEXT
        mov     di,[textpos_cmd4l]
        mov     si,TEXT_BUILDER013
        call    WRITE_TEXT
        mov     di,[textpos_cmd5l]
        mov     si,TEXT_BUILDER014
        call    WRITE_TEXT
        mov     di,[textpos_cmd6l]
        mov     si,TEXT_BUILDER015
        mov     ax,[font_bg_alt_bright]
        mov     word [font_bg_color],ax
        call    WRITE_TEXT_COLOR
        jmp     BBS05
        BBS03:
        mov     byte [cs:TEMP_TOGGLE],0
        call    CLEAR_COMMAND_WINDOW
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER016
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER017
        call    WRITE_TEXT
        mov     di,[textpos_cmd3l]
        mov     si,TEXT_BUILDER018
        call    WRITE_TEXT
        mov     di,[textpos_cmd4l]
        mov     si,TEXT_BUILDER019
        call    WRITE_TEXT
        mov     di,[textpos_cmd5l]
        mov     si,TEXT_BUILDER020
        call    WRITE_TEXT
        mov     di,[textpos_cmd6l]
        mov     si,TEXT_BUILDER015
        mov     ax,[font_bg_alt_bright]
        mov     word [font_bg_color],ax
        call    WRITE_TEXT_COLOR
        BBS05:
        cmp     byte[cs:BG_TIMER_MAIN],1
        jne     .L6
        call    BACKGROUND_ROUTINE
        call    BM_CHECK_REDRAWS
        ; doublecheck builder hasn't been destroyed.
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],0
        jne     .L6
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L6:
        mov     ah,1
        int     16h                     ; getkey buffer
        jz      BBS05
        xor     ah,ah                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     al,0dh                  ; enter key
        jne     .L10
        jmp     BBS01
        .L10:
        cmp     ah,1                    ; escape key
        jne     .L11
        call    DRAW_COMMAND_WINDOW
        ret
        .L11:
        cmp     al,68h                  ; h-key
        jne     .L12
        call    BUILD_HEADQUARTERS
        ret
        .L12:
        cmp     al,70h                  ; p-key
        jne     .L13
        call    BUILD_POWER_STATION
        ret
        .L13:
        cmp     al,73h                  ; s-key
        jne     .L14
        call    BUILD_SOLAR_PANEL
        ret
        .L14:
        cmp     al,67h                  ; g-key
        jne     .L15
        call    BUILD_GAS_REFINERY
        ret
        .L15:
        cmp     al,72h                  ; r-key
        jne     .L16
        call    BUILD_RADAR_STATION
        ret
        .L16:
        cmp     al,66h                  ; f-key
        jne     .L17
        call    BUILD_FACTORY
        ret
        .L17:
        cmp     al,6dh                  ; m-key
        jne     .L18
        call    BUILD_MISSILE_SILO
        ret
        .L18:
        cmp     al,65h                  ; e-key
        jne     .L19
        call    BUILD_SMELTER
        ret
        .L19:
        jmp     BBS05
        TEMP_TOGGLE db 0                ; toggle bit

; The following is a simplified version of the re-draw check which is used
; for when the build-menu is being displayed.  Thus, it will not redraw
; the command window

BM_CHECK_REDRAWS:
        cmp     byte [REDRAW_SCREEN_REQ],1
        jne     .L4
        call    DRAW_ENTIRE_SCREEN
        call    DRAW_FLYING_OBJECTS
        mov     byte [REDRAW_SCREEN_REQ],0
        .L4:
        cmp     byte [REDRAW_COORDS_REQ],1
        jne     .L5
        call    WRITE_COORDINATES
        mov     byte [REDRAW_COORDS_REQ],0
        .L5:
        cmp     byte [REDRAW_STATUS_REQ],1
        jne     .L7
        call    DRAW_STATUS_WINDOW
        mov     byte [REDRAW_STATUS_REQ],0
        .L7:
        ret

BUILD_BUILDING_START:
        mov     al,18                           ; selects short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    CLEAR_COMMAND_WINDOW
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER025
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER026
        call    WRITE_TEXT
        mov     byte [BIG_CURSOR_MODE],1
        call    START_BROWSE_MODE
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L0
        ret
        .L0:
        mov     byte [BIG_CURSOR_MODE],0
        call    CLEAR_COMMAND_WINDOW
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        mov     UNIT_DEST_X[si],al
        mov     al,[MAP_OFFS_Y]
        add     al,[BROWSE_CURSOR_Y]
        mov     UNIT_DEST_Y[si],al
        mov     byte UNIT_AI[si],5              ; traveller type 1
        mov     byte UNIT_ALTMOVE_X[si],0
        mov     byte UNIT_ALTMOVE_Y[si],0
        mov     byte UNIT_GEN_A[si],14          ; change to construction ai when done travelling
        mov     al,14                           ; construction set sound
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound
        ret

; The Following routine checks the 4-tiles where the building should go
; to make sure they are all considered "build" enabled.

CHECK_BUILD_LOCATION:
        ; make sure building isn't at edge of map
        call    ERASE_UNIT_FROM_MAP
        mov     al,[MAP_OFFS_Y]
        add     al,[BROWSE_CURSOR_Y]
        cmp     al,0                    ; check for top edge
        jne     .L1
        jmp     CANTBUILD
        .L1:
        cmp     al,125                  ; check for bottom edge
        jbe     .L2
        jmp     CANTBUILD
        .L2:
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        cmp     al,0                    ; check for left edge
        jne     .L3
        jmp     CANTBUILD
        .L3:
        cmp     al,253                  ; check for right edge
        jbe     .L5
        jmp     CANTBUILD
        .L5:
        ; now check the tiles to make sure it is acceptable landscape
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        mov     ah,[MAP_OFFS_Y]
        add     ah,[BROWSE_CURSOR_Y]
        mov     di,ax
        GET_MAP_BYTE    di              ; first tile
        mov     ah,0
        mov     di,ax
        mov     cl,TILEATTRIB[di]
        and     cl,2                    ; build attribute
        cmp     cl,2                    ; can you build there?
        je      .L2a
        jmp     CANTBUILD
        .L2a:
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        mov     ah,[MAP_OFFS_Y]
        add     ah,[BROWSE_CURSOR_Y]
        mov     di,ax
        inc     di
        GET_MAP_BYTE    di              ; second tile
        dec     di
        mov     ah,0
        mov     di,ax
        mov     cl,TILEATTRIB[di]
        and     cl,2                    ; build attribute
        cmp     cl,2                    ; can you build there?
        je      .L3a
        jmp     CANTBUILD
        .L3a:
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        mov     ah,[MAP_OFFS_Y]
        add     ah,[BROWSE_CURSOR_Y]
        mov     di,ax
        add     di,256
        GET_MAP_BYTE    di              ; third tile
        sub     di,256
        mov     ah,0
        mov     di,ax
        mov     cl,TILEATTRIB[di]
        and     cl,2                    ; build attribute
        cmp     cl,2                    ; can you build there?
        je      .L4
        jmp     CANTBUILD
        .L4:
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        mov     ah,[MAP_OFFS_Y]
        add     ah,[BROWSE_CURSOR_Y]
        mov     di,ax
        add     di,257
        GET_MAP_BYTE    di              ; fourth tile
        sub     di,257
        mov     ah,0
        mov     di,ax
        mov     cl,TILEATTRIB[di]
        and     cl,2                    ; build attribute
        cmp     cl,2                    ; can you build there?
        je      .L5a
        jmp     CANTBUILD
        .L5a:
        mov     byte [TEMP_A],1         ; can build!
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        call    PLOT_UNIT_ON_MAP
        ret
        CANTBUILD:
        mov     si,INFO_CANT_BLD1       ; message "CAN'T BUILD THERE"
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_BLD2
        call    WRITE_NEW_MESSAGE
        mov     al,00                   ; error beep
        mov     ah,150                  ; priority
        call    m_playSFX               ; play sound effect
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte [TEMP_A],0         ; can't build
        call    PLOT_UNIT_ON_MAP
        ret


BUILD_FAIL:
        mov     byte [BIG_CURSOR_MODE],0
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_AI[si],0              ; cancel ai
        mov     byte UNIT_GEN_B[si],0           ; building type 0 (headquarters)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILD_HEADQUARTERS:
        call    BUILD_BUILDING_START
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        jmp     BUILD_FAIL
        .L1:
        call    CHECK_BUILD_LOCATION
        cmp     byte [TEMP_A],1
        je      .L2
        jmp     BUILD_FAIL
        .L2:
        mov     byte UNIT_GEN_B[si],0           ; building type 0 (headquarters)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILD_POWER_STATION:
        call    BUILD_BUILDING_START
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        jmp     BUILD_FAIL
        .L1:
        call    CHECK_BUILD_LOCATION
        cmp     byte [TEMP_A],1
        je      .L2
        jmp     BUILD_FAIL
        .L2:
        mov     byte UNIT_GEN_B[si],1           ; building type 1 (power station)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILD_SOLAR_PANEL:
        call    BUILD_BUILDING_START
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        jmp     BUILD_FAIL
        .L1:
        call    CHECK_BUILD_LOCATION
        cmp     byte [TEMP_A],1
        je      .L2
        jmp     BUILD_FAIL
        .L2:
        mov     byte UNIT_GEN_B[si],2           ; building type 2 (solar panel)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILD_GAS_REFINERY:
        call    BUILD_BUILDING_START
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L0
        mov     byte [BIG_CURSOR_MODE],0
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L0:
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        mov     ah,[MAP_OFFS_Y]
        add     ah,[BROWSE_CURSOR_Y]
        mov     di,ax
        GET_MAP_BYTE    di
        cmp     al,024h                         ; top-left of gas vent
        je      .L1
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],0
        mov     byte UNIT_GEN_C[si],0
        mov     byte UNIT_AI[si],0
        mov     si,INFO_BUILDGAS1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BUILDGAS2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret
        .L1:
        mov     byte UNIT_GEN_B[si],3           ; building type 3 (gas refinery)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILD_RADAR_STATION:
        call    BUILD_BUILDING_START
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        jmp     BUILD_FAIL
        .L1:
        call    CHECK_BUILD_LOCATION
        cmp     byte [TEMP_A],1
        je      .L2
        jmp     BUILD_FAIL
        .L2:
        mov     byte UNIT_GEN_B[si],4           ; building type 4 (radar station)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILD_FACTORY:
        call    BUILD_BUILDING_START
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        jmp     BUILD_FAIL
        .L1:
        call    CHECK_BUILD_LOCATION
        cmp     byte [TEMP_A],1
        je      .L2
        jmp     BUILD_FAIL
        .L2:
        mov     byte UNIT_GEN_B[si],5           ; building type 5 (factory)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILD_MISSILE_SILO:
        call    BUILD_BUILDING_START
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        jmp     BUILD_FAIL
        .L1:
        call    CHECK_BUILD_LOCATION
        cmp     byte [TEMP_A],1
        je      .L2
        jmp     BUILD_FAIL
        .L2:
        mov     byte UNIT_GEN_B[si],6           ; building type 6 (missile silo)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILD_SMELTER:
        call    BUILD_BUILDING_START
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        jmp     BUILD_FAIL
        .L1:
        call    CHECK_BUILD_LOCATION
        cmp     byte [TEMP_A],1
        je      .L2
        jmp     BUILD_FAIL
        .L2:
        mov     byte UNIT_GEN_B[si],7           ; building type 7 (smelter)
        mov     byte UNIT_GEN_C[si],0           ; construction counter zero
        mov     byte UNIT_TIMER[si],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILDER_DROP_OFF_ITEM:
        ; check if carrying something
        mov     al,UNIT_GEN_C[si]
        cmp     al,0
        jne     .L5
        ret
        .L5:
        mov     al,18                           ; selects short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    CLEAR_COMMAND_WINDOW
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER007
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER006
        call    WRITE_TEXT
        call    START_BROWSE_MODE
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L1:
        call    BROWSE_GET_TILE
        ; find out if tile can be built on
        mov     al,[SELECTED_TILE]
        mov     ah,0
        mov     si,ax
        mov     al,TILEATTRIB[si]
        and     al,00000010b                    ; move attribute bit
        cmp     al,00000010b                    ; Can it be BUILT ON?
        je      .L10
        mov     si,INFO_CANT_DROP1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_DROP2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L10:
        ; is the tile next to the builder?
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,[BROWSE_CURSOR_X]
        add     al,[MAP_OFFS_X]
        mov     UNIT_DEST_X[di],al
        mov     al,[BROWSE_CURSOR_Y]
        add     al,[MAP_OFFS_Y]
        mov     UNIT_DEST_Y[di],al
        mov     bl,[SELECTED_UNIT]
        mov     [UNIT_SCAN],bl
        call    CHECK_DISTANCE_TO_DESTINATION
        cmp     byte [TEMP_X],1
        jbe     .L11
        jmp     .L20
        .L11:
        cmp     byte [TEMP_Y],1
        jbe     .L12
        jmp     .L20
        .L12:
        ; place the object on the map
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     bl,UNIT_GEN_C[si]
        mov     byte UNIT_GEN_C[si],0
        mov     al,[BROWSE_CURSOR_X]
        add     al,[MAP_OFFS_X]
        mov     ah,[BROWSE_CURSOR_Y]
        add     ah,[MAP_OFFS_Y]
        mov     di,ax
        SET_MAP_BYTE    di,bl
        call    DRAW_ENTIRE_SCREEN
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L20:
        ; Builder needs to drive to unit first
        mov     byte UNIT_AI[di],13             ; traveller type 2
        mov     byte UNIT_ALTMOVE_X[si],0
        mov     byte UNIT_ALTMOVE_Y[si],0
        mov     byte UNIT_GEN_A[di],16          ; change to drop off when done
        mov     byte UNIT_TIMER[di],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

BUILDER_PICK_UP_ITEM:
        ; check if already carrying somethig
        mov     al,UNIT_GEN_C[si]
        cmp     al,0
        je      .L5
        mov     si,INFO_CANT_BLD3
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_BLD4
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        ret
        .L5:
        mov     al,18                           ; selects short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    CLEAR_COMMAND_WINDOW
        mov     di,[textpos_cmd1l]
        mov     si,TEXT_BUILDER005
        call    WRITE_TEXT
        mov     di,[textpos_cmd2l]
        mov     si,TEXT_BUILDER006
        call    WRITE_TEXT
        call    START_BROWSE_MODE
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L1
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L1:
        call    BROWSE_GET_TILE
        ; find tile and see if it can be moved
        mov     al,[SELECTED_TILE]
        cmp     al,2                            ; we want to be able to move the plant, as well
        je      .L10
        mov     ah,0
        mov     si,ax
        mov     al,TILEATTRIB[si]
        and     al,00000100b                    ; move attribute bit
        cmp     al,00000100b                    ; Can it be moved?
        je      .L10
        mov     si,INFO_CANT_MOVE1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_MOVE2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret
        .L10:
        ; ok, tile can be moved.
        ; is the tile next to the builder?
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,[BROWSE_CURSOR_X]
        add     al,[MAP_OFFS_X]
        mov     UNIT_DEST_X[di],al
        mov     al,[BROWSE_CURSOR_Y]
        add     al,[MAP_OFFS_Y]
        mov     UNIT_DEST_Y[di],al
        mov     bl,[SELECTED_UNIT]
        mov     [UNIT_SCAN],bl
        call    CHECK_DISTANCE_TO_DESTINATION
        cmp     byte [TEMP_X],1
        jbe     .L11
        jmp     .L20
        .L11:
        cmp     byte [TEMP_Y],1
        jbe     .L12
        jmp     .L20
        .L12:
        ; object is next to unit, so pick it up now.
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,[SELECTED_TILE]
        mov     UNIT_GEN_C[di],al
        ; now replace that with dirt on the map
        mov     al,[BROWSE_CURSOR_X]
        add     al,[MAP_OFFS_X]
        mov     ah,[BROWSE_CURSOR_Y]
        add     ah,[MAP_OFFS_Y]
        mov     di,ax
        GET_SET_MAP_BYTE        di,22h  ; dirt
        cmp     al,2                    ; special case for plant
        jne     .not_a_plant
        SET_MAP_BYTE    di,0
        .not_a_plant:
        call    DRAW_ENTIRE_SCREEN
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret
        .L20:
        ; Builder needs to drive to unit first
        mov     byte UNIT_AI[di],13             ; traveller type 2
        mov     byte UNIT_ALTMOVE_X[si],0
        mov     byte UNIT_ALTMOVE_Y[si],0
        mov     byte UNIT_GEN_A[di],15          ; change to pick up when done
        mov     byte UNIT_TIMER[di],1
        call    DRAW_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        ret

; The following routine actually handles the background part of the
; building construction AI.

AI_CONSTRUCTION:
        call    SET_BUILD_ITEMS_FLAGS_CLEAR
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_GEN_B[si]               ; get construction type
        mov     ah,0
        mov     di,ax
        mov     al,BDATA_SPEED[di]              ; get speed for that construction
        mov     UNIT_TIMER[si],al               ; set timer
        mov     al,UNIT_GEN_C[si]               ; find which stage of construction we're at.
        cmp     al,0
        jne     .L1
        ; check for resources first
        mov     al,UNIT_GEN_B[si]               ; get construction type
        mov     [TEMP_A],al
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        jne     .L0
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        call    BUILD_ABORT
        call    SET_BUILD_ITEMS_FLAGS_NORMAL
        ret
        .L0:
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        mov     bl,UNIT_TILE_UNDER[si]
        mov     bh,0
        mov     di,bx
        mov     al,TILEATTRIB[di]
        and     al,00010000b                    ; bulldoze attribute
        cmp     al,00010000b                    ; bulldoze attribute
        je      .B1
        jmp     CONSTBLOCKED
        .B1:
        mov     byte UNIT_TILE_UNDER[si],022h   ; dirt
        call    AI_MOVERIGHT
        mov     byte UNIT_WORKING[si],1
        jmp     AICONST_STEP2
        .L1:
        cmp     al,1
        jne     .L2
        mov     bl,UNIT_TILE_UNDER[si]
        mov     bh,0
        mov     di,bx
        mov     al,TILEATTRIB[di]
        and     al,00010000b                    ; bulldoze attribute
        cmp     al,00010000b                    ; bulldoze attribute
        je      .B2
        jmp     CONSTBLOCKED
        .B2:
        mov     byte UNIT_TILE_UNDER[si],022h   ; dirt
        call    AI_MOVEDOWN
        jmp     AICONST_STEP2
        .L2:
        cmp     al,2
        jne     .L3
        mov     bl,UNIT_TILE_UNDER[si]
        mov     bh,0
        mov     di,bx
        mov     al,TILEATTRIB[di]
        and     al,00010000b                    ; bulldoze attribute
        cmp     al,00010000b                    ; bulldoze attribute
        je      .B3
        jmp     CONSTBLOCKED
        .B3:
        mov     byte UNIT_TILE_UNDER[si],022h   ; dirt
        mov     byte UNIT_WORKING[si],2
        call    AI_MOVELEFT
        jmp     AICONST_STEP2
        .L3:
        cmp     al,3
        jne     .L4
        mov     bl,UNIT_TILE_UNDER[si]
        mov     bh,0
        mov     di,bx
        mov     al,TILEATTRIB[di]
        and     al,00010000b                    ; bulldoze attribute
        cmp     al,00010000b                    ; bulldoze attribute
        je      .B4
        jmp     CONSTBLOCKED
        .B4:
        mov     byte UNIT_TILE_UNDER[si],022h   ; dirt
        call    AI_MOVEUP
        jmp     AICONST_STEP2
        .L4:
        cmp     al,4
        jne     .L5
        mov     byte UNIT_TILE_UNDER[si],06eh   ; concrete
        mov     byte UNIT_WORKING[si],3
        call    AI_MOVERIGHT
        jmp     AICONST_STEP2
        .L5:
        cmp     al,5
        jne     .L6
        mov     byte UNIT_TILE_UNDER[si],06eh   ; concrete
        call    AI_MOVEDOWN
        jmp     AICONST_STEP2
        .L6:
        cmp     al,6
        jne     .L7
        mov     byte UNIT_TILE_UNDER[si],06eh   ; concrete
        mov     byte UNIT_WORKING[si],4
        call    AI_MOVELEFT
        jmp     AICONST_STEP2
        .L7:
        cmp     al,7
        jne     .L8
        mov     byte UNIT_TILE_UNDER[si],06eh   ; concrete
        call    AI_MOVEUP
        jmp     AICONST_STEP2
        .L8:
        cmp     al,8
        jne     .L9
        mov     byte UNIT_TILE_UNDER[si],088h   ; construction zone
        mov     byte UNIT_WORKING[si],5
        call    AI_MOVERIGHT
        jmp     AICONST_STEP2
        .L9:
        cmp     al,9
        jne     .L10
        mov     byte UNIT_TILE_UNDER[si],089h   ; construction zone
        call    AI_MOVEDOWN
        jmp     AICONST_STEP2
        .L10:
        cmp     al,10
        jne     .L11
        mov     byte UNIT_TILE_UNDER[si],090h   ; construction zone
        mov     byte UNIT_WORKING[si],6
        call    AI_MOVELEFT
        jmp     AICONST_STEP2
        .L11:
        cmp     al,11
        jne     .L12
        mov     byte UNIT_TILE_UNDER[si],091h   ; construction zone
        call    AI_MOVEUP
        jmp     AICONST_STEP2
        .L12:
        cmp     al,12
        jne     .L13
        mov     byte UNIT_WORKING[si],7
        call    AI_MOVERIGHT
        call    AI_MOVEDOWN
        jmp     AICONST_STEP2
        .L13:
        cmp     al,13
        jne     .L14
        call    AI_MOVELEFT
        jmp     AICONST_STEP2
        .L14:
        cmp     al,14
        jne     .L15
        mov     byte UNIT_WORKING[si],8
        call    AI_MOVERIGHT
        call    AI_MOVEUP
        jmp     AICONST_STEP2
        .L15:
        cmp     al,15
        jne     .L16
        call    AI_MOVELEFT
        jmp     AICONST_STEP2
        .L16:
        cmp     al,16
        jne     .L17
        mov     byte UNIT_WORKING[si],9
        mov     al,UNIT_GEN_B[si]
        mov     ah,0
        mov     di,ax
        mov     al,BDATA_TILE_TL[di]
        mov     UNIT_TILE_UNDER[si],al          ; building top-left
        call    AI_MOVERIGHT
        jmp     AICONST_STEP2
        .L17:
        cmp     al,17
        jne     .L18
        mov     al,UNIT_GEN_B[si]
        mov     ah,0
        mov     di,ax
        mov     al,BDATA_TILE_TL[di]
        inc     al
        mov     UNIT_TILE_UNDER[si],al          ; building top-right
        call    AI_MOVEDOWN
        jmp     AICONST_STEP2
        .L18:
        cmp     al,18
        jne     .L19
        mov     al,UNIT_GEN_B[si]
        mov     byte UNIT_WORKING[si],10
        mov     ah,0
        mov     di,ax
        mov     al,BDATA_TILE_TL[di]
        add     al,9
        mov     UNIT_TILE_UNDER[si],al          ; building bottom-right
        call    AI_MOVELEFT
        jmp     AICONST_STEP2
        .L19:
        cmp     al,19
        jne     .L20
        mov     al,UNIT_GEN_B[si]
        mov     ah,0
        mov     di,ax
        mov     al,BDATA_TILE_TL[di]
        add     al,8
        mov     UNIT_TILE_UNDER[si],al          ; building bottom-left
        jmp     AICONST_STEP2B
        .L20:
        ; create new building officially
        cmp     al,20
        je      .B20
        jmp     .L21
        .B20:
        mov     byte UNIT_WORKING[si],11
        call    REQUEST_NEW_BUILDING_NUMBER
        cmp     byte [TEMP_A],1                 ; did we get a new number?
        je      .L20a
        jmp     CONSTEND
        .L20a:
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax                           ; get builder unit#
        mov     al,UNIT_LOCATION_X[si]          ; copy coordinates to new building
        mov     UNIT_LOCATION_X[di],al
        mov     al,UNIT_LOCATION_Y[si]
        dec     al
        mov     UNIT_LOCATION_Y[di],al
        mov     al,UNIT_GEN_B[si]
        mov     ah,0
        mov     si,ax                           ; get building type number
        mov     al,BDATA_TYPE[si]
        mov     UNIT_TYPE[di],al                ; set unit type for new building
        mov     al,BDATA_AI[si]
        mov     UNIT_AI[di],al                  ; set ai type for new building
        mov     al,BDATA_HEALTH[si]
        mov     UNIT_HEALTH[di],al              ; set health for new building
        mov     al,BDATA_TILE_TL[si]
        mov     UNIT_TILE[di],al                ; set tile for new building
        mov     al,BDATA_TILE_TL[si]
        mov     UNIT_TILE[di],al                ; set tile for new building
        mov     byte UNIT_TIMER[di],10          ; set timer for new unit
        mov     byte UNIT_GEN_A[di],0           ; clear general variables
        mov     byte UNIT_GEN_B[di],0           ; clear general variables
        mov     byte UNIT_GEN_C[di],0           ; clear general variables
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax                           ; get builder unit#
        jmp     AICONST_STEP2B
        .L21:
        ; exit from construction site
        cmp     al,21
        jne     CONSTEND
        call    AI_MOVELEFT
        cmp     byte [MOVE_RESULT],1
        je      AICONST_STEP2
        call    AI_MOVEDOWN
        cmp     byte [MOVE_RESULT],1
        je      AICONST_STEP2
        inc     byte UNIT_GEN_C[si]
        call    SET_BUILD_ITEMS_FLAGS_NORMAL
        mov     si,INFO_BLOCKED3
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BLOCKED2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     CONSTEND
        AICONST_STEP2:
        cmp     byte [MOVE_RESULT],1
        jne     CONSTBLOCKED
        AICONST_STEP2B:
        inc     byte UNIT_GEN_C[si]
        call    SET_BUILD_ITEMS_FLAGS_NORMAL
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L23
        mov     byte [REDRAW_STATUS_REQ],1
        .L23:
        ret

        CONSTBLOCKED:
        mov     si,INFO_CANT_BLD1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_CANT_BLD2
        call    WRITE_NEW_MESSAGE
        mov     al,00                           ; error beep
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect

        CONSTEND:
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_AI[si],0
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],0
        mov     byte UNIT_GEN_C[si],0
        mov     byte UNIT_WORKING[si],0
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L2
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        .L2:
        call    SET_BUILD_ITEMS_FLAGS_NORMAL
        ret


; The following routines change the "can drive on it flag"
; and the "can bulldoze flag" for
; certain items that the builder needs to be able to drive on
; temporarily, such as construction materials and gas vents,
; then changes them back.

SET_BUILD_ITEMS_FLAGS_CLEAR:
        mov     si,0
        .L1:
        mov     ah,0
        mov     al,BDATA_TILES[si]
        mov     di,ax
        mov     bl,TILEATTRIB[di]
        or      bl,00010001b
        mov     TILEATTRIB[di],bl
        inc     si
        cmp     si,8
        jne     .L1
        ret

SET_BUILD_ITEMS_FLAGS_NORMAL:
        mov     si,0
        .L1:
        mov     ah,0
        mov     al,BDATA_TILES[si]
        mov     di,ax
        mov     bl,TILEATTRIB[di]
        and     bl,238
        mov     TILEATTRIB[di],bl
        inc     si
        cmp     si,8
        jne     .L1
        ret
BDATA_TILES     db 088h,089h,090h,091h,024h,025h,02ch,02dh


; The following table contains information on how to construct
; nine different buildings, which are:
; ---------------
; 00-Headquarters
; 01-Power station
; 02-solar panel
; 03-gas refinery
; 04-radar Station
; 05-factory
; 06-missile silo
; 07-smelter

BDATA_TYPE      db 20,22,23,24,21,25,26,27
BDATA_AI        db 4,1,2,10,0,0,0,8
BDATA_HEALTH    db 200,150,75,125,100,175,220,145
BDATA_TILE_TL   db 124,120,122,126,108,104,138,106
BDATA_SPEED     db 10,10,6,7,10,15,15,8

; 02h - dirt
; 06eh - concrete
; 088h - under constr
; 07ch - headquarters
