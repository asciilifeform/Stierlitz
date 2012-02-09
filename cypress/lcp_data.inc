#ifndef __Generatedlcp_data_
__Generatedlcp_data_ equ 1

;
; This assembly include file is machine generated as part of CDS.
;
; DO NOT EDIT!
;
; Generated on 09/03/2003, 11:24:56
; by program "..\tools\cds2inc" version 1.15 Beta
; from source file "cds.inc\lcp_data.cds".
;
;

;***********************************************************
; EZ-Host/EZ-OTG Data Pointers for Common Data Area
;***********************************************************

_start_of_comm                                     equ 0x019a
lcp_table                                          equ 0x019a ; COMM_TRANSPORT
spi_mode                                           equ 0x019c
lcp_sema                                           equ 0x019e ; lcp_semaphore
lcp_chain                                          equ 0x01a0 ; chain for lcp idle loop
lcp_rsp                                            equ 0x01a2 ; CommConfig: location 0x1a4-0x1ae are free

; -----Memory adress for send the TD list pointer and Semaphore in USB HOST
HUSB_SIE1_pCurrentTDPtr                            equ 0x01b0 ; Address to SIE1 current TD pointer
HUSB_SIE2_pCurrentTDPtr                            equ 0x01b2 ; Address to SIE2 current TD pointer
HUSB_pEOT                                          equ 0x01b4 ; Address to End Of Transfer 
HUSB_SIE1_pTDListDone_Sem                          equ 0x01b6 ; Address to SIE1 TD List Done semaphore
HUSB_SIE2_pTDListDone_Sem                          equ 0x01b8 ; Address to SIE2 TD List Done semaphore


; ===== CMD DATA AREA - UNION for ALL COMMANDS ============  
; --- 8 byte HSS/SPI FIFO Data goes in here ---
COMM_PORT_CMD                                      equ 0x01ba
COMM_PORT_DATA                                     equ 0x01bc ; Generic Ptr to CMD data in HSS FIFO

; -- DATA UNION FOR SIMPLE PORT CMDS --
COMM_MEM_ADDR                                      equ 0x01bc ; -- For COMM_RD/WR_MEM
COMM_MEM_LEN                                       equ 0x01be ; -- For COMM_RD/WR_MEM
COMM_LAST_DATA                                     equ 0x01c0 ; -- UNUSED but HSS FiFo can handle this last data

COMM_CTRL_REG_ADDR                                 equ 0x01bc ; -- For COMM_RD/WR_CTRL_REG
COMM_CTRL_REG_DATA                                 equ 0x01be ; -- For COMM_RD/WR_CTRL_REG
COMM_CTRL_REG_LOGIC                                equ 0x01c0 ; -- User to AND/OR Reg
REG_WRITE_FLG                                      equ 0x0000
REG_AND_FLG                                        equ 0x0001
REG_OR_FLG                                         equ 0x0002

COMM_BAUD_RATE                                     equ 0x01bc ; -- For COMM_SET_BAUD in scalar units for the given I/F
COMM_TIMEOUT                                       equ 0x01be ; -- For using Timerout on Sending Response to host.
COMM_CODE_ADDR                                     equ 0x01bc ; -- For COMM_CALL_CODE and COMM_JUMP2CODE

; !!! NOTE: For HSS/SPI all of the above are sent in FIFO
;           For HPI done with HW Access.
; --- Register Buffers for EXEC_INT Commands
COMM_INT_NUM                                       equ 0x01c2 ; -- For COMM_EXEC_INT
COMM_R0                                            equ 0x01c4 ; This data struct must be written via MEM_WRITE commands for HSS and SPI
COMM_R1                                            equ 0x01c6
COMM_R2                                            equ 0x01c8
COMM_R3                                            equ 0x01ca
COMM_R4                                            equ 0x01cc
COMM_R5                                            equ 0x01ce
COMM_R6                                            equ 0x01d0
COMM_R7                                            equ 0x01d2
COMM_R8                                            equ 0x01d4
COMM_R9                                            equ 0x01d6
COMM_R10                                           equ 0x01d8
COMM_R11                                           equ 0x01da
COMM_R12                                           equ 0x01dc
COMM_R13                                           equ 0x01de

;=============================================================
; BIOS free memory area: 0x1E0 - 0x1FE

#endif
