;*****************************************************************************
iChunk				dw	0x0000
align 2
;*****************************************************************************


;*****************************************************************************
; Handle SCSI Data Out. (Host to Device)
;*****************************************************************************
handle_data_out:
    mov	   r0, 0x0058		; X
    call   dbg_putchar


    mov    w[iChunk], USB_PACKET_SIZE ; start with 64
    
    mov    r0, w[dwTransferSize_lw]
    mov    r1, w[dwTransferSize_uw] ; R1:R0 = dwTransferSize
    mov    r2, w[dwOffset_lw]
    mov    r3, w[dwOffset_uw] ; R3:R2 = dwOffset
    ;; R1:R0 - R3:R2
    call   subtract_16
    jc     no_data_out ; if carry, then dwOffset > dwTransferSize
    ;; if (dwOffset < dwTransferSize)
    ;; iChunk = USBHwEPRead(bulk_out_ep, pbData, dwTransferSize - dwOffset)
    ;; r0 already = dwTransferSize - dwOffset
    ;; iChunk = MIN(64, dwTransferSize - dwOffset)
    and    r1, r1
    jnz    @f ; if upper word of subtraction result is nonzero, then definitely > 64
    mov    r4, r0
    and    r4, (1 + (0xFFFF - USB_PACKET_SIZE)) ; 64: 0xFFC0
    jnz    @f ; if lower word is greater than 64, then keep iChunk == 64.
    mov    w[iChunk], r0 ; otherwise, iChunk <- r0 (dwTransferSize - dwOffset).
@@:
    mov    r0, w[iChunk] ; number of bytes to receive from bulk_out_ep
    mov    w[usbrecv_len], r0 ; how many bytes to receive
    mov    w[usbrecv_addr], block_receive_buffer ; into Block buffer!

    ;; !!!!!!!!!!!!!!!!!!!!!
    ;; int    PUSHALL_INT
    ;; call   print_newline
    ;; mov	   r0, 0x004C		; L
    ;; call   dbg_putchar
    ;; mov	   r0, 0x003D		; =
    ;; call   dbg_putchar
    ;; mov    r1, w[iChunk]
    ;; shr    r1, 8
    ;; and    r1, 0xFF
    ;; call   print_hex_byte
    ;; mov    r1, w[iChunk]
    ;; and    r1, 0xFF
    ;; call   print_hex_byte
    ;; int    POPALL_INT
    ;; !!!!!!!!!!!!!!!!!!!!!
    
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

    mov	   r0, 0x0031		; 1
    call   dbg_putchar
    
    call   stall_transfer
    mov    r0, CSW_CMD_FAILED
    call   send_csw
    ret
@@:
    ;; send data to host?
    ;; if (dwOffset < dwTransferSize)
    ;; iChunk = MIN(64, dwTransferSize - dwOffset)
    mov    w[iChunk], USB_PACKET_SIZE ; start with 64
    mov    r0, w[dwTransferSize_lw]
    mov    r1, w[dwTransferSize_uw] ; R1:R0 = dwTransferSize
    mov    r2, w[dwOffset_lw]
    mov    r3, w[dwOffset_uw] ; R3:R2 = dwOffset
    ;; R1:R0 - R3:R2
    call   subtract_16
    cmp    r1, 0
    jne    @f ; if upper word of subtraction result is nonzero, then definitely > 64
    mov    r4, r0
    and    r4, (1 + (0xFFFF - USB_PACKET_SIZE)) ; 64: 0xFFC0
    jnz    @f ; if lower word is greater than 64, then keep iChunk == 64.
    mov    w[iChunk], r0 ; otherwise, iChunk <- r0 (dwTransferSize - dwOffset).
@@:
    mov    r0, w[iChunk] ; number of bytes to transmit to bulk_in_ep
    mov	   w[usbsend_len], r0
    mov    r0, w[dwOffset_lw] ; only need lower word of dwoffset to calculate offset into block
    and    r0, 0x01FF ;; dwBufPos = (dwOffset & (BLOCKSIZE - 1))
    mov    w[send_buffer_offset], r0
    call   bulk_send	; transmit bytes to host
    mov    r0, w[iChunk]
    add    w[dwOffset_lw], r0    ; dwOffset += iChunk
    addc   w[dwOffset_uw], 0 	 ; add possible carry
    ;; are we done?
    cmp    w[dwOffset_lw], w[dwTransferSize_lw]
    jne    data_in_done
    cmp    w[dwOffset_uw], w[dwTransferSize_uw]
    jne    data_in_done
    ;; if (dwOffset == dwTransferSize)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; call print_newline
    ;; mov w[Debug_Title], 0x54 ; T
    ;; mov w[Debug_LW], w[CBW_data_transfer_length_lw]
    ;; mov w[Debug_UW], w[CBW_data_transfer_length_uw]
    ;; call dbg_print_32bit
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; call print_newline
    ;; mov w[Debug_Title], 0x4F ; O
    ;; mov w[Debug_LW], w[dwOffset_lw]
    ;; mov w[Debug_UW], w[dwOffset_uw]
    ;; call dbg_print_32bit
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;; mov    r0, w[CBW_data_transfer_length_lw]
    ;; cmp    w[dwOffset_lw], r0
    ;; jne    data_in_stall
    ;; mov    r0, w[CBW_data_transfer_length_uw]
    ;; cmp    w[dwOffset_uw], r0
    ;; jne    data_in_stall
data_in_send_csw:
    mov    r0, CSW_CMD_PASSED
    call   send_csw
data_in_done:
    ret
data_in_stall:

    mov	   r0, 0x0073		; s
    call   dbg_putchar

    call   stall_transfer
    jmp    data_in_send_csw
;*****************************************************************************
