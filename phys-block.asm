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
;; Load physical LBA block.
;*****************************************************************************
physical_lba_lw			dw 0x0000
physical_lba_uw			dw 0x0000
;*****************************************************************************
load_physical_lba_block:
    ;; right now, just a lame test.
    mov    r1, 0x0080
    mov    r9, send_buffer
@@:
    mov    w[r9++], w[physical_lba_lw]
    mov    w[r9++], w[physical_lba_uw]
    dec    r1
    jnz    @b
    ret
;*****************************************************************************
