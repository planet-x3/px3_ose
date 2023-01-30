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
; - Benedikt Freisen
;
; *)  Of or for 8-Bit Productions LLC
; **) Partly for 8-Bit Productions LLC

VGA_PALETTE     db 0,0,0        ; index 0
                db 170,0,0      ; index 1
                db 170,85,0     ; index 2
                db 0,170,0      ; index 3
                db 0,170,170    ; index 4
                db 0,0,170      ; index 5
                db 170,0,170    ; index 6
                db 170,170,170  ; index 7
                db 85,85,85     ; index 8
                db 255,85,85    ; index 9
                db 255,255,85   ; index 10
                db 85,255,85    ; index 11
                db 85,255,255   ; index 12
                db 85,85,255    ; index 13
                db 0,0,0        ; index 14 (transparency)
                db 255,255,255  ; index 15
                db 79,0,23      ; index 16
                db 144,0,28     ; index 17
                db 207,35,16    ; index 18
                db 208,83,7     ; index 19
                db 218,101,5    ; index 20
                db 218,141,0    ; index 21
                db 220,185,3    ; index 22
                db 220,216,41   ; index 23
                db 217,223,92   ; index 24
                db 219,226,133  ; index 25
                db 236,243,154  ; index 26
                db 246,251,185  ; index 27
                db 254,255,184  ; index 28
                db 251,253,135  ; index 29
                db 251,255,38   ; index 30
                db 255,226,33   ; index 31
                db 82,48,35     ; index 32
                db 122,66,40    ; index 33
                db 147,81,42    ; index 34
                db 178,107,55   ; index 35
                db 201,131,72   ; index 36
                db 244,141,54   ; index 37
                db 248,143,85   ; index 38
                db 252,146,122  ; index 39
                db 255,155,155  ; index 40
                db 255,175,175  ; index 41
                db 254,199,163  ; index 42
                db 253,217,153  ; index 43
                db 252,231,146  ; index 44
                db 255,188,177  ; index 45
                db 255,155,155  ; index 46
                db 255,122,154  ; index 47
                db 52,52,59     ; index 48
                db 79,30,91     ; index 49
                db 89,58,112    ; index 50
                db 141,78,78    ; index 51
                db 185,87,55    ; index 52
                db 202,109,78   ; index 53
                db 210,132,106  ; index 54
                db 220,158,137  ; index 55
                db 244,170,144  ; index 56
                db 203,148,173  ; index 57
                db 179,135,189  ; index 58
                db 145,117,213  ; index 59
                db 134,117,175  ; index 60
                db 120,110,144  ; index 61
                db 98,93,110    ; index 62
                db 75,73,79     ; index 63
                db 39,32,12     ; index 64
                db 67,55,20     ; index 65
                db 98,81,29     ; index 66
                db 126,104,38   ; index 67
                db 157,130,47   ; index 68
                db 185,152,55   ; index 69
                db 202,171,78   ; index 70
                db 210,184,106  ; index 71
                db 220,199,137  ; index 72
                db 206,184,151  ; index 73
                db 189,165,168  ; index 74
                db 155,146,186  ; index 75
                db 135,125,209  ; index 76
                db 93,90,249    ; index 77
                db 54,109,163   ; index 78
                db 22,110,70    ; index 79
                db 91,40,39     ; index 80
                db 113,55,51    ; index 81
                db 151,91,75    ; index 82
                db 172,117,85   ; index 83
                db 176,143,92   ; index 84
                db 138,166,101  ; index 85
                db 99,183,113   ; index 86
                db 87,196,127   ; index 87
                db 68,209,136   ; index 88
                db 72,223,160   ; index 89
                db 75,231,210   ; index 90
                db 91,240,211   ; index 91
                db 142,249,229  ; index 92
                db 182,230,232  ; index 93
                db 181,194,196  ; index 94
                db 128,128,128  ; index 95
                db 255,153,130  ; index 96
                db 255,190,130  ; index 97
                db 255,223,130  ; index 98
                db 255,255,130  ; index 99
                db 171,255,130  ; index 100
                db 130,255,158  ; index 101
                db 130,255,208  ; index 102
                db 130,255,255  ; index 103
                db 130,237,255  ; index 104
                db 130,223,255  ; index 105
                db 130,206,255  ; index 106
                db 130,190,255  ; index 107
                db 124,175,255  ; index 108
                db 116,158,255  ; index 109
                db 107,137,255  ; index 110
                db 97,113,255   ; index 111
                db 226,111,101  ; index 112
                db 205,140,80   ; index 113
                db 205,173,80   ; index 114
                db 205,205,80   ; index 115
                db 121,205,80   ; index 116
                db 80,205,108   ; index 117
                db 80,205,158   ; index 118
                db 56,227,228   ; index 119
                db 57,203,227   ; index 120
                db 59,182,225   ; index 121
                db 67,158,218   ; index 122
                db 75,140,210   ; index 123
                db 72,125,207   ; index 124
                db 66,108,205   ; index 125
                db 57,87,205    ; index 126
                db 47,63,205    ; index 127
                db 160,58,58    ; index 128
                db 160,101,58   ; index 129
                db 160,128,58   ; index 130
                db 160,160,58   ; index 131
                db 87,160,58    ; index 132
                db 58,160,78    ; index 133
                db 58,160,117   ; index 134
                db 44,173,173   ; index 135
                db 47,149,171   ; index 136
                db 49,131,168   ; index 137
                db 52,114,165   ; index 138
                db 56,101,162   ; index 139
                db 53,90,160    ; index 140
                db 48,78,160    ; index 141
                db 41,63,160    ; index 142
                db 34,45,160    ; index 143
                db 117,42,42    ; index 144
                db 117,73,42    ; index 145
                db 117,92,42    ; index 146
                db 117,117,42   ; index 147
                db 63,117,42    ; index 148
                db 42,117,56    ; index 149
                db 42,117,85    ; index 150
                db 47,115,115   ; index 151
                db 46,100,113   ; index 152
                db 46,89,112    ; index 153
                db 45,78,110    ; index 154
                db 44,70,109    ; index 155
                db 40,61,107    ; index 156
                db 36,53,106    ; index 157
                db 31,42,104    ; index 158
                db 24,30,102    ; index 159
                db 87,31,31     ; index 160
                db 87,54,31     ; index 161
                db 87,68,31     ; index 162
                db 87,87,31     ; index 163
                db 47,87,31     ; index 164
                db 31,87,42     ; index 165
                db 31,87,63     ; index 166
                db 91,82,83     ; index 167
                db 81,73,77     ; index 168
                db 75,68,73     ; index 169
                db 67,58,67     ; index 170
                db 61,52,63     ; index 171
                db 51,43,55     ; index 172
                db 44,37,47     ; index 173
                db 36,29,38     ; index 174
                db 21,19,22     ; index 175
                db 39,48,91     ; index 176
                db 51,59,113    ; index 177
                db 76,75,151    ; index 178
                db 100,85,172   ; index 179
                db 137,94,177   ; index 180
                db 160,99,143   ; index 181
                db 178,103,113  ; index 182
                db 196,106,87   ; index 183
                db 209,108,68   ; index 184
                db 231,143,74   ; index 185
                db 231,179,75   ; index 186
                db 247,184,103  ; index 187
                db 249,208,142  ; index 188
                db 232,224,182  ; index 189
                db 234,231,201  ; index 190
                db 252,241,224  ; index 191
                db 18,25,43     ; index 192
                db 19,27,49     ; index 193
                db 19,42,74     ; index 194
                db 25,48,86     ; index 195
                db 58,55,76     ; index 196
                db 91,50,64     ; index 197
                db 97,60,61     ; index 198
                db 134,62,48    ; index 199
                db 150,73,47    ; index 200
                db 164,93,49    ; index 201
                db 174,118,59   ; index 202
                db 180,137,74   ; index 203
                db 183,145,103  ; index 204
                db 182,167,126  ; index 205
                db 183,174,156  ; index 206
                db 191,190,193  ; index 207
                db 11,15,23     ; index 208
                db 15,21,35     ; index 209
                db 20,30,55     ; index 210
                db 21,34,62     ; index 211
                db 22,43,78     ; index 212
                db 25,53,96     ; index 213
                db 20,59,123    ; index 214
                db 50,75,115    ; index 215
                db 58,104,103   ; index 216
                db 58,121,90    ; index 217
                db 59,138,77    ; index 218
                db 104,159,91   ; index 219
                db 182,167,126  ; index 220
                db 225,195,144  ; index 221
                db 232,211,168  ; index 222
                db 232,224,182  ; index 223
                db 17,33,58     ; index 224
                db 17,37,57     ; index 225
                db 16,42,56     ; index 226
                db 15,46,53     ; index 227
                db 14,52,51     ; index 228
                db 13,60,49     ; index 229
                db 14,72,46     ; index 230
                db 14,86,46     ; index 231
                db 17,111,54    ; index 232
                db 16,134,60    ; index 233
                db 16,155,62    ; index 234
                db 17,176,66    ; index 235
                db 20,192,70    ; index 236
                db 21,204,75    ; index 237
                db 36,220,85    ; index 238
                db 53,231,113   ; index 239
                db 31,26,19     ; index 240
                db 54,46,33     ; index 241
                db 79,67,48     ; index 242
                db 102,87,62    ; index 243
                db 127,108,77   ; index 244
                db 149,126,90   ; index 245
                db 168,146,112  ; index 246
                db 181,163,134  ; index 247
                db 197,182,159  ; index 248
                db 191,178,166  ; index 249
                db 182,171,174  ; index 250
                db 166,161,175  ; index 251
                db 154,153,182  ; index 252
                db 135,142,203  ; index 253
                db 117,133,182  ; index 254
                db 92,117,140   ; index 255

; This LUT converts VGA pixel values to pairs of IRGB pixel values rearranged to RGRGBIBI

VGA_TO_GS_LUT:

; This LUT converts VGA pixel values to packed pairs of IRGB pixel values.
; In VGA mode, it gets overwritten with an identity LUT.

VGA_TO_ETGA_LUT db 0,68,102,34,51,17,85,15,136,204,238,170,187,153,221,255
                db 4,68,76,108,108,78,110,238,238,126,239,239,239,238,238,238
                db 8,6,70,44,44,206,206,124,207,207,207,239,239,207,207,205
                db 8,8,24,72,108,108,124,94,94,79,61,121,105,23,136,8
                db 0,6,6,36,44,44,78,206,126,111,79,45,121,153,19,2
                db 4,6,104,44,44,39,138,58,58,171,187,187,191,191,63,120
                db 94,126,238,238,62,171,123,187,187,187,123,123,155,155,155,153
                db 204,78,78,110,106,58,43,187,155,155,27,57,57,57,25,25
                db 12,102,44,224,10,10,26,11,41,41,19,9,9,9,17,17
                db 4,6,6,36,40,2,40,3,3,24,24,24,24,1,1,1
                db 4,6,6,6,2,2,8,136,8,8,8,8,8,0,0,0
                db 1,24,24,137,105,87,140,108,108,206,206,206,126,239,239,255
                db 0,0,1,1,8,8,8,72,70,102,44,44,142,30,15,127
                db 0,0,0,0,1,1,1,24,136,40,40,138,30,126,239,239
                db 0,0,0,0,0,0,0,2,2,2,34,10,42,42,170,170
                db 0,0,8,136,104,44,103,30,111,111,15,119,119,121,23,56

; This LUT converts VGA pixel values to IRGB pixel values.
; Upper 4 bits are best match, lower 4 bits could be used for 2nd best match.

VGA_TO_IRGB_LUT db 0,64,96,32,48,16,80,112,128,192,224,160,176,144,208,240
                db 0,64,192,192,192,192,224,224,224,224,224,240,240,224,224,224
                db 0,96,96,208,192,192,192,192,112,112,224,224,224,240,112,192
                db 0,80,128,128,96,192,208,112,112,112,112,144,112,112,128,128
                db 0,0,128,96,96,96,224,224,240,240,112,112,144,144,48,32
                db 0,128,96,192,112,112,160,160,160,176,176,176,176,240,112,112
                db 192,224,224,224,224,160,176,176,176,240,240,176,176,112,144,144
                db 192,192,224,224,160,160,48,176,176,176,176,144,112,144,144,144
                db 96,96,96,224,32,160,48,48,48,48,48,48,144,16,16,16
                db 64,96,96,96,48,32,48,128,128,128,128,128,128,16,16,16
                db 0,0,128,128,0,32,32,128,128,128,0,128,0,0,0,0
                db 0,128,128,144,144,112,192,192,192,192,224,224,240,240,240,240
                db 0,0,0,0,128,128,128,64,96,192,96,96,112,112,112,112
                db 0,0,0,0,0,16,16,128,128,128,128,160,112,224,240,240
                db 0,0,0,0,0,96,0,0,32,32,160,160,160,160,224,160
                db 0,0,128,128,64,128,112,112,112,112,112,112,240,112,48,112

irgb_to_pal_lut db 00h,05h,03h,04h,01h,06h,02h,07h,08h,0dh,0bh,0ch,09h,0eh,0ah,0fh

; The following table is used to determine if
; a tile is to be drawn as transparent or not.

TRANSPARENCY    db      0,0,0,0,0,0,0,0 ; tile 0
                db      0,0,0,0,0,0,0,0 ; tile 8
                db      0,0,0,0,0,0,0,0 ; tile 10
                db      0,0,0,0,0,0,0,0 ; tile 18
                db      0,0,0,0,0,0,0,0 ; tile 20
                db      0,0,0,0,0,0,0,0 ; tile 28
                db      0,0,0,0,0,0,0,0 ; tile 30
                db      0,0,0,0,0,0,0,0 ; tile 38
                db      0,0,0,0,0,0,0,0 ; tile 40
                db      0,0,0,0,0,0,0,0 ; tile 48
                db      1,1,1,1,1,1,1,1 ; tile 50
                db      1,1,1,1,1,1,1,1 ; tile 58
                db      1,1,0,0,0,0,0,0 ; tile 60
                db      0,0,0,0,0,0,0,0 ; tile 68
                db      0,0,0,0,0,0,0,0 ; tile 70
                db      0,0,0,0,0,0,0,0 ; tile 78
                db      0,0,0,0,0,0,0,0 ; tile 80
                db      0,0,0,0,1,1,1,1 ; tile 88
                db      0,0,0,0,1,1,1,1 ; tile 90
                db      0,0,0,0,0,0,0,1 ; tile 98
                db      1,1,1,1,1,1,1,1 ; tile a0
                db      1,1,1,1,1,1,1,1 ; tile a8
                db      1,1,1,1,0,0,1,1 ; tile b0
                db      0,0,0,0,0,0,0,0 ; tile b8
                db      0,0,0,0,0,0,0,0 ; tile c0
                db      0,0,0,0,0,0,0,0 ; tile c8
                db      0,0,0,0,0,0,0,0 ; tile d0
                db      0,0,0,0,0,0,0,1 ; tile d8
                db      0,0,0,0,0,0,0,0 ; tile e0
                db      0,0,0,0,0,0,0,0 ; tile e8
                db      0,0,0,0,0,0,0,0 ; tile f0
                db      0,0,0,0,0,0,0,0 ; tile f8
