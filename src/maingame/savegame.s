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
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

;-------the following are all saved at once in the save-game feature-------
UNIT_TYPE               resb    256
UNIT_LOCATION_X         resb    256     ; Where the unit is now.
UNIT_LOCATION_Y         resb    256
UNIT_DEST_X             resb    256     ; Where the unit is going.
UNIT_DEST_Y             resb    256
UNIT_TILE               resb    256
UNIT_TILE_UNDER         resb    256
UNIT_HEALTH             resb    256
UNIT_WORKING            resb    256     ; percent complete.
UNIT_GEN_A              resb    256     ; general purpose A
UNIT_GEN_B              resb    256     ; General purpose B
UNIT_GEN_C              resb    256     ; General purpose C
UNIT_TIMER              resb    256     ; countdown until that unit's A/I runs.
UNIT_AI                 resb    256     ; Defines which AI routine to run.
UNIT_ALTMOVE_X          resb    256     ; For movement detours.  Bit 7=direction bit.
UNIT_ALTMOVE_Y          resb    256     ; For movement detours.  Bit 7=direction bit.
TILE_SET                db      0       ; Stores which tile set is in use for this map.
SELECTED_UNIT           db      0       ; Unit that the player is playing now.
GAME_DIFF               db      1       ; 0=EASY 1=NORM 2=HARD
QTY_MINERALS            db      0       ; Available Minerals
QTY_GAS                 db      0       ; Available Gas
QTY_ENERGY              db      0       ; Available Energy
HOTKEYS                 resb    10      ; Used to store hotkeys
