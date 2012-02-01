;*****************************************************************************
;; RS-232 debugger
;*****************************************************************************
dbg_enable:
    mov    r0, 13		; 9600 baud
    int    KBHIT_INT
    ret
;*****************************************************************************
dbg_putchar:
    push   r2
    mov    r2, r0
    mov    r0, 1      ; write to the UART
    int    UART_INT   ; call UART_INT
    pop    r2
    ret
;*****************************************************************************
dbg_getchar:
    xor    r0, r0     ;R0 = read data from the keyboard
    int    UART_INT   ;call UART_INT
    ret    	      ;return character in R0
;*****************************************************************************
dbg_dump_tx_buffer:
    call   print_newline
    mov    r0, 0x54		; 'T'
    call   dbg_putchar
    mov    r0, 0x58		; 'X'
    call   dbg_putchar
    call   print_newline
    mov    r8, send_buffer	; address of buffer
    mov    r9, 64		; number of bytes to print
    call   dbg_dump_buffer
    ret
;*****************************************************************************
dbg_dump_rx_buffer:
    call   print_newline
    mov    r0, 0x52		; 'R'
    call   dbg_putchar
    mov    r0, 0x58		; 'X'
    call   dbg_putchar
    call   print_newline
    mov    r8, receive_buffer	; address of buffer
    mov    r9, 64		; number of bytes to print
    call   dbg_dump_buffer
    ret
;*****************************************************************************
dbg_dump_buffer:
    xor    r3, r3
print_byte:
    addi   r3, 1
    mov    r1, [r8++] 		; get byte from buffer
    call   print_hex_byte	; print byte as hex
    mov    r0, 0x20
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
    mov    r0, r1
    shr    r0, 4
    call   print_hex_digit 	; print upper nibble:
    mov    r0, r1
    call   print_hex_digit	; print lower nibble:
    ret
print_hex_digit:
    and    r0, 0x0F
    cmp    r0, 0x09
    jbe    @f
    add    r0, 0x11
@@:
    add    r0, 0x30
    call   dbg_putchar
    ret
;*****************************************************************************
print_newline:
    mov    r0, 0x0D
    call   dbg_putchar
    mov    r0, 0x0A
    call   dbg_putchar
    ret
;*****************************************************************************