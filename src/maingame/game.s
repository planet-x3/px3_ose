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

; block 1
; The following database stores which tile to display for various directions
; of each unit type.
DIR_TILE_UP     db 0,000,000,8Eh,5fh,0,0,0, 0,0,5bh
DIR_TILE_DOWN   db 0,000,000,8Fh,61h,0,0,0, 0,0,5dh
DIR_TILE_LEFT   db 0,50h,58h,8Ch,5eh,0a8h,0aah,0adh, 52h,54h,5ah
DIR_TILE_RIGHT  db 0,51h,59h,8Dh,60h,0a9h,0abh,0aeh, 53h,55h,5ch
UNIT_FLY        db 0,0,0,0,0,0,0,0, 0,0,1
UNIT_SWIM       db 0,0,0,0,0,32,32,35, 0,0,0    ; How many bytes forward is the swim tile?

TEXT_BROWSEMODE db "BROWSE MODE",0
TEXT_HEALTH     db "HEALTH=",0
TEXT_UNIT       db "UNIT #=",0
TEXT_BUILDER001 db "B-BUILD",0
TEXT_BUILDER002 db "Z-BULLDOZE",0
TEXT_BUILDER003 db "P-PICKUP",0
TEXT_BUILDER004 db "D-DROP OFF",0
TEXT_BUILDER005 db "PICK UP ITEM",0
TEXT_BUILDER006 db "ENTER-SELECT",0
TEXT_BUILDER007 db "DROP ITEM",0
TEXT_BUILDER010 db "E-SMELTER",0
TEXT_BUILDER011 db "F-FACTORY",0
TEXT_BUILDER012 db "P-PWRSTATION",0
TEXT_BUILDER013 db "S-SOLAR PANL",0
TEXT_BUILDER014 db "G-GAS REFINE",0
TEXT_BUILDER015 db "ENT FOR MORE",0
TEXT_BUILDER016 db "R-RADAR STAT",0
TEXT_BUILDER017 db "M-MIS. SILO",0
TEXT_BUILDER018 db "H-HEADQUARTR",0
TEXT_BUILDER019 db " ",0
TEXT_BUILDER020 db "ESC-ABORT",0
TEXT_BUILDER025 db "SELECT",0
TEXT_BUILDER026 db "LOCATION",0
TEXT_BUILDER027 db "W-WALL",0
TEXT_BUILDER028 db "V-BRIDGE",0
TEXT_CONPANEL1  db "CONNECTED",0
TEXT_CONPANEL2  db "PANELS:",0
TEXT_CONPANEL3  db "POWERING",0
TEXT_CONPANEL4  db "UNIT:",0
TEXT_CONPANEL5  db "NOT",0
TEXT_CONPANEL6  db "CONNECTED!",0
TEXT_CARRYING   db "CARRYING:",0
TEXT_FACTORY001 db "BUILD UNIT",0
TEXT_FACTORY002 db "B-BUILDER",0
TEXT_FACTORY003 db "T-TANK",0
TEXT_FACTORY004 db "H-HEAVY TANK",0
TEXT_FACTORY005 db "F-FRIGATE",0
TEXT_FACTORY006 db "S-SCOUT CAR",0
TEXT_FACTORY007 db 0                    ; TODO: Change back to "F-FIGHTER",0 once implemented
TEXT_RADAR001   db "SCAN TYPE",0
TEXT_RADAR002   db "M-METALLIC",0
TEXT_RADAR003   db "H-HYDROSCAN",0
TEXT_RADAR004   db "T-THERMAL",0
TEXT_RADAR005   db "O-OSCILLATE",0
TEXT_RADARSCAN1 db "RADAR SCAN RESULTS",0
TEXT_RADARSCAN2 db "SHOWING METALLIC OBJECTS",0
TEXT_RADARSCAN3 db "SHOWING H20 FORMATION",0
TEXT_RADARSCAN4 db "SHOWING THERMAL SIGNATURES",0
TEXT_RADARSCAN5 db "SHOWING CRYSTALINE STRUCTURES",0
TEXT_TANK001    db "SPACE-ATTACK",0
TEXT_TANK002    db "D-SELF",0
TEXT_TANK003    db "  DESTRUCT",0
TEXT_TANK004    db "S-SENTRY",0
TEXT_TANK005    db "A-ASSAULT",0
TEXT_TANK006    db "  MODE",0
TEXT_TANK007    db "SPACE-AUTO",0
TEXT_TANK008    db "  ATTACK",0
TEXT_TANK009    db "M-MANUAL",0
TEXT_WORKING    db "WORKING",0
TEXT_MISSILE1   db "B-BUILD",0
TEXT_MISSILE2   db "L-LAUNCH",0
TEXT_MISSILE3   db "X/Y+SHIFT",0
TEXT_MISSILE4   db "TO SET",0
TEXT_MISSILE5   db "COORDINATES",0
TEXT_MISSILE6   db "--TARGET--",0
TEXT_MISSILE7   db "X=    Y=",0
TEXT_MISSILE8   db " ARMED ",0
TEXT_SMELTER1   db "SEARCHING",0
TEXT_SMELTER2   db "FOR MINERALS",0
TEXT_SMELTER3   db "DROP",0
TEXT_SMELTER4   db "MINERALS",0
TEXT_SMELTER5   db "NEXT TO THE",0
TEXT_SMELTER6   db "SMELTER",0
TEXT_COMCEN1    db "VEHICLES:",0
TEXT_COMCEN2    db "BUILDNGS:",0
TEXT_ABORT      db "A-ABORT",0
TEXT_GS1        db "GAME IS SAVED!",0
TEXT_GS2        db "PRESS ANY KEY",0
TEXT_GS3        db "GAME IS LOADED!",0
TEXT_HHG1       db "PLEASE DO NOT",0
TEXT_HHG2       db " PRESS THIS",0
TEXT_HHG3       db "BUTTON AGAIN. ",0
MENU_DIFF       db "EASYNORMHARD"
GAME_MENU01     db " RETURN TO GAME "
GAME_MENU02     db "   SAVE GAME    "
GAME_MENU03     db "   LOAD GAME    "
GAME_MENU04     db "SCREEN WIDTH-STD"
GAME_MENU05     db "                "   ; overwritten by set_mode_vars
GAME_MENU06     db "    MUSIC-ON    "
GAME_MENU07     db "  SOUND FX-ON   "
GAME_MENU08     db " MOUSE CTRL-ON  "
GAME_MENU09     db "   EXIT GAME    "
INTRO_MENU01    db "START GAME      "
INTRO_MENU02    db "CREDITS         "
INTRO_MENU03    db "MAP:RIVER DIVIDE"
INTRO_MENU04    db "DIFFICULTY:NORM "
INTRO_MENU05    db "EXIT TO DOS     "
INFO_RESOURCES1 db "REQ. TO BUILD:"
INFO_RESOURCES2 db "MINERALS:000  "
INFO_RESOURCES3 db "     GAS:000  "
INFO_RESOURCES4 db "  ENERGY:000  "
INFO_CANT_MOVE1 db "CANNOT MOVE   "
INFO_CANT_MOVE2 db "THIS OBJECT!  "
INFO_CANT_DROP1 db "SOMETHING IS  "
INFO_CANT_DROP2 db "IN THE WAY!   "
INFO_MAXERR01   db "MAX BUILDING  "
INFO_MAXERR02   db "LIMIT REACHED "
INFO_MAXERR03   db "MAX UNIT      "
INFO_BLOCKED1   db "FACTORY EXIT  "
INFO_BLOCKED2   db "IS BLOCKED!   "
INFO_BLOCKED3   db "CONSTR. EXIT  "
INFO_TEST       db "TESTING...    "
INFO_CANT_BLD1  db "CANNOT BUILD  "
INFO_CANT_BLD2  db "THERE!        "
INFO_CANT_BLD3  db "MUST DROP ITEM"
INFO_CANT_BLD4  db "FIRST!        "
INFO_BUILDGAS1  db "MUST BUILD ON "
INFO_BUILDGAS2  db "GAS VENTS!    "
INFO_BULLDOZE1  db "CAN'T BULLDOZE"
INFO_BULLDOZE2  db "THAT!         "
INFO_TARGETOR1  db "TARGET OUT OF "
INFO_TARGETOR2  db "RANGE!        "
INFO_ONWATER1   db "MUST BUILD ON "
INFO_ONWATER2   db "WATER!        "
INFO_GAMEOVER   db "GAME OVER!    "
INFO_BROWSE1    db "NOT IN BROWSE "
INFO_BROWSE2    db "MODE!         "
INFO_NOFOUND    db "NO UNITS FOUND"
INFO_BLANK      db "              "

; ---------- 512 byte fixed-format block of data describing all maps ----------

maplist_data_block:                             ; MAPLIST.BIN goes here
maplist_header  db "px3maps:"
mapnames_marker db "mapnames"
MAPNAMES        db "MAP:RIVER DIVIDE"
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "
                db "MAP:            "

mapfiles_marker db "mapfiles"
MAPFILES        db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
                db "00"
tilesetA_marker db "tilesetA"
MAPTILESET      db "11111111111111111111"       ; 1=grassy 2=winter 3=desert
tilesetB_marker db "tilesetB"
MAPTILESET_ALT1 db "20000000000000000000"       ; 1=grassy 2=winter 3=desert 0=none
tilesetC_marker db "tilesetC"
MAPTILESET_ALT2 db "00000000000000000000"       ; 1=grassy 2=winter 3=desert 0=none

mapmusic_marker db "mapmusic"
; MUST contain a music number choice for every map!
mapmusicset     db "11111111111111111111"
num_maps_marker db "num_maps"
num_maps_ascii  db "01"
maflist_theEOF  db "theEOF"

; -----------------------------------------------------------------------------

; The following table lists which AI types the user is allowed to abort. 0=no 1=yes

CANABORT        db      0       ; 0=none
                db      0       ; 1=power station
                db      0       ; 2=solar panel
                db      1       ; 3=missile silo arming
                db      0       ; 4=headquarters
                db      1       ; 5=traveller type 1 (to exact dest)
                db      1       ; 6=factory making a builder
                db      1       ; 7=factory making a tank
                db      0       ; 8=smelter searching for minerals
                db      0       ; 9=smelter refining minerals
                db      0       ; 10=gas refinery
                db      0       ; 11=projectile
                db      0       ; 12=explosion (small)
                db      1       ; 13=traveller type 2 (to 1-tile next door)
                db      1       ; 14=builder constructing a building (gen-b contains building type)
                db      1       ; 15=builder pickup automatic
                db      1       ; 16=builder drop off automatic
                db      1       ; 17=builder bulldoze
                db      0       ; 18=alien sentry pod
                db      0       ; 19=tank self destruct
                db      0       ; 20=explosion (large)
                db      0       ; 21=nuclear missile falling
                db      1       ; 22=factory making a heavy tank
                db      0       ; 23=heavy tank (sentry mode)
                db      1       ; 24=factory making a frigate
                db      1       ; 25=builder building a wall
                db      1       ; 26=builder building a bridge
                db      0       ; 27=heavy tank converting to sentry mode
                db      0       ; 28=heavy tank converting to assault mode
                db      0       ; 29=pyramid base
                db      0       ; 30=sentry construction
                db      0       ; 31=protoid building construction
                db      0       ; 32-protoid clone facility
                db      0       ; 33-protoid academy
                db      0       ; 34-protoid factory
                db      0       ; 35-protoid something else
                db      0       ; 36-protoid clone warrior
                db      0       ; 37-protoid advanced warrior
                db      0
                db      0
                db      1       ; 40=factory making a fighter
                db      1       ; 41=factory making a scout
; block 2
; The following table is used to fix the cost of anything that the player
; will build.
COST_MIN        db 20   ; 00-headquarters
                db 25   ; 01-power station
                db 5    ; 02-solar panel
                db 16   ; 03-gas refinery
                db 32   ; 04-radar station
                db 50   ; 05-factory
                db 48   ; 06-missile silo
                db 35   ; 07-smelter
                db 16   ; 08-builder
                db 30   ; 09-tank
                db 40   ; 10-heavy tank
                db 3    ; 11-brick wall
                db 4    ; 12-bridge piece
                db 16   ; 13-build missile
                db 30   ; 14-frigate
                db 0    ; 15-radar scan
                db 0    ; 16-
                db 0    ; 17-
                ;-----------------------
COST_GAS        db 5    ; 00-headquarters
                db 5    ; 01-power station
                db 0    ; 02-solar panel
                db 0    ; 03-gas refinery
                db 10   ; 04-radar station
                db 10   ; 05-factory
                db 10   ; 06-missile silo
                db 10   ; 07-smelter
                db 2    ; 08-builder
                db 5    ; 09-tank
                db 10   ; 10-heavy tank
                db 0    ; 11-brick wall
                db 0    ; 12-bridge piece
                db 32   ; 13-build missile
                db 5    ; 14-frigate
                db 0    ; 15-radar scan
                db 0    ; 16-
                db 0    ; 17-
                ;-----------------------
COST_NRG        db 5    ; 00-headquarters
                db 0    ; 01-power station
                db 0    ; 02-solar panel
                db 3    ; 03-gas refinery
                db 12   ; 04-radar station
                db 10   ; 05-factory
                db 10   ; 06-missile silo
                db 10   ; 07-smelter
                db 1    ; 08-builder
                db 3    ; 09-tank
                db 5    ; 10-heavy tank
                db 1    ; 11-brick wall
                db 2    ; 12-bridge piece
                db 32   ; 13-build missile
                db 5    ; 14-frigate
                db 30   ; 15-radar scan
                db 0    ; 16-
                db 0    ; 17-

; The following chart is used to determine placement of alien sentry pods
; relative to the main pyramid, with a starting offset of -4,-4.

SENTRY_ORDER_X  db      3,6,9,0,6,3,9,0,1,8,8,1
SENTRY_ORDER_Y  db      0,9,3,6,0,9,6,3,1,8,1,8


; description:
;       Reset all game-related variables.
RESET_GAME:
        cmp     byte [GAME_DIFF],0
        jne     .L1
        mov     byte [QTY_MINERALS],255
        mov     byte [QTY_GAS],100
        mov     byte [QTY_ENERGY],150
        jmp     .L5
        .L1:
        cmp     byte [GAME_DIFF],1
        jne     .L2
        mov     byte [QTY_MINERALS],100
        mov     byte [QTY_GAS],20
        mov     byte [QTY_ENERGY],20
        jmp     .L5
        .L2:
        mov     byte [QTY_MINERALS],35
        mov     byte [QTY_GAS],15
        mov     byte [QTY_ENERGY],10
        .L5:
        mov     byte [SELECTED_UNIT],0
        mov     byte [BROWSE_MODE],0
        mov     byte [BIG_CURSOR_MODE],0
        mov     byte [HILITE_MODE],0
        mov     word [cs:GAME_CLOCK_TICKS],0
        mov     byte [cs:GAME_CLOCK_SECONDS],0
        mov     byte [cs:GAME_CLOCK_MINUTES],0
        mov     byte [cs:GAME_CLOCK_HOURS],0


; description:
;       Create actual units for all unit tiles on the newly loaded map.
SCAN_MAP_FOR_INITIAL_UNITS:
        mov     si,0
        .L1:
        GET_MAP_BYTE    si
        cmp     al,50h                  ; builder
        jne     .L2
        mov     ah,1                    ; type = builder
        mov     dl,20                   ; health = 20
        mov     bx,1                    ; under = <right>
        call    SCAN_MAP_CREATE_UNIT
        jmp     .L20
        .L2:
        cmp     al,51h                  ; builder
        jne     .L2a
        mov     ah,1                    ; type = builder
        mov     dl,20                   ; health = 20
        mov     bx,-1                   ; under = <left>
        call    SCAN_MAP_CREATE_UNIT
        jmp     .L20
        .L2a:
        cmp     al,58h                  ; tank
        jne     .L3
        mov     ah,2                    ; type = tank
        mov     dl,85                   ; health = 85
        mov     bx,1                    ; under = <right>
        call    SCAN_MAP_CREATE_UNIT
        jmp     .L20
        .L3:
        cmp     al,59h                  ; tank
        jne     .L3a
        mov     ah,2                    ; type = tank
        mov     dl,85                   ; health = 85
        mov     bx,-1                   ; under = <left>
        call    SCAN_MAP_CREATE_UNIT
        jmp     .L20
        .L3a:
        cmp     al,07ch                 ; headquarters
        jne     .L4
        call    SCAN_MAP_CREATE_HQ
        jmp     .L20
        .L4:
        cmp     al,0cch                 ; pyramid base
        jne     .L20
        inc     si
        GET_MAP_BYTE    si
        dec     si
        cmp     al,0cdh                 ; hack for mirrored "2nd strike": no broken pyramids
        jne     .L20
        call    SCAN_MAP_CREATE_PYRAMID
        jmp     .L20
        ; put more searches here....
        .L20:
        inc     si
        cmp     si,32767                ; end of map
        je      .L21                    ; too long for short jump
        jmp     .L1
        .L21:
        mov     byte [UNIT_COUNT_TIMER],1
        call    UNIT_COUNT
        ret

; description:
;       Create a single unit for a certain map location.
; parameters:
;       al: unit tile
;       ah: unit type
;       dl: unit health
;       bx: offset of substitute tile_under on map
SCAN_MAP_CREATE_UNIT:
        mov     di,0
        .L1:
        cmp     byte UNIT_TYPE[di],0
        je      .L2
        inc     di
        cmp     di,20
        je      .L3
        jmp     .L1
        .L2:
        mov     byte UNIT_TYPE[di],ah
        mov     byte UNIT_TILE[di],al
        mov     byte UNIT_HEALTH[di],dl
        mov     ax,si
        mov     UNIT_LOCATION_X[di],al
        mov     UNIT_LOCATION_Y[di],ah
        ; find tile to right, use as under-tile
        add     si,bx                           ; get tile to the right, left, top or bottom
        GET_MAP_BYTE    si
        mov     UNIT_TILE_UNDER[di],al
        .L3:
        ret

SCAN_MAP_CREATE_HQ:
        mov     di,20
        .L1:
        cmp     byte UNIT_TYPE[di],0
        je      .L2
        inc     di
        cmp     di,50
        je      .L3
        jmp     .L1
        .L2:
        mov     byte UNIT_TYPE[di],20           ; HQ
        mov     byte UNIT_TILE[di],07Ch         ; HQ tile
        mov     byte UNIT_TILE_UNDER[di],1      ; grass
        mov     byte UNIT_HEALTH[di],200
        mov     byte UNIT_AI[di],4              ; headquarters AI
        mov     byte UNIT_TIMER[di],1
        mov     ax,si
        mov     UNIT_LOCATION_X[di],al
        mov     UNIT_LOCATION_Y[di],ah
        .L3:
        ret

SCAN_MAP_CREATE_PYRAMID:
        mov     di,128
        .L1:
        cmp     byte UNIT_TYPE[di],0
        je      .L2
        inc     di
        cmp     di,164
        je      .L3
        jmp     .L1
        .L2:
        mov     byte UNIT_TYPE[di],33           ; protoid pyramid base
        mov     byte UNIT_TILE[di],0CCh         ; pyramid pod tile
        mov     byte UNIT_TILE_UNDER[di],1      ; grass
        mov     byte UNIT_HEALTH[di],250
        mov     byte UNIT_AI[di],29             ; pyramid AI
        mov     bx,di
        shl     bl,1
        mov     UNIT_TIMER[di], bl              ; semi-random timing
        mov     ax,si
        mov     UNIT_LOCATION_X[di],al
        mov     UNIT_LOCATION_Y[di],ah
        .L3:
        ret

CLEAR_ALL_UNIT_VARIABLES:
        mov     di,0
        .L1:
        mov     byte UNIT_TYPE[di],0
        mov     byte UNIT_TIMER[di],0
        mov     byte UNIT_TILE[di],0
        mov     byte UNIT_HEALTH[di],0
        mov     byte UNIT_LOCATION_X[di],0
        mov     byte UNIT_LOCATION_Y[di],0
        mov     byte UNIT_DEST_X[di],0
        mov     byte UNIT_DEST_Y[di],0
        mov     byte UNIT_WORKING[di],0
        mov     byte UNIT_GEN_A[di],0
        mov     byte UNIT_GEN_B[di],0
        mov     byte UNIT_GEN_C[di],0
        mov     byte UNIT_AI[di],0
        inc     di
        cmp     di,256
        jne     .L1
        mov     di,0
        .L2:
        mov     byte HOTKEYS[di],0
        inc     di
        cmp     di,10
        jne     .L2
        ret
; block 3
RESET_KEYBOARD_REPEAT_RATE:
        mov     ah,03
        mov     al,00
;        mov     bh,0                    ; lowest delay
;        mov     bl,017h                 ; 4 characters a second
        int     16h
        ret

BROWSE_GET_TILE:
        mov     bh,[BROWSE_CURSOR_Y]
        add     bh,[MAP_OFFS_Y]
        mov     bl,[BROWSE_CURSOR_X]
        add     bl,[MAP_OFFS_X]
        mov     si,bx
        GET_MAP_BYTE    si
        mov     [SELECTED_TILE],al
        ret

BROWSE_PUT_CURSOR:
        call    find_cursor_location
        cmp     byte [BIG_CURSOR_MODE],0
        jne     .L2
        call    [plot_cursor]
        jmp     .L3
        .L2:
        call    [plot_cursor_big]
        .L3:
        call    BROWSE_GET_TILE
        call    DRAW_STATUS_BROWSE
        ret

BROWSE_UP:
        mov     byte [BROWSE_MOVEMENT],1
        cmp     byte [BROWSE_CURSOR_Y],0
        je      .L1
        call    BROWSE_ERASE_CURSOR
        dec     byte [BROWSE_CURSOR_Y]
        call    BROWSE_PUT_CURSOR
        .L1:
        ret
BROWSE_DOWN:
        mov     byte [BROWSE_MOVEMENT],1
        mov     al,8                            ; max downward movement
        cmp     byte [BIG_CURSOR_MODE],0
        je      .L2
        dec     al                              ; reduce 1 for big cursor
        .L2:
        cmp     [BROWSE_CURSOR_Y],al
        je      .L1
        call    BROWSE_ERASE_CURSOR
        inc     byte [BROWSE_CURSOR_Y]
        call    BROWSE_PUT_CURSOR
        .L1:
        ret
BROWSE_LEFT:
        mov     byte [BROWSE_MOVEMENT],1
        cmp     byte [BROWSE_CURSOR_X],0
        je      .L1
        call    BROWSE_ERASE_CURSOR
        dec     byte [BROWSE_CURSOR_X]
        call    BROWSE_PUT_CURSOR
        .L1:
        ret
BROWSE_RIGHT:
        mov     byte [BROWSE_MOVEMENT],1
        mov     cl,[SCREEN_WIDTH]
        dec     cl
        cmp     byte [BIG_CURSOR_MODE],0
        je      .L2
        dec     cl
        .L2:
        cmp     [BROWSE_CURSOR_X],cl
        je      .L1
        call    BROWSE_ERASE_CURSOR
        inc     byte [BROWSE_CURSOR_X]
        call    BROWSE_PUT_CURSOR
        .L1:
        ret

CHECK_FOR_UNIT_AT_XY:
        mov     si,0
        .L1:
        cmp     byte UNIT_TYPE[si],0
        je      .L10
        mov     al,[CHECK_X]
        cmp     UNIT_LOCATION_X[si],al
        jne     .L10
        mov     al,[CHECK_Y]
        cmp     UNIT_LOCATION_Y[si],al
        jne     .L10
        mov     ax,si
        mov     [CHECK_XY_UNIT],al
        mov     byte [CHECK_XY_RESULT],1
        ret
        .L10:
        inc     si
        cmp     si,196  ; end at 195 because don't check for explosions, etc.
        jne     .L1
        mov     byte [CHECK_XY_RESULT],0
        ret

START_BROWSE_MODE:
        mov     byte [BROWSE_MOVEMENT],0
        call    CLEAR_STATUS_WINDOW
        mov     byte [BROWSE_MODE],1
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_LOCATION_X[si]
        sub     al,[MAP_OFFS_X]
        mov     [BROWSE_CURSOR_X],al
        mov     al,UNIT_LOCATION_Y[si]
        sub     al,[MAP_OFFS_Y]
        mov     [BROWSE_CURSOR_Y],al
        cmp     byte [BIG_CURSOR_MODE],0
        je      .L1
        cmp     byte [BROWSE_CURSOR_Y],8
        jne     .L1
        mov     byte [BROWSE_CURSOR_Y],7
        .L1:
        call    BROWSE_PUT_CURSOR

BROWSE_LOOP:
        cmp     byte[cs:BG_TIMER_MAIN],1
        jne     BWLP01
        call    BACKGROUND_ROUTINE
        call    CHECK_FOR_REDRAWS
        BWLP01:
        mov     ah,1
        int     16h                     ; check keyboard buffer
        jz      BROWSE_LOOP
        xor     ah,ah                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     ah,048h                 ; Up arrow
        jne     .L5
        call    BROWSE_UP
        jmp     BROWSE_LOOP
.L5:    cmp     ah,050h                 ; Down arrow
        jne     .L6
        call    BROWSE_DOWN
        jmp     BROWSE_LOOP
.L6:    cmp     ah,04Bh                 ; Left arrow
        jne     .L7
        call    BROWSE_LEFT
        jmp     BROWSE_LOOP
.L7:    cmp     ah,04Dh                 ; Right arrow
        jne     .L8
        call        BROWSE_RIGHT
        jmp     BROWSE_LOOP
.L8:    cmp     al,0dh                  ; ENTER key
        jne     .L9
        mov     byte [BROWSE_MODE],0
        call    BROWSE_ERASE_CURSOR
        mov     byte [BROWSE_CANCEL],0
        ret
.L9:    cmp     al,020h                 ; SPACE-BAR
        jne     .L10
        mov     byte [BROWSE_MODE],0
        call    BROWSE_ERASE_CURSOR
        mov     byte [BROWSE_CANCEL],0
        ret
.L10:   cmp     ah,01h                  ; ESCAPE key
        jne     .L11
        mov     byte [BROWSE_MODE],0
        call    BROWSE_ERASE_CURSOR
        mov     byte [BROWSE_CANCEL],1
        ret
.L11:   ; User must have pressed something not supported, so
        ; show an error message
        mov     si,INFO_BROWSE1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BROWSE2
        call    WRITE_NEW_MESSAGE
        mov     al,0                    ; error beep
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound
        jmp     BROWSE_LOOP

MAINLOOP:
        mov     byte [cs:clock_active],1; If we were in menu, re-enable clock
        call    CHECK_FOR_REDRAWS
        cmp     byte [cs:BG_TIMER_MAIN],1
        jne     ML000
        call    BACKGROUND_ROUTINE
        cmp     byte [END_GAME_DETECTED],0
        je      ML000
        call    GAMEOVER_SCREEN
        ret
ML000:
        mov     ah,01
        int     16h                     ; check keyboard buffer
        jz      MAINLOOP
        xor     ah,ah                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     ah,048h                 ; Up arrow
        jne     ML001
        call    MOVEUP
        jmp     MAINLOOP
ML001:  cmp     ah,04Bh                 ; Left arrow
        jne     ML002
        call    MOVELEFT
        jmp     MAINLOOP
ML002:  cmp     ah,04Dh                 ; Right arrow
        jne     ML003
        call    MOVERIGHT
        jmp     MAINLOOP
ML003:  cmp     ah,050h                 ; Down arrow
        jne     ML004
        call    MOVEDOWN
        jmp     MAINLOOP
ML004:  cmp     al,020h                 ; SPACE bar
        jne     ML005
        call    KEY_COMMAND_SPACE
        jmp     MAINLOOP
ML005:  cmp     ah,1                    ; ESC key
        jne     ML010
        mov     al,09                   ; menu beep
        mov     ah,255                  ; priority
        call    m_playSFX               ; play sound effect
        mov     byte [cs:clock_active],0; Pause the game if we're in the menu
        call    GAME_MENU
        mov     byte [cs:clock_active],1; start clock again
        cmp     byte [MENU_SEL], 8
        jne     .not_exit
        ret     ; return to INTRO_MENU
.not_exit:
        call    force_draw_entire_screen
        jmp     MAINLOOP
ML010:  cmp     Ah,051h                 ; PAGE DOWN
        jne     ML011
        call    CYCLE_BUILDING_FORWARD
        jmp     MAINLOOP
ML011:  cmp     Ah,0fh                  ; TAB-key
        jne     ML012
        call    KEY_COMMAND_TAB
        jmp     MAINLOOP
ML012:  cmp     al,0dh                  ; ENTER key
        %IF     DIAGS
        jne     ML030
        %ELSE
        jne     ML031
        %ENDIF
        call    BROWSE_FOR_UNIT
        jmp     MAINLOOP
        %IF     DIAGS
ML030:  cmp     Ah,03bh                 ; F1 - key
        jne     ML031
        call    DIAGNOSTIC_SCREEN
        jmp     MAINLOOP
        %ENDIF
ML031:  cmp     al,'+'                  ; plus key
        je      ML031a
        cmp     al,'='                  ; without shift: '=' on US layout
        jne     ML032
ML031a: call    CYCLE_UNIT_FORWARD
        jmp     MAINLOOP
ML032:  cmp     al,'-'                  ; minus key
        jne     ML033
        call    CYCLE_UNIT_BACKWARD
        jmp     MAINLOOP
ML033:  cmp     al,'['                  ; [ -key
        jne     ML034
        call    CYCLE_BUILDING_BACKWARD
        jmp     MAINLOOP
ML034:  cmp     al,']'                  ; ] - key
        jne     ML035
        call    CYCLE_BUILDING_FORWARD
        jmp     MAINLOOP
ML035:  cmp     al,'p'                  ; p - key
        jne     ML036
        call    KEY_COMMAND_P
        jmp     MAINLOOP
ML036:  cmp     al,'d'                  ; d - key
        jne     ML037
        call    KEY_COMMAND_D
        jmp     MAINLOOP
ML037:  cmp     al,'b'                  ; b - key
        jne     ML038
        call    KEY_COMMAND_B
        jmp     MAINLOOP
ML038:  cmp     al,'m'                  ; m - key
        jne     ML039
        call    KEY_COMMAND_M
        jmp     MAINLOOP
ML039:  cmp     al,'h'                  ; h - key
        jne     ML040
        call    KEY_COMMAND_H
        jmp     MAINLOOP
ML040:  cmp     al,'t'                  ; t - key
        jne     ML041
        call    KEY_COMMAND_T
        jmp     MAINLOOP
ML041:  cmp     al,'o'                  ; o - key
        jne     ML042
        call    KEY_COMMAND_O
        jmp     MAINLOOP
ML042:  cmp     al,'x'                  ; x - key
        jne     ML043
        call    KEY_COMMAND_X
        jmp     MAINLOOP
ML043:  cmp     al,'X'                  ; shift-x key
        jne     ML044
        call    KEY_COMMAND_SHIFT_X
        jmp     MAINLOOP
ML044:  cmp     al,'y'                  ; y - key
        jne     ML045
        call    KEY_COMMAND_Y
        jmp     MAINLOOP
ML045:  cmp     al,'Y'                  ; shift-y key
        jne     ML046
        call    KEY_COMMAND_SHIFT_Y
        jmp     MAINLOOP
ML046:  cmp     al,'a'                  ; a-key
        jne     ML047
        call    KEY_COMMAND_A
        jmp     MAINLOOP
ML047:  cmp     al,'z'                  ; z-key
        jne     ML048
        call    KEY_COMMAND_Z
        jmp     MAINLOOP
ML048:  cmp     al,'l'                  ; l-key
        jne     ML049
        call    KEY_COMMAND_L
        jmp     MAINLOOP
ML049:  cmp     al,'s'                  ; s-key
        jne     ML050
        call    KEY_COMMAND_S
        jmp     MAINLOOP
ML050:  cmp     al,'f'                  ; f-key
        jne     ML051
        call    KEY_COMMAND_F
        jmp     MAINLOOP
ML051:  cmp     al,'w'                  ; w-key
        jne     ML052
        call    KEY_COMMAND_W
        jmp     MAINLOOP
ML052:  cmp     al,'v'                  ; v-key
        jne     ML053
        call    KEY_COMMAND_V
        jmp     MAINLOOP
ML053:  cmp     Ah,049h                 ; PAGE UP key
        jne     ML054
        call    CYCLE_BUILDING_BACKWARD
ML054:  cmp     ah,02h                  ; numbers 0 to 9
        jae     .L1
        jmp     ML055
        .L1:
        cmp     ah,0bh
        ja      ML055
        call    HOTKEY_PRESSED
ML055:
        jmp     MAINLOOP

HOTKEY_PRESSED:
        ; first figure out if it was shifted or not
        cmp     al,030h
        jae     .L1
        jmp     HOTKEY_DEFINE
        .L1:
        cmp     al,039h
        jbe     .L2
        jmp     HOTKEY_DEFINE
        .L2:
        jmp     HOTKEY_JUMP
        ret

HOTKEY_DEFINE:
        sub     ah,2
        mov     al,ah
        mov     ah,0
        mov     di,ax
        mov     bl,[SELECTED_UNIT]
        cmp     di,10
        jae     .L1     ; safety net in case we somehow end up with number bigger than 9.
        mov     HOTKEYS[di],bl
        mov     al,19                   ; selects order "19" in SOUNDS.P3M
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L1:
        ret

HOTKEY_JUMP:
        sub     ah,2
        mov     al,ah
        mov     ah,0
        mov     di,ax
        mov     bl,HOTKEYS[di]
        mov     bh,0
        mov     si,bx
        cmp     byte UNIT_TYPE[si],0
        je      .L2
        jmp     COMPLETE_UNIT_CHANGE
        .L2:
        mov     si,INFO_NOFOUND
        call    WRITE_NEW_MESSAGE
        mov     al,0                    ; beep
        mov     ah,150                  ; priority
        call    m_playSFX               ; play sound
        ret

KEY_COMMAND_TAB:
        cmp     al,09                   ; Is it TAB or SHIFT-TAB?
        je      .L1
        jmp     CYCLE_UNIT_BACKWARD
        .L1:
        jmp     CYCLE_UNIT_FORWARD

KEY_COMMAND_V:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; check for AI in progress
        je      KEYV01
        ret
        KEYV01:
        cmp     byte UNIT_TYPE[si],1    ; builder
        jne     KEYV02
        call    BUILDER_BUILD_BRIDGE
        KEYV02:
        ret

KEY_COMMAND_W:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; check for AI in progress
        je      KEYW01
        ret
        KEYW01:
        cmp     byte UNIT_TYPE[si],1    ; builder
        jne     KEYW02
        call    BUILDER_BUILD_WALL
        KEYW02:
        ret

KEY_COMMAND_F:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; check for AI in progress
        je      KEYF01
        ret
        KEYF01:
        cmp     byte UNIT_TYPE[si],25   ; factory
        jne     KEYF02
        call    FACTORY_BUILD_FRIGATE
        ret
        KEYF02:
        ret

KEY_COMMAND_S:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; check for AI in progrress
        je      KEYS01
        ret
        KEYS01:
        cmp     byte UNIT_TYPE[si],3    ; heavy tank (assault mode)
        jne     KEYS02
        call    CONVERT_TO_SENTRY_MODE
        ret
        KEYS02:
        cmp     byte UNIT_TYPE[si],25   ; factory
        jne     KEYS03
        call    FACTORY_BUILD_SCOUT
        ret
        KEYS03:
        ret

KEY_COMMAND_L:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; check for AI in progrress
        je      KEYL01
        ret
        KEYL01:
        cmp     byte UNIT_TYPE[si],26   ; missile silo
        jne     KEYL02
        cmp     byte UNIT_GEN_A[si],1   ; is it armed?
        jne     KEYL02
        call    LAUNCH_NUCLEAR_MISSILE
        ret
        KEYL02:
        ret

KEY_COMMAND_Z:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; check for AI in progrress
        je      KEYZ01
        ret
        KEYZ01:
        cmp     byte UNIT_TYPE[si],1    ; builder
        jne     KEYZ02
        call    BUILDER_BULLDOZE
        KEYZ02:
        ret

KEY_COMMAND_SPACE:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; check for AI in progrress
        je      .L1
        ret
        .L1:
        cmp     byte UNIT_TYPE[si],2    ; tank
        jne     .L2
        call    TANK_AUTO_FIRE
        ret
        .L2:
        cmp     byte UNIT_TYPE[si],3    ; heavy tank
        jne     .L3
        call    TANK_FIRE
        ret
        .L3:
        cmp     byte UNIT_TYPE[si],4    ; frigate
        jne     .L4
        call    TANK_FIRE
        .L4:
        ret

KEY_COMMAND_A:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],32           ; sentry tank
        je      .L3
        cmp     byte UNIT_AI[si],0              ; check for AI in progress
        jne     .L1
        ret
        .L1:
        ; find out if unit is allowed to abort
        mov     bl,UNIT_AI[si]
        mov     bh,0
        mov     di,bx
        cmp     byte CANABORT[di],1
        je      .L5
        ret
        .L5:
        cmp     byte UNIT_AI[si],14             ; construction in progress?
        jne     .L2
        mov     byte UNIT_GEN_C[si],0           ; clear construction counter
        .L2:
        cmp     byte UNIT_AI[si],26             ; is it building a bridge?
        jne     .L6
        mov     al,[SELECTED_UNIT]
        mov     [UNIT_SCAN],al
        call    BUILD_ABORT
        .L6:
        mov     byte UNIT_AI[si],0
        mov     byte UNIT_WORKING[si],0
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte UNIT_DEST_X[si],0
        mov     byte UNIT_DEST_Y[si],0
        mov     byte UNIT_ALTMOVE_X[si],0
        mov     byte UNIT_ALTMOVE_Y[si],0
        mov     al,1                            ; selects ABORT SOUND
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        ret
        .L3:
        cmp     byte UNIT_AI[si],28             ; is it already converting to assault?
        jne     .L4
        mov     byte UNIT_WORKING[si],0
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte UNIT_AI[si],23             ; abort back to sentry tank.
        ret
        .L4:
        call    CONVERT_TO_ASSAULT_MODE
        ret

KEY_COMMAND_X:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0              ; check for AI in progress
        je      KEYX01
        ret
        KEYX01:
        cmp     byte UNIT_TYPE[si],26           ; missile silo
        jne     KEYX02
        inc     byte UNIT_DEST_X[si]
        mov     al,18                           ; short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_MISSILE_SILO
        KEYX02:
        ret
KEY_COMMAND_SHIFT_X:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0              ; check for AI in progress
        je      KEYSX01
        ret
        KEYSX01:
        cmp     byte UNIT_TYPE[si],26           ; missile silo
        jne     KEYSX02
        dec     byte UNIT_DEST_X[si]
        mov     al,18                           ; short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_MISSILE_SILO
        KEYSX02:
        ret
KEY_COMMAND_Y:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0              ; check for AI in progress
        je      KEYY01
        ret
        KEYY01:
        cmp     byte UNIT_TYPE[si],26           ; missile silo
        jne     KEYY02
        inc     byte UNIT_DEST_Y[si]
        and     byte UNIT_DEST_Y[si],7fh
        mov     al,18                           ; short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_MISSILE_SILO
        KEYY02:
        ret
KEY_COMMAND_SHIFT_Y:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0              ; check for AI in progress
        je      KEYSY01
        ret
        KEYSY01:
        cmp     byte UNIT_TYPE[si],26           ; missile silo
        jne     KEYSY02
        dec     byte UNIT_DEST_Y[si]
        and     byte UNIT_DEST_Y[si],7fh
        mov     al,18                           ; short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    DRAW_STATUS_MISSILE_SILO
        KEYSY02:
        ret

KEY_COMMAND_T:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_TYPE[si]
        cmp     al,21                   ; radar station
        jne     KEYT02
        call    RADAR_THERMAL_SCAN
        KEYT02:
        cmp     al,25                   ; factory
        jne     KEYT03
        call    FACTORY_BUILD_TANK
        ret
        KEYT03:
        ret

KEY_COMMAND_O:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_TYPE[si]
        cmp     al,21                   ; radar station
        jne     KEYO02
        call    RADAR_OSC_SCAN
        KEYO02:
        ret

KEY_COMMAND_H:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_TYPE[si]
        cmp     al,21                   ; radar station
        jne     .L2
        call    RADAR_HYDRO_SCAN
        ret
        .L2:
        cmp     al,25                   ; factory
        jne     .L3
        call    FACTORY_BUILD_HEAVY_TANK
        .L3:
        ret

KEY_COMMAND_M:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_TYPE[si]
        cmp     al,21                   ; radar station
        jne     .L1
        call    RADAR_METAL_SCAN
        .L1:
        cmp     byte UNIT_TYPE[si],2    ; tank
        jne     .L2
        call    TANK_FIRE               ; manual fire
        .L2:
        ret

KEY_COMMAND_P:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],01   ; builder
        jne     KEYP02
        call    BUILDER_PICK_UP_ITEM
        ret
        KEYP02:
        cmp     byte UNIT_TYPE[si],27   ; smelter
        jne     KEYP03
        call    SMELTER_PROCESS_MINERALS
        ret
        KEYP03:
        ret

KEY_COMMAND_D:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],01   ; builder
        jne     .L2
        cmp     byte UNIT_AI[si],0
        jne     .L3
        call    BUILDER_DROP_OFF_ITEM
        ret
        .L2:
        cmp     byte UNIT_TYPE[si],02   ; tank
        jne     .L3
        cmp     byte UNIT_AI[si],0
        jne     .L3
        call    TANK_SELF_DESTRUCT
        ret
        .L3:
        ret

KEY_COMMAND_B:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],01           ; builder
        jne     .L2
        cmp     byte UNIT_AI[si],0
        jne     .L4
        call    BUILDER_BUILD_STRUCTURE
        ret
        .L2:
        cmp     byte UNIT_TYPE[si],26           ; missile silo
        jne     .L3
        call    MISSILE_SILO_BUILD_MISSILE
        ret
        .L3:
        cmp     byte UNIT_TYPE[si],25           ; factory
        jne     .L4
        call    FACTORY_BUILD_BUILDER
        .L4:
        ret

CONVERT_TO_ASSAULT_MODE:
        mov     byte UNIT_AI[si],28             ; AI convert to sentry
        jmp     ctsm1

CONVERT_TO_SENTRY_MODE:
        mov     byte UNIT_AI[si],27             ; AI convert to sentry
        ctsm1:
        mov     byte UNIT_WORKING[si],1
        mov     byte UNIT_TIMER[si],2
        mov     byte [REDRAW_SCREEN_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        mov     al,6                            ; selects CONVERT SOUND
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        ret

LAUNCH_NUCLEAR_MISSILE:
        mov     byte UNIT_GEN_A[si],0
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        mov     di,196                          ; start of projectiles
        LNM04:
        cmp     byte UNIT_TYPE[di],0
        je      LNM05                           ; found a unit number
        inc     di
        cmp     di,212                          ; end of projectiles
        jne     LNM04
        ; failed to find available projectile number
        ret
        LNM05:
        mov     byte UNIT_TYPE[di],31           ; nuclear missile unit type
        mov     byte UNIT_AI[di],21             ; nuclear missile AI type
        mov     al,UNIT_DEST_X[si]
        mov     UNIT_LOCATION_X[di],al
        mov     al,UNIT_DEST_Y[si]
        mov     UNIT_LOCATION_Y[di],al
        mov     byte UNIT_TIMER[di],1
        mov     byte UNIT_GEN_A[di],50          ; drop height
        mov     al,5                            ; selects NUCLEAR MISSILE
        mov     ah,250                          ; priority
        call    m_playSFX                       ; play sound effect
        ret

TANK_SELF_DESTRUCT:
        mov     byte UNIT_AI[si],19             ; tank self destruct AI
        mov     byte UNIT_TIMER[si],3
        mov     byte UNIT_WORKING[si],1
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     al,21                           ; selects self destruct sound
        mov     ah,250                          ; priority
        call    m_playSFX                       ; play sound effect
        ret

TANK_AUTO_FIRE:
        ; check for enemy units nearby
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     [UNIT_SCAN],al
        ; see if weapon is recharging
        cmp     byte UNIT_GEN_C[si],0
        je      .L03
        ret
        .L03:
        mov     di,64                           ; start of enemy units
        .L05:
        cmp     byte UNIT_TYPE[di],0
        jne     .L10
        .L06:
        inc     di
        cmp     di,196                          ; end of enemy units
        jne     .L05
        ; ret    ;NONE FOUND, RETURN
        jmp     TANK_FIRE                       ; go to manual if nothing found.
        .L10:
        mov     al,UNIT_LOCATION_X[di]          ; enemy unit
        mov     UNIT_DEST_X[si],al              ; location dest
        mov     al,UNIT_LOCATION_Y[di]
        mov     UNIT_DEST_Y[si],al
        call    CHECK_DISTANCE_TO_DESTINATION
        cmp     byte [TEMP_X],5
        ja      .L06
        cmp     byte [TEMP_Y],4
        ja      .L06
        mov     ax,di
        mov     [TEMP_A],al                     ; store target unit#
        ; find new projectile unit number
        mov     di, 196
        .L15:
        mov     al,UNIT_TYPE[di]
        cmp     al,0
        je      .L20
        inc     di
        cmp     di,212
        jne     .L15
        ret     ; failure to find free projectile unit
        .L20:
        ; set information for projectile
        mov     byte UNIT_TYPE[di],28           ; projectile unit type
        mov     byte UNIT_AI[di],11             ; projectile AI
        mov     byte UNIT_GEN_A[di],10          ; damage
        mov     al,[TEMP_A]
        mov     UNIT_GEN_B[di],al               ; fire at unit#
        mov     byte UNIT_TILE[di],0b7h         ; blue projectile tile
        mov     byte UNIT_TIMER[di],2
        mov     al,UNIT_LOCATION_X[si]          ; projectile starting location
        mov     UNIT_LOCATION_X[di],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     UNIT_LOCATION_Y[di],al
        mov     byte UNIT_GEN_C[si],1           ; firing delay
        mov     byte UNIT_TIMER[si],8           ; firing delay
        mov     byte UNIT_AI[si],38             ; firing delay AI
        mov     al,UNIT_DEST_X[si]
        mov     [LAST_ATTACK_X],al
        mov     al,UNIT_DEST_Y[si]
        mov     [LAST_ATTACK_Y],al
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        jne     .L21
        mov     al,04                           ; shooting sound
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound
        .L21:
        ret

TANK_FIRE:
        ; see if weapon is recharging
        cmp     byte UNIT_GEN_C[si],0
        je      .L20
        cmp     byte [UNIT_AI],38               ; verify it is in recharge mode.
        jne     .L20
        ret
        .L20:
        mov     al,18                           ; short beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        call    START_BROWSE_MODE
        cmp     byte [BROWSE_CANCEL],1          ; did user cancel?
        jne     .L0
        ret
        .L0:
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],0            ; is unit still alive?
        jne     .L1
        ret
        .L1:
        cmp     byte [BROWSE_MOVEMENT],1
        je      .L2
        ; attacking previous location
        mov     al,[LAST_ATTACK_X]
        mov     UNIT_DEST_X[si],al
        mov     al,[LAST_ATTACK_Y]
        mov     UNIT_DEST_Y[si],al
        jmp     .L3
        .L2:
        ; attacking new location
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        mov     UNIT_DEST_X[si],al
        mov     al,[MAP_OFFS_Y]
        add     al,[BROWSE_CURSOR_Y]
        mov     UNIT_DEST_Y[si],al
        .L3:
        ; check if target is in range
        mov     al,[SELECTED_UNIT]
        mov     [UNIT_SCAN],al
        call    CHECK_DISTANCE_TO_DESTINATION
        cmp     byte [TEMP_X],5
        jbe     .L5
        jmp     TARGET_OUT_OF_RANGE
        .L5:
        cmp     byte [TEMP_Y],4
        jbe     .L6
        jmp     TARGET_OUT_OF_RANGE
        .L6:
        ; find new projectile unit number
        mov     di, 196
        .L7:
        mov     al,UNIT_TYPE[di]
        cmp     al,0
        je      .L8
        inc     di
        cmp     di,212
        jne     .L7
        ret     ; failure to find free projectile unit
        .L8:
        mov     al,15                           ; selects SHOOTING SOUND
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        mov     byte UNIT_TYPE[di],28           ; projectile unit type
        mov     byte UNIT_AI[di],11             ; projectile AI
        mov     byte UNIT_GEN_B[di],255         ; fire at map
        mov     al,UNIT_DEST_X[si]
        mov     [LAST_ATTACK_X],al
        mov     UNIT_DEST_X[di],al
        mov     al,UNIT_DEST_Y[si]
        mov     [LAST_ATTACK_Y],al
        mov     UNIT_DEST_Y[di],al
        mov     al,UNIT_LOCATION_X[si]
        mov     UNIT_LOCATION_X[di],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     UNIT_LOCATION_Y[di],al
        mov     al,UNIT_TILE[si]
        mov     UNIT_TILE_UNDER[di],al
        mov     byte UNIT_TIMER[di],1
        mov     byte UNIT_GEN_C[si],1           ; firing delay
        mov     byte UNIT_TIMER[si],8           ; firing delay
        mov     byte UNIT_AI[si],38             ; firing delay AI
        cmp     byte UNIT_TYPE[si],3
        je      .L10
        ; regular tank
        mov     byte UNIT_TILE[di],0B7h         ; blue projectile tile
        mov     byte UNIT_GEN_A[di],25          ; damage
        ret
        .L10:
        ; heavy tank
        mov     byte UNIT_TILE[di],0B6h         ; blue projectile tile
        mov     byte UNIT_GEN_A[di],50          ; damage
        ret



        TARGET_OUT_OF_RANGE:
        mov     si,INFO_TARGETOR1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_TARGETOR2
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects ERROR
        mov     ah,175                          ; priority
        call    m_playSFX                       ; play sound effect
        ret

SMELTER_PROCESS_MINERALS:
        mov     byte UNIT_AI[si],8              ; search for minerals
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret

FACTORY_BUILD_FRIGATE:
        mov     al,[SELECTED_UNIT]
        mov     [UNIT_SCAN],al
        call    FIND_WATER_DELIVERY_LOCATION    ; success: zf=1
        jz      .L1
        ; build fighter, instead
        ret                                     ; TODO: Implement and re-enable fighter
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0              ; is it already building something?
        je      .skip1
        jmp     FACTORY_BUILD_TANK.L2
        .skip1:
        ; check for resources
        mov     byte [TEMP_A],14                ; frigate
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        jne     .skip2
        jmp     FACTORY_BUILD_TANK.L2
        .skip2:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_WORKING[si],1
        mov     byte UNIT_AI[si],40             ; BUILD fighter
        mov     byte UNIT_TIMER[si],30
        call    CLEAR_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        mov     al,14                           ; selects CONSTRUCTION SOUND
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        ret
        .L1:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0              ; is it already building something?
        jne     FACTORY_BUILD_TANK.L2
        ; check for resources
        mov     byte [TEMP_A],14                ; frigate
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        je      FACTORY_BUILD_TANK.L2
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_WORKING[si],1
        mov     byte UNIT_AI[si],24             ; BUILD frigate
        mov     byte UNIT_TIMER[si],30
        call    CLEAR_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        mov     al,14                           ; selects CONSTRUCTION SOUND
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        .L3:
        ret

FACTORY_BUILD_TANK:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0              ; is it already building something?
        jne     .L2
        ; check for resources
        mov     byte [TEMP_A],09                ; tank
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        je      .L2
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_WORKING[si],1
        mov     byte UNIT_AI[si],7              ; build tank
        mov     byte UNIT_TIMER[si],30
        call    CLEAR_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        mov     al,14                           ; selects CONSTRUCTION SOUND
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound effect
        .L2:
        ret

FACTORY_BUILD_HEAVY_TANK:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; is it already building something?
        jne     .L2
        ; check for resources
        mov     byte [TEMP_A],10        ; heavy tank
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        je      .L2
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_WORKING[si],1
        mov     byte UNIT_AI[si],22     ; build heavy tank
        mov     byte UNIT_TIMER[si],30
        call    CLEAR_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        mov     al,14                   ; selects CONSTRUCTION SOUND
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L2:
        ret

FACTORY_BUILD_BUILDER:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; is it already building something?
        jne     .L2
        ; check for resources
        mov     byte [TEMP_A],08        ; builder
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        je      .L2
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_WORKING[si],1
        mov     byte UNIT_AI[si],6      ; build builder
        mov     byte UNIT_TIMER[si],30
        call    CLEAR_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        mov     al,14                   ; selects CONSTRUCTION SOUND
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L2:
        ret

FACTORY_BUILD_SCOUT:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0      ; is it already building something?
        jne     .L2
        ; check for resources
        mov     byte [TEMP_A],08        ; builder
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        je      .L2
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_WORKING[si],1
        mov     byte UNIT_AI[si],41     ; BUILD scout
        mov     byte UNIT_TIMER[si],30
        call    CLEAR_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        mov     al,14                   ; selects CONSTRUCTION SOUND
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L2:
        ret

MISSILE_SILO_BUILD_MISSILE:
        cmp     byte UNIT_GEN_A[si],0   ; is it armed already?
        jne     .L3
        cmp     byte UNIT_AI[si],0      ; is it busy?
        jne     .L3
        ; check for resources
        mov     byte [TEMP_A],13        ; missile
        call    CHECK_RESOURCES
        cmp     byte [TEMP_A],0
        jne     .L1
        ret
        .L1:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_WORKING[si],1
        mov     byte UNIT_AI[si],3
        mov     byte UNIT_TIMER[si],75
        call    CLEAR_COMMAND_WINDOW
        call    DRAW_STATUS_WINDOW
        mov     al,14                   ; selects CONSTRUCTION SOUND
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L3:
        ret

CHECK_FOR_REDRAWS:
        cmp     byte [REDRAW_SCREEN_REQ],1
        jne     .L4
        call    DRAW_ENTIRE_SCREEN
        call    DRAW_FLYING_OBJECTS
        cmp     byte [BROWSE_MODE],0
        je      .L2
        call    find_cursor_location
        cmp     byte [BIG_CURSOR_MODE],1
        jne     .L1
        call    [plot_cursor_big]
        jmp     .L2
        .L1:
        call    [plot_cursor]
        .L2:
        cmp     byte [HILITE_MODE],0
        je      .L3
        call    HILITE_UNIT
        .L3:
        mov     byte [REDRAW_SCREEN_REQ],0
        .L4:
        cmp     byte [REDRAW_COORDS_REQ],1
        jne     .L5
        call    WRITE_COORDINATES
        mov     byte [REDRAW_COORDS_REQ],0
        .L5:
        cmp     byte [REDRAW_COMWIN_REQ],1
        jne     .L6
        call    DRAW_COMMAND_WINDOW
        mov     byte [REDRAW_COMWIN_REQ],0
        .L6:
        cmp     byte [REDRAW_STATUS_REQ],1
        jne     .L7
        call    DRAW_STATUS_WINDOW
        mov     byte [REDRAW_STATUS_REQ],0
        .L7:
        ret

HILITE_UNIT:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        mov     al,UNIT_LOCATION_X[di]
        sub     al,[MAP_OFFS_X]
        mov     [BROWSE_CURSOR_X],al
        mov     al,UNIT_LOCATION_Y[di]
        sub     al,[MAP_OFFS_Y]
        mov     [BROWSE_CURSOR_Y],al
        call    find_cursor_location
        cmp     byte [SELECTED_UNIT],20
        jae     .L5
        call    [plot_cursor]                   ; small cursor for 1-tile player units
        ret
        .L5:
        cmp     byte [SELECTED_UNIT],64
        jae     .L6
        call    [plot_cursor_big]               ; big cursor for 4-tile player buildings
        ret
        .L6:
        cmp     byte [SELECTED_UNIT],128
        jae     .L7
        call    [plot_cursor]                   ; small cursor for 1-tile enemy units
        ret
        .L7:
        push di
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     di,ax
        cmp     byte UNIT_TYPE[di],30           ; protoid sentry pod
        je      .L8
        cmp     byte UNIT_TYPE[di],34           ; protoid sentry pod construction
        je      .L8
        pop     di
        call    [plot_cursor_big]               ; big cursor for 4-tile enemy buildings
        ret
        .L8:
        pop     di
        call    [plot_cursor]                   ; small cursor for 1-tile enemy units
        ret


CYCLE_BUILDING_FORWARD:
        ; First check if we are over 63 (in THE ENEMY UNITS)
        mov     cl,0
        cmp     byte [SELECTED_UNIT],63
        jb      .L0
        mov     byte [SELECTED_UNIT],20
        jmp     .L5
        ; check if we are below 20 (a drivable unit)
        .L0:
        cmp     byte [SELECTED_UNIT],20
        jae     .L1
        mov     byte [SELECTED_UNIT],20
        .L1:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        .L2:
        cmp     si,63                   ; max building number
        jne     .L4
        cmp     cl,44                   ; max number of units to try
        je      .L3
        mov     si,20                   ; first building number
        jmp     .L5
        .L3:
        mov     si,INFO_NOFOUND
        call    WRITE_NEW_MESSAGE
        mov     al,0                    ; beep
        mov     ah,150                  ; priority
        call    m_playSFX               ; play sound
        ret
        .L4:
        inc     si
        inc     cl                      ; count how many units have we tried so far.
        .L5:
        cmp     byte UNIT_TYPE[si],0
        je      .L2
        cmp     byte UNIT_TYPE[si],23   ; skip solar panels
        je      .L2
        jmp     COMPLETE_UNIT_CHANGE

CYCLE_BUILDING_BACKWARD:
        ; First check if we are over 63 (in THE ENEMY UNITS)
        mov     cl,0
        cmp     byte [SELECTED_UNIT],63
        jb      .L0
        mov     byte [SELECTED_UNIT],63
        jmp     .L5
        ; check if we are below 20 (a drivable unit)
        .L0:
        cmp     byte [SELECTED_UNIT],20
        jae     .L1
        mov     byte [SELECTED_UNIT],63
        .L1:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        .L2:
        cmp     si,20                   ; first building number
        jne     .L4
        cmp     cl,44                   ; max number of units to try
        je      .L3
        mov     si,63                   ; max building number
        jmp     .L5
        .L3:
        mov     si,INFO_NOFOUND
        call    WRITE_NEW_MESSAGE
        mov     al,0                    ; beep
        mov     ah,150                  ; priority
        call    m_playSFX               ; play sound
        ret
        .L4:
        dec     si
        inc     cl                      ; count how many units have we tried so far.
        .L5:
        cmp     byte UNIT_TYPE[si],0
        je      .L2
        cmp     byte UNIT_TYPE[si],23   ; skip solar panels
        je      .L2
        jmp     COMPLETE_UNIT_CHANGE

CYCLE_UNIT_FORWARD:
        ; First check if we are over 19 (a building)
        mov     cl,0
        cmp     byte [SELECTED_UNIT],20
        jb      .L1
        mov     si,0
        jmp     .L5
        .L1:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        .L2:
        cmp     si,19                   ; max drivable unit number
        jne     .L4
        cmp     cl,20                   ; max number of units to try
        je      .L3
        mov     si,0
        jmp     .L5
        .L3:
        mov     si,INFO_NOFOUND
        call    WRITE_NEW_MESSAGE
        mov     al,0                    ; beep
        mov     ah,150                  ; priority
        call    m_playSFX               ; play sound
        ret
        .L4:
        inc     si
        inc     cl                      ; count how many units have we tried so far.
        .L5:
        cmp     byte UNIT_TYPE[si],0
        je      .L2
        jmp     COMPLETE_UNIT_CHANGE

CYCLE_UNIT_BACKWARD:
        ; First check if we are over 19 (a building)
        mov     cl,0
        cmp     byte [SELECTED_UNIT],20
        jb      .L1
        mov     si,19
        jmp     .L5
        .L1:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        .L2:
        cmp     si,0                    ; lowest drivable unit number
        jne     .L4
        cmp     cl,20                   ; max number of units to try
        je      .L3
        mov     si,19
        jmp     .L5
        .L3:
        mov     si,INFO_NOFOUND
        call    WRITE_NEW_MESSAGE
        mov     al,0                    ; beep
        mov     ah,150                  ; priority
        call    m_playSFX               ; play sound
        ret
        .L4:
        dec     si
        inc     cl                      ; count how many units have we tried so far.
        .L5:
        cmp     byte UNIT_TYPE[si],0
        je      .L2
        jmp     COMPLETE_UNIT_CHANGE

COMPLETE_UNIT_CHANGE:
        mov     ax,si
        mov     [SELECTED_UNIT],al
        mov     byte [HILITE_MODE],5
        call    FIND_MAP_OFFSET
        call    WRITE_COORDINATES
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        call    DRAW_ENTIRE_SCREEN
        call    DRAW_FLYING_OBJECTS
        mov     al,13                   ; beep
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound
        ret

ADJUST_CO_FOR_BUILDING:
        ; This routine checks to see if the map location in question
        ; is part of a 4-tile structure.  if so, it re-adjusts the
        ; CHECK_X and CHECK_Y accordingly
        mov     al,[CHECK_X]
        mov     ah,[CHECK_Y]
        mov     si,ax
        GET_MAP_BYTE    si              ; get tile
        mov     ah,0
        mov     si,ax
        mov     al,TILEATTRIB[si]       ; get attributes of tile
        mov     [TEMP_A],al
        and     al,01000000B
        cmp     al,01000000B
        jne     ACFB01
        dec     byte [CHECK_X]
        ACFB01:
        mov     al,[TEMP_A]
        and     al,10000000B
        cmp     al,10000000B
        jne     ACFB02
        dec     byte [CHECK_Y]
        ACFB02:
        ret

BROWSE_FOR_UNIT:
        call    START_BROWSE_MODE
        cmp     byte [BROWSE_CANCEL],1
        jne     .L0
        mov     byte [REDRAW_STATUS_REQ],1
        ret
        .L0:
        mov     al,[MAP_OFFS_X]
        add     al,[BROWSE_CURSOR_X]
        mov     [CHECK_X],al
        mov     al,[MAP_OFFS_Y]
        add     al,[BROWSE_CURSOR_Y]
        mov     [CHECK_Y],al
        call    ADJUST_CO_FOR_BUILDING
        call    CHECK_FOR_UNIT_AT_XY
        cmp     byte [CHECK_XY_RESULT],0
        je      BFU01
        mov     al,[CHECK_XY_UNIT]
        mov     [SELECTED_UNIT],al
        mov     byte [HILITE_MODE],6
        call    FIND_MAP_OFFSET
        call    DRAW_ENTIRE_SCREEN
        call    DRAW_FLYING_OBJECTS
        call    WRITE_COORDINATES
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        mov     al,13                           ; beep
        mov     ah,128                          ; priority
        call    m_playSFX                       ; play sound
        ret
        BFU01:
        cmp     byte [SELECTED_UNIT],19
        jbe     BFU02
        ret
        BFU02:
        ; Check to see if unit is busy
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0
        je      BFU00
        ret
        BFU00:
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,[CHECK_X]
        mov     UNIT_DEST_X[si],al
        mov     al,[CHECK_Y]
        mov     UNIT_DEST_Y[si],al
        mov     byte UNIT_ALTMOVE_X[si],0
        mov     byte UNIT_ALTMOVE_Y[si],0
        mov     byte UNIT_AI[si],5              ; traveller AI
        mov     byte UNIT_TIMER[si],7
        mov     byte UNIT_GEN_A[si],0           ; AI once reached destination
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret


MOVEDOWN:
        ; Check that it is a movable unit:
        cmp     byte [SELECTED_UNIT],20
        jb      MDW07
        ret
        MDW07:
        ; Check to see if unit is busy
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0
        je      MDW08
        ret
        MDW08:
        ; Check that unit is stil alive:
        cmp     byte UNIT_TYPE[si],0
        jne     MDW09
        ret
        MDW09:
        mov     al,[SELECTED_UNIT]
        mov     [UNIT_SCAN],al
        cmp     byte [MUSIC_ON],1       ; only play movement sound if music is off
        je      .L9
        mov     al,17                   ; Movement sound
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L9:
        call    AI_MOVEDOWN
        ret

MOVEUP:
        ; Check that it is a movable unit:
        cmp     byte [SELECTED_UNIT],20
        jb      MUP07
        ret
        MUP07:
        ; Check to see if unit is busy
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0
        je      MUP08
        ret
        MUP08:
        ; Check that unit is stil alive:
        cmp     byte UNIT_TYPE[si],0
        jne     MUP09
        ret
        MUP09:
        mov     al,[SELECTED_UNIT]
        mov     [UNIT_SCAN],al
        cmp     byte [MUSIC_ON],1       ; only play movement sound if music is off
        je      .L9
        mov     al,17                   ; Movement sound
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L9:
        call    AI_MOVEUP
        ret

MOVERIGHT:
        ; Check that it is a movable unit:
        cmp     byte [SELECTED_UNIT],20
        jb      MRT07
        ret
        MRT07:
        ; Check to see if unit is busy
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0
        je      MRT08
        ret
        MRT08:
        ; Check that unit is stil alive:
        cmp     byte UNIT_TYPE[si],0
        jne     MRT09
        ret
        MRT09:
        mov     al,[SELECTED_UNIT]
        mov     [UNIT_SCAN],al
        cmp     byte [MUSIC_ON],1       ; only play movement sound if music is off
        je      .L9
        mov     al,17                   ; Movement sound
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L9:
        call    AI_MOVERIGHT
        ret

MOVELEFT:
        ; Check that it is a movable unit:
        cmp     byte [SELECTED_UNIT],20
        jb      MLF07
        ret
        MLF07:
        ; Check to see if unit is busy
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_AI[si],0
        je      MLF08
        ret
        MLF08:
        ; Check that unit is stil alive:
        cmp     byte UNIT_TYPE[si],0
        jne     MLF09
        ret
        MLF09:
        ; Check for bounary of map first.
        mov     al,[SELECTED_UNIT]
        mov     [UNIT_SCAN],al
        cmp     byte [MUSIC_ON],1       ; only play movement sound if music is off
        je      .L9
        mov     al,17                   ; Movement sound
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L9:
        call    AI_MOVELEFT
        ret

ERASE_UNIT_FROM_MAP:
        mov     bh,UNIT_LOCATION_Y[si]
        mov     bl,UNIT_LOCATION_X[si]
        mov     di,bx
        mov     al,UNIT_TILE_UNDER[si]
        SET_MAP_BYTE    di,al
        ret

PLOT_UNIT_ON_MAP:
        mov     cl,UNIT_TYPE[si]
        cmp     cl,5                    ; is it a clone?
        je      .L7
        cmp     cl,6                    ; is it an adv clone?
        je      .L7
        cmp     cl,7                    ; IS IT AN Protoid Tank?
        je      .L7
        jmp     .L5
        .L5:
        ; standard unit
        mov     bh,UNIT_LOCATION_Y[si]
        mov     bl,UNIT_LOCATION_X[si]
        mov     di,bx
        GET_MAP_BYTE    di
        mov     UNIT_TILE_UNDER[si],al
        mov     al,UNIT_TILE[si]
        SET_MAP_BYTE    di,al
        ret
        .L7:
        ; possible swimmer
        mov     bh,UNIT_LOCATION_Y[si]
        mov     bl,UNIT_LOCATION_X[si]
        mov     di,bx
        GET_MAP_BYTE    di
        cmp     al,24                   ; water
        je      .L9
        cmp     al,25                   ; water
        je      .L9
        cmp     al,26                   ; water
        je      .L9
        jmp     .L10
        .L9:
        mov     UNIT_TILE_UNDER[si],al
        mov     al,UNIT_TILE[si]
        mov     ch,0
        mov     si,cx
        add     al,UNIT_SWIM[si]        ; change tile for swimmer
        jmp     .L11
        .L10:
        mov     UNIT_TILE_UNDER[si],al
        mov     al,UNIT_TILE[si]
        .L11:
        SET_MAP_BYTE    di,al
        ret

RANDOM_NUMBER_GENERATOR:
        ; generates random number using the system timer, leaves a
        ; 16-bit result in ax.
        mov     al,00000110b            ; Channel 0, Latch Counter, Square Wave, Binary
        out     43h,al                  ; Tell timer about it
        in      al,40h                  ; Get LSB of timer counter
        mov     ah,al                   ; Save it in ah for a second
        in      al,40h                  ; Get MSB of timer counter
        xchg    ah,al                   ; Put things in the right order
        ret

; The following routine looks at temporary variable TEMP_A to see what item
; is requesting to be built, checks if resources are available, reduces inventory
; if so, sends an error to the user if not, and returns a result
; in TEMP_A 0=failed 1=success.

CHECK_RESOURCES:
        ; check if enough minerals
        mov     al,[TEMP_A]
        mov     ah,0
        mov     si,ax
        mov     al,COST_MIN[si]
        cmp     [QTY_MINERALS],al
        jae     .L1
        jmp     RESOURCE_INSUF
        .L1:
        ; check if enough gas
        mov     al,COST_GAS[si]
        cmp     [QTY_GAS],al
        jae     .L2
        jmp     RESOURCE_INSUF
        .L2:
        ; check if enough energy
        mov     al,COST_NRG[si]
        cmp     [QTY_ENERGY],al
        jae     .L3
        jmp     RESOURCE_INSUF
        .L3:
        ; reduce mineral count
        mov     al,COST_MIN[si]
        sub     [QTY_MINERALS],al
        ; reduce gas count
        mov     al,COST_GAS[si]
        sub     [QTY_GAS],al
        ; reduce energy count
        mov     al,COST_NRG[si]
        sub     [QTY_ENERGY],al
        call    WRITE_RESOURCES
        mov     byte [TEMP_A],1         ; success
        ret
        RESOURCE_INSUF:
        ; create error message showing required minerals
        mov     al,COST_MIN[si]
        mov     [HEXNUM],al
        mov     di,INFO_RESOURCES2+9
        push    si
        call    INSERT_DECNUM
        pop     si
        mov     al,COST_GAS[si]
        mov     [HEXNUM],al
        mov     di,INFO_RESOURCES3+9
        push    si
        call    INSERT_DECNUM
        pop     si
        mov     al,COST_NRG[si]
        mov     [HEXNUM],al
        mov     di,INFO_RESOURCES4+9
        push    si
        call    INSERT_DECNUM
        pop     si
        mov     si,INFO_RESOURCES1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_RESOURCES2
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_RESOURCES3
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_RESOURCES4
        call    WRITE_NEW_MESSAGE
        mov     byte [TEMP_A],0         ; failed
        mov     al,01                   ; error beep
        mov     ah,175                  ; priority
        call    m_playSFX               ; play sound
        ret

; unit numbering scheme
;-----------------------
; 0-19    = tanks/builders
; 20-63   = player buildings
; 64-127  = enemy warriors
; 128-195 = enemy buildings
; 196-211 = projectiles/explosions

; list of unit types
;--------------------
; 01-builder
; 02-tank
; 03-heavy tank (assault mode)
; 04-frigate
; 05-protoid humanoid
; 20-headquarters
; 21-radar station
; 22-power station
; 23-solar panel
; 24-gas refinery
; 25-factory
; 26-missile silo
; 27-smelter
; 28-projectile
; 29-explosion (small)
; 30-alien sentry pod
; 31-nuclear missile
; 32-heavy tank (sentry mode)
; 33-pyradmid base
; 34-sentry construction
; 35-protoid building construction
; 36-protoid clone facility
; 37-protoid academy
; 38-protoid factory
; 39-protoid something else


; list of ai types:
;-------------------
; 1=power station
; 2=solar panel
; 3=missile silo arming
; 4=headquarters
; 5=traveller type 1 (to exact dest)
; 6=factory making a builder
; 7=factory making a tank
; 8=smelter searching for minerals
; 9=smelter refining minerals
; 10=gas refinery
; 11=projectile
; 12=explosion (small)
; 13=traveller type 2 (to 1-tile next door)
; 14=builder constructing a building (gen-b contains building type)
; 15=builder pickup automatic
; 16=builder drop off automatic
; 17=builder bulldoze
; 18=alien sentry pod
; 19=tank self destruct
; 20=explosion (large)
; 21=nuclear missile falling
; 22=factory making a heavy tank
; 23=heavy tank (sentry mode)
; 24=factory making a frigate
; 25=builder building a wall
; 26=builder building a bridge
; 27=heavy tank converting to sentry mode
; 28=heavy tank converting to assault mode
; 29=pyramid base
; 30=sentry construction
; 31=protoid building construction
; 32-protoid clone facility
; 33-protoid academy
; 34-protoid factory
; 35-protoid something else
; 38-tank weapon recharge
