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

; description:
;       Parse all command line parameters and set variables appropriately.
parse_command_line:
        mov     si,81h                  ; command tail in PSP
.param_loop:
        mov     ah,0
        mov     al,[80h]                ; number of characters in command tail
        add     ax,81h
        cmp     si,ax
        jb      .can_read
        jmp     .end
        .can_read:
        call    read_command_line_char
        cmp     al,' '
        je      .param_loop
        cmp     al,'/'
        je      .is_param
        tcall   command_line_syntax_error
        .is_param:
        call    read_command_line_char
        call    al_to_lower
        cmp     al,'v'
        jne     .not_v
        call    parse_arg_v
        jmp     .after_arg
        .not_v:
        cmp     al,'a'
        jne     .not_a
        call    parse_arg_a
        jmp     .after_arg
        .not_a:
        cmp     al,'i'
        jne     .not_i
        call    parse_arg_i
        jmp     .after_arg
        .not_i:
        cmp     al,'n'
        jne     .not_n
        call    parse_arg_n
        jmp     .after_arg
        .not_n:
        cmp     al,'f'
        jne     .not_f
        call    parse_arg_f
        jmp     .after_arg
        .not_f:
        cmp     al,'o'
        jne     .not_o
        call    parse_arg_o
        jmp     .after_arg
        .not_o:
        cmp     al,'p'
        jne     .not_p
        call    parse_arg_p
        jmp     .after_arg
        .not_p:
        cmp     al,'g'
        jne     .not_g
        call    parse_arg_g
        jmp     .after_arg
        .not_g:
        cmp     al,'c'
        jne     .not_c
        call    parse_arg_c
        jmp     .after_arg
        .not_c:
        cmp     al,'m'
        jne     .not_m
        call    parse_arg_m
        jmp     .after_arg
        .not_m:
        cmp     al,'r'
        jne     .not_m
        call    parse_arg_r
        jmp     .after_arg
        .not_r:
        tcall   command_line_syntax_error
.after_arg:
        jmp     .param_loop
.end:
        ret


; description:
;       Convert a character to lower case.
; parameters:
;       al: the character
; returns:
;       al: the lower case character
al_to_lower:
        cmp     al,'A'
        jb      .end
        cmp     al,'Z'
        ja      .end
        add     al,'a'-'A'
        .end:
        ret

; description:
;       Parse /v.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_v:
        call    read_arg_char
        mov     [cmd_arg_v],al
        ret

; description:
;       Parse /a.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_a:
        call    read_arg_char
        mov     [cmd_arg_a],al
        ret

; description:
;       Parse /i.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_i:
        ; no actual argument
        mov     byte [cmd_arg_i],1
        ret

; description:
;       Parse /n.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_n:
        ; no actual argument
        mov     byte [SOUNDFX_ON],0
        ret

; description:
;       Parse /m.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_m:
        ; no actual argument
        mov     byte [MUSIC_ON],0
        mov     byte [cmd_arg_m],1
        ret

; description:
;       Parse /f.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_f:
        ; no actual argument
        mov     byte [cmd_arg_f],1
        ret

; description:
;       Parse /c.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_c:
        mov     byte [cmd_arg_c],0
        call    arg_has_extra_char
        jnc     .end
        call    read_hex_digit
        mov     byte [cmd_arg_c],1
        mov     byte [cga_color_override],al
        .end:
        ret

; description:
;       Parse /o.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_o:
        call    read_arg_char
        mov     [cmd_arg_o],al
        cmp     al,'2'
        jne     .not2
        ; use CGA instead of CG2 tile set for Monochrome CGA mode
        mov     byte [mode_vars_cg2.file_exts+11],'A'
        .not2:
        cmp     al,'4'
        jne     .not4
        ; use TDY instead of CMP artwork for Composite CGA mode
        mov     byte [mode_vars_cmp.file_exts+9],'T'
        mov     byte [mode_vars_cmp.file_exts+10],'D'
        mov     byte [mode_vars_cmp.file_exts+11],'Y'
        .not4:
        ret

; description:
;       Parse /r.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_r:
        call    read_hex_digit
        and     al,3
        mov     [cmd_arg_r],al
        ret

; description:
;       Read at most four hexadecimal digits as port number.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_p:
        call    read_hex_digit
        mov     [cmd_arg_p],ax
        call    arg_has_extra_char
        jnc     .end
        call    read_hex_digit
        shl     word [cmd_arg_p],4
        or      [cmd_arg_p],ax
        call    arg_has_extra_char
        jnc     .end
        call    read_hex_digit
        shl     word [cmd_arg_p],4
        or      [cmd_arg_p],ax
        call    arg_has_extra_char
        jnc     .end
        call    read_hex_digit
        shl     word [cmd_arg_p],4
        or      [cmd_arg_p],ax
        .end:
        ret

; description:
;       Parse /g.
; parameters:
;       [in,out] si: pointer to the next character
parse_arg_g:
        ; grayscale video requested
        mov     byte [cmd_arg_g],1
        ; if there are argument chars, expect exactly 16
        call    arg_has_extra_char
        jnc     .end
        mov     cx,16
        mov     bx,gray_ramp
        .loop16:
        call    read_hex_digit
        mov     [bx],al
        inc     bx
        loop    .loop16
        .end:
        ret

; description:
;       Read a character from the command line string, aborting on error.
; parameters:
;       [in,out] si: pointer to the next character
; returns:
;       al: the value
read_command_line_char:
        mov     ah,0
        mov     al,[80h]                ; number of characters in command tail
        add     ax,81h
        cmp     si,ax
        jb      .do_it
        tcall   command_line_syntax_error
        .do_it:
        lodsb
        ret

; description:
;       Determine, whether there are still unparsed characters in the command line string.
; returns:
;       cf=1 if there are extra argument characters, i.e. not '/' nor ' '
arg_has_extra_char:
        mov     ah,0
        mov     al,[80h]                ; number of characters in command tail
        add     ax,81h
        cmp     si,ax
        jnb     .end                    ; no characters left => cf=0
        mov     al,[ds:si]
        cmp     al,'/'                  ; cf=0 if equal
        jne     .not_slash
        ret
        .not_slash:
        cmp     al,' '                  ; cf=0 if equal
        jne     .not_space
        ret
        .not_space:
        stc                             ; success => set cf=1
        .end:
        ret

; description:
;       Read a hex digit from the command line string, aborting on error.
; parameters:
;       [in,out] si: pointer to the next character
; returns:
;       ax: the value
read_hex_digit:
        call    read_arg_char
        call    al_to_lower
        mov     ah,0
        cmp     al,'0'
        jb      .error
        cmp     al,'f'
        ja      .error
        cmp     al,'9'
        ja      .not09
        sub     al,'0'
        ret
        .not09:
        cmp     al,'a'
        jb      .error
        sub     al,'a'-10
        ret
        .error:
        tcall   command_line_syntax_error

; description:
;       Read a single character argument from the command line string, aborting on error.
; parameters:
;       [in,out] si: pointer to the next character
; returns:
;       al: the value
read_arg_char:
        call    read_command_line_char
        cmp     al,'/'
        je      .error
        cmp     al,' '
        je      .error
        ret
        .error
        tcall   command_line_syntax_error

; description:
;       Exit with an error message.
; returns:
;       DOES NOT RETURN
command_line_syntax_error:
        call    EXITPROG
        db      "Command line syntax error! Exiting.",13,10,0
