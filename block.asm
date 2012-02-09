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
;; Load LBA block
;*****************************************************************************
blocks_offset_lw		dw 0x0000
blocks_offset_uw		dw 0x0000

actual_lba_lw			dw 0x0000
actual_lba_uw			dw 0x0000


ActualLBA_0			EQU	(actual_lba_lw)
ActualLBA_1			EQU	(actual_lba_lw + 1)
ActualLBA_2			EQU	(actual_lba_uw)
ActualLBA_3			EQU	(actual_lba_uw + 1)

;*****************************************************************************
load_lba_block:
    mov    b[ActualLBA_0], b[Read10_SCSI_CDB_LBA_0]
    mov    b[ActualLBA_1], b[Read10_SCSI_CDB_LBA_1]
    mov    b[ActualLBA_2], b[Read10_SCSI_CDB_LBA_2]
    mov    b[ActualLBA_3], b[Read10_SCSI_CDB_LBA_3]

    call   compute_actual_block_index
    
    ;; correction done.

    ;; print corrected:
    ;; int    PUSHALL_INT
    ;; call   print_newline
    ;; mov	   r0, 0x005A		; Z
    ;; call   dbg_putchar
    ;; mov	   r0, 0x0052		; R
    ;; call   dbg_putchar   
    ;; mov	   r0, 0x003D		; =
    ;; call   dbg_putchar
    ;; mov    r1, b[ActualLBA_3]
    ;; and    r1, 0xFF
    ;; call   print_hex_byte
    ;; mov    r1, b[ActualLBA_2]
    ;; and    r1, 0xFF
    ;; call   print_hex_byte
    ;; mov    r1, b[ActualLBA_1]
    ;; and    r1, 0xFF
    ;; call   print_hex_byte
    ;; mov    r1, b[ActualLBA_0]
    ;; and    r1, 0xFF
    ;; call   print_hex_byte
    ;; call   print_newline
    ;; int    POPALL_INT
    
    ;; We have blocks: 0, 10, 63, 64, 192, 320

    ;; 320 == 0x0140
    
    ;; Upper two LBA address bytes must be zero
    cmp	   b[ActualLBA_3], 0x00
    jne    zero_block
    cmp	   b[ActualLBA_2], 0x00
    jne    zero_block

    cmp	   b[ActualLBA_1], 0x00
    je     @f
    cmp	   b[ActualLBA_1], 0x01
    jne    @f
    cmp	   b[ActualLBA_0], 0x40
    jne    zero_block
    ;; block 320;
    mov    r8, block_320
    jmp    load_block
@@:
    cmp	   b[ActualLBA_0], 0
    jne    @f
    mov    r8, block_0
    jmp    load_block
@@:
    cmp	   b[ActualLBA_0], 10
    jne    @f
    mov    r8, block_10
    jmp    load_block
@@:
    cmp	   b[ActualLBA_0], 63
    jne    @f
    mov    r8, block_63
    jmp    load_block
@@:
    cmp	   b[ActualLBA_0], 64
    jne    @f
    mov    r8, block_64
    jmp    load_block
@@:
    cmp	   b[ActualLBA_0], 192
    jne    zero_block
    mov    r8, block_192
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
    ;; debug only right now:
    int    PUSHALL_INT
    call   print_newline
    mov	   r0, 0x004C		; L
    call   dbg_putchar
    mov	   r0, 0x0057		; W
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, b[Write10_SCSI_CDB_LBA_3]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Write10_SCSI_CDB_LBA_2]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Write10_SCSI_CDB_LBA_1]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Write10_SCSI_CDB_LBA_0]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT
    ret
;*****************************************************************************


;*****************************************************************************
;; Correct LBA block index for offset
;*****************************************************************************
compute_actual_block_index:
    ;; find out if offset extends one or more block forward:
    mov    r1, w[dwOffset_uw]
    shl    r1, 8
    and    r1, 0xFF00
    mov    r0, r1  ;; upper byte of r0 == lower byte of uw
    mov    r1, w[dwOffset_lw]
    clc
    shr    r1, 8
    and    r1, 0x00FF
    or     r0, r1 ;; r0 == {low{uw}, high{lw}}
    xor    r4, r4
    mov    r1, w[dwOffset_uw]
    clc
    shr    r1, 8
    test   r1, 1
    jz     @f
    addi   r4, 1 ; bit 0 of uw
@@:
    clc
    shr    r0, 1
    and    r4, r4
    jz     @f
    or     r0, 0x0080 ; set bit 7 of result to equal low bit of uw
@@:
    clc
    shr    r1, 1 ;; now {r1:r0} = {dwOffset_uw:dwOffset_lw} / 512
    mov    w[blocks_offset_lw], r0
    mov    w[blocks_offset_uw], r1
    ;; skip block correction if correction factor is zero:
    and    r0, r0
    jnz    @f
    and    r1, r1
    jnz    @f
    jmp    no_block_correction ;; no need to correct for offset
@@:
    ;; need to correct for offset:
    ;; load original LBA:
    mov    r4, b[Read10_SCSI_CDB_LBA_3]
    shl    r4, 8
    or     r4, b[Read10_SCSI_CDB_LBA_2] ;; r4 = old lba high word
    mov    r3, b[Read10_SCSI_CDB_LBA_1]
    shl    r3, 8
    or     r3, b[Read10_SCSI_CDB_LBA_0] ;; r3 = old lba low word
    ;; add correction factor:
    clc
    add    r3, w[blocks_offset_lw] ; add lw of corrector to low word of LBA
    addc   r4, w[blocks_offset_uw] ; add possible carry to high word of LBA

    ;; write actual LBA to access:
    ;; mov    w[actual_lba_lw], r3
    ;; mov    w[actual_lba_uw], r4
    
    ;; write low word of corrected LBA back:
    mov    r5, r3
    and    r5, 0x00FF
    mov    b[ActualLBA_0], r5
    mov    r5, r3
    clc
    shr    r5, 8
    and    r5, 0x00FF
    mov    b[ActualLBA_1], r5
    ;; write high word of corrected LBA back:
    mov    r5, r4
    and    r5, 0x00FF
    mov    b[ActualLBA_3], r5
    mov    r5, r4
    clc
    shr    r5, 8
    and    r5, 0x00FF
    mov    b[ActualLBA_2], r5
no_block_correction:
    ret
;*****************************************************************************
