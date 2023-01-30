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

; description:
;       Display the diagnostic screen, usually triggered by F1 (and only
;       available if DIAGS = 1).
DIAGNOSTIC_SCREEN:
        mov     ax,[font_bg_black]
        mov     word [font_bg_color],ax
        call    CLEAR_PLAYFIELD_WINDOW
        mov     al,[SELECTED_UNIT]
        mov     [DIAG_UNIT],al
        DIAGSCR02:
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     si,DIAG_NUMBER
        mov     di,xy(16,20)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        mov     al,[DIAG_UNIT]
        mov     [HEXNUM],al
        call    WRITE_DECNUM
        mov     si,DIAG_TYPE
        mov     di,xy(16,26)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_TYPE[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM
        mov     si,DIAG_AI
        mov     di,xy(16,32)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_AI[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM
        mov     si,DIAG_HEALTH
        mov     di,xy(16,38)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_HEALTH[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM
        mov     si,DIAG_WORKING
        mov     di,xy(16,44)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_WORKING[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM
        mov     si,DIAG_TIMER
        mov     di,xy(16,50)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_TIMER[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM
        mov     si,DIAG_TILE
        mov     di,xy(16,56)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_TILE[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM
        mov     si,DIAG_TILEUNDER
        mov     di,xy(16,62)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_TILE_UNDER[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_LOCATIONX
        mov     di,xy(16,74)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_LOCATION_X[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_LOCATIONY
        mov     di,xy(16,80)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_LOCATION_Y[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_DESTX
        mov     di,xy(136,74)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_DEST_X[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_DESTY
        mov     di,xy(136,80)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_DEST_Y[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_ALTX
        mov     di,xy(136,86)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_ALTMOVE_X[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_ALTY
        mov     di,xy(136,92)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_ALTMOVE_Y[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM


        mov     si,DIAG_GENA
        mov     di,xy(16,98)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_GEN_A[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_GENB
        mov     di,xy(16,104)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_GEN_B[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_GENC
        mov     di,xy(16,110)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[DIAG_UNIT]
        mov     ah,0
        mov     si,ax
        mov     al,UNIT_GEN_C[si]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

        mov     si,DIAG_DIFF
        mov     di,xy(16,122)
        call    [calc_screen_offset]
        call    WRITE_TEXT
        push    si
        mov     al,[GAME_DIFF]
        mov     [HEXNUM],al
        pop     si
        call    WRITE_DECNUM

DIAGKEYSCAN:
        xor     ah,ah                   ; ah = 0
        int     16h                     ; Wait for a keystroke
        cmp     ah,00h
        je      DIAGKEYSCAN
DGK01:  cmp     ah,04Bh                 ; Left arrow
        jne     .L02
        dec     byte [DIAG_UNIT]
        jmp     DIAGSCR02
.L02:   cmp     ah,04Dh                 ; Right arrow
        jne     .L03
        inc     byte [DIAG_UNIT]
        jmp     DIAGSCR02
.L03:   cmp     ah,022h                 ; G-KEY
        jne     .L04
        mov     al,[DIAG_UNIT]
        mov     [SELECTED_UNIT],al
.L04:
        call    FIND_MAP_OFFSET
        call    force_draw_entire_screen
        call    DRAW_FLYING_OBJECTS
        call    WRITE_COORDINATES
        call    DRAW_STATUS_WINDOW
        call    DRAW_COMMAND_WINDOW
        ret

        DIAG_UNIT       db 0

        DIAG_NUMBER     db "UNIT NUMBER-",0
        DIAG_TYPE       db "UNIT TYPE-",0
        DIAG_AI         db "UNIT AI-",0
        DIAG_HEALTH     db "HEALTH-",0
        DIAG_WORKING    db "WORKING-",0
        DIAG_TIMER      db "TIMER-",0
        DIAG_TILE       db "TILE-",0
        DIAG_TILEUNDER  db "TILE UNDER-",0
        DIAG_LOCATIONX  db "LOCATION X-",0
        DIAG_LOCATIONY  db "LOCATION Y-",0
        DIAG_DESTX      db "DESTINATION X-",0
        DIAG_DESTY      db "DESTINATION Y-",0
        DIAG_ALTX       db "ALTMOVE X-",0
        DIAG_ALTY       db "ALTMOVE Y-",0
        DIAG_GENA       db "GEN A-",0
        DIAG_GENB       db "GEN B-",0
        DIAG_GENC       db "GEN C-",0
        DIAG_DIFF       db "GAME DIFF-",0
