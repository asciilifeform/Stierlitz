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
;; Spin until host reads HPI
;*****************************************************************************
;; TODO: timeouts
wait_for_hpi_read:
@@:
    cmp    b[hpi_was_read], 0x01
    jne    @b
    mov    b[hpi_was_read], 0x00
    ret
;*****************************************************************************


;*****************************************************************************
;; Spin until host writes HPI
;*****************************************************************************
;; TODO: timeouts
wait_for_hpi_written:
@@:
    cmp    b[hpi_was_written], 0x01
    jne    @b
    mov    b[hpi_was_written], 0x00
    ret
;*****************************************************************************


;*****************************************************************************
;; Send r0 to HPI port, synchronously
;*****************************************************************************
hpi_mb_tx:
    mov    w[HPI_MAILBOX_REG], r0
    call   wait_for_hpi_read
    ret
;*****************************************************************************


;*****************************************************************************
;; Receive r0 from HPI port, synchronously
;*****************************************************************************
hpi_mb_rx:
    call   wait_for_hpi_written
    mov    r0, w[HPI_MAILBOX_REG]
    ret
;*****************************************************************************
