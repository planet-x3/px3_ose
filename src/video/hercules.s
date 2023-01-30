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
; - Benedikt Freisen
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

; Hercules Graphics Card routines

; data for CRTC registers 0-11, index port 3b4h, data port 3b5h

; CRTC table for 720x348, 4 fields
; hercules_crtc_tab db 35h,2dh,2eh,07h,5bh,02h,57h,57h,02h,03h,00h,00h
; CRTC table for 640x348, 4 fields
; hercules_crtc_tab db 35h,28h,2ch,07h,5bh,02h,57h,57h,02h,03h,00h,00h
; CRTC table for 640x300, 3 fields
hercules_crtc_tab db 35h,28h,2ch,07h,79h,03h,64h,6ch,02h,02h,00h,00h

; switch to 640x300x2 Hercules mode
set_hercules_640x300x2:
        push    ax
        push    dx

        ; switch to mode 7
        mov     ax,7
        int     10h

        ; disable video (graphics mode with page 0)
        mov     dx,3b8h
        mov     al,02h
        out     dx,al

        ; set CRTC registers

        push    si

        mov     si,hercules_crtc_tab
        xor     ax,ax
        cli             ; disable interrupts
        cld

sh_crtc_loop:
        mov     dl,0b4h ; dx=3b4h
        out     dx,al
        inc     ax
        push    ax
        lodsb
        inc     dx
        out     dx,al
        pop     ax
        cmp     al,12
        jb      sh_crtc_loop

        sti             ; enable interrupts
        pop     si

        ; allow graphics mode, upper page disabled
        mov     dl,0bfh ; dx=3bfh
        mov     al,1    ; 3 if upper page enabled
        out     dx,al

        ; clear screen
        push    es      ; save es
        mov     ax,0b000h
        mov     es,ax   ; es=0a000h
        push    di      ; save di
        xor     di,di   ; di=0
        xor     ax,ax   ; ax=0
        push    cx      ; save cx
        mov     cx,16384
        rep     stosw   ; clear the entire 32KiB page
        pop     cx      ; restore cx
        pop     di      ; restore di
        pop     es      ; restore es

        ; enable video (graphics mode with page 0)
        mov     dl,0b8h ; dx = 3b8h
        mov     al,0ah
        out     dx,al

        pop     dx      ; restore dx
        pop     ax      ; restore ax

        ret

restore_old_mode_hercules:
        ; switch to old video mode saved at program start
        mov     ah,0
        mov     al,[cs:old_mode]
        int     10h

        ; re-enable port 3b8 protection
        mov     dx,3bfh
        mov     al,0
        out     dx,al

        ret

emulate_movsb_to_cga_on_hgc:
        push    ax,dx

        lodsb           ; load group of pixels
        mov     dl,al
        mov     dh,al
        and     dx,0101010110101010b
        shl     dh,1
        or      al,dh
        and     dh,dl

        cmp     di,1fffh        ; cf = (di <= 8191)
        jnc     emtcoh01
        stosb
        mov     al,[es:di+1fffh]
        and     al,01010101b
        or      al,dh
        mov     [es:di+1fffh],al
        jmp     emtcoh02
emtcoh01:
        mov     [es:di+2000h],al
        mov     al,[es:di]
        and     al,10101010b
        shr     dh,1
        or      al,dh
        stosb
emtcoh02:

        pop     dx,ax
        ret

; ds:si  input: 1st & 2nd field
; es:di  output: 1st, 2nd, 3rd & empty 4th field
convert_cga_to_3_field_hgc:
        mov     si,3fffh
        mov     di,7fffh-32

        mov     bh,0
.tileloop:
        mov     cx,32
.byteloop:
        mov     al,[si]
        mov     dl,al
        mov     dh,al
        and     dx,0101010110101010b
        shl     dh,1
        or      al,dh
        and     dh,dl

        mov     [es:di],al
        shr     dh,1
        mov     ah,dh

        mov     al,[si-32]
        mov     dl,al
        mov     dh,al
        and     dx,0101010110101010b
        shl     dh,1
        or      al,dh
        and     dh,dl

        mov     [es:di-64],al

        or      ah,dh
        mov     [es:di-32],ah

        dec     si
        dec     di
        loop    .byteloop

        sub     si,32
        sub     di,96
        dec     bh
        jnz     .tileloop

        ret
