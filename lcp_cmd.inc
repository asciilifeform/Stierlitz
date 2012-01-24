#ifndef __Generatedlcp_cmd_
__Generatedlcp_cmd_ equ 1

;
; This assembly include file is machine generated as part of CDS.
;
; DO NOT EDIT!
;
; Generated on 09/03/2003, 11:24:56
; by program "..\tools\cds2inc" version 1.15 Beta
; from source file "cds.inc\lcp_cmd.cds".
;
;

;***********************************************************
; LCP COMMUNICATION EQUATES - Common for HPI, HSS and SPI   
;***********************************************************
; THESE DEFINITIONS DEFINE THE LYBERTY CONTROL PROTOCOL (LCP)

; ====== HOST TO LYBERTY PORT COMMAND EQUATES ======
; -- CMDs common to all ports --
COMM_RESET                                         equ 0xfa50
COMM_JUMP2CODE                                     equ 0xce00 ; CE = CMD Equate
COMM_EXEC_INT                                      equ 0xce01
COMM_READ_CTRL_REG                                 equ 0xce02
COMM_WRITE_CTRL_REG                                equ 0xce03
COMM_CALL_CODE                                     equ 0xce04
COMM_READ_XMEM                                     equ 0xce05 ; Can access IRAM too but uses a small buffer
COMM_WRITE_XMEM                                    equ 0xce06 ;   compared to READ_MEM and WRITE_MEM
COMM_CONFIG                                        equ 0xce07 ; Uses COMM_BAUD_RATE to change HSS BaudRate etc

; -- CMDs for HSS and SPI  --
COMM_READ_MEM                                      equ 0xce08 ; Addr and Len sent as part of CMD  packet 
COMM_WRITE_MEM                                     equ 0xce09 ; Addr and Len sent as part of CMD packet 

; ====== LYBERTY TO HOST RESPONSE AND COMMAND EQUATES ======
; ----- Response Equates should Use 0xCxxx, 0xDxxx, 0xExxx, 0xFxxx ---
; General Responses
COMM_ACK                                           equ 0x0fed ; I ate it just fine.
COMM_NAK                                           equ 0xdead ; Sorry I'm not feeling well.
COMM_ASYNC                                         equ 0xf00d ; Async message


; Message for SIE1 and SIE2 in register 0x144 and 0x148
SUSB_EP0_MSG                                       equ 0x0001
SUSB_EP1_MSG                                       equ 0x0002
SUSB_EP2_MSG                                       equ 0x0004
SUSB_EP3_MSG                                       equ 0x0008
SUSB_EP4_MSG                                       equ 0x0010
SUSB_EP5_MSG                                       equ 0x0020
SUSB_EP6_MSG                                       equ 0x0040
SUSB_EP7_MSG                                       equ 0x0080
SUSB_RST_MSG                                       equ 0x0100
SUSB_SOF_MSG                                       equ 0x0200
SUSB_CFG_MSG                                       equ 0x0400 ; send these flags to external processor
SUSB_SUS_MSG                                       equ 0x0800
SUSB_VBUS_MSG                                      equ 0x8000
SUSB_ID_MSG                                        equ 0x4000

; ----- Commands To Host (HPI Only) ----- (use -0x00xx - 0x0Fxx) where top byte is Port Num)
; new bit map for Host in both register 0x144 and 0x148
HUSB_TDListDone                                    equ 0x1000 ;TDListDone message

; Sharing bits
HUSB_SOF                                           equ 0x2000 ;SOF message
HUSB_ARMV                                          equ 0x0001 ;Device Remove message
HUSB_AINS_FS                                       equ 0x0002 ;Full Speed Device Insert message
HUSB_AINS_LS                                       equ 0x0004 ;Low Speed Device Insert message
HUSB_AWakeUp                                       equ 0x0008 ;WakeUp message
HUSB_BRMV                                          equ 0x0010 ;Device Remove message
HUSB_BINS_FS                                       equ 0x0020 ;Full Speed Device Insert message
HUSB_BINS_LS                                       equ 0x0040 ;Low Speed Device Insert message
HUSB_BWakeUp                                       equ 0x0080 ;WakeUp message


#endif
