;*****************************************************************************
;; The Payload (File)
;*****************************************************************************
FILE_SIZE_LW		equ	0x0000
FILE_SIZE_UW		equ	0x0010

;; QTASM is Retarded...:
FILE_SIZE_IN_BLKS_LW	equ	0x0800
FILE_SIZE_IN_BLKS_UW	equ	0x0000

FAKE_FILE_CLUSTERS	equ	32 ; 1 meg
;*****************************************************************************


;*****************************************************************************
;; Derived partition constants
;*****************************************************************************
MBR_BLOCK_LBA_UW			equ     0x0000
MBR_BLOCK_LBA_LW			equ     0x0000
FAT16_BOOT_BLOCK_LBA_UW			equ	PART0_START_LBA_UW
FAT16_BOOT_BLOCK_LBA_LW			equ	PART0_START_LBA_LW
FAT16_FAT_TABLES_BLOCK_LBA_UW		equ	0x0000 ; Forget about upper word... Because QTASM is retarded.
FAT16_FAT_TABLES_BLOCK_LBA_LW		equ	((FAT16_BOOT_BLOCK_LBA_LW) + 1)
FAT16_FAT_TABLES_COPY_BLOCK_LBA_UW	equ     0x0000
FAT16_FAT_TABLES_COPY_BLOCK_LBA_LW	equ     (FAT16_FAT_TABLES_BLOCK_LBA_LW + FAT16_PART0_SECTORS_PER_FAT)
FAT16_ROOT_DIRECTORY_ENTRY_LBA_UW	equ     0x0000
FAT16_ROOT_DIRECTORY_ENTRY_LBA_LW	equ     (FAT16_FAT_TABLES_BLOCK_LBA_LW + ((FAT16_PART0_SECTORS_PER_FAT) * 2))

FAT16_DATA_AREA_LBA_UW			equ	0x0000
FAT16_DATA_AREA_LBA_LW			equ	(FAT16_ROOT_DIRECTORY_ENTRY_LBA_LW + ((FAT16_PART0_MAX_ROOT_DIR_ENTRIES * 32) / BLOCKSIZE))

;; Now, this is because 64 blocks are taken up by Cluster 0 (reserved)
FAT16_DATA_AREA_LBA_UW_EFFECTIVE_BOTTOM	equ	0x0000
FAT16_DATA_AREA_LBA_LW_EFFECTIVE_BOTTOM equ	(FAT16_DATA_AREA_LBA_LW + 64)
;*****************************************************************************


;*****************************************************************************
;; Partition Format
;*****************************************************************************
BOOT_SIGNATURE				equ	0xaa55 ; for both boot block and MBA
;; Partition Record in MBR
PART0_MBR_RECORD_OFFSET			equ     (send_buffer + 0x01BE)
BOOT_SIGNATURE_OFFSET			equ	(send_buffer + 0x01fe)
FAT16_BOOT_BLOCK_FILLER			equ	0xf6f6  ; how MSDOS did it
;*****************************************************************************


;*****************************************************************************
;; Partition Data
;*****************************************************************************
;; Fields:
PART0_STATUS				equ	  0x00 ;  0:  P0 status (0x00 = non-bootable, 0x80 = bootable)
PART0_START_HEAD			equ	  0x01 ;  1: Start CHS: Head
PART0_START_SECT_76CYLHIGH		equ	  0x01 ;  2: Start CHS: Sector in bits 5..0; bits 7..6 are high bits of Cylinder
PART0_START_CYL				equ	  0x00 ;  3: Start CHS: Bits 7..0 of Cylinder
PART0_PARTITION_TYPE			equ	  0x0e ;  4: Partition Type
PART0_END_HEAD				equ	  0x1f ;  5: Ending CHS: Head
PART0_END_SECT_76CYLHIGH		equ	  0xff ;  6: Ending CHS: Sector in bits 5..0; bits 7..6 are high bits of Cylinder
PART0_END_CYL				equ	  0xff ;  7: Ending CHS: Bits 7..0 of Cylinder
PART0_START_LBA_UW			equ	0x0000 ; 11: Starting LBA: Upper Word
PART0_START_LBA_LW			equ	0x003f ;  8: Starting LBA: Lower Word
PART0_SECTORS_UW			equ	0x001f ; 14: Size in sectors
PART0_SECTORS_LW			equ	0xfdc1 ; 12: Size in sectors

;; Our partition parameters
FAT16_PART0_BYTES_PER_SECTOR		equ	0x0200 ; Bytes per sector
FAT16_PART0_SECTORS_PER_CLUSTER		equ	  0x40 ; Sectors per cluster
FAT16_PART0_RESERVED_SECTORS		equ	0x0001 ; Reserved sectors
FAT16_PART0_COPIES_OF_FAT		equ	  0x02 ; # of copies of FAT
FAT16_PART0_MAX_ROOT_DIR_ENTRIES	equ	0x0200 ; Max root dir entries
FAT16_PART0_MAX_SECTS_IF_UNDR_32M	equ	0x0000 ; # of sectors in part < 32MB
FAT16_PART0_MEDIA_DESCRIPTOR		equ	  0xf8 ; media descriptor
FAT16_PART0_SECTORS_PER_FAT		equ	0x0080 ; sectors per FAT
FAT16_PART0_SECTORS_PER_TRACK		equ	0x003f ; sectors per track
FAT16_PART0_HEADS			equ	0x0020 ; # of heads
FAT16_PART0_LOGICAL_DRIVE_NUMBER	equ	0x0080 ; Logical drive number of partition
FAT16_PART0_EXTENDED_SIGNATURE		equ	  0x29 ; Extended signature - must equal 0x29
FAT16_PART0_PARTITION_SERIAL_NUM_UW	equ	0x4f30 ; Serial number of partition (B1)
FAT16_PART0_PARTITION_SERIAL_NUM_LW	equ	0x5f7b ; Serial number of partition (B0)

;*****************************************************************************
