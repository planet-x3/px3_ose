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

; ---------- macros ----------

DEBUG   equ     0       ; Visual debugging tools; change to 0 for final build
DIAGS   equ     0       ; Used for showing diagnostic screen if F1 pressed

; macro for tail calls -- change to "call" and "ret" for easier static code analysis
%macro tcall 1
        jmp     %1
%endmacro

; ---------- global variables ----------

CGA_PALETTE             db 3            ; 0=MAGENTA 1=ORANGE, 2nd bit is intensity
VIDEO_TRANS             db 0            ; 0=TRANSPARENCY OFF 1=TRANSPARENCY ON
MUSIC_ON                db 1            ; 0=MUSIC OFF 1=MUSIC ON
SOUNDFX_ON              db 1            ; 0=SOUNDFX OFF 1=SOUNDFX ON
TILE_BG                 dw 0            ; STORES THE SI LOCATION OF BACKGROUND TILE
SCREEN_WIDTH            db 19           ; 19=NORMAL / 11=REDUCED FOR SLOW MACHINES
MAP_NUMBER              db 0            ; determines which map is played.
REDRAW_SCREEN_REQ       db 0            ; 0=Nothing 1=redraw screen
REDRAW_COORDS_REQ       db 0            ; 0=Nothing 1=redraw coordinates
REDRAW_COMWIN_REQ       db 0            ; 0=Nothing 1=redraw command window
REDRAW_STATUS_REQ       db 0            ; 0=Nothing 1=redraw status window
WINDOW_ACTION           db 0            ; 0=no 1=yes (used to determine if playing sound or not)
UNIT_COUNT_TIMER        db 0            ; countdown to the periodic unit count
UNIT_COUNT_PLUNITS      db 0            ; count of active player units
UNIT_COUNT_PLBLDG       db 0            ; count of active player buildings
UNIT_COUNT_ENUNITS      db 0            ; count of active enemy units
UNIT_COUNT_ENBLDG       db 0            ; count of active enemy buildings
END_GAME_DETECTED       db 0            ; 1=game over 0=still playing
BROWSE_MODE             db 0            ; 0=off 1=on
HILITE_MODE             db 0            ; 0=OFF, Any other number is countdown.
SELECTED_TILE           db 0            ; Current Tile IN BROWSE MODE
CURSOR_X                db 0            ; X location of cusror
CURSOR_Y                db 0            ; Y location of cursor
BROWSE_CURSOR_X         db 0            ; X location of browsing cusror
BROWSE_CURSOR_Y         db 0            ; Y location of browsing cursor
BROWSE_MOVEMENT         db 0            ; used for firing on last location
BROWSE_CANCEL           db 0            ; 0=Not cancelled 1=cancelled
RADAR_ACTIVE            db 0            ; 0=NO 1=YES
LAST_ATTACK_X           db 0            ; Keep track of last coordinates attacked
LAST_ATTACK_Y           db 0            ; Keep track of last coordinates attacked
LAST_ATTACK_U           db 0            ; Keep track of last unit attacked
BIG_CURSOR_MODE         db 0            ; 0=NO 1=YES
CHECK_X                 db 0            ; used to check for unit at map location
CHECK_Y                 db 0            ; used to check for unit at map location
CHECK_XY_RESULT         db 0            ; Returns 0=no unit 1=unit found
CHECK_XY_UNIT           db 0            ; Returns the unit number found.
MOVE_RESULT             db 0            ; 0=failed 1=success
MAP_OFFS_X              db 0            ; Offset for the map vs window
MAP_OFFS_Y              db 0            ; Offset for the map vs window
TEMP_X                  db 0
TEMP_Y                  db 0
TEMP_A_TIMES_256        db 0            ; Little-endian WORD read returns TEMP_A*256
TEMP_A                  db 0
TEMP_A_PADDING          db 0            ; Zero padding to enable WORD access to TEMP_A
TEMP_B                  db 0
TEMP_C                  db 0
PLOT_X                  dw 0            ; Used for Radar routine
TEMP_MAP_LOC            dw 0            ; Used to store the map address
HEXNUM                  db 0            ; Number to be displayed in Hexidecimal
font_bg_color           dw 0            ; Used to create font background.
MENU_SEL                db 0            ; Which menu item is selected?
TEMPATTRIB              resb 8          ; Temp storage of attributes
handle                  dw 0            ; File HANDLE
TEMPDESTRUCT            db 0            ; TEMP DESTRUCT PATH
TEMPSTRENGTH            db 0            ; TEMP STRENGTH
FONT                    resb 1220       ; Font array 61 characters by 5, 10 or 20 bytes each
TILENAMES               resb 3072       ; Array that stores all of the tile names.
TILEATTRIB              resb 256        ; 8-Bit attribute for each tile
TILEDESTRUCT            resb 256        ; Destruct path for each tile
TILESTRENGTH            resb 256        ; Strength for each tile
MAPSEG                  dw 0            ; Main Map DS segment
TILESEG                 dw 0            ; TILE ARRAY DS segment
oldINT08                dd ?            ; 32-bit var for old interrupt vector
SCRATCHSEG              dw 0            ; "extra" seg in case you need scratch
TIMER_COUNT             dw ?    ; Keeps track of the number of PIT cycles, when it overflows
                                ; the BIOS timer interrupt handler must be called
UNIT_SCAN               db 0    ; Active background unit
UNIT_SCAN_PADDING       db 0    ; Zero padding to enable WORD access to UNIT_SCAN
INFO_TIMER1             db 0    ; Keeps track of when to scroll the info text
INFO_TIMER2             db 0    ; Keeps track of how many times it has scrolled.
TILELOADSEG             dw ?    ; Segment in which to initially load the tile data
old_mode                db ?    ; stores the BIOS video mode number at program start
mirror_settings         db 0
in_intro_menu           db 0    ; are we in the intro menu? -- used for read error messages
screen_xor              dw 0    ; for inverted colors in 2-color CGA mode: either 0 or 0ffffh
cmd_arg_v               db 0    ; video mode requested via command line
cmd_arg_a               db 0    ; audio mode requested via command line
cmd_arg_i               db 0    ; inverted colors requested via command line
cmd_arg_o               db 0    ; override VGA or CG2 tile set via BPP value: 2=CGA, 4=TDY
cmd_arg_p               dw 0    ; port number set via command line (for audio devices)
cmd_arg_g               db 0    ; switch the selected video mode to grayscale if possible
cmd_arg_f               db 0    ; skip hardware detection and all sanity checks
cmd_arg_c               db 0    ; override the one freely selectable color in CGA mode
cmd_arg_m               db 0    ; start with music disabled
cmd_arg_r               db 0    ; rotate composite colors 0-3 times
track_not_loaded        db 0    ; makes music files optional (silence instead of a crash)
video_hw                dw 0    ; stores bit flags for detected video hardware
cga_color_override      db 0    ; requested value for the one freely selectable CGA color
maplist_loaded          db 0    ; has there been an attempt to load maplist.bin?
active_track            db 0    ; the music track most recently passed to m_loadmusic

VIDEO_HW_VGA            equ     1b
VIDEO_HW_EGA            equ     10b
VIDEO_HW_MDA_LIKE       equ     100b
VIDEO_HW_PCJR_OR_TANDY  equ     1000b
VIDEO_HW_ETGA           equ     10000b
VIDEO_HW_TANDY          equ     100000b
VIDEO_HW_CGA_LIKE       equ     1000000b
VIDEO_HW_MCGA           equ     10000000b
VIDEO_HW_EGA128         equ     100000000b
VIDEO_HW_EGA256         equ     1000000000b

VIDEO_HW_CGA_OR_BETTER  equ     VIDEO_HW_CGA_LIKE | VIDEO_HW_PCJR_OR_TANDY | VIDEO_HW_TANDY | VIDEO_HW_ETGA | VIDEO_HW_EGA | VIDEO_HW_VGA
VIDEO_HW_PCJR_OR_BETTER equ     VIDEO_HW_PCJR_OR_TANDY | VIDEO_HW_TANDY | VIDEO_HW_ETGA
VIDEO_HW_COMPOSITE      equ     VIDEO_HW_CGA_LIKE | VIDEO_HW_PCJR_OR_BETTER


VIDEOMENU               db "aq",10,"Choose Video Mode: (/v)",13,10
                        db "-----------------------",13,10
                        db "a-CGA Monochrome  640x200 / 2-color",13,10
                        db "b-Hercules        640x300 / 2-color",13,10
                        db "c-EGA Mono (256k) 640x350 / 3-color     (accelerated)",13,10
                        db "d-CGA             320x200 / 4-color",13,10
                        db "e-CGA Composite   160x200 / 16-color",13,10
                        db "f-CGA 8x2 Chars   320x200 / 16-color    (text mode)",13,10
                        db "g-Tandy (PC Jr.)  160x200 / 16-color",13,10
                        db "h-Plantronics     320x200 / 16-color    (doubled pixels)",13,10
                        db "i-Tandy           320x200 / 16-color",13,10
                        db "j-Plantronics     320x200 / 16-color",13,10
                        db "k-EGA (64k)       320x200 / 16-color    (reserved, not implemented)",13,10
                        db "l-VGA (MCGA)      320x200 / 256-color",13,10
                        db "m-VGA (mode Y)    320x200 / 256-color   (accelerated)",13,10
                        db "n-Tandy (ETGA)    640x200 / 16-color",13,10
                        db "o-EGA (128k)      640x200 / 16-color    (accelerated)",13,10
                        db "p-ATI-GS          640x200 / 16-color",13,10
                        db "q-Amstrad PC1512  640x200 / 16-color",13,10
                        db "$"

                        ; NOTE: Video modes using the VGA artwork are grouped together.
                        ; NOTE: There is no need to explicitly reserve letters for hypothetical future video modes
                        ;       with 640x200 or more pixels and 16 colors, because they can simply be appended.
