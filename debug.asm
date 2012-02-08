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