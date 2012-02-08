;*****************************************************************************
;*****************************************************************************
; Bulk Endpoint I/O
;*****************************************************************************
;*****************************************************************************

;*****************************************************************************
;; wait for event on EP1
;*****************************************************************************
wait_for_ep1_in_fired:
@@:
    call   bios_idle
    cmp    b[ep1_in_fired], 0x01
    jne    @b
    mov    b[ep1_in_fired], 0x00
    ret
;*****************************************************************************


;*****************************************************************************
;; wait for event on EP2
;*****************************************************************************
wait_for_ep2_out_fired:
@@:
    call   bios_idle
    cmp    b[ep2_out_fired], 0x01
    jne    @b
    mov    b[ep2_out_fired], 0x00
    ret
;*****************************************************************************


;*****************************************************************************
; Transmit usbsend_len bytes to endpoint send_endpoint from send_buffer.
;*****************************************************************************
;; tx_spin_lock			db 0x00
send_buffer_offset		dw 0x0000
align 2
;*****************************************************************************
usb_send_data:
    mov    w[usbsend_link], 0	; must be 0x0000 for send routine
    mov    w[usbsend_addr], send_buffer
    mov    r0, w[send_buffer_offset]
    add    w[usbsend_addr], r0
    mov    w[usbsend_call], usb_send_done ;; set up callback
    ;; mov    b[tx_spin_lock], 1
usb_tx:
    mov    r8, usbsend_link	; pointer to linker
    xor    r1, r1
    mov    r1, EP_IN ; which endpoint to send to
    int    SUSB2_SEND_INT	; call interrupt
    call   wait_for_ep1_in_fired
    mov    r0, w[usbsend_len]
    cmp    r0, 0x0000
    jne    usb_tx
    ;; mov    b[tx_spin_lock], 0
    ret
usb_send_done: ;; Callback
    ;; mov    b[tx_spin_lock], 0
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
    call   usb_send_data	; transmit answer
    mov    r0, w[usbsend_len]	; bytes failed (0 if all were sent.)
    ret
;*****************************************************************************


;*****************************************************************************
; Receive usbrecv_length bytes of data from Bulk OUT endpoint into receive_buffer.
; r0 will equal number of bytes NOT received.
;*****************************************************************************
;; rx_spin_lock			db 0x00
align 2
;*****************************************************************************
usb_receive_data:
    ;; mov    b[rx_spin_lock], 1
    mov    w[usbrecv_link], 0
    mov    w[usbrecv_addr], receive_buffer
    mov    w[usbrecv_call], receiver_done
usb_rx:
    mov    r8, usbrecv_link	; pointer to linker
    mov    r1, EP_OUT           ; from which endpoint to receive
    and    r1, 0x0F
    int    SUSB2_RECEIVE_INT	; call interrupt
    call   wait_for_ep2_out_fired
    mov    r0, w[usbrecv_len]
    cmp    r0, 0x0000
    jne    usb_rx
    ret
receiver_done:
    ;; mov    b[rx_spin_lock], 0
    ;; mov    r0, w[usbrecv_len]	; bytes failed (0 if all were received.)
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
