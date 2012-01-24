;*****************************************************************************
;;;; SCSI
;*****************************************************************************

BLOCKSIZE			equ	512

;; SBC2 mandatory SCSI commands
SCSI_CMD_TEST_UNIT_READY	equ	0x00
SCSI_CMD_REQUEST_SENSE		equ	0x03
SCSI_CMD_FORMAT_UNIT		equ	0x04
SCSI_CMD_READ_6			equ	0x08
SCSI_CMD_INQUIRY		equ	0x12
SCSI_CMD_SEND_DIAGNOSTIC	equ	0x1D
SCSI_CMD_READ_CAPACITY		equ	0x25
SCSI_CMD_READ_10		equ 	0x28
SCSI_CMD_REPORT_LUNS		equ	0xA0

;; SBC2 optional SCSI commands
SCSI_CMD_WRITE_6		equ	0x0A
SCSI_CMD_WRITE_10		equ	0x2A
SCSI_CMD_VERIFY_10		equ	0x2F

;; SCSI sense codes
SENSE_WRITE_ERROR		equ	0x030C00
SENSE_READ_ERROR		equ	0x031100
SENSE_INVALID_CMD_OPCODE	equ	0x052000
SENSE_INVALID_FIELD_IN_CDB	equ	0x052400

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
MSC_CBW_Signature_lw            equ	0x5355
MSC_CBW_Signature_uw            equ	0x4342

MSC_CSW_Signature_lw            equ	0x5355
MSC_CSW_Signature_uw            equ	0x5342

;;  MSC Bulk-only Stage
MSC_BS_CBW                      equ	0 	;; Command Block Wrapper
MSC_BS_DATA_OUT                 equ	1       ;; Data Out Phase
MSC_BS_DATA_IN                  equ	2       ;; Data In Phase
MSC_BS_DATA_IN_LAST             equ	3       ;; Data In Last Phase
MSC_BS_DATA_IN_LAST_STALL       equ	4       ;; Data In Last Phase with Stall
MSC_BS_CSW                      equ	5       ;; Command Status Wrapper
MSC_BS_ERROR                    equ	6       ;; Error

;*****************************************************************************

;; /* Bulk-only Command Block Wrapper */
;; typedef __packed struct _MSC_CBW {
;;   DWORD dSignature;
;;   DWORD dTag;
;;   DWORD dDataLength;
;;   BYTE  bmFlags;
;;   BYTE  bLUN;
;;   BYTE  bCBLength;
;;   BYTE  CB[16];
;; } MSC_CBW;

;; /* Bulk-only Command Status Wrapper */
;; typedef __packed struct _MSC_CSW {
;;   DWORD dSignature;
;;   DWORD dTag;
;;   DWORD dDataResidue;
;;   BYTE  bStatus;
;; } MSC_CSW;



;; //	Sense code, which is set on error conditions
;; static U32			dwSense;	// hex: 00aabbcc, where aa=KEY, bb=ASC, cc=ASCQ

;; static const U8		abInquiry[] = {
;; 	0x00,		// PDT = direct-access device
;; 	0x80,		// removeable medium bit = set
;; 	0x05,		// version = complies to SPC3
;; 	0x02,		// response data format = SPC3
;; 	0x1F,		// additional length
;; 	0x00,
;; 	0x00,
;; 	0x00,
;; 	'L','P','C','U','S','B',' ',' ',	// vendor
;; 	'M','a','s','s',' ','s','t','o',	// product
;; 	'r','a','g','e',' ',' ',' ',' ',
;; 	'0','.','1',' '						// revision
;; };

;; //	Data for "request sense" command. The 0xFF are filled in later
;; static const U8 abSense[] = { 0x70, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x0A, 
;; 							  0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00,
;; 							  0x00, 0x00 };

;; //	Buffer for holding one block of disk data
;; static U8 abBlockBuf[512];


;; typedef struct {
;; 	U8		bOperationCode;
;; 	U8		abLBA[3];
;; 	U8		bLength;
;; 	U8		bControl;
;; } TCDB6;


;; /*************************************************************************
;; 	SCSIReset
;; 	=========
;; 		Resets any SCSI state
		
;; **************************************************************************/
;; void SCSIReset(void)
;; {
;; 	dwSense = 0;
;; }


;; /*************************************************************************
;; 	SCSIHandleCmd
;; 	=============
;; 		Verifies a SCSI CDB and indicates the direction and amount of data
;; 		that the device wants to transfer.
		
;; 	If this call fails, a sense code is set in dwSense.

;; 	IN		pbCDB		Command data block
;; 			iCDBLen		Command data block len
;; 	OUT		*piRspLen	Length of intended response data:
;; 			*pfDevIn	TRUE if data is transferred from device-to-host
	
;; 	Returns a pointer to the data exchange buffer if successful,
;; 	return NULL otherwise.
;; **************************************************************************/
;; U8 * SCSIHandleCmd(U8 *pbCDB, U8 iCDBLen, int *piRspLen, BOOL *pfDevIn)
;; {
;; 	static const U8 aiCDBLen[] = {6, 10, 10, 0, 16, 12, 0, 0};
;; 	int		i;
;; 	TCDB6	*pCDB;
;; 	U32		dwLen, dwLBA;
;; 	U8		bGroupCode;
	
;; 	pCDB = (TCDB6 *)pbCDB;
	
;; 	// default direction is from device to host
;; 	*pfDevIn = TRUE;
	
;; 	// check CDB length
;; 	bGroupCode = (pCDB->bOperationCode >> 5) & 0x7;
;; 	if (iCDBLen < aiCDBLen[bGroupCode]) {
;; 		DBG("Invalid CBD len (expected %d)!\n", aiCDBLen[bGroupCode]);
;; 		return NULL;
;; 	}

;; 	switch (pCDB->bOperationCode) {

;; 	// test unit ready (6)
;; 	case SCSI_CMD_TEST_UNIT_READY:
;; 		DBG("TEST UNIT READY\n");
;; 		*piRspLen = 0;
;; 		break;
	
;; 	// request sense (6)
;; 	case SCSI_CMD_REQUEST_SENSE:
;; 		DBG("REQUEST SENSE (%06X)\n", dwSense);
;; 		// check params
;; 		*piRspLen = MIN(18, pCDB->bLength);
;; 		break;
	
;; 	case SCSI_CMD_FORMAT_UNIT:
;; 		DBG("FORMAT UNIT %02X\n", pbCDB[1]);
;; 		*piRspLen = 0;
;; 		break;
	
;; 	// inquiry (6)
;; 	case SCSI_CMD_INQUIRY:
;; 		DBG("INQUIRY\n");
;; 		// see SPC3r23, 4.3.4.6
;; 		*piRspLen = MIN(36, pCDB->bLength);
;; 		break;
		
;; 	// read capacity (10)
;; 	case SCSI_CMD_READ_CAPACITY_10:
;; 		DBG("READ CAPACITY\n");
;; 		*piRspLen = 8;
;; 		break;
		
;; 	// read (10)
;; 	case SCSI_CMD_READ_10:
;; 		dwLBA = (pbCDB[2] << 24) | (pbCDB[3] << 16) | (pbCDB[4] << 8) | (pbCDB[5]);
;; 		dwLen = (pbCDB[7] << 8) | pbCDB[8];
;; 		DBG("READ10, LBA=%d, len=%d\n", dwLBA, dwLen);
;; 		*piRspLen = dwLen * BLOCKSIZE;
;; 		break;

;; 	// write (10)
;; 	case SCSI_CMD_WRITE_10:
;; 		dwLBA = (pbCDB[2] << 24) | (pbCDB[3] << 16) | (pbCDB[4] << 8) | (pbCDB[5]);
;; 		dwLen = (pbCDB[7] << 8) | pbCDB[8];
;; 		DBG("WRITE10, LBA=%d, len=%d\n", dwLBA, dwLen);
;; 		*piRspLen = dwLen * BLOCKSIZE;
;; 		*pfDevIn = FALSE;
;; 		break;

;; 	case SCSI_CMD_VERIFY_10:
;; 		DBG("VERIFY10\n");
;; 		if ((pbCDB[1] & (1 << 1)) != 0) {
;; 			// we don't support BYTCHK
;; 			DBG("BYTCHK not supported\n");
;; 			return NULL;
;; 		}
;; 		*piRspLen = 0;
;; 		break;
	
;; 	default:
;; 		DBG("Unhandled SCSI: ");		
;; 		for (i = 0; i < iCDBLen; i++) {
;; 			DBG(" %02X", pbCDB[i]);
;; 		}
;; 		DBG("\n");
;; 		// unsupported command
;; 		dwSense = INVALID_CMD_OPCODE;
;; 		*piRspLen = 0;
;; 		return NULL;
;; 	}
	
	
;; 	return abBlockBuf;
;; }


;; /*************************************************************************
;; 	SCSIHandleData
;; 	==============
;; 		Handles a block of SCSI data.
		
;; 	IN		pbCDB		Command data block
;; 			iCDBLen		Command data block len
;; 	IN/OUT	pbData		Data buffer
;; 	IN		dwOffset	Offset in data
	
;; 	Returns a pointer to the next data to be exchanged if successful,
;; 	returns NULL otherwise.
;; **************************************************************************/
;; U8 * SCSIHandleData(U8 *pbCDB, U8 iCDBLen, U8 *pbData, U32 dwOffset)
;; {
;; 	TCDB6	*pCDB;
;; 	U32		dwLBA;
;; 	U32		dwBufPos, dwBlockNr;
;; 	U32		dwDevSize, dwMaxBlock;
	
;; 	pCDB = (TCDB6 *)pbCDB;
	
;; 	switch (pCDB->bOperationCode) {

;; 	// test unit ready
;; 	case SCSI_CMD_TEST_UNIT_READY:
;; 		if (dwSense != 0) {
;; 			return NULL;
;; 		}
;; 		break;
	
;; 	// request sense
;; 	case SCSI_CMD_REQUEST_SENSE:
;; 		memcpy(pbData, abSense, 18);
;; 		// fill in KEY/ASC/ASCQ
;; 		pbData[2] = (dwSense >> 16) & 0xFF;
;; 		pbData[12] = (dwSense >> 8) & 0xFF;
;; 		pbData[13] = (dwSense >> 0) & 0xFF;
;; 		// reset sense data
;; 		dwSense = 0;
;; 		break;
	
;; 	case SCSI_CMD_FORMAT_UNIT:
;; 		// nothing to do, ignore this command
;; 		break;
	
;; 	// inquiry
;; 	case SCSI_CMD_INQUIRY:
;; 		memcpy(pbData, abInquiry, sizeof(abInquiry));
;; 		break;
		
;; 	// read capacity
;; 	case SCSI_CMD_READ_CAPACITY_10:
;; 		// get size of drive (bytes)
;; 		BlockDevGetSize(&dwDevSize);
;; 		// calculate highest LBA
;; 		dwMaxBlock = (dwDevSize - 1) / 512;
		
;; 		pbData[0] = (dwMaxBlock >> 24) & 0xFF;
;; 		pbData[1] = (dwMaxBlock >> 16) & 0xFF;
;; 		pbData[2] = (dwMaxBlock >> 8) & 0xFF;
;; 		pbData[3] = (dwMaxBlock >> 0) & 0xFF;
;; 		pbData[4] = (BLOCKSIZE >> 24) & 0xFF;
;; 		pbData[5] = (BLOCKSIZE >> 16) & 0xFF;
;; 		pbData[6] = (BLOCKSIZE >> 8) & 0xFF;
;; 		pbData[7] = (BLOCKSIZE >> 0) & 0xFF;
;; 		break;
		
;; 	// read10
;; 	case SCSI_CMD_READ_10:
;; 		dwLBA = (pbCDB[2] << 24) | (pbCDB[3] << 16) | (pbCDB[4] << 8) | (pbCDB[5]);

;; 		// copy data from block buffer
;; 		dwBufPos = (dwOffset & (BLOCKSIZE - 1));
;; 		if (dwBufPos == 0) {
;; 			// read new block
;; 			dwBlockNr = dwLBA + (dwOffset / BLOCKSIZE);
;; 			DBG("R");
;; 			if (BlockDevRead(dwBlockNr, abBlockBuf) < 0) {
;; 				dwSense = READ_ERROR;
;; 				DBG("BlockDevRead failed\n");
;; 				return NULL;
;; 			}
;; 		}
;; 		// return pointer to data
;; 		return abBlockBuf + dwBufPos;

;; 	// write10
;; 	case SCSI_CMD_WRITE_10:
;; 		dwLBA = (pbCDB[2] << 24) | (pbCDB[3] << 16) | (pbCDB[4] << 8) | (pbCDB[5]);
		
;; 		// copy data to block buffer
;; 		dwBufPos = ((dwOffset + 64) & (BLOCKSIZE - 1));
;; 		if (dwBufPos == 0) {
;; 			// write new block
;; 			dwBlockNr = dwLBA + (dwOffset / BLOCKSIZE);
;; 			DBG("W");
;; 			if (BlockDevWrite(dwBlockNr, abBlockBuf) < 0) {
;; 				dwSense = WRITE_ERROR;
;; 				DBG("BlockDevWrite failed\n");
;; 				return NULL;
;; 			}
;; 		}
;; 		// return pointer to next data
;; 		return abBlockBuf + dwBufPos;
		
;; 	case SCSI_CMD_VERIFY_10:
;; 		// dummy implementation
;; 		break;
		
;; 	default:
;; 		// unsupported command
;; 		dwSense = INVALID_CMD_OPCODE;
;; 		return NULL;
;; 	}
	
;; 	// default: return pointer to start of block buffer
;; 	return abBlockBuf;
;; }


