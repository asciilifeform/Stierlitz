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
    ;; Check for Data Area range:

    ;; ...

    ;; else:
    ;; MBR?
    cmp    w[actual_lba_lw], MBR_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], MBR_BLOCK_LBA_UW
    jne    @f
    ;; Build MBR
    call   build_fat16_mbr
    ret
@@:
    ;; Boot Block - start of partition
    cmp    w[actual_lba_lw], FAT16_BOOT_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_BOOT_BLOCK_LBA_UW
    jne    @f
    call   build_fat16_boot_block
    ret
@@: ;; FAT itself.
    cmp    w[actual_lba_lw], FAT16_FAT_TABLES_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_FAT_TABLES_BLOCK_LBA_UW
    jne    @f
    ;; Or, Copy of FAT. Keep PC OS from whining...
    cmp    w[actual_lba_lw], FAT16_FAT_TABLES_COPY_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_FAT_TABLES_COPY_BLOCK_LBA_UW
    jne    @f
    ;; Build FAT
    call   build_fat16_fat
    ret
@@:
    ;; Root Directory Entries
    cmp    w[actual_lba_lw], FAT16_ROOT_DIRECTORY_ENTRY_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_ROOT_DIRECTORY_ENTRY_LBA_UW
    jne    @f
    ;; Build Root Dir
    call   build_fat16_root_dir
    ret
@@:
zero_block: ; null
    call   zap_send_buffer
    ret
;*****************************************************************************


;*****************************************************************************
;; FAT16 Parts
;*****************************************************************************
build_fat16_mbr:
    call   zap_send_buffer
    mov    b[PART0_STATUS_OFFSET], PART0_STATUS
    mov    b[PART0_START_HEAD_OFFSET], PART0_START_HEAD
    mov    b[PART0_START_SECT_76CYLHIGH_OFFSET], PART0_START_SECT_76CYLHIGH
    mov    b[PART0_START_CYL_OFFSET], PART0_START_CYL
    mov    b[PART0_PARTITION_TYPE_OFFSET], PART0_PARTITION_TYPE
    mov    b[PART0_END_HEAD_OFFSET], PART0_END_HEAD
    mov    b[PART0_END_SECT_76CYLHIGH_OFFSET], PART0_END_SECT_76CYLHIGH
    mov    b[PART0_END_CYL_OFFSET], PART0_END_CYL
    mov    w[PART0_START_LBA_UW_OFFSET], PART0_START_LBA_UW
    mov    w[PART0_START_LBA_LW_OFFSET], PART0_START_LBA_LW
    mov    w[PART0_SECTORS_UW_OFFSET], PART0_SECTORS_UW
    mov    w[PART0_SECTORS_LW_OFFSET], PART0_SECTORS_LW
    mov    w[BOOT_SIGNATURE_OFFSET], BOOT_SIGNATURE
    ret
;*****************************************************************************
build_fat16_fat:
    call   zap_send_buffer
    mov    w[send_buffer], 0xfff8
    mov    w[(send_buffer + 2)], 0xffff
    ret
;*****************************************************************************
build_fat16_root_dir:
    call   zap_send_buffer
    mov    w[send_buffer], 0x5355
    mov    w[(send_buffer + 2)], 0x2042
    mov    w[(send_buffer + 4)], 0x2020
    mov    w[(send_buffer + 6)], 0x2020
    mov    w[(send_buffer + 8)], 0x2020
    mov    w[(send_buffer + 10)], 0x0820
    mov    w[(send_buffer + 22)], 0xba27
    mov    w[(send_buffer + 24)], 0x4046
    ret
;*****************************************************************************
build_fat16_boot_block:
    mov    r8, boot_block
    mov    r9, send_buffer
    mov    r1, 0x0100 		; 256 words
    call   mem_move 		; r9 = dest, r8 = src, r1 = word count
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
