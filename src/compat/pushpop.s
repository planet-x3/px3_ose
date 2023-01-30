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

%macro push 1
        push    %1
%endmacro

%macro push 2
        push    %1
        push    %2
%endmacro

%macro push 3
        push    %1
        push    %2
        push    %3
%endmacro

%macro push 4
        push    %1
        push    %2
        push    %3
        push    %4
%endmacro

%macro push 5
        push    %1
        push    %2
        push    %3
        push    %4
        push    %5
%endmacro

%macro push 6
        push    %1
        push    %2
        push    %3
        push    %4
        push    %5
        push    %6
%endmacro

%macro push 7
        push    %1
        push    %2
        push    %3
        push    %4
        push    %5
        push    %6
        push    %7
%endmacro

%macro push 8
        push    %1
        push    %2
        push    %3
        push    %4
        push    %5
        push    %6
        push    %7
        push    %8
%endmacro

%macro pop 1
        pop     %1
%endmacro

%macro pop 2
        pop     %1
        pop     %2
%endmacro

%macro pop 3
        pop     %1
        pop     %2
        pop     %3
%endmacro

%macro pop 4
        pop     %1
        pop     %2
        pop     %3
        pop     %4
%endmacro

%macro pop 5
        pop     %1
        pop     %2
        pop     %3
        pop     %4
        pop     %5
%endmacro

%macro pop 6
        pop     %1
        pop     %2
        pop     %3
        pop     %4
        pop     %5
        pop     %6
%endmacro

%macro pop 7
        pop     %1
        pop     %2
        pop     %3
        pop     %4
        pop     %5
        pop     %6
        pop     %7
%endmacro

%macro pop 8
        pop     %1
        pop     %2
        pop     %3
        pop     %4
        pop     %5
        pop     %6
        pop     %7
        pop     %8
%endmacro
