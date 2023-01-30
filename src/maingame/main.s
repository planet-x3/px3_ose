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
; - Jim Leonard**
; - Benedikt Freisen
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

[bits 16]
[org 100h]

; CODE SEGMENT
        jmp     planetx3_start

%include "globals.s"                    ; a large block of global variables and some macros

%include "savegame.s"                   ; global variables for the (saved) game state
%include "coords.s"                     ; global variables and init code for on-screen positions
%include "modevars.s"                   ; global variables and init code for video mode specifics
%include "scrl_clr.s"                   ; scroll_up_*, clear_rect_*, calc_screen_offset_*
%include "choice.s"                     ; Simple menu-get-keystroke function
%include "soundsup.s"                   ; Supplimental sound vars and code
%include "cmdline.s"                    ; command line parser

planetx3_start:
        mov     ah,0fh                  ; save BIOS video mode number
        int     10h
        mov     [old_mode],al

        call    setup_new_interrupt     ; hook irq0/int8 and speed to 72Hz
                                        ; setup_new_interrupt must be first
        call    parse_command_line

        call    ask_video
        call    ask_sound

        mov     ax,ds
        add     ax,((end_of_code+15+1024)>>4)-1000h     ; skip over code & reserve space for stack
        cli
        mov     ss,ax
        mov     sp,0
        sti
        add     ax,1000h

        mov     [MAPSEG],ax             ; MAPSEG = start of memory beyond .COM
        mov     cx,8000h                ; reserve 32K for maps
        call    clearmem                ; clear MAPSEG
        shr     cx,4                    ; convert seg size into paragraphs
        add     ax,cx                   ; add to determine next segment

        mov     [TILESEG],ax            ; TILESEG = ds+MAPSEG
        mov     [TILELOADSEG],ax
        add     ax,[tileseg_paragraphs]

        mov     [SSY_SEG],ax            ; define SSY_SEG
        mov     cx,[ssy_seg_paragraphs]
        shl     cx,4
        sbb     cx,0                    ; take care of overflow in 1000h << 4
        call    clearmem
        add     ax,[ssy_seg_paragraphs]

        mov     [SCRATCHSEG],ax         ; SCRATCHSEG = ds+MAPSEG+SSY_SEG
                                        ; not going to clear scratchseg,
                                        ; because it immediately gets
                                        ; overwritten with compressed data

        ; configure extra segment to video ram
        mov     es,[VIDEO_SEG]

        call    LOAD_FONT               ; load font here, so that set_video can convert its format
        call    set_video
        call    set_sound
        call    RESET_KEYBOARD_REPEAT_RATE
        mov     byte [GAME_DIFF],0
        call    SET_DIFF
        call    SET_MAP_NAME

        ; ---------- INIT_PROGRAM ----------
        call    prepare_intro_env
        mov     word [menu_context],intro_menu_items
        call    show_menu

        ; Let's do a nice fadeout before exiting to DOS.  First clear
        ; scratchseg, then fade scratchseg to the screen.
        push    es
        mov     ax,[SCRATCHSEG]
        mov     es,ax
        xor     di,di
        mov     ax,di
        mov     cx,[framebuf_size]
        shr     cx,1
        rep     stosw
        pop     es

        push    ds
        mov     ax,[SCRATCHSEG]
        mov     ds,ax
        xor     si,si
        mov     di,si
        call    fadestart
        pop     ds

        xor     ax,ax                   ; exit code of 0 for clean exit
        call    EXITPROG
        db      'Engine: Planet X3 Open Source Edition',13,10
        db      'Version ',GIT_TAG,GIT_MODIFIED,13,10
        db      'Source code available under GPL. See',13,10
        db      'https://github.com/planet-x3/px3_ose',13,10
        db      13,10
        db      'Have a nice DOS!',13,10,0

start_game:
        mov     si,FILENAME_IN
        call    LOAD_SCREEN             ; gameplay screen
        ; HACK: clear last line in Hercules mode to work around a graphical bug
        cmp     word [set_video_mode],set_hercules_640x300x2
        jne     .S0
        mov     di,(8192*2)+(99*80)
        xor     ax,ax
        mov     cx,40
        rep     stosw
.S0:
        mov     byte [in_intro_menu],0
        ; keep playing the jukebox music track unless it is the MENU, WIN or LOSE track
        cmp     byte [active_track],0
        je      .load_track_for_map
        cmp     byte [active_track],8
        je      .load_track_for_map
        cmp     byte [active_track],9
        je      .load_track_for_map
        jmp     .keep_playing_active_track
        .load_track_for_map:
        call    m_loadmapmusic
        .keep_playing_active_track:
        cmp     byte [ssy_default_music_on],0   ; music disabled by default
        jne     .L1
        mov     byte [MUSIC_ON],0               ; disable music by default for PC-Speaker
        call    m_setmusicstate
        .L1:
        call    LOAD_TILES
        call    LOAD_DATA
        call    LOAD_MAP
        call    mirror_map_as_necessary
        call    RESET_GAME
        call    WRITE_COORDINATES
        call    WRITE_RESOURCES
        mov     byte [BROWSE_MODE],0
        call    FIND_MAP_OFFSET
        call    force_draw_entire_screen
        call    DRAW_FLYING_OBJECTS
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        call    MAINLOOP
        ret

; description:
;       Prepare the environment for the intro menu screen.
prepare_intro_env:
        call    CLEAR_ALL_UNIT_VARIABLES
        mov     byte [END_GAME_DETECTED],0
        mov     si,FILENAME_MENU
        call    LOAD_SCREEN
        mov     byte [in_intro_menu],1
        cmp     byte [ssy_default_music_on],1
        je      .skip_reenable_music
        cmp     byte [cmd_arg_m],1
        je      .skip_reenable_music
        mov     byte [MUSIC_ON],1
        .skip_reenable_music:
        call    [ssy_init_in_menu]
        cmp     byte [maplist_loaded],1
        je      .maplist_already_loaded
        call    load_maplist
        mov     byte [maplist_loaded],1
        .maplist_already_loaded:
        call    m_loadmenu
        ret

; description:
;       Ask user for video mode they want to play the game in.
ask_video:
        ; Ask user for video mode
        push    si
        mov     si,VIDEOMENU
        ; if a valid mode has been requested via command line, use that one instead
        mov     al,[cmd_arg_v]
        cmp     al,[si]                 ; compare to start of allowed character range
        jb      .ask_anyway
        cmp     al,[si+1]               ; compare to end of allowed character range
        ja      .ask_anyway
        jmp     .skip
        .ask_anyway:
        call    askchoice
        .skip:
        pop     si
        mov     bh,0
        mov     bl,al
        sub     bx,'a'
        cmp     bx,17                   ; highest mode number
        jnb     ask_video
        shl     bx,1
        mov     si,[.block_addr_lut+bx]
        tcall   set_mode_vars           ; tail call

.block_addr_lut dw      mode_vars_cg2
                dw      mode_vars_hercules
                dw      mode_vars       ; reserved for monochrome EGA
                dw      mode_vars
                dw      mode_vars_cmp
                dw      mode_vars_text
                dw      mode_vars_ltdy
                dw      mode_vars_plantronics
                dw      mode_vars_mtdy
                dw      mode_vars_plantronics_2
                dw      mode_vars       ; reserved for low-res EGA
                dw      mode_vars_vga
                dw      mode_vars_vga_y
                dw      mode_vars_etga
                dw      mode_vars_ega
                dw      mode_vars_atigs
                dw      mode_vars_pc1512

%include "setmode.s"                    ; video mode initialization
%include "convert.s"                    ; conversion functions for tile graphics and fade-in
%include "ega.s"                        ; EGA routines
%include "atigs.s"                      ; ATI Graphics Solution routines
%include "etga.s"                       ; Tandy Video II (ETGA) routines
%include "hercules.s"                   ; Hercules Graphics Card routines
%include "pcplus.s"                     ; Plantronics ColorPlus routines
%include "backgrnd.s"                   ; background AI routines
%include "builder.s"                    ; builder routines
%include "diskio.s"                     ; disk load routines
%include "menus.s"                      ; game menus
%include "plot8pix.s"                   ; plot8pix functions for radar etc.
%include "radar.s"                      ; radar station scan routines
%include "plot_cur.s"                   ; plot_cursor_* functions
%include "scrdraw.s"                    ; draws tiles on the screen
%include "textout.s"                    ; draws text on the screen
%include "windows.s"                    ; draws command and status windows
%include "soundsys.s"                   ; Sound/music routines by Alex
%include "interrup.s"                   ; interrupt handling
%include "mpu.s"                        ; MPU routines
%include "eventdec.s"                   ; MIDI player
%include "gameover.s"                   ; End-game screen
%include "game.s"

%if     DIAGS
%include "diagscr.s"                    ; Diagnostic screen
%endif

FILENAME_TILES  db "TILES.CMP",0
FILENAME_DATA   db "TILEDATA.DAT",0
FILENAME_MLUTS  db "MIRRORS-.DAT",0
FILENAME_IN     db "SCREEN1.CMP",0
FILENAME_FONT   db "FONT.CMP",0
FILENAME_SG     db "SAVEGAME.DAT",0
FILENAME_MENU   db "MENU.CMP",0
MAP_NAME        db "MAP--.MAP",0        ; Map name
HEXARRAY        db "0123456789ABCDEF"

%include "palsluts.s"

SET_VGA_PALETTE:
        mov     cl,0                    ; PALETTE NUMBER
        mov     si,VGA_PALETTE
        .L1:
        mov     al,cl
        mov     dx,03C8H                ; DAC WRITE
        out     dx,al
        mov     dx,03C9H                ; DAC DATA
        lodsb
        shr     al,2
        out     dx,al                   ; DAC DATA RED
        lodsb
        shr     al,2
        out     dx,al                   ; DAC DATA GREEN
        lodsb
        shr     al,2
        out     dx,al                   ; DAC DATA BLUE
        inc     cl
        jnz     .L1
        ret

; This exit procedore is now a combined exit+error handler.  To exit, you must
; use CALL EXITPROG and then the very next line MUST be a DB 'message',0 statement.
; The program will exit, printing that message.
EXITPROG:
        mov     bp,ax                   ; save any exit code we might get
        call    [restore_old_mode]
        cmp     byte [SOUND_INITIALIZED],1
        jne     .S0
        call    ssy_music_stop          ; stop music playing
.S0:
        call    restore_old_interrupt   ; restore old int08
        cmp     byte [SOUND_INITIALIZED],1
        jne     .S1
        call    ssy_shut                ; shut down music code
.S1:

; This next part prints the string whose address was pushed onto the stack.
        pop     di                      ; We're never returning from here,
                                        ; so use return address as message ptr
.M0:
        mov     al,[cs:di]              ; get next char of message
        inc     di
        test    al,al                   ; is al=0?
        je      .E0                     ; exit if so
        int     29h                     ; DOS fast character I/O
        jmp     .M0
        push    di                      ; restore stack

; Finally, exit the program.
.E0:
        mov     ax,bp                   ; restore exit code
        mov     ah,4ch                  ; We want subfunction 4c
        int     21h


end_of_code:                            ; this is where our other segments start
