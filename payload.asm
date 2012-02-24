 ;; /*************************************************************************
 ;; *                     This file is part of Stierlitz:                    *
 ;; *               https://github.com/asciilifeform/Stierlitz               *
 ;; *************************************************************************/

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
physical_lba_lw			dw 0x0000
physical_lba_uw			dw 0x0000
;*****************************************************************************

;*****************************************************************************
;; Load physical LBA block.
;*****************************************************************************
load_physical_lba_block:
    call   send_host_physical_lba

    mov    r1, 0x0100
    mov    r9, send_buffer
@@:
    mov    r0, 0x4000 ; Read byte from bus
    call   hpi_mb_tx  ; Send read command
    call   hpi_mb_rx  ; Receive result
    and    r0, 0x00FF

    mov    r2, r0
    
    mov    r0, 0x4000 ; Read byte from bus
    call   hpi_mb_tx  ; Send read command
    call   hpi_mb_rx  ; Receive result
    and    r0, 0x00FF
    shl    r0, 8

    or     r2, r0
    
    mov    w[r9++], r2
    dec    r1
    jnz    @b

    ret
;*****************************************************************************


;*****************************************************************************
;; Save physical LBA block.
;*****************************************************************************
save_physical_lba_block:
    call   send_host_physical_lba

    mov    r1, 0x0100
    mov    r9, block_receive_buffer
@@:
    mov    r2, w[r9++]

    mov    r0, r2
    and    r0, 0x00FF
    or     r0, 0x8000 ; Write byte to bus
    call   hpi_mb_tx  ; Send write command
    call   hpi_mb_rx  ; Receive confirmation

    mov    r0, r2
    shr    r0, 8
    and    r0, 0x00FF
    or     r0, 0x8000 ; Write byte to bus
    call   hpi_mb_tx  ; Send write command
    call   hpi_mb_rx  ; Receive confirmation
    
    dec    r1
    jnz    @b
    ret    
;*****************************************************************************


;*****************************************************************************
;; Set host's LBA registers.
;*****************************************************************************
send_host_physical_lba:
    ;; Send LBA[0]:
    mov    r0, w[physical_lba_lw]
    and    r0, 0xFF
    call   hpi_mb_tx
    ;; Send LBA[1]:
    mov    r0, w[physical_lba_lw]
    shr    r0, 8
    and    r0, 0xFF
    or     r0, 0x100
    call   hpi_mb_tx
    ;; Send LBA[2]:
    mov    r0, w[physical_lba_uw]
    shr    r0, 8
    and    r0, 0xFF
    or     r0, 0x200
    call   hpi_mb_tx
    ;; Send LBA[3]:
    mov    r0, w[physical_lba_uw]
    and    r0, 0xFF
    or     r0, 0x300
    call   hpi_mb_tx
    ret
;*****************************************************************************


;; ;*****************************************************************************
;; ;; Load physical LBA block.
;; ;*****************************************************************************
;; load_physical_lba_block:
;;     call   send_host_physical_lba

;;     ;; right now, just a lame test.
;;     mov    r1, 0x0080
;;     mov    r9, send_buffer
;; @@:
;;     mov    w[r9++], w[physical_lba_lw]
;;     mov    w[r9++], w[physical_lba_uw]
;;     dec    r1
;;     jnz    @b
;;     ret
;; ;*****************************************************************************

;; ;*****************************************************************************
;; ;; Save physical LBA block.
;; ;*****************************************************************************
;; save_physical_lba_block:
;;     call   send_host_physical_lba

;;     ;; right now, a test.
;;     int    PUSHALL_INT
;;     ;;-------------------------------------------
;;     ;; See if expected values match:
;;     mov    r1, 0x0080
;;     mov    r9, block_receive_buffer
;; @@:
;;     mov    r0, w[r9++]
;;     cmp    r0, w[physical_lba_lw]
;;     jne    sad_block
;;     mov    r2, w[r9++]
;;     cmp    r2, w[physical_lba_uw]
;;     jne    sad_block
;;     dec    r1
;;     jnz    @b
;;     ;; all ok:
;;     jmp    happy_block
;; sad_block:
;;     mov    w[Debug_LW], r0
;;     mov    w[Debug_UW], r2
;;     mov	   r0, 0x004E		; N
;;     call   dbg_putchar
;;     mov    w[Debug_Title], 0x42 ; B
;;     call   dbg_print_32bit
;;     mov	   r0, 0x0020		; [space]
;;     call   dbg_putchar
;;     mov	   r0, 0x004E		; N
;;     call   dbg_putchar
;;     mov	   r0, 0x004F		; O
;;     call   dbg_putchar
;;     ;; test
;;     call   print_newline
;;     mov    w[Debug_LW], w[physical_lba_lw]
;;     mov    w[Debug_UW], 0x0000
;;     mov    w[Debug_Title], 0x49 ; I
;;     call   dbg_print_32bit
;;     call   print_newline
;;     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; happy_block:
;;     ;; mov	   r0, 0x004F		; O
;;     ;; call   dbg_putchar
;;     ;; mov	   r0, 0x004B		; K
;;     ;; call   dbg_putchar
;; done_block:
;;     ;;-------------------------------------------
;;     int    POPALL_INT
;;     ret
;; ;*****************************************************************************


