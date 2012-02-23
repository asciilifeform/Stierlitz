 ;; /*************************************************************************
 ;; *                     This file is part of Stierlitz:                    *
 ;; *               https://github.com/asciilifeform/Stierlitz               *
 ;; *************************************************************************/

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
;; Test if LBA block is within the given range.
;; block is in actual_lba; range is r3:r2 to r4:r5.
;; results: r2 is true or false.
;;          r1:r0 is index into range (0...N)
;*****************************************************************************
test_lba_block_in_range:
    mov    r1, w[actual_lba_uw]
    mov    r0, w[actual_lba_lw]
    call   subtract_16 ;; R1:R0 - R3:R2
    jc     out_of_range	; below range?
    ;; r1:r0 is now index into range, save it
    mov    r6, r1
    mov    r7, r0
    mov    r1, w[actual_lba_uw]
    mov    r0, w[actual_lba_lw]
    mov    r3, r4 ; uw of upper bound
    mov    r2, r5 ; lw of upper bound
    call   subtract_16 ;; R1:R0 - R3:R2
    jnc    out_of_range
    ;; is in range:
    mov    r2, 0x0001 ; True
    jmp    blk_range_done
out_of_range:
    mov    r2, 0x0000 ; False
blk_range_done:
    mov    r1, r6
    mov    r0, r7
    ret
;*****************************************************************************


;*****************************************************************************
;; Test if LBA block is within the payload range.
;*****************************************************************************
;; watch out for carry (unhandled because QTASM is RETARDED ...)
;; TODO: there's none right now. but check here again when we up the virtual file size.
FILE_TOP_LW	equ	(FAT16_DATA_AREA_LBA_LW_EFFECTIVE_BOTTOM + FILE_SIZE_IN_BLKS_LW)
FILE_TOP_UW	equ	(FAT16_DATA_AREA_LBA_UW_EFFECTIVE_BOTTOM + FILE_SIZE_IN_BLKS_UW)
;*****************************************************************************
test_lba_block_in_payload_range:
    mov    r3, FAT16_DATA_AREA_LBA_UW_EFFECTIVE_BOTTOM
    mov    r2, FAT16_DATA_AREA_LBA_LW_EFFECTIVE_BOTTOM
    mov    r4, FILE_TOP_UW
    mov    r5, FILE_TOP_LW
    call   test_lba_block_in_range
    test   r2, 1
    jz     @f
    mov    w[physical_lba_uw], r1
    mov    w[physical_lba_lw], r0
@@:
    mov    r0, r2
    ret
;*****************************************************************************


;*****************************************************************************
;; Load LBA block
;*****************************************************************************
load_lba_block:
    call   test_lba_block_in_payload_range
    test   r0, 1
    jz     @f
    call   load_physical_lba_block ; this was a payload block
    ret	; and so we're done here.
@@: ; Or, well, not:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; call   dbg_print_read_block_index
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; What is it then?
    ;; Primary FAT:
    mov    r3, FAT16_FAT_TABLES_BLOCK_LBA_UW
    mov    r2, FAT16_FAT_TABLES_BLOCK_LBA_LW
    mov    r4, FAT16_FAT_TABLES_BLOCK_LBA_UW ; should work, since we are the 1st partition
    mov    r5, (FAT16_FAT_TABLES_BLOCK_LBA_LW + FAT16_PART0_SECTORS_PER_FAT)
    call   test_lba_block_in_range
    test   r2, 1
    jz     @f
    call   build_fat16_fat ;; Build FAT
    ret
@@:
    ;; Secondary FAT:
    mov    r3, FAT16_FAT_TABLES_COPY_BLOCK_LBA_UW
    mov    r2, FAT16_FAT_TABLES_COPY_BLOCK_LBA_LW
    mov    r4, FAT16_FAT_TABLES_COPY_BLOCK_LBA_UW ; should work, since we are the 1st partition
    mov    r5, (FAT16_FAT_TABLES_COPY_BLOCK_LBA_LW + FAT16_PART0_SECTORS_PER_FAT)
    call   test_lba_block_in_range
    test   r2, 1
    jz     @f
    call   build_fat16_fat ;; Build FAT
    ret
@@:
    ;; MBR:
    cmp    w[actual_lba_lw], MBR_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], MBR_BLOCK_LBA_UW
    jne    @f
    ;; Build MBR
    call   build_fat16_mbr
    ret
    ;; Boot Block - start of partition:
@@: cmp    w[actual_lba_lw], FAT16_BOOT_BLOCK_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_BOOT_BLOCK_LBA_UW
    jne    @f
    call   build_fat16_boot_block
    ret
    ;; Root Directory Entries:
@@: cmp    w[actual_lba_lw], FAT16_ROOT_DIRECTORY_ENTRY_LBA_LW
    jne    @f
    cmp    w[actual_lba_uw], FAT16_ROOT_DIRECTORY_ENTRY_LBA_UW
    jne    @f
    ;; Build Root Dir
    call   build_fat16_root_dir
    ret
zero_block: ; default - null block:
@@: call   zap_send_buffer
    ret
;*****************************************************************************


;*****************************************************************************
;; Save LBA block
;*****************************************************************************
save_lba_block:
    call   test_lba_block_in_payload_range
    test   r0, 1
    jz     @f
    ;; this was a payload block:
    call   save_physical_lba_block
    ret	; and so we're done here.
@@: ;; don't do anything for non-payload blocks...
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
;*****************************************************************************
;; FAT16_PART0_SECTORS_PER_CLUSTER == 0x040
;; FAKE_FILE_BYTES		equ	0x100000 ; 1 MB
;; FAT16_CLUSTER_SIZE		equ	(0x040 * BLOCKSIZE)
;; FAKE_FILE_CLUSTERS		equ	(FAKE_FILE_BYTES / FAT16_CLUSTER_SIZE)
;*****************************************************************************
;; ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED ! QTASM IS RETARDED
;*****************************************************************************

align 2
build_fat16_fat:
    ;; r0 contains index of FAT page to load (0...FF)
    mov    r9, send_buffer
    and    r0, r0
    jnz    @f
    ;; If we were asked for the first page of the FAT:
    mov    w[r9++], 0xfff8 ; Partition Type = HDD (0xf8);
    mov    w[r9++], 0xffff ; State = Good (0xff) - TODO: Might need to be writable for mount! <---- Should we make this dirty?
    mov    w[r9++], 0x0000 ; Cluster 0 is reserved, and its address is 2.
    mov    r0, FIRST_CLUSTER_INDEX ; Number of first cluster of file
    jmp    build_fat
@@: ;; Not the first page:
    mov    r1, r0
    xor    r0, r0
@@:
    add    r0, 0x0100
    subi   r1, 1
    jnz    @b
    ;; if we're past the last page?
    cmp    r0, FAKE_FILE_CLUSTERS
    jbe    @f
    call   zap_send_buffer
    jmp    fat_build_done
@@: ;; now, r0 is either 3 (page 0) or 0xFF * page-index.
    addi   r0, 1
build_fat:
@@:
    ;; block full?
    cmp    r9, (send_buffer + BLOCKSIZE) ; stop if the block is full
    je     fat_build_done
    ;; There is room:
    cmp    r0, (FIRST_CLUSTER_INDEX + FAKE_FILE_CLUSTERS - 1)
    je     penult_cluster ; this was the penultimate cluster
    mov    w[r9++], r0
    addi   r0, 1
    jmp    @b ; keep adding cluster records.
penult_cluster:
    mov    w[r9++], 0xFFFF ; Now write the last cluster of file.
    xor    r0, r0
@@:
    cmp    r9, (send_buffer + BLOCKSIZE) ; stop if the block is full
    je     fat_build_done
    mov    w[r9++], r0
    jmp    @b
fat_build_done:
    ret
;*****************************************************************************


;*****************************************************************************
;; FAT16 Root Directory
;*****************************************************************************
;; Note: Linux actually tries to write access dates here, upon sync.
;; But we don't care. There is no good reason to waste EEPROM write cycles
;; only to store such garbage. The FAT16 bookkeeping will be kept constant.
;*****************************************************************************
align 2
fat16_root_dir_data:
        ;; *****************************************************************
        ;; Volume Label
        ;; *****************************************************************
	db      'STIRLITZ   ' ; Volume Label (8 chars body + 3 chars ext)
	db	0x08   ; Attrib = 0x08 (Volume Label)
	dw	0x0000 ; b. 12 - n/a; b. 13 - creation time (10th of secs)
	dw	0x0000 ; 14, 15: creation time (hours, minutes, seconds)
	dw	0x0000 ; creation date
	dw	0x0000 ; access date
	dw	0x0000 ; high word of 1st cluster address
	dw	0x0000 ; modified time (hours, minutes, seconds)
	dw	0x0000 ; modified date
	dw	0x0000 ; low word of 1st cluster address
	dw	0x0000 ; lower word of size (0 for directories)
	dw	0x0000 ; upper word of size (0 for directories)
        ;; *****************************************************************
	;; If we wanted long file name, it would live here...
	;; *****************************************************************
        ;; The File itself
        ;; *****************************************************************
    	db      'LOPERIMGBIN' ; Volume Label (8 chars body + 3 chars ext)
	db	0x20   ; Attrib = 0x20 ("Archive")
	dw	0x0000 ; b. 12 - n/a; b. 13 - creation time (10th of secs)
	dw	0x0000 ; 14, 15: creation time (hours, minutes, seconds)
	dw	0x0000 ; creation date
	dw	0x0000 ; access date
	dw	0x0000 ; high word of 1st cluster address
	dw	0x0000 ; modified time (hours, minutes, seconds)
	dw	0x0000 ; modified date
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
