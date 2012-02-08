;*****************************************************************************
;; SCSI command handler
;*****************************************************************************
response_length_lw		dw 0x0000 ; Length of intended response data
response_length_uw		dw 0x0000 ; Length of intended response data - Upper Word
dev_in_flag			db 0x00 ; TRUE if data moving device -> host
cmd_must_stall_flag		db 0x00 ; TRUE if bad command and must stall
align 2
;*****************************************************************************
; CDB length table:
aiCDBLen_table:
    db				6
    db			       10
    db			       10
    db				0
    db			       16
    db			       12
    db				0
    db			        0
align 2
;*****************************************************************************
SCSI_handle_cmd:
    mov    w[response_length_lw], 0x0000 ; default - no data
    mov    w[response_length_uw], 0x0000 ; default - no data
    mov    b[cmd_must_stall_flag], 0x00	 ; default - no stall
    mov    b[dev_in_flag], 0x01	; default direction is device -> host
    xor    r0, r0
    mov    r0, b[Common_SCSI_CDB_op_code]
    clc
    shr    r0, 5
    and    r0, 0x7		       ; bGroupCode
    mov    r11, r0	               ; table offset
    add    r11, aiCDBLen_table	       ; table origin
    xor    r1, r1
    mov    r1, b[r11]                  ; aiCDBLen[bGroupCode]
    cmp    b[CBW_cb_length], r1	       ; if (CDBLen < aiCDBLen[bGroupCode])
    jb     bad_scsi_cmd		       ; return NULL (bad cmd)
    xor    r0, r0
    mov    r0, b[Common_SCSI_CDB_op_code]
    cmp    r0, SCSI_CMD_TEST_UNIT_READY
    je     SCSI_command_test_unit_ready
    cmp    r0, SCSI_CMD_REQUEST_SENSE
    je     SCSI_command_request_sense
    cmp    r0, SCSI_CMD_FORMAT_UNIT
    je     SCSI_command_format_unit
    cmp    r0, SCSI_CMD_INQUIRY
    je     SCSI_command_inquiry
    cmp    r0, SCSI_CMD_MODE_SENSE6
    je     SCSI_command_mode_sense_6
    cmp    r0, SCSI_CMD_P_OR_A_MEDIUM_RMVL
    je     SCSI_command_p_or_a_medium_rmvl
    cmp    r0, SCSI_CMD_READ_CAPACITY
    je     SCSI_command_read_capacity
    cmp    r0, SCSI_CMD_READ_6
    je     SCSI_command_read_6
    cmp    r0, SCSI_CMD_READ_10
    je     SCSI_command_read_10
    cmp    r0, SCSI_CMD_WRITE_6
    je     SCSI_command_write_6
    cmp    r0, SCSI_CMD_WRITE_10
    je     SCSI_command_write_10
    cmp    r0, SCSI_CMD_VERIFY_10
    je     SCSI_command_verify_10
    cmp    r0, SCSI_CMD_REPORT_LUNS
    je     SCSI_command_report_luns
scsi_cmd_not_implemented: ;; None of these (unhandled / bad):
    mov    w[SCSI_dw_sense_lw], SENSE_INVALID_CMD_OPCODE_lw
    mov    w[SCSI_dw_sense_uw], SENSE_INVALID_CMD_OPCODE_uw ;; dwSense = INVALID_CMD_OPCODE;
bad_scsi_cmd:
    mov    b[cmd_must_stall_flag], 0x01 ; Must stall
    ret
;; bad_field:
;;     mov    w[SCSI_dw_sense_lw], SENSE_INVALID_FIELD_IN_CDB_lw
;;     mov    w[SCSI_dw_sense_uw], SENSE_INVALID_FIELD_IN_CDB_uw
;;     jmp    bad_scsi_cmd
;; SCSI Command Handlers
SCSI_command_test_unit_ready:
    ret
SCSI_command_request_sense:
    ;; rsplen = min(18, pCDB->bLength)
    mov    w[response_length_uw], 0x0000
    mov    w[response_length_lw], 18
    xor    r0, r0
    mov    r0, b[Request_Sense_SCSI_CDB_bLength]
    cmp    w[response_length_lw], r0
    jbe    @f
    mov    w[response_length_lw], r0
@@:
    ret
SCSI_command_format_unit:
    ret
SCSI_command_inquiry:
    ;; rsplen = min(36, pCDB->bLength)
    mov    w[response_length_uw], 0x0000
    mov    w[response_length_lw], 36
    xor    r0, r0
    mov    r0, b[Inquiry_SCSI_CDB_bLength]
    cmp    w[response_length_lw], r0
    jbe    @f
    mov    w[response_length_lw], r0
@@:
    ret
SCSI_command_mode_sense_6:
    ;; jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    mov    w[response_length_uw], 0x0000
    mov    w[response_length_lw], 0xC0
    ret
SCSI_command_p_or_a_medium_rmvl:
    ret
SCSI_command_read_capacity:
    mov    w[response_length_uw], 0x0000
    mov    w[response_length_lw], 8
    ret
SCSI_command_read_6:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_command_read_10:
    ;; Calculate response length: BLOCKSIZE will always be 512
    xor    r0, r0 ; will be lower word of rsplen
    xor    r1, r1 ; will be upper word of rsplen
    mov    r1, b[Read10_SCSI_CDB_Transfer_Len_1] ; upper byte of transfer length
    shl    r1, 1				 ; shift by 1 (already shifted by 8)
    mov    r0, b[Read10_SCSI_CDB_Transfer_Len_0] ; lower byte of transfer length
    shl    r0, 8
    clc
    shl    r0, 1
    addc   r1, 0 ; if carry, set low bit of upper word of result
    ;; now, rsplen = dwLen * 512
    mov    w[response_length_lw], r0
    mov    w[response_length_uw], r1
    ret
SCSI_command_write_6:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_command_write_10: ;; write returns nothing, AFAIK...
    ret
SCSI_command_verify_10:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_command_report_luns:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
;*****************************************************************************



;*****************************************************************************
;; SCSI data handler
;*****************************************************************************
dat_must_stall_flag		db 0x00 ; TRUE if bad command and must stall
align 2
;*****************************************************************************
SCSI_handle_data:
    mov    b[dat_must_stall_flag], 0x00
    xor    r0, r0
    mov    r0, b[Common_SCSI_CDB_op_code]
    cmp    r0, SCSI_CMD_TEST_UNIT_READY
    je     SCSI_data_cmd_test_unit_ready
    cmp    r0, SCSI_CMD_REQUEST_SENSE
    je     SCSI_data_cmd_request_sense
    cmp    r0, SCSI_CMD_FORMAT_UNIT
    je     SCSI_data_cmd_format_unit
    cmp    r0, SCSI_CMD_INQUIRY
    je     SCSI_data_cmd_inquiry
    cmp    r0, SCSI_CMD_MODE_SENSE6
    je     SCSI_data_cmd_mode_sense_6
    cmp    r0, SCSI_CMD_P_OR_A_MEDIUM_RMVL
    je     SCSI_data_cmd_p_or_a_medium_rmvl
    cmp    r0, SCSI_CMD_READ_CAPACITY
    je     SCSI_data_cmd_read_capacity
    cmp    r0, SCSI_CMD_READ_6
    je     SCSI_data_cmd_read_6
    cmp    r0, SCSI_CMD_READ_10
    je     SCSI_data_cmd_read_10
    cmp    r0, SCSI_CMD_WRITE_6
    je     SCSI_data_cmd_write_6
    cmp    r0, SCSI_CMD_WRITE_10
    je     SCSI_data_cmd_write_10
    cmp    r0, SCSI_CMD_VERIFY_10
    je     SCSI_data_cmd_verify_10
    cmp    r0, SCSI_CMD_REPORT_LUNS
    je     SCSI_data_cmd_report_luns
scsi_data_cmd_not_implemented: ;; None of these (unhandled / bad):
    mov    w[SCSI_dw_sense_lw], SENSE_INVALID_CMD_OPCODE_lw
    mov    w[SCSI_dw_sense_uw], SENSE_INVALID_CMD_OPCODE_uw ;; dwSense = INVALID_CMD_OPCODE;
bad_scsi_dat_cmd:
    mov    b[dat_must_stall_flag], 0x01 ; Must stall
    ret
scsi_read_error:
    mov    w[SCSI_dw_sense_lw], SENSE_READ_ERROR_lw
    mov    w[SCSI_dw_sense_uw], SENSE_READ_ERROR_uw
    jmp    bad_scsi_dat_cmd
scsi_write_error:
    mov    w[SCSI_dw_sense_lw], SENSE_WRITE_ERROR_lw
    mov    w[SCSI_dw_sense_uw], SENSE_WRITE_ERROR_uw
    jmp    bad_scsi_dat_cmd
;; SCSI data command handlers:
SCSI_data_cmd_test_unit_ready:
    cmp    w[SCSI_dw_sense_lw], 0
    je     @f
    cmp    w[SCSI_dw_sense_uw], 0
    je     @f
    mov    b[dat_must_stall_flag], 0x01 ;; if (dwSense !=0) return NULL;
@@:
    ret
SCSI_data_cmd_request_sense:
    ;; Build reply to request_sense command:
    mov    b[(send_buffer)], 0x70
    mov    b[(send_buffer + 1)], 0x00
    mov    b[(send_buffer + 2)], b[dwSense_KEY]
    mov    b[(send_buffer + 3)], 0x00
    mov    b[(send_buffer + 4)], 0x00
    mov    b[(send_buffer + 5)], 0x00
    mov    b[(send_buffer + 6)], 0x00
    mov    b[(send_buffer + 7)], 0x0A
    mov    b[(send_buffer + 8)], 0x00
    mov    b[(send_buffer + 9)], 0x00
    mov    b[(send_buffer + 10)], 0x00
    mov    b[(send_buffer + 11)], 0x00
    mov    b[(send_buffer + 12)], b[dwSense_ASC]
    mov    b[(send_buffer + 13)], b[dwSense_ASCQ]
    mov    b[(send_buffer + 14)], 0x00
    mov    b[(send_buffer + 15)], 0x00
    mov    b[(send_buffer + 16)], 0x00
    mov    b[(send_buffer + 17)], 0x00
    ;; reset dwSense
    xor    r0, r0
    mov    w[SCSI_dw_sense_lw], r0
    mov    w[SCSI_dw_sense_uw], r0
    ret
SCSI_data_cmd_format_unit: ;; nothing happens
    ret
SCSI_data_cmd_inquiry:
    mov    r9, send_buffer
    mov    r8, SCSI_inquiry_response
    xor    r1, r1
    mov    r1, (INQ_ADD_LEN >> 1) ; number of WORDS to mem_move
    call   mem_move
    ret
SCSI_data_cmd_mode_sense_6:
    call   zap_send_buffer
    mov    b[(send_buffer)], 0x03 ; Number of bytes which follow
    mov    b[(send_buffer + 1)], 0x00 ; Medium Type: 00h for SBC devices.
    mov    b[(send_buffer + 2)], 0x00 ; Device-Specific Parameter - no WP, no cache
    mov    b[(send_buffer + 3)], 0x00 ; No mode-parameter block descriptors.
    mov    b[(send_buffer + 4)], 0x00 ; No blocks
    mov    b[(send_buffer + 5)], 0x00 ; No blocks
    mov    b[(send_buffer + 6)], 0x00 ; No blocks
    mov    b[(send_buffer + 7)], 0x00 ; No blocks
    ret
SCSI_data_cmd_p_or_a_medium_rmvl: ;; nothing happens
    ret
SCSI_data_cmd_read_capacity:
    ;; maximal block:
    mov    b[(send_buffer)], 0x00 ;; ((MAXBLOCK >> 24) && 0xFF)
    mov    b[(send_buffer + 1)], 0x20 ;; ((MAXBLOCK >> 16) && 0xFF)
    mov    b[(send_buffer + 2)], 0x00 ;; ((MAXBLOCK >> 8) && 0xFF)
    mov    b[(send_buffer + 3)], 0x00 ;; ((MAXBLOCK >> 0) && 0xFF)
    ;; block size:
    mov    b[(send_buffer + 4)], ((BLOCKSIZE >> 24) && 0xFF)
    mov    b[(send_buffer + 5)], ((BLOCKSIZE >> 16) && 0xFF)
    mov    b[(send_buffer + 6)], ((BLOCKSIZE >> 8) && 0xFF)
    mov    b[(send_buffer + 7)], (BLOCKSIZE && 0xFF)
    ret
SCSI_data_cmd_read_6:
    jmp    scsi_data_cmd_not_implemented  ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_data_cmd_read_10:
    ;; Calculate current offset into buffer:
    mov    r0, w[dwOffset_lw]
    and    r0, 0x01FF ;; dwBufPos = (dwOffset & (BLOCKSIZE - 1))
    jnz    @f
    call   load_lba_block ;; if (dwBufPos == 0) then read new block:
@@: ; not new block
    ;; offset into block is calculated in handle_data_in
    ret
SCSI_data_cmd_write_6:
    jmp    scsi_data_cmd_not_implemented  ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_data_cmd_write_10:
    ;; This is wrong:
    
    ;; mov    r0, w[dwOffset_lw]
    ;; and    r0, 0x01FF
    ;; jnz    @f
    ;; call   save_lba_block ;; if (dwBufPos == 0) then write new block:

    ;; Because we want to write a *finished* block once it finishes.
    ;; Unlike the READ-10.
    ret
SCSI_data_cmd_verify_10: ;; nothing happens
    ret
SCSI_data_cmd_report_luns:
    jmp    scsi_data_cmd_not_implemented  ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
;*****************************************************************************
