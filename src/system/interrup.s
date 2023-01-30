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
; - Alex Semenov*
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

; ======== Interrupt section begins ========
; The Mode/Command register at I/O address 43h is defined as follows:
;
;       7 6 5 4 3 2 1 0
;       * * . . . . . .  Select chan:   0 0 = Channel 0
;                                       0 1 = Channel 1
;                                       1 0 = Channel 2
;                                       1 1 = Read-back command (8254 only)
;                                             (Illegal on 8253, PS/2)
;       . . * * . . . .  Cmd/Acc mode:  0 0 = Latch count value command
;                                       0 1 = Access mode: lobyte only
;                                       1 0 = Access mode: hibyte only
;                                       1 1 = Access mode: lobyte/hibyte
;       . . . . * * * .  Oper. mode:  0 0 0 = Mode 0
;                                     0 0 1 = Mode 1
;                                     0 1 0 = Mode 2
;                                     0 1 1 = Mode 3
;                                     1 0 0 = Mode 4
;                                     1 0 1 = Mode 5
;                                     1 1 0 = Mode 2
;                                     1 1 1 = Mode 3
;       . . . . . . . *  BCD/Binary mode: 0 = 16-bit binary
;                                         1 = four-digit BCD
;
; PC and XT : I/O address 61h, "PPI Port B", read/write
;       7 6 5 4 3 2 1 0
;       * * * * * * . .  Not relevant to speaker - do not modify!
;       . . . . . . * .  Speaker Data
;       . . . . . . . *  Timer 2 Gate


CHAN0           equ     00000000b
CHAN1           equ     01000000b
CHAN2           equ     10000000b
AMREAD          equ     00000000b
AMLOBYTE        equ     00010000b
AMHIBYTE        equ     00100000b
AMBOTH          equ     00110000b
MODE0           equ     00000000b
MODE1           equ     00000010b
MODE2           equ     00000100b
MODE3           equ     00000110b
MODE4           equ     00001000b
MODE5           equ     00001010b
BINARY          equ     00000000b
BCD             equ     00000001b
changeTickRate  equ     CHAN0 | AMBOTH | MODE2 | BINARY


CTCMODECMDREG   equ     043h
CHAN0PORT       equ     040h
CHAN2PORT       equ     042h
CGAPITDIVRATE   equ     (912*262) / 12 ; 19912
PPIPORTB        equ     61h

soundIntDivisor equ     16384


; Hook the existing int 08 timer interrupt.
setup_new_interrupt:
        ; First, we save the existing 08h vector so we can restore it later
        pushf
        cli

        push    es
        push    bx
        mov     ah,35h                  ; Get Interrupt Vector
        mov     al,08h                  ; we want the existing 08h vector
        int     21h                     ; do it
        mov     word [cs:oldINT08],bx   ; save offset portion
        mov     word [cs:oldINT08+2],es ; save segment portion
        pop     bx
        pop     es

        ; Next, we install our own interrupt handler at 08h
        mov     ah,25h                  ; Set Interrupt Vector
        mov     al,08h                  ; we want to replace 08h
        push    ds                      ; save DS, as we'll be changing it
        push    cs                      ; push CS...
        pop     ds                      ; ...so we can copy it to DS
        mov     dx,gameInt              ; Now DS:DX points to our code
        int     21h                     ; do it
        pop     ds                      ; restore previous DS

        ; Finally, speed up the tick rate 4x
        push    ax
        mov     al,changeTickRate
        out     CTCMODECMDREG,al
        mov     ax,soundIntDivisor
        out     CHAN0PORT,al            ; output lobyte first
        ; out     04fh,al                 ; allow device recovery time
        in      al,61h                  ; safer device recovery on clones
        xchg    al,ah
        out     CHAN0PORT,al
        pop     ax

        popf
        ret                             ; done, return to main program

restore_old_interrupt:
        pushf
        cli

        ; Restore original firing rate no matter what state we're in
        mov     al,changeTickRate
        out     CTCMODECMDREG,al
        xor     ax,ax                   ; xtal / 65536 iterations = 18.2Hz
        out     CHAN0PORT,al
        ; out     04fh,al                 ; allow device recovery time
        in      al,61h                  ; safer device recovery on clones
        xchg    al,ah
        out     CHAN0PORT,al

        ; Restore previous 08h user interrupt handler
        push    ds
        push    ax
        mov     ah,25h                  ; Set Interrupt Vector
        mov     al,08h                  ; we want to replace 08h
        mov     dx,word [oldINT08]      ; retrieve offset portion
        mov     ds,word [oldINT08+2]    ; retrieve segment portion
        int     21h                     ; do it
        pop     ax
        pop     ds                      ; restore previous DS
E0:
        popf
        ret

; Our custom interrupt handler.  Performs game housekeeping.
; Our handler runs at the same 18.2 tick rate as the system BIOS tick.
gameInt:
        inc     word [cs:handler_ticks]

        %if DEBUG
        ; toggle a screen byte at the tick rate to show we're alive
        push    bx
        push    es
        mov     bx,[VIDEO_SEG]
        mov     es,bx
        xor     byte es:[0],0ffh
        pop     es
        pop     bx
        %endif

        ; perform sound tick
        cmp     byte [cs:SOUND_INITIALIZED],1   ; is sound system initialized?
        jne     skip_sound_isr                  ; skip if not
        push    ax                              ; save scratch register
        mov     al,byte [cs:MUSIC_ON]           ; load music state
        or      al,byte [cs:SOUNDFX_ON]         ; are music or sound on?
        pop     ax                              ; restore scratch register
        jz      skip_sound_isr                  ; skip sound if both are off

        %if DEBUG
        ; toggle a screen byte to see if music+sound routines are being called
        push    bx
        push    es
        mov     bx,[VIDEO_SEG]
        mov     es,bx
        xor     byte es:[4],0ffh
        pop     es
        pop     bx
        %endif

        push    ax,bx,cx,dx,si,di,ds            ; save regs sound routines touch
        push    cs
        pop     ds                              ; DS=CS for sound routines
        call    ssy_timer_isr                   ; do sound routine tick
        pop     ds,di,si,dx,cx,bx,ax            ; restore regs in proper order
skip_sound_isr:

        ; Handler is 4x BIOS tick speed.
        ; If on 4th tick, call the BIOS tick handler.
        test    byte [cs:handler_ticks],3       ; on 4th tick?
        jnz     exitHandler                     ; if not, exit

        ; Perform game housekeeping:
        cmp     byte [cs:clock_active],1        ; Is game clock active?
        jne     doneHousekeeping                ; skip housekeeping if not
        %if DEBUG
        ; toggle a screen byte at the housekeeping rate to show it is alive
        push    bx
        push    es
        mov     bx,[VIDEO_SEG]
        mov     es,bx
        xor     byte es:[2],0ffh
        pop     es
        pop     bx
        %endif
        mov     byte [CS:BG_TIMER_MAIN],1       ; reset our timer
        inc     word [CS:GAME_CLOCK_TICKS]
        cmp     word [CS:GAME_CLOCK_TICKS],1092 ; one minute
        jne     doneHousekeeping
        mov     word [CS:GAME_CLOCK_TICKS],0
        inc     byte [CS:GAME_CLOCK_MINUTES]
        cmp     byte [CS:GAME_CLOCK_MINUTES],60 ; one hour
        jne     doneHousekeeping
        inc     byte [CS:GAME_CLOCK_HOURS]
        mov     byte [CS:GAME_CLOCK_MINUTES],0

doneHousekeeping:

maintainBIOStick:
        ; call BIOS tick int. at 18.2 Hz or else the system clock will be wrong
        jmp     far [cs:oldINT08]       ; Old int08 will ACK PIC and return here

exitHandler:
        push    ax
        mov     al,20h
        out     20h,al                  ; acknowledge hardware PIC
        pop     ax
        iret

; gameHousekeepingInt variables -- keep in same segment as int. code
BG_TIMER_MAIN           db      0
GAME_CLOCK_TICKS        dw      0
GAME_CLOCK_SECONDS      db      0
GAME_CLOCK_MINUTES      db      0
GAME_CLOCK_HOURS        db      0
handler_ticks           dw      0
clock_active            db      1

; ======== Interrupt section ends ========
