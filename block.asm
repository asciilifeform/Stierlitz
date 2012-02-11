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
;; watch out for carry (unhandled because QTASM is RETARDED ...)
FILE_TOP_LW	equ	(FAT16_DATA_AREA_LBA_LW_EFFECTIVE_BOTTOM + FILE_SIZE_LW)
FILE_TOP_UW	equ	(FAT16_DATA_AREA_LBA_UW_EFFECTIVE_BOTTOM + FILE_SIZE_UW)
;*****************************************************************************
load_lba_block:
    ;; Check for Data Area range:
    ;; check if below:
    cmp    w[actual_lba_uw], 0x0000
    jne    @f ; if upper word of LBA != 0, then definitely NOT below range...
    cmp    w[actual_lba_lw], FAT16_DATA_AREA_LBA_LW_EFFECTIVE_BOTTOM
    jb     not_meat ; below range
@@:
    ;; Forget about checking upper bound, since we have just one file.
    ;; In data range:
    mov    r0, w[actual_lba_lw]
    mov    r3, w[actual_lba_uw]
    mov    r2, FAT16_DATA_AREA_LBA_LW_EFFECTIVE_BOTTOM
    mov    r3, FAT16_DATA_AREA_LBA_UW_EFFECTIVE_BOTTOM
    call   subtract_16 ;; R1:R0 - R3:R2
    ;; WE HAVE A WINNER!
    mov    w[physical_lba_lw], r0
    mov    w[physical_lba_uw], r3
    call   load_physical_lba_block
    ret
not_meat:
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
    ;; Boot Block - start of partition
@@: cmp    w[actual_lba_lw], FAT16_BOOT_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_BOOT_BLOCK_LBA_UW
    jne    @f
    call   build_fat16_boot_block
    ret
    ;; FAT itself.
@@: cmp    w[actual_lba_lw], FAT16_FAT_TABLES_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_FAT_TABLES_BLOCK_LBA_UW
    jne    @f
    call   build_fat16_fat ;; Build FAT
    ret
    ;; Or, Copy of FAT. Keep PC OS from whining...
@@: cmp    w[actual_lba_lw], FAT16_FAT_TABLES_COPY_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_FAT_TABLES_COPY_BLOCK_LBA_UW
    jne    @f
    call   build_fat16_fat ;; Build FAT
    ret
    ;; Root Directory Entries
@@: cmp    w[actual_lba_lw], FAT16_ROOT_DIRECTORY_ENTRY_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_ROOT_DIRECTORY_ENTRY_LBA_UW
    jne    @f
    ;; Build Root Dir
    call   build_fat16_root_dir
    ret
zero_block: ; null
@@: call   zap_send_buffer
    ret
;*****************************************************************************


;*****************************************************************************
;; FAT16 MBR
;*****************************************************************************
align 2
part0_mbr_record_data:
	db	PART0_STATUS
	db	PART0_START_HEAD
	db	PART0_START_SECT_76CYLHIGH
	db	PART0_START_CYL
	db	PART0_PARTITION_TYPE
	db	PART0_END_HEAD
	db	PART0_END_SECT_76CYLHIGH
	db	PART0_END_CYL
	dw	PART0_START_LBA_LW
	dw	PART0_START_LBA_UW
	dw	PART0_SECTORS_LW
	dw	PART0_SECTORS_UW
	PART0_MBR_RECORD_DATA_LEN equ ($-part0_mbr_record_data)
;*****************************************************************************
align 2
build_fat16_mbr:
    call   zap_send_buffer
    mov    r8, part0_mbr_record_data
    mov    r9, PART0_MBR_RECORD_OFFSET
    mov    r1, (PART0_MBR_RECORD_DATA_LEN >> 1) ; word count
    call   mem_move
    mov    w[BOOT_SIGNATURE_OFFSET], BOOT_SIGNATURE
    ret
;*****************************************************************************


;*****************************************************************************
;; FAT16 FAT
;*****************************************************************************
;; ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED
;; ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED
;; ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED
;; ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED

;; FAT16_PART0_SECTORS_PER_CLUSTER == 0x040
;; FAKE_FILE_BYTES		equ	0x100000 ; 1 MB
;; FAT16_CLUSTER_SIZE		equ	(0x040 * BLOCKSIZE)
;; FAKE_FILE_CLUSTERS		equ	(FAKE_FILE_BYTES / FAT16_CLUSTER_SIZE)
;*****************************************************************************
align 2
build_fat16_fat:
    call   zap_send_buffer
    mov    r9, send_buffer
    mov    w[r9++], 0xfff8 ; Partition Type = HDD (0xf8);
    mov    w[r9++], 0xffff ; State = Good (0xff) - TODO: Might need to be writable for mount!
    mov    w[r9++], 0x0000 ; Cluster 0 is reserved, and its address is 2.
    ;; There is exactly one file. Write its clusters:
    mov    r0, 0x0003 ; Number of first cluster of file
@@:
    addi   r0, 1
    mov    [r9++], r0
    cmp    r0, (0x0003 + FAKE_FILE_CLUSTERS - 1)
    jb     @b
    mov    [r9++], 0xFFFF ; Now write the last cluster of file.
    ret
;*****************************************************************************


;*****************************************************************************
;; FAT16 Root Directory
;*****************************************************************************
;; TODO:
;; Looks like Linux actually tries to write access dates here...
;; .................................... but only on unmount.
;*****************************************************************************
align 2
fat16_root_dir_data:
        ;; *****************************************************************
        ;; Volume Label
        ;; *****************************************************************
    	db      'USB        ' ; Volume Label (8 chars body + 3 chars ext)
	db	0x08   ; Attrib = 0x08 (Volume Label)
	dw	0x0000 ; b. 12 - n/a; b. 13 - creation time (10th of secs)
	dw	0x0000 ; 14, 15: creation time (hours, minutes, seconds)
	dw	0x0000 ; creation date
	dw	0x0000 ; access date
	dw	0x0000 ; high word of 1st cluster address
	dw	0xba27 ; modified time (hours, minutes, seconds)
	dw	0x4046 ; modified date
	dw	0x0000 ; low word of 1st cluster address
	dw	0x0000 ; lower word of size (0 for directories)
	dw	0x0000 ; upper word of size (0 for directories)
        ;; *****************************************************************
	;; If we wanted long file name, it would live here...
	;; *****************************************************************
        ;; The File itself
        ;; *****************************************************************
    	db      'STIRLITZBIN' ; Volume Label (8 chars body + 3 chars ext)
	db	0x20   ; Attrib = 0x20 ("Archive")
	dw	0x0000 ; b. 12 - n/a; b. 13 - creation time (10th of secs)
	dw	0x0000 ; 14, 15: creation time (hours, minutes, seconds)
	dw	0x0000 ; creation date
	dw	0x0000 ; access date
	dw	0x0000 ; high word of 1st cluster address
	dw	0xba27 ; modified time (hours, minutes, seconds)
	dw	0x4046 ; modified date
	dw	0x0003 ; low word of 1st cluster address
	dw	FILE_SIZE_LW ; lower word of size (0 for directories)
	dw	FILE_SIZE_UW ; upper word of size (0 for directories)	
        ;; *****************************************************************
	FAT16_ROOT_DIR_DATA_LEN equ ($-fat16_root_dir_data)
;*****************************************************************************
align 2
build_fat16_root_dir:
    call   zap_send_buffer
    mov    r8, fat16_root_dir_data
    mov    r9, send_buffer
    mov    r1, (FAT16_ROOT_DIR_DATA_LEN >> 1) ; word count
    call   mem_move
    ret
;*****************************************************************************


;*****************************************************************************
;; FAT16 Boot Block
;*****************************************************************************
align 2
boot_block_data:
    	db	0xeb ; jmp
	db	0x3c ; jmp
	db	0x90 ; nop
	db      'MSWIN4.0' ; OEM name (8 chars)
	dw      FAT16_PART0_BYTES_PER_SECTOR
	db      FAT16_PART0_SECTORS_PER_CLUSTER
	dw      FAT16_PART0_RESERVED_SECTORS
	db      FAT16_PART0_COPIES_OF_FAT
	dw      FAT16_PART0_MAX_ROOT_DIR_ENTRIES
	dw      FAT16_PART0_MAX_SECTS_IF_UNDR_32M
	db      FAT16_PART0_MEDIA_DESCRIPTOR
	dw      FAT16_PART0_SECTORS_PER_FAT
	dw      FAT16_PART0_SECTORS_PER_TRACK
	dw      FAT16_PART0_HEADS
	dw      PART0_START_LBA_LW ; # of hidden sectors (LW) from MBR
	dw      PART0_START_LBA_UW ; # of hidden sectors (UW) from MBR
	dw      PART0_SECTORS_LW ; # of sectors (LW) from MBR
	dw      PART0_SECTORS_UW ; # of sectors (UW) from MBR
	dw      FAT16_PART0_LOGICAL_DRIVE_NUMBER
	db      FAT16_PART0_EXTENDED_SIGNATURE
	dw      FAT16_PART0_PARTITION_SERIAL_NUM_LW
	dw      FAT16_PART0_PARTITION_SERIAL_NUM_UW
	db	'STIERLITZ  ' ; Volume name of partition (11 chars)
	db      'FAT16   ' ; FAT Name (must equal "FAT16   ")
	BOOT_BLOCK_DATA_LEN equ ($-boot_block_data)
;*****************************************************************************
align 2
build_fat16_boot_block:
    mov    r8, boot_block_data
    mov    r9, send_buffer
    mov    r1, (BOOT_BLOCK_DATA_LEN >> 1) ; word count
    call   mem_move
    ;; fill remainder:
    mov    r9, (send_buffer + BOOT_BLOCK_DATA_LEN) ; redundant?
    mov    r1, (((BLOCKSIZE - BOOT_BLOCK_DATA_LEN) >> 1) - 1)
@@:
    mov    w[r9++], FAT16_BOOT_BLOCK_FILLER
    dec    r1
    jnz    @b
    mov    w[BOOT_SIGNATURE_OFFSET], BOOT_SIGNATURE
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
