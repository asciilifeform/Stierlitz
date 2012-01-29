;************************************************************************************
;* We are what we pretend to be, so we must be careful about what we pretend to be. *
;************************************************************************************

;; TODO: add RS232 debugging?

;*****************************************************************************
FW_REV      equ 0x1
VENDOR_ID   equ 0x08EC 		; "M-Systems Flash Disk"
PRODUCT_ID  equ 0x0020		; "TravelDrive"

ORIGIN equ 0x500

.xlist
    include 67300.inc
    ;; include lcp_cmd.inc
    ;; include lcp_data.inc
    include storage.inc
.list

;*****************************************************************************
.code
    org    (ORIGIN - 16)
    dw     SCAN_SIGNATURE    ; dummy signature to align the structure
    dw	   4                 ; length
    db     0                 ; COPY opcode
    dw     IROM_BEGIN        ; mov [0xe000],0 - dummy write for alignment
    dw     0
    dw     SCAN_SIGNATURE    ; copy data to ORIGIN
    dw     ((rom_end-rom_start)+2) ; length
    db     0
    dw     ORIGIN            ; Copy Destination
    reloc  ORIGIN            ; Relocate to this symbol
;*****************************************************************************
rom_start:
    jmp	   init_code
;*****************************************************************************
;; to save bios handlers
bios_standard_request_handler:	dw 0xDEAD
bios_class_request_handler: 	dw 0xDEAD
bios_configuration_change:  	dw 0xDEAD
bios_idle_chain:  		dw 0xDEAD

;; Endpoints:
EP_IN	equ	1 ; 0x81 (ep1)
EP_OUT	equ	2 ; 0x02 (ep2)

;*****************************************************************************
;; RS-232 debugger
;*****************************************************************************
dbg_putchar:
    push   r2
    mov    r2, r0
    mov    r0, 1      ; write to the UART
    int    UART_INT   ; call UART_INT
    pop    r2
    ret

dbg_getchar:
    xor    r0, r0     ;R0 = read data from the keyboard
    int    UART_INT   ;call UART_INT
    ret    	      ;return character in R0

splat:
    mov	   r0, 0x48 		; 'H'
    call   dbg_putchar
    ret

;*****************************************************************************
;; Set up BIOS hooks.
;*****************************************************************************
init_code:
    ; enable UART debug
    mov    r0, 9		; 19200 baud
    int    KBHIT_INT

    ; Update BIOS SIE2 descriptor pointers.
    mov    [SUSB2_DEV_DESC_VEC], dev_desc
    mov    [SUSB2_CONFIG_DESC_VEC], conf_desc
    mov    [SUSB2_STRING_DESC_VEC], string_desc
    ;; Back up BIOS handler locations
    mov    [bios_standard_request_handler], [(SUSB2_STANDARD_INT*2)]
    mov    [bios_class_request_handler], [(SUSB2_CLASS_INT*2)]
    mov    [bios_configuration_change], [(SUSB2_DELTA_CONFIG_INT*2)]
    ;; Overwrite BIOS handler locations with ours
    mov    [(SUSB2_STANDARD_INT*2)], my_standard_request_handler
    mov    [(SUSB2_CLASS_INT*2)], my_class_request_handler
    mov    [(SUSB2_DELTA_CONFIG_INT*2)], my_configuration_change
    ;; Initialize idler
    mov    r0, main_idler	; r0 <- new idle task
    int    INSERT_IDLE_INT	; insert idle task
    mov    [bios_idle_chain], r0 ; save link to bios idle chain
    ret
;*****************************************************************************

;*****************************************************************************
;; Main Idler - called periodically by the BIOS.
;*****************************************************************************
main_idler:
    call   usb_bulk_in_handler ; handle any input from host
    call   usb_bulk_out_handler ; handle any output to host
    jmp    [bios_idle_chain]
;*****************************************************************************

;*****************************************************************************
;;;;;; Intercepts
;*****************************************************************************
;*****************************************************************************
;*****************************************************************************
;; Device request offsets
bmRequest	equ	0
bRequest	equ	1
wValue		equ	2
wIndex		equ	4
wLength		equ	6
;*****************************************************************************

;*****************************************************************************
;; CLASS_INT vector
;*****************************************************************************
my_class_request_handler: ;; Handle MSC class requests.
    mov	   r0, b[r8 + bRequest] ; save request value
    cmp	   r0, MSC_REQUEST_RESET
    je	   class_req_eq_request_reset
    cmp	   r0, MSC_REQUEST_GET_MAX_LUN
    je	   class_req_eq_request_get_max_lun
    ;; none of these:
    ;; jmp    [bios_class_request_handler] ; Carry out BIOS class request handler.
    int	   SUSB2_FINISH_INT	; replace BIOS's handler: call STATUS phrase
    ret
    ;;; ----------------------
class_req_eq_request_get_max_lun:
    ;; No LUNs on this device, so send back a zero:
    mov	   [send_buffer], 0x00	 ; EP0Buf[0] = 0
    mov	   [usbsend_len], 0x0001 ; send 1 byte
    mov	   [send_endpoint], 0x00 ; to endpoint 0
    call   usb_send_data	 ; transmit
    jmp	   end_class_request_handler
class_req_eq_request_reset:
    mov    [scsi_state], SCSI_state_CBW
    mov    [SCSI_dw_sense_lw], 0x0000
    mov    [SCSI_dw_sense_uw], 0x0000 ; dwSense = 0
    ;; ----------------------------------
    ;; Done with class request handler
end_class_request_handler:
    ret
;*****************************************************************************

;*****************************************************************************
;; STANDARD_INT vector
;*****************************************************************************
my_standard_request_handler:
    ;; which requests? i.e. STALL?
    ;; ... for now, do nothing.
    ;; Carry out BIOS standard request handler.
    jmp    [bios_standard_request_handler]
;*****************************************************************************

;*****************************************************************************
;; DELTA_CONFIG_INT vector
;*****************************************************************************
my_configuration_change:
    ;; we want to enable self when configured?
    ;; ... for now, do nothing.
    jmp    [bios_configuration_change]
;*****************************************************************************

;*****************************************************************************
;*****************************************************************************
; Endpoint I/O
;*****************************************************************************
;*****************************************************************************

;*****************************************************************************
; Variables to keep track of bulk I/O
;*****************************************************************************
dwTransferSize:			; Total size of data transfer
dwTransferSize_lw		dw 0x0000
dwTransferSize_uw		dw 0x0000

dwOffset:			; Offset in current data transfer
dwOffset_lw			dw 0x0000
dwOffset_uw			dw 0x0000
;*****************************************************************************

;*****************************************************************************
; Transmit usbsend_len bytes to endpoint send_endpoint from send_buffer.
;*****************************************************************************
usb_send_data:
    mov     [usbsend_link], 0	; must be 0x0000 for send routine
    mov     [usbsend_addr], send_buffer
    mov     [usbsend_call], usb_send_done ;; set up callback
    mov     r8, usbsend_link	; pointer to linker
    mov     r1, [send_endpoint] ; which endpoint to send to
    int     SUSB2_SEND_INT	; call interrupt
    ret
usb_send_done: ;; Callback
    int	    SUSB2_FINISH_INT	; call STATUS phrase
    ret
;*****************************************************************************
send_endpoint			db 0x00
;; Send data structure
usbsend_link			dw 0x0000
usbsend_addr			dw 0x0000
usbsend_len			dw 0x0000
usbsend_call			dw 0x0000
;*****************************************************************************

;*****************************************************************************
; Transmit r0 bytes from send_buffer to host via EP_IN.
; r0 will equal number of bytes which were NOT sent.
;*****************************************************************************
bulk_send:
    mov	   [usbsend_len], r0	  ; # of bytes in send_buffer to send
    mov    [send_endpoint], EP_IN ; send response to host Bulk IN endpoint
    call   usb_send_data	  ; transmit answer
    mov    r0, [usbsend_len]	  ; bytes failed (0 if all were sent.)
    ret
;*****************************************************************************

;*****************************************************************************
; Receive r0 bytes of data from Bulk OUT endpoint into receive_buffer.
; r0 will equal number of bytes NOT received.
;*****************************************************************************
usb_receive_data:
    mov    [usbrecv_len], r0	; how many bytes to receive
    mov    [usbrecv_link], 0
    mov    [usbrecv_addr], receive_buffer
    mov    [usbrecv_call], receiver_done
    mov    r8, usbrecv_link	; pointer to linker
    mov    r0, EP_OUT           ; from which endpoint to receive
    int    SUSB2_RECEIVE_INT	; call interrupt
    ret
receiver_done: ;; Callback
    int	   SUSB2_FINISH_INT	; call STATUS phrase
    mov    r0, [usbrecv_len]	; bytes failed (0 if all were received.)
    ret
;*****************************************************************************
;; Receiver data structure
usbrecv_link			dw 0x0000
usbrecv_addr			dw 0x0000
usbrecv_len			dw 0x0000
usbrecv_call			dw 0x0000
;*****************************************************************************

;*****************************************************************************
;; Process data received from an endpoint (bulk.) EP is in R0.
;; Received packet is in receive_buffer.
;; Response (if not stall) will be built in send_buffer.
;*****************************************************************************
usb_bulk_in_handler:
    ;; Determine what the response should be.
    ;; This depends first on the SCSI state machine's state.
    mov    r9, [scsi_state]
    cmp    r9, 4
    jle    scsi_state_0_to_4	; make sure state is 0..4
    ;; recover from weird state - should never get here:
    mov    [scsi_state], SCSI_state_CBW
    mov    r9, [scsi_state]
scsi_state_0_to_4:
    shl    r9, 1		; table offset times two (addresses are words.)
    jmpl   [r9 + scsi_state_jmp_table]
    ;; SCSI State Machine Table
scsi_state_jmp_table:
    dw     do_rx_state_CBW
    dw     do_rx_state_data_out
    dw     do_rx_state_data_in
    dw     do_rx_state_CSW
    dw     do_rx_state_stalled
    ;; ------------------------
do_rx_state_CBW:
    mov    r0, CBW_Size
    call   usb_receive_data	; read CBW from host Bulk OUT endpoint
    ;; Check for valid CBW:
    cmp    r0, 0		; how many bytes (of 31) failed to read?
    jne    invalid_cbw		; if any unread bytes, invalid.
    cmp    [MSC_CBW_Signature_lw], CBW_Signature_lw_expected
    jne    invalid_cbw		; lower word of signature is invalid
    cmp    [MSC_CBW_Signature_uw], CBW_Signature_uw_expected
    jne    invalid_cbw		; upper word of signature is invalid
    cmp    [CBW_lun], 0		; LUN == 0?
    jne    invalid_cbw		; if not, then CBW is 'not meaningful.'
    cmp    [CBW_cb_length], 1	; if bCBWCBLength < 1:
    jb     invalid_cbw		; then invalid
    cmp    [CBW_cb_length], 16	; if bCBWCBLength > 16:
    jg     invalid_cbw		; then invalid
    jmp    valid_cbw ;; CBW is Valid and Meaningful
invalid_cbw: ;; Or not:
    call   stall_bulk_in_ep
    call   stall_bulk_out_ep
    mov    [scsi_state], SCSI_state_stalled
    ret
valid_cbw:
    ;; clear dwOffset and dwTransferSize:
    xor    r0, r0
    mov    w[dwOffset_lw], r0
    mov    w[dwOffset_uw], r0
    mov    w[dwTransferSize_lw], r0
    mov    w[dwTransferSize_uw], r0
    ;; fHostIN = ((CBW.bmCBWFlags & 0x80) != 0);
    ;; ...
    ;; verify request:
    ;; pbData = SCSIHandleCmd(CBW.CBWCB, CBW.bCBWCBLength, &iLen, &fDevIn);
    call   SCSI_handle_cmd
    ;; results in:
    ;; response_length
    ;; dev_in_flag
    

    ret

do_rx_state_data_out:

    ret

do_rx_state_data_in:

    ret

do_rx_state_CSW:

    ret

do_rx_state_stalled:

    ret
;*****************************************************************************

;*****************************************************************************
;; Process data sent to bulk endpoint.
;*****************************************************************************
usb_bulk_out_handler:

    ret
;*****************************************************************************

;*****************************************************************************
;; Stall ongoing transfer. Determine which endpoint to stall using CBW.
;*****************************************************************************
stall_transfer:
    mov    r0, [CBW_flags]  ; Whether to stall IN endpoint:
    test   r0, 0x80         ; Bit 7 = 0 for an OUT (host-to-device) transfer.
    jnz	   stall_bulk_in_ep ; Bit 7 = 1 for an IN (device-to-host) transfer.
    cmp    [CBW_data_transfer_length_lw], 0x0000 ; if lower word != 0, then stall EP_OUT
    jne    stall_out
    cmp    [CBW_data_transfer_length_uw], 0x0000 ; if upper word != 0, then stall EP_OUT
    jne    stall_out
    ;; otherwise, if CBW_data_transfer_length == 0, stall EP_IN:
    call   stall_bulk_in_ep
    ret
stall_out:
    call   stall_bulk_out_ep
    ret
;*****************************************************************************

;*****************************************************************************
;; Stall endpoints.
;*****************************************************************************
stall_bulk_out_ep: ; Select endpoint 2 (OUT) control register
    mov    r9, DEV2_EP2_CTL_REG
    jmp    set_stall_bit
stall_bulk_in_ep: ; Select endpoint 1 (IN) control register
    mov    r9, DEV2_EP1_CTL_REG
set_stall_bit: ; Stall the endpoint:
    or     [r9], STALL_EN
    ret
;; ---------------------------------------------------------------------------
;; Do we need to clear the stall bit later?
;; CY7C67300 data sheet sayeth:
;; ---------------------------------------------------------------------------
;; Stall Enable (Bit 5)
;; The Stall Enable bit sends a Stall in response to the next request
;; (unless it is a setup request, which are always ACKed). This is a
;; sticky bit and continues to respond with Stalls until cleared by
;; firmware.
;; 1: Send Stall
;; 0: Do not send Stall
;; ---------------------------------------------------------------------------
;*****************************************************************************

;*****************************************************************************
;; Send CSW, on the next bulk-IN transfer.
;; argument: r0 = bStatus
;*****************************************************************************
send_csw:
    mov    [CSW_status], r0
    mov    [MSC_CSW_Signature_lw], CSW_Signature_lw_expected ; signature lower word
    mov    [MSC_CSW_Signature_uw], CSW_Signature_uw_expected ; signature upper word
    mov    w[CSW_tag_lw], w[CBW_tag_lw]	; copy lower word of tag from last CBW
    mov    w[CSW_tag_uw], w[CBW_tag_uw] ; copy upper word of tag from last CBW
    ;; iResidue = max( 0, (dwCBWDataTransferLength - dwTransferSize) )
    mov    r2, w[dwTransferSize_lw]
    mov    r3, w[dwTransferSize_uw] ; R3:R2 = dwTransferSize
    mov    r0, w[CBW_data_transfer_length_lw]
    mov    r1, w[CBW_data_transfer_length_uw] ; R1:R0 = dwCBWDataTransferLength
    ;; R1:R0 - R3:R2
    sub    r0, r2 ; Subtract the lower halves.  This may "borrow" from the upper half.
    subb   r1, r3 ; Subtract the upper halves.
    jnc    @f	  ; If result < 0?
    xor    r0, r0 ; then iResidue = 0.
    xor    r1, r1
@@: ; iResidue >= 0:
    mov    [CSW_data_residue_lw], r0
    mov    [CSW_data_residue_uw], r1
    mov    [scsi_state], SCSI_state_CSW ; next SCSI state = CSW
    ret
;*****************************************************************************

;*****************************************************************************
;; SCSI command handler
;*****************************************************************************
response_length			dw 0x0000 ; Length of intended response data
dev_in_flag			db 0x00 ; TRUE if data moving device -> host
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
;*****************************************************************************
SCSI_handle_cmd:
    mov    [dev_in_flag], 0x01	; default direction is device -> host
    ;; bGroupCode = (pCDB->bOperationCode >> 5) & 0x7;
    mov    r0, [SCSI_CDB6_op_code]
    shr    r0, 5
    and    r0, 0x7		       ; bGroupCode
    mov    r11, r0	               ; table offset
    add    r11, aiCDBLen_table	       ; table origin
    xor    r1, r1
    mov    r1, b[r11]                  ; aiCDBLen[bGroupCode]
    cmp    [CBW_cb_length], r1	       ; if (CDBLen < aiCDBLen[bGroupCode])
    jb     bad_scsi_cmd		       ; return NULL (bad cmd)
    ;; switch(pCDB->bOperationCode)
    mov    r0, [SCSI_CDB6_op_code]
    cmp    r0, SCSI_CMD_TEST_UNIT_READY
    je     SCSI_command_test_unit_ready
    cmp    r0, SCSI_CMD_REQUEST_SENSE
    je     SCSI_command_request_sense
    cmp    r0, SCSI_CMD_FORMAT_UNIT
    je     SCSI_command_format_unit
    cmp    r0, SCSI_CMD_INQUIRY
    je     SCSI_command_inquiry
    cmp    r0, SCSI_CMD_READ_CAPACITY
    je     SCSI_command_read_capacity
    cmp    r0, SCSI_CMD_READ_6 	; ?
    je     SCSI_command_read_6
    cmp    r0, SCSI_CMD_READ_10
    je     SCSI_command_read_10
    cmp    r0, SCSI_CMD_WRITE_6 ; ?
    je     SCSI_command_write_6
    cmp    r0, SCSI_CMD_WRITE_10
    je     SCSI_command_write_10
    cmp    r0, SCSI_CMD_VERIFY_10
    je     SCSI_command_verify_10
    cmp    r0, SCSI_CMD_REPORT_LUNS
    je     SCSI_command_report_luns
scsi_cmd_not_implemented: ;; None of these (unhandled / bad):
    mov    [SCSI_dw_sense_lw], SENSE_INVALID_CMD_OPCODE_lw
    mov    [SCSI_dw_sense_uw], SENSE_INVALID_CMD_OPCODE_uw ;; dwSense = INVALID_CMD_OPCODE;
bad_scsi_cmd:
    mov    w[response_length], 0x0000 ; return NULL
    ret
;; SCSI Command Handlers
SCSI_command_test_unit_ready:
    mov    w[response_length], 0x0000
    ret
SCSI_command_request_sense:
    ;; rsplen = min(18, pCDB->bLength)
    mov    w[response_length], 18
    xor    r0, r0
    mov    r0, b[SCSI_CDB6_bLength]
    cmp    w[response_length], r0
    jbe    @f
    mov    w[response_length], r0
@@:
    ret
SCSI_command_format_unit:
    mov    w[response_length], 0x0000
    ret
SCSI_command_inquiry:
    ;; rsplen = min(36, pCDB->bLength)
    mov    w[response_length], 36
    xor    r0, r0
    mov    r0, b[SCSI_CDB6_bLength]
    cmp    w[response_length], r0
    jbe    @f
    mov    w[response_length], r0
@@:
    ret
SCSI_command_read_capacity:
    mov    w[response_length], 8    
    ret
SCSI_command_read_6:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_command_read_10:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;    
    ret
SCSI_command_write_6:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_command_write_10:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_command_verify_10:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
SCSI_command_report_luns:
    jmp    scsi_cmd_not_implemented ;;;;;; NOT IMPLEMENTED YET ;;;;;;
    ret
;*****************************************************************************

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
MSC_CBW_Signature_uw		EQU	(receive_buffer + 1)
CBW_tag_lw			EQU	(receive_buffer + 2)
CBW_tag_uw			EQU	(receive_buffer + 3)
CBW_data_transfer_length_lw	EQU	(receive_buffer + 4)
CBW_data_transfer_length_uw	EQU	(receive_buffer + 5)
CBW_flags			EQU	(receive_buffer + 6)
CBW_lun				EQU	(receive_buffer + 7)
CBW_cb_length			EQU	(receive_buffer + 8)
CBW_cb				EQU	(receive_buffer + 9)
;*****************************************************************************

;*****************************************************************************
;; SCSI Command Block (received)
;*****************************************************************************
SCSI_CDB6_op_code		EQU	(CBW_cb)
SCSI_CDB6_LBA_0			EQU	(CBW_cb + 1)
SCSI_CDB6_LBA_1			EQU	(CBW_cb + 2)
SCSI_CDB6_LBA_2			EQU	(CBW_cb + 3)
SCSI_CDB6_LBA_3			EQU	(CBW_cb + 4)
SCSI_CDB6_bLength		EQU	(CBW_cb + 5)
SCSI_CDB6_bControl		EQU	(CBW_cb + 6)
;*****************************************************************************

;*****************************************************************************
;; SCSI Command Status Wrapper (to send to host)
;*****************************************************************************
CSW_Size			EQU	0x0D
MSC_CSW_Signature_lw		EQU	(send_buffer)
MSC_CSW_Signature_uw		EQU	(send_buffer + 1)
CSW_tag_lw			EQU	(send_buffer + 2)
CSW_tag_uw			EQU	(send_buffer + 3)
CSW_data_residue_lw		EQU	(send_buffer + 4)
CSW_data_residue_uw		EQU	(send_buffer + 5)
CSW_status			EQU	(send_buffer + 6)
;*****************************************************************************

;*****************************************************************************
;; Inquiry Response
;*****************************************************************************
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

;*****************************************************************************

;*****************************************************************************
;; Buffers
align 2

send_buffer			dup 512
receive_buffer			dup 512 ; This comes last, in case of overrun.
;*****************************************************************************

include descriptor.inc

;*****************************************************************************
rom_end:
    dw     SCAN_SIGNATURE       ; signature 
    dw	   2                    ; length
    db     5                    ; jump opcode
    dw     ORIGIN               ; Jump to BIOS Start in RAM
    db 	   0                    ; end scan
;*****************************************************************************
;*****************************************************************************
;*****************************************************************************
;*****************************************************************************
