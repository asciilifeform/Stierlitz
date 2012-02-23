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
; EZ-Host/EZ-OTG device descriptor
;*****************************************************************************
dev_desc:
      db 0x12       ; bLength
      db 0x01       ; bDescriptorType
      dw USB_VER    ; bcdUSB
      db 0x00       ; bDeviceClass
      db 0x00       ; bDeviceSubClass
      db 0x00       ; bDeviceProtocol
      db 0x40       ; bMaxPacketSize0
      dw VENDOR_ID  ; idVendor
      dw PRODUCT_ID ; idProduct
      dw FW_REV     ; bcdDevice
      db 1          ; iManufacturer (index of manufacture string)
      db 2          ; iProduct (index of product string)
      db 3          ; iSerialNumber (index of serial number string)
      db 1          ; bNumConfigurations (number of configurations)
;****************************************************************
; EZ-Host/EZ-OTG configuration descriptor
;****************************************************************
conf_desc:
bLength             equ ($-conf_desc)
      db 9          ; len of config
bDescriptorType     equ ($-conf_desc)
      db 2          ; type of config
wTotalLength        equ ($-conf_desc)
      dw (end_all-conf_desc)
bNumInterfaces      equ ($-conf_desc)
      db 1          ; one interface
bConfigurationValue equ ($-conf_desc)
      db 1          ; config #1
iConfiguration      equ ($-conf_desc)
      db 0          ; index of string describing config
bmAttributes        equ ($-conf_desc)
      db 0x80       ; attributes (self powered)
MaxPower            equ ($-conf_desc)
      db 50
;****************************************************************
; Interface Descriptor
;****************************************************************
interface_desc:
      db 9
      db 4
bInterfaceNumber    equ ($-interface_desc)
      db 0          ; base #
bAlternateSetting   equ ($-interface_desc)
      db 0          ; alt
bNumEndpoints       equ ($-interface_desc)
      db 2          ; 2 endpoints
bInterfaceClass     equ ($-interface_desc)
      db 0x08       ; interface class (Mass Storage)
bInterfaceSubClass  equ ($-interface_desc)
      db 0x06       ; subclass (SCSI)
bInterfaceProtocol  equ ($-interface_desc)
      db 0x50       ; interface proto (Bulk-Only Transport)
iInterface          equ ($-interface_desc)
      db 0          ; index of string describing interface
INTERFACE_DESC_LEN equ ($-interface_desc)
;****************************************************************
; EZ-Host/EZ-OTG endpoints descriptor
;****************************************************************
;; --------------------------------------------------
ep1:  db 0x07       ; len
      db 0x05       ; type (endpoint)
      db EP_IN_ADDR ; bEndpointAddress (EP 1 IN)
      db 0x02	    ; bmAttributes = Bulk
      dw USB_PACKET_SIZE ; packet size = 64 bytes
      db EP_IN_BINTERVAL ; bInterval
;; --------------------------------------------------
ep2:  db 0x07       ; len
      db 0x05       ; type (endpoint)
      db EP_OUT_ADDR ; bEndpointAddress (EP 2 OUT)
      db 0x02       ; bmAttributes = Bulk
      dw USB_PACKET_SIZE ; packet size = 64 bytes
      db EP_OUT_BINTERVAL ; bInterval
;; --------------------------------------------------
end_all:
      align 2
;================================================
; String: Require the string must be align 2
;================================================
;;-----------------------------------------------
string_desc:
      db STR0_LEN
      db 3
      dw 0x409     ; language id = English
STR0_LEN equ ($-string_desc)
;;-----------------------------------------------
str1:
      db STR1_LEN
      db 3
      dw 'Loper OS'
STR1_LEN equ ($-str1)
;;-----------------------------------------------
str2: db STR2_LEN
      db 3
      dw 'Stierlitz'
STR2_LEN equ ($-str2)
;;-----------------------------------------------
str3: db STR3_LEN
      db 3
      dw '300'
STR3_LEN equ ($-str3)
;;-----------------------------------------------
      align 2
