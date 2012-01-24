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
begin_code:
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
    jmp    [bios_class_request_handler] ; Carry out BIOS class request handler.
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
    int	    SUSB2_FINISH_INT
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
   ;; mov      [usbsend_call], usb_send_done
   mov      [usbsend_call], 0x0000
   ;; --------
   mov      r8, usbsend_link	; pointer to linker
   mov      r1, [send_endpoint] ; which endpoint to send to
   int      SUSB2_SEND_INT	; call interrupt
   ret
usb_send_done:
   ;; Do we need this?
   ;; int	    SUSB2_FINISH_INT	; call STATUS phrase
   ret
;*****************************************************************************
send_endpoint			db 0x00
;; Send data structure
usbsend_link			dw 0x0000
usbsend_addr			dw send_buffer
usbsend_len			dw 0x0000
usbsend_call			dw usb_send_done
;*****************************************************************************


;*****************************************************************************
;; Poll for received data
;*****************************************************************************
check_for_received:
    

    ret
;*****************************************************************************



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

;*****************************************************************************
; EZ-Host/EZ-OTG device descriptor
;*****************************************************************************
dev_desc:
      db 0x12       ; bLength
      db 0x01       ; bDescriptorType
      dw 0x0200     ; bcdUSB
      db 0x00       ; bDeviceClass
      db 0x00       ; bDeviceSubClass
      db 0x00       ; bDeviceProtocol
      db 0x40       ; bMaxPacketSize0
      dw VENDOR_ID  ; idVendor
      dw PRODUCT_ID ; idProduct
      dw FW_REV     ; bcdDevice
      db 1          ; iManufacturer (index of manufacture string)
      db 2          ; iProduct (index of product string)
      db 3          ; iSerialNumber (index of serial number string)
      db 1          ; bNumConfigurations (number of configurations)
;****************************************************************
; EZ-Host/EZ-OTG configuration descriptor
;****************************************************************
conf_desc:
bLength             equ ($-conf_desc)
      db 9          ; len of config
bDescriptorType     equ ($-conf_desc)
      db 2          ; type of config
wTotalLength        equ ($-conf_desc)
      dw (end_all-conf_desc)
bNumInterfaces      equ ($-conf_desc)
      db 1          ; one interface
bConfigurationValue equ ($-conf_desc)
      db 1          ; config #1
iConfiguration      equ ($-conf_desc)
      db 0          ; index of string describing config
bmAttributes        equ ($-conf_desc)
      db 0x80       ; attributes (self powered)
MaxPower            equ ($-conf_desc)
      db 50

;****************************************************************
; Interface Descriptor
;****************************************************************
interface_desc:
      db 9
      db 4
bInterfaceNumber    equ ($-interface_desc)
      db 0          ; base #
bAlternateSetting   equ ($-interface_desc)
      db 0          ; alt
bNumEndpoints       equ ($-interface_desc)
      db 2          ; 2 endpoints
bInterfaceClass     equ ($-interface_desc)
      db 0x08       ; interface class (Mass Storage)
bInterfaceSubClass  equ ($-interface_desc)
      db 0x06       ; subclass (SCSI)
bInterfaceProtocol  equ ($-interface_desc)
      db 0x50       ; interface proto (Bulk-Only Transport)
iInterface          equ ($-interface_desc)
      db 0          ; index of string describing interface
;****************************************************************
; EZ-Host/EZ-OTG endpoints descriptor
;****************************************************************
;; --------------------------------------------------
;; ------------- ep1 from original BIOS -------------
;; ep1:  db 7          ; len
;;       db 5          ; type (endpoint)
;;       db 0x1        ; type/number  (Host use WriteFile)
;;       db 2
;;       dw 64         ; packet size
;;       db 0          ; interval
;; --------------------------------------------------
ep1:  db 0x07       ; len
      db 0x05       ; type (endpoint)
      db 0x81       ; bEndpointAddress (EP 1 IN)
      db 0x02	    ; bmAttributes = Bulk
      dw 0x0200     ; packet size = 512 bytes
      db 0          ; bInterval
;; --------------------------------------------------
ep2:  db 0x07       ; len
      db 0x05       ; type (endpoint)
      db 0x02       ; bEndpointAddress (EP 2 OUT)
      db 0x02       ; bmAttributes = Bulk
      dw 0x0200     ; packet size = 512 bytes
      db 0          ; bInterval
;; --------------------------------------------------
;================================================
; support for OTG
;================================================
;; otg:  db 3          ; len=3
;;       db 9          ; type = OTG
;;       db 3          ; HNP|SRP supported

end_all:
      align 2
;================================================
; String: Require the string must be align 2
;================================================
;;-----------------------------------------------
string_desc:
      db STR0_LEN
      db 3
      dw 0x409     ; language id = English
STR0_LEN equ ($-string_desc)
;;-----------------------------------------------
str1:
      db STR1_LEN
      db 3
      dw 'Loper OS'
STR1_LEN equ ($-str1)
;;-----------------------------------------------
str2: db STR2_LEN
      db 3
      dw 'Stierlitz'
STR2_LEN equ ($-str2)
;;-----------------------------------------------
str3: db STR3_LEN
      db 3
      dw '300K'
STR3_LEN equ ($-str3)
;;-----------------------------------------------

bEPAddress       equ 2
bEPAttribute     equ 3
wMaxPacketSize   equ 4
bInterval        equ 6
      align 2


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
