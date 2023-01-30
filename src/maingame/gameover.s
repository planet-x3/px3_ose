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

singleKeyExit   equ     1

GAMEOVER_SCREEN:
        ; clear_entire_screen
        mov     di,0
        mov     cx,160
        mov     bx,200
        call    [clear_rect]

        ; figure out who won
        mov     byte [MUSIC_ON],1
        cmp     byte [UNIT_COUNT_PLBLDG],0      ; did humans lose?
        je      .L1
        mov     al,8                    ; victory music
        call    m_loadmusic
        mov     si,GOVR01
        mov     di,[textpos_govr01]
        mov     ax,[font_bg_norm]
        mov     word [font_bg_color],ax
        jmp     .L3
        .L1:
        mov     al,9                    ; defeat music
        call    m_loadmusic
        mov     si,GOVR02
        mov     di,[textpos_govr02]
        mov     ax,[font_bg_alt]
        mov     word [font_bg_color],ax
        .L3:

        ; create rest of screen
        call    WRITE_TEXT_COLOR
        mov     si,GOVR03               ; humans
        mov     di,[textpos_govr03]
        call    WRITE_TEXT
        mov     si,GOVR04               ; protoids
        mov     di,[textpos_govr04]
        call    WRITE_TEXT

        ; horizontal line
        mov     di,xy(16,32)
        call    [calc_screen_offset]
        mov     bp,[radar_color_frame]
        mov     si,38
        .L4:
        mov     ch,11111111b
        call    [plot8pix]
        dec     si
        jnz     .L4
        ; vertical line
        mov     di,xy(144,34)
        mov     si,60
        .L5:
        push    di
        push    cx
        call    [calc_screen_offset]
        pop     cx
        mov     ch,00001000b
        call    [plot8pix]
        pop     di
        add     di,xy(0,1)
        dec     si
        jnz     .L5

        mov     di,[tilepos_govr_hq]
        mov     al,7ch                  ; headquarters
        call    plot_tile_in_gui_big

        mov     di,[tilepos_govr_py]
        mov     al,0cch                 ; pyramid
        call    plot_tile_in_gui_big

        mov     di,[tilepos_govr_hu]
        mov     al,57h                  ; human tank
        call    plot_tile_in_gui

        mov     di,[tilepos_govr_pr]
        mov     al,0abh                 ; protoid unit
        call    plot_tile_in_gui

        mov     ax,[font_bg_black]
        mov     word [font_bg_color],ax

        mov     si,GOVR05               ; buildings
        mov     di,[textpos_govr05l]
        call    WRITE_TEXT
        mov     si,GOVR05               ; buildings
        mov     di,[textpos_govr05r]
        call    WRITE_TEXT
        mov     si,GOVR06               ; ground units
        mov     di,[textpos_govr06l]
        call    WRITE_TEXT
        mov     si,GOVR06               ; ground units
        mov     di,[textpos_govr06r]
        call    WRITE_TEXT
        mov     si,GOVR07               ; elapsed time
        mov     di,[textpos_govr07]
        call    WRITE_TEXT

        mov     si,GOVR08               ; remaining resources
        mov     di,[textpos_govr08]
        call    WRITE_TEXT
        mov     si,GOVR09               ; minerals
        mov     di,[textpos_govr09]
        call    WRITE_TEXT
        mov     al,[QTY_MINERALS]
        mov     [HEXNUM],al
        call    WRITE_DECNUM
        mov     si,GOVR10               ; gas
        mov     di,[textpos_govr10]
        call    WRITE_TEXT
        mov     al,[QTY_GAS]
        mov     [HEXNUM],al
        call    WRITE_DECNUM
        mov     si,GOVR11               ; energy
        mov     di,[textpos_govr11]
        call    WRITE_TEXT
        mov     al,[QTY_ENERGY]
        mov     [HEXNUM],al
        call    WRITE_DECNUM

        mov     di,[numpos_govr_bch]
        mov     bl,"="
        call    PLOT_CHAR
        mov     al,[UNIT_COUNT_PLBLDG]  ; human building count
        mov     [HEXNUM],al
        call    WRITE_DECNUM
        mov     di,[numpos_govr_bcp]
        mov     bl,"="
        call    PLOT_CHAR
        mov     al,[UNIT_COUNT_ENBLDG]  ; protoid building count
        mov     [HEXNUM],al
        call    WRITE_DECNUM

        mov     di,[numpos_govr_uch]
        mov     bl,"="
        call    PLOT_CHAR
        mov     al,[UNIT_COUNT_PLUNITS] ; human unit count
        mov     [HEXNUM],al
        call    WRITE_DECNUM
        mov     di,[numpos_govr_ucp]
        mov     bl,"="
        call    PLOT_CHAR
        mov     al,[UNIT_COUNT_ENUNITS] ; protoid unit count
        mov     [HEXNUM],al
        call    WRITE_DECNUM

        mov     ax,word [cs:GAME_CLOCK_TICKS]
        shl     ax,2                            ; multiply by 4
        add     ax,word [cs:GAME_CLOCK_TICKS]   ; add it again to mult by 5
        mov     bx,91
        div     bl
        mov     byte [cs:GAME_CLOCK_SECONDS],al
        mov     al,byte [cs:GAME_CLOCK_HOURS]
        mov     [HEXNUM],al
        mov     di,[clockpos_govr]
        call    WRITE_DECNUM_2DIGIT
        mov     bl,":"
        call    PLOT_CHAR
        mov     al,byte [cs:GAME_CLOCK_MINUTES]
        mov     [HEXNUM],al
        call    WRITE_DECNUM_2DIGIT
        mov     bl,":"
        call    PLOT_CHAR
        mov     al,byte [cs:GAME_CLOCK_SECONDS]
        mov     [HEXNUM],al
        call    WRITE_DECNUM_2DIGIT

        mov     ax,[font_bg_norm]
        mov     word [font_bg_color],ax
        mov     si,GOVR80
        mov     di,[textpos_govr80]
        call    WRITE_TEXT_COLOR

        %IF singleKeyExit
.L10:   ; Wait for the letter "M", then continue
        xor     ax,ax
        int     16h                     ; Wait for a keystroke
        cmp     ah,032h                 ; 'm'
        jne     .L10
        %ELSE
.L10a:  ; wait for keypress (but ignore cursor keys)
        mov     ah,0                    ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     ah,04Bh                 ; left arrow
        je      .L10a
        cmp     ah,04Dh                 ; Right arrow
        je      .L10a
        cmp     Ah,048h                 ; Up arrow
        je      .L10a
        cmp     ah,050h                 ; Down arrow
        je      .L10a
        %ENDIF
        mov     byte [cs:clock_active],1; If we were in menu, re-enable clock
        ret

        GOVR01: db      "GAME OVER - HUMANS WIN!",0
        GOVR02: db      "GAME OVER - PROTOIDS WIN!",0
        GOVR03: db      "HUMANS",0
        GOVR04: db      "PROTOIDS",0
        GOVR05: db      "BUILDINGS",0
        GOVR06: db      "GROUND UNITS",0
        GOVR07: db      "ELAPSED TIME",0
        GOVR08: db      "REMAINING RESOURCES:",0
        GOVR09: db      "MINERALS:",0
        GOVR10: db      "GAS:",0
        GOVR11: db      "ENERGY:",0
        %IF singleKeyExit
        GOVR80: db      "PRESS -M- TO RETURN TO THE MAIN MENU",0
        %ELSE
        GOVR80: db      "PRESS ANY KEY TO RETURN TO MAIN MENU",0
        %ENDIF

DISPLAY_CREDITS:
        ; clear_credits_window
        mov     di,[rect_credits]
        mov     cx,96
        mov     bx,100
        call    [clear_rect]

        mov     si,CREDITS
        mov     byte [TEMP_B],0
        mov     byte [cs:BG_TIMER_MAIN],0
        DCLOOP:
        cmp     byte [cs:BG_TIMER_MAIN],1
        je      .L2
        mov     ah,01
        int     16H                     ; check keyboard buffer
        jz      DCLOOP
        xor     ah,AH                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        mov     si,FILENAME_MENU
        call    LOAD_SCREEN
        ret                             ; back to menu
        .L2:
        mov     byte [cs:BG_TIMER_MAIN],0
        inc     byte [TEMP_B]
        cmp     byte [TEMP_B],10
        jne     DCLOOP
        mov     byte [TEMP_B],0
        ; credits_scroll_up
        mov     di,[rect_credits]
        mov     cx,96
        mov     bx,94
        call    [scroll_up]

        call    CREDITS_NEW_LINE
        jmp     DCLOOP

CREDITS_NEW_LINE:
        mov     di,[textpos_credits]
        lodsb
        cmp     al,1
        je      .L5
        cmp     al,255
        jne     .L3
        mov     si,CREDITS
        jmp     CREDITS_NEW_LINE
        .L2:
        inc     si
        mov     ax,[stride_tile]
        shr     ax,1
        add     di,ax
        .L3:
        mov     al,byte [si]
        cmp     al," "                  ; space
        je      .L2
        call    WRITE_TEXT_COLOR
        inc     si
        ret
        .L5:
        call    WRITE_TEXT
        inc     si
        ret


CREDITS:        db      1,"   PLANET X3 CREDITS",0
                db      1,"",0
                db      2," -X86 ASSEMBLY CODING-",0
                db      1," ",0
                db      1,"      DAVID MURRAY",0
                db      1,"  ALEX 'SHIRU' SEMENOV",0
                db      1," JIM 'TRIXTER' LEONARD",0
                db      1,"    BENEDIKT FREISEN",0
                db      1,"    MICHAL PROCHAZKA",0
                db      1,"",0
                db      2,"       -ARTWORK-",0
                db      1,"",0
                db      1,"     RENAUD SCHEIDT",0
                db      1,"",0
                db      2,"        -MUSIC-",0
                db      1,"",0
                db      1,"      NOELLE AMAN",0
                db      1,"  ANDERS ENGER JENSEN",0
                db      1,"  ALEX 'SHIRU' SEMENOV",0
                db      1,"",0
                db      2,"     -USER MANUAL-",0
                db      1,"",0
                db      1,"      DAVID MURRAY",0
                db      1,"  ANDERS ENGER JENSEN",0
                db      1,"",0
                db      2,"     -BETA TESTERS-",0
                db      1,"",0
                db      1,"       MAID-CHAN",0
                db      1,"        CJ LUCK",0
                db      1,"    JASON PRITCHARD",0
                db      1,"      WILL PRESTON",0
                db      1,"ANDREW 'XEOBLADE' HOWELL",0
                db      1,"   JOSHUA JAY SALAZAR",0
                db      1,"        KEVIN P.",0
                db      1,"      DJ. KOELKAST",0
                db      1,"      KEVIN BOYER",0
                db      1,"  NATE + LEVI SPENCER",0
                db      1,"  HOME COMPUTER MUSEUM",0
                db      1,"        ROB IVY",0
                db      1,"        BAUdbAND",0
                db      1,"      LORIN MILSAP",0
                db      1,"      KINNEAR DAVID",0
                db      1,"    PAUL A.J. FISHER",0
                db      1,"   JOHN MESHELANY JR.",0
                db      1,"      ARNE SCHMITZ",0
                db      1,"    GREGORY ANDERSON",0
                db      1,"    BRIAN R. POPILEK",0
                db      1,"     SERGE DEFEVER",0
                db      1,"          REDS",0
                db      1,"          HPT",0
                db      1,"    ANTHONY MATTERA",0
                db      1,"      BRITT DODD",0
                db      1,"       FISHMECH",0
                db      1,"     JAMES RICHARD",0
                db      1,0
                db      2,"     -300 DOLLAR- ",0
                db      2," -KICKSTARTER BACKERS- ",0
                db      1,0
                db      1,"     SERGE DEFEVER",0
                db      1,"    ANTHONY MARTIN",0
                db      1,"     ROBERT MEYERS",0
                db      1,"  NICOLA WORTHINGTON",0
                db      1,"         DALAN",0
                db      1,"      HANK ESKIN",0
                db      1,0
                db      1,"THANK YOU TO ALL OF THE",0
                db      1,"  KICKSTARTER BACKERS ",0
                db      1," AND PATREON SUPPORTERS",0
                db      1,"           OF",0
                db      1,"     THE 8-BIT GUY",0
                db      1,"FOR MAKING THIS POSSIBLE",0
                db      1,"",0
                db      1,"",0,255
