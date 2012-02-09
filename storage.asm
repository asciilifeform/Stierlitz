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
;;;; SCSI
;*****************************************************************************

BLOCKSIZE			equ	512
; MAXBLOCK			equ	8388608 ; 4GB
MAXBLOCK			equ	2097152 ; 1GB


;; SBC2 mandatory SCSI commands
SCSI_CMD_FORMAT_UNIT		equ	0x04
SCSI_CMD_INQUIRY		equ	0x12
SCSI_CMD_MODE_SENSE6            equ     0x1A
SCSI_CMD_P_OR_A_MEDIUM_RMVL	equ	0x1E
SCSI_CMD_READ_6			equ	0x08
SCSI_CMD_READ_10		equ 	0x28
SCSI_CMD_WRITE_6		equ	0x0A
SCSI_CMD_WRITE_10		equ	0x2A
SCSI_CMD_READ_CAPACITY		equ	0x25
SCSI_CMD_REPORT_LUNS		equ	0xA0
SCSI_CMD_REQUEST_SENSE		equ	0x03
SCSI_CMD_SEND_DIAGNOSTIC	equ	0x1D
SCSI_CMD_TEST_UNIT_READY	equ	0x00

;; SBC2 optional SCSI commands
SCSI_CMD_VERIFY_10		equ	0x2F

;; SCSI sense codes
SENSE_WRITE_ERROR_lw		equ	0x0C00  ; 0x030C00
SENSE_WRITE_ERROR_uw		equ	0x0003

SENSE_READ_ERROR_lw		equ	0x1100  ; 0x031100
SENSE_READ_ERROR_uw		equ	0x0003

SENSE_INVALID_CMD_OPCODE_lw	equ	0x2000  ; 0x052000
SENSE_INVALID_CMD_OPCODE_uw	equ	0x0005

SENSE_INVALID_FIELD_IN_CDB_lw	equ	0x2400  ; 0x052400
SENSE_INVALID_FIELD_IN_CDB_uw	equ	0x0005


;; /* SCSI Commands */
;;  SCSI_TEST_UNIT_READY            0x00
;;  SCSI_REQUEST_SENSE              0x03
;;  SCSI_FORMAT_UNIT                0x04
;;  SCSI_INQUIRY                    0x12
;;  SCSI_MODE_SELECT6               0x15
;;  SCSI_MODE_SENSE6                0x1A
;;  SCSI_START_STOP_UNIT            0x1B
;;  SCSI_MEDIA_REMOVAL              0x1E
;;  SCSI_READ_FORMAT_CAPACITIES     0x23
;;  SCSI_READ_CAPACITY              0x25
;;  SCSI_READ10                     0x28
;;  SCSI_WRITE10                    0x2A
;;  SCSI_VERIFY10                   0x2F
;;  SCSI_MODE_SELECT10              0x55
;;  SCSI_MODE_SENSE10               0x5A
;*****************************************************************************

;*****************************************************************************
;;;; MSC
;*****************************************************************************
;; MSC Request Codes
MSC_REQUEST_RESET               equ	0xFF
MSC_REQUEST_GET_MAX_LUN         equ	0xFE

;; CSW Status Definitions
CSW_CMD_PASSED                  equ	0x00  ;; Successful transfer
CSW_CMD_FAILED                  equ	0x01  ;; Failed transfer
CSW_PHASE_ERROR                 equ	0x02  ;; Conflict b/w host and device

;; MSC signatures
CBW_Signature_lw_expected	equ	0x5355
CBW_Signature_uw_expected      	equ	0x4342

CSW_Signature_lw_expected      	equ	0x5355
CSW_Signature_uw_expected      	equ	0x5342

;;  MSC Bulk-only Stage
MSC_BS_CBW                      equ	0 	;; Command Block Wrapper
MSC_BS_DATA_OUT                 equ	1       ;; Data Out Phase
MSC_BS_DATA_IN                  equ	2       ;; Data In Phase
MSC_BS_DATA_IN_LAST             equ	3       ;; Data In Last Phase
MSC_BS_DATA_IN_LAST_STALL       equ	4       ;; Data In Last Phase with Stall
MSC_BS_CSW                      equ	5       ;; Command Status Wrapper
MSC_BS_ERROR                    equ	6       ;; Error

;*****************************************************************************

