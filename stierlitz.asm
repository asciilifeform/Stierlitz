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
    jmp	   begin_code
;*****************************************************************************
;; vars
bios_standard_request_handler:	dw 0xDEAD
bios_class_request_handler: 	dw 0xDEAD
bios_configuration_change:  	dw 0xDEAD

bios_idle_chain:  		dw 0xDEAD
;; ...

;; EP_IN = 0x81 (ep1), EP_OUT = 0x02 (ep2)

EP_IN	equ	1
EP_OUT	equ	2

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
begin_code:
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
;; Main Idler
;*****************************************************************************
main_idler:
    ;; Attempt to read CSW from bulk-in endpoint:
    mov    [recv_endpoint], EP_IN	; Receive form EP 1 (IN)
    call   poll_receiver	; speak if spoken to
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
my_class_request_handler:
    ;; Handle MSC class requests
    mov	   r0, b[r8 + bRequest] ; save request value
    ;; what to do about the fact that MSC_* are only byte-long ???
    cmp	   r0, MSC_REQUEST_RESET
    je	   class_req_eq_request_reset
    cmp	   r0, MSC_REQUEST_GET_MAX_LUN
    je	   class_req_eq_request_get_max_lun
    ;; none of these:
    ;; jmp    [bios_class_request_handler] ; Carry out BIOS class request handler.
    ;;; replace BIOS's handler
    int	   SUSB2_FINISH_INT	; call STATUS phrase
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
    ;; dwSense = 0
    ;; apparently nothing else ...?
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
    ;; ... getDescriptor? (maybe not, seeing as the BIOS seems to do it ?)
    ;; ...
    ;; ... for now, do nothing.
    ;; Or:
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
;; Endpoint I/O
;*****************************************************************************
;*****************************************************************************

;*****************************************************************************
; Transmit usbsend_len bytes to endpoint send_endpoint from send_buffer.
;*****************************************************************************
usb_send_data:
    mov     [usbsend_link], 0	; must be 0x0000 for send routine
    mov     [usbsend_addr], send_buffer
    ;; set up callback
    mov     [usbsend_call], usb_send_done
    ;; --------
    mov     r8, usbsend_link	; pointer to linker
    mov     r1, [send_endpoint] ; which endpoint to send to
    int     SUSB2_SEND_INT	; call interrupt
    ret
usb_send_done:
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
;; Poll for received data. EP is in [recv_endpoint].
;*****************************************************************************
receiver_lock			db 0x00 ; Are we already waiting?
;*****************************************************************************
poll_receiver:
    cmp     [receiver_lock], 1
    je      receiver_busy
    ;; Start receive-data:
    mov     [receiver_lock], 1	; Lock receiver
    mov     [usbrecv_link], 0
    mov     [usbrecv_addr], receive_buffer
    mov     [usbrecv_call], receiver_done
    mov     r8, usbrecv_link	; pointer to linker
    mov     r0, [recv_endpoint] ; from which endpoint to receive
    int     SUSB2_RECEIVE_INT	; call interrupt
receiver_busy:
    ret

;; Callback
receiver_done:
    int	    SUSB2_FINISH_INT	; call STATUS phrase
    ;; now process the received packet:
    mov     r0, [recv_endpoint]	; which endpoint we finished receiving from
    call    process_rx_from_ep  ; process the rx buffer
    mov     [receiver_lock], 0	; Unlock receiver
    
    call    splat		; debug
    
    ret
;*****************************************************************************
recv_endpoint			db 0x00
;; Receiver data structure
usbrecv_link			dw 0x0000
usbrecv_addr			dw 0x0000
usbrecv_len			dw 0x0000
usbrecv_call			dw 0x0000
;*****************************************************************************

;*****************************************************************************
;; Process data received from an endpoint (bulk.) EP is in R0.
;; Received packet is in receive_buffer.
;; Response will be built in send_buffer.
;*****************************************************************************
response_length			dw 0x0000
;*****************************************************************************
process_rx_from_ep:
    ;; Determine what the response should be.
    ;; This depends first on the SCSI state.

    mov    r9, [scsi_state]
    cmp    r9, 4
    jle    scsi_state_0_to_4	; make sure state is 0..4
    ;; recover from weird state - should never get here:
    mov    [scsi_state], SCSI_state_CBW
    mov    r9, [scsi_state]
scsi_state_0_to_4:
    shl    r9, 1
    jmpl   [r9 + scsi_state_jmp_table]

    ;; SCSI State Machine Table
scsi_state_jmp_table:
    dw     do_state_CBW
    dw     do_state_data_out
    dw     do_state_data_in
    dw     do_state_CSW
    dw     do_state_stalled
    ;; ------------------------
do_state_CBW:


    jmp    response_is_cooked

do_state_data_out:

    jmp    response_is_cooked

do_state_data_in:

    jmp    response_is_cooked

do_state_CSW:

    jmp    response_is_cooked

do_state_stalled:


    ;; mov	   [send_buffer], 0x00	 ; EP0Buf[0] = 0
response_is_cooked:
    ;; Send the response:
    mov	   r0, [response_length]
    mov	   [usbsend_len], r0	 ; # of bytes in response
    mov    [send_endpoint], EP_OUT ; send response to OUT endpoint
    call   usb_send_data	 ; transmit answer
    ret
;*****************************************************************************


;*****************************************************************************
;; SCSI stuff
;*****************************************************************************

;*****************************************************************************
;; SCSI State
;*****************************************************************************
;; sense key
SCSI_dw_sense:
;; hex: 00aabbcc, where aa=KEY, bb=ASC, cc=ASCQ
    dw				0x0000
    dw				0x0000

    ;; state machine state
scsi_state:
    db				0x00
    ;; Possible states:
SCSI_state_CBW		EQU	0
SCSI_state_data_out	EQU	1
SCSI_state_data_in	EQU	2
SCSI_state_CSW		EQU	3
SCSI_state_stalled	EQU	4
;*****************************************************************************

;*****************************************************************************
;; Command Block Wrapper
;*****************************************************************************
CBW:
CBW_signature:
    dw				MSC_CBW_Signature_lw
    dw				MSC_CBW_Signature_uw
CBW_tag:
    dw				0x0000
    dw				0x0000
CBW_data_transfer_length:
    dw				0x0000
    dw				0x0000
CBW_flags:
    db				0x00
CBW_lun:
    db				0x00
CBW_cb_length:
    db				0x00
CBW_cb:
    dup				16
;*****************************************************************************

;*****************************************************************************
;; Command Status Wrapper
;*****************************************************************************
CSW:
CSW_signature:
    dw				MSC_CSW_Signature_lw
    dw				MSC_CSW_Signature_uw
CSW_tag:
    dw				0x0000
    dw				0x0000
CSW_data_residue:
    dw				0x0000
    dw				0x0000
CSW_status:
    db				0x00
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
receive_buffer			dup 512 ; Let's make sure this comes last, in case of overrun.
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
