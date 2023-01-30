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

        MPU_DataPort    equ 330h
        MPU_StatusPort  equ 331h

MPU_Init:
        push    ax
        call    MPU_WaitOutput

        ; Detect the MPU

        mov     al,0ffh
        out     dx,al                   ; Sending data to the status port

        ; Wait for the acknowledgement

.ack_loop:
        call    MPU_ReadData
        cmp     al,0feh
        jne     .ack_loop

        ; Put the MPU into UART mode

        call    MPU_WaitOutput

        mov     al,3fh
        out     dx,al

        pop     ax
        ret

MPU_InitMT32:
        cmp     byte [.mt32_initialized],1
        je      .exit

        mov     byte [.mt32_initialized],1

        mov     di,[textpos_mt32]
        mov     si,.msg
        mov     cx,14
        mov     ax,[font_bg_black]
        mov     [font_bg_color],ax
        call    [plot_string]

        ; Make sure that music is enabled and load SysEx
        mov     al,[MUSIC_ON]
        push    ax
        mov     byte [MUSIC_ON],1
        mov     al,MT32_INIT_INDEX
        call    m_loadmusic
        pop     ax
        mov     byte [MUSIC_ON],al

        mov     byte [repeat],0

.wait_loop:
        cmp     byte [intrunning],1
        je      .wait_loop

.exit:
        ret

        .mt32_initialized       db 0
        .msg    db 'PREPARING MT32'

MPU_Clear:
        mov     bl,0b0h                 ; Control change

.channel_loop:
        mov     si,.cc_reset
        mov     cx,6

.cc_loop:
        mov     al,bl
        call    MPU_SendData

        lodsw

        call    MPU_SendData

        mov     al,ah
        call    MPU_SendData

        loop    .cc_loop

        mov     al,bl
        add     al,20h                  ; Pitch wheel
        call    MPU_SendData

        mov     al,8192 / 128
        call    MPU_SendData

        mov     al,8192 % 128
        call    MPU_SendData

        inc     bl
        cmp     bl,0c0h
        jne     .channel_loop

        ; Reset MPU

;       mov     al,255
;       call    MPU_SendData

        ret

        .cc_reset       dw 0001h,7f07h,400ah,7f0bh,0040h,007bh

MPU_WaitOutput:
        mov     dx,[ssy_base_port]
        inc     dx                      ; Status port
        in      al,dx
        test    al,40h
        jnz     MPU_WaitOutput
        ret

MPU_WaitInput:
        mov     dx,[ssy_base_port]
        inc     dx                      ; Status port
        in      al,dx
        test    al,40h
        jnz     MPU_WaitOutput
        ret

MPU_SendData:   ; In: AL = data to send, DX destroyed
        ; Check if it's alright to write to the MPU

        push    ax
        call    MPU_WaitOutput
        pop     ax

        ; It is, so write the data

        mov     dx,[ssy_base_port]      ; Data port
        out     dx,al

;       call    os_print_2hex
        ret

MPU_ReadData:   ; Out: AL = received data, DX destroyed
        ; Wait for incoming data from the MPU

        call    MPU_WaitInput

        ; Read the data

        mov     dx,[ssy_base_port]      ; Data port
        in      al,dx
        ret
