 /*************************************************************************
 *                (c) Copyright 2012 Stanislav Datskovskiy                *
 *                         http://www.loper-os.org                        *
 **************************************************************************
 *                                                                        *
 *  This program is free software: you can redistribute it and/or modify  *
 *  it under the terms of the GNU General Public License as published by  *
 *  the Free Software Foundation, either version 3 of the License, or     *
 *  (at your option) any later version.                                   *
 *                                                                        *
 *  This program is distributed in the hope that it will be useful,       *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *  GNU General Public License for more details.                          *
 *                                                                        *
 *  You should have received a copy of the GNU General Public License     *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *                                                                        *
 *************************************************************************/


;*****************************************************************************
;; Call BIOS idle
;*****************************************************************************
bios_idle:
    int    PUSHALL_INT
    int    IDLE_INT
    int    POPALL_INT
    ret
;*****************************************************************************


;*****************************************************************************
;; Delay - call idle loop R0 times
;*****************************************************************************
delay:
    call   bios_idle
    subi   r0, 1
    jnz    delay
    ret
;*****************************************************************************


;*****************************************************************************
; mem_move
; r9 = dest, r8 = src, r1 = word count
;*****************************************************************************
mem_move:
@@:
    mov    w[r9++], w[r8++]	; copy data
    dec    r1
    jnz    @b
    ret
;*****************************************************************************


;*****************************************************************************
; subtract (16-bit)
; R1:R0 - R3:R2
;*****************************************************************************
subtract_16:
    push   r4
    xor    r4, r4
    sub    r0, r2 ; Subtract the lower halves.  This may "borrow" from the upper half.
    jnc    @f
    mov    r4, 1
@@:
    subb   r1, r3 ; Subtract the upper halves.
    jc     @f	  ; Carry set from subtracting upper halves?
    test   r4, 1  ; If not, see if carry was set from subtracting lower halves:
    jz     @f
    stc
@@:
    pop    r4
    ret
;*****************************************************************************
