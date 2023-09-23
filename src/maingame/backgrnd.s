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

BACKGROUND_ROUTINE:
        mov     byte [cs:BG_TIMER_MAIN],0       ; reset timer
        call    UPDATE_CLOCK
        call    UNIT_COUNT
        call    UPDATE_INFO_WINDOW
        mov     byte [UNIT_SCAN],0
        ; FIRST, scan all units and see if their AI timer
        ; has hit zero, run AI routines as needed.
        .L10:
        mov     si,[UNIT_SCAN]
        cmp     byte UNIT_TYPE[si],0            ; check if unit exists..
        je      .L20
        cmp     byte UNIT_AI[si],0              ; check if AI routine is assigned
        je      .L20                            ; skip to next if not.
        dec     byte UNIT_TIMER[si]             ; ZERO = Time to run AI routine
        jnz     .L20
        ; dispatch AI call via jump table
        xor     bx,bx
        mov     bl,UNIT_AI[si]
        dec     bl
        cmp     bl,40                           ; bounds check
        ja      .L20
        shl     bx,1
        call    [bx+.jtab]
        .L20:
        inc     byte [UNIT_SCAN]
        cmp     byte [UNIT_SCAN],212            ; end of all unit numbers
        jne     .L10
        ; next turn off hilite mode if it is on
        cmp     byte [HILITE_MODE],0
        je      .end
        dec     byte [HILITE_MODE]
        test    byte [HILITE_MODE],1
        jnz     .L26
        tcall   UNHILITE_UNIT                   ; tail call
        .L26:
        tcall   HILITE_UNIT                     ; tail call
.end:   ret

.jtab   dw      AI_POWER_STATION
        dw      AI_SOLAR_PANEL
        dw      AI_BUILD_MISSILE
        dw      AI_HEADQUARTERS
        dw      AI_TRAVELLER
        dw      AI_BUILD_BUILDER
        dw      AI_BUILD_TANK
        dw      AI_SMELTER_SEARCHING
        dw      AI_SMELTER_REFINING
        dw      AI_GAS_REFINERY
        dw      AI_PROJECTILE
        dw      AI_SMALL_EXPLOSION_CLEANUP
        dw      AI_TRAVELLER
        dw      AI_CONSTRUCTION
        dw      AI_BUILDER_PICKUP
        dw      AI_BUILDER_DROPOFF
        dw      AI_BUILDER_BULLDOZE
        dw      AI_SENTRY_POD
        dw      AI_TANK_SELF_DESTRUCT
        dw      AI_LARGE_EXPLOSION
        dw      AI_NUCLEAR_MISSILE
        dw      AI_BUILD_HEAVY_TANK
        dw      AI_SENTRY_TANK
        dw      AI_BUILD_FRIGATE
        dw      AI_BUILD_WALL
        dw      AI_BUILD_BRIDGE
        dw      AI_CONVERT_TO_SENTRY
        dw      AI_CONVERT_TO_ASSAULT
        dw      AI_PYRAMID
        dw      AI_SENTRY_CONST
        dw      AI_PROT_CONST
        dw      AI_PROT_CLONE
        dw      AI_PROT_ACADEMY
        dw      AI_PROT_FACTORY
        dw      AI_PROT_SOMETHING
        dw      AI_CLONE
        dw      AI_CLONE_ADV
        dw      AI_WEAPON_RECHARGE
        dw      AI_PROT_TANK
        dw      AI_BUILD_FIGHTER
        dw      AI_BUILD_SCOUT

UPDATE_INFO_WINDOW:
        cmp     byte [INFO_TIMER2],5
        je      .L1
        dec     byte [INFO_TIMER1]
        jnz     .L1
        mov     si,INFO_BLANK
        call    WRITE_NEW_MESSAGE
        mov     byte [INFO_TIMER1],8
        inc     byte [INFO_TIMER2]
        .L1:
        ret

; The following routine counts up all of the active units and stores them
; in the appropriate variables.

UNIT_COUNT:
        dec     byte [UNIT_COUNT_TIMER]
        jz      .L0
        ret
        .L0:
        mov     byte [UNIT_COUNT_TIMER],128
        ; find number of player units
        mov     si,0
        mov     al,0
        .L1:
        cmp     byte UNIT_TYPE[si],0
        je      .L2
        inc     al
        .L2:
        inc     si
        cmp     si,20
        jne     .L1
        mov     [UNIT_COUNT_PLUNITS],al
        ; find number of buildings
        mov     si,20
        mov     al,0
        .L3:
        cmp     byte UNIT_TYPE[si],0
        je      .L4
        inc     al
        .L4:
        inc     si
        cmp     si,64                           ; max buildings
        jne     .L3
        mov     [UNIT_COUNT_PLBLDG],al
        ; find number of enemy warriors
        mov     si,64
        mov     al,0
        .L5:
        cmp     byte UNIT_TYPE[si],0
        je      .L6
        inc     al
        .L6:
        inc     si
        cmp     si,128
        jne     .L5
        mov     [UNIT_COUNT_ENUNITS],al
        ; find number of enemy buildings
        mov     si,128
        mov     al,0
        .L7:
        cmp     byte UNIT_TYPE[si],0
        je      .L8
        inc     al
        .L8:
        inc     si
        cmp     si,196
        jne     .L7
        mov     [UNIT_COUNT_ENBLDG],al
        ; update status if needed.
        mov     al,[SELECTED_UNIT]
        mov     ah,0
        mov     si,ax
        cmp     byte UNIT_TYPE[si],20           ; headquarters
        jne     .L15
        mov     byte [REDRAW_STATUS_REQ],1
        .L15:
        ; check for game-over scenario
        cmp     byte [UNIT_COUNT_ENBLDG],0
        je      .L20
        cmp     byte [UNIT_COUNT_PLBLDG],0
        je      .L20
        ret
        .L20:
        mov     byte [END_GAME_DETECTED],1
        ret

; The following routine counts down a tank's weapon recharge time
; which is stored in UNIT_GEN_C.

AI_WEAPON_RECHARGE:
        mov     byte UNIT_AI[si],0              ; end this process
        mov     byte UNIT_GEN_C[si],0
        ret

AI_CLONE:
        call    LOCAL_SEARCH
        ; allow walk on water
        mov     byte [TILEATTRIB+24],1          ; water
        mov     byte [TILEATTRIB+25],1          ; water
        mov     byte [TILEATTRIB+26],1          ; water
        call    AI_TRAVELLER
        ; remove walk on water
        mov     byte [TILEATTRIB+24],0          ; water
        mov     byte [TILEATTRIB+25],0          ; water
        mov     byte [TILEATTRIB+26],0          ; water
        ; check if unit is on water, reduce speed if so.
        mov     si,[UNIT_SCAN]
        mov     byte UNIT_TIMER[si],10          ; normal delay
        cmp     byte UNIT_TILE_UNDER[si],24     ; water
        je      .L2
        cmp     byte UNIT_TILE_UNDER[si],25     ; water
        je      .L2
        cmp     byte UNIT_TILE_UNDER[si],26     ; water
        je      .L2
        jmp     .L3
        .L2:
        mov     byte UNIT_TIMER[si],50          ; moves slower in water
        .L3:
        call    CHECK_DIST
        call    CHECK_DEST
        call    AI_ATTACK_CLOSE
        ret

AI_PROT_TANK:
        call    LOCAL_SEARCH
        ; allow walk on water
        mov     byte [TILEATTRIB+24],1          ; water
        mov     byte [TILEATTRIB+25],1          ; water
        mov     byte [TILEATTRIB+26],1          ; water
        call    AI_TRAVELLER
        ; remove walk on water
        mov     byte [TILEATTRIB+24],0          ; water
        mov     byte [TILEATTRIB+25],0          ; water
        mov     byte [TILEATTRIB+26],0          ; water
        ; check if unit is on water, reduce speed if so.
        mov     si,[UNIT_SCAN]
        mov     byte UNIT_TIMER[si],10          ; normal delay
        cmp     byte UNIT_TILE_UNDER[si],24     ; water
        je      .L2
        cmp     byte UNIT_TILE_UNDER[si],25     ; water
        je      .L2
        cmp     byte UNIT_TILE_UNDER[si],26     ; water
        je      .L2
        jmp     .L3
        .L2:
        mov     byte UNIT_TIMER[si],30          ; moves slower in water
        .L3:
        call    CHECK_DIST
        call    CHECK_DEST
        mov     byte [TEMP_B],5                 ; attack range
        call    ATTACK_FAR
        call    AI_PROT_TANK_BULLDOZE
        ret

AI_PROT_TANK_BULLDOZE:
        mov     si,[UNIT_SCAN]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     al,UNIT_LOCATION_X[si]
        mov     di,ax                   ; find map tile for current position
        ; first figure out if we are moving up, down, or none.
        mov     al,UNIT_LOCATION_Y[si]
        mov     bl,UNIT_DEST_Y[si]
        cmp     al,bl
        je      .L10                    ; if equal, skip this section:
        jb      .L05
        sub     di,256                  ; move up
        jmp     .L10
        .L05:
        add     di,256                  ; move down

        ; next figure out if we are moving left, right, or none.
        .L10:
        mov     al,UNIT_LOCATION_X[si]
        mov     bl,UNIT_DEST_X[si]
        cmp     al,bl
        je      .L20                    ; if equal, skip this section:
        jb      .L11
        dec     di                      ; move left
        jmp     .L20
        .L11:
        inc     di                      ; move right

        ; now get the tile
        .L20:
        GET_MAP_BYTE    di

        ; now find the attributes of this tile
        mov     ah,0
        mov     si,ax
        mov     al,TILEATTRIB[si]

        ; now see if it can be driven on
        mov     bl,al
        and     bl,1
        cmp     bl,1                    ; can drive on it?
        jne     .L30
        ret                             ; if so, abort this whole process.

        ; now see if it can be destroyed
        .L30:
        mov     bl,al
        and     bl,8                    ; can be destroyed?
        cmp     bl,8
        je      .L31
        ret                             ; if not, abort this whole process.

        ; bulldoze tile
        .L31:
        SET_MAP_BYTE    di,34           ; dirt
        ; create explosion AI unit
        mov     si,196                  ; start of projectile units
        .L40:
        cmp     byte UNIT_TYPE[si],0    ; does it exist
        je      .L41
        inc     si
        cmp     si,212                  ; max unit number
        jne     .L40
        ret                             ; no free slots found, abort
        .L41:
        mov     byte UNIT_TYPE[si],29   ; small explosion
        mov     byte UNIT_AI[si],12     ; small explosion ai
        mov     ax,di
        mov     UNIT_LOCATION_X[si],al
        mov     UNIT_LOCATION_Y[si],ah
        mov     byte UNIT_TIMER[si],2
        mov     byte UNIT_TILE[si],0a0h ; small explosion tile
        mov     byte UNIT_TILE_UNDER[si], 34    ; dirt
        mov     al,[UNIT_SCAN]
        mov     ah,0
        mov     si,ax
        mov     byte UNIT_TIMER[si],100 ; slow down after shooting
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        je      .L42
        ret
        .L42:
        mov     al,04                   ; shooting sound
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound
        ret


AI_CLONE_ADV:
        call    LOCAL_SEARCH
        ; allow walk on water
        mov     byte [TILEATTRIB+24],1          ; water
        mov     byte [TILEATTRIB+25],1          ; water
        mov     byte [TILEATTRIB+26],1          ; water
        call    AI_TRAVELLER
        ; remove walk on water
        mov     byte [TILEATTRIB+24],0          ; water
        mov     byte [TILEATTRIB+25],0          ; water
        mov     byte [TILEATTRIB+26],0          ; water
        ; check if unit is on water, reduce speed if so.
        mov     si,[UNIT_SCAN]
        mov     byte UNIT_TIMER[si],7           ; normal delay
        cmp     byte UNIT_TILE_UNDER[si],24     ; water
        je      .L2
        cmp     byte UNIT_TILE_UNDER[si],25     ; water
        je      .L2
        cmp     byte UNIT_TILE_UNDER[si],26     ; water
        je      .L2
        jmp     .L3
        .L2:
        mov     byte UNIT_TIMER[si],50          ; moves slower in water
        .L3:
        call    CHECK_DIST
        call    CHECK_DEST
        mov     byte [TEMP_B],3                 ; attack range
        call    ATTACK_FAR
        ret

; The following routine checks to see how many steps the protoid has taken
; since it last changed destination.  If it is too many (probably stuck) then
; it will change to new destination.

CHECK_DIST:
        inc     byte UNIT_GEN_C[si]
        cmp     byte UNIT_GEN_C[si],200 ; max number of movements
        jne     .L5
        mov     byte UNIT_GEN_C[si],0   ; set destination to current location
        mov     al,UNIT_LOCATION_X[si]  ; so that next cycle it will reset.
        mov     UNIT_DEST_X[si],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     UNIT_DEST_Y[si],al
        .L5:
        ret

; The following routine checks to see if the destination has been reached.

CHECK_DEST:
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,UNIT_DEST_X[si]
        jne     .end
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,UNIT_DEST_Y[si]
        jne     .end
        .L6:
        ; looks like we've arrived, better find a new destination
        ; find a random building that's active between 20 and 63.
        call    RANDOM_NUMBER_GENERATOR
        and     ax,63                   ; make sure the number is less than 64
        cmp     al,20                   ; make sure the number is more than 19
        jb      .L6
        mov     di,ax
        .L7:
        cmp     byte UNIT_TYPE[di],0    ; check if building number exists.
        jne     .L8
        inc     di
        cmp     di,64                   ; end of human units
        jne     .L7
        ; odd.. we should never get here unless all humans buildings are gone.
        ret
        .L8:
        mov     al,UNIT_LOCATION_X[di]
        mov     UNIT_DEST_X[si],al
        mov     al,UNIT_LOCATION_Y[di]
        mov     UNIT_DEST_Y[si],al
        mov     byte UNIT_GEN_C[si],0   ; reset movement counter.
.end:   ret

; The following routine figures out if there are any player units or
; buildings within a 5 tile radius, and if it finds something, it will
; re-adjust the destination to that location.

LOCAL_SEARCH:
        mov     di,0                    ; start of player units
        .L05:
        cmp     byte UNIT_TYPE[di],0
        jne     .L10
        .L06:
        inc     di
        cmp     di,64                   ; end of player units
        jne     .L05
        ret                             ; none found, return
        .L10:
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,0
        sub     al,UNIT_LOCATION_X[di]
        jns     .L1
        neg     ax
        .L1:                            ; check distance positive x
        cmp     al,5                    ; is it more than 5 tiles away?
        ja      .L06
        mov     al,UNIT_LOCATION_Y[si]
        mov     ah,0
        sub     al,UNIT_LOCATION_Y[di]
        jns     .L2
        neg     ax
        .L2:                            ; check distance positive y
        cmp     al,4                    ; is it more than 4 tiles away?
        ja      .L06
        ; apparently we found something, let's change course.
        mov     al,UNIT_LOCATION_X[di]
        mov     UNIT_DEST_X[si],al
        mov     al,UNIT_LOCATION_Y[di]
        mov     UNIT_DEST_Y[si],al
        ret

; The following routine scans to see if any player units are within
; 1-tile distance of a protoid unit, and if so it will attack it.

AI_ATTACK_CLOSE:
        cmp     byte UNIT_GEN_B[si],0   ; can we attack again yet?
        je      .L2
        dec     byte UNIT_GEN_B[si]
        ret
        .L2:
        mov     di,0                    ; start of player units
        .L05:
        cmp     byte UNIT_TYPE[di],0
        jne     .L10
        .L06:
        inc     di
        cmp     di,64                   ; end of player units
        jne     .L05
        ret                             ; none found, return
        .L10:
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,0
        sub     al,UNIT_LOCATION_X[di]
        jns     .L1
        neg     ax
        .L1:                            ; check distance positive x
        cmp     al,1                    ; is it more than 1 tile away?
        ja      .L06
        mov     al,UNIT_LOCATION_Y[si]
        mov     ah,0
        sub     al,UNIT_LOCATION_Y[di]
        jns     .L2a
        neg     ax
        .L2a:                           ; check distance positive y
        cmp     al,1                    ; is it more than 1 tile away?
        ja      .L06
        ; apparently we found something, let's attack it!
        mov     byte UNIT_GEN_B[si],10  ; reset attack delay
        mov     si,196                  ; start of projectiles/explosions
        .L14:
        cmp     byte UNIT_TYPE[si],0
        je      .L15
        inc     si
        cmp     si,212                  ; end of projectiles
        jne     .L14
        ret                             ; apparently out of explosion slots at the moment.
        .L15:
        mov     byte UNIT_GEN_A[si],5   ; damage
        mov     byte UNIT_TYPE[si],29   ; explosion(small) unit type
        mov     byte UNIT_AI[si],12     ; explosion(small) AI type
        mov     byte UNIT_TIMER[si],2   ; set dela
        mov     byte UNIT_TILE[si],0a0h ; set tile
        mov     al,UNIT_LOCATION_X[di]  ; set location
        mov     UNIT_LOCATION_X[si],al
        mov     al,UNIT_LOCATION_Y[di]
        mov     UNIT_LOCATION_Y[si],al
        mov     ax,di
        mov     [CHECK_XY_UNIT],al      ; define unit to attack
        call    DRAW_FLYING_OBJECTS
        jmp     ATTACK_UNIT             ; tail call
        ret

ATTACK_FAR:
        cmp     byte UNIT_GEN_B[si],0   ; can we attack again yet?
        je      .L2
        dec     byte UNIT_GEN_B[si]
        ret
        .L2:
        ; start scanning for player units (0-63) to attack
        mov     di,0
        .L05:
        cmp     byte UNIT_TYPE[di],0
        jne     .L10
        .L06:
        inc     di
        cmp     di,64
        jne     .L05
        ret
        .L10:
        mov     al,UNIT_LOCATION_X[di]
        mov     UNIT_DEST_X[si],al
        mov     al,UNIT_LOCATION_Y[di]
        mov     UNIT_DEST_Y[si],al
        call    CHECK_DISTANCE_TO_DESTINATION
        mov     bl,[TEMP_B]             ; get search range
        cmp     [TEMP_X],bl             ; distance
        ja      .L06
        cmp     [TEMP_Y],bl             ; distance
        ja      .L06
        mov     byte UNIT_GEN_B[si],10  ; reset attack delay
        mov     ax,di
        mov     [TEMP_A],al
        ; find new projectile unit number
        mov     di,196
        .L15:
        mov     al,UNIT_TYPE[di]
        cmp     al,0
        je      .L20
        inc     di
        cmp     di,212
        jne     .L15
        ret                             ; failure to find free projectile unit
        .L20:
        ; set information for projectile
        mov     byte UNIT_TYPE[di],28   ; projectile unit type
        mov     byte UNIT_AI[di],11     ; projectile ai
        mov     byte UNIT_GEN_A[di],10  ; damage
        mov     al,[TEMP_A]
        mov     UNIT_GEN_B[di],al       ; fire at unit#
        mov     byte UNIT_TILE[di],0b7h ; blue projectile tile
        mov     byte UNIT_TIMER[di],2
        mov     al,UNIT_LOCATION_X[si]
        mov     UNIT_LOCATION_X[di],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     UNIT_LOCATION_Y[di],al
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        jne     .L21
        mov     al,04                   ; shooting sound
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound
        .L21:
        ret

AI_PROT_CLONE:
        ; first check if pyramid has been destroyed, if so rebuild.
        mov     byte UNIT_TIMER[si],255
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        add     ah,3                    ; Locate 3 tiles SOUTH OF CLONE FACILITY
        call    AI_CHECK_PYRAMID
        dec     byte UNIT_GEN_B[si]
        cmp     byte UNIT_GEN_B[si],0
        jne     .L2
        mov     byte UNIT_GEN_B[si],2   ; delay for creating more clones.
        mov     byte [TEMP_A],5         ; unit type
        mov     byte [TEMP_B],40        ; health
        mov     byte [TEMP_C],36        ; AI type
        call    SPAWN_WALKER1
        .L2:
        ret

AI_PROT_ACADEMY:
        ; first check if pyramid has been destroyed, if so rebuild.
        mov     byte UNIT_TIMER[si],255
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        sub     al,3                    ; Locate 3 tiles WEST OF THE ACADEMY
        call    AI_CHECK_PYRAMID
        cmp     byte [GAME_DIFF],2      ; if playing in hard mode, skip the delay!
        je      .L1
        dec     byte UNIT_GEN_B[si]
        cmp     byte UNIT_GEN_B[si],0
        jne     .L2
        mov     byte UNIT_GEN_B[si],2   ; delay for creating more clones.
        .L1:
        mov     byte [TEMP_A],6         ; unit type
        mov     byte [TEMP_B],60        ; health
        mov     byte [TEMP_C],37        ; AI type
        call    SPAWN_WALKER1
        .L2:
        ret

AI_PROT_FACTORY:
        ; first check if pyramid has been destroyed, if so rebuild.
        mov     byte UNIT_TIMER[si],255
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        sub     ah,3                    ; Locate 3 tiles NORTH OF THE FACTORY
        call    AI_CHECK_PYRAMID
        dec     byte UNIT_GEN_B[si]
        cmp     byte UNIT_GEN_B[si],0
        jne     .L2
        mov     byte UNIT_GEN_B[si],20  ; delay for creating more tanks
        mov     byte [TEMP_A],7         ; UNIT TYPE (protoid tank)
        mov     byte [TEMP_B],150       ; health
        mov     byte [TEMP_C],39        ; AI type (protoid tank)
        call    SPAWN_WALKER1
        .L2:
        ret

AI_PROT_SOMETHING:
        ; first check if pyramid has been destroyed, if so rebuild.
        mov     byte UNIT_TIMER[si],255
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        add     al,3                    ; Locate 3 tiles EAST OF THE SOMETHING
        call    AI_CHECK_PYRAMID
        ret

AI_PYRAMID:
        mov     byte UNIT_TIMER[si],255
        call    AI_PYRAMID_SENTRY_SCAN
        mov     al,60
        mov     ah,0
        mul     byte [cs:GAME_CLOCK_HOURS]
        mov     cx,ax
        add     cl,byte [cs:GAME_CLOCK_MINUTES] ; calculate total minutes of gameplay
        adc     ch,0                            ; BUG in converted code: This was "add cx,byte [...]"
        mov     ax,7                            ; seven minute mark (for easy level)
        sub     al,[GAME_DIFF]                  ; remove a minute for each difficulty level.
        cmp     cX,ax
        jae     .L4
        ret
        .L4:
        call    AI_CHECK_CLONE
        mov     ax,10                   ; ten minute mark (for easy level)
        sub     al,[GAME_DIFF]          ; remove a minute for each difficulty level.
        cmp     cx,ax
        jae     .L5
        ret
        .L5:
        call    AI_CHECK_ACADEMY
        mov     ax,17                   ; fifteen minute mark (for easy level)
        sub     al,[GAME_DIFF]          ; remove a minute for each difficulty level.
        cmp     cx,ax
        jae     .L6
        ret
        .L6:
        call    AI_CHECK_FACTORY
        call    AI_CHECK_SOMEBUILD
        ret

AI_CHECK_PYRAMID:
        ; Test for and Build the PYRAMID if it is not there.
        mov     di,ax
        mov     bx,ax
        GET_MAP_BYTE    di
        cmp     al,0cch                 ; Is it A PYRAMID?
        je      .L15
        cmp     al,088h                 ; Is it a construction zone?
        je      .L15
        ; nothing there, let's build one.
        mov     di,128                  ; Start of enemy buildings
        .L6:
        cmp     byte UNIT_TYPE[di],0
        je      .L7
        inc     di
        cmp     di,196                  ; End of enemy buildings
        jne     .L6
        ret
        .L7:
        mov     byte UNIT_TYPE[di],35   ; protoid building construction unit type
        mov     byte UNIT_AI[di],31     ; protoid building construction AI
        mov     UNIT_LOCATION_X[di],bl
        mov     UNIT_LOCATION_Y[di],bh
        mov     byte UNIT_TIMER[di],1
        mov     byte UNIT_TILE[di],088h ; Construction tile
        mov     byte UNIT_GEN_A[di],0
        mov     byte UNIT_GEN_B[di],0   ; create a PYRAMID
        mov     byte UNIT_GEN_C[di],0
        mov     byte UNIT_HEALTH[di],200
        .L15:
        ret

AI_CHECK_CLONE:
        ; Test for and Build the clone facility if it is not there
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        sub     ah,3                    ; Locate 3 tiles north of pyramid
        mov     di,ax
        mov     bx,ax
        GET_MAP_BYTE    di
        cmp     al,0b8h                 ; Is it clone facility?
        je      .L15
        cmp     al,088h                 ; Is it a construction zone?
        je      .L15
        ; nothing there, let's build one.
        mov     di,128                  ; Start of enemy buildings
        .L6:
        cmp     byte UNIT_TYPE[di],0
        je      .L7
        inc     di
        cmp     di,196                  ; End of enemy buildings
        jne     .L6
        ret
        .L7:
        mov     byte UNIT_TYPE[di],35   ; protoid building construction unit type
        mov     byte UNIT_AI[di],31     ; protoid building construction AI
        mov     UNIT_LOCATION_X[di],bl
        mov     UNIT_LOCATION_Y[di],bh
        mov     byte UNIT_TIMER[di],1
        mov     byte UNIT_TILE[di],088h ; Construction tile
        mov     byte UNIT_GEN_A[di],0
        mov     byte UNIT_GEN_B[di],1   ; create an clone facility
        mov     byte UNIT_GEN_C[di],0
        mov     byte UNIT_HEALTH[di],150
        .L15:
        ret

AI_CHECK_ACADEMY:
        ; Test for and Build the ACADEMY if it is not there.
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        add     al,3                    ; Locate 3 tiles EAST of pyramid
        mov     di,ax
        mov     bx,ax
        GET_MAP_BYTE    di
        cmp     al,0ceh                 ; Is it AN ACADEMY?
        je      .L15
        cmp     al,088h                 ; Is it a construction zone?
        je      .L15
        ; nothing there, let's build one.
        mov     di,128                  ; Start of enemy buildings
        .L6:
        cmp     byte UNIT_TYPE[di],0
        je      .L7
        inc     di
        cmp     di,196                  ; End of enemy buildings
        jne     .L6
        ret
        .L7:
        mov     byte UNIT_TYPE[di],35   ; protoid building construction unit type
        mov     byte UNIT_AI[di],31     ; protoid building construction AI
        mov     UNIT_LOCATION_X[di],bl
        mov     UNIT_LOCATION_Y[di],bh
        mov     byte UNIT_TIMER[di],1
        mov     byte UNIT_TILE[di],088h ; Construction tile
        mov     byte UNIT_GEN_A[di],0
        mov     byte UNIT_GEN_B[di],2   ; create an academy
        mov     byte UNIT_GEN_C[di],0
        mov     byte UNIT_HEALTH[di],250
        .L15:
        ret

AI_CHECK_FACTORY:
        cmp     byte [GAME_DIFF],0      ; easy mode
        jne     .L1
        ret     ; skip if in easy mode.
        .L1:
        ; Test for and Build the PROTOID FACTORY if it is not there.
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        add     ah,3                    ; Locate 3 tiles SOUTH of pyramid
        mov     di,ax
        mov     bx,ax
        GET_MAP_BYTE    di
        cmp     al,088h                 ; Is it a construction zone?
        je      .L15
        cmp     al,0bah                 ; Is it a FACTORY?
        je      .L15
        ; nothing there, let's build one.
        mov     di,128                  ; Start of enemy buildings
        .L6:
        cmp     byte UNIT_TYPE[di],0
        je      .L7
        inc     di
        cmp     di,196                  ; End of enemy buildings
        jne     .L6
        ret
        .L7:
        mov     byte UNIT_TYPE[di],35   ; protoid building construction unit type
        mov     byte UNIT_AI[di],31     ; protoid building construction AI
        mov     UNIT_LOCATION_X[di],bl
        mov     UNIT_LOCATION_Y[di],bh
        mov     byte UNIT_TIMER[di],1
        mov     byte UNIT_TILE[di],088h ; Construction tile
        mov     byte UNIT_GEN_A[di],0
        mov     byte UNIT_GEN_B[di],3   ; create a protoid factory
        mov     byte UNIT_GEN_C[di],0
        mov     byte UNIT_HEALTH[di],175
        .L15:
        ret

AI_CHECK_SOMEBUILD:
        ; Test for and Build the OTHER BUILDING if it is not there.
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        sub     al,3                    ; Locate 3 tiles WEST of pyramid
        mov     di,ax
        mov     bx,ax
        GET_MAP_BYTE    di
        cmp     al,0bch                 ; Is it A something else?
        je      .L15
        cmp     al,088h                 ; Is it a construction zone?
        je      .L15
        ; nothing there, let's build one.
        mov     di,128                  ; Start of enemy buildings
        .L6:
        cmp     byte UNIT_TYPE[di],0
        je      .L7
        inc     di
        cmp     di,196                  ; End of enemy buildings
        jne     .L6
        ret
        .L7:
        mov     byte UNIT_TYPE[di],35   ; protoid building construction unit type
        mov     byte UNIT_AI[di],31     ; protoid building construction AI
        mov     UNIT_LOCATION_X[di],bl
        mov     UNIT_LOCATION_Y[di],bh
        mov     byte UNIT_TIMER[di],1
        mov     byte UNIT_TILE[di],088h ; Construction tile
        mov     byte UNIT_GEN_A[di],0
        mov     byte UNIT_GEN_B[di],4   ; create a protoid OTHER BUILDING
        mov     byte UNIT_GEN_C[di],0
        mov     byte UNIT_HEALTH[di],150
        .L15:
        ret

AI_PROT_CONST:
        mov     byte UNIT_TIMER[si],200
        cmp     byte UNIT_GEN_A[si],0   ; has construction started yet?
        jne     .L5
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        mov     bl,088h
        SET_MAP_BIG_BUILDING_DI_BL
        inc     byte UNIT_GEN_A[si]
        call    RANDOM_NUMBER_GENERATOR
        mov     UNIT_TIMER[si],al       ; set random start time
        call    CHECK_WINDOW_FOR_ACTION
        ret
        .L5:
        inc     byte UNIT_GEN_A[si]
        cmp     byte UNIT_GEN_A[si],12  ; construction delay time
        je      .L6
        ret
        .L6:
        ; transform to actual building
        mov     al,UNIT_GEN_B[si]       ; get building type
        mov     ah,0
        mov     di,ax
        mov     al,PROTBLD_AI[di]
        mov     UNIT_AI[si],al
        mov     al,PROTBLD_TYPE[di]
        mov     UNIT_TYPE[si],al
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],2
        mov     byte UNIT_GEN_C[si],0
        mov     bl,PROTBLD_TILE[di]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        ; draw new building to map
        SET_MAP_BIG_BUILDING_DI_BL
        call    CHECK_WINDOW_FOR_ACTION
        ret
; list of enemy building construction types
; 0=pyramid
; 1=clone facility
; 2=academy
; 3=factory
; 4=something else

PROTBLD_TILE    db 0cch,0b8h,0ceh,0bah,0bch
PROTBLD_AI      db 29,32,33,34,35
PROTBLD_TYPE    db 33,36,37,38,39

; The following routine will spawn a walker from whatever building calls it.

SPAWN_WALKER1:
        mov     si,[UNIT_SCAN]
        ; create new walker
        mov     di,64                           ; start of enemy warriors
        .L1:
        cmp     byte UNIT_TYPE[di],0
        je      .L2
        inc     di
        cmp     di,128
        jne     .L1
        ; no units left
        ret
        .L2:
        mov     al,[TEMP_A]
        mov     UNIT_TYPE[di],al                ; protoid type (5=regular, 6=advanced)
        mov     al,UNIT_LOCATION_X[si]
        dec     al
        mov     UNIT_LOCATION_X[di],al          ; copy x/y location
        mov     ah,UNIT_LOCATION_Y[si]          ; from clone base
        inc     ah
        mov     UNIT_LOCATION_Y[di],ah
        mov     bx,ax                           ; store map location for later
        mov     byte UNIT_TILE[di],0a8h         ; protoid tile
        mov     byte UNIT_TILE_UNDER[di],06eh   ; concrete
        mov     al,[TEMP_C]
        mov     UNIT_AI[di],al  ; AI type
        mov     al,[TEMP_B]
        mov     UNIT_HEALTH[di],al
        mov     byte UNIT_GEN_A[di],0
        mov     byte UNIT_GEN_B[di],0
        mov     byte UNIT_GEN_C[di],0
        mov     byte UNIT_ALTMOVE_X[di],0
        mov     byte UNIT_ALTMOVE_Y[di],0
        mov     al,UNIT_LOCATION_X[di]          ; set destination to itself
        mov     UNIT_DEST_X[di],al              ; that way it will reset and find a new
        mov     al,UNIT_LOCATION_Y[di]          ; target upon spawning.
        mov     UNIT_DEST_Y[di],al
        call    RANDOM_NUMBER_GENERATOR
        mov     UNIT_TIMER[di],al
        ; plot to map
        mov     di,bx
        SET_MAP_BYTE    di,0a8h                 ; protoid tile
        call    CHECK_WINDOW_FOR_ACTION
        ret

; The following routine scans around the base for sentry pod locations.  If they
; are occupied then it skips to the next location.  If the spot is empty, a new
; sentry construction is started.

AI_PYRAMID_SENTRY_SCAN:
        mov     di,0
        .L1:
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        sub     al,4
        add     al,SENTRY_ORDER_X[di]
        mov     ah,UNIT_LOCATION_Y[si]
        sub     ah,4
        add     ah,SENTRY_ORDER_Y[di]
        mov     si,ax
        mov     bx,ax                   ; Store for later
        GET_MAP_BYTE    si              ; what tile is on the map currently?
        mov     ah,0
        mov     si,ax
        mov     al,TILEATTRIB[si]       ; Grab attributes of that tile
        and     al,16
        cmp     al,16                   ; Can it be bulldozed?
        je      .L5
        inc     di
        mov     al,[GAME_DIFF]
        inc     al
        shl     al,2                    ; Multiply by 4
        mov     ah,0
        cmp     di,ax                   ; Max sentry pods
        jne     .L1
        ret
        .L5:
        ; create new sentry pod
        mov     di,128                  ; Start of enemy buildings
        .L6:
        cmp     byte UNIT_TYPE[di],0
        je      .L7
        inc     di
        cmp     di,196                  ; End of enemy buildings
        jne     .L6
        ret
        .L7:
        mov     byte UNIT_TYPE[di],34   ; Sentry construction unit type
        mov     byte UNIT_AI[di],30     ; Sentry construction AI
        mov     UNIT_LOCATION_X[di],bl
        mov     UNIT_LOCATION_Y[di],bh
        mov     byte UNIT_TIMER[di],1
        mov     byte UNIT_TILE[di],0dfh ; Construction tile
        mov     byte UNIT_GEN_A[di],0
        mov     byte UNIT_GEN_B[di],0
        mov     byte UNIT_GEN_C[di],0
        mov     byte UNIT_HEALTH[di],100
        ret

AI_SENTRY_CONST:
        cmp     byte UNIT_GEN_A[si],0   ; Has it drawn to the map yet? 0=no 1=yes
        je      .L5
        mov     byte UNIT_TIMER[si],255
        inc     byte UNIT_GEN_A[si]
        cmp     byte UNIT_GEN_A[si],6   ; Time to change to finished sentry pod
        je      .L6
        ret
        .L5:
        ; draw it to map
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        SET_MAP_BYTE    di,0dfh         ; sentry construction tile
        mov     byte UNIT_GEN_A[si],1
        call    RANDOM_NUMBER_GENERATOR
        mov     UNIT_TIMER[si],al       ; set random start time
        call    CHECK_WINDOW_FOR_ACTION
        ret
        .L6:
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        GET_SET_MAP_BYTE        di,0afh ; Get old tile, Sentry Pod tile
        mov     UNIT_TILE_UNDER[si],al
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_TIMER[si],1
        mov     byte UNIT_TYPE[si],30   ; Sentry pod unit type
        mov     byte UNIT_AI[si],18     ; Sentry pod AI
        call    CHECK_WINDOW_FOR_ACTION
        ret

AI_CONVERT_TO_ASSAULT:
        mov     byte UNIT_TIMER[si],3
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12
        jne     AI_CONVERT_TO_SENTRY.L2
        mov     byte UNIT_TYPE[si],3
        mov     byte UNIT_AI[si],0
        mov     al,UNIT_TILE[si]
        sub     al,8
        jmp     AI_CONVERT_TO_SENTRY.L1

AI_CONVERT_TO_SENTRY:
        mov     byte UNIT_TIMER[si],3
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12
        jne     .L2
        mov     byte UNIT_TYPE[si],32
        mov     byte UNIT_TIMER[si],5
        mov     byte UNIT_AI[si],23     ; sentry tank
        mov     al,UNIT_TILE[si]
        add     al,8
        .L1:
        mov     UNIT_TILE[si],al
        mov     bh,UNIT_LOCATION_Y[si]
        mov     bl,UNIT_LOCATION_X[si]
        mov     di,bx
        mov     byte UNIT_WORKING[si],0
        SET_MAP_BYTE    di,al
        call    CHECK_WINDOW_FOR_ACTION
        .L2:
        mov     al,[SELECTED_UNIT]
        cmp     al,[UNIT_SCAN]
        jne     .L3
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L3:
        ret

AI_SENTRY_TANK:
        mov     byte UNIT_TIMER[si],10
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        GET_MAP_BYTE    di
        cmp     al,094h                 ; make sure the tile is between 94h to 97h
        jae     .L01
        mov     al,094h                 ; set it to 094h if not.
        jmp     .L03
        .L01:
        cmp     al,097h
        jbe     .L03
        mov     al,094h                 ; set it to 094h if not.
        .L03:
        mov     ah,0
        mov     si,ax
        sub     si,94h
        mov     al,byte [SENTRY_SPIN+si]
        SET_MAP_BYTE    di,al
        mov     si,[UNIT_SCAN]
        ; check if it is okay to fire again
        cmp     byte UNIT_GEN_A[si],0
        je      .L04
        dec     byte UNIT_GEN_A[si]
        jmp     SENTANK20
        .L04:
        ; check for enemy units nearby
        mov     di,64                   ; start of enemy units
        .L05:
        cmp     byte UNIT_TYPE[di],0
        jne     .L10
        .L06:
        inc     di
        cmp     di,196                  ; end of enemy units
        jne     .L05
        jmp     SENTANK20               ; none found
        .L10:
        mov     al,UNIT_LOCATION_X[di]  ; enemy unit
        mov     UNIT_DEST_X[si],al      ; location dest
        mov     al,UNIT_LOCATION_Y[di]
        mov     UNIT_DEST_Y[si],al
        call    CHECK_DISTANCE_TO_DESTINATION
        cmp     byte [TEMP_X],5
        ja      .L06
        cmp     byte [TEMP_Y],4
        ja      .L06
        mov     ax,di
        mov     [TEMP_A],al             ; store target unit#
        ; find new projectile unit number
        mov     di,196
        .L15:
        mov     al,UNIT_TYPE[di]
        cmp     al,0
        je      .L20
        inc     di
        cmp     di,212
        jne     .L15
        ret                             ; failure to find free projectile unit
        .L20:
        ; set information for projectile
        mov     byte UNIT_TYPE[di],28   ; projectile unit type
        mov     byte UNIT_AI[di],11     ; projectile ai
        mov     byte UNIT_GEN_A[di],20  ; damage
        mov     al,[TEMP_A]
        mov     UNIT_GEN_B[di],al       ; fire at unit#
        mov     byte UNIT_TILE[di],0b7h ; blue projectile tile
        mov     byte UNIT_TIMER[di],2
        mov     al,UNIT_LOCATION_X[si]  ; projectile starting location
        mov     UNIT_LOCATION_X[di],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     UNIT_LOCATION_Y[di],al
        mov     byte UNIT_GEN_A[si],5   ; firing delay
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        jne     .L21
        mov     al,04                   ; shooting sound
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound
        .L21:
        ret
        SENTANK20:
        call    CHECK_WINDOW_FOR_ACTION
        ret
        SENTRY_SPIN     db 96h,97h,95h,94h

AI_NUCLEAR_MISSILE:
        mov     byte UNIT_TIMER[si],1
        cmp     byte UNIT_GEN_A[si],0
        jne     AINM10
        mov     byte UNIT_AI[si],20             ; large explosion ai
        mov     byte UNIT_GEN_A[si],0           ; explosion counter to zero
        mov     byte UNIT_GEN_B[si],0           ; explosion counter to zero
        mov     byte UNIT_TIMER[si],1
        call    CLEAR_PLAYFIELD_WINDOW_WHITE
        call    invalidate_lazy_redraw_buffer
        ret
        AINM10:
        dec     byte UNIT_GEN_A[si]
        ret

AI_LARGE_EXPLOSION:
        ; some code to check for edges of screen and move
        ; the explosion if needed.
        cmp     byte UNIT_LOCATION_X[si],2
        ja      .L0
        mov     byte UNIT_LOCATION_X[si],2
        .L0:
        cmp     byte UNIT_LOCATION_X[si],253
        jb      .L1
        mov     byte UNIT_LOCATION_X[si],253
        .L1:
        cmp     byte UNIT_LOCATION_Y[si],2
        ja      .L2
        mov     byte UNIT_LOCATION_Y[si],2
        .L2:
        cmp     byte UNIT_LOCATION_Y[si],125
        jb      .L3
        mov     byte UNIT_LOCATION_Y[si],125
        .L3:

        cmp     byte UNIT_GEN_A[si],0
        jne     .L08
        mov     al,16                   ; long explosion
        mov     ah,255                  ; priority
        call    m_playSFX               ; play sound effect
        call    AI_LARGE_EXPLOSION_KILL_UNITS
        mov     si,[UNIT_SCAN]
        .L08:
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        sub     al,2                    ; move 2 to the left
        sub     ah,2                    ; move 2 to the north
        mov     di,ax
        mov     al,UNIT_GEN_B[si]
        mov     ah,0
        mov     si,ax
        mov     bx,0
        .L10:
        mov     al,[BIGEXPLOSION+si]
        cmp     al,0                    ; zero doesn't get drawn
        je      .L15
        ; check to see if map tile is indestructible or not
        ; ------
        GET_MAP_BYTE_IN_CL      di
        push    si
        mov     ch,0
        mov     si,cx
        mov     cl,TILEDESTRUCT[si]
        mov     si,cx
        mov     ah,TILEATTRIB[si]
        pop     si
        and     ah,8
        cmp     ah,8                    ; can it be destroyed?
        je      .L13
        SET_MAP_BYTE    di,cl
        jmp     .L15
        .L13:
        ; ------
        SET_MAP_BYTE    di,al
        .L15:
        inc     si
        inc     di
        inc     bl
        cmp     bl,5
        jne     .L10
        mov     bl,0
        add     di,251
        inc     bh
        cmp     bh,5
        jne     .L10
        mov     byte [REDRAW_SCREEN_REQ],1
        mov     cx,si
        mov     si,[UNIT_SCAN]
        mov     byte UNIT_TIMER[si],3
        mov     UNIT_GEN_B[si],cl
        inc     byte UNIT_GEN_A[si]
        cmp     byte UNIT_GEN_A[si],7
        jne     .L20
        mov     byte UNIT_TYPE[si],0
        mov     byte UNIT_AI[si],0
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L20:
        ret
BIGEXPLOSION    db 000h,000h,000h,000h,000h
                db 000h,000h,0a2h,000h,000h
                db 000h,0a2h,0a0h,0a2h,000h
                db 000h,000h,0a2h,000h,000h
                db 000h,000h,000h,000h,000h
                ; --------------------------
                db 000h,0a3h,0a2h,0a3h,000h
                db 0a3h,0a2h,0a1h,0a2h,0a3h
                db 0a2h,0a1h,0a1h,0a1h,0a2h
                db 0a3h,0a2h,0a1h,0a2h,0a3h
                db 000h,0a3h,0a2h,0a3h,000h
                ; --------------------------
                db 000h,0a2h,0a1h,0a2h,000h
                db 0a2h,0a1h,0a2h,0a1h,0a2h
                db 0a1h,0a2h,0a2h,0a2h,0a1h
                db 0a2h,0a1h,0a2h,0a1h,0a2h
                db 000h,0a2h,0a1h,0a2h,000h
                ; --------------------------
                db 000h,0a1h,0a2h,0a1h,000h
                db 0a1h,0a2h,0a3h,0a2h,0a1h
                db 0a2h,0a3h,0e1h,0a3h,0a2h
                db 0a1h,0a2h,0a3h,0a2h,0a1h
                db 000h,0a1h,0a2h,0a1h,000h
                ; --------------------------
                db 000h,0a2h,0a3h,0a2h,000h
                db 0a2h,0a3h,0d9h,0a3h,0a2h
                db 0a3h,0e0h,0e1h,0e2h,0a3h
                db 0a2h,0a3h,0e9h,0a3h,0a2h
                db 000h,0a2h,0a3h,0a2h,000h
                ; --------------------------
                db 000h,0a3h,022h,0a3h,000h
                db 0a3h,0d8h,0d9h,0dah,0a3h
                db 022h,0e0h,0e1h,0e2h,022h
                db 0a3h,0e8h,0e9h,0eah,0a3h
                db 000h,0a3h,022h,0a3h,000h
                ; --------------------------
                db 000h,022h,022h,022h,000h
                db 022h,0d8h,0d9h,0dah,022h
                db 022h,0e0h,0e1h,0e2h,022h
                db 022h,0e8h,0e9h,0eah,022h
                db 000h,022h,022h,022h,000h

AI_LARGE_EXPLOSION_KILL_UNITS:
        ; First we check a 5x3 rectangular area
        ; for any units
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        sub     al,2                    ; move 2 to the left
        mov     [CHECK_X],al
        mov     al,UNIT_LOCATION_Y[si]
        dec     al                      ; move 1 to the north
        mov     [CHECK_Y],al
        mov     bx,0
        .L10:
        mov     al,[CHECK_X]
        mov     [TEMP_X],al
        mov     al,[CHECK_Y]
        mov     [TEMP_Y],al
        call    ADJUST_CO_FOR_BUILDING
        call    CHECK_FOR_UNIT_AT_XY
        cmp     byte [CHECK_XY_RESULT],0
        je      .L15
        ; found something
        mov     al,[CHECK_XY_UNIT]
        cmp     al,[UNIT_SCAN]          ; make sure we don't kill our own process.
        je      .L15
        mov     ah,0
        mov     si,ax
        push    bx
        call    UNIT_DESTROYED
        pop     bx
        .L15:
        mov     al,[TEMP_X]
        mov     [CHECK_X],al
        mov     al,[TEMP_Y]
        mov     [CHECK_Y],al
        inc     byte [CHECK_X]
        inc     bl
        cmp     bl,5
        jne     .L10
        mov     bl,0
        sub     byte [CHECK_X],5
        inc     byte [CHECK_Y]
        inc     bh
        cmp     bh,3
        jne     .L10
        ; We we check the top 3 and bottom 3 tiles
        ; for any units
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        dec     al                      ; move 1 to the left
        mov     [CHECK_X],al
        mov     al,UNIT_LOCATION_Y[si]
        sub     al,2                    ; move 2 to the north
        mov     [CHECK_Y],al
        mov     bx,0
        .L20:
        call    ADJUST_CO_FOR_BUILDING
        call    CHECK_FOR_UNIT_AT_XY
        cmp     byte [CHECK_XY_RESULT],0
        je      .L25
        ; found something
        mov     al,[CHECK_XY_UNIT]
        cmp     al,[UNIT_SCAN]          ; make sure we don't kill our own process.
        je      .L25
        mov     ah,0
        mov     si,ax
        push    bx
        call    UNIT_DESTROYED
        pop     bx
        .L25:
        inc     byte [CHECK_X]
        inc     bl
        cmp     bl,3
        jne     .L20
        mov     bl,0
        sub     byte [CHECK_X],3
        add     byte [CHECK_Y],4
        inc     bh
        cmp     bh,2
        jne     .L20
        ret


AI_TANK_SELF_DESTRUCT:
        mov     byte UNIT_TIMER[si],3
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12
        je      .L05
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L04
        mov     byte [REDRAW_STATUS_REQ],1
        .L04:
        ret
        .L05:
        call    ERASE_UNIT_FROM_MAP
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_TYPE[si],0
        mov     byte UNIT_AI[si],0
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],0
        mov     byte UNIT_GEN_C[si],0
        mov     di,196                  ; start of projectile units
        .L6:
        cmp     byte UNIT_TYPE[di],0
        je      .L7
        inc     di
        cmp     di,212                  ; end of projectile units
        jne     .L6
        ret                             ; apparently we're out of projectile units, so abort.
        .L7:
        mov     byte UNIT_TYPE[di],2
        mov     byte UNIT_AI[di],20     ; large explosion ai
        mov     byte UNIT_WORKING[di],0
        mov     byte UNIT_GEN_A[di],0   ; explosion counter to zero
        mov     byte UNIT_GEN_B[di],0   ; explosion counter to zero
        mov     byte UNIT_TIMER[di],2
        mov     al,UNIT_LOCATION_X[si]
        mov     UNIT_LOCATION_X[di],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     UNIT_LOCATION_Y[di],al
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L10
        mov     byte [REDRAW_STATUS_REQ],1
        .L10:
        call    CLEAR_PLAYFIELD_WINDOW_WHITE
        call    invalidate_lazy_redraw_buffer
        ret

AI_SENTRY_POD:
        mov     byte UNIT_TIMER[si],20
        ; start scanning for player units (0-63) to attack
        mov     di,0
        .L05:
        cmp     byte UNIT_TYPE[di],0
        jne     .L10
        .L06:
        inc     di
        cmp     di,64
        jne     .L05
        ret
        .L10:
        mov     al,UNIT_LOCATION_X[di]
        mov     UNIT_DEST_X[si],al
        mov     al,UNIT_LOCATION_Y[di]
        mov     UNIT_DEST_Y[si],al
        call    CHECK_DISTANCE_TO_DESTINATION
        cmp     byte [TEMP_X],5
        ja      .L06
        cmp     byte [TEMP_Y],4
        ja      .L06
        mov     ax,di
        mov     [TEMP_A],al
        ; find new projectile unit number
        mov     di,196
        .L15:
        mov     al,UNIT_TYPE[di]
        cmp     al,0
        je      .L20
        inc     di
        cmp     di,212
        jne     .L15
        ret                             ; failure to find free projectile unit
        .L20:
        ; set information for projectile
        mov     byte UNIT_TYPE[di],28   ; projectile unit type
        mov     byte UNIT_AI[di],11     ; projectile ai
        mov     byte UNIT_GEN_A[di],5   ; damage
        mov     al,[TEMP_A]
        mov     UNIT_GEN_B[di],al       ; fire at unit#
        mov     byte UNIT_TILE[di],0b7h ; blue projectile tile
        mov     byte UNIT_TIMER[di],2
        mov     al,UNIT_LOCATION_X[si]
        mov     UNIT_LOCATION_X[di],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     UNIT_LOCATION_Y[di],al
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        jne     .L21
        mov     al,04                   ; shooting sound
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound
        .L21:
        ret

AI_SMALL_EXPLOSION_CLEANUP:
        mov     byte UNIT_TIMER[si],2
        cmp     byte UNIT_TILE[si],0a3h         ; land explosion
        je      .L1
        cmp     byte UNIT_TILE[si],067h         ; water explosion
        je      .L1
        inc     byte UNIT_TILE[si]
        call    DRAW_FLYING_OBJECTS
        ret
        .L1:
        mov     byte UNIT_TYPE[si],0
        mov     byte UNIT_AI[si],0
        cmp     byte [REDRAW_SCREEN_REQ],1      ; see if there is a redraw already scheduled
        je      .L2                             ; if so, skip this.
        call    CHECK_WINDOW_FOR_ACTION
        cmp     byte [REDRAW_SCREEN_REQ],0      ; see if this is happening in viewable area
        je      .L2
        mov     byte [REDRAW_SCREEN_REQ],0
        mov     al,UNIT_LOCATION_X[si]
        sub     al,[MAP_OFFS_X]
        mov     [CURSOR_X],al
        mov     al,UNIT_LOCATION_Y[si]
        sub     al,[MAP_OFFS_Y]
        mov     [CURSOR_Y],al
        call    plot_tile_XY_on_bg
        mov     si,[UNIT_SCAN]
        .L2:
        ret

AI_PROJECTILE:
        ; unit_gen_a contains damage amount
        ; unit_gen_b 255=fire at coordinates, 0-254=fire at unit#
        ; first figure out if we are shooting at a unit or map object.
        mov     byte UNIT_TIMER[si],1
        cmp     byte UNIT_GEN_B[si],255         ; 255=shooting at map object
        je      .L05
        ; if we've come here then we need to find the coordinates of
        ; the unit we're shooting at and copy those to the destination
        ; in case the unit has moved.
        mov     al,UNIT_GEN_B[si]
        mov     ah,0
        mov     di,ax
        mov     al,UNIT_LOCATION_X[di]
        mov     UNIT_DEST_X[si],al
        mov     al,UNIT_LOCATION_Y[di]
        mov     UNIT_DEST_Y[si],al
        .L05:
        ; check if reached destination yet
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,UNIT_DEST_X[si]
        jne     .L10
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,UNIT_DEST_Y[si]
        jne     .L10
        jmp     .L40
        .L10:
        ; erase old image
        cmp     byte [REDRAW_SCREEN_REQ],1      ; see if there is a redraw already scheduled
        je      .L11                            ; if so, skip this.
        call    CHECK_WINDOW_FOR_ACTION
        cmp     byte [REDRAW_SCREEN_REQ],0      ; see if this is happening in viewable area
        je      .L11
        mov     byte [REDRAW_SCREEN_REQ],0
        mov     al,UNIT_LOCATION_X[si]
        sub     al,[MAP_OFFS_X]
        mov     [CURSOR_X],al
        mov     al,UNIT_LOCATION_Y[si]
        sub     al,[MAP_OFFS_Y]
        mov     [CURSOR_Y],al
        call    plot_tile_XY_on_bg
        mov     si,[UNIT_SCAN]
        .L11:
        ; figure out direction for x
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,UNIT_DEST_X[si]
        je      .L20
        jb      .L15
        dec     byte UNIT_LOCATION_X[si]        ; move left
        jmp     .L20
        .L15:
        inc     byte UNIT_LOCATION_X[si]        ; move right
        .L20:
        ; figure out direction for y
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,UNIT_DEST_Y[si]
        je      .L30
        jb      .L25
        dec     byte UNIT_LOCATION_Y[si]        ; move up
        jmp     .L30
        .L25:
        inc     byte UNIT_LOCATION_Y[si]        ; move down
        .L30:
        ; draw new image
        call    ADJUST_PROJECTILE_FOR_WATER
        cmp     byte [REDRAW_SCREEN_REQ],1      ; see if there is a redraw already scheduled
        je      .L31                            ; if so, skip this.
        call    DRAW_FLYING_OBJECTS
        .L31:
        ret
        .L40:
        ; reached destination, so convert to explosion
        mov     al,UNIT_GEN_A[si]               ; damage amount
        mov     [TEMP_C],al
        mov     byte UNIT_TYPE[si],29           ; explosion(small) unit type
        mov     byte UNIT_AI[si],12             ; explosion(small) AI type
        mov     byte UNIT_TIMER[si],2           ; set delay
        call    ADJUST_EXPLOSION_FOR_WATER
        cmp     byte [REDRAW_SCREEN_REQ],1      ; see if there is a redraw already scheduled
        je      .L41                            ; if so, skip this.
        call    DRAW_FLYING_OBJECTS
        .L41:
        ; determine if attacking map or unit
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     [CHECK_X],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     [CHECK_Y],al
        call    ADJUST_CO_FOR_BUILDING
        call    CHECK_FOR_UNIT_AT_XY
        cmp     byte [CHECK_XY_RESULT],0
        je      ATTACK_MAP                      ; conditional short tail call
        jmp     ATTACK_UNIT                     ; tail call

ATTACK_MAP:
        mov     si,[UNIT_SCAN]
        mov     bl,UNIT_LOCATION_X[si]
        mov     bh,UNIT_LOCATION_Y[si]
        mov     si,bx
        GET_MAP_BYTE    si              ; get current map object
        mov     ah,0
        mov     di,ax
        mov     al,TILEATTRIB[di]
        and     al,8
        cmp     al,8                    ; destruction attribute bit
        je      .L50
        ret
        .L50:
        mov     al,TILESTRENGTH[di]
        cmp     al,[TEMP_C]
        jbe     .L55
        ret
        .L55:
        mov     al,TILEDESTRUCT[di]
        SET_MAP_BYTE    si,al           ; place new map object
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        jne     .L56
        mov     al,8                    ; selects EXPLOSION SOUND
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L56:
        ret

ATTACK_UNIT:
        mov     al,[CHECK_XY_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_HEALTH[si]
        cmp     al,[TEMP_C]
        jbe     UNIT_DESTROYED
        mov     al,UNIT_HEALTH[si]
        sub     al,[TEMP_C]             ; reduce health by damage amount
        mov     UNIT_HEALTH[si],al
        mov     ax,si
        cmp     al,[SELECTED_UNIT]
        jne     .L73
        mov     byte [REDRAW_STATUS_REQ],1
        .L73:
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        jne     .L72
        mov     al,8                    ; selects EXPLOSION SOUND
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L72:
        ret

        UNIT_DESTROYED:
        mov     byte UNIT_TYPE[si],0
        mov     byte UNIT_HEALTH[si],0
        mov     byte UNIT_AI[si],0
        mov     bl,UNIT_LOCATION_X[si]
        mov     bh,UNIT_LOCATION_Y[si]
        mov     ax,si
        cmp     al,[SELECTED_UNIT]
        jne     .L74
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        .L74:
        mov     si,bx
        GET_MAP_BYTE    si              ; get current map object
        mov     ah,0
        mov     di,ax
        mov     al,TILEDESTRUCT[di]
        SET_MAP_BYTE    si,al           ; replace current map object
        ; now check tile to the right
        inc     si
        GET_MAP_BYTE    si              ; get current map object
        mov     ah,0
        mov     di,ax
        mov     al,TILEATTRIB[di]
        and     al,64
        cmp     al,64
        jne     .L75
        mov     al,TILEDESTRUCT[di]
        SET_MAP_BYTE    si,al           ; replace current map object
        .L75:
        ; now check tile below
        add     si,255
        GET_MAP_BYTE    si              ; get current map object
        mov     ah,0
        mov     di,ax
        mov     al,TILEATTRIB[di]
        and     al,128
        cmp     al,128
        jne     .L76
        mov     al,TILEDESTRUCT[di]
        SET_MAP_BYTE    si,al           ; replace current map object
        .L76:
        ; now check tile bottom-right
        inc     si
        GET_MAP_BYTE    si              ; get current map object
        mov     ah,0
        mov     di,ax
        mov     al,TILEATTRIB[di]
        and     al,192
        cmp     al,192
        jne     .L77
        mov     al,TILEDESTRUCT[di]
        SET_MAP_BYTE    si,al           ; replace current map object
        .L77:
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        jne     .L78
        mov     al,8                    ; selects EXPLOSION SOUND
        mov     ah,128                  ; priority
        call    m_playSFX               ; play sound effect
        .L78:
        ret

ADJUST_PROJECTILE_FOR_WATER:
        ; This routine checks the tile under the projectile
        ; to see if it is land or water, and adjusts the tile
        ; accordingly.
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        GET_MAP_BYTE    di
        cmp     al,18h                  ; water shallow
        je      .L5
        cmp     al,19h                  ; water shallow
        je      .L5
        cmp     al,1ah                  ; water deep
        je      .L5
        mov     byte UNIT_TILE[si],0b7h ; land projectile
        ret
        .L5:
        mov     byte UNIT_TILE[si],09fh ; water projectile
        ret

ADJUST_EXPLOSION_FOR_WATER:
        ; This routine checks the tile under the projectile
        ; to see if it is land or water, and adjusts the tile
        ; accordingly.
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        GET_MAP_BYTE    di
        cmp     al,18h                  ; water shallow
        je      .L5
        cmp     al,19h                  ; water shallow
        je      .L5
        cmp     al,1ah                  ; water deep
        je      .L5
        mov     byte UNIT_TILE[si],0a0h ; land explosion
        ret
        .L5:
        mov     byte UNIT_TILE[si],064h ; water explosion
        ret

AI_BUILDER_BULLDOZE:
        mov     byte UNIT_TIMER[si],5
        mov     byte UNIT_AI[si],0
        mov     al,UNIT_DEST_X[si]
        mov     ah,UNIT_DEST_Y[si]
        mov     di,ax
        SET_MAP_BYTE    di,22h          ; dirt
        call    CHECK_WINDOW_FOR_ACTION_S
        cmp     byte [WINDOW_ACTION],1
        jne     .L1
        mov     al,11                   ; bulldoze sound
        mov     ah,128                  ; priority
        call    m_playSFX
        .L1:
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L2
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        .L2:
        ret

AI_BUILDER_DROPOFF:
        mov     byte UNIT_TIMER[si],5
        mov     byte UNIT_AI[si],0
        mov     al,UNIT_DEST_X[si]
        mov     ah,UNIT_DEST_Y[si]
        mov     di,ax
        mov     al,UNIT_GEN_C[si]
        mov     byte UNIT_GEN_C[si],0
        SET_MAP_BYTE    di,al
        call    CHECK_WINDOW_FOR_ACTION
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L2
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        .L2:
        ret

AI_BUILDER_PICKUP:
        mov     byte UNIT_TIMER[si],5
        mov     byte UNIT_AI[si],0
        mov     al,UNIT_DEST_X[si]
        mov     ah,UNIT_DEST_Y[si]
        mov     di,ax
        GET_SET_MAP_BYTE        di,22h  ; dirt
        cmp     al,2                    ; special case for plant
        jne     .not_a_plant
        SET_MAP_BYTE    di,0
        .not_a_plant:
        mov     UNIT_GEN_C[si],al
        call    CHECK_WINDOW_FOR_ACTION
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L2
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        .L2:
        ret

AI_GAS_REFINERY:
        mov     byte UNIT_TIMER[si],225
        cmp     byte [QTY_GAS],255
        je      .L2
        inc     byte [QTY_GAS]
        call    WRITE_RESOURCES
        .L2:
        ret

AI_SMELTER_REFINING:
        cmp     byte [QTY_MINERALS],255
        jne     .L2
        ret                             ; pause if mineral store is full.
        .L2:
        mov     al,UNIT_GEN_A[si]
        mov     UNIT_TIMER[si],al
        mov     al,UNIT_GEN_B[si]
        clc
        add     al,[QTY_MINERALS]
        jnc     .L5
        mov     al,255
        .L5:
        mov     [QTY_MINERALS],al
        call    WRITE_RESOURCES
        mov     si,[UNIT_SCAN]
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12
        jne     .L1
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_AI[si],8      ; back to search mode!
        mov     byte UNIT_TIMER[si],5
        .L1:
        mov     al,[UNIT_SCAN]
        cmp     [SELECTED_UNIT],al
        jne     .L2a
        mov     byte [REDRAW_STATUS_REQ],1
        mov     byte [REDRAW_COMWIN_REQ],1
        .L2a:
        ret

; The following routine checks at a given map location (defined by
; al (X location) and ah (Y location) to see if any minerals are
; at that location.
; If so, it changes the tile to dirt and returns with ZF=1

CHECK_FOR_MINERALS_AT_LOCATION:
        mov     di,ax
        GET_MAP_BYTE    di
        cmp     al,07h                  ; high-density crystal
        je      .L5
        cmp     al,06h                  ; low-density crystal
        je      .L5
        cmp     al,0fh                  ; boulder
        je      .L5
        cmp     al,0eh                  ; cracked boulder
        je      .L5
        cmp     al,0dh                  ; smaller rock group
        je      .L5
        cmp     al,0ch                  ; sMALL ROCK
        je      .L5
        cmp     al,62h                  ; pile of junk
        je      .L5
        ; If we made it this far, there's no minerals
        ret
        .L5:
        SET_MAP_BYTE    di,22h          ; dirt
        ret

AI_SMELTER_SEARCHING:
        mov     byte UNIT_TIMER[si],50  ; reset timer delay
        mov     byte UNIT_WORKING[si],0
        ; test location #1
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        dec     al
        inc     ah
        call    CHECK_FOR_MINERALS_AT_LOCATION
        jz      SSFM01
        ; test location #2
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        dec     al
        call    CHECK_FOR_MINERALS_AT_LOCATION
        jz      SSFM01
        ; test location #3
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        dec     ah
        call    CHECK_FOR_MINERALS_AT_LOCATION
        jz      SSFM01
        ; test location #4
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        dec     ah
        inc     al
        call    CHECK_FOR_MINERALS_AT_LOCATION
        jz      SSFM01
        ; test location #5
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        inc     al
        inc     al
        call    CHECK_FOR_MINERALS_AT_LOCATION
        jz      SSFM01
        ; test location #6
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        inc     al
        inc     al
        inc     ah
        call    CHECK_FOR_MINERALS_AT_LOCATION
        jz      SSFM01
        ; test location #7
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        inc     ah
        inc     ah
        inc     al
        call    CHECK_FOR_MINERALS_AT_LOCATION
        jz      SSFM01
        ; test location #8
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        inc     ah
        inc     ah
        call    CHECK_FOR_MINERALS_AT_LOCATION
        jz      SSFM01
        ; nothing found
        ret
        SSFM01:                         ; minerals found!
        cmp     al,07h                  ; high-density crystal
        jne     .L12
        mov     ax,10*256+50            ; speed=50, yield=10
        jmp     SMEL10
        .L12:
        cmp     al,06h                  ; low-density crystal
        jne     .L13
        mov     ax,8*256+50             ; speed=50, yield=8
        jmp     SMEL10
        .L13:
        cmp     al,0fh                  ; boulder
        jne     .L14
        mov     ax,6*256+70             ; speed=70, yield=6
        jmp     SMEL10
        .L14:
        cmp     al,0eh                  ; cracked boulder
        jne     .L15
        mov     ax,6*256+70             ; speed=70, yield=6
        jmp     SMEL10
        .L15:
        cmp     al,0dh                  ; smaller rock group
        jne     .L16
        mov     ax,4*256+60             ; speed=60, yield=4
        jmp     SMEL10
        .L16:
        cmp     al,0ch                  ; sMALL ROCK
        jne     .L17
        mov     ax,2*256+40             ; speed=40, yield=2
        jmp     SMEL10
        .L17:
        cmp     al,062h                 ; pile of junk
        jne     .L18
        mov     ax,1*256+10             ; speed=10, yield=1
        jmp     SMEL10
        .L18:                           ; should never get here!
        ret
        SMEL10:
        mov     byte UNIT_GEN_A[si],al  ; speed
        mov     byte UNIT_GEN_B[si],ah  ; yield
        mov     byte UNIT_AI[si],9      ; smelter refining ai
        mov     byte UNIT_WORKING[si],1
        mov     al,UNIT_GEN_A[si]
        mov     UNIT_TIMER[si],al
        call    CHECK_WINDOW_FOR_ACTION
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L18
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L18:
        ret

AI_BUILD_HEAVY_TANK:
        mov     byte UNIT_TIMER[si],12          ; reset timer delay
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12        ; finished
        je      .L3
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L1:
        ret
        .L3:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_AI[si],0
        call    FIND_DELIVERY_LOCATION          ; returns x in al, y in ah, failure in zf
        jnz     .L5                             ; skip error message in case of success
        mov     si,INFO_BLOCKED1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BLOCKED2
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L5:
        mov     si,0
        .L4:                                    ; get new unit#
        cmp     byte UNIT_TYPE[si],0
        je      .L6
        inc     si
        cmp     si,20
        jne     .L4
        mov     si,INFO_MAXERR03
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_MAXERR02
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L6:
        ; create tank unit
        mov     byte UNIT_TYPE[si],03           ; heavy tank
        mov     byte UNIT_AI[si],00
        mov     byte UNIT_WORKING[si],00
        mov     byte UNIT_TILE[si],8ch
        mov     byte UNIT_HEALTH[si],125
        mov     UNIT_LOCATION_X[si],al
        mov     UNIT_LOCATION_Y[si],ah
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        .L7:
        ; check if this unit is selected
        mov     al,[UNIT_SCAN]
        cmp     [SELECTED_UNIT],al
        je      .L8
        ret
        .L8:
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret

AI_BUILD_TANK:
        mov     byte UNIT_TIMER[si],6           ; reset timer delay
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12        ; finished
        je      .L3
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L1:
        ret
        .L3:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_AI[si],0
        call    FIND_DELIVERY_LOCATION          ; returns x in al, y in ah, failure in zf
        jnz     .L2                             ; skip error message in case of success
        mov     si,INFO_BLOCKED1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BLOCKED2
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L2:
        mov     si,0
        .L4:                                    ; get new unit#
        cmp     byte UNIT_TYPE[si],0
        je      .L6
        inc     si
        cmp     si,20
        jne     .L4
        mov     si,INFO_MAXERR03
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_MAXERR02
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L6:
        ; create tank unit
        mov     byte UNIT_TYPE[si],02
        mov     byte UNIT_AI[si],00
        mov     byte UNIT_WORKING[si],00
        mov     byte UNIT_TILE[si],58h
        mov     byte UNIT_HEALTH[si],85
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],0
        mov     byte UNIT_GEN_C[si],0
        mov     UNIT_LOCATION_X[si],al
        mov     UNIT_LOCATION_Y[si],ah
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        .L7:
        ; check if this unit is selected
        mov     al,[UNIT_SCAN]
        cmp     [SELECTED_UNIT],al
        je      .L8
        ret
        .L8:
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret

AI_BUILD_BUILDER:
        mov     byte UNIT_TIMER[si],3           ; reset timer delay
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12        ; finished
        je      .L3
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L1:
        ret
        .L3:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_AI[si],0
        call    FIND_DELIVERY_LOCATION          ; returns x in al, y in ah, failure in zf
        jnz     .L2                             ; skip error message in case of success
        mov     si,INFO_BLOCKED1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BLOCKED2
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L2:
        mov     si,0
        .L4:                                    ; get new unit#
        cmp     byte UNIT_TYPE[si],0
        je      .L6
        inc     si
        cmp     si,20
        jne     .L4
        mov     si,INFO_MAXERR03
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_MAXERR02
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L6:
        ; create builder unit
        mov     byte UNIT_TYPE[si],01
        mov     byte UNIT_AI[si],00
        mov     byte UNIT_WORKING[si],00
        mov     byte UNIT_TILE[si],50h
        mov     byte UNIT_HEALTH[si],20
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],0
        mov     byte UNIT_GEN_C[si],0
        mov     UNIT_LOCATION_X[si],al
        mov     UNIT_LOCATION_Y[si],ah
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        .L7:
        ; check if this unit is selected
        mov     al,[UNIT_SCAN]
        cmp     [SELECTED_UNIT],al
        je      .L8
        ret
        .L8:
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret

AI_BUILD_FIGHTER:
        mov     byte UNIT_TIMER[si],3           ; reset timer delay
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12        ; finished
        je      .L3
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L1:
        ret
        .L3:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_AI[si],0
        call    FIND_DELIVERY_LOCATION          ; returns x in al, y in ah, failure in zf
        jnz     .L2                             ; skip error message in case of success
        mov     si,INFO_BLOCKED1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BLOCKED2
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L2:
        mov     si,0
        .L4:                                    ; get new unit#
        cmp     byte UNIT_TYPE[si],0
        je      .L6
        inc     si
        cmp     si,20
        jne     .L4
        mov     si,INFO_MAXERR03
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_MAXERR02
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L6:
        ; create fighter unit
        mov     byte UNIT_TYPE[si],10
        mov     byte UNIT_AI[si],00
        mov     byte UNIT_WORKING[si],00
        mov     byte UNIT_TILE[si],5ah
        mov     byte UNIT_HEALTH[si],40
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],0
        mov     byte UNIT_GEN_C[si],0
        mov     UNIT_LOCATION_X[si],al
        mov     UNIT_LOCATION_Y[si],ah
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        .L7:
        ; check if this unit is selected
        mov     al,[UNIT_SCAN]
        cmp     [SELECTED_UNIT],al
        je      .L8
        ret
        .L8:
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret

AI_BUILD_SCOUT:
        mov     byte UNIT_TIMER[si],3           ; reset timer delay
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12        ; finished
        je      .L3
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L1:
        ret
        .L3:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_AI[si],0
        call    FIND_DELIVERY_LOCATION          ; returns x in al, y in ah, failure in zf
        jnz     .L2                             ; skip error message in case of success
        mov     si,INFO_BLOCKED1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BLOCKED2
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L2:
        mov     si,0
        .L4:                                    ; get new unit#
        cmp     byte UNIT_TYPE[si],0
        je      .L6
        inc     si
        cmp     si,20
        jne     .L4
        mov     si,INFO_MAXERR03
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_MAXERR02
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L6:
        ; create scout unit
        mov     byte UNIT_TYPE[si],9
        mov     byte UNIT_AI[si],00
        mov     byte UNIT_WORKING[si],00
        mov     byte UNIT_TILE[si],54h
        mov     byte UNIT_HEALTH[si],20
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],0
        mov     byte UNIT_GEN_C[si],0
        mov     UNIT_LOCATION_X[si],al
        mov     UNIT_LOCATION_Y[si],ah
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        .L7:
        ; check if this unit is selected
        mov     al,[UNIT_SCAN]
        cmp     [SELECTED_UNIT],al
        je      .L8
        ret
        .L8:
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret

AI_BUILD_FRIGATE:
        mov     byte UNIT_TIMER[si],6           ; reset timer delay
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12        ; finished
        je      .L3
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L1
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        .L1:
        ret
        .L3:
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_AI[si],0
        call    FIND_WATER_DELIVERY_LOCATION    ; returns x in al, y in ah, success in zf
        jz      .L2                             ; skip error message in case of success
        mov     si,INFO_BLOCKED1
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_BLOCKED2
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L2:
        mov     si,0
        .L4:                                    ; get new unit#
        cmp     byte UNIT_TYPE[si],0
        je      .L6
        inc     si
        cmp     si,20
        jne     .L4
        mov     si,INFO_MAXERR03
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_MAXERR02
        call    WRITE_NEW_MESSAGE
        mov     al,0                            ; selects SOUND "0" (ERROR)
        mov     ah,150                          ; priority
        call    m_playSFX                       ; play sound effect
        jmp     .L7
        .L6:
        ; create frigate unit
        mov     byte UNIT_TYPE[si],4            ; frigate
        mov     byte UNIT_AI[si],00
        mov     byte UNIT_WORKING[si],00
        mov     byte UNIT_TILE[si],5eh          ; frigate tile
        mov     byte UNIT_HEALTH[si],85
        mov     byte UNIT_GEN_A[si],0
        mov     byte UNIT_GEN_B[si],0
        mov     byte UNIT_GEN_C[si],0
        mov     UNIT_LOCATION_X[si],al ; x
        mov     UNIT_LOCATION_Y[si],ah ; y
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        .L7:
        ; check if this unit is selected
        mov     al,[UNIT_SCAN]
        cmp     [SELECTED_UNIT],al
        je      .L8
        ret
        .L8:
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret


CHECK_FOR_WATER_XY:
        ; This routine checks around the factory for
        ; water as a delivery location for boats.
        ; zf=1 if water is found, 0=no water
        mov     si,ax
        GET_MAP_BYTE_IN_BL      si
        cmp     bl,18h                  ; water shallow
        je      .L1
        cmp     bl,19h                  ; water medium depth
        je      .L1
        cmp     bl,1ah                  ; water deep
        .L1:
        ret

FIND_WATER_DELIVERY_LOCATION:
        ; This routine will search for a free WATER area
        ; around a factory.
        ; The result is in al for X, ah for Y and zf
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        dec     al                      ; test position 1
        call    CHECK_FOR_WATER_XY
        jnz     .L0
        ret
        .L0:
        dec     ah                      ; test position 2
        inc     al
        call    CHECK_FOR_WATER_XY
        jnz     .L1
        ret
        .L1:
        inc     al                      ; test position 3
        call    CHECK_FOR_WATER_XY
        jnz     .L2
        ret
        .L2:
        inc     ah                      ; test position 4
        inc     al
        call    CHECK_FOR_WATER_XY
        jnz     .L3
        ret
        .L3:
        inc     ah                      ; test position 5
        call    CHECK_FOR_WATER_XY
        jnz     .L4
        ret
        .L4:
        inc     ah                      ; test position 6
        dec     al
        call    CHECK_FOR_WATER_XY
        jnz     .L5
        ret
        .L5:
        dec     al                      ; test position 7
        call    CHECK_FOR_WATER_XY
        jnz     .L6
        ret
        .L6:
        dec     al                      ; test position 8
        dec     ah
        call    CHECK_FOR_WATER_XY
        ret

GET_TILE_ATTRIB_XY:
        ; This routine grabs the attribute of the tile
        ; located at al for X, ah for Y ---> bl
        mov     si,ax
        GET_MAP_BYTE_IN_BL      si
        mov     bh,0
        mov     si,bx
        mov     bl,TILEATTRIB[si]
        ret

FIND_DELIVERY_LOCATION:
        ; This routine will search for a free area around
        ; a factory and then create the new unit.
        ; The result is placed in zf/al/ah
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        dec     al                      ; test position 1
        call    GET_TILE_ATTRIB_XY
        test    bl,1                    ; drive atttrib
        jz      .L5
        ret
        .L5:
        dec     ah                      ; test position 2
        inc     al
        call    GET_TILE_ATTRIB_XY
        test    bl,1                    ; drive atttrib
        jz      .L6
        ret
        .L6:
        inc     al                      ; test position 3
        call    GET_TILE_ATTRIB_XY
        test    bl,1                    ; drive atttrib
        jz      .L7
        ret
        .L7:
        inc     ah                      ; test position 4
        inc     al
        call    GET_TILE_ATTRIB_XY
        test    bl,1                    ; drive atttrib
        jz      .L8
        ret
        .L8:
        inc     ah                      ; test position 5
        call    GET_TILE_ATTRIB_XY
        test    bl,1                    ; drive atttrib
        jz      .L9
        ret
        .L9:
        inc     ah                      ; test position 6
        dec     al
        call    GET_TILE_ATTRIB_XY
        test    bl,1                    ; drive atttrib
        jz      .L10
        ret
        .L10:
        dec     al                      ; test position 7
        call    GET_TILE_ATTRIB_XY
        test    bl,1                    ; drive atttrib
        jz      .L11
        ret
        .L11:
        dec     al                      ; test position 8
        dec     ah
        call    GET_TILE_ATTRIB_XY
        test    bl,1                    ; drive atttrib
        ; FAILED if zf=1
        ret

AI_TRAVELLER:
        ; This AI routine is used for most an unit that is
        ; in a state of movement.  Upon arriving at its
        ; destination, it will change its AI routine to
        ; whatever is in UNIT_GEN_A
        cmp     byte UNIT_TYPE[si],1            ; builder
        jne     .L01
        cmp     byte UNIT_GEN_B[si],3           ; gas refinery const
        jne     .L01
        push    si
        call    SET_BUILD_ITEMS_FLAGS_CLEAR
        pop     si
        .L01:
        mov     byte UNIT_TIMER[si],5           ; reset timer delay
        cmp     byte UNIT_AI[si],13             ; traveller type 2
        jne     AI_TR_MOVE
        ; if we are type 2, we check to see if the unit
        ; is within 1 tile of the destination.
        call    CHECK_DISTANCE_TO_DESTINATION
        cmp     byte [TEMP_X],1
        ja      AI_TR_MOVE
        cmp     byte [TEMP_Y],1
        ja      AI_TR_MOVE
        jmp     AITR_DONE02                     ; close enough to dest!
        AI_TR_MOVE:
        ; First check up/down and see which way we need
        ; to move.
        mov     al,UNIT_LOCATION_Y[si]
        mov     bl,UNIT_DEST_Y[si]
        cmp     al,bl
        je      AITR_LR01                       ; if equal, skip this section:
        jb      .L05
        call    AI_PATHFIND_UP
        jmp     AITR_LR02
        .L05:
        call    AI_PATHFIND_DOWN
        jmp     AITR_LR02
        ; Next check left/right and see which way
        ; we need to move.
        AITR_LR01:
        ; we only go here if the Y coordinate has been reached
        ; so we check if the X coordinate has been reached too!
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     bl,UNIT_DEST_X[si]
        cmp     al,bl
        je      AITR_DONE02
        jmp     AITR_LR03
        AITR_LR02:
        ; X coordinate not reached yet, so we move!
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     bl,UNIT_DEST_X[si]
        cmp     al,bl
        je      AITR_DONE01
        AITR_LR03:
        jb      AITR_LR_05
        call    AI_PATHFIND_LEFT
        jmp     AITR_DONE01
        AITR_LR_05:
        call    AI_PATHFIND_RIGHT
        jmp     AITR_DONE01
        AITR_DONE01:
        ; At this point, we're done moving for this session
        ; but haven't yet arrived at the destination
        cmp     byte UNIT_TYPE[si],1            ; builder
        jne     AITR_DONE01B
        call    SET_BUILD_ITEMS_FLAGS_NORMAL
        AITR_DONE01B:
        ret
        AITR_DONE02:
        ; At this point, we've reached the destination.
        ; so we change AI routines to whatever is stored
        ; in UNIT_GEN_A
        cmp     byte [UNIT_SCAN],64             ; is it protoid unit?
        jae     AITR_DONE02B
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_GEN_A[si]
        mov     UNIT_AI[si],al
        mov     byte UNIT_GEN_A[si],0
        mov     byte [REDRAW_COMWIN_REQ],1
        cmp     byte UNIT_TYPE[si],1            ; builder
        jne     AITR_DONE02B
        call    SET_BUILD_ITEMS_FLAGS_NORMAL
        AITR_DONE02B:
        ret

; things to fix
;               - Prioritize the first movement based on the distance
;                 needed to go in each direction, then second movement
;                 will be the shorter direction. (hopefully solve
;                 bridge problems.)

PF_DIR_BIT_X:
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,UNIT_DEST_X[si]
        jbe     .L1
        mov     byte UNIT_ALTMOVE_X[si],128     ; go left
        ret
        .L1:
        mov     byte UNIT_ALTMOVE_X[si],0       ; go right
        ret

PF_DIR_BIT_Y:
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,UNIT_DEST_Y[si]
        jbe     .L1
        mov     byte UNIT_ALTMOVE_Y[si],128     ; go up
        ret
        .L1:
        mov     byte UNIT_ALTMOVE_Y[si],0       ; go down
        ret


AI_PATHFIND_UP:
        cmp     byte UNIT_ALTMOVE_Y[si],0
        je      .L1
        ret
        .L1:
        call    AI_MOVEUP
        cmp     byte [MOVE_RESULT],1
        je      .L20
        ; check altmove direction bit
        cmp     byte UNIT_ALTMOVE_X[si],0       ; 0=no alt move in progress.
        jne     .L2
        call    PF_DIR_BIT_X
        .L2:
        mov     al,UNIT_ALTMOVE_X[si]
        and     al,128                          ; direction bit
        cmp     al,128                          ; direction bit 1=left 0=right
        je      .L4
        call    ALT_MOVERIGHT
        ret
        .L4:
        call    ALT_MOVELEFT
        ret
        .L20:
        ; move was a success, we can cancel the alt-move mode.
        mov     byte UNIT_ALTMOVE_X[si],0
        ret

AI_PATHFIND_DOWN:
        cmp     byte UNIT_ALTMOVE_Y[si],0
        je      .L1
        ret
        .L1:
        call    AI_MOVEDOWN
        cmp     byte [MOVE_RESULT],1
        je      .L20
        ; check altmove direction bit
        cmp     byte UNIT_ALTMOVE_X[si],0       ; 0=no alt move in progress.
        jne     .L2
        call    PF_DIR_BIT_X
        .L2:
        mov     al,UNIT_ALTMOVE_X[si]
        and     al,128                          ; direction bit
        cmp     al,128                          ; direction bit 1=left 0=right
        je      .L4
        call    ALT_MOVERIGHT
        ret
        .L4:
        call    ALT_MOVELEFT
        ret
        .L20:
        ; move was a success, we can cancel the alt-move mode.
        mov     byte UNIT_ALTMOVE_X[si],0
        ret

AI_PATHFIND_LEFT:
        cmp     byte UNIT_ALTMOVE_X[si],0
        je      .L1
        ret
        .L1:
        call    AI_MOVELEFT
        cmp     byte [MOVE_RESULT],1
        je      .L20
        ; check altmove direction bit
        cmp     byte UNIT_ALTMOVE_Y[si],0       ; 0=no alt move in progress.
        jne     .L2
        call    PF_DIR_BIT_Y
        .L2:
        mov     al,UNIT_ALTMOVE_Y[si]
        and     al,128                          ; direction bit
        cmp     al,128                          ; direction bit 1=up 0=down
        je      .L4
        call    ALT_MOVEDOWN
        ret
        .L4:
        call    ALT_MOVEUP
        ret
        .L20:
        ; move was a success, we can cancel the alt-move mode.
        mov     byte UNIT_ALTMOVE_Y[si],0
        ret

AI_PATHFIND_RIGHT:
        cmp     byte UNIT_ALTMOVE_X[si],0
        je      .L1
        ret
        .L1:
        call    AI_MOVERIGHT
        cmp     byte [MOVE_RESULT],1
        je      .L20
        ; check altmove direction bit
        cmp     byte UNIT_ALTMOVE_Y[si],0       ; 0=no alt move in progress.
        jne     .L2
        call    PF_DIR_BIT_Y
        .L2:
        mov     al,UNIT_ALTMOVE_Y[si]
        and     al,128                          ; direction bit
        cmp     al,128                          ; direction bit 1=up 0=down
        je      .L4
        call    ALT_MOVEDOWN
        ret
        .L4:
        call    ALT_MOVEUP
        ret
        .L20:
        ; move was a success, we can cancel the alt-move mode.
        mov     byte UNIT_ALTMOVE_Y[si],0
        ret

ALT_MOVEUP:
        inc     byte UNIT_ALTMOVE_Y[si]
        cmp     byte UNIT_ALTMOVE_Y[si],143     ; allow 15 movements up.  (128 for bit7 + 15)
        jne     .L1
        mov     byte UNIT_ALTMOVE_Y[si],1       ; change to move down instead
        ret
        .L1:
        call    AI_MOVEUP
        cmp     byte [MOVE_RESULT],1
        je      .L2
        ; ran into obstacle moving up, change direction.
        mov     byte UNIT_ALTMOVE_Y[si],1       ; change to move down instead
        ret
        .L2:
        ; success
        ret

ALT_MOVEDOWN:
        inc     byte UNIT_ALTMOVE_Y[si]
        cmp     byte UNIT_ALTMOVE_Y[si],15      ; allow 10 movements up.
        jne     .L1
        mov     byte UNIT_ALTMOVE_Y[si],128     ; change to move up instead
        ret
        .L1:
        call    AI_MOVEDOWN
        cmp     byte [MOVE_RESULT],1
        je      .L2
        ; ran into obstacle moving up, change direction.
        mov     byte UNIT_ALTMOVE_Y[si],128     ; change to move down instead
        ret
        .L2:
        ; success
        ret

ALT_MOVELEFT:
        inc     byte UNIT_ALTMOVE_X[si]
        cmp     byte UNIT_ALTMOVE_X[si],143     ; allow 15 movements up. (128 for bit7 + 10)
        jne     .L1
        mov     byte UNIT_ALTMOVE_X[si],1       ; change to move right instead
        ret
        .L1:
        call    AI_MOVELEFT
        cmp     byte [MOVE_RESULT],1
        je      .L2
        ; ran into obstacle moving up, change direction.
        mov     byte UNIT_ALTMOVE_X[si],1       ; change to move right instead
        ret
        .L2:
        ; success
        ret

ALT_MOVERIGHT:
        inc     byte UNIT_ALTMOVE_X[si]
        cmp     byte UNIT_ALTMOVE_X[si],15      ; allow 20 movements up.
        jne     .L1
        mov     byte UNIT_ALTMOVE_X[si],128     ; change to move left instead
        ret
        .L1:
        call    AI_MOVERIGHT
        cmp     byte [MOVE_RESULT],1
        je      .L2
        ; ran into obstacle moving up, change direction.
        mov     byte UNIT_ALTMOVE_X[si],128     ; change to move left instead
        ret
        .L2:
        ; success
        ret


AI_MOVEDOWN:
        mov     byte [MOVE_RESULT],0    ; reset flag.
        ; Check for bounary of map first.
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,127
        jne     AIMDW09
        ret
        ; Check if unit type can fly
        AIMDW09:
        mov     al,UNIT_TYPE[si]
        mov     ah,0
        mov     di,ax
        mov     al,UNIT_FLY[di]
        cmp     al,01
        je      AIMDW20
        ; Check for objects in the way
        AIMDW10:
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        inc     ah                      ; Check object to NORTH
        mov     di,ax
        GET_MAP_BYTE    di
        ; check if this is a boat
        cmp     byte UNIT_TYPE[si],4    ; frigate
        jne     AIMDW12
        cmp     al,18h                  ; water shallow
        je      AIMDW20
        cmp     al,19h                  ; water medium
        je      AIMDW20
        cmp     al,1ah                  ; water deep
        je      AIMDW20
        ret
        AIMDW12:
        mov     ah,0
        mov     di,ax
        mov     al,TILEATTRIB[di]
        and     al,1
        cmp     al,1                    ; can drive on this object?
        je      AIMDW20
        ret
        AIMDW20:
        ; Find correct tile for this direction.
        mov     bl,UNIT_TYPE[si]
        mov     bh,0
        mov     di,bx
        mov     bl,DIR_TILE_DOWN[di]
        cmp     bl,0
        je      AIMD30
        mov     UNIT_TILE[si],bl
        AIMD30:
        ; Move unit
        call    ERASE_UNIT_FROM_MAP
        inc     byte UNIT_LOCATION_Y[si]
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        mov     byte [MOVE_RESULT],1    ; move success
        ; call    sfx_engine              ; Make an "engine moving" sound
        ret

AI_MOVEUP:
        mov     byte [MOVE_RESULT],0    ; reset flag.
        ; Check for bounary of map first.
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,0
        jne     AIMUP09
        ret
        ; Check if unit type can fly
        AIMUP09:
        mov     al,UNIT_TYPE[si]
        mov     ah,0
        mov     di,ax
        mov     al,UNIT_FLY[di]
        cmp     al,01
        je      AIMUP20
        ; Check for objects in the way
        AIMUP10:
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        dec     ah                      ; Check object to NORTH
        mov     di,ax
        GET_MAP_BYTE    di
        ; check if this is a boat
        cmp     byte UNIT_TYPE[si],4    ; frigate
        jne     AIMUP12
        cmp     al,18h                  ; water shallow
        je      AIMUP20
        cmp     al,19h                  ; water medium
        je      AIMUP20
        cmp     al,1ah                  ; water deep
        je      AIMUP20
        ret
        AIMUP12:
        mov     ah,0
        mov     di,ax
        mov     al,TILEATTRIB[di]
        and     al,1
        cmp     al,1                    ; can drive on this object?
        je      AIMUP20
        ret
        AIMUP20:
        ; Find correct tile for this direction.
        mov     bl,UNIT_TYPE[si]
        mov     bh,0
        mov     di,bx
        mov     bl,DIR_TILE_UP[di]
        cmp     bl,0
        je      AIMUP30
        mov     UNIT_TILE[si],bl
        AIMUP30:
        ; Move unit
        call    ERASE_UNIT_FROM_MAP
        dec     byte UNIT_LOCATION_Y[si]
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        mov     byte [MOVE_RESULT],1    ; move success
        ; call    sfx_engine              ; Make an "engine moving" sound
        ret

AI_MOVERIGHT:
        mov     byte [MOVE_RESULT],0    ; reset flag.
        ; Check for bounary of map first.
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,255
        jne     AIMRT09
        ret
        ; Check if unit type can fly
        AIMRT09:
        mov     al,UNIT_TYPE[si]
        mov     ah,0
        mov     di,ax
        mov     al,UNIT_FLY[di]
        cmp     al,01
        je      AIMRT20
        ; Check for objects in the way
        AIMRT10:
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        inc     di                      ; Check object to right
        GET_MAP_BYTE    di
        ; check if this is a boat
        cmp     byte UNIT_TYPE[si],4    ; frigate
        jne     AIMRT12
        cmp     al,18h                  ; water shallow
        je      AIMRT20
        cmp     al,19h                  ; water medium
        je      AIMRT20
        cmp     al,1ah                  ; water deep
        je      AIMRT20
        ret
        AIMRT12:
        mov     ah,0
        mov     di,ax
        mov     al,TILEATTRIB[di]
        and     al,1
        cmp     al,1                    ; can drive on this object?
        je      AIMRT20
        ret
        AIMRT20:
        ; Find correct tile for this direction.
        mov     bl,UNIT_TYPE[si]
        mov     bh,0
        mov     di,bx
        mov     bl,DIR_TILE_RIGHT[di]
        mov     UNIT_TILE[si],bl
        ; Move unit
        call    ERASE_UNIT_FROM_MAP
        inc     byte UNIT_LOCATION_X[si]
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        mov     byte [MOVE_RESULT],1    ; move success
        ; call    sfx_engine              ; Make an "engine moving" sound
        ret

AI_MOVELEFT:
        mov     byte [MOVE_RESULT],0    ; reset flag.
        ; Check for bounary of map first.
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,0
        jne     AIMLF09
        ret
        ; Check if unit type can fly
        AIMLF09:
        mov     al,UNIT_TYPE[si]
        mov     ah,0
        mov     di,ax
        mov     al,UNIT_FLY[di]
        cmp     al,01
        je      AIMLF20
        ; Check for objects in the way
        AIMLF10:
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,UNIT_LOCATION_Y[si]
        mov     di,ax
        dec     di                      ; Check object to LEFT
        GET_MAP_BYTE    di
        ; check if this is a boat
        cmp     byte UNIT_TYPE[si],4    ; frigate
        jne     AIMLF12
        cmp     al,18h                  ; water shallow
        je      AIMLF20
        cmp     al,19h                  ; water medium
        je      AIMLF20
        cmp     al,1ah                  ; water deep
        je      AIMLF20
        ret
        AIMLF12:
        mov     ah,0
        mov     di,ax
        mov     al,TILEATTRIB[di]
        and     al,1
        cmp     al,1                    ; can drive on this object?
        je      AIMLF20
        ret
        AIMLF20:
        ; Find correct tile for this direction.
        mov     bl,UNIT_TYPE[si]
        mov     bh,0
        mov     di,bx
        mov     bl,DIR_TILE_LEFT[di]
        mov     UNIT_TILE[si],bl
        ; Move unit
        call    ERASE_UNIT_FROM_MAP
        dec     byte UNIT_LOCATION_X[si]
        call    PLOT_UNIT_ON_MAP
        call    CHECK_WINDOW_FOR_ACTION
        mov     byte [MOVE_RESULT],1    ; move success
        ; call    sfx_engine              ; Make an "engine moving" sound
        ret

; The following routine checks the screen for action and sets the
; redraw flags as needed.  It skips the rest of the checks if the
; redraw is already set, saving time.

CHECK_WINDOW_FOR_ACTION:
        cmp     byte [REDRAW_SCREEN_REQ],1      ; see if already set
        jne     .L1
        ret
        .L1:
        ; This routine checks to see if the current unit
        ; activity is located within the visible area
        ; and sets redraw flags as needed.
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L2
        ; If the unit in question is the same as the currently
        ; selected unit, then we can skip all of this.
        call    FIND_MAP_OFFSET
        mov     byte [REDRAW_SCREEN_REQ],1
        mov     byte [REDRAW_COORDS_REQ],1
        ret
        .L2:
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,[MAP_OFFS_X]
        jae     .L3
        ret
        .L3:
        mov     ah,[MAP_OFFS_X]
        add     ah,[SCREEN_WIDTH]
        dec     ah
        cmp     al,ah
        jbe     .L4
        ret
        .L4:
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,[MAP_OFFS_Y]
        jae     .L5
        ret
        .L5:
        mov     ah,[MAP_OFFS_Y]
        add     ah,8
        cmp     al,ah
        jbe     .L6
        ret
        .L6:
        mov     byte [REDRAW_SCREEN_REQ],1
        ret

; The following routine is used when it is neccessary to check
; if a sound effect needs to be played.  It also checks the screen
; for redraws, but runs regardless if the flag is already set.

CHECK_WINDOW_FOR_ACTION_S:
        cmp     byte [SOUNDFX_ON],1             ; is sound on?
        je      .L10
        cmp     byte [REDRAW_SCREEN_REQ],1      ; is the redraw flag already set?
        jne     .L10
        ret                             ; skip this if flag is set and sound fx are off (for speed)
        .L10:
        mov     byte [WINDOW_ACTION],0          ; set to zero by default (sound effects)
        ; This routine checks to see if the current unit
        ; activity is located within the visible area
        ; and sets redraw flags as needed.
        mov     al,[UNIT_SCAN]
        cmp     al,[SELECTED_UNIT]
        jne     .L2
        ; If the unit in question is the same as the currently
        ; selected unit, then we can skip all of this.
        call    FIND_MAP_OFFSET
        mov     byte [REDRAW_SCREEN_REQ],1
        mov     byte [REDRAW_COORDS_REQ],1
        mov     byte [WINDOW_ACTION],1          ; play sound effect if needed
        ret
        .L2:
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_LOCATION_X[si]
        cmp     al,[MAP_OFFS_X]
        jae     .L3
        ret
        .L3:
        mov     ah,[MAP_OFFS_X]
        add     ah,[SCREEN_WIDTH]
        dec     ah
        cmp     al,ah
        jbe     .L4
        ret
        .L4:
        mov     al,UNIT_LOCATION_Y[si]
        cmp     al,[MAP_OFFS_Y]
        jae     .L5
        ret
        .L5:
        mov     ah,[MAP_OFFS_Y]
        add     ah,8
        cmp     al,ah
        jbe     .L6
        ret
        .L6:
        mov     byte [REDRAW_SCREEN_REQ],1
        mov     byte [WINDOW_ACTION],1          ; play sound effect if needed
        ret

AI_HEADQUARTERS:
        mov     byte UNIT_TIMER[si],127         ; reset timer
        ret

AI_BUILD_MISSILE:
        mov     byte UNIT_TIMER[si],15          ; reset timer
        inc     byte UNIT_WORKING[si]
        cmp     byte UNIT_WORKING[si],12
        jne     .L4
        mov     byte UNIT_WORKING[si],0
        mov     byte UNIT_GEN_A[si],1
        mov     byte UNIT_AI[si],0
        mov     al,[SELECTED_UNIT]
        cmp     [UNIT_SCAN],al
        jne     .L5
        mov     byte [REDRAW_COMWIN_REQ],1
        mov     byte [REDRAW_STATUS_REQ],1
        ret
        .L4:
        mov     al,[SELECTED_UNIT]
        cmp     [UNIT_SCAN],al
        jne     .L5
        mov     byte [REDRAW_STATUS_REQ],1
        .L5:
        ret

AI_POWER_STATION:
        mov     byte UNIT_TIMER[si],255         ; reset timer
        mov     ax,si
        mov     [TEMP_A],al
        call    POWER_STATION_SCAN
        mov     al,[UNIT_SCAN]
        cmp     [SELECTED_UNIT],al
        jne     .L1
        call    DRAW_STATUS_WINDOW
        .L1:
        ret

AI_SOLAR_PANEL:
        mov     byte UNIT_TIMER[si],255         ; reset timer
        mov     al,UNIT_GEN_A[si]
        cmp     al,0
        jne     .L1
        ret
        .L1:
        cmp     byte [QTY_ENERGY],255
        je      .L2
        inc     byte [QTY_ENERGY]
        call    WRITE_RESOURCES
        .L2:
        ret

REQUEST_NEW_BUILDING_NUMBER:
        mov     di,20
        .L1:
        cmp     byte UNIT_TYPE[di],0
        je      .L5
        inc     di
        cmp     di,64                   ; failed to find available slot
        jne     .L1
        mov     byte [TEMP_A],0         ; failed
        mov     si,INFO_MAXERR01
        call    WRITE_NEW_MESSAGE
        mov     si,INFO_MAXERR02
        call    WRITE_NEW_MESSAGE
        mov     al,0                    ; selects SOUND 0 (ERROR)
        mov     ah,150                  ; priority
        call    m_playSFX               ; play sound effect
        ret
        .L5:
        mov     byte [TEMP_A],1        ; success
        ; resulting building number left in di
        ret


POWER_PANEL_CHECK:
        mov     si,20
        .L1:
        cmp     byte UNIT_TYPE[si],23   ; solar panel
        jne     .L2
        mov     al,[CHECK_X]
        cmp     UNIT_LOCATION_X[si],al
        jne     .L2
        mov     al,[CHECK_Y]
        cmp     UNIT_LOCATION_Y[si],al
        jne     .L2
        cmp     byte UNIT_GEN_A[si],0   ; must not be owned
        jne     .L2
        mov     al,[TEMP_B]
        mov     UNIT_GEN_A[si],al       ; own this unit
        ret
        .L2:
        inc     si
        cmp     si,64
        jne     .L1
        ret

POWER_PANEL_SCAN:
        ; temp_a contains unit number to scan around
        ; temp_b contains unit number to assign
        mov     al,[TEMP_A]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_LOCATION_X[si]
        mov     [TEMP_X],al
        mov     al,UNIT_LOCATION_Y[si]
        mov     [TEMP_Y],al
        ; first check directly above
        cmp     byte [TEMP_Y],02
        jb      PPS05                   ; skip if out of bounds
        mov     al,[TEMP_X]
        mov     [CHECK_X],al
        mov     al,[TEMP_Y]
        mov     [CHECK_Y],al
        sub     byte [CHECK_Y],2
        call    POWER_PANEL_CHECK
        PPS05:
        ; next check directly below
        cmp     byte [TEMP_Y],124
        ja      PPS06                   ; skip if out of bounds
        mov     al,[TEMP_X]
        mov     [CHECK_X],al
        mov     al,[TEMP_Y]
        mov     [CHECK_Y],al
        add     byte [CHECK_Y],2
        call    POWER_PANEL_CHECK
        PPS06:
        ; next check directly to left
        cmp     byte [TEMP_X],2
        jb      PPS07                   ; skip if out of bounds
        mov     al,[TEMP_X]
        mov     [CHECK_X],al
        mov     al,[TEMP_Y]
        mov     [CHECK_Y],al
        sub     byte [CHECK_X],2
        call    POWER_PANEL_CHECK
        PPS07:
        ; next check directly to right
        cmp     byte [TEMP_X],253
        ja      PPS08                   ; skip if out of bounds
        mov     al,[TEMP_X]
        mov     [CHECK_X],al
        mov     al,[TEMP_Y]
        mov     [CHECK_Y],al
        add     byte [CHECK_X],2
        call    POWER_PANEL_CHECK
        PPS08:
        ret

POWER_STATION_SCAN:
        ; temp_a should already be power station unit in question
        mov     al,[TEMP_A]
        mov     [TEMP_B],al
        call    POWER_PANEL_SCAN
        mov     byte [TEMP_C],0         ; counter
        .L0:
        mov     si,20
        .L1:
        cmp     byte UNIT_TYPE[si],23   ; solar panel
        jne     .L10                    ; if not,skip
        mov     al,[TEMP_B]
        cmp     UNIT_GEN_A[si],al       ; is it assigned to this power station?
        jne     .L10                    ; if not,skip
        push    si
        mov     ax,si
        mov     [TEMP_A],al
        call    POWER_PANEL_SCAN
        pop     si
        .L10:
        inc     si
        cmp     si,64
        jne     .L1
        inc     byte [TEMP_C]
        cmp     byte [TEMP_C],3
        jne     .L0
        ; now calculate how many panels are connected
        mov     si,20
        mov     cl,0                    ; counter
        mov     al,[TEMP_B]
        .L11:
        cmp     byte UNIT_TYPE[si],23
        jne     .L20
        cmp     UNIT_GEN_A[si],al
        jne     .L20
        inc     cl
        .L20:
        inc     si
        cmp     si,64
        jne     .L11
        mov     ah,0
        mov     si,ax
        mov     UNIT_GEN_A[si],cl
        ret

; The following routine will check the distance between the
; unit's current position and it's destination

CHECK_DISTANCE_TO_DESTINATION:
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_X[si]
        mov     ah,0
        sub     al,UNIT_DEST_X[si]
        jns     .L1
        neg     ax
        .L1:     ; check distance positive x
        mov     [TEMP_X],al
        mov     si,[UNIT_SCAN]
        mov     al,UNIT_LOCATION_Y[si]
        sub     al,UNIT_DEST_Y[si]
        mov     ah,0
        jns     .L2
        neg     ax
        .L2:     ; check distance positive y
        mov     [TEMP_Y],al
        mov     si,[UNIT_SCAN]
        ret
