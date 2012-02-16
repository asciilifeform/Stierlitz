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
