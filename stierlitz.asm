;; /**************************************************************************
;;  *                                                                        *
;;  *                               "Stierlitz"                              *
;;  *                     Bus Munger as USB Mass Storage                     *
;;  *                                                                        *
;;  *************************************************************************/

;;  /*************************************************************************
;;  *                (c) Copyright 2012 Stanislav Datskovskiy                *
;;  *                         http://www.loper-os.org                        *
;;  **************************************************************************
;;  *                                                                        *
;;  *  This program is free software: you can redistribute it and/or modify  *
;;  *  it under the terms of the GNU General Public License as published by  *
;;  *  the Free Software Foundation, either version 3 of the License, or     *
;;  *  (at your option) any later version.                                   *
;;  *                                                                        *
;;  *  This program is distributed in the hope that it will be useful,       *
;;  *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
;;  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
;;  *  GNU General Public License for more details.                          *
;;  *                                                                        *
;;  *  You should have received a copy of the GNU General Public License     *
;;  *  along with this program.  If not, see <http://www.gnu.org/licenses/>. *
;;  *                                                                        *
;;  *************************************************************************/

;;  /*************************************************************************
;;  *     "We are what we pretend to be, so we must be careful about what    *
;;  *      we pretend to be." (K. Vonnegut, "Mother Night")                  *
;;  *************************************************************************/

;*****************************************************************************
include knobs.asm
;*****************************************************************************

ORIGIN equ 0x500

.xlist
    include cypress/67300.inc
    ;; include lcp_cmd.inc
    ;; include lcp_data.inc
    include storage.asm
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



include debug.asm ;; RS-232 Debugger


;; TODO: enable watchdog timer?

;*****************************************************************************
;*****************************************************************************

;*****************************************************************************
;; Set up BIOS hooks.
;*****************************************************************************
init_code:
    call   dbg_enable ; Enable RS-232 Debug Port.

    call   insert_vectors ; Overwrite stock ISRs

    call   print_newline
    mov	   r0, 0x002A		; *
    call   dbg_putchar

    ;; init:
    xor    r1, r1		; full speed
    mov    r2, 2		; SIE2
    int    SUSB_INIT_INT

    ;; enable idler:
    mov    b[main_enable], 0x00 ; we want to enable self when configured
    mov    [(IDLER_INT*2)], aux_idler
    ret
;*****************************************************************************


;*****************************************************************************
;; Main Loop
;*****************************************************************************
aux_idler:
    addi   r15, 2
    cmp    b[main_lock], 0x00
    jne    @f
    mov    b[main_lock], 1
    call   main_idler
    mov    b[main_lock], 0
@@:
    int    IDLER_INT
;*****************************************************************************


;*****************************************************************************
main_enable			dw 0x0000
main_lock			dw 0x0000
align 2
;*****************************************************************************
main_idler:
    call   bios_idle
    cmp    b[main_enable], 0 	; global enable toggled by delta_config
    je     main_idler		; if disabled, skip MSC routines
    call   usb_host_to_dev_handler ; handle any input from host
    call   usb_dev_to_host_handler ; handle any output to host
    jmp    main_idler
;*****************************************************************************


align 2
;*****************************************************************************
include usbstd.asm
include usb-bulk.asm
include msc.asm
include util.asm
include scsi-data.asm
include scsi-cmd.asm
include block.asm
include scsi-state.asm
include descriptor.asm
include fat16.asm
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
