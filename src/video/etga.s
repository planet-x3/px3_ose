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
; - Jim Leonard**
; - Benedikt Freisen
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

; Tandy Video II (ETGA) routines

; Note: The palette-specific VGA_TO_ETGA_LUT has to be defined by the including program

; data for CRTC registers 0-18, index port 3d4h, data port 3d4h
etga_crtc_and_ctrl_tab  db 71h,50h,5ah,0efh,0ffh,6,0c8h,0e2h,2,0,0,0,0,0,0,0,18h,0,46h
; data for control registers, index in low byte
                        dw 0f01h,2,1003h,105h,208h

text_crtc_and_ctrl_tab  db 71h,50h,5ah,0feh,1ch,1,19h,1ah,2,8,6,7,0,0,0,0,18h,20h,7
                        dw 0f01h,2,1003h,5,8

; common code from set_etga_640x200x16 and exit_etga_640x200x16
etga_set_exit_common_code:
        xor     ax,ax
        cli             ; disable interrupts
        cld

        ; set CRTC registers
esecc_crtc_loop:
        mov     dl,0d4h ; dx=3d4h
        out     dx,al
        inc     ax
        push    ax
        lodsb
        inc     dx
        out     dx,al
        pop     ax
        cmp     al,19
        jb      esecc_crtc_loop

        ; set control registers
esecc_ctrl_loop:
        mov     dl,0dah ; dx=3dah
        lodsw
        out     dx,al
        mov     dl,0deh ; dx=3deh
        xchg    al,ah
        out     dx,al
        cmp     ah,8
        jne     esecc_ctrl_loop

        sti             ; enable interrupts

        ; clear color select register
        mov     dl,0d9h ; dx=3d9h
        mov     al,0
        out     dx,al

        ; disable extended RAM paging
        mov     dl,0ddh ; dx=3ddh
        mov     al,0
        out     dx,al

        ret

; switch to 640x200x16 Tandy mode -- this is not EGA mode 0eh
set_etga_640x200x16:
        push    ax
        push    dx

        ; switch to mode 3
        mov     ax,3
        int     10h

        ; select 640 dot graphics mode with hi-res clock, disable video
        mov     dx,3d8h
        mov     al,13h
        out     dx,al

        push    si
        mov     si,etga_crtc_and_ctrl_tab
        call    etga_set_exit_common_code
        pop     si

        ; select page bit 2 for CRT & CPU
        mov     dl,0dfh ; dx=3dfh
        mov     al,24h
        out     dx,al

        ; clear screen
        push    es      ; save es
        mov     ax,0a000h
        mov     es,ax   ; es=0a000h
        push    di      ; save di
        xor     di,di   ; di=0
        xor     ax,ax   ; ax=0
        push    cx      ; save cx
        mov     cx,32000
        rep     stosw   ; write 64000 black pixels (technically 128000)
        pop     cx      ; restore cx
        pop     di      ; restore di
        pop     es      ; restore es

        ; select 640 dot graphics mode with hi-res clock, enable video
        mov     dl,0d8h ; dx = 3d8h
        mov     al,1bh
        out     dx,al

        pop     dx      ; restore dx
        pop     ax      ; restore ax

        ret

; switch back from 640x200x16 Tandy mode
exit_etga_640x200x16:
        push    ax
        push    dx

        ; select 80 column text mode, disable video
        mov     dx,3d8h
        mov     al,13h
        out     dx,al

        push    si
        mov     si,text_crtc_and_ctrl_tab
        call    etga_set_exit_common_code
        pop     si

        ; select page bits 0-2 for CRT & CPU
        mov     dl,0dfh ; dx=3dfh
        mov     al,3fh
        out     dx,al

        ; select 80 column text mode, enable blinking, enable video
        mov     dl,0d8h ; dx = 3d8h
        mov     al,29h
        out     dx,al

        pop     dx      ; restore dx
        pop     ax      ; restore ax

        ret

vga2etga:
        push    ds
        push    ax
        push    bx
        push    cx
        push    si
        push    di

        push    es
        pop     ds
        mov     si,di
        mov     bx,VGA_TO_ETGA_LUT
        cld
vga2etga_loop:
        lodsb
        cs xlatb
        stosb
        loop    vga2etga_loop

        pop     di
        pop     si
        pop     cx
        pop     bx
        pop     ax
        pop     ds
        ret
