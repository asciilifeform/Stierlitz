;************************************************************************************
;* We are what we pretend to be, so we must be careful about what we pretend to be. *
;************************************************************************************

;*****************************************************************************
FW_REV      equ 0x1
VENDOR_ID   equ 0x08EC 		; "M-Systems Flash Disk"
PRODUCT_ID  equ 0x0020		; "TravelDrive"

TMR_INTERVAL equ 0xFFFF
;; TMR_INTERVAL equ 10000


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
EP_IN	equ	0x01 ; 0x81 (ep1)
EP_OUT	equ	0x02 ; 0x02 (ep2)

include debug.inc ;; RS-232 Debugger


;; TODO: enable watchdog timer?

;*****************************************************************************
;; Set up BIOS hooks.
;*****************************************************************************
init_code:
    call   dbg_enable ; Enable RS-232 Debug Port.

    ;; init:
    mov    r1, 0		; full speed
    mov    r2, 2		; SIE2
    int    SUSB_INIT_INT
    
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

    call   print_newline
    mov	   r0, 0x002A		; *
    call   dbg_putchar

    ;; Init Timer:
    mov	   [TMR1_IRQ_EN], main_timer ; New Timer1 ISR
    or     [IRQ_EN_REG], 2	     ; enable timer1 interrupt

    ;; Init Idler:
    ;; mov    r0, main_idler ; r0 <- new idle task
    ;; int    INSERT_IDLE_INT ; insert idle task
    ;; mov    w[bios_idle_chain], r0 ; save link to bios idle chain
    
    ret
;*****************************************************************************


;*****************************************************************************
;; Main Idler - called periodically by the BIOS.
;*****************************************************************************
;; idle_lock			db 0x00
;; align 2
;; ;*****************************************************************************
;; main_idler:
;;     push   [CPU_FLAGS_REG]	; push flags register
;;     int    PUSHALL_INT
    
;;     cmp    b[idle_lock], 0
;;     jne    switched_off

;;     mov    b[idle_lock], 0x01
    
;;     cmp    b[main_enable], 0 	; global enable toggled by delta_config
;;     je     switched_off		; if disabled, skip MSC routines
;;     cmp    b[rx_spin_lock], 0
;;     jne    switched_off
;;     cmp    b[tx_spin_lock], 0
;;     jne    switched_off

;;     mov	   r0, 0x002E		; .
;;     call   dbg_putchar

;;     call   usb_host_to_dev_handler ; handle any input from host
;;     call   usb_dev_to_host_handler ; handle any output to host
;; switched_off:
;;     mov    b[idle_lock], 0x00
;;     int    POPALL_INT
;;     pop    [CPU_FLAGS_REG]	; restore flags register
;;     jmp    [bios_idle_chain]
;*****************************************************************************


;*****************************************************************************
;; Main Timer - called periodically by the BIOS.
;*****************************************************************************
main_enable			db 0x00
prev_state			db 0x00
;*****************************************************************************
main_timer:
    push   [CPU_FLAGS_REG]	; push flags register
    int    PUSHALL_INT
    and    [IRQ_EN_REG], !2	; disable timer1 interrupt
    sti

    cmp    b[main_enable], 0 	; global enable toggled by delta_config
    je     main_disabled	; if disabled, skip MSC routines
 
    ;; print SCSI state:
    call   print_newline
    mov	   r0, 0x0051		; Q
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    xor    r1, r1
    mov    r1, b[scsi_state]
    call   print_hex_byte
    
    call   usb_host_to_dev_handler ; handle any input from host
    call   usb_dev_to_host_handler ; handle any output to host
    
    mov	   r0, 0x002E		; .
    call   dbg_putchar

main_disabled:
    mov    [TMR1_REG], TMR_INTERVAL	; reload timer 1
    or     [IRQ_EN_REG], 2	; enable timer1 interrupt
    int    POPALL_INT
    pop    [CPU_FLAGS_REG]	; restore flags register
    sti
    ret
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
    int	   SUSB2_FINISH_INT	; replace BIOS's handler: call STATUS phrase
    ret
    ;;; ----------------------
class_req_eq_request_get_max_lun:
    ;; No LUNs on this device, so send back a zero:
    mov	   [ctlsend_addr], ctlsend_buffer ; address of buffer
    mov	   [ctlsend_buffer], 0x0000 ; EP0Buf[0] = 0
    mov	   [ctlsend_len], 0x0001 ; send 1 byte
    mov    [ctlsend_call], 0x0000 ; no callback
    mov    r8, ctlsend_link	; pointer to linker
    mov    r1, 0x0000 		; which endpoint to send to
    int    SUSB2_SEND_INT	; call interrupt
    jmp	   end_class_request_handler
class_req_eq_request_reset:
    ;; TODO: implement genuine reset of EVERYTHING...
    mov    b[scsi_state], SCSI_state_CBW
    mov    [SCSI_dw_sense_lw], 0x0000
    mov    [SCSI_dw_sense_uw], 0x0000 ; dwSense = 0
    ;; int	   SUSB2_FINISH_INT
    ;; ----------------------------------
    ;; Done with class request handler
end_class_request_handler:
    ret
;*****************************************************************************
;; CTL Send data structure
align 2
ctlsend_link			dw 0x0000
ctlsend_addr			dw 0x0000
ctlsend_len			dw 0x0000
ctlsend_call			dw 0x0000
ctlsend_buffer			dw 0x0000
;*****************************************************************************

;*****************************************************************************
;; STANDARD_INT vector
;*****************************************************************************
my_standard_request_handler:
    jmp    [bios_standard_request_handler]
;*****************************************************************************

;*****************************************************************************
;; DELTA_CONFIG_INT vector
;*****************************************************************************
req_wvalue		dw 0x0000
conf_count		dw 0x0000
;*****************************************************************************
my_configuration_change:
    push   [CPU_FLAGS_REG]	; push flags register
    int    PUSHALL_INT

    addi   [conf_count], 1
    
    mov    r8, SIE2_DEV_REQ
    mov	   r0, w[r8 + wValue]
    mov    [req_wvalue], r0
    call   [bios_configuration_change] ; let BIOS configure endpoints...
    mov	   r0, [req_wvalue]
    and    r0, 0xFF
    cmp    r0, 1 ; [bConfigurationValue]
    jne    @f ; it isn't time yet

    cmp    b[conf_count], 4
    jb     @f
    
    mov    [main_enable], 1 ; we want to enable self when configured
@@:
    int    POPALL_INT
    pop    [CPU_FLAGS_REG]	; push flags register
    ret
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

align 2

;*****************************************************************************
; Transmit usbsend_len bytes to endpoint send_endpoint from send_buffer.
;*****************************************************************************
tx_spin_lock			db 0x00
send_buffer_offset		dw 0x0000
align 2
;*****************************************************************************
usb_send_data:
    mov    w[usbsend_link], 0	; must be 0x0000 for send routine
    mov    w[usbsend_addr], send_buffer
    mov    r0, w[send_buffer_offset]
    add    w[usbsend_addr], r0
    mov    w[usbsend_call], usb_send_done ;; set up callback
    mov    b[tx_spin_lock], 1
    mov    r8, usbsend_link	; pointer to linker
    xor    r1, r1
    mov    r1, EP_IN ; which endpoint to send to
    int    SUSB2_SEND_INT	; call interrupt
@@:
    int    PUSHALL_INT
    int    IDLE_INT
    int    POPALL_INT
    cmp    b[tx_spin_lock], 0
    je     @b
    ret
usb_send_done: ;; Callback
    mov   b[tx_spin_lock], 0
    ret
;*****************************************************************************
;; Send data structure
align 2
usbsend_link			dw 0x0000
usbsend_addr			dw 0x0000
usbsend_len			dw 0x0000
usbsend_call			dw 0x0000
;*****************************************************************************

;*****************************************************************************
; Transmit [usbsend_len] bytes from send_buffer to host via EP_IN.
; r0 will equal number of bytes which were NOT sent.
;*****************************************************************************
bulk_send:
    int    PUSHALL_INT
    call   print_newline
    mov	   r0, 0x006e		; n
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[usbsend_len]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[usbsend_len]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    ;; call   dbg_dump_tx_buffer	; debug
    int    POPALL_INT

    call   usb_send_data	; transmit answer
    
    mov    r0, w[usbsend_len]	; bytes failed (0 if all were sent.)
    ret
;*****************************************************************************

;*****************************************************************************
; Receive r0 bytes of data from Bulk OUT endpoint into receive_buffer.
; r0 will equal number of bytes NOT received.
;*****************************************************************************
rx_spin_lock			db 0x00
align 2
;*****************************************************************************
usb_receive_data:
    mov    b[rx_spin_lock], 1
    mov    w[usbrecv_len], r0	; how many bytes to receive
    mov    w[usbrecv_link], 0
    mov    w[usbrecv_addr], receive_buffer
    mov    w[usbrecv_call], receiver_done
    mov    r8, usbrecv_link	; pointer to linker
    mov    r1, EP_OUT           ; from which endpoint to receive
    and    r1, 0x0F
    int    SUSB2_RECEIVE_INT	; call interrupt
@@:
    int    PUSHALL_INT
    int    IDLE_INT
    int    POPALL_INT
    cmp    b[rx_spin_lock], 0
    jne    @b
    ret
receiver_done:
    mov    b[rx_spin_lock], 0
    mov    r0, w[usbrecv_len]	; bytes failed (0 if all were received.)
    ret
;*****************************************************************************
;; Receiver data structure
usbrecv_link			dw 0x0000
usbrecv_addr			dw 0x0000
usbrecv_len			dw 0x0000
usbrecv_call			dw 0x0000
align 2
;*****************************************************************************

;*****************************************************************************
;; Process data received from bulk OUT endpoint.
;; Received packet is in receive_buffer.
;; Response (if not stall) will be built in send_buffer.
;*****************************************************************************
host_in_flag			db 0x00
align 2
;*****************************************************************************
usb_host_to_dev_handler:
    ;; Determine what the response should be.
    ;; This depends first on the SCSI state machine's state.
    xor    r9, r9
    mov    r9, b[scsi_state]
    cmp    r9, 4
    jle    scsi_rx_state_0_to_4	; make sure state is 0..4
    ;; recover from weird state - should never get here:
    mov    b[scsi_state], SCSI_state_CBW
    mov    r9, b[scsi_state]
scsi_rx_state_0_to_4:
    shl    r9, 1		; table offset times two (addresses are words.)
    jmpl   [r9 + scsi_rx_state_jmp_table]
    ;; SCSI State Machine Table
scsi_rx_state_jmp_table:
    dw     do_rx_state_CBW
    dw     do_rx_state_data_out
    dw     do_rx_state_data_in
    dw     do_rx_state_CSW
    dw     do_rx_state_stalled
    ;; ------------------------
do_rx_state_CBW:
    mov    r0, CBW_Size
    call   usb_receive_data	; read CBW from host Bulk OUT endpoint

    ;; push   r0
    ;; call   dbg_dump_rx_buffer	; debug
    ;; pop    r0
    
    ;; Check for valid CBW:
    cmp    r0, 0		; how many bytes (of 31) failed to read?
    jne    invalid_cbw		; if any unread bytes, invalid.
    cmp    w[MSC_CBW_Signature_lw], CBW_Signature_lw_expected
    jne    invalid_cbw		; lower word of signature is invalid
    cmp    w[MSC_CBW_Signature_uw], CBW_Signature_uw_expected
    jne    invalid_cbw		; upper word of signature is invalid
    mov    r0, [CBW_lun]
    and    r0, 0x0F
    cmp    r0, 0		; LUN == 0?
    jne    invalid_cbw		; if not, then CBW is 'not meaningful.'
    cmp    b[CBW_cb_length], 1	; if bCBWCBLength < 1:
    jb     invalid_cbw		; then invalid
    cmp    b[CBW_cb_length], 16	; if bCBWCBLength > 16:
    jg     invalid_cbw		; then invalid
    jmp    valid_cbw ;; CBW is Valid and Meaningful
invalid_cbw: ;; Or not:
    call   stall_bulk_in_ep
    call   stall_bulk_out_ep
    mov    b[scsi_state], SCSI_state_stalled
    ret
valid_cbw:
    ;; clear dwOffset and dwTransferSize:
    xor    r0, r0
    mov    w[dwOffset_lw], r0
    mov    w[dwOffset_uw], r0
    mov    w[dwTransferSize_lw], r0
    mov    w[dwTransferSize_uw], r0
    ;; fHostIN = ((CBW.bmCBWFlags & 0x80) != 0);
    mov    [host_in_flag], 0x00
    mov    r0, b[CBW_flags] ; Whether to stall IN endpoint:
    test   r0, 0x80         ; Bit 7 = 0 for an OUT (host-to-device) transfer.
    jz	   @f               ; Bit 7 = 1 for an IN (device-to-host) transfer.
    mov    [host_in_flag], 0x01
@@:
    call   SCSI_handle_cmd  ; pbData = SCSIHandleCmd(CBW.CBWCB, CBW.bCBWCBLength, &iLen, &fDevIn);
    cmp    b[cmd_must_stall_flag], 0x01
    jne    @f
    ;; if (pbData == NULL)
    call   stall_transfer
    mov    r0, CSW_CMD_FAILED
    call   send_csw
    ret
@@:
    ;; if device and host disagree on direction, send Phase Error status.
    cmp    w[response_length_uw], 0
    jne    yes_response
    cmp    w[response_length_lw], 0
    je     no_disagree
yes_response:
    ;; if (response length > 0)
    mov    r0, [host_in_flag]
    xor    r0, [dev_in_flag]
    jz     no_disagree
    ;; && ((fHostIn && !fDevIn) || (!fHostIn && fDevIn)) then:
    call   stall_transfer
    mov    r0, CSW_PHASE_ERROR
    call   send_csw
    ret
no_disagree:
    ;; if D > H, send Phase Error status.
    mov    r2, w[response_length_lw] ; R3:R2 = dwTransferSize
    mov    r3, w[response_length_uw] ; upper word of response length
    mov    r0, w[CBW_data_transfer_length_lw]
    mov    r1, w[CBW_data_transfer_length_uw] ; R1:R0 = dwCBWDataTransferLength
    ;; R1:R0 - R3:R2
    ;; sub    r0, r2 ; Subtract the lower halves.  This may "borrow" from the upper half.
    ;; subb   r1, r3 ; Subtract the upper halves.
    call   subtract_16
    jnc    @f	  ; If result < 0?
    ;; if (iLen > CBW.dwCBWDataTransferLength) then: negative residue
    call   stall_transfer
    mov    r0, CSW_PHASE_ERROR
    call   send_csw
    ret
@@:
    ;; dwTransferSize = iLen
    mov    w[dwTransferSize_lw], w[response_length_lw]
    mov    w[dwTransferSize_uw], w[response_length_uw]
    ;; if ((dwTransferSize == 0) || fDevIn)
    cmp    w[dwTransferSize_lw], 0x0000
    jne    @f
    cmp    w[dwTransferSize_lw], 0x0000
    jne    @f
    jmp    device_to_host
@@:
    cmp    b[dev_in_flag], 0x01
    je     device_to_host
    ;; otherwise, data from host to device:
    mov    b[scsi_state], SCSI_state_data_out
    ret
device_to_host:
    mov    b[scsi_state], SCSI_state_data_in
    call   handle_data_in
    ret
do_rx_state_data_out:
    call   handle_data_out
    ret
do_rx_state_data_in:
do_rx_state_CSW:
    ;; iChunk = USBHwEPRead(bEP, NULL, 0); (for debug only?)
    ;; phrase error:
    ;; mov    b[scsi_state], SCSI_state_CBW
    ret
do_rx_state_stalled:
    call   stall_bulk_out_ep ; if stalled, keep stalling:
    ret
;*****************************************************************************

;*****************************************************************************
;; Process data sent to bulk IN endpoint.
;*****************************************************************************
usb_dev_to_host_handler:
    ;; Determine what the response should be.
    ;; This depends first on the SCSI state machine's state.
    xor    r9, r9
    mov    r9, b[scsi_state]
    cmp    r9, 4
    jle    scsi_tx_state_0_to_4	; make sure state is 0..4
    ;; recover from weird state - should never get here:
    mov    b[scsi_state], SCSI_state_CBW
    mov    r9, b[scsi_state]
scsi_tx_state_0_to_4:
    shl    r9, 1		; table offset times two (addresses are words.)
    jmpl   [r9 + scsi_tx_state_jmp_table]
    ;; SCSI State Machine Table
scsi_tx_state_jmp_table:
    dw     do_tx_state_CBW
    dw     do_tx_state_data_out
    dw     do_tx_state_data_in
    dw     do_tx_state_CSW
    dw     do_tx_state_stalled
    ;; ------------------------
do_tx_state_CBW:
do_tx_state_data_out:
    ret
do_tx_state_data_in:
    call   handle_data_in
    ret
do_tx_state_CSW:
    mov	   w[usbsend_len], CSW_Size
    mov    w[send_buffer_offset], 0x0000
    call   bulk_send  ;; send the CSW:
    mov    b[scsi_state], SCSI_state_CBW
    ret
do_tx_state_stalled:
    call   stall_bulk_in_ep ; if stalled, keep stalling:
    ret
;*****************************************************************************

;*****************************************************************************
iChunk			dw 0x0000
align 2
;*****************************************************************************

;*****************************************************************************
; Handle SCSI Data Out. (Host to Device)
;*****************************************************************************
handle_data_out:
    mov    r0, w[dwTransferSize_lw]
    mov    r1, w[dwTransferSize_uw] ; R1:R0 = dwTransferSize
    mov    r2, w[dwOffset_lw]
    mov    r3, w[dwOffset_uw] ; R3:R2 = dwOffset
    ;; R1:R0 - R3:R2
    ;; sub    r0, r2 ; Subtract the lower halves.  This may "borrow" from the upper half.
    ;; subb   r1, r3 ; Subtract the upper halves.
    call   subtract_16
    jc     no_data_out ; if carry, then dwOffset > dwTransferSize
    ;; if (dwOffset < dwTransferSize)
    ;; iChunk = USBHwEPRead(bulk_out_ep, pbData, dwTransferSize - dwOffset)
    ;; r0 already = dwTransferSize - dwOffset
    call   usb_receive_data ; receive data from host
    call   SCSI_handle_data
    cmp    b[dat_must_stall_flag], 0x01
    jne    @f
    ;; if pbData == NULL:
    call   stall_transfer
    mov    r0, CSW_CMD_FAILED
    call   send_csw
    ret
@@:
    mov    r0, w[iChunk]
    add    w[dwOffset_lw], r0   ; dwOffset += iChunk
    addc   w[dwOffset_uw], 0 	; add possible carry
no_data_out:
    cmp    w[dwOffset_lw], w[dwTransferSize_lw]
    jne    data_out_done
    cmp    w[dwOffset_uw], w[dwTransferSize_uw]
    jne    data_out_done
    ;; if (dwOffset == dwTransferSize)
    mov    r0, w[CBW_data_transfer_length_lw]
    cmp    w[dwOffset_lw], r0
    jne    data_out_stall
    mov    r0, w[CBW_data_transfer_length_uw]
    cmp    w[dwOffset_uw], r0
    jne    data_out_stall
data_out_send_csw:
    mov    r0, CSW_CMD_PASSED
    call   send_csw
data_out_done:
    ret
data_out_stall:
    call   stall_transfer
    jmp    data_out_send_csw
;*****************************************************************************

;*****************************************************************************
; Handle SCSI Data In. (Device to Host)
;*****************************************************************************
handle_data_in:
    call   SCSI_handle_data
    cmp    b[dat_must_stall_flag], 0x01
    jne    @f
    ;; pbData == NULL:
    call   stall_transfer
    mov    r0, CSW_CMD_FAILED
    call   send_csw
    ret
@@:
    ;; send data to host?
    ;; if (dwOffset < dwTransferSize)
    ;; iChunk = MIN(64, dwTransferSize - dwOffset)
    mov    w[iChunk], 64 	; start with 64
    mov    r0, w[dwTransferSize_lw]
    mov    r1, w[dwTransferSize_uw] ; R1:R0 = dwTransferSize
    mov    r2, w[dwOffset_lw]
    mov    r3, w[dwOffset_uw] ; R3:R2 = dwOffset
    ;; R1:R0 - R3:R2
    ;; sub    r0, r2 ; Subtract the lower halves.  This may "borrow" from the upper half.
    ;; subb   r1, r3 ; Subtract the upper halves.
    call   subtract_16
    cmp    r1, 0
    jne    @f	  ; if upper word of subtraction result is nonzero, then definitely > 64

    ;; cmp    r0, 64
    ;; jg     @f	  ; if lower word is greater than 64, then keep iChunk == 64.

    mov    r4, r0
    and    r4, 0xFFC0
    jnz    @f	  ; if lower word is greater than 64, then keep iChunk == 64.
    
    mov    w[iChunk], r0 ; otherwise, iChunk <- r0 (dwTransferSize - dwOffset).
@@:

    int    PUSHALL_INT
    call   print_newline
    mov	   r0, 0x0043		; C
    call   dbg_putchar
    mov	   r0, 0x004C		; L
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[iChunk]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[iChunk]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT

    mov    r0, w[iChunk] ; number of bytes to transmit to bulk_in_ep
    mov	   w[usbsend_len], r0

    mov    r0, w[dwOffset_lw]	; MOOOOOOOOOO
    and    r0, 0x01FF ;; dwBufPos = (dwOffset & (BLOCKSIZE - 1))
    mov    w[send_buffer_offset], r0
    
    call   bulk_send	; transmit bytes to host
    mov    r0, w[iChunk]
    add    w[dwOffset_lw], r0    ; dwOffset += iChunk
    addc   w[dwOffset_uw], 0 	 ; add possible carry
    
    int    PUSHALL_INT
    call   print_newline
    mov	   r0, 0x004F		; O
    call   dbg_putchar
    mov	   r0, 0x004C		; L
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[dwOffset_lw]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[dwOffset_lw]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    mov	   r0, 0x004F		; O
    call   dbg_putchar
    mov	   r0, 0x0055		; U
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[dwOffset_uw]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[dwOffset_uw]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline

    call   print_newline
    mov	   r0, 0x0054		; T
    call   dbg_putchar
    mov	   r0, 0x004C		; L
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[CBW_data_transfer_length_lw]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[CBW_data_transfer_length_lw]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    mov	   r0, 0x0054		; T
    call   dbg_putchar
    mov	   r0, 0x0055		; U
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[CBW_data_transfer_length_uw]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[CBW_data_transfer_length_uw]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT

    ;; are we done?
    cmp    w[dwOffset_lw], w[dwTransferSize_lw]
    jne    data_in_done
    cmp    w[dwOffset_uw], w[dwTransferSize_uw]
    jne    data_in_done
    ;; if (dwOffset == dwTransferSize)
    mov    r0, w[CBW_data_transfer_length_lw]
    cmp    w[dwOffset_lw], r0
    jne    data_in_stall
    mov    r0, w[CBW_data_transfer_length_uw]
    cmp    w[dwOffset_uw], r0
    jne    data_in_stall
data_in_send_csw:
    mov    r0, CSW_CMD_PASSED
    call   send_csw
data_in_done:
    ret
data_in_stall:
    call   stall_transfer
    jmp    data_in_send_csw
;*****************************************************************************

;*****************************************************************************
;; Stall ongoing transfer. Determine which endpoint to stall using CBW.
;*****************************************************************************
stall_transfer:
    xor    r0,r0
    mov    r0, b[CBW_flags]  ; Whether to stall IN endpoint:
    test   r0, 0x80         ; Bit 7 = 0 for an OUT (host-to-device) transfer.
    jnz	   stall_bulk_in_ep ; Bit 7 = 1 for an IN (device-to-host) transfer.
    cmp    w[CBW_data_transfer_length_lw], 0x0000 ; if lower word != 0, then stall EP_OUT
    jne    stall_out
    cmp    w[CBW_data_transfer_length_uw], 0x0000 ; if upper word != 0, then stall EP_OUT
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
    ;; mov	   r0, 0x0053		; S
    ;; call   dbg_putchar
    ret
;*****************************************************************************

;*****************************************************************************
;; Send CSW, on the next bulk-IN transfer.
;; argument: r0 = bStatus
;*****************************************************************************
send_csw:
    and    r0, 0xFF
    mov    b[CSW_status], r0

    int    PUSHALL_INT
    call   print_newline
    mov	   r0, 0x0074		; t
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    xor    r1, r1
    mov    r1, b[CSW_status]
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT
    
    mov    w[MSC_CSW_Signature_lw], CSW_Signature_lw_expected ; signature lower word
    mov    w[MSC_CSW_Signature_uw], CSW_Signature_uw_expected ; signature upper word
    mov    w[CSW_tag_lw], w[CBW_tag_lw]	; copy lower word of tag from last CBW
    mov    w[CSW_tag_uw], w[CBW_tag_uw] ; copy upper word of tag from last CBW
    ;; iResidue = max( 0, (dwCBWDataTransferLength - dwTransferSize) )
    mov    r2, w[dwTransferSize_lw]
    mov    r3, w[dwTransferSize_uw] ; R3:R2 = dwTransferSize
    mov    r0, w[CBW_data_transfer_length_lw]
    mov    r1, w[CBW_data_transfer_length_uw] ; R1:R0 = dwCBWDataTransferLength
    ;; R1:R0 - R3:R2
    ;; sub    r0, r2 ; Subtract the lower halves.  This may "borrow" from the upper half.
    ;; subb   r1, r3 ; Subtract the upper halves.
    call   subtract_16
    jnc    @f	  ; If result < 0?
    xor    r0, r0 ; then iResidue = 0.
    xor    r1, r1
@@: ; iResidue >= 0:
    mov    w[CSW_data_residue_lw], r0
    mov    w[CSW_data_residue_uw], r1
    mov    b[scsi_state], SCSI_state_CSW ; next SCSI state = CSW

    int    PUSHALL_INT
    call   print_newline
    mov	   r0, 0x004C		; L
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[CSW_data_residue_lw]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[CSW_data_residue_lw]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    mov	   r0, 0x0055		; U
    call   dbg_putchar
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, w[CSW_data_residue_uw]
    shr    r1, 8
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, w[CSW_data_residue_uw]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT
    
    ret
;*****************************************************************************

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
    ;; ...
    ;; ...
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

;*****************************************************************************
;; Load LBA block
;*****************************************************************************
load_lba_block:
    ;; debug only right now:
    int    PUSHALL_INT
    call   print_newline
    mov	   r0, 0x004C		; L
    call   dbg_putchar
    mov	   r0, 0x0052		; R
    call   dbg_putchar   
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, b[Read10_SCSI_CDB_LBA_3]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Read10_SCSI_CDB_LBA_2]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Read10_SCSI_CDB_LBA_1]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Read10_SCSI_CDB_LBA_0]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT


    ;; find out if offset extends one or more block forward:

    ;; mov    r1, w[dwOffset_uw]
    mov    r0, w[dwOffset_lw]
    shr    r0, 8
    clc
    shr    r0, 1
    ;; now block offset: r0 == dwOffset_lw / 512
    
    jz     @f
    ;; need to correct for offset:
    mov    r1, b[Read10_SCSI_CDB_LBA_1]
    shl    r1, 8
    mov    r1, b[Read10_SCSI_CDB_LBA_0]
    add    r1, r0

    mov    b[Read10_SCSI_CDB_LBA_0], r1
    shr    r1, 8
    mov    b[Read10_SCSI_CDB_LBA_1], r1

    ;; print corrected:
    int    PUSHALL_INT
    call   print_newline
    mov	   r0, 0x005A		; Z
    call   dbg_putchar
    mov	   r0, 0x0052		; R
    call   dbg_putchar   
    mov	   r0, 0x003D		; =
    call   dbg_putchar
    mov    r1, b[Read10_SCSI_CDB_LBA_3]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Read10_SCSI_CDB_LBA_2]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Read10_SCSI_CDB_LBA_1]
    and    r1, 0xFF
    call   print_hex_byte
    mov    r1, b[Read10_SCSI_CDB_LBA_0]
    and    r1, 0xFF
    call   print_hex_byte
    call   print_newline
    int    POPALL_INT
    
@@:
    ;; no need to correct for offset:

    
    ;; We have blocks: 0, 10, 63, 64, 192, 320

    ;; 320 == 0x0140
    
    ;; Upper two LBA address bytes must be zero
    cmp	   b[Read10_SCSI_CDB_LBA_3], 0x00
    jne    zero_block
    cmp	   b[Read10_SCSI_CDB_LBA_2], 0x00
    jne    zero_block

    cmp	   b[Read10_SCSI_CDB_LBA_1], 0x00
    je     @f
    cmp	   b[Read10_SCSI_CDB_LBA_1], 0x01
    jne    @f
    cmp	   b[Read10_SCSI_CDB_LBA_0], 0x40
    jne    zero_block
    ;; block 320;
    mov    r8, block_320
    jmp    load_block
@@:
    cmp	   b[Read10_SCSI_CDB_LBA_0], 0
    jne    @f
    mov    r8, block_0
    jmp    load_block
@@:
    cmp	   b[Read10_SCSI_CDB_LBA_0], 10
    jne    @f
    mov    r8, block_10
    jmp    load_block
@@:
    cmp	   b[Read10_SCSI_CDB_LBA_0], 63
    jne    @f
    mov    r8, block_63
    jmp    load_block
@@:
    cmp	   b[Read10_SCSI_CDB_LBA_0], 64
    jne    @f
    mov    r8, block_64
    jmp    load_block
@@:
    cmp	   b[Read10_SCSI_CDB_LBA_0], 192
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
; zap send buffer
; r9 = dest, r8 = src, r1 = word count
;*****************************************************************************
zap_send_buffer:
    mov    r1, 0x0200
    mov    r9, send_buffer
@@:
    mov    b[r9++], 0x00
    dec    r1
    jnz    @b
    ret
;*****************************************************************************

;*****************************************************************************
; mem_move
; r9 = dest, r8 = src, r1 = word count
;*****************************************************************************
mem_move:
@@:
    mov    w[r9++], w[r8++]	; copy data
    dec    r1
    jnz    @b
    ret
;*****************************************************************************

;*****************************************************************************
; subtract (16-bit)
; R1:R0 - R3:R2
;*****************************************************************************
subtract_16:
    push   r4
    xor    r4, r4
    sub    r0, r2 ; Subtract the lower halves.  This may "borrow" from the upper half.
    jnc    @f
    mov    r4, 1
@@:
    subb   r1, r3 ; Subtract the upper halves.
    jc     @f	  ; Carry set from subtracting upper halves?
    test   r4, 1  ; If not, see if carry was set from subtracting lower halves:
    jz     @f
    stc
@@:
    pop    r4
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

;*****************************************************************************

include descriptor.inc

include clean1gb.inc

;*****************************************************************************
;; Buffers
align 2

send_buffer			dup 512
receive_buffer			dup 512
;*****************************************************************************

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
