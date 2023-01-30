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

%include "zx7_8086.s"                   ; zx7 decompression code


; description:
;       Save the current game to a file in the working directory.
SAVE_GAME_DISKIO:
        ; first save the map
        mov     cx,0
        mov     dx,FILENAME_SG
        mov     ah,3ch
        int     21h
        jc      .l2
        mov     [handle],ax
        jmp     .l3
        .l2:                            ; map_save_error
        ret
        .l3:                            ; save map
        mov     bx,[handle]
        mov     dx,0000                 ; set location map data
        mov     cx,32768                ; size of map 32k
        mov     ah,40h
        push    ds
        mov     ds,[MAPSEG]
        int     21h
        pop     ds
        ; save variable data
        mov     bx,[handle]
        mov     dx,UNIT_TYPE            ; set location unit data
        mov     cx,4112                 ; size of unit data
        mov     ah,40h
        int     21h
        ; save running clock
        mov     bx,[handle]
        mov     dx,GAME_CLOCK_TICKS     ; set location unit data
        mov     cx,5                    ; size of unit data
        mov     ah,40h
        int     21h
        ; close file
        mov     ah,3eh
        mov     bx,[handle]
        int     21h
        ret

; description:
;       Load a game from a file in the working directory, replacing the current game.
LOAD_GAME_DISKIO:
        ; FIRST LOAD THE MAP
        mov     al,0                    ; read-only
        mov     dx,FILENAME_SG
        mov     ah,03dh                 ; open file
        int     21h
        jc      .l2
        mov     [handle],ax
        jmp     .l3
        .l2:                            ; map_load_error
        ret
        .l3:                            ; load map
        mov     bx,[handle]
        mov     dx,0000                 ; set location map data
        mov     cx,32768                ; size of map 32k
        mov     ah,03fh                 ; read file instruction
        push    ds
        mov     ds,[MAPSEG]
        int     21h
        pop     ds
        ; load variable data
        mov     bx,[handle]
        mov     dx,UNIT_TYPE            ; set location unit data
        mov     cx,4112                 ; size of unit data
        mov     ah,03fh                 ; read file instruction
        int     21h
        ; load game clock
        mov     bx,[handle]
        mov     dx,GAME_CLOCK_TICKS     ; set location unit data
        mov     cx,5                    ; size of unit data
        mov     ah,03fh                 ; read file instruction
        int     21h
        ; close file
        mov     ah,3eh
        mov     bx,[handle]
        int     21h
        ret


; description:
;       Shows a disk swap prompt.
show_prompt:
        push    ds
        push    cs
        pop     ds
        push    es
        mov     es,[VIDEO_SEG]

        mov     ax,[font_bg_black]
        mov     word [font_bg_color],ax
        cmp     byte [in_intro_menu],1
        jne     .else_in_intro_menu
        mov     di,[error_pos_intro]
        jmp     .endif_in_intro_menu
        .else_in_intro_menu:
        call    CLEAR_MENU_WINDOW
        mov     di,[error_pos_game]
        .endif_in_intro_menu:
        mov     [.prompt_pos],di
        call    [calc_screen_offset]
        mov     si,.prompt1
        mov     cx,16
        call    [plot_string]

        mov     di,[.prompt_pos]
        add     di,xy(0,6)
        call    [calc_screen_offset]
        mov     si,.prompt2
        mov     cx,16
        call    [plot_string]

        mov     di,[.prompt_pos]
        add     di,xy(0,12)
        call    [calc_screen_offset]
        mov     si,.empty
        mov     cx,16
        call    [plot_string]

        mov     di,[.prompt_pos]
        add     di,xy(0,12)
        call    [calc_screen_offset]
        mov     si,safer_open.f_path + 3
        mov     cx,12
        call    [plot_string]

        mov     di,[.prompt_pos]
        add     di,xy(0,18)
        call    [calc_screen_offset]
        mov     si,.empty
        cmp     byte [safer_open_allow_ignore],1
        jne     .keep_empty
        mov     si,.ignore
        .keep_empty:
        mov     cx,16
        call    [plot_string]

        mov     di,[.prompt_pos]
        add     di,xy(0,24)
        call    [calc_screen_offset]
        mov     si,.retry_abort
        mov     cx,16
        call    [plot_string]

        pop     es
        pop     ds
        ret
.prompt1        db      "PLEASE INSERT   "
.prompt2        db      "THE DISK WITH   "
.empty          db      "                "
.retry_abort    db      "R:RETRY A:ABORT "
.ignore         db      "I:IGNORE        "
.prompt_pos     dw      0

; description:
;       Safer file open function:
;       - failover mechanism reading the current directory followed by drive A,
;         followed by drive B
;       - displays a disk swap prompt upon failure
; parameters:
;       si: file name
safer_open:
        xor     bx,bx
.l1:
        mov     al,[si+bx]
        mov     [.f_path+bx+3],al
        inc     bx
        cmp     bl,12
        jne     .l1
.try_workdir:
        mov     dx,.f_path + 3
        mov     ax,3d00h
        int     21h
        jc      .try_a
        ret
.try_a:
        mov     byte [.f_path],'A'
        mov     dx,.f_path
        mov     ax,3d00h
        int     21h
        jc      .try_b
        ret
.try_b:
        mov     byte [.f_path],'B'
        mov     dx,.f_path
        mov     ax,3d00h
        int     21h
        jc      .swap_prompt
        ret
.swap_prompt:
        ; show disk swap prompt in case of failure
        call    show_prompt
.read_key:
        xor     ax,ax
        int     16h
        cmp     al,'r'
        jne     .no_retry
        jmp     .try_workdir
.no_retry:
        cmp     byte [safer_open_allow_ignore],1
        jne     .not_i
        cmp     al,'i'
        jne     .not_i
        mov     byte [track_not_loaded],1
        jmp     .end
.not_i:
        cmp     al,'a'
        jne     .read_key
.end:
        stc
        ret

.f_path db      " :\            ",0

safer_open_allow_ignore db      0

; works like loadfile, but sets track_not_loaded and succeeds on error
loadtrack:
        mov     byte [safer_open_allow_ignore],1
        mov     byte [track_not_loaded],0
        call    loadfile
        mov     byte [safer_open_allow_ignore],0
        ret

; ==========================================================================
; Procedure LOADFILE opens a file, reads CX bytes into ES:DI, then closes
; the file handle.  If errors are encountered, it calls the exit handler
; to report which file had the issue.
;
; Input:
;
;   DS:SI = location of filename string, null-terminated
;   ES:DI = destination buffer for file contents
;   CX    = number of bytes to read
;
; Output: "Error ? handling file: xxxxxxxx.xxxx" message printed to user,
; where "?" is:
;   o: opening file
;   r: reading file
;   c: closing file
;
; Also returns the DOS error code as the ERRORLEVEL (exit code) which can
; be printed and/or checked for in a DOS batch file to see exactly what
; error DOS encountered.

loadfile:
        ; copy filename string to error string in case we need to print it
        pushf
        pusha
        push    ds

        xor     bx,bx
        mov     [f_size],cx
        push    cx
        mov     cx,12                   ; copy no more than 12 characters
        push    si
.R0:
        lodsb                           ; load a char
        test    al,al                   ; is it 0?
        jz      .R1                     ; if so, stop copying
        mov     [cs:f_name+bx],al       ; otherwise, copy the char we loaded
        inc     bx                      ; point to next target char position
        loop    .R0
.R1:
        pop     si                      ; restore ds:si source filename
        pop     cx                      ; restore length to copy

        ; open file handle, read-only
        ; mov     al,0                    ; read-only
        ; mov     ah,03dh                 ; open file handle
        ; mov     dx,si                   ; ds:si = filename = ds:dx
        ; int     21h
        call    safer_open
        jnc     .success                ; handle open errors
        cmp     byte [safer_open_allow_ignore],1
        jne     openerror
        jmp     .end
.success:

        ; read file into memory
        mov     bx,ax                   ; use file handle we just created
        ; read into our scratch buffer
        mov     ds,[SCRATCHSEG]
        xor     dx,dx
        mov     ah,03fh                 ; int 21,3f = read from file or device
        int     21h
        jc      readerror
        ; if we got this far, store how many bytes we actually read
        mov     [cs:f_read],cx          ; assume we read in what we asked for
        cmp     cx,ax                   ; ...but was it a partial read?
        je      .E0                     ; skip if it wasn't
        mov     [cs:f_read],ax          ; record if it was
.E0:

        ; close file handle
        mov     ah,03eh
        int     21h
        jc      closeerror
        call    decomp
.end:
        pop     ds
        popa
        popf
        ret

openerror:
        mov     byte [cs:f_errs+6],'o'
        jmp     exiterror
readerror:
        mov     byte [cs:f_errs+6],'r'
        jmp     exiterror
closeerror:
        mov     byte [cs:f_errs+6],'c'
exiterror:
        call    EXITPROG
f_errs  DB "Error x handling file: "
f_name  DB "            ",13,10,0
f_size  DW 0 ; number of bytes requested to read in from the file
f_read  DW 0 ; number of bytes actually read


decomp:
        mov     si,dx                   ; ds:si = scratchseg:0
        ; mov     ax,es
        ; cmp     ax,0a000h               ; is the destination screen ram?
        ; jae     fadeit                  ; if so, do a visual fade transfer
        mov     ax,es
        cmp     ax,[cs:SCRATCHSEG]
        je      inplace
        call    dzx7_speed              ; decompress to actual destination
        ret

; fadeit:
inplace:
        ; Doing a fade to the screen requires some careful planning.
        ; We want to decompress the file "in place" so that we don't use
        ; more memory than we have to.  To do that, we'll have to move
        ; the compressed data to the end of our scratch buffer, plus one
        ; paragraph more to give us some overlap so we don't decompress
        ; right over still-compressed data.  Once that's done, we'll
        ; have the data completely decompressed in the scratch buffer
        ; and can then copy it to the destination with a transition.

        ; 1. Move compressed data from scratchseg:0 to scratchseg+1:end
        push    es,di,ds,si
        mov     ax,ds
        inc     ax
        mov     es,ax                   ; es = ds+1 = one paragraph beyond ds
        mov     cx,[cs:f_read]          ; cx = # of compressed bytes to move
        add     si,cx
        dec     si                      ; ds:si = last byte of comp.data
        mov     di,[cs:f_size]          ; es:di = end of new compressed dest.
        std                             ; string ops work in reverse
        rep     movsb                   ; perform overlapping copy of comp.data
        inc     si                      ; fixup: si on first byte of comp.data
        inc     di                      ; fixup: di on first byte of uncomparea
        cld                             ; string ops work normally (forward)
        ; now we need to set up ds:si and es:di again for the decompress
        push    es,ds
        pop     es,ds                   ; swap ds and es
        xchg    si,di                   ; ds:si = start of compressed data
                                        ; es:di = scratchbuf:0
        call    dzx7_speed              ; decomp from ds:si to es:di
        pop     si,ds,di,es             ; restore our original src and dst
ret

        ; 2. Now that we've decompressed in-place to scratchbuf:0, we can
        ; move it to its final destination -- all FANCY-LIKE!
        ; We'll use an exact-period Galois linear feedback shift register
        ; to generate offsets in a pseudo-random manner.

fadestart:
        call    [cs:convert_screen]
        mov     dx,FADESTEPS            ; dx = total iterations to complete
        mov     ax,1                    ; ax = lfsr with 2^14 non-zero seed
        ; copy offset 0, because lfsr cannot
        call    [cs:converting_sys_to_vid_movsb]

fullLoop:
        mov     cx,[cs:fadestep_chunks]
        ; grab int. handler global tick counter, which ticks at (18*4) Hz
        mov     bp,[cs:word handler_ticks]

copyloop:
        shr     ax,1                    ; lfsr: shift untapped bits
        sbb     bx,bx                   ; bx = -(least significant bit)
        and     bx,[cs:lfsr_tap_bits]
        xor     ax,bx                   ; flip bits if lsb = 1
        mov     si,ax
        mov     di,si                   ; di = si = our byte to copy
        ; copy to screen
        call    [cs:converting_sys_to_vid_movsb]
        loop    copyloop                ; do it # of bytes to copy
copyloop_end:
.L9:
        ; did int. handler tick again?
        cmp     bp,word [cs:handler_ticks]
        je      .L9                     ; keep waiting if not
        dec     dx                      ; mark one FADESTEP off the list
        jnz     fullLoop                ; keep going if we have more to do

        ret


; ==========================================================================

; description:
;       Load a fullscreen bitmap with fade-in effect.
; parameters:
;       ds:si = filename
LOAD_SCREEN:
        push    es
        push    di

        mov     bp,[SCRATCHSEG]
        mov     es,bp
        xor     di,di
        mov     cx,[framebuf_size]
        call    loadfile

        pop     di
        pop     es

        push    ds
        mov     ax,[SCRATCHSEG]
        mov     ds,ax
        xor     si,si
        mov     di,si
        call    fadestart
        pop     ds

        ret


; description:
;       Load tile description data.
LOAD_DATA:
        push    es
        push    di

        mov     si,FILENAME_DATA        ; ds:si = filename
        push    ds
        pop     es
        mov     di,TILENAMES            ; es:di = ds:tilenames
        mov     cx,3840
        call    loadfile

        pop     di
        pop     es
        ret


; description:
;       Load the appropriate tile set, converting it if necessary.
LOAD_TILES:
        push    es
        push    di

        ; This is the most convenient spot to process tile set overrides:
        ; If tileset_size indicates VGA and cmd_arg_o is 2 or 4,
        ; use CGA or TDY, instead, and convert convert it to VGA format.
        ; NOTE: Simpler overrides, like CG2 to CGA or CMP to TDY use
        ;       the normal conversion mechanisms, only.
        cmp     word [tileset_size],65535
        jne     .load_normal
        cmp     byte [cmd_arg_o],'2'
        jne     .cmd_arg_o_not_2
        call    load_tiles_o2
        jmp     .end
        .cmd_arg_o_not_2:
        cmp     byte [cmd_arg_o],'4'
        jne     .load_normal
        call    load_tiles_o4
        jmp     .end

        .load_normal:
        mov     si,FILENAME_TILES       ; ds:si = filename
        mov     bp,[TILELOADSEG]
        mov     es,bp
        xor     di,di                   ; es:di = tileseg:0
        mov     cx,[tileset_size]
        call    loadfile

        call    [convert_tiles]         ; convert assets if necessary

        .end:
        pop     di
        pop     es
        ret


; description:
;       Load the CGA tile set, convert it to 256 colors and potentially convert it further.
load_tiles_o2:
        ; temporarily alter LUT entries
        cmp     byte [cmd_arg_g],1
        je      .patching_done
        cmp     byte [VGA_TO_ETGA_LUT+7],0fh
        jne     .not_0fh
        mov     byte [VGA_TO_ETGA_LUT+7],77h
        jmp     .patching_done
        .not_0fh:
        mov     byte [VGA_TO_ETGA_LUT+7],0fah
        .patching_done:

        mov     si,FILENAME_TILES
        mov     byte [si+6],'C'
        mov     byte [si+7],'G'
        mov     byte [si+8],'A'
        mov     es,[MAPSEG]             ; use stll unused map as buffer
        xor     di,di                   ; es:di = tileseg:0
        mov     cx,16384
        call    loadfile
        push    ds
        mov     es,[TILELOADSEG]
        mov     ds,[MAPSEG]
        xor     si,si
        xor     di,di
        mov     cx,16384
        xor     bx,bx
        .conv_loop:
        mov     di,si
        shl     di,2
        mov     dx,di
        mov     ax,di
        and     di,0ff0fh
        shl     dx,1
        and     dx,000e0h
        shr     ax,3
        and     ax,00010h
        or      di,ax
        or      di,dx
        lodsb
        mov     dl,al
        mov     bl,al
        shr     bl,3
        and     bl,1eh
        mov     ax,[cs:bx+.lut]
        stosw
        mov     bl,dl
        shl     bl,1
        and     bl,1eh
        mov     ax,[cs:bx+.lut]
        stosw
        loop    .conv_loop
        pop     ds

        call    [convert_tiles]

        ; restore altered LUT entries
        cmp     byte [cmd_arg_g],1
        je      .backpatching_done
        cmp     byte [VGA_TO_ETGA_LUT+7],77h
        jne     .not_77h
        mov     byte [VGA_TO_ETGA_LUT+7],0fh
        jmp     .backpatching_done
        .not_77h:
        mov     byte [VGA_TO_ETGA_LUT+7],33h
        .backpatching_done:

        ret
.lut    dw      0000h,0700h,0800h,0f00h
        dw      0007h,0707h,0807h,0f07h
        dw      0008h,0708h,0808h,0f08h
        dw      000fh,070fh,080fh,0f0fh


; description:
;       Load the TDY tile set, convert it to 256 colors and potentially convert it further.
load_tiles_o4:
        ; temporarily alter LUT entries
        cmp     byte [cs:cmd_arg_g],1
        je      .patching_done
        cmp     byte [cs:VGA_TO_ETGA_LUT+7],0fh
        jne     .not_0fh
        mov     byte [cs:VGA_TO_ETGA_LUT+7],77h
        jmp     .patching_done
        .not_0fh:
        mov     byte [cs:VGA_TO_ETGA_LUT+7],0fah
        .patching_done:

        mov     si,FILENAME_TILES
        mov     byte [si+6],'T'
        mov     byte [si+7],'D'
        mov     byte [si+8],'Y'
        mov     es,[MAPSEG]             ; use stll unused map as buffer
        xor     di,di                   ; es:di = tileseg:0
        mov     cx,16384
        call    loadfile
        push    ds
        mov     es,[TILELOADSEG]
        mov     ds,[MAPSEG]
        xor     si,si
        xor     di,di
        mov     cx,16384
        xor     bx,bx
        .conv_loop:
        mov     di,si
        shl     di,2
        mov     dx,di
        mov     ax,di
        and     di,0ff0fh
        shl     dx,1
        and     dx,000e0h
        shr     ax,3
        and     ax,00010h
        or      di,ax
        or      di,dx
        lodsb
        mov     dl,al
        mov     bl,al
        shr     bl,3
        and     bl,1eh
        mov     ax,[cs:bx+.lut]
        stosw
        mov     bl,dl
        shl     bl,1
        and     bl,1eh
        mov     ax,[cs:bx+.lut]
        stosw
        loop    .conv_loop
        pop     ds

        call    [convert_tiles]

        ; restore altered LUT entries
        cmp     byte [cmd_arg_g],1
        je      .backpatching_done
        cmp     byte [VGA_TO_ETGA_LUT+7],77h
        jne     .not_77h
        mov     byte [VGA_TO_ETGA_LUT+7],0fh
        jmp     .backpatching_done
        .not_77h:
        mov     byte [VGA_TO_ETGA_LUT+7],33h
        .backpatching_done:

        ret
.lut    dw      0000h,0505h,0303h,0404h
        dw      0101h,0606h,0202h,0707h
        dw      0808h,0d0dh,0b0bh,0c0ch
        dw      0909h,0e0eh,0a0ah,0f0fh


; description:
;       Load a map.
; parameters:
;       MAP_NAME
LOAD_MAP:
        push    es
        push    di

        mov     si,MAP_NAME             ; ds:si = filename
        mov     bp,[MAPSEG]
        mov     es,bp
        xor     di,di                   ; es:di = MAPSEG:0
        mov     cx,32768                ; size of map data
        call    loadfile

        pop     di
        pop     es
        ret


; description:
;       Flip the map horizontally, vertically or both, according to mirror_settings.
mirror_map_as_necessary:
        push    es
        push    ds

        cmp     byte [mirror_settings],0
        je      .end

        ; load appropriate LUTs
        mov     al,[FILENAME_DATA+7]
        mov     [FILENAME_MLUTS+7],al
        mov     si,FILENAME_MLUTS
        mov     es,[SCRATCHSEG]
        xor     di,di
        mov     cx,512
        call    loadfile

        xor     si,si
        xor     bx,bx
        cmp     byte [mirror_settings],2
        mov     ds,[MAPSEG]
        mov     cx,32768
        je      .v_mirror_init
.h_mirror_loop:
        test    si,0080h
        jnz     .l1
        mov     di,si
        xor     di,00ffh
        mov     al,[si]
        es      xlatb
        xchg    [di],al
        es      xlatb
        mov     [si],al
        .l1:
        inc     si
        loop    .h_mirror_loop
        cmp     byte [cs:mirror_settings],3
        je      .v_mirror_init
        jmp     .end
.v_mirror_init:
        inc     bh
        mov     cx,16384
        xor     si,si
.v_mirror_loop:
        mov     di,si
        xor     di,7f00h
        mov     al,[si]
        es      xlatb
        xchg    [di],al
        es      xlatb
        mov     [si],al
        inc     si
        loop    .v_mirror_loop
        jmp     .end

.end:
        pop     ds
        pop     es
        ret


; description:
;       Load the appropriate font for this video mode.
;       NOTE: Use before set_video, which may convert the format.
LOAD_FONT:
        push    es
        push    di

        mov     si,FILENAME_FONT        ; ds:si = filename
        push    ds
        pop     es
        mov     di,FONT                 ; es:di = FONT array
        mov     cx,[font_size]
        call    loadfile

        pop     di
        pop     es
        ret


; description:
;       Load the map list from MAPLIST.BIN, but resume with the internal
;       map list upon failure.
load_maplist:
        mov     si,.maplist_name
        call    safer_open
        jc      .l2
        mov     [handle],ax
        jmp     .l3
        .l2:                            ; error
        ; NOTE: Loading the map list failed => use internal one!
        ret
        .l3:                            ; load maplist
        ; load maplist data
        mov     bx,[handle]
        mov     dx,maplist_data_block   ; destination buffer
        mov     cx,512                  ; number of bytes
        mov     ah,03fh                 ; read file instruction
        int     21h
        ; close file
        mov     ah,3eh
        mov     bx,[handle]
        int     21h
        ret
.maplist_name   db "MAPLIST.BIN"
