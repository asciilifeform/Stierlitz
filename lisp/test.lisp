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

;; mount -o sync,uid=1000,gid=1002 /dev/sdb1 /mnt/usb/

(require 'sb-posix)

(defconstant +O_DIRECT+ #x4000)

(defun open-stierlitz-image (pathname)
  "Open Stierlitz image using sb-unix with blocking I/O."
  (multiple-value-bind (fd errno)
      (sb-unix:unix-open pathname
			 (logior sb-posix:o-rdwr
				 sb-posix:o-sync
				 +O_DIRECT+)
			 0)
    (unless fd
      (error "Could not open Stierlitz image: ~A!~%Errno: ~a~%"
	     pathname (sb-int:strerror errno)))
    (sb-sys:make-fd-stream fd
    			   :input t
    			   :output t
    			   :element-type '(unsigned-byte 8)
    			   :buffering :none
    			   :pathname (make-pathname :name pathname))))

(defvar *stierlitz* (open-stierlitz-image "/mnt/usb/LOPERIMG.BIN"))


(defun stierlitz-seek (pos)
  (file-position *stierlitz* pos))


(let ((buf (make-array 512 :element-type '(unsigned-byte 8))))
  (stierlitz-seek 512)
  (read-sequence buf *stierlitz*)
  buf)


(let ((buf (make-array 512 :element-type '(unsigned-byte 8) :initial-element #xAA)))
  (stierlitz-seek 512)
  (write-sequence buf *stierlitz*)
  buf)


(close *stierlitz*)
