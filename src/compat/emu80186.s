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

%define ROL rol

%macro rol 2
  %ifidn %2,cl
        rol     %1,cl
  %else
    %rep %2
        rol     %1,1
    %endrep
  %endif
%endmacro

%define ROR ror

%macro ror 2
  %ifidn %2,cl
        ror     %1,cl
  %else
    %rep %2
        ror     %1,1
    %endrep
  %endif
%endmacro

%define SAL sal

%macro sal 2
  %ifidn %2,cl
        sal     %1,cl
  %else
    %rep %2
        sal     %1,1
    %endrep
  %endif
%endmacro

%define SAR sar

%macro sar 2
  %ifidn %2,cl
        sar     %1,cl
  %else
    %rep %2
        sar     %1,1
    %endrep
  %endif
%endmacro

%define SHL shl

%macro shl 2
  %ifidn %2,cl
        shl     %1,cl
  %else
    %rep %2
        shl     %1,1
    %endrep
  %endif
%endmacro

%define SHR shr

%macro shr 2
  %ifidn %2,cl
        shr     %1,cl
  %else
    %rep %2
        shr     %1,1
    %endrep
  %endif
%endmacro

%define PUSHA pusha

%macro pusha 0
        push    ax
        push    cx
        push    dx
        push    bx
        push    sp
        push    bp
        push    si
        push    di
%endmacro

%define POPA popa

%macro popa 0
        pop     di
        pop     si
        pop     bp
        pop     bx      ;sp?
        pop     bx
        pop     dx
        pop     cx
        pop     ax
%endmacro
