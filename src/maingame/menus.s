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

CLEAR_MENU_WINDOW:
        mov     di,[rect_menu]
        mov     cx,68
        mov     bx,56
        jmp     [clear_rect]

GAME_MENU:
        mov     word [menu_context],game_menu_items
        tcall   show_menu

; description:
;       Prepare menu entry strings of the in-game menu.
game_menu_prepare_entries:
        ; adjust screen width string
        cmp     byte [SCREEN_WIDTH],19
        je      .screen_width_st
        mov     byte [GAME_MENU01+61],"R"
        mov     byte [GAME_MENU01+62],"E"
        jmp     .after_screen_width
        .screen_width_st:
        mov     byte [GAME_MENU01+61],"S"
        mov     byte [GAME_MENU01+62],"T"
        .after_screen_width:

        ; adjust music state string
        cmp     byte [MUSIC_ON],1
        jne     .music_off
        mov     byte [GAME_MENU01+91],"N"
        mov     byte [GAME_MENU01+92]," "
        jmp     .after_music
        .music_off:
        mov     byte [GAME_MENU01+91],"F"
        mov     byte [GAME_MENU01+92],"F"
        .after_music:

        ; adjust sound effects string
        cmp     byte [SOUNDFX_ON],1
        jne     .sound_fx_off
        mov     byte [GAME_MENU01+108],"N"
        mov     byte [GAME_MENU01+109]," "
        jmp     .after_sound_fx
        .sound_fx_off:
        mov     byte [GAME_MENU01+108],"F"
        mov     byte [GAME_MENU01+109],"F"
        .after_sound_fx:

        ; adjust transparency string
        cmp     byte [VIDEO_TRANS],1
        je      .transparency_on
        ; transparency is off
        call    fill_transparent_pixels
        mov     byte [menu_string_transparency_on+14],"F"
        mov     byte [menu_string_transparency_on+15],"F"
        jmp     .after_transparency
        .transparency_on:
        ; transparency is on
        mov     byte [menu_string_transparency_on+14],"N"
        mov     byte [menu_string_transparency_on+15]," "
        .after_transparency:

        ret

fill_transparent_pixels:
        ret

; data structure for the in-game menu
game_menu_items:
        ; menu description
        dw      xy(96,60)               ; top left coordinate
        db      8,0                     ; highest index, index for ESC
        dw      CLEAR_MENU_WINDOW       ; clear background func
        dw      game_menu_prepare_entries       ; prepare entries func
        ; index 0: return to game
        dw      GAME_MENU01
        dw      0
        db      9,255                   ; sound effect, priority
        dw      0                       ; 0: no redraw
        ; index 1: save game
        dw      GAME_MENU02
        dw      SAVE_GAME ; game_menu_func_save
        db      9,255                   ; sound effect, priority
        dw      3                       ; 3: redraw menu incl. bg
        ; index 2: load game
        dw      GAME_MENU03
        dw      LOAD_GAME ; game_menu_func_load
        db      9,255                   ; sound effect, priority
        dw      3                       ; 3: redraw menu incl. bg
        ; index 3: screen width
        dw      GAME_MENU04
        dw      CHANGE_SCREEN_WIDTH
        db      7,255                   ; sound effect, priority
        dw      3                       ; 3: redraw menu incl. bg
        ; index 4: mode specific -- overwritten by set_mode_vars
        dw      0
        dw      0
        db      7,255                   ; sound effect, priority
        dw      3                       ; 3: redraw menu incl. bg
        ; index 5: music
        dw      GAME_MENU06
        dw      TOGGLE_MUSIC            ; actual beep stays in here
        db      0,0                     ; sound effect, priority
        dw      1                       ; 1: redraw entry
        ; index 6: sound fx
        dw      GAME_MENU07
        dw      TOGGLE_SOUNDFX
        db      7,255                   ; sound effect, priority
        dw      1                       ; 1: redraw entry
        ; index 7: mouse ctrl
        dw      GAME_MENU08
        dw      HHG_JOKE ; game_menu_hhg_joke
        db      7,255                   ; sound effect, priority
        dw      3                       ; 3: redraw menu incl. bg
        ; index 8: exit game
        dw      GAME_MENU09
        dw      0
        db      9,255                   ; sound effect, priority
        dw      0                       ; 0: no redraw

; description:
;       Handler function for the LOAD GAME entry.
LOAD_GAME:
        call    LOAD_GAME_DISKIO
        mov     al,[TILE_SET]
        mov     [FILENAME_TILES+4],al   ; set tile-set filename
        mov     [FILENAME_DATA+7],al    ; set data filename
        call    LOAD_TILES
        call    LOAD_DATA
        call    FIND_MAP_OFFSET
        call    force_draw_entire_screen
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        call    UPDATE_CLOCK
        call    WRITE_RESOURCES
        call    CLEAR_MENU_WINDOW
        mov     di,[textpos_ldsav1]
        mov     si,TEXT_GS3
        call    WRITE_TEXT
        mov     di,[textpos_ldsav2]
        mov     si,TEXT_GS2
        call    WRITE_TEXT
        .L1:
        xor     ah,ah                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     al,0
        je      .L1
        ret

; description:
;       Handler function for the SAVE GAME entry.
SAVE_GAME:
        call    CLEAR_MENU_WINDOW
        call    SAVE_GAME_DISKIO
        mov     di,[textpos_ldsav1]
        mov     si,TEXT_GS1
        call    WRITE_TEXT
        mov     di,[textpos_ldsav2]
        mov     si,TEXT_GS2
        call    WRITE_TEXT
        .L1:
        xor     ah,ah                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     al,0
        je      .L1
        ret

; description:
;       Handler function for the MOUSE CTRL entry.
HHG_JOKE:
        call    CLEAR_MENU_WINDOW
        mov     di,[textpos_hhg1]
        mov     si,TEXT_HHG1
        call    WRITE_TEXT
        mov     di,[textpos_hhg2]
        mov     si,TEXT_HHG2
        call    WRITE_TEXT
        mov     di,[textpos_hhg3]
        mov     si,TEXT_HHG3
        call    WRITE_TEXT
        .L1:
        xor     ah,ah                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     al,0
        je      .L1
        mov     al,09                   ; menu beep
        mov     ah,255                  ; priority
        call    m_playSFX               ; play sound effect
        ret

; description:
;       Handler function for the SCREEN WIDTH entry.
CHANGE_SCREEN_WIDTH:
        cmp     byte [SCREEN_WIDTH],19
        je      .L1
        mov     byte [SCREEN_WIDTH],19
        jmp     .L2
        .L1:
        mov     byte [SCREEN_WIDTH],11
        .L2:
        call    CLEAR_PLAYFIELD_WINDOW
        call    FIND_MAP_OFFSET
        call    force_draw_entire_screen
        ret

; description:
;       Handler function for the MUSIC entry.
TOGGLE_MUSIC:
        xor     byte [MUSIC_ON],1       ; toggle var between 1 and 0
        call    m_setmusicstate         ; enable or disable based on variable
        ; NOTE: the beep has to stay here, because m_setmusicstate would cut it off
        mov     al,07                   ; beep
        mov     ah,255                  ; priority
        call    m_playSFX               ; play sound effect
        ret

; description:
;       Handler function for the SOUNDFX entry.
TOGGLE_SOUNDFX:
        xor     byte [SOUNDFX_ON],1     ; toggle var between 1 and 0
        ret

; description:
;       Handler function for the TRANSPARENCY entry.
TOGGLE_TRANS:
        cmp     byte [VIDEO_TRANS],1
        je      .L1
        mov     byte [VIDEO_TRANS],1
        ; transparency is on
        ; skip tile reloading for non-VGA tile sets
        cmp     byte [cmd_arg_o],"2"
        je      .do_not_reload
        cmp     byte [cmd_arg_o],"4"
        je      .do_not_reload
        call    LOAD_TILES
        .do_not_reload:
        ret
        .L1:
        ; transparency is off
        mov     byte [VIDEO_TRANS],0
        call    fill_transparent_pixels
        ret

; description:
;       Handler function for the CGA PALETTE entry.
ROTATE_CGA_PALETTE:
        ; Cycle through 4 of the 6 built-in CGA 320x200x4 palettes
        push    ax,dx
        mov     al,[CGA_PALETTE]
        inc     al
        and     al,00000011b            ; ensure we stay within 0-3
        mov     [CGA_PALETTE],al        ; store for next time
        ; Set BIOS mode so that VGA will show at least the two main palettes
        cmp     byte [cmd_arg_g],1
        je      .is_gray
        push    ax
        and     al,1                    ; limit to the two palettes VGA can do
        mov     bh,1                    ; set CGA palette
        mov     bl,al                   ; which palette to use?
        mov     ah,0bh                  ; palette change sub-command
        int     10h                     ; BIOS interrupt
        pop     ax
        .is_gray:
        ; Now use CGA hardware to show low and high intensity as appropriate
        ; This does nothing on VGA which is why we use BIOS before this.
        shl     al,4                    ; shift pal. & inten. bits into place
        mov     dx,03d9h                ; CGA color select register
        out     dx,al
        pop     dx,ax
        ret

ROTATE_CGA_DATA:
        call    INVERT_COLORS
        call    INVERT_SCREEN
        ret

INVERT_CGA_DATA:
        call    INVERT_TILES_BW
        call    INVERT_SCREEN_BW
        call    toggle_inverted
        ret

toggle_inverted:
        ret

; data structure for the intro menu
intro_menu_items:
        ; menu description
        dw      xy(96,142)              ; top left coordinate
        db      4,4                     ; highest index, index for ESC
        dw      dummy_func              ; clear background func
        dw      intro_menu_prepare_entries      ; prepare entries func
        ; index 0: start game
        dw      INTRO_MENU01            ; string
        dw      intro_menu_func_start_game
        db      9,255                   ; sound effect, priority
        dw      3                       ; 3: redraw menu incl. bg
        ; index 1: credits
        dw      INTRO_MENU02            ; string
        dw      DISPLAY_CREDITS
        db      9,255                   ; sound effect, priority
        dw      3                       ; 3: redraw menu incl. bg
        ; index 2: map
        dw      INTRO_MENU03            ; string
        dw      IMENU_NEXT_MAP
        db      7,255                   ; sound effect, priority
        dw      1                       ; 1: redraw entry
        ; index 3: game settings
        dw      settings_menu02         ; string
        dw      intro_menu_func_game_settings
        db      9,255                   ; sound effect, priority
        dw      3                       ; 3: redraw menu incl. bg
        ; index 4: exit to dos
        dw      INTRO_MENU05            ; string
        dw      0                       ; null pointer: return
        db      9,255                   ; sound effect, priority
        dw      0                       ; 0: no redraw

settings_menu01         db      "LEAVE THIS MENU "
settings_menu02         db      "GAME SETTINGS..."
settings_menu03         db      "MIRRORED (H):OFF"
settings_menu04         db      "MIRRORED (V):OFF"
settings_climate_grassy db      "CLIMATE:GRASSY  "
settings_climate_snowy  db      "CLIMATE:SNOWY   "
settings_climate_desert db      "CLIMATE:DESERT  "

; data structure for the game settings menu
settings_menu_items:
        ; menu description
        dw      xy(96,142)              ; top left coordinate
        db      4,0                     ; highest index, index for ESC
        dw      dummy_func              ; clear background func
        dw      settings_menu_prepare_entries   ; prepare entries func
        ; index 0: leave this menu
        dw      settings_menu01
        dw      0
        db      9,255                   ; sound effect, priority
        dw      0                       ; 0: no redraw
        ; index 1: set difficulty
        dw      INTRO_MENU04
        dw      SET_DIFF
        db      7,255                   ; sound effect, priority
        dw      1                       ; 1: redraw entry
        ; index 2: mirrored (h)
        dw      settings_menu03
        dw      settings_menu_func_mirrored_h
        db      7,255                   ; sound effect, priority
        dw      1                       ; 1: redraw entry
        ; index 3: mirrored (v)
        dw      settings_menu04
        dw      settings_menu_func_mirrored_v
        db      7,255                   ; sound effect, priority
        dw      1                       ; 1: redraw entry
        ; index 4: climate
        dw      settings_climate_grassy
        dw      settings_menu_func_climate
        db      7,255                   ; sound effect, priority
        dw      1                       ; 1: redraw entry

menu_context    dw      0

; description:
;       Redraws item TEMP_Y of menu menu_context.
display_menu_item:
        mov     ax,[font_bg_norm_bright]
        mov     word [font_bg_color],ax
        mov     byte [TEMP_X],0

        mov     al,6
        mov     bl,[TEMP_Y]
        mul     bl
        mov     ah,al
        mov     al,0
        mov     si,[menu_context]
        add     ax,[si]                 ; add top left coordinate from menu context
        mov     di,ax
        call    [calc_screen_offset]

        mov     ah,0
        mov     al,[TEMP_Y]
        inc     ax
        shl     ax,3                    ; multiply by 8
        mov     si,ax
        add     si,[menu_context]
        mov     si,[si]
        mov     cx,16
        mov     al,[MENU_SEL]
        cmp     al,[TEMP_Y]
        je      .L1
        tcall   [plot_string]           ; tail call
.L1:
        tcall   [plot_string_color]     ; tail call

; description:
;       Redraws the menu from menu_context.
display_menu:
        mov     byte [TEMP_Y],0
        .L1:
        call    display_menu_item
        inc     byte [TEMP_Y]
        mov     si,[menu_context]
        mov     al,[si+2]               ; get highest menu index
        cmp     byte [TEMP_Y],al
        jbe     .L1
        ret

; description:
;       Shows the menu from menu_context and handles key presses.
show_menu:
        mov     si,[menu_context]
        call    [si+4]                  ; clear background func
        mov     si,[menu_context]
        call    [si+6]                  ; prepare entries func
        mov     byte [MENU_SEL],0
        call    display_menu
        .L1:                            ; intro menu getkey
        xor     ah,ah                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     ah,048h                 ; Up arrow
        jne     .L5
        call    move_menu_selection_up
        jmp     .L1
        .L5:
        cmp     ah,050h                 ; Down arrow
        jne     .L6
        call    move_menu_selection_down
        jmp     .L1
        .L6:
        cmp     al,0dh                  ; ENTER key
        jne     .L7
        jmp     .L8
        .L7:
        cmp     ah,1                    ; ESC key
        jne     .not_esc
        mov     si,[menu_context]
        mov     al,[si+3]               ; menu index for ESC
        mov     [MENU_SEL],al
        jmp     .L8                     ; continue with that index
        .not_esc:
        call    extra_key_handler
        jmp     .L1
        .L8:                            ; intro menuexecute
        mov     bl,[MENU_SEL]
        mov     bh,0
        inc     bx
        shl     bx,3
        add     bx,[menu_context]
        push    bx
        mov     ax,[bx+4]               ; get sound effect and priority
        or      ax,ax
        jz      .skip_sfx
        call    m_playSFX
        .skip_sfx
        pop     bx
        push    bx
        mov     bx,[bx+2]
        cmp     bx,0
        je      .end
        push    word [menu_context]
        call    bx
        pop     word [menu_context]
        pop     bx
        cmp     byte [bx+6],1           ; redraw mode?
        jb      .after_redraw
        push    bx
        pushf
        mov     si,[menu_context]
        call    [si+6]                  ; prepare entries func
        popf
        pop     bx
        jne     .redraw_all_entries
        mov     al,[MENU_SEL]
        mov     [TEMP_Y],al
        call    display_menu_item
        jmp     .after_redraw
        .redraw_all_entries:
        cmp     byte [bx+6],3           ; redraw mode?
        jne     .skip_clear_bg
        mov     si,[menu_context]
        call    [si+4]                  ; clear background func
        .skip_clear_bg:
        call    display_menu
        .after_redraw:
        jmp     .L1
        .end:
        pop     bx
        ret

; description:
;       Extra key handler for the intro menu.
;       This is currently just the intro menu jukebox that uses the keys 0-9.
;       On MT-32, the four additional tracks can be accessed with SHIFT + 1-4.
; parameters:
;       al: ASCII code
;       ah: scan code
extra_key_handler:
        cmp     ah,2                    ; scan for keys 0-9
        jb      .L20
        cmp     ah,0bh
        ja      .L20
        mov     al,ah
        sub     al,2
        cmp     byte [ssy_file_name_marker],'M'
        jne     .no_additional_tracks
        push    ax
        mov     ah,2                    ; get shift flags
        int     16h
        mov     bl,0
        test    al,3                    ; bits 0 and 1 are shift keys
        jz      .no_shift
        mov     bl,10
        .no_shift:
        pop     ax
        add     al,bl
        cmp     al,MT32_INIT_INDEX      ; MT-32 init track comes after last music track
        jb      .no_additional_tracks
        sub     al,10                   ; not enough tracks => ignore shift
        .no_additional_tracks:
        call    m_loadmusic             ; load music track al
        .L20:
        ret

settings_menu_prepare_entries:
        test    byte [mirror_settings],1
        jz      .h_off
        mov     byte [settings_menu03+14],"N"
        mov     byte [settings_menu03+15]," "
        jmp     .h_end
        .h_off:
        mov     byte [settings_menu03+14],"F"
        mov     byte [settings_menu03+15],"F"
        .h_end:
        test    byte [mirror_settings],2
        jz      .v_off
        mov     byte [settings_menu04+14],"N"
        mov     byte [settings_menu04+15]," "
        jmp     .v_end
        .v_off:
        mov     byte [settings_menu04+14],"F"
        mov     byte [settings_menu04+15],"F"
        .v_end:
        ; update climate entry
        cmp     byte [FILENAME_TILES+4],"1"
        jne     .snowy_or_desert
        ; grassy
        mov     word [settings_menu_items+8+(4*8)],settings_climate_grassy
        ret
        .snowy_or_desert:
        cmp     byte [FILENAME_TILES+4],"2"
        jne     .desert
        ; snowy
        mov     word [settings_menu_items+8+(4*8)],settings_climate_snowy
        ret
        .desert:
        mov     word [settings_menu_items+8+(4*8)],settings_climate_desert
        ret

settings_menu_func_mirrored_h:
        xor     byte [mirror_settings],1
        ret

settings_menu_func_mirrored_v:
        xor     byte [mirror_settings],2
        ret

settings_menu_func_climate:
        mov     al,[FILENAME_TILES+4]
        mov     bl,[MAP_NUMBER]
        mov     bh,0
        cmp     al,[MAPTILESET+bx]
        jne     .is_alt1_or_alt2
        ; is default tile set
        cmp     byte [MAPTILESET_ALT1+bx],"0"
        je      .end
        ; advance to alt1
        mov     al,[MAPTILESET_ALT1+bx]
        mov     byte [TILE_SET],al
        mov     byte [FILENAME_TILES+4],al
        mov     byte [FILENAME_DATA+7],al
        jmp     .end
        .is_alt1_or_alt2:
        cmp     al,[MAPTILESET_ALT1+bx]
        jne     .is_alt2
        ; is alt1
        cmp     byte [MAPTILESET_ALT2+bx],"0"
        je      .back_to_default
        ; advance to alt2
        mov     al,[MAPTILESET_ALT2+bx]
        mov     byte [TILE_SET],al
        mov     byte [FILENAME_TILES+4],al
        mov     byte [FILENAME_DATA+7],al
        jmp     .end
        .back_to_default:
        mov     al,[MAPTILESET+bx]
        mov     byte [TILE_SET],al
        mov     byte [FILENAME_TILES+4],al
        mov     byte [FILENAME_DATA+7],al
        jmp     .end
        .is_alt2:
        ; back to default
        mov     al,[MAPTILESET+bx]
        mov     byte [TILE_SET],al
        mov     byte [FILENAME_TILES+4],al
        mov     byte [FILENAME_DATA+7],al
        .end:
        ret

intro_menu_func_start_game:
        call    start_game
        call    prepare_intro_env
        mov     byte [MENU_SEL], 0
        ret

intro_menu_func_game_settings:
        mov     word [menu_context],settings_menu_items
        mov     byte [MENU_SEL],0
        call    show_menu
        mov     byte [MENU_SEL],3
        ret

SET_DIFF:
        inc     byte [GAME_DIFF]
        cmp     byte [GAME_DIFF],3
        jne     .L1
        mov     byte [GAME_DIFF],0
        .L1:
        mov     al,[GAME_DIFF]
        shl     al,2                    ; multiply by 4
        mov     ah,0
        mov     si,ax
        mov     di,59
        mov     cl,0
        .L2:
        mov     al,MENU_DIFF[si]
        mov     byte INTRO_MENU01[di],al
        inc     di
        inc     si
        inc     cl
        cmp     cl,4
        jne     .L2
        ret

IMENU_NEXT_MAP:
        inc     byte [MAP_NUMBER]
        mov     ah,[num_maps_ascii]
        sub     ah,'0'
        mov     al,[num_maps_ascii+1]
        sub     al,'0'
        aad
        cmp     byte [MAP_NUMBER],al
        jne     .L1
        mov     byte [MAP_NUMBER],00
        .L1:
        call    SET_MAP_NAME
        ret

move_menu_selection_up:
        cmp     byte [MENU_SEL],0
        je      .L1
        mov     al,18                   ; selects short beep
        mov     ah,255                  ; priority
        call    m_playSFX               ; play sound effect
        mov     al,[MENU_SEL]
        mov     [TEMP_Y],al
        dec     byte [MENU_SEL]
        call    display_menu_item
        dec     byte [TEMP_Y]
        call    display_menu_item
        .L1:
        ret

move_menu_selection_down:
        mov     si,[menu_context]
        mov     al,[si+2]               ; get highest menu index
        cmp     byte [MENU_SEL],al
        je      .L1
        mov     al,18                   ; selects short beep
        mov     ah,255                  ; priority
        call    m_playSFX               ; play sound effect
        mov     al,[MENU_SEL]
        mov     [TEMP_Y],al
        inc     byte [MENU_SEL]
        call    display_menu_item
        inc     byte [TEMP_Y]
        call    display_menu_item
        .L1:
        ret

intro_menu_prepare_entries:
        mov     al,[MAP_NUMBER]
        mov     ah,0
        shl     ax,4                            ; multiply by 16
        mov     si,ax
        mov     di,0
        .L1:
        mov     al,byte [cs:MAPNAMES+si]
        mov     byte [INTRO_MENU01+32+di],al    ; set map name
        inc     si
        inc     di
        cmp     di,16
        jne     .L1
        ret

SET_MAP_NAME:
        mov     al,[MAP_NUMBER]
        shl     al,1                            ; multiply by 2
        mov     ah,0
        mov     si,ax
        mov     ax,word [MAPFILES+si]
        mov     word [MAP_NAME+3],ax            ; set map filename
        mov     al,[MAP_NUMBER]
        mov     ah,0
        mov     si,ax
        mov     al,[MAPTILESET+si]
        mov     [TILE_SET],al
        mov     [FILENAME_TILES+4],al           ; set tile-set filename
        mov     [FILENAME_DATA+7],al            ; set data filename
        ret
