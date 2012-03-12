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

(defpackage #:lcdtest
  (:documentation "LCD test using Stierlitz")
  (:use :cl :stierlitz)
  (:export))

(in-package #:lcdtest)

(stierlitz-start)

(defun lcd-data-out (data)
  (with-stierlitz-block-write 0
    (setf (aref *stierlitz-buffer* 0) data)))

(defun lcd-write-nibble (data rs)
  "Send a nibble to the LCD module."
  (let ((dout
	 (logior
	  (logand data #b00001111)
	  (if rs #b10000000 0))))
    (sleep 0.001) ;; Must delay as per the LCD spec
    (lcd-data-out dout)))

(defun lcd-write (byte rs)
  "Send command or data byte to the LCD module."
  (let* ((upper-nibble (logand (ash byte -4) #xF))
	 (lower-nibble (logand byte #xf)))
    (lcd-write-nibble upper-nibble rs)
    (lcd-write-nibble lower-nibble rs)))

(defun lcd-write-char (char)
  "Write a character to the LCD module."
  (lcd-write (char-code char) t))

(defun lcd-write-cmd (cmd)
  "Write a command to the LCD module."
  (lcd-write cmd nil))

(defun lcd-init ()
  (lcd-write #b0010 nil) ;; Enable 4-bit mode
  (lcd-write-cmd #b00101000) ;; Function Set
  (lcd-write-cmd #b00001100) ;; Display on, cursor and blink off
  (lcd-write-cmd #b00000110) ;; Entry mode set
  (lcd-write-cmd #x01)) ;; Clear LCD


(lcd-init) ;; Initialize LCD module.

;; Write some text using the memory-mapped port
(loop for c across "www.loper-os.org" do
     (lcd-write-char c))

(stierlitz-stop)
