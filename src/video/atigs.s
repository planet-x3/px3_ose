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

; Routines for ATI "Small Wonder" Graphics Solution
; (a.k.a. Commodore Advanced Graphics Adapter)

; data for CRTC registers 0-13, index port 3d4h, data port 3d5h
ags_aga_crtc_tab_color db 70h,50h,58h,0ah,40h,06h,32h,38h,02h,03h,06h,07h,00h,00h
ags_aga_crtc_tab_emu db 61h,50h,52h,08h,32h,06h,32h,32h,02h,07h,06h,07h,00h,00h
text_80x25_crtc_tab_color db 71h,50h,5ah,0ah,1fh,06h,19h,1ch,02h,07h,06h,07h,00h,00h

; switch to 640x200x16 ATI GS mode
set_gs_640x200x16:
        push    ax
        push    dx

        ; set 320x200 4-color mode, first
        mov     ax,0004h
        int     10h
        cmp     byte [cmd_arg_f],1
        je      .after_check
        ; sanity check: Do we have Plantronics page flipping?
        push    es
        mov     ax,0b800h
        mov     es,ax
        mov     dx,3ddh
        mov     al,50h
        out     dx,al
        mov     byte [es:0],1
        mov     al,10h
        out     dx,al
        cmp     byte [es:0],0
        pop     es
        je      .after_check    ; check successful
        tcall   video_error
        .after_check:

        ; disable video (graphics mode)
        mov     dx,3d8h
        mov     al,02h
        out     dx,al

        ; set 640x200 graphics mode with 16 colors (only flags; not the CRTC regs!)
        mov     dl,0ddh ; dx=3ddh
        mov     al,80h  ; 640x200 16 colors
        out     dx,al

        cmp     byte [cmd_arg_f],1
        je      .after_check_2
        ; another sanity check: do we now have memory at b000h?
        push    es
        mov     ax,0b000h
        mov     es,ax
        mov     byte [es:0],0           ; paranoid test writes
        mov     byte [es:1],1
        cmp     byte [es:0],0           ; read back 1st byte written
        jne     .b000_free
        cmp     byte [es:1],1           ; read back 2nd byte written
        jne     .b000_free
        ; success: this appears to be an ATI Graphics Solution
        pop     es
        jmp     .after_check_2
        .b000_free:
        pop     es
        mov     al,0                    ; disable Plantronics extensions
        out     dx,al                   ; dx is still 3ddh
        tcall   video_error
        .after_check_2:

        ; set CRTC registers for 640x200 graphics mode with 16 colors

        push    si

        mov     si,ags_aga_crtc_tab_color
        cmp     byte [cmd_arg_i],1      ; /i: use CRTC values for MDA screens
        jne     .keep_color_crtc_tab
        mov     si,ags_aga_crtc_tab_emu
        .keep_color_crtc_tab:

        xor     ax,ax
        cli             ; disable interrupts
        cld

        .crtc_loop:
        mov     dl,0d4h ; dx=3d4h
        out     dx,al
        inc     ax
        push    ax
        lodsb
        inc     dx
        out     dx,al
        pop     ax
        cmp     al,14
        jb      .crtc_loop

        sti             ; enable interrupts

        pop     si

        ; clear screen
        push    es      ; save es
        mov     ax,0b000h
        mov     es,ax   ; es=0b000h
        push    di      ; save di
        xor     di,di   ; di=0
        xor     ax,ax   ; ax=0
        push    cx      ; save cx
        mov     cx,32768
        rep     stosw   ; clear both 32KiB pages
        pop     cx      ; restore cx
        pop     di      ; restore di
        pop     es      ; restore es

        ; enable video (graphics mode, color or b/w as requested)
        mov     dl,0d8h ; dx = 3d8h
        mov     al,[cmd_arg_g]
        shl     al,2
        or      al,0ah
        out     dx,al

        pop     dx      ; restore dx
        pop     ax      ; restore ax

        ret

switch_from_gs_to_mode_3:
        ; disable video (graphics mode)
        mov     dx,3d8h
        mov     al,02h
        out     dx,al

        ; reset GS/Plantronics extension register
        mov     dl,0ddh ; dx=3ddh
        mov     al,00h  ; disable extended modes
        out     dx,al

        ; switch to mode 3 -- should reenable video
        mov     ax,3
        int     10h

        ret

emulate_movsb_to_vga_on_gs:
        push    ax,bx,dx,di

        mov     ax,di
        xor     dx,dx
        mov     bx,320
        div     bx
        cmp     al,200
        jae     emteoaa02
        xor     di,di
        shr     ax,1
        rcr     di,1
        shr     ax,1
        rcr     di,1
        shr     di,1
        shr     bx,1
        mul     bl
        add     di,ax

        lodsb                   ; al = 256 color pixel
        mov     bx,VGA_TO_GS_LUT
        cs xlatb                ; al = irgb pair as rgrgbibi
        mov     ah,al
        shr     dx,1
        jc      emteoaa01
        add     di,dx
        mov     bl,[es:di]
        mov     bh,[es:di+32768]
        and     bx,0f0fh
        and     ax,0ff0h
        shl     ah,4
        or      ax,bx
        mov     [es:di+32768],ah
        stosb
        jmp     emteoaa02
emteoaa01:
        add     di,dx
        mov     bl,[es:di]
        mov     bh,[es:di+32768]
        and     bx,0f0f0h
        and     ax,0ff0h
        shr     al,4
        or      ax,bx
        mov     [es:di+32768],ah
        stosb

emteoaa02:
        pop     di,dx,bx,ax
        inc     di
        ret

; convert 256 16x16 tiles
; ds:0   pointer to source/destination data
; es:0   pointer to buffer
convert_vga_to_gs:
        cld
        mov     bx,VGA_TO_GS_LUT
cvtg01:
        mov     bp,256
cvtg02:
        mov     cx,128
cvtg03:
        mov     dx,si
        shr     dl,1
        and     dl,7
        mov     di,dx
        mov     dx,si
        shr     dl,3
        and     dl,18h
        or      di,dx
        mov     dx,si
        shl     dl,1
        and     dl,60h
        or      di,dx
        and     di,0ffh

        lodsb
        cs xlatb
        mov     ah,al
        lodsb
        cs xlatb
        ror     al,4
        mov     dx,ax
        and     ax,0f00fh
        or      al,ah
        and     dx,0ff0h
        or      dl,dh
        ror     dl,4

        stosb
        mov     [es:di+127],dl
        dec     cx
        jnz     cvtg03

        push    ds,es
        pop     ds,es
        sub     si,256
        mov     di,si
        xor     si,si
        mov     cx,128
        rep     movsw
        push    ds,es
        pop     ds,es
        mov     si,di

        dec     bp
        jnz     cvtg02

        ret
