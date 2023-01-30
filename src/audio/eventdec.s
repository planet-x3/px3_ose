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
; - Michal Prochazka
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

InitializeSong:
        mov     word [pointer],SSY_MUS_DATA+1
        mov     word [delay_value],0
        mov     byte [repeat],1
        mov     byte [intrunning],1
        ret

StopSong:
        mov     byte [cs:intrunning],0
        call    MPU_Clear
        ret

interrupt:
        cmp     byte [intrunning],0
        je      .no_run

        cmp     word [delay_value],0
        je      .play

        dec     word [delay_value]

        cmp     word [delay_value],0
        je      .play

        ret

.play:
        push    es
        push    bx
        push    ax
        push    dx              ; For MPU_SendData

        mov     es,[SSY_SEG]

        mov     bx,[pointer]

.play_loop:
        ; Fetch a byte

        mov     al,[es:bx]
        inc     bx

        cmp     al,0fch         ; Song end?
        je      .restart

        cmp     al,0d0h         ; Delay?
        jl      .no_delay

        cmp     al,0dfh
        jg      .no_delay

        ; We have reached a delay event!

        mov     ah,0

        cmp     al,0dfh
        je      .long_delay

        cmp     al,0deh
        je      .short_delay

        sub     ax,0d0h-1

        mov     [delay_value],ax
        jmp     .end

.no_delay:
        call    MPU_SendData
        jmp     .play_loop

.end:
        mov     [pointer],bx

.end_no_store:
        pop     dx              ; For MPU_SendData
        pop     ax
        pop     bx
        pop     es

.no_run:
        ret

.short_delay:
        mov     al,[es:bx]
        inc     bx

        inc     ax

        mov     [delay_value],ax
        jmp     .end

.long_delay:
        mov     al,0
        mov     ah,[es:bx+1]

        shr     ax,1

        or      al,[es:bx]

        add     bx,2
        inc     ax

        mov     [delay_value],ax
        jmp     .end

.restart:
        mov     byte [intrunning],0

        cmp     byte [repeat],0
        je      .stop

        call    InitializeSong
        jmp     .end_no_store

.stop:
        mov     byte [intrunning],0
        jmp     .end_no_store

        pointer         dw 0
        delay_value     dw 0
        intrunning      db 0
        repeat          db 0
