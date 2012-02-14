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
    mov    w[usbrecv_addr], receive_buffer
    mov    w[usbrecv_len], CBW_Size	; how many bytes to receive
    call   usb_receive_data	; read CBW from host Bulk OUT endpoint
    
    ;; Check for valid CBW:
    cmp    r0, 0		; how many bytes (of 31) failed to read?
    jne    invalid_cbw		; if any unread bytes, invalid.
    cmp    w[MSC_CBW_Signature_lw], CBW_Signature_lw_expected
    jne    invalid_cbw		; lower word of signature is invalid
    cmp    w[MSC_CBW_Signature_uw], CBW_Signature_uw_expected
    jne    invalid_cbw		; upper word of signature is invalid
    mov    r0, b[CBW_lun]
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
    mov    b[host_in_flag], 0x00
    mov    r0, b[CBW_flags] ; Whether to stall IN endpoint:
    test   r0, 0x80         ; Bit 7 = 0 for an OUT (host-to-device) transfer.
    jz	   @f               ; Bit 7 = 1 for an IN (device-to-host) transfer.
    mov    b[host_in_flag], 0x01
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
    ;; xor    r0, r0
    mov    r0, b[host_in_flag]
    xor    r0, b[dev_in_flag]
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
    cmp    w[dwTransferSize_uw], 0x0000
    jne    @f
    jmp    device_to_host
@@: ;; else, host to device:
    test   b[dev_in_flag], 1
    jnz    device_to_host
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

    mov	   r0, 0x0053		; S
    call   dbg_putchar
    
    ret
;*****************************************************************************

;*****************************************************************************
;; Send CSW, on the next bulk-IN transfer.
;; argument: r0 = bStatus
;*****************************************************************************
send_csw:
    and    r0, 0x00FF
    mov    b[CSW_status], r0
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
    call   subtract_16
    jnc    @f	  ; If result < 0?
    xor    r0, r0 ; then iResidue = 0.
    xor    r1, r1
@@: ; iResidue >= 0:
    mov    w[CSW_data_residue_lw], r0
    mov    w[CSW_data_residue_uw], r1
    mov    b[scsi_state], SCSI_state_CSW ; next SCSI state = CSW
    ret
;*****************************************************************************
