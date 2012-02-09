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
;; Actual index of LBA block to read/write
;*****************************************************************************
actual_lba_lw			dw 0x0000
actual_lba_uw			dw 0x0000
;*****************************************************************************

;*****************************************************************************
;; Load LBA block
;*****************************************************************************
load_lba_block:
    ;; block 0
    cmp    w[actual_lba_lw], 0x0000
    jne    @f
    cmp    w[actual_lba_uw], 0x0000
    jne    @f
    mov    r8, block_0
    jmp    load_block
@@:
    ;; block 10
    cmp    w[actual_lba_lw], 10
    jne    @f
    cmp    w[actual_lba_uw], 0x0000
    jne    @f
    mov    r8, block_10
    jmp    load_block
@@:
    ;; block 63
    cmp    w[actual_lba_lw], 63
    jne    @f
    cmp    w[actual_lba_uw], 0x0000
    jne    @f
    mov    r8, block_63
    jmp    load_block
@@:
    ;; block 64
    cmp    w[actual_lba_lw], 64
    jne    @f
    cmp    w[actual_lba_uw], 0x0000
    jne    @f
    mov    r8, block_64
    jmp    load_block
@@:
    ;; block 192
    cmp    w[actual_lba_lw], 192
    jne    @f
    cmp    w[actual_lba_uw], 0x0000
    jne    @f
    mov    r8, block_192
    jmp    load_block
@@:
    ;; block 320
    cmp    w[actual_lba_lw], 320
    jne    @f
    cmp    w[actual_lba_uw], 0x0000
    jne    @f
    mov    r8, block_320
    jmp    load_block
@@:
    ;; default: zero
    jmp    zero_block
load_block:
    mov    r9, send_buffer
    mov    r1, 0x0100 		; 256 words
    call   mem_move 		; r9 = dest, r8 = src, r1 = word count
    ret
zero_block:
    call   zap_send_buffer
    ret
;*****************************************************************************


;*****************************************************************************
;; Save LBA block
;*****************************************************************************
save_lba_block:
    call   dbg_print_write_block_index
    ;; ...
    ret
;*****************************************************************************


;*****************************************************************************
;; Print current block index:
;*****************************************************************************
dbg_print_read_block_index:
    int    PUSHALL_INT
    mov	   r0, 0x0052		; R
    jmp    @f
dbg_print_write_block_index:
    int    PUSHALL_INT
    mov	   r0, 0x0057		; W
@@:
    call   dbg_putchar
    call   print_newline
    mov	   r0, 0x0042		; B
    call   dbg_putchar   
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    ;; print actual LBA index:
    mov    r1, w[actual_lba_uw]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[actual_lba_uw]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[actual_lba_lw]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[actual_lba_lw]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT
    ret
;*****************************************************************************
