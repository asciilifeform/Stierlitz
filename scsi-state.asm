;*****************************************************************************
;; SCSI State
;*****************************************************************************
;; sense key
SCSI_dw_sense:
SCSI_dw_sense_lw		dw 0x0000
SCSI_dw_sense_uw		dw 0x0000

;; hex: 00aabbcc, where aa=KEY, bb=ASC, cc=ASCQ
dwSense_KEY			EQU	(SCSI_dw_sense + 1)
dwSense_ASC			EQU	(SCSI_dw_sense + 2)
dwSense_ASCQ			EQU	(SCSI_dw_sense + 3)

;; state machine state
scsi_state:
    db				0x00
;; Possible states:
SCSI_state_CBW		EQU	0x00
SCSI_state_data_out	EQU	0x01
SCSI_state_data_in	EQU	0x02
SCSI_state_CSW		EQU	0x03
SCSI_state_stalled	EQU	0x04
;*****************************************************************************

;*****************************************************************************
;; SCSI Command Block Wrapper (received)
;*****************************************************************************
CBW_Size			EQU	0x1F
MSC_CBW_Signature_lw		EQU	(receive_buffer)
MSC_CBW_Signature_uw		EQU	(receive_buffer + 2)
CBW_tag_lw			EQU	(receive_buffer + 4)
CBW_tag_uw			EQU	(receive_buffer + 6)
CBW_data_transfer_length_lw	EQU	(receive_buffer + 8)
CBW_data_transfer_length_uw	EQU	(receive_buffer + 10)
CBW_flags			EQU	(receive_buffer + 12)
CBW_lun				EQU	(receive_buffer + 13)
CBW_cb_length			EQU	(receive_buffer + 14)
CBW_cb				EQU	(receive_buffer + 15)
;*****************************************************************************

;*****************************************************************************
;; All SCSI Command CDBs
;*****************************************************************************
Common_SCSI_CDB_op_code		EQU	(CBW_cb)
;*****************************************************************************

;*****************************************************************************
;; 'Inquiry' SCSI Command
;*****************************************************************************
Inquiry_SCSI_CDB_bLength	EQU	(CBW_cb + 4)
;*****************************************************************************

;*****************************************************************************
;; 'Request Sense' SCSI Command
;*****************************************************************************
Request_Sense_SCSI_CDB_bLength	EQU	(CBW_cb + 4)
;*****************************************************************************

;*****************************************************************************
;; 'Read-10' SCSI Command
;*****************************************************************************
Read10_SCSI_CDB_LUN_etc		EQU	(CBW_cb + 1)
Read10_SCSI_CDB_LBA_3		EQU	(CBW_cb + 2)
Read10_SCSI_CDB_LBA_2		EQU	(CBW_cb + 3)
Read10_SCSI_CDB_LBA_1		EQU	(CBW_cb + 4)
Read10_SCSI_CDB_LBA_0		EQU	(CBW_cb + 5)
Read10_SCSI_CDB_Transfer_Len_1	EQU	(CBW_cb + 7)
Read10_SCSI_CDB_Transfer_Len_0	EQU	(CBW_cb + 8)
;*****************************************************************************

;*****************************************************************************
;; 'Write-10' SCSI Command
;*****************************************************************************
Write10_SCSI_CDB_LUN_etc	EQU	(CBW_cb + 1)
Write10_SCSI_CDB_LBA_3		EQU	(CBW_cb + 2)
Write10_SCSI_CDB_LBA_2		EQU	(CBW_cb + 3)
Write10_SCSI_CDB_LBA_1		EQU	(CBW_cb + 4)
Write10_SCSI_CDB_LBA_0		EQU	(CBW_cb + 5)
Write10_SCSI_CDB_Transfer_Len_1	EQU	(CBW_cb + 7)
Write10_SCSI_CDB_Transfer_Len_0	EQU	(CBW_cb + 8)
;*****************************************************************************

;*****************************************************************************
;; SCSI Command Status Wrapper (to send to host)
;*****************************************************************************
CSW_Size			EQU	13
MSC_CSW_Signature_lw		EQU	(send_buffer)
MSC_CSW_Signature_uw		EQU	(send_buffer + 2)
CSW_tag_lw			EQU	(send_buffer + 4)
CSW_tag_uw			EQU	(send_buffer + 6)
CSW_data_residue_lw		EQU	(send_buffer + 8)
CSW_data_residue_uw		EQU	(send_buffer + 10)
CSW_status			EQU	(send_buffer + 12)
;*****************************************************************************

;*****************************************************************************
;; Inquiry Response
;*****************************************************************************
align 2
SCSI_inquiry_response:
    db		0x00		; Device = Direct Access
    db		0x80		; RMB = 1: Removable Medium
    db		0x00		; Standard Version = None
    db		0x01		; Data Format = unknown
    db		(INQ_ADD_LEN-4)	; Additional Length
    db		0x00		; Flags: nothing special
    db		0x00		; Flags: normal device, no extra features
    db		0x00		; Flags: no rel. addressing, sync. xmit, linked commands, or queuing
    db          'Loper OS'	; Manufacturer ID (bytes 8..15)
    db		'Bus to Thumb Drv' ; Product ID (bytes 16..31)
    db		'1.00'		; Product Revision Level (Bytes 32..35)
    INQ_ADD_LEN equ ($-SCSI_inquiry_response)
;*****************************************************************************
