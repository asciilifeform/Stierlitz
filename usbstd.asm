;*****************************************************************************
;;;;;; Intercepts
;*****************************************************************************

;*****************************************************************************
;; Replace stock vectors
;*****************************************************************************
;; save bios handlers here:
bios_standard_request_handler:	dw 0xDEAD
bios_class_request_handler: 	dw 0xDEAD
bios_configuration_change:  	dw 0xDEAD
bios_idle_chain:  		dw 0xDEAD
;*****************************************************************************
insert_vectors:
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
    ret
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
