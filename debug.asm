 ;; /*************************************************************************
 ;; *                (c) Copyright 2012 Stanislav Datskovskiy                *
 ;; *                         http://www.loper-os.org                        *
 ;; **************************************************************************
 ;; *                                                                        *
 ;; *  This program is free software: you can redistribute it and/or modify  *
 ;; *  it under the terms of the GNU General Public License as published by  *
 ;; *  the Free Software Foundation, either version 3 of the License, or     *
 ;; *  (at your option) any later version.                                   *
 ;; *                                                                        *
 ;; *  This program is distributed in the hope that it will be useful,       *
 ;; *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 ;; *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 ;; *  GNU General Public License for more details.                          *
 ;; *                                                                        *
 ;; *  You should have received a copy of the GNU General Public License     *
 ;; *  along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 ;; *                                                                        *
 ;; *************************************************************************/


;*****************************************************************************
;; RS-232 debugger
;*****************************************************************************
dbg_enable:
    push   r0
    mov    r0, 13		; 9600 baud
    int    KBHIT_INT
    pop    r0
    ret
;*****************************************************************************
dbg_putchar:
    push   r2
    push   r0
    and    r0, 0xFF
    mov    r2, r0
    mov    r0, 1      ; write to the UART
    int    UART_INT   ; call UART_INT
    pop    r0
    pop    r2
    ret
;*****************************************************************************
dbg_getchar:
    xor    r0, r0     ;R0 = read data from the keyboard
    int    UART_INT   ;call UART_INT
    ret    	      ;return character in R0
;*****************************************************************************
dbg_dump_tx_buffer:
    int    PUSHALL_INT
    call   print_newline
    mov    r0, 0x0054		; 'T'
    call   dbg_putchar
    mov    r0, 0x0058		; 'X'
    call   dbg_putchar
    call   print_newline
    mov    r8, send_buffer	; address of buffer
    mov    r9, 64		; number of bytes to print
    call   dbg_dump_buffer
    int    POPALL_INT
    ret
;*****************************************************************************
dbg_dump_rx_buffer:
    int    PUSHALL_INT
    call   print_newline
    mov    r0, 0x0052		; 'R'
    call   dbg_putchar
    mov    r0, 0x0058		; 'X'
    call   dbg_putchar
    call   print_newline
    mov    r8, receive_buffer	; address of buffer
    mov    r9, 64		; number of bytes to print
    call   dbg_dump_buffer
    int    POPALL_INT
    ret
;*****************************************************************************
dbg_dump_buffer:
    xor    r3, r3
print_byte:
    xor    r1, r1
    addi   r3, 1
    mov    r1, b[r8] 		; get byte from buffer
    call   print_hex_byte	; print byte as hex
    addi   r8, 1
    mov    r0, 0x0020
    call   dbg_putchar 		; print space between byte values:
    mov    r4, r3
    and    r4, 0x0F		; every 16 bytes
    jnz    @f
    call   print_newline 	; print possible EOL
@@:
    dec    r9
    jnz    print_byte
    ret
;*****************************************************************************
print_hex_byte:			; in r1
    and    r1, 0xFF
    mov    r0, r1
    shr    r0, 4
    call   print_hex_digit 	; print upper nibble:
    mov    r0, r1
    call   print_hex_digit	; print lower nibble:
    ret
print_hex_digit:
    and    r0, 0x000F
    cmp    r0, 0x0009
    jbe    @f
    add    r0, 0x07
@@:
    add    r0, 0x30
    call   dbg_putchar
    ret
;*****************************************************************************
print_newline:
    push   r0
    mov    r0, 0x0D
    call   dbg_putchar
    mov    r0, 0x0A
    call   dbg_putchar
    pop    r0
    ret
;*****************************************************************************
;; Title char in Debug_Title; Word in {Debug_UW, Debug_LW}
Debug_Title	dw	0x0000
Debug_LW	dw	0x0000
Debug_UW	dw	0x0000
;*****************************************************************************
dbg_print_32bit:
    int    PUSHALL_INT
    mov	   r0, w[Debug_Title]
    call   dbg_putchar
    call   print_newline
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[Debug_UW]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[Debug_UW]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[Debug_LW]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[Debug_LW]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT
    ret
;*****************************************************************************
