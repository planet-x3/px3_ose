SPEEDONLY EQU 1 ; change to 0 if you want to call the dzx7_size routine too

; Decompresses Einar Saukas' ZX7 compressed stream data in 16-bit real mode.
; ZX7 format and original Z80 decompressor by Einar Saukas.
; Original Z80 to 8086 conversion, and size-optimized version, by Peter Ferrie.
; Speed-optimized code by Peter Ferrie and Jim Leonard.
; 20160308
; 20181216 - Adapted for A86+PX3 by Jim Leonard
;
; The source for the conversion was the original "default" Z80 decompression
; code provided by Einar.  Further size optimization and unrolling were
; independently performed specifically for the 8086.
; Source is formatted for Borland Turbo Assembler IDEAL mode and NEAR calls,
; however it should be very easy to port to other assemblers if necessary.
;
; Input:
;   Call "dzx7_size" or "dzx7_speed" with:
;   DS:SI - Location of source compressed data
;   ES:DI - Location to put decompressed output
;   Overlapping decompression is supported; see OVERLAPPING below.
;
; Pre/Post actions:
;   If you want to know what the size of the decompressed output is,
;   measure the difference between DI before and after calling a routine.
;   For example, something like:
;       push    di
;       call    dzx7_speed
;       pop     ax
;       sub     di,ax
;
; Limitations:
;   Trashes most registers and flags.  Preserve what you need before calling.
;   Source and destintation are each limited to a 64K segment.
;   Supports forward compression only; backward decompression not implemented.
;
; OVERLAPPING decompression is supported: The command-line compressor outputs
; the minimum distance ("delta") needed to perform this.  To perform
; overlapping decompression, the END of the compressed data needs to be
; "delta" bytes AHEAD of the END of the decompressed area.  This requires
; prior knowledge of the size of the decompressed output, as the ZX7 stream
; format does not include that information.


;USER-CHANGEABLE SECTION BEGINS===

OPTIMIZE_RLE EQU 0
;When using the speed-optimized routine, setting OPTIMIZE_RLE to 1 speeds
;up decompressing very sparse data (ie. data where there are large runs of
;the same value) about 3%, but hurts decompression speed of most normal
;data types by 3%.  Turn this on if you are compressing a lot of sparse
;data, otherwise leave it off.

CPU_BUG_WORKAROUND EQU 1
;There is a bug in the 8086 to 80286 CPUs where more than one instruction
;prefix is not honored after an interrupt occurs.  This code avoids the bug,
;but there is an ~8% speed penalty for doing so.  If you are certain you
;will ALWAYS run this code on a 386 or higher, you can turn it off.
;We recommend you leave this alone.

DISABLE_INTERRUPTS EQU 0
;If CPU_BUG_WORKAROUND is enabled, there is a faster way to work around the
;bug by disabling interrupts during match copies.  While this is ~4% faster,
;it can disable interrupts for as long as 524 cycles on an 8086, which can
;introduce timing jitter in devices that need their interrupts serviced
;quickly.  For most situations, this is fine, but if you are doing something
;interrupt-heavy (like digitized audio through the speaker) and don't want
;this routine disabling interrupts, turn off DISABLE_INTERRUPTS.

;USER-CHANGEABLE SECTION ENDS=====

%IF SPEEDONLY=0

;==========================================================================
;dzx7_size assembles to 71 bytes.  It is the smallest routine and, for most
;material, the same speed as the original dzx7_standard conversion.
;==========================================================================
dzx7_size:
        mov     al, 80h
        xor     cx, cx
        mov     bp, @@dzx7si_next_bit
        cld
@@dzx7si_copy_byte_loop:
        movsb                           ; copy literal byte
@@dzx7si_main_loop:
        call    bp
        jnc     @@dzx7si_copy_byte_loop ; next bit indicates either
                                        ; literal or sequence

; determine number of bits used for length (Elias gamma coding)
        xor     bx, bx
@@dzx7si_len_size_loop:
        inc     bx
        call    bp
        jnc     @@dzx7si_len_size_loop
        db      80h                     ; mask call
; determine length
@@dzx7si_len_value_loop:
        call    bp
@@dzx7si_len_value_skip:
        adc     cx, cx
        jb      @@dzx7si_next_bit_ret   ; check end marker
        dec     bx
        jnz     @@dzx7si_len_value_loop
        inc     cx                      ; adjust length

; determine offset
        mov     bl, [si]                ; load offset flag (1 bit) +
                                        ; offset value (7 bits)
        inc     si
        stc
        adc     bl, bl
        jnc     @@dzx7si_offset_end     ; if offset flag is set, load
                                        ; 4 extra bits
        mov     bh, 10h                 ; bit marker to load 4 bits
@@dzx7si_rld_next_bit:
        call    bp
        adc     bh, bh                  ; insert next bit into D
        jnc     @@dzx7si_rld_next_bit   ; repeat 4 times, until bit
                                        ; marker is out
        inc     bh                      ; add 128 to DE
@@dzx7si_offset_end:
        shr     bx, 1                   ; insert fourth bit into E

; copy previous sequence
        push    si
        mov     si, di
        sbb     si, bx                  ; destination = destination - offset - 1
%IF CPU_BUG_WORKAROUND
; CPUs < 386 can't handle two prefixes properly with interrupts on,
; so we can't use "es: rep movsb" and must fall back to something compatible
@@again:
        es     movsb
        loop    @@again
%ELSE
        es     rep movsb
%ENDIF
        pop     si                      ; restore source address
                                        ; (compressed data)
        jmp     @@dzx7si_main_loop
@@dzx7si_next_bit:
        add     al, al                  ; check next bit
        jnz     @@dzx7si_next_bit_ret   ; no more bits left?
        lodsb                           ; load another group of 8 bits
        adc     al, al
@@dzx7si_next_bit_ret:
        ret

%ENDIF


;===========================================================================
;dzx7_speed is a speed-optimized version that increases speed between 80%
;(worst case) and 100% (best case) over the others at the expense of size.
;Default configuration assembles to 269 bytes; other combinations will vary.
;===========================================================================

dzx7_speed:

%MACRO next_bit 0
        shl     al,1                    ;check next bit
        jnz     %%M0                     ;no more bits left?
        lodsb                           ;load another group of 8 bits
        rcl     al,1                    ;...and put first bit into carry
%%M0:
%ENDMACRO

        mov     al,80h                  ;init mask
        xor     cx,cx                   ;init counter
        cld                             ;ensure we are always moving forward
@@dzx7s_copy_byte_loop:
        movsb                           ;copy literal byte
@@dzx7s_main_loop:
        next_bit                        ;get next bit
        jnc     @@dzx7s_copy_byte_loop  ;bit clear = literal; bit set = match

;determine number of bits used for length (Elias gamma coding)
        xor     dx,dx
@@dzx7s_len_size_loop:
%MACRO sizeloop 0
%REP 7
        inc     dx
        next_bit                        ;get next bit
        jc      @@dzx7s_len_value_skip
%ENDREP
%ENDMACRO
        sizeloop
        inc     dx
        next_bit                        ;get next bit
        jnc     @@dzx7s_len_size_loop
        jmp     @@dzx7s_len_value_skip

;determine length
@@dzx7s_len_value_loop:
        next_bit                        ;get next bit

@@dzx7s_len_value_skip:
        rcl     cx,1
        jc      @@decompdone            ;check end marker
%MACRO valskiploop 0
%REP 7
        dec     dx
        jz      @@dzx7s_len_value_adjust
        next_bit                        ;get next bit
        rcl     cx,1
%ENDREP
%ENDMACRO
        valskiploop
        dec     dx
        jnz     @@dzx7s_len_value_loop

        db      0b2h                    ;mask ret to retain relative branch distance
@@decompdone:
        ret

@@dzx7s_len_value_adjust:
        inc     cx                      ;adjust length

;determine offset
        mov     dl,[si]                 ;load offset flag (1 bit) +
                                        ;offset value (7 bits)
        inc     si
        stc
        rcl     dl,1
        jnc     @@dzx7s_offset_end      ;if offset flag set, load 4 more bits
@@dzx7s_rld_next_bit:
%MACRO nextbits 0
%REP 4
        next_bit                        ;get next bit
        rcl     dh,1                    ;insert next bit
%ENDREP
%ENDMACRO
        nextbits
                                        ;marker is out
        inc     dh                      ;add 128
@@dzx7s_offset_end:
        shr     dx,1                    ;insert fourth bit
%IF OPTIMIZE_RLE
        jz      @@run                   ;dx=0=run, which we can do faster
%ENDIF

;copy previous sequence
%IF CPU_BUG_WORKAROUND
  %IF DISABLE_INTERRUPTS
        mov     bx,si                   ;preserve source address
        mov     si,di
        sbb     si,dx                   ;destination = dest. - offset - 1
        cli
        es:     rep movsb
        sti
        mov     si,bx                   ;restore source address (comp. data)
  %ELSE
        ;CPUs < 386 can't handle two prefixes properly with interrupts on,
        ;so we can't use "es: rep movsb" and must fall back to "rep movsb"
        mov     bp,ds                   ;preserve ds
        mov     bx,es
        mov     ds,bx                   ;ds=es
        mov     bx,si                   ;preserve source address
        mov     si,di
        sbb     si,dx                   ;destination = dest. - offset - 1
        rep     movsb
        mov     si,bx                   ;restore source address (comp. data)
        mov     ds,bp                   ;restore ds
  %ENDIF
%ELSE
        mov     bx,si                   ;preserve source address
        mov     si,di
        sbb     si,dx                   ;destination = dest. - offset - 1
        es:     rep movsb
        mov     si,bx                   ;restore source address (comp. data)
%ENDIF
        jmp     @@dzx7s_main_loop

%IF OPTIMIZE_RLE
@@run:
        xchg    bp,ax                   ;preserve bitmask
        mov     bx,di
        sbb     bx,dx                   ;destination = dest. - offset - 1
        mov     al,[es:bx]
        rep     stosb
        xchg    bp,ax                   ;restore bitmask
        jmp     @@dzx7s_main_loop
%ENDIF

        ret

        END
