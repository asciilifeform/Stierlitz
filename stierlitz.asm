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

;; ...

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

    
;;; TODO:
;;; Now initialize SIE1, this will result in it enumerating with the PC Host
;;; susb_init( SIE1, USB_FULL_SPEED );

    ret


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
usb_send_data:
   mov      [usbsend_link], 0	; must be 0x0000 for send routine
   mov      [usbsend_addr], send_buffer
   ;; set up callback
   mov      [usbsend_call], usb_send_done
   ;; --------
   mov      r8, usbsend_link	; pointer to linker
   mov      r1, [send_endpoint] ; which endpoint to send to
   int      SUSB2_SEND_INT	; call interrupt
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
;; Poll for received data
;*****************************************************************************
check_for_received:
    

    ret
;*****************************************************************************




;*****************************************************************************
;; SCSI stuff
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

;*****************************************************************************
;; Buffers
align 2

send_buffer			dup 512

receive_buffer			dup 512
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
