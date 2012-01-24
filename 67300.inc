#ifndef __Generated67300_
__Generated67300_ equ 1

;
; This assembly include file is machine generated as part of CDS.
;
; DO NOT EDIT!
;
; Generated on 09/03/2003, 11:24:56
; by program "..\tools\cds2inc" version 1.15 Beta
; from source file "cds.inc\67300.cds".
;
;

;*******************************************************
; FILE        : 63700.H                                 
;*******************************************************
; DESCRIPTION : This file contains the register and     
;               field definitions for the CY7C63700.    
;                                                       
; NOTICE      : This file is provided as-is for         
;               reference purposes only. No warranty is 
;               made as to functionality or suitability 
;               for any particular purpose or           
;               application.                            
;                                                       
; COPYRIGHT 2003, CYPRESS SEMICONDUCTOR CORP.           
;*******************************************************

;*******************************************************
; REGISTER/FIELD NAMING CONVENTIONS                     
;*******************************************************
;                                                       
; Fieldss can be considered either:                     
; (a) BOOLEAN (1 or 0, On or Off, True or False) or     
; (b) BINARY (Numeric value)                            
;                                                       
; Multiple-bit fields contain numeric values only.      
;                                                       
; Boolean fields are identified by the _EN suffix?      
;                                                       
; Binary fields are defined by the field name. In       
; addition, all legal values for the binary field are   
; identified.                                           
;                                                       
; Either ALL register names should include REG as part  
; of the label or NO register names should include REG  
; as part of the label.                                 
;                                                       
; Certain nomenclature is applied universally within    
; this file. Commonly applied abbreviations include:    
;                                                       
;  EN      Enable                                       
;  DIS     Disable                                      
;  SEL     Select                                       
;  FLG     Flag                                         
;  STB     Strobe                                       
;                                                       
;  ADDR    Address                                      
;  CTL     Control                                      
;  CNTRL   Control                                      
;  CFG     Config                                       
;  RST     Reset                                        
;  BFR     Buffer                                       
;  REG     Register                                     
;  SIE     Serial Interface Engine                      
;  DEV     Device                                       
;  HOST    Host                                         
;  EP      Endpoint                                     
;  IRQ     Interrupt                                    
;  BKPT    Breakpoint                                   
;  STAT    Status                                       
;  CNT     Count                                        
;  CTR     Counter                                      
;  TMR     Timer                                        
;  MAX     Maximum                                      
;  MIN     Minimum                                      
;  POL     Polarity                                     
;  BLK     Block                                        
;  WDT     Watchdog Timer                               
;  RX      Receive                                      
;  RXD     Received                                     
;  TX      Transmit                                     
;  TXD     Transmitted                                  
;  ACK     Acknowledge                                  
;  ACKD    Acknowledged                                 
;  MBX     Mailbox                                      
;  CLR     Clear                                        
;  bm      Bit Mask  (prefix)                           
;  XRAM    External RAM                                 
;                                                       
;*******************************************************

;*******************************************************
;*******************************************************
; CPU REGISTERS                                         
;*******************************************************
;*******************************************************

;*******************************************************
; CPU FLAGS REGISTER [R]                                
;*******************************************************
CPU_FLAGS_REG                                      equ 0xc000 ; CPU Flags Register [R]
flags                                              equ 0xc000

; FIELDS 

GLOBAL_IRQ_EN                                      equ 0x0010 ; Global Interrupt Enable
NEG_FLG                                            equ 0x0008 ; Negative Sign Flag
OVF_FLG                                            equ 0x0004 ; Overflow Flag
CARRY_FLG                                          equ 0x0002 ; Carry/Borrow Flag
ZER0_FLG                                           equ 0x0001 ; Zero Flag

;*******************************************************
; BANK REGISTER [R/W]                                   
;*******************************************************

BANK_REG                                           equ 0xc002 ; Bank Register [R/W]
regbuf                                             equ 0xc002 ; alias for BIOS code
BANK                                               equ 0xffe0 ; Bank

;*******************************************************
; HARDWARE REVISION REGISTER [R]                        
;*******************************************************
; First Silicon Revision is 0x0101. Revision number     
; will be incremented by one for each revision change.  
;*******************************************************

HW_REV_REG                                         equ 0xc004 ; Hardware Revision Register [R]

;*******************************************************
; INTERRUPT ENABLE REGISTER [R/W]                       
;*******************************************************

IRQ_EN_REG                                         equ 0xc00e ; Interrupt Enable Register [R/W]
intenb                                             equ 0xc00e ; Alias for BIOS code
INT_EN_REG                                         equ 0xc00e ; BIOS Interrupt Enable Register Alias

; FIELDS 
OTG_IRQ_EN                                         equ 0x1000 ; OTG Interrupt Enable
SPI_IRQ_EN                                         equ 0x0800 ; SPI Interrupt Enable
HOST2_IRQ_EN                                       equ 0x0200 ; Host 2 Interrupt Enable
DEV2_IRQ_EN                                        equ 0x0200 ; Device 2 Interrupt Enable
HOST1_IRQ_EN                                       equ 0x0100 ; Host 1 Interrupt Enable
DEV1_IRQ_EN                                        equ 0x0100 ; Device 1 Interrupt Enable
HSS_IRQ_EN                                         equ 0x0080 ; HSS Interrupt Enable
IN_MBX_IRQ_EN                                      equ 0x0040 ; In Mailbox Interrupt Enable
OUT_MBX_IRQ_EN                                     equ 0x0020 ; Out Mailbox Interrupt Enable
DMA_IRQ_EN                                         equ 0x0010 ; DMA Interrupt Enable
UART_IRQ_EN                                        equ 0x0008 ; UART Interrupt Enable
GPIO_IRQ_EN                                        equ 0x0004 ; GPIO Interrupt Enable
TMR1_IRQ_EN                                        equ 0x0002 ; Timer 1 Interrupt Enable
TMR0_IRQ_EN                                        equ 0x0001 ; Timer 0 Interrupt Enable

;  Alias bit mask definition for register IRQ_EN_REG 
bmINT_EN_TM0                                       equ 0x0001
bmINT_EN_TM1                                       equ 0x0002
bmINT_EN_GPIO                                      equ 0x0004
bmINT_EN_UART                                      equ 0x0008
bmINT_EN_DMA                                       equ 0x0010
bmINT_EN_MBX_OUT                                   equ 0x0020
bmINT_EN_MBX_IN                                    equ 0x0040
bmINT_EN_HSP                                       equ 0x0080
bmINT_EN_SIE1                                      equ 0x0100
bmINT_EN_SIE2                                      equ 0x0200
bmINT_EN_SPI                                       equ 0x0800
bmINT_EN_OTG                                       equ 0x1000

; another define from sys_memmap
GIO_IntCtl_MSK                                     equ 0x0000
GIO_IntCtl_IRQ0En_BIT                              equ 0x0000
GIO_IntCtl_IRQ0En_BM                               equ 0x0001
GIO_IntCtl_IRQ0Pol_BIT                             equ 0x0001
GIO_IntCtl_IRQ0Pol_BM                              equ 0x0002
GIO_IntCtl_IRQ1En_BIT                              equ 0x0002
GIO_IntCtl_IRQ1En_BM                               equ 0x0004
GIO_IntCtl_IRQ1Pol_BIT                             equ 0x0003
GIO_IntCtl_IRQ1Pol_BM                              equ 0x0008
GIO_IntCtl_SX_BIT                                  equ 0x0004
GIO_IntCtl_SX_BM                                   equ 0x0010
GIO_IntCtl_SG_BIT                                  equ 0x0005
GIO_IntCtl_SG_BM                                   equ 0x0020
GIO_IntCtl_HX_BIT                                  equ 0x0006
GIO_IntCtl_HX_BM                                   equ 0x0040
GIO_IntCtl_HG_BIT                                  equ 0x0007
GIO_IntCtl_HG_BM                                   equ 0x0080

GIO_IntCtl_Mode_POS                                equ 0x0008
GIO_IntCtl_Mode_SIZ                                equ 0x0003
GIO_IntCtl_Mode_GPIO                               equ 0x0000
GIO_IntCtl_Mode_GPIObm                             equ 0x0000
GIO_IntCtl_Mode_Flash                              equ 0x0001
GIO_IntCtl_Mode_Flashbm                            equ 0x0100
GIO_IntCtl_Mode_EPP                                equ 0x0002
GIO_IntCtl_Mode_EPPbm                              equ 0x0200
GIO_IntCtl_Mode_SLV                                equ 0x0003
GIO_IntCtl_Mode_SLVbm                              equ 0x0300
GIO_IntCtl_Mode_IDE                                equ 0x0004
GIO_IntCtl_Mode_IDEbm                              equ 0x0400
GIO_IntCtl_Mode_HPI                                equ 0x0005
GIO_IntCtl_Mode_HPIbm                              equ 0x0500
GIO_IntCtl_Mode_SCAN                               equ 0x0006
GIO_IntCtl_Mode_SCANbm                             equ 0x0600
GIO_IntCtl_Mode_MDiag                              equ 0x0007
GIO_IntCtl_Mode_MDiagbm                            equ 0x0700

GIO_IntCtl_Bond_POS                                equ 0x000b
GIO_IntCtl_Bond_SIZ                                equ 0x0002
GIO_IntCtl_Bond_Embed                              equ 0x0000
GIO_IntCtl_Bond_Embedbm                            equ 0x0000
GIO_IntCtl_Bond_Flash                              equ 0x0001
GIO_IntCtl_Bond_Flashbm                            equ 0x0800
GIO_IntCtl_Bond_Mobile                             equ 0x0002
GIO_IntCtl_Bond_Mobilebm                           equ 0x1000

GIO_IntCtl_MD_BIT                                  equ 0x000f
INT_Enable_T0_BIT                                  equ 0x0000
INT_Enable_T0_BM                                   equ 0x0001
INT_Enable_T1_BIT                                  equ 0x0001
INT_Enable_T1_BM                                   equ 0x0002
INT_Enable_GP_BIT                                  equ 0x0002
INT_Enable_GP_BM                                   equ 0x0004
INT_Enable_UART_BIT                                equ 0x0003
INT_Enable_UART_BM                                 equ 0x0008
INT_Enable_FDMA_BIT                                equ 0x0004
INT_Enable_FDMA_BM                                 equ 0x0010
INT_Enable_MBX_BIT                                 equ 0x0006
INT_Enable_MBX_BM                                  equ 0x0040
INT_Enable_HSS_BIT                                 equ 0x0007
INT_Enable_HSS_BM                                  equ 0x0080
INT_Enable_SIE1_BIT                                equ 0x0008
INT_Enable_SIE1_BM                                 equ 0x0100
INT_Enable_SIE2_BIT                                equ 0x0009
INT_Enable_SIE2_BM                                 equ 0x0200
INT_Enable_SPI_BIT                                 equ 0x000b
INT_Enable_SPI_BM                                  equ 0x0800

;*******************************************************
; CPU SPEED REGISTER [R/W]                              
;*******************************************************

CPU_SPEED_REG                                      equ 0xc008 ; CPU Speed Register [R/W]
P_SPEED                                            equ 0xc008 ; Alias for BIOS code

; CPU SPEED REGISTER FIELDS 
;** The Speed field in the CPU Speed Register provides a mechanism to
;** divide the external clock signal down to operate the CPU at a lower 
;** clock speed (presumedly for lower-power operation). The value loaded 
;** into this field is a divisor and is calculated as (n+1). For instance, 
;** if 3 is loaded into the field, the resulting CPU speed will be PCLK/4.
;

CPU_SPEED                                          equ 0x000f ; CPU Speed

;*******************************************************
; POWER CONTROL REGISTER [R/W]                          
;*******************************************************

POWER_CTL_REG                                      equ 0xc00a ; Power Control Register [R/W]

; FIELDS 

HOST2_WAKE_EN                                      equ 0x4000 ; Host 2 Wake Enable
DEV2_WAKE_EN                                       equ 0x4000 ; Device 2 Wake Enable
HOST1_WAKE_EN                                      equ 0x1000 ; Host 1 Wake Enable
DEV1_WAKE_EN                                       equ 0x1000 ; Device 1 Wake Enable
OTG_WAKE_EN                                        equ 0x0800 ; OTG Wake Enable 
HSS_WAKE_EN                                        equ 0x0200 ; HSS Wake Enable 
SPI_WAKE_EN                                        equ 0x0100 ; SPI Wake Enable 
HPI_WAKE_EN                                        equ 0x0080 ; HPI Wake Enable 
GPIO_WAKE_EN                                       equ 0x0010 ; GPIO Wake Enable 
SLEEP_EN                                           equ 0x0002 ; Sleep Enable
HALT_EN                                            equ 0x0001 ; Halt Enable

;*******************************************************
; BREAKPOINT REGISTER [R/W]                             
;*******************************************************

BKPT_REG                                           equ 0xc014 ; Breakpoint Register [R/W]

;*******************************************************
; USB DIAGNOSTIC REGISTER [W]                           
;*******************************************************

USB_DIAG_REG                                       equ 0xc03c ; USB Diagnostic Register [R/W]

; FIELDS 

c2B_DIAG_EN                                        equ 0x8000 ; Port 2B Diagnostic Enable
c2A_DIAG_EN                                        equ 0x4000 ; Port 2A Diagnostic Enable
c1B_DIAG_EN                                        equ 0x2000 ; Port 1B Diagnostic Enable
c1A_DIAG_EN                                        equ 0x1000 ; Port 1A Diagnostic Enable
PULLDOWN_EN                                        equ 0x0040 ; Pull-down resistors enable
LS_PULLUP_EN                                       equ 0x0020 ; Low-speed pull-up resistor enable
FS_PULLUP_EN                                       equ 0x0010 ; Full-speed pull-up resistor enable
FORCE_SEL                                          equ 0x0007 ; Control D+/- lines

; FORCE FIELD VALUES 

ASSERT_SE0                                         equ 0x0004 ; Assert SE0 on selected ports
TOGGLE_JK                                          equ 0x0002 ; Toggle JK state on selected ports
ASSERT_J                                           equ 0x0001 ; Assert J state on selected ports
ASSERT_K                                           equ 0x0000 ; Assert K state on selected ports

;*******************************************************
; MEMORY DIAGNOSTIC REGISTER [W]                        
;*******************************************************
MEM_DIAG_REG                                       equ 0xc03e ; Memory Diagnostic Register [W]

; FIELDS 
FAST_REFRESH_EN                                    equ 0x8000 ; Fast Refresh Enable (15x acceleration)
MEM_ARB_SEL                                        equ 0x0700 ; Memory Arbitration
MONITOR_EN                                         equ 0x0001 ; Monitor Enable (Echoes internal address bus externally)

; MEMORY ARBITRATION SELECT FIELD VALUES 
MEM_ARB_7                                          equ 0x0700 ; Number of dead cycles out of 8 possible
MEM_ARB_6                                          equ 0x0600 ; Should not use any cycle >= 6
MEM_ARB_5                                          equ 0x0500 ; 
MEM_ARB_4                                          equ 0x0400 ;
MEM_ARB_3                                          equ 0x0300 ;
MEM_ARB_2                                          equ 0x0200 ;
MEM_ARB_1                                          equ 0x0100 ; 
MEM_ARB_0                                          equ 0x0000 ; Power up default

;*******************************************************
; EXTENDED PAGE n MAP REGISTER [R/W]                    
;*******************************************************
PG1_MAP_REG                                        equ 0xc018 ; Page 1 Map Register [R/W]
PG2_MAP_REG                                        equ 0xc01a ; Page 2 Map Register [R/W]

;*******************************************************
; DRAM CONTROL REGISTER [R/W]                           
;*******************************************************
DRAM_CTL_REG                                       equ 0xc038 ; DRAM Control Register [R/W]

; FIELDS 
DRAM_DIS                                           equ 0x0008 ; DRAM Disable
TURBO_EN                                           equ 0x0004 ; Turbo Mode
PAGE_MODE_EN                                       equ 0x0002 ; Page Mode
REFRESH_EN                                         equ 0x0001 ; Refresh 

;*******************************************************
; EXTERNAL MEMORY CONTROL REGISTER [R/W]                
;*******************************************************

XMEM_CTL_REG                                       equ 0xc03a ; External Memory Control Register [R/W]
X_MEM_CNTRL                                        equ 0xc03a ; Alias for BIOS code

XRAM_BEGIN                                         equ 0x4000 ; External SRAM begin
XROM_BEGIN                                         equ 0xc100 ; External ROM Begin
IROM_BEGIN                                         equ 0xe000 ; Internal ROM Begin


; FIELDS 
XRAM_MERGE_EN                                      equ 0x2000 ; Overlay XRAMSEL w/ XMEMSEL
XROM_MERGE_EN                                      equ 0x1000 ; Overlay XROMSEL w/ XMEMSEL
XMEM_WIDTH_SEL                                     equ 0x0800 ; External MEM Width Select
XMEM_WAIT_SEL                                      equ 0x0700 ; Number of Extended Memory wait states (0-7)
XROM_WIDTH_SEL                                     equ 0x0080 ; External ROM Width Select
XROM_WAIT_SEL                                      equ 0x0070 ; Number of External ROM wait states (0-7)
XRAM_WIDTH_SEL                                     equ 0x0008 ; External RAM Width Select
XRAM_WAIT_SEL                                      equ 0x0007 ; Number of External RAM wait states (0-7)

; XMEM_WIDTH FIELD VALUES 
XMEM_8                                             equ 0x0800 ; 
XMEM_16                                            equ 0x0000 ; 

; XRAM_WIDTH FIELD VALUES 

XROM_8                                             equ 0x0080 ; 
XROM_16                                            equ 0x0000 ; 

; XRAM_WIDTH FIELD VALUES 

XRAM_8                                             equ 0x0008 ; 
XRAM_16                                            equ 0x0000 ; 

;*******************************************************
; WATCHDOG TIMER REGISTER [R/W]                         
;*******************************************************
WDT_REG                                            equ 0xc00c ; Watchdog Timer Register [R/W]

; FIELDS 
WDT_TIMEOUT_FLG                                    equ 0x0020 ; WDT timeout flag
WDT_PERIOD_SEL                                     equ 0x0018 ; WDT period select (options below)
WDT_LOCK_EN                                        equ 0x0004 ; WDT enable
WDT_EN                                             equ 0x0002 ; WDT lock enable
WDT_RST_STB                                        equ 0x0001 ; WDT reset Strobe

; WATCHDOG PERIOD FIELD VALUES 

WDT_64MS                                           equ 0x0003 ; 64.38 ms
WDT_21MS                                           equ 0x0002 ; 21.68 ms
WDT_5MS                                            equ 0x0001 ; 5.67 ms
WDT_1MS                                            equ 0x0000 ; 1.67 ms

;*******************************************************
; TIMER n REGISTER [R/W]                                
;*******************************************************

TMR0_REG                                           equ 0xc010 ; Timer 0 Register [R/W]
TIMER_0                                            equ 0xc010 ; Alias for BIOS code
TMR1_REG                                           equ 0xc012 ; Timer 1 Register [R/W]
TIMER_1                                            equ 0xc012 ; Alias for BIOS code

;*******************************************************
;*******************************************************
; USB REGISTERS                                         
;*******************************************************
;*******************************************************

;*******************************************************
; USB n CONTROL REGISTERS [R/W]                         
;*******************************************************
USB1_CTL_REG                                       equ 0xc08a ; USB 1 Control Register [R/W]
SIE1_USB_CONTROL                                   equ 0xc08a

USB2_CTL_REG                                       equ 0xc0aa ; USB 2 Control Register [R/W]
SIE2_USB_CONTROL                                   equ 0xc0aa

; FIELDS 
B_DP_STAT                                          equ 0x8000 ; Port B D+ status
B_DM_STAT                                          equ 0x4000 ; Port B D- status
A_DP_STAT                                          equ 0x2000 ; Port A D+ status
A_DM_STAT                                          equ 0x1000 ; Port A D- status
B_SPEED_SEL                                        equ 0x0800 ; Port B Speed select (See below)
A_SPEED_SEL                                        equ 0x0400 ; Port A Speed select (See below)
MODE_SEL                                           equ 0x0200 ; Mode (See below)
B_RES_EN                                           equ 0x0100 ; Port B Resistors enable
A_RES_EN                                           equ 0x0080 ; Port A Resistors enable
B_FORCE_SEL                                        equ 0x0060 ; Port B Force D+/- state (See below)
A_FORCE_SEL                                        equ 0x0018 ; Port A Force D+/- state (See below)
SUSP_EN                                            equ 0x0004 ; Suspend enable
B_SOF_EOP_EN                                       equ 0x0002 ; Port B SOF/EOP enable
A_SOF_EOP_EN                                       equ 0x0001 ; Port A SOF/EOP enable


; USB Control Register1 (0xC08A/0xC0AA) bit mask         
bmHOST_CTL1_SOF0                                   equ 0x0001
bmHOST_CTL1_SOF1                                   equ 0x0002
bmHOST_CTL1_SUSPEND                                equ 0x0004
bmHOST_CTL1_JKState0                               equ 0x0008
bmHOST_CTL1_USBReset0                              equ 0x0010
bmHOST_CTL1_JKState1                               equ 0x0020
bmHOST_CTL1_USBReset1                              equ 0x0040
bmHOST_CTL1_UD0                                    equ 0x0080
bmHOST_CTL1_UD1                                    equ 0x0100
bmHOST_CTL1_HOST                                   equ 0x0200
bmHOST_CTL1_LOA                                    equ 0x0400
bmHOST_CTL1_LOB                                    equ 0x0800
bmHOST_CTL1_D0m                                    equ 0x1000
bmHOST_CTL1_D0p                                    equ 0x2000
bmHOST_CTL1_D1m                                    equ 0x4000
bmHOST_CTL1_D1p                                    equ 0x8000


; MODE FIELD VALUES 
HOST_MODE                                          equ 0x0200 ; Host mode
DEVICE_MODE                                        equ 0x0000 ; Device mode

; p_SPEED SELECT FIELD VALUES 

LOW_SPEED                                          equ 0xffff ; Low speed
FULL_SPEED                                         equ 0x0000 ; Full speed

B_SPEED_LOW                                        equ 0x0800
B_SPEED_FULL                                       equ 0x0000
A_SPEED_LOW                                        equ 0x0400
A_SPEED_FULL                                       equ 0x0000

; FORCEn FIELD VALUES 

FORCE_K                                            equ 0x0078 ; Force K state on associated port
FORCE_SE0                                          equ 0x0050 ; Force SE0 state on associated port
FORCE_J                                            equ 0x0028 ; Force J state on associated port
FORCE_NORMAL                                       equ 0x0000 ; Don't force associated port

A_FORCE_K                                          equ 0x0018 ; Force K state on A port
A_FORCE_SE0                                        equ 0x0010 ; Force SE0 state on associated port
A_FORCE_J                                          equ 0x0008 ; Force J state on associated port
A_FORCE_NORMAL                                     equ 0x0000 ; Don't force associated port

B_FORCE_K                                          equ 0x0060 ; Force K state on associated port
B_FORCE_SE0                                        equ 0x0040 ; Force SE0 state on associated port
B_FORCE_J                                          equ 0x0020 ; Force J state on associated port
B_FORCE_NORMAL                                     equ 0x0000 ; Don't force associated port

;*******************************************************
;*******************************************************
; HOST REGISTERS                                        
;*******************************************************
;*******************************************************

;*******************************************************
; HOST n INTERRUPT ENABLE REGISTER [R/W]                
;*******************************************************

HOST1_IRQ_EN_REG                                   equ 0xc08c ; Host 1 Interrupt Enable Register [R/W]
SIE1_INT_EN_REG                                    equ 0xc08c

HOST2_IRQ_EN_REG                                   equ 0xc0ac ; Host 2 Interrupt Enable Register [R/W]
SIE2_INT_EN_REG                                    equ 0xc0ac

; FIELDS 

VBUS_IRQ_EN                                        equ 0x8000 ; VBUS Interrupt Enable (Available on HOST1 only) 
ID_IRQ_EN                                          equ 0x4000 ; ID Interrupt Enable (Available on HOST1 only)
SOF_EOP_IRQ_EN                                     equ 0x0200 ; SOF/EOP Interrupt Enable 
B_WAKE_IRQ_EN                                      equ 0x0080 ; Port B Wake Interrupt Enable 
A_WAKE_IRQ_EN                                      equ 0x0040 ; Port A Wake Interrupt Enable 
B_CHG_IRQ_EN                                       equ 0x0020 ; Port B Connect Change Interrupt Enable 
A_CHG_IRQ_EN                                       equ 0x0010 ; Port A Connect Change Interrupt Enable 
DONE_IRQ_EN                                        equ 0x0001 ; Done Interrupt Enable 


; Host Interrupt enable (0xC08C/0xC0AC)  bit mask      
bmHOST_INTEN_XFERDONE                              equ 0x0001
bmHOST_INTEN_INSRMV0                               equ 0x0010
bmHOST_INTEN_INSRMV1                               equ 0x0020
bmHOST_INTEN_WAKEUP0                               equ 0x0040
bmHOST_INTEN_WAKEUP1                               equ 0x0080
bmHOST_INTEN_SOFINTR                               equ 0x0200
bmHOST_INTEN_IEXP                                  equ 0x0400
bmHOST_INTEN_OTG_ID                                equ 0x4000
bmHOST_INTEN_OTG_44V                               equ 0x8000



;*******************************************************
; HOST n STATUS REGISTER [R/W]                          
;*******************************************************
; In order to clear status for a particular IRQ bit,    
; write a '1' to that bit location.                     
;*******************************************************
HOST1_STAT_REG                                     equ 0xc090 ; Host 1 Status Register [R/W]
SIE1_INT_STATUS_REG                                equ 0xc090

HOST2_STAT_REG                                     equ 0xc0b0 ; Host 2 Status Register [R/W]
SIE2_INT_STATUS_REG                                equ 0xc0b0

; FIELDS 

VBUS_IRQ_FLG                                       equ 0x8000 ; VBUS Interrupt Request (HOST1 only)
ID_IRQ_FLG                                         equ 0x4000 ; ID Interrupt Request (HOST1 only)

SOF_EOP_IRQ_FLG                                    equ 0x0200 ; SOF/EOP Interrupt Request 
B_WAKE_IRQ_FLG                                     equ 0x0080 ; Port B Wake Interrupt Request 
A_WAKE_IRQ_FLG                                     equ 0x0040 ; Port A Wake Interrupt Request 
B_CHG_IRQ_FLG                                      equ 0x0020 ; Port B Connect Change Interrupt Request 
A_CHG_IRQ_FLG                                      equ 0x0010 ; Port A Connect Change Interrupt Request 
B_SE0_STAT                                         equ 0x0008 ; Port B SE0 status
A_SE0_STAT                                         equ 0x0004 ; Port A SE0 status
DONE_IRQ_FLG                                       equ 0x0001 ; Done Interrupt Request 

; Host interrupt status register (0xC090/0xC0B0) bit mask 
bmHOST_INT_XFERDONE                                equ 0x0001
bmHOST_INT_USBRST0                                 equ 0x0004
bmHOST_INT_USBRST1                                 equ 0x0008
bmHOST_INT_INSRMV0                                 equ 0x0010
bmHOST_INT_INSRMV1                                 equ 0x0020
bmHOST_INT_WAKEUP0                                 equ 0x0040
bmHOST_INT_WAKEUP1                                 equ 0x0080
bmHOST_INT_SOFINTR                                 equ 0x0200
bmHOST_INT_OTG_ID                                  equ 0x4000
bmHOST_INT_OTG_44V                                 equ 0x8000

;*******************************************************
; HOST n CONTROL REGISTERS [R/W]                        
;*******************************************************

HOST1_CTL_REG                                      equ 0xc080 ; Host 1 Control Register [R/W]
SIE1_USB_CTRL_REG0                                 equ 0xc080
SIE1_REG_BASE                                      equ 0xc080 ; Alias for susb.asm


HOST2_CTL_REG                                      equ 0xc0a0 ; Host 2 Control Register [R/W]
SIE2_USB_CTRL_REG0                                 equ 0xc0a0
SIE2_REG_BASE                                      equ 0xc0a0 ; Alias for susb.asm


; FIELDS 
PREAMBLE_EN                                        equ 0x0080 ; Preamble enable
SEQ_SEL                                            equ 0x0040 ; Data Toggle Sequence Bit Select (Write next/read last)
SYNC_EN                                            equ 0x0020 ; (1:Send next packet at SOF/EOP, 0: Send next packet immediately)
ISO_EN                                             equ 0x0010 ; Isochronous enable 
TIMEOUT_SEL                                        equ 0x0008 ; Timeout select (1:22 bit times, 0:18 bit times)
DIR_SEL                                            equ 0x0004 ; Transfer direction (1:OUT, 0:IN)
EN                                                 equ 0x0002 ; Enable operation
ARM_EN                                             equ 0x0001 ; Arm operation
BSY_FLG                                            equ 0x0001 ; Busy flag

; Use in the 0xc080 and 0xc0a0 
bmHOST_HCTL_ARM                                    equ 0x0001
bmHOST_HCTL_ISOCH                                  equ 0x0010
bmHOST_HCTL_AFTERSOF                               equ 0x0020
bmHOST_HCTL_DT                                     equ 0x0040
bmHOST_HCTL_PREAMBLE                               equ 0x0080


;*******************************************************
; HOST n ADDRESS REGISTERS [R/W]                        
;*******************************************************

HOST1_ADDR_REG                                     equ 0xc082 ; Host 1 Address Register [R/W]
SIE1_USB_BASE_ADDR                                 equ 0xc082

HOST2_ADDR_REG                                     equ 0xc0a2 ; Host 2 Address Register [R/W]
SIE2_USB_BASE_ADDR                                 equ 0xc0a2

;*******************************************************
; HOST n COUNT REGISTERS [R/W]                          
;*******************************************************

HOST1_CNT_REG                                      equ 0xc084 ; Host 1 Count Register [R/W]
SIE1_USB_LENGTH                                    equ 0xc084


HOST2_CNT_REG                                      equ 0xc0a4 ; Host 2 Count Register [R/W]
SIE2_USB_LENGTH                                    equ 0xc0a4

; FIELDS 
PORT_SEL                                           equ 0x4000 ; Port Select (1:PortB, 0:PortA)
HOST_CNT                                           equ 0x03ff ; Host Count

; Base Length register (0xC084/0xC0A4)bit mask          
bmHOST_PORT_SEL                                    equ 0x4000

;*******************************************************
; HOST n PID REGISTERS [W]                              
;*******************************************************

HOST1_PID_REG                                      equ 0xc086 ; Host 1 PID Register [W]
SIE1_USB_HOST_PID                                  equ 0xc086
SIE1_USB_ERR_STATUS                                equ 0xc086 ; When read


HOST2_PID_REG                                      equ 0xc0a6 ; Host 2 PID Register [W]
SIE2_USB_HOST_PID                                  equ 0xc0a6
SIE2_USB_ERR_STATUS                                equ 0xc0a6 ; When read

; Packet status register (0xC086/0xC0A6)bit mask       
bmHOST_STATMASK_ACK                                equ 0x0001
bmHOST_STATMASK_ERROR                              equ 0x0002
bmHOST_STATMASK_TMOUT                              equ 0x0004
bmHOST_STATMASK_SEQ                                equ 0x0008
bmHOST_STATMASK_SETUP                              equ 0x0010
bmHOST_STATMASK_OVF                                equ 0x0020
bmHOST_STATMASK_NAK                                equ 0x0040
bmHOST_STATMASK_STALL                              equ 0x0080

; FIELDS 
PID_SEL                                            equ 0x00f0 ; Packet ID (see below)
EP_SEL                                             equ 0x000f ; Endpoint number

; PID FIELD VALUES 
SETUP_PID                                          equ 0x000d ; SETUP
IN_PID                                             equ 0x0009 ; IN
OUT_PID                                            equ 0x0001 ; OUT
SOF_PID                                            equ 0x0005 ; SOF
PRE_PID                                            equ 0x000c ; PRE
NAK_PID                                            equ 0x000a ; NAK
STALL_PID                                          equ 0x000e ; STALL
DATA0_PID                                          equ 0x0003 ; DATA0
DATA1_PID                                          equ 0x000b ; DATA1

;*******************************************************
; LYBERTY HOST Define value                             
;*******************************************************
cPortA                                             equ 0x0000
cPortB                                             equ 0x0001
cPortC                                             equ 0x0002
cPortD                                             equ 0x0003

cPID_SETUP                                         equ 0x000d
cPID_IN                                            equ 0x0009
cPID_OUT                                           equ 0x0001
cPID_SOF                                           equ 0x0005
cPID_PRE                                           equ 0x000c
cPID_NAK                                           equ 0x000a
cPID_STALL                                         equ 0x000e
cPID_DATA0                                         equ 0x0003
cPID_DATA1                                         equ 0x000b
cPID_ACK                                           equ 0x0002

;*******************************************************
; HOST n ENDPOINT STATUS REGISTERS [R]                  
;*******************************************************
HOST1_EP_STAT_REG                                  equ 0xc086 ; Host 1 Endpoint Status Register [R]
HOST2_EP_STAT_REG                                  equ 0xc0a6 ; Host 2 Endpoint Status Register [R]

; FIELDS 
STALL_FLG                                          equ 0x0080 ; Device returned STALL
NAK_FLG                                            equ 0x0040 ; Device returned NAK
OVERFLOW_FLG                                       equ 0x0020 ; Receive overflow
SEQ_STAT                                           equ 0x0008 ; Data Toggle value
TIMEOUT_FLG                                        equ 0x0004 ; Timeout occurred
ERROR_FLG                                          equ 0x0002 ; Error occurred
ACK_FLG                                            equ 0x0001 ; Transfer ACK'd       

;*******************************************************
; HOST n DEVICE ADDRESS REGISTERS [W]                   
;*******************************************************
HOST1_DEV_ADDR_REG                                 equ 0xc088 ; Host 1 Device Address Register [W]
SIE1_USB_HOST_DEV                                  equ 0xc088
SIE1_USB_LEFT_BYTE                                 equ 0xc088 ; When read


HOST2_DEV_ADDR_REG                                 equ 0xc0a8 ; Host 2 Device Address Register [W]
SIE2_USB_HOST_DEV                                  equ 0xc0a8
SIE2_USB_LEFT_BYTE                                 equ 0xc0a8 ; When read


; FIELDS 
DEV_ADDR                                           equ 0x007f ; Device Address

;*******************************************************
; HOST n COUNT RESULT REGISTERS [R]                     
;*******************************************************

HOST1_CTR_REG                                      equ 0xc088 ; Host 1 Counter Register [R]
HOST2_CTR_REG                                      equ 0xc0a8 ; Host 2 Counter Register [R]

; FIELDS

HOST_RESULT                                        equ 0x00ff ; Host Count Result

;*******************************************************
; HOST n SOF/EOP COUNT REGISTER [R/W]                   
;*******************************************************

HOST1_SOF_EOP_CNT_REG                              equ 0xc092 ; Host 1 SOF/EOP Count Register [R/W]
SIE1_USB_SOF_COUNT                                 equ 0xc092

HOST2_SOF_EOP_CNT_REG                              equ 0xc0b2 ; Host 2 SOF/EOP Count Register [R/W]
SIE2_USB_SOF_COUNT                                 equ 0xc0b2

; FIELDS 

SOF_EOP_CNT                                        equ 0x3fff ; SOF/EOP Count

;*******************************************************
; HOST n SOF/EOP COUNTER REGISTER [R]                       
;*******************************************************
HOST1_SOF_EOP_CTR_REG                              equ 0xc094 ; Host 1 SOF/EOP Counter Register [R]
SIE1_USB_SOF_TIMER                                 equ 0xc094


HOST2_SOF_EOP_CTR_REG                              equ 0xc0b4 ; Host 2 SOF/EOP Counter Register [R]
SIE2_USB_SOF_TIMER                                 equ 0xc0b4

; FIELDS 

SOF_EOP_CTR                                        equ 0x3fff ; SOF/EOP Counter

;*******************************************************
; HOST n FRAME REGISTER [R]                             
;*******************************************************

HOST1_FRAME_REG                                    equ 0xc096 ; Host 1 Frame Register [R]
SIE1_USB_FRAME_NO                                  equ 0xc096

HOST2_FRAME_REG                                    equ 0xc0b6 ; Host 2 Frame Register [R]
SIE2_USB_FRAME_NO                                  equ 0xc0b6

; FIELDS 

HOST_FRAME_NUM                                     equ 0x07ff ; Frame


;*******************************************************
;*******************************************************
; DEVICE REGISTERS                                      
;*******************************************************
;*******************************************************

;*******************************************************
; DEVICE n PORT SELECT REGISTERS [R/W]                  
;*******************************************************

DEV1_SEL_REG                                       equ 0xc084 ; Device 1 Port Select Register [R/W]
DEV2_SEL_REG                                       equ 0xc0a4 ; Device 2 Port Select Register [R/W]

; FIELDS 

;*******************************************************
; DEVICE n INTERRUPT ENABLE REGISTER [R/W]              
;*******************************************************

DEV1_IRQ_EN_REG                                    equ 0xc08c ; Device 1 Interrupt Enable Register [R/W]
DEV2_IRQ_EN_REG                                    equ 0xc0ac ; Device 2 Interrupt Enable Register [R/W]

; FIELDS 

; Defined in Host Interrupt Enable Register
WAKE_IRQ_EN                                        equ 0x0400 ; Wake Interrupt Enable 
RST_IRQ_EN                                         equ 0x0100 ; Reset Interrupt Enable 
EP7_IRQ_EN                                         equ 0x0080 ; EP7 Interrupt Enable 
EP6_IRQ_EN                                         equ 0x0040 ; EP6 Interrupt Enable 
EP5_IRQ_EN                                         equ 0x0020 ; EP5 Interrupt Enable 
EP4_IRQ_EN                                         equ 0x0010 ; EP4 Interrupt Enable 
EP3_IRQ_EN                                         equ 0x0008 ; EP3 Interrupt Enable 
EP2_IRQ_EN                                         equ 0x0004 ; EP2 Interrupt Enable 
EP1_IRQ_EN                                         equ 0x0002 ; EP1 Interrupt Enable 
EP0_IRQ_EN                                         equ 0x0001 ; EP0 Interrupt Enable 

;*******************************************************
; DEVICE n STATUS REGISTER [R/W]                        
;*******************************************************
; In order to clear status for a particular IRQ bit,    
; write a '1' to that bit location.                     
;*******************************************************

DEV1_STAT_REG                                      equ 0xc090 ; Device 1 Status Register [R/W]
DEV2_STAT_REG                                      equ 0xc0b0 ; Device 2 Status Register [R/W]

; FIELDS 
WAKE_IRQ_FLG                                       equ 0x0400 ; Wakeup Interrupt Request
RST_IRQ_FLG                                        equ 0x0100 ; Reset Interrupt Request
EP7_IRQ_FLG                                        equ 0x0080 ; EP7 Interrupt Request
EP6_IRQ_FLG                                        equ 0x0040 ; EP6 Interrupt Request
EP5_IRQ_FLG                                        equ 0x0020 ; EP5 Interrupt Request
EP4_IRQ_FLG                                        equ 0x0010 ; EP4 Interrupt Request
EP3_IRQ_FLG                                        equ 0x0008 ; EP3 Interrupt Request
EP2_IRQ_FLG                                        equ 0x0004 ; EP2 Interrupt Request
EP1_IRQ_FLG                                        equ 0x0002 ; EP1 Interrupt Request
EP0_IRQ_FLG                                        equ 0x0001 ; EP0 Interrupt Request

;*******************************************************
; DEVICE n ADDRESS REGISTERS [R/W]                      
;*******************************************************

DEV1_ADDR_REG                                      equ 0xc08e ; Device 1 Address Register [R/W]
DEV2_ADDR_REG                                      equ 0xc0ae ; Device 2 Address Register [R/W]

; FIELDS 

DEV_ADDR_SEL                                       equ 0x007f ; Device Address

;*******************************************************
; DEVICE n FRAME NUMBER REGISTER [R]                    
;*******************************************************

DEV1_FRAME_REG                                     equ 0xc092 ; Device 1 Frame Register [R]
DEV2_FRAME_REG                                     equ 0xc0b2 ; Device 2 Frame Register [R]

; FIELDS 

DEV_FRAME_STAT                                     equ 0x07ff ; Device Frame

;*******************************************************
; DEVICE n ENDPOINT n CONTROL REGISTERS [R/W]           
;*******************************************************
DEV1_EP0_CTL_REG                                   equ 0x0200 ; Device 1 Endpoint 0 Control Register [R/W]
DEV1_EP1_CTL_REG                                   equ 0x0210 ; Device 1 Endpoint 1 Control Register [R/W]      
DEV1_EP2_CTL_REG                                   equ 0x0220 ; Device 1 Endpoint 2 Control Register [R/W]
DEV1_EP3_CTL_REG                                   equ 0x0230 ; Device 1 Endpoint 3 Control Register [R/W]
DEV1_EP4_CTL_REG                                   equ 0x0240 ; Device 1 Endpoint 4 Control Register [R/W]
DEV1_EP5_CTL_REG                                   equ 0x0250 ; Device 1 Endpoint 5 Control Register [R/W]
DEV1_EP6_CTL_REG                                   equ 0x0260 ; Device 1 Endpoint 6 Control Register [R/W]
DEV1_EP7_CTL_REG                                   equ 0x0270 ; Device 1 Endpoint 7 Control Register [R/W]

DEV2_EP0_CTL_REG                                   equ 0x0280 ; Device 2 Endpoint 0 Control Register [R/W]
DEV2_EP1_CTL_REG                                   equ 0x0290 ; Device 2 Endpoint 1 Control Register [R/W]      
DEV2_EP2_CTL_REG                                   equ 0x02a0 ; Device 2 Endpoint 2 Control Register [R/W]
DEV2_EP3_CTL_REG                                   equ 0x02b0 ; Device 2 Endpoint 3 Control Register [R/W]
DEV2_EP4_CTL_REG                                   equ 0x02c0 ; Device 2 Endpoint 4 Control Register [R/W]
DEV2_EP5_CTL_REG                                   equ 0x02d0 ; Device 2 Endpoint 5 Control Register [R/W]
DEV2_EP6_CTL_REG                                   equ 0x02e0 ; Device 2 Endpoint 6 Control Register [R/W]
DEV2_EP7_CTL_REG                                   equ 0x02f0 ; Device 2 Endpoint 7 Control Register [R/W]

SIE1_DEV_REQ                                       equ 0x0300 ; SIE1 Default Setup packet Address
SIE2_DEV_REQ                                       equ 0x0308 ; SIE2 Default Setup packet Address


; FIELDS 

; Defined in Host Control Register
INOUT_IGN_EN                                       equ 0x0080 ; Ignores IN and OUT requests on EP0    
STALL_EN                                           equ 0x0020 ; Endpoint Stall
NAK_INT_EN                                         equ 0x0080 ; NAK Response Interrupt enable 

;*******************************************************
; DEVICE n ENDPOINT n ADDRESS REGISTERS [R/W]           
;*******************************************************

DEV1_EP0_ADDR_REG                                  equ 0x0202 ; Device 1 Endpoint 0 Address Register [R/W]
DEV1_EP1_ADDR_REG                                  equ 0x0212 ; Device 1 Endpoint 1 Address Register [R/W]     
DEV1_EP2_ADDR_REG                                  equ 0x0222 ; Device 1 Endpoint 2 Address Register [R/W]
DEV1_EP3_ADDR_REG                                  equ 0x0232 ; Device 1 Endpoint 3 Address Register [R/W]
DEV1_EP4_ADDR_REG                                  equ 0x0242 ; Device 1 Endpoint 4 Address Register [R/W]
DEV1_EP5_ADDR_REG                                  equ 0x0252 ; Device 1 Endpoint 5 Address Register [R/W]
DEV1_EP6_ADDR_REG                                  equ 0x0262 ; Device 1 Endpoint 6 Address Register [R/W]
DEV1_EP7_ADDR_REG                                  equ 0x0272 ; Device 1 Endpoint 7 Address Register [R/W]

DEV2_EP0_ADDR_REG                                  equ 0x0282 ; Device 2 Endpoint 0 Address Register [R/W]
DEV2_EP1_ADDR_REG                                  equ 0x0292 ; Device 2 Endpoint 1 Address Register [R/W]
DEV2_EP2_ADDR_REG                                  equ 0x02a2 ; Device 2 Endpoint 2 Address Register [R/W]
DEV2_EP3_ADDR_REG                                  equ 0x02b2 ; Device 2 Endpoint 3 Address Register [R/W]
DEV2_EP4_ADDR_REG                                  equ 0x02c2 ; Device 2 Endpoint 4 Address Register [R/W]
DEV2_EP5_ADDR_REG                                  equ 0x02d2 ; Device 2 Endpoint 5 Address Register [R/W]
DEV2_EP6_ADDR_REG                                  equ 0x02e2 ; Device 2 Endpoint 6 Address Register [R/W]
DEV2_EP7_ADDR_REG                                  equ 0x02f2 ; Device 2 Endpoint 7 Address Register [R/W]

;*******************************************************
; DEVICE n ENDPOINT n COUNT REGISTERS [R/W]             
;*******************************************************

DEV1_EP0_CNT_REG                                   equ 0x0204 ; Device 1 Endpoint 0 Count Register [R/W]
DEV1_EP1_CNT_REG                                   equ 0x0214 ; Device 1 Endpoint 1 Count Register [R/W]      
DEV1_EP2_CNT_REG                                   equ 0x0224 ; Device 1 Endpoint 2 Count Register [R/W]
DEV1_EP3_CNT_REG                                   equ 0x0234 ; Device 1 Endpoint 3 Count Register [R/W]
DEV1_EP4_CNT_REG                                   equ 0x0244 ; Device 1 Endpoint 4 Count Register [R/W]
DEV1_EP5_CNT_REG                                   equ 0x0254 ; Device 1 Endpoint 5 Count Register [R/W]
DEV1_EP6_CNT_REG                                   equ 0x0264 ; Device 1 Endpoint 6 Count Register [R/W]
DEV1_EP7_CNT_REG                                   equ 0x0274 ; Device 1 Endpoint 7 Count Register [R/W]

DEV2_EP0_CNT_REG                                   equ 0x0284 ; Device 2 Endpoint 0 Count Register [R/W]
DEV2_EP1_CNT_REG                                   equ 0x0294 ; Device 2 Endpoint 1 Count Register [R/W]     
DEV2_EP2_CNT_REG                                   equ 0x02a4 ; Device 2 Endpoint 2 Count Register [R/W]
DEV2_EP3_CNT_REG                                   equ 0x02b4 ; Device 2 Endpoint 3 Count Register [R/W]
DEV2_EP4_CNT_REG                                   equ 0x02c4 ; Device 2 Endpoint 4 Count Register [R/W]
DEV2_EP5_CNT_REG                                   equ 0x02d4 ; Device 2 Endpoint 5 Count Register [R/W]
DEV2_EP6_CNT_REG                                   equ 0x02e4 ; Device 2 Endpoint 6 Count Register [R/W]
DEV2_EP7_CNT_REG                                   equ 0x02f4 ; Device 2 Endpoint 7 Count Register [R/W]

; FIELDS 

EP_CNT                                             equ 0x03ff ; Endpoint Count

;*******************************************************
; DEVICE n ENDPOINT n STATUS REGISTERS [R/W]            
;*******************************************************

DEV1_EP0_STAT_REG                                  equ 0x0206 ; Device 1 Endpoint 0 Status Register [R/W]
DEV1_EP1_STAT_REG                                  equ 0x0216 ; Device 1 Endpoint 1 Status Register [R/W]      
DEV1_EP2_STAT_REG                                  equ 0x0226 ; Device 1 Endpoint 2 Status Register [R/W]
DEV1_EP3_STAT_REG                                  equ 0x0236 ; Device 1 Endpoint 3 Status Register [R/W]
DEV1_EP4_STAT_REG                                  equ 0x0246 ; Device 1 Endpoint 4 Status Register [R/W]
DEV1_EP5_STAT_REG                                  equ 0x0256 ; Device 1 Endpoint 5 Status Register [R/W]
DEV1_EP6_STAT_REG                                  equ 0x0266 ; Device 1 Endpoint 6 Status Register [R/W]
DEV1_EP7_STAT_REG                                  equ 0x0276 ; Device 1 Endpoint 7 Status Register [R/W]

DEV2_EP0_STAT_REG                                  equ 0x0286 ; Device 2 Endpoint 0 Status Register [R/W]
DEV2_EP1_STAT_REG                                  equ 0x0296 ; Device 2 Endpoint 1 Status Register [R/W]     
DEV2_EP2_STAT_REG                                  equ 0x02a6 ; Device 2 Endpoint 2 Status Register [R/W]
DEV2_EP3_STAT_REG                                  equ 0x02b6 ; Device 2 Endpoint 3 Status Register [R/W]
DEV2_EP4_STAT_REG                                  equ 0x02c6 ; Device 2 Endpoint 4 Status Register [R/W]
DEV2_EP5_STAT_REG                                  equ 0x02d6 ; Device 2 Endpoint 5 Status Register [R/W]
DEV2_EP6_STAT_REG                                  equ 0x02e6 ; Device 2 Endpoint 6 Status Register [R/W]
DEV2_EP7_STAT_REG                                  equ 0x02f6 ; Device 2 Endpoint 7 Status Register [R/W]

; FIELDS 

OUT_EXCEPTION_FLG                                  equ 0x0200 ; OUT received when armed for IN
IN_EXCEPTION_FLG                                   equ 0x0100 ; IN received when armed for OUT
SETUP_FLG                                          equ 0x0010 ; SETUP packet received

;*******************************************************
; DEVICE n ENDPOINT n COUNT RESULT REGISTERS [R]      
;*******************************************************

DEV1_EP0_CTR_REG                                   equ 0x0208 ; Device 1 Endpoint 0 Count Result Register [R]
DEV1_EP1_CTR_REG                                   equ 0x0218 ; Device 1 Endpoint 1 Count Result Register [R]      
DEV1_EP2_CTR_REG                                   equ 0x0228 ; Device 1 Endpoint 2 Count Result Register [R]
DEV1_EP3_CTR_REG                                   equ 0x0238 ; Device 1 Endpoint 3 Count Result Register [R]
DEV1_EP4_CTR_REG                                   equ 0x0248 ; Device 1 Endpoint 4 Count Result Register [R]
DEV1_EP5_CTR_REG                                   equ 0x0258 ; Device 1 Endpoint 5 Count Result Register [R]
DEV1_EP6_CTR_REG                                   equ 0x0268 ; Device 1 Endpoint 6 Count Result Register [R]
DEV1_EP7_CTR_REG                                   equ 0x0278 ; Device 1 Endpoint 7 Count Result Register [R]

DEV2_EP0_CTR_REG                                   equ 0x0288 ; Device 2 Endpoint 0 Count Result Register [R]
DEV2_EP1_CTR_REG                                   equ 0x0298 ; Device 2 Endpoint 1 Count Result Register [R]      
DEV2_EP2_CTR_REG                                   equ 0x02a8 ; Device 2 Endpoint 2 Count Result Register [R]
DEV2_EP3_CTR_REG                                   equ 0x02b8 ; Device 2 Endpoint 3 Count Result Register [R]
DEV2_EP4_CTR_REG                                   equ 0x02c8 ; Device 2 Endpoint 4 Count Result Register [R]
DEV2_EP5_CTR_REG                                   equ 0x02d8 ; Device 2 Endpoint 5 Count Result Register [R]
DEV2_EP6_CTR_REG                                   equ 0x02e8 ; Device 2 Endpoint 6 Count Result Register [R]
DEV2_EP7_CTR_REG                                   equ 0x02f8 ; Device 2 Endpoint 7 Count Result Register [R]

; FIELDS 

EP_RESULT                                          equ 0x00ff ; Endpoint Count Result

;*******************************************************
;*******************************************************
; OTG REGISTERS                                         
;*******************************************************
;*******************************************************

;*******************************************************
; OTG CONTROL REGISTER [R/W]                            
;*******************************************************

OTG_CTL_REG                                        equ 0xc098 ; On-The-Go Control Register [R/W]

; FIELDS 
OTG_RX_DIS                                         equ 0x1000 ; Disable OTG receiver
CHG_PUMP_EN                                        equ 0x0800 ; OTG Charge Pump enable
VBUS_DISCH_EN                                      equ 0x0400 ; VBUS discharge enable
OTG_DATA_STAT                                      equ 0x0004 ; TTL logic state of VBUS pin [R]
OTG_ID_STAT                                        equ 0x0002 ; Value of OTG ID pin [R]
VBUS_VALID_FLG                                     equ 0x0001 ; VBUS > 4.4V [R]

;*******************************************************
;*******************************************************
; GPIO REGISTERS                                        
;*******************************************************
;*******************************************************

;*******************************************************
; GPIO CONTROL REGISTER [R/W]                           
;*******************************************************

GPIO_CTL_REG                                       equ 0xc006 ; GPIO Control Register [R/W]
GPIO_CONFIG                                        equ 0xc006
GPIO_CNTRL                                         equ 0xc01c ; Alias for BIOS code

; FIELDS 
GPIO_WP_EN                                         equ 0x8000 ; GPIO Control Register Write-Protect enable (1:WP)
GPIO_BOND48                                        equ 0x2000 ; Bond48 bit
GPIO_SAS_EN                                        equ 0x0800 ; 1:SPI SS to GPIO[15]
GPIO_MODE_SEL                                      equ 0x0700 ; GPIO Mode      
GPIO_HSS_EN                                        equ 0x0080 ; Connect HSS to GPIO (Dependent on TQFP_PKG)
; TQFP: GPIO [26, 18:16]
; FBGA: GPIO[15:12]
GPIO_HSS_XD_EN                                     equ 0x0040 ; Connect HSS to XD[15:12] (TQFP only)
GPIO_SPI_EN                                        equ 0x0020 ; Connect SPI to GPIO[11:8]
GPIO_SPI_XD_EN                                     equ 0x0010 ; Connect SPI to XD[11:8]
GPIO_IRQ1_POL_SEL                                  equ 0x0008 ; IRQ1 polarity (1:positive, 0:negative) 
GPIO_IRQ1_EN                                       equ 0x0004 ; IRQ1 enable
GPIO_IRQ0_POL_SEL                                  equ 0x0002 ; IRQ0 polarity (1:positive, 0:negative)
GPIO_IRQ0_EN                                       equ 0x0001 ; IRQ0 enable

; GPIO MODE FIELD VALUES 

DIAG_MODE                                          equ 0x0007 ; Memory Diagnostic mode
SCAN_MODE                                          equ 0x0006 ; Boundary Scan mode
HPI_MODE                                           equ 0x0005 ; HPI mode
IDE_MODE                                           equ 0x0004 ; IDE mode
EPP_MODE                                           equ 0x0002 ; EPP mode
FLASH_MODE                                         equ 0x0001 ; FLASH mode
GPIO_MODE                                          equ 0x0000 ; GPIO only

;*******************************************************
; GPIO n REGISTERS                                      
;*******************************************************

GPIO0_OUT_DATA_REG                                 equ 0xc01e ; GPIO 0 Output Data Register [R/W]
GPIO1_OUT_DATA_REG                                 equ 0xc024 ; GPIO 1 Output Data Register [R/W]

GPIO0_IN_DATA_REG                                  equ 0xc020 ; GPIO 0 Input Data Register [R]
GPIO1_IN_DATA_REG                                  equ 0xc026 ; GPIO 1 Input Data Register [R]

GPIO0_DIR_REG                                      equ 0xc022 ; GPIO 0 Direction Register [R/W] (1:Output, 0:Input)
GPIO1_DIR_REG                                      equ 0xc028 ; GPIO 1 Direction Register [R/W] (1:Output, 0:Input)
GPIO_HI_IO                                         equ 0xc024 ; Alias for BIOS
GPIO_HI_ENB                                        equ 0xc028 ; Alias for BIOS

;*******************************************************
; EPP CONTROL REGISTER [R/W]                            
;*******************************************************
EPP_CTL_REG                                        equ 0xc046 ; EPP Control Register [R/W]

; FIELDS 

EPP_MODE_SEL                                       equ 0x8000 ; 1: EPP_MODE, 0: COMPATABILITY MODE [R/W]
EPP_SELECT_STAT                                    equ 0x4000 ; Returns current logic state of the SELECT pin [R]
EPP_nFAULT_STAT                                    equ 0x2000 ; Returns current logic state of the nFAULT pin [R]
EPP_pERROR_STAT                                    equ 0x1000 ; Returns current logic state of the pERROR pin [R]

; EPP MODE ONLY FIELDS (EPP_MODE_EN = 1) 

EPP_nRESET_EN                                      equ 0x0020 ; Reads/Writes current logic state of the nRESET pin [R/W]
EPP_nDSTRB_EN                                      equ 0x0010 ; Reads/Writes current logic state of the nDSTRB pin [R/W]
EPP_nASTRB_EN                                      equ 0x0008 ; Reads/Writes current logic state of the nASTRB pin [R/W] 
EPP_nWRITE_EN                                      equ 0x0004 ; Reads/Writes current logic state of the nWRITE pin [R/W] 
EPP_IRQ_STAT                                       equ 0x0002 ; ??? [R]
EPP_WAIT_STAT                                      equ 0x0001 ; ??? [R]

; COMPATABILITY MODE ONLY FIELDS (EPP_MODE_EN = 0) 

EPP_nINIT_EN                                       equ 0x0020 ; ??? [R/W] 
EPP_nAUTOFD_EN                                     equ 0x0010 ; ??? [R/W] 
EPP_ASELECT_EN                                     equ 0x0008 ; ??? [R/W] 
EPP_nSTROBE_EN                                     equ 0x0004 ; ??? [R/W] 
EPP_nACK_STAT                                      equ 0x0002 ; ??? [R] 
EPP_BUSY_STAT                                      equ 0x0001 ; ??? [R] 

;*******************************************************
; EPP DATA REGISTER [R/W]                               
;*******************************************************

EPP_DATA_REG                                       equ 0xc040 ; EPP Data Register [R/W]

; FIELDS 
EPP_DATA                                           equ 0x00ff ; EPP Data

;*******************************************************
; EPP BUFFER READ REGISTER [R]                          
;*******************************************************

EPP_BFR_READ_REG                                   equ 0xc042 ; EPP Buffer Read Register [R]

; FIELDS 

EPP_BFR                                            equ 0x00ff ; EPP Buffer

;*******************************************************
; EPP ADDRESS REGISTER [R/W]                            
;*******************************************************

EPP_ADDR_REG                                       equ 0xc044 ; EPP Address Register [R/W]

; FIELDS 

EPP_ADDR                                           equ 0x00ff ; EPP Address

;*******************************************************
; IDE MODE REGISTER [R/W]                               
;*******************************************************

IDE_MODE_REG                                       equ 0xc048 ; IDE Mode Register [R/W]

; FIELDS 

IDE_MODE_SEL                                       equ 0x0007 ; IDE Mode (See field values below)

; MODE FIELD VALUES 

MODE_DIS                                           equ 0x0007 ; Disabled
MODE_PIO4                                          equ 0x0004 ; PIO Mode 4
MODE_PIO3                                          equ 0x0003 ; PIO Mode 3
MODE_PIO2                                          equ 0x0002 ; PIO Mode 2
MODE_PIO1                                          equ 0x0001 ; PIO Mode 1
MODE_PIO0                                          equ 0x0000 ; PIO Mode 0

;*******************************************************
; IDE START ADDRESS REGISTER [R/W]                      
;*******************************************************

IDE_START_ADDR_REG                                 equ 0xc04a ; IDE Start Address Register [R/W]

;*******************************************************
; IDE STOP ADDRESS REGISTER [R/W]                       
;*******************************************************

IDE_STOP_ADDR_REG                                  equ 0xc04c ; IDE Stop Address Register [R/W]

;*******************************************************
; IDE CONTROL REGISTER [R/W]                            
;*******************************************************

IDE_CTL_REG                                        equ 0xc04e ; IDE Control Register [R/W]

; FIELDS 

IDE_DIR_SEL                                        equ 0x0008 ; IDE Direction Select
IDE_IRQ_EN                                         equ 0x0004 ; IDE Interrupt Enable
IDE_DONE_FLG                                       equ 0x0002 ; IDE Done Flag (Set by silicon, Cleared by writing 0)
IDE_EN                                             equ 0x0001 ; IDE Enable (Set by writing 1, Cleared by silicon)

; DIRECTION SELECT FIELD VALUES 

WR_EXT                                             equ 0x0008 ; Write to external device
RD_EXT                                             equ 0x0000 ; Read from external device

;*******************************************************
; IDE PIO PORT REGISTERS [R/W]                          
;*******************************************************

IDE_PIO_DATA_REG                                   equ 0xc050 ; IDE PIO Data Register [R/W]
IDE_PIO_ERR_REG                                    equ 0xc052 ; IDE PIO Error Register [R/W]
IDE_PIO_SCT_CNT_REG                                equ 0xc054 ; IDE PIO Sector Count Register [R/W]
IDE_PIO_SCT_NUM_REG                                equ 0xc056 ; IDE PIO Sector Number Register [R/W]
IDE_PIO_CYL_LO_REG                                 equ 0xc058 ; IDE PIO Cylinder Low Register [R/W]
IDE_PIO_CYL_HI_REG                                 equ 0xc05a ; IDE PIO Cylinder High Register [R/W]
IDE_PIO_DEV_HD_REG                                 equ 0xc05c ; IDE PIO Device/Head Register [R/W]
IDE_PIO_CMD_REG                                    equ 0xc05e ; IDE PIO Command Register [R/W]
IDE_PIO_DEV_CTL_REG                                equ 0xc06c ; IDE PIO Device Control Register [R/W]

;*******************************************************
; MDMA MODE REGISTER [R/W]                              
;*******************************************************

MDMA_MODE_REG                                      equ 0xc048 ; MDMA Mode Register [R/W]

; FIELDS 

MDMA_PROTOCOL_SEL                                  equ 0x0008 ; 1:MDMA-B, 0:MDMA-A
MDMA_MODE_SEL                                      equ 0x0007 ; MDMA Mode (See field values below)

; MDMA MODE FIELD VALUES 

MDMA_DIS                                           equ 0x0007 ; Disabled
MDMA_16                                            equ 0x0006 ; MDMA Mode, 16-bit
MDMA_8                                             equ 0x0005 ; MDMA Mode, 8-bit

;*******************************************************
; MDMA START ADDRESS REGISTER [R/W]                     
;*******************************************************

MDMA_START_ADDR_REG                                equ 0xc04a ; MDMA Start Address Register [R/W]

;*******************************************************
; MDMA STOP ADDRESS REGISTER [R/W]                      
;*******************************************************

MDMA_STOP_ADDR_REG                                 equ 0xc04c ; MDMA Stop Address Register [R/W]

;*******************************************************
; MDMA CONTROL REGISTER [R/W]                           
;*******************************************************

MDMA_CTL_REG                                       equ 0xc04e ; MDMA Control Register [R/W]

; FIELDS 

MDMA_DIR_SEL                                       equ 0x0008 ; MDMA Direction Select
MDMA_IRQ_EN                                        equ 0x0004 ; MDMA Interrupt Enable
MDMA_DONE_FLG                                      equ 0x0002 ; MDMA Done Flag (Set by silicon, Cleared by writing 0)
MDMA_EN                                            equ 0x0001 ; MDMA Enable (Set by writing 1, Cleared by silicon)

;*******************************************************
; HSS CONTROL REGISTER [R/W]                            
;*******************************************************

HSS_Ctl_REG                                        equ 0xc070 ; HSS Control Register [R/W]

; FIELDS 

HSS_EN                                             equ 0x8000 ; HSS Enable
RTS_POL_SEL                                        equ 0x4000 ; RTS Polarity Select
CTS_POL_SEL                                        equ 0x2000 ; CTS Polarity Select
XOFF                                               equ 0x1000 ; XOFF/XON state (1:XOFF received, 0:XON received) [R]
XOFF_EN                                            equ 0x0800 ; XOFF/XON protocol Enable
CTS_EN                                             equ 0x0400 ; CTS Enable 
RX_IRQ_EN                                          equ 0x0200 ; RxRdy/RxPktRdy Interrupt Enable
HSS_DONE_IRQ_EN                                    equ 0x0100 ; TxDone/RxDone Interrupt Enable
TX_DONE_IRQ_FLG                                    equ 0x0080 ; TxDone Interrupt (Write 1 to clear)
RX_DONE_IRQ_FLG                                    equ 0x0040 ; RxDone Interrupt (Write 1 to clear)
ONE_STOP_BIT                                       equ 0x0020 ; Number of TX Stop bits (1:one TX stop bit, 0:2 TX stop bits)
HSS_TX_RDY                                         equ 0x0010 ; Tx ready for next byte
PACKET_MODE_SEL                                    equ 0x0008 ; RxIntr Source (1:RxPktRdy, 0:RxRdy)
RX_OVF_FLG                                         equ 0x0004 ; Rx FIFO overflow (Write 1 to clear and flush RX FIFO)
RX_PKT_RDY_FLG                                     equ 0x0002 ; RX FIFO full
RX_RDY_FLG                                         equ 0x0001 ; RX FIFO not empty

; RTS POLARITY SELECT FIELD VALUES 

RTS_POL_LO                                         equ 0x4000 ; Low-true polarity
RTS_POL_HI                                         equ 0x0000 ; High-true polarity

; CTS POLARITY SELECT FIELD VALUES 

CTS_POL_LO                                         equ 0x2000 ; Low-true polarity
CTS_POL_HI                                         equ 0x0000 ; High-true polarity

;*******************************************************
; HSS BAUD RATE REGISTER [???]                          
;*******************************************************
; Baud rate is determined as follows:
;
;     48 MHz
; --------------
; (HSS_BAUD + 1)
;*******************************************************

HSS_BAUD_REG                                       equ 0xc072 ; HSS Baud Register [???]

; FIELDS 

HSS_BAUD_SEL                                       equ 0x1fff ; HSS Baud

;*******************************************************
; HSS TX GAP REGISTER [???]                             
;*******************************************************
; This register defines the number of stop bits used
; for block mode transmission ONLY. The number of stop 
; bits is determined as follows:
;
; (TX_GAP - 7)
;
; Valid values for TX_GAP are 8-255.
;*******************************************************

HSS_TX_GAP_REG                                     equ 0xc074 ; HSS Transmit Gap Register [???]

; FIELDS 

TX_GAP_SEL                                         equ 0x00ff ; HSS Transmit Gap

;*******************************************************
; HSS DATA REGISTER [R/W]                               
;*******************************************************

HSS_DATA_REG                                       equ 0xc076 ; HSS Data Register [R/W]

; FIELDS 

HSS_DATA                                           equ 0x00ff ; HSS Data

;*******************************************************
; HSS RECEIVE ADDRESS REGISTER [???]                    
;*******************************************************

HSS_RX_ADDR_REG                                    equ 0xc078 ; HSS Receive Address Register [???]

;*******************************************************
; HSS RECEIVE COUNTER REGISTER [R/W]                    
;*******************************************************

HSS_RX_CTR_REG                                     equ 0xc07a ; HSS Receive Counter Register [R/W]

; FIELDS 

HSS_RX_CTR                                         equ 0x03ff ; Counts from (n-1) to (0-1)

;*******************************************************
; HSS TRANSMIT ADDRESS REGISTER [???]                   
;*******************************************************

HSS_TX_ADDR_REG                                    equ 0xc07c ; HSS Transmit Address Register [???]

;*******************************************************
; HSS TRANSMIT COUNTER REGISTER [R/W]                   
;*******************************************************

HSS_TX_CTR_REG                                     equ 0xc07e ; HSS Transmit Counter Register [R/W]

; FIELDS 

HSS_TX_CTR                                         equ 0x03ff ; Counts from (n-1) to (0-1)

; ------------------ HIGH SPEED SERIAL INTERFACE ADDRESS -------------------
; High Speed Serial Control

HSS_RGN                                            equ 0xc070
HSS_STS_REG                                        equ 0xc070
HSS_Ctl_ADR                                        equ 0xc070
HSS_Ctl_MSK                                        equ 0x0000
HSS_Ctl_RxRst_BIT                                  equ 0x0002
HSS_Ctl_RxRst_BM                                   equ 0x0004
HSS_Ctl_PacketMode_BIT                             equ 0x0003
HSS_Ctl_PacketMode_BM                              equ 0x0008
HSS_Ctl_OneStop_BIT                                equ 0x0005
HSS_Ctl_OneStop_BM                                 equ 0x0020
HSS_Ctl_RBkDoneClr_BIT                             equ 0x0006
HSS_Ctl_RBkDoneClr_BM                              equ 0x0040
HSS_Ctl_TBkDoneClr_BIT                             equ 0x0007
HSS_Ctl_TBkDoneClr_BM                              equ 0x0080
HSS_Ctl_DoneIntrEnab_BIT                           equ 0x0008
HSS_Ctl_DoneIntrEnab_BM                            equ 0x0100
HSS_Ctl_RxIntrEnab_BIT                             equ 0x0009
HSS_Ctl_RxIntrEnab_BM                              equ 0x0200
HSS_Ctl_CTSenab_BIT                                equ 0x000a
HSS_Ctl_CTSenab_BM                                 equ 0x0400
HSS_Ctl_XOFFenab_BIT                               equ 0x000b
HSS_Ctl_XOFFenab_BM                                equ 0x0800
HSS_Ctl_CTSpolarity_BIT                            equ 0x000d
HSS_Ctl_CTSpolarity_BM                             equ 0x2000
HSS_Ctl_RTSpolarity_BIT                            equ 0x000e
HSS_Ctl_RTSpolarity_BM                             equ 0x4000
HSS_Ctl_Enable_BIT                                 equ 0x000f
HSS_Ctl_Enable_BM                                  equ 0x8000
HSS_Ctl_RxRdy_BIT                                  equ 0x0000
HSS_Ctl_RxRdy_BM                                   equ 0x0001
HSS_Ctl_RxPktRdy_BIT                               equ 0x0001
HSS_Ctl_RxPktRdy_BM                                equ 0x0002
HSS_Ctl_RxErr_BIT                                  equ 0x0002
HSS_Ctl_RxErr_BM                                   equ 0x0004
HSS_Ctl_TxRdy_BIT                                  equ 0x0004
HSS_Ctl_TxRdy_BM                                   equ 0x0010
HSS_Ctl_RBkDone_BIT                                equ 0x0006
HSS_Ctl_RBkDone_BM                                 equ 0x0040
HSS_Ctl_TBkDone_BIT                                equ 0x0007
HSS_Ctl_TBkDone_BM                                 equ 0x0080
HSS_Ctl_XOFFstate_BIT                              equ 0x000c
HSS_Ctl_OFFstate_BM                                equ 0x1000

; High Speed Serial BAUD Rate Register
HSS_BAUDRATE_REG                                   equ 0xc072
HSS_BAUDRate_ADR                                   equ 0xc072
HSS_BAUDRate_MSK                                   equ 0x0000
HSS_BAUDRate_Rate_POS                              equ 0x0000
HSS_BAUDRate_Rate_SIZ                              equ 0x000d

; High Speed Serial GAP Register
HSS_GAP_REG                                        equ 0xc074
HSS_GAP_ADR                                        equ 0xc074
HSS_GAP_MSK                                        equ 0x0000
HSS_GAP_GAP_POS                                    equ 0x0000
HSS_GAP_GAP_SIZ                                    equ 0x0010

; High Speed Serial Data Register
HSS_RX_DATA_REG                                    equ 0xc076
HSS_TX_DATA_REG                                    equ 0xc076
HSS_Data_ADR                                       equ 0xc076
HSS_Data_MSK                                       equ 0x0000
HSS_Data_Data_POS                                  equ 0x0000
HSS_Data_Data_SIZ                                  equ 0x0008

; High Speed Serial Block Receive Address Register
HSS_RX_BLK_ADDR_REG                                equ 0xc078
HSS_RxBlkAddr_ADR                                  equ 0xc078
HSS_RxBlkAddr_MSK                                  equ 0x0000
HSS_RxBlkAddr_Addr_POS                             equ 0x0000
HSS_RxBlkAddr_Addr_SIZ                             equ 0x0010

; High Speed Serial Block Receive Length Register
HSS_RX_BLK_LEN_REG                                 equ 0xc07a
HSS_RxBlkLen_ADR                                   equ 0xc07a
HSS_RxBlkLen_MSK                                   equ 0x0000
HSS_RxBlkLen_POS                                   equ 0x0000
HSS_RxBlkLen_SIZ                                   equ 0x000a

; High Speed Serial Block Transmit Address Register
HSS_TX_BLK_ADDR_REG                                equ 0xc07c
HSS_TxBlkAddr_ADR                                  equ 0xc07c
HSS_TxBlkAddr_MSK                                  equ 0x0000
HSS_TxBlkAddr_Addr_POS                             equ 0x0000
HSS_TxBlkAddr_Addr_SIZ                             equ 0x0010

; High Speed Serial Block Transmit Length Register
HSS_TX_BLK_LEN_REG                                 equ 0xc07e
HSS_TxBlkLen_ADR                                   equ 0xc07e
HSS_TxBlkLen_MSK                                   equ 0x0000
HSS_TxBlkLen_POS                                   equ 0x0000
HSS_TxBlkLen_SIZ                                   equ 0x000a

;*******************************************************
;*******************************************************
; SPI REGISTERS                                         
;*******************************************************
;*******************************************************

;*******************************************************
; SPI CONFIGURATION REGISTER [R/W]                      
;*******************************************************

SPI_CFG_REG                                        equ 0xc0c8 ; SPI Config Register [R/W]

; FIELDS 

c3WIRE_EN                                          equ 0x8000 ; MISO/MOSI data lines common
PHASE_SEL                                          equ 0x0400 ; Advanced SCK phase
SCK_POL_SEL                                        equ 0x2000 ; Positive SCK Polarity
SCALE_SEL                                          equ 0x1e00 ; SPI Clock Frequency Scaling
MSTR_ACTIVE_EN                                     equ 0x0080 ; Master state machine active
MSTR_EN                                            equ 0x0040 ; Master/Slave select
SS_EN                                              equ 0x0020 ; SS enable
SS_DLY_SEL                                         equ 0x001f ; SS delay select

; SCALE VALUES 
SPI_SCALE_1E                                       equ 0x1e00 ;
SPI_SCALE_1C                                       equ 0x1c00 ;
SPI_SCALE_1A                                       equ 0x1a00 ;
SPI_SCALE_18                                       equ 0x1800 ;
SPI_SCALE_16                                       equ 0x1600 ;
SPI_SCALE_14                                       equ 0x1400 ;
SPI_SCALE_12                                       equ 0x1200 ;
SPI_SCALE_10                                       equ 0x1000 ;
SPI_SCALE_0E                                       equ 0x0e00 ;
SPI_SCALE_0C                                       equ 0x0c00 ;
SPI_SCALE_0A                                       equ 0x0a00 ;
SPI_SCALE_08                                       equ 0x0800 ;
SPI_SCALE_06                                       equ 0x0600 ;
SPI_SCALE_04                                       equ 0x0400 ;
SPI_SCALE_02                                       equ 0x0200 ;
SPI_SCALE_00                                       equ 0x0000 ;

;*******************************************************
; SPI CONTROL REGISTER [R/W]                            
;*******************************************************

SPI_CTL_REG                                        equ 0xc0ca ; SPI Control Register [R/W]

; FIELDS 

SCK_STROBE                                         equ 0x8000 ; SCK Strobe
FIFO_INIT                                          equ 0x4000 ; FIFO Init
BYTE_MODE                                          equ 0x2000 ; Byte Mode
FULL_DUPLEX                                        equ 0x1000 ; Full Duplex
SS_MANUAL                                          equ 0x0800 ; SS Manual
READ_EN                                            equ 0x0400 ; Read Enable
SPI_TX_RDY                                         equ 0x0200 ; Transmit Ready
RX_DATA_RDY                                        equ 0x0100 ; Receive Data Ready
TX_EMPTY                                           equ 0x0080 ; Transmit Empty
RX_FULL                                            equ 0x0020 ; Receive Full
TX_BIT_LEN                                         equ 0x0031 ; Transmit Bit Length
RX_BIT_LEN                                         equ 0x0007 ; Receive Bit Length

;*******************************************************
; SPI INTERRUPT ENABLE REGISTER [R/W]                   
;*******************************************************

SPI_IRQ_EN_REG                                     equ 0xc0cc ; SPI Interrupt Enable Register [R/W]

; FIELDS 

SPI_RX_IRQ_EN                                      equ 0x0004 ; SPI Receive Interrupt Enable
SPI_TX_IRQ_EN                                      equ 0x0002 ; SPI Transmit Interrupt Enable
SPI_XFR_IRQ_EN                                     equ 0x0001 ; SPI Transfer Interrupt Enable

;*******************************************************
; SPI STATUS REGISTER [R]                               
;*******************************************************

SPI_STAT_REG                                       equ 0xc0ce ; SPI Status Register [R]

; FIELDS 

SPI_FIFO_ERROR_FLG                                 equ 0x0100 ; FIFO Error occurred
SPI_RX_IRQ_FLG                                     equ 0x0004 ; SPI Receive Interrupt 
SPI_TX_IRQ_FLG                                     equ 0x0002 ; SPI Transmit Interrupt
SPI_XFR_IRQ_FLG                                    equ 0x0001 ; SPI Transfer Interrupt

;*******************************************************
; SPI INTERRUPT CLEAR REGISTER [W]                      
;*******************************************************
; In order to clear a particular IRQ, write a '1' to    
; the appropriate bit location.                         
;*******************************************************

SPI_IRQ_CLR_REG                                    equ 0xc0d0 ; SPI Interrupt Clear Register [W]

; FIELDS 

SPI_TX_IRQ_CLR                                     equ 0x0002 ; SPI Transmit Interrupt Clear
SPI_XFR_IRQ_CLR                                    equ 0x0001 ; SPI Transfer Interrupt Clear

;*******************************************************
; SPI CRC CONTROL REGISTER [R/W]                        
;*******************************************************

SPI_CRC_CTL_REG                                    equ 0xc0d2 ; SPI CRC Control Register [R/W]

; FIELDS 

CRC_MODE                                           equ 0xc000 ; CRC Mode
CRC_EN                                             equ 0x2000 ; CRC Enable
CRC_CLR                                            equ 0x1000 ; CRC Clear
RX_CRC                                             equ 0x0800 ; Receive CRC
ONE_IN_CRC                                         equ 0x0400 ; One in CRC [R]
ZERO_IN_CRC                                        equ 0x0200 ; Zero in CRC [R]

; CRC MODE VALUES 

POLYNOMIAL_3                                       equ 0x0003 ; CRC POLYNOMIAL 1
POLYNOMIAL_2                                       equ 0x0002 ; CRC POLYNOMIAL X^16+X^15+X^2+1
POLYNOMIAL_1                                       equ 0x0001 ; CRC POLYNOMIAL X^7+X^3+1
POLYNOMIAL_0                                       equ 0x0000 ; CRC POLYNOMIAL X^16+X^12+X^5+1

;*******************************************************
; SPI CRC VALUE REGISTER [R/W]                          
;*******************************************************

SPI_CRC_VALUE_REG                                  equ 0xc0d4 ; SPI CRC Value Register [R/W]

;*******************************************************
; SPI DATA REGISTER [R/W]                               
;*******************************************************

SPI_DATA_REG                                       equ 0xc0d6 ; SPI Data Register [R/W]

; FIELDS 

SPI_DATA                                           equ 0x00ff ; SPI Data

;*******************************************************
; SPI TRANSMIT ADDRESS REGISTER [R/W]                   
;*******************************************************

SPI_TX_ADDR_REG                                    equ 0xc0d8 ; SPI Transmit Address Register [R/W]

;*******************************************************
; SPI TRANSMIT COUNT REGISTER [R/W]                     
;*******************************************************

SPI_TX_CNT_REG                                     equ 0xc0da ; SPI Transmit Count Register [R/W]

; FIELDS 

SPI_TX_CNT                                         equ 0x07ff ; SPI Transmit Count

;*******************************************************
; SPI RECEIVE ADDRESS REGISTER [R/W]                    
;*******************************************************

SPI_RX_ADDR_REG                                    equ 0xc0dc ; SPI Receive Address Register [R/W]

;*******************************************************
; SPI RECEIVE COUNT REGISTER [R/W]                      
;*******************************************************

SPI_RX_CNT_REG                                     equ 0xc0de ; SPI Receive Count Register [R/W]

; FIELDS 

SPI_RX_CNT                                         equ 0x07ff ; SPI Receive Count
SPI_RGN                                            equ 0xc0c0 ; SPI memory map start

; SPI 16-bit Configuration Register
;------------------------------------
SPI_Cfg_AFE                                        equ 0x0008
SPI_Cfg_ADR                                        equ 0xc0c8

; b i t   d e f i n i t i o n s
SPI_Cfg_3WireNot4_BIT                              equ 0x000f
SPI_Cfg_3WireNot4_BM                               equ 0x8000
SPI_Cfg_CPHA_BIT                                   equ 0x000e
SPI_Cfg_CPHA_BM                                    equ 0x4000
SPI_Cfg_CPOL_BIT                                   equ 0x000d
SPI_Cfg_CPOL_BM                                    equ 0x2000
SPI_Cfg_Sel_SIZ                                    equ 0x0004
SPI_Cfg_Sel_POS                                    equ 0x0009

; possible selections
SPI_Cfg_Sel_250                                    equ 0x000b
SPI_Cfg_Sel_250_BM                                 equ 0x1600
SPI_Cfg_Sel_375                                    equ 0x000a
SPI_Cfg_Sel_375_BM                                 equ 0x1400
SPI_Cfg_Sel_500                                    equ 0x0009
SPI_Cfg_Sel_500_BM                                 equ 0x1200
SPI_Cfg_Sel_750                                    equ 0x0008
SPI_Cfg_Sel_750_BM                                 equ 0x1000
SPI_Cfg_Sel_1000                                   equ 0x0007
SPI_Cfg_Sel_1000_BM                                equ 0x0e00
SPI_Cfg_Sel_1500                                   equ 0x0006
SPI_Cfg_Sel_1500_BM                                equ 0x0c00
SPI_Cfg_Sel_2M                                     equ 0x0005
SPI_Cfg_Sel_2M_BM                                  equ 0x0a00
SPI_Cfg_Sel_3M                                     equ 0x0004
SPI_Cfg_Sel_3M_BM                                  equ 0x0800
SPI_Cfg_Sel_4M                                     equ 0x0003
SPI_Cfg_Sel_4M_BM                                  equ 0x0600
SPI_Cfg_Sel_6M                                     equ 0x0002
SPI_Cfg_Sel_6M_BM                                  equ 0x0400
SPI_Cfg_Sel_8M                                     equ 0x0001
SPI_Cfg_Sel_8M_BM                                  equ 0x0200
SPI_Cfg_Sel_12M                                    equ 0x0000
SPI_Cfg_Sel_12M_BM                                 equ 0x0000
; end  SPI_Cfg_Sel
SPI_Cfg_RedLine_BIT                                equ 0x0008
SPI_Cfg_RedLine_BM                                 equ 0x0100

SPI_Cfg_MstrActive_BIT                             equ 0x0007
SPI_Cfg_MstrActive_BM                              equ 0x0080
SPI_Cfg_MstrNotSlv_BIT                             equ 0x0006
SPI_Cfg_MstrNotSlv_BM                              equ 0x0040
SPI_Cfg_SSEn_BIT                                   equ 0x0005
SPI_Cfg_SSEn_BM                                    equ 0x0020
;      SPI_Cfg_SSDly                     MSB 4
SPI_Cfg_SSDly_SIZ                                  equ 0x0005
SPI_Cfg_SSDly_POS                                  equ 0x0000
; assign to manual
SPI_Cfg_SSDly_Manual                               equ 0x0000
; one possible selection
SPI_Cfg_SSDly_2                                    equ 0x0002
SPI_Cfg_SSDly_2_BM                                 equ 0x0002


; SPI 16-bit Control Register
;------------------------------------
SPI_Ctl_AFE                                        equ 0x000a
SPI_Ctl_ADR                                        equ 0xc0ca

; b i t   d e f i n i t i o n s
SPI_Ctl_SCKStrobe_BIT                              equ 0x000f
SPI_Ctl_SCKStrobe_BM                               equ 0x8000
SPI_Ctl_FIFOInit_BIT                               equ 0x000e
SPI_Ctl_FIFOInit_BM                                equ 0x4000
SPI_Ctl_ByteMode_BIT                               equ 0x000d
SPI_Ctl_ByteMode_BM                                equ 0x2000
SPI_Ctl_FullDuplex_BIT                             equ 0x000c
SPI_Ctl_FullDuplex_BM                              equ 0x1000
SPI_Ctl_SSManVal_BIT                               equ 0x000b
SPI_Ctl_SSManVal_BM                                equ 0x0800
SPI_Ctl_DoRead_BIT                                 equ 0x000a
SPI_Ctl_DoRead_BM                                  equ 0x0400
SPI_Ctl_TxRdy_BIT                                  equ 0x0009
SPI_Ctl_TxRdy_BM                                   equ 0x0200
SPI_Ctl_RxDatRdy_BIT                               equ 0x0008
SPI_Ctl_RxDatRdy_BM                                equ 0x0100

SPI_Ctl_TxEmpty_BIT                                equ 0x0007
SPI_Ctl_TxEmpty_BM                                 equ 0x0080
SPI_Ctl_RxFull_BIT                                 equ 0x0006
SPI_Ctl_RxFull_BM                                  equ 0x0040
;      SPI_Ctl_TxBitLen                  MSB 5
SPI_Ctl_TxBitLen_POS                               equ 0x0003
SPI_Ctl_TxBitLen_SIZ                               equ 0x0003

; zero is full byte
SPI_Ctl_TxBitLen_FullByte                          equ 0x0000
SPI_Ctl_TxBitLen_FullByte_BM                       equ 0x0000

;      SPI_Ctl_RxBitLen                  MSB 2
SPI_Ctl_RxBitLen_POS                               equ 0x0000
SPI_Ctl_RxBitLen_SIZ                               equ 0x0003

; zero is full byte
SPI_Ctl_RxBitLen_FullByte                          equ 0x0000
SPI_Ctl_RxBitLen_FullByte_BM                       equ 0x0000


; SPI Interrupt Type Bits
; for all Interrupt Registers
; -----------------------------------
SPI_Int_XfrBk_BIT                                  equ 0x0000
SPI_Int_Tx_BIT                                     equ 0x0001
SPI_Int_Rx_BIT                                     equ 0x0002
SPI_Int_FIFOErr_BIT                                equ 0x0007

; SPI 16-bit Interrupt Enable Register
;------------------------------------
SPI_IntEnab_AFE                                    equ 0x000c
SPI_IntEnab_ADR                                    equ 0xc0cc

; b i t   d e f i n i t i o n s
; reserved BITS                              15 - 8

; reserved BITS                              7 - 3
SPI_IntEnab_Rx_BM                                  equ 0x0004
SPI_IntEnab_Tx_BM                                  equ 0x0002
SPI_IntEnab_XfrBk_BM                               equ 0x0001


; SPI 16-bit Interrupt Value Register
;------------------------------------
SPI_IntVal_AFE                                     equ 0x000e
SPI_IntVal_ADR                                     equ 0xc0ce

; b i t   d e f i n i t i o n s
; reserved BITS                              15 - 8

SPI_IntVal_FIFOErr_BM                              equ 0x0080

; reserved BITS                              6 - 3
SPI_IntVal_Rx_BM                                   equ 0x0004
SPI_IntVal_Tx_BM                                   equ 0x0002
SPI_IntVal_XfrBk_BM                                equ 0x0001

; SPI 16-bit Interrupt Clear Register
;------------------------------------
SPI_IntClr_AFE                                     equ 0x0010
SPI_IntClr_ADR                                     equ 0xc0d0

; b i t   d e f i n i t i o n s
; reserved BITS                              15 - 8

; reserved BITS                              7 - 2
SPI_IntClr_Tx_BM                                   equ 0x0002
SPI_IntClr_XfrBk_BM                                equ 0x0001


; SPI 16-bit CRC Control Register
;------------------------------------
SPI_CRCCtl_AFE                                     equ 0x0012
SPI_CRCCtl_ADR                                     equ 0xc0d2

; b i t   d e f i n i t i o n s
;      SPI_CRCCtl                        MSB 15
SPI_CRCCtl_Mode_POS                                equ 0x000e
SPI_CRCCtl_Mode_SIZ                                equ 0x0002

; Mode selections MMC (CCITT),
;  CRC-7, Memory Stick & Reserved
SPI_CRCCtl_Mode_MMC                                equ 0x0000
SPI_CRCCtl_Mode_MMC_BM                             equ 0x0000
SPI_CRCCtl_Mode_CRC7                               equ 0x0001
SPI_CRCCtl_Mode_CRC7_BM                            equ 0x4000
SPI_CRCCtl_Mode_MS                                 equ 0x0002
SPI_CRCCtl_Mode_MS_BM                              equ 0x8000
SPI_CRCCtl_Mode_Res                                equ 0x0003
SPI_CRCCtl_Mode_Res_BM                             equ 0xc000
SPI_CRCCtl_Active_BIT                              equ 0x000d
SPI_CRCCtl_Active_BM                               equ 0x2000
SPI_CRCCtl_Clear_BIT                               equ 0x000c
SPI_CRCCtl_Clear_BM                                equ 0x1000
SPI_CRCCtl_RxNotTx_BIT                             equ 0x000b
SPI_CRCCtl_RxNotTx_BM                              equ 0x0800
SPI_CRCCtl_OR_BIT                                  equ 0x000a
SPI_CRCCtl_OR_BM                                   equ 0x0400
SPI_CRCCtl_NAND_BIT                                equ 0x0009
SPI_CRCCtl_NAND_BM                                 equ 0x0200
; reserved BIT                               8

; reserved BITS                              7 - 0


; SPI 16-bit CRC Value Register
;------------------------------------
SPI_CRCVal_AFE                                     equ 0x0014
SPI_CRCVal_ADR                                     equ 0xc0d4
SPI_CRCVal_Port_POS                                equ 0x0000
SPI_CRCVal_Port_SIZ                                equ 0x0010


; SPI 8-bit transmit & receive port (PIO)
;------------------------------------
SPI_TxRxData_AFE                                   equ 0x0016
SPI_TxRxData_ADR                                   equ 0xc0d6
SPI_TxRxData_Port_POS                              equ 0x0000
SPI_TxRxData_Port_SIZ                              equ 0x0008


; SPI 16-bit DMA transmit base address
;------------------------------------
SPI_TxBlk_AFE                                      equ 0x0018
SPI_TxBlk_ADR                                      equ 0xc0d8
SPI_TxBlk_Base_POS                                 equ 0x0000
SPI_TxBlk_Base_SIZ                                 equ 0x0010


; SPI 11-bit DMA transmit length
;------------------------------------
SPI_TxLen_AFE                                      equ 0x001a
SPI_TxLen_ADR                                      equ 0xc0da
SPI_TxLen_Bytes_POS                                equ 0x0000
SPI_TxLen_Bytes_SIZ                                equ 0x0010


; SPI 16-bit DMA recieve base address
;------------------------------------
SPI_RxBlk_AFE                                      equ 0x001c
SPI_RxBlk_ADR                                      equ 0xc0dc
SPI_RxBlk_Base_POS                                 equ 0x0000
SPI_RxBlk_Base_SIZ                                 equ 0x0010


; SPI 11-bit DMA recieve length
;------------------------------------
SPI_RxLen_AFE                                      equ 0x001e
SPI_RxLen_ADR                                      equ 0xc0de
SPI_RxLen_Bytes_POS                                equ 0x0000
SPI_RxLen_Bytes_SIZ                                equ 0x0010

; ------------------------- IDE PIO MODES ----------------------------------
; IDE Memory Map
; --------------------------------------------------------------------------
IDE_RGN                                            equ 0xc050
; IDE 16-bit Data Register
IDE_Data_ADR                                       equ 0xc050
IDE_Data_MSK                                       equ 0x0000
IDE_Data_Data_POS                                  equ 0x0000
IDE_Data_Data_SIZ                                  equ 0x0010

; IDE 8-bit Features/Status Register (write)
IDE_FeaturesStat_ADR                               equ 0xc052
IDE_FeaturesStat_MSK                               equ 0x0000
IDE_FeaturesStat_Data_POS                          equ 0x0000
IDE_FeaturesStat_Data_SIZ                          equ 0x0008

; IDE Sector Count Register
IDE_SectCount_ADR                                  equ 0xc054
IDE_SectCount_MSK                                  equ 0x0000
IDE_SectCount_Count_POS                            equ 0x0000
IDE_SectCount_Count_SIZ                            equ 0x0008

; IDE Sector Number Register
IDE_SectorNum_ADR                                  equ 0xc056
IDE_SectorNum_MSK                                  equ 0x0000
IDE_SectorNum_Count_POS                            equ 0x0000
IDE_SectorNum_Count_SIZ                            equ 0x0008

; IDE Cylinder Low Register
IDE_CylLow_ADR                                     equ 0xc058
IDE_CylLow_MSK                                     equ 0x0000
IDE_CylLow_Cyl_POS                                 equ 0x0000
IDE_CylLow_Cyl_SIZ                                 equ 0x0008

; IDE Cylinder High Register
IDE_CylHigh_ADR                                    equ 0xc05a
IDE_CylHigh_MSK                                    equ 0x0000
IDE_CylHigh_Cyl_POS                                equ 0x0000
IDE_CylHigh_Cyl_SIZ                                equ 0x0008

; IDE Drive/Head Register
IDE_DrvHead_ADR                                    equ 0xc05c
IDE_DrvHead_MSK                                    equ 0x0000
IDE_DrvHead_Reg_POS                                equ 0x0000
IDE_DrvHead_Reg_SIZ                                equ 0x0008

; IDE Command/Status Register
IDE_CmdStatus_ADR                                  equ 0xc05e
IDE_CmdStatus_MSK                                  equ 0x0000
IDE_CmdStatus_Reg_POS                              equ 0x0000
IDE_CmdStatus_Reg_SIZ                              equ 0x0008

; IDE Status/Alternate Status Register
IDE_AltStat_ADR                                    equ 0xc06c
IDE_AltStat_MSK                                    equ 0x0000
IDE_AltStat_Reg_POS                                equ 0x0000
IDE_AltStat_Reg_SIZ                                equ 0x0008

;*******************************************************
; UART CONTROL REGISTER [R/W]                           
;*******************************************************

UART_CTL_REG                                       equ 0xc0e0 ; UART Control Register [R/W]
UART_CNTL                                          equ 0xc0e0 ; Alias for BIOS code

;  bit mask for 0xc0e2 
UART_RX_BUFF_FULL                                  equ 0x0002

; FIELDS 

UART_SCALE_SEL                                     equ 0x0010 ; UART Scale (1:Divide by 8 prescaler for the UART Clock)
UART_BAUD_SEL                                      equ 0x000e ; UART Baud
UART_EN                                            equ 0x0001 ; UART Enable

; BAUD VALUES 

UART_7K2                                           equ 0x000f ; 7.2K Baud (0.9K with DIV8_EN Set)
UART_9K6                                           equ 0x000e ; 9.6K Baud (1.2K with DIV8_EN Set)
UART_14K4                                          equ 0x000c ; 14.4K Baud (1.8K with DIV8_EN Set)
UART_19K2                                          equ 0x000d ; 19.2K Baud (2.4K with DIV8_EN Set)
UART_28K8                                          equ 0x000b ; 28.8K Baud (3.6K with DIV8_EN Set)
UART_38K4                                          equ 0x000a ; 38.4K Baud (4.8K with DIV8_EN Set)
UART_57K6                                          equ 0x0009 ; 57.6K Baud (7.2K with DIV8_EN Set)
UART_115K2                                         equ 0x0008 ; 115.2K Baud (14.4K with DIV8_EN Set)

;*******************************************************
; UART STATUS REGISTER [R]                              
;*******************************************************

UART_STAT_REG                                      equ 0xc0e2 ; UART Status Register [R]
UART_STATUS                                        equ 0xc0e2

; FIELDS 

UART_RX_FULL                                       equ 0x0002 ; UART Receive Full
UART_TX_EMPTY                                      equ 0x0001 ; UART Transmit Empty

;*******************************************************
; UART DATA REGISTER [R/W]                              
;*******************************************************

UART_DATA_REG                                      equ 0xc0e4 ; UART Data Register [R/W]
UART_RX_REG                                        equ 0xc0e4 ; Alias for BIOS code
UART_TX_REG                                        equ 0xc0e4 ; Alias for BIOS code

; FIELDS 
UART_DATA                                          equ 0x00ff ; UART Data

;*******************************************************
; PWM CONTROL REGISTER [R/W]                            
;*******************************************************

PWM_CTL_REG                                        equ 0xc0e6 ; PWM Control Register [R/W]

; FIELDS 

PWM_EN                                             equ 0x8000 ; 1:Start, 0:Stop
PWM_PRESCALE_SEL                                   equ 0x0e00 ; Prescale field (See values below)
PWM_MODE_SEL                                       equ 0x0100 ; 1:Single cycle, 0:Repetitive cycle
PWM3_POL_SEL                                       equ 0x0080 ; 1:Positive polarity, 0:Negative polarity 
PWM2_POL_SEL                                       equ 0x0040 ; 1:Positive polarity, 0:Negative polarity 
PWM1_POL_SEL                                       equ 0x0020 ; 1:Positive polarity, 0:Negative polarity 
PWM0_POL_SEL                                       equ 0x0010 ; 1:Positive polarity, 0:Negative polarity 
PWM3_EN                                            equ 0x0008 ; PWM3 Enable
PWM2_EN                                            equ 0x0004 ; PWM2 Enable
PWM1_EN                                            equ 0x0002 ; PWM1 Enable
PWM0_EN                                            equ 0x0001 ; PWM0 Enable

; PRESCALER FIELD VALUES 

PWM_5K9                                            equ 0x0007 ; 5.9 KHz 
PWM_23K5                                           equ 0x0006 ; 23.5 KHz
PWM_93K8                                           equ 0x0005 ; 93.8 KHz
PWM_375K                                           equ 0x0004 ; 375 KHz
PWM_1M5                                            equ 0x0003 ; 1.5 MHz
PWM_6M                                             equ 0x0002 ; 6.0 MHz
PWM_24M                                            equ 0x0001 ; 24.0 MHz
PWM_48M                                            equ 0x0000 ; 48.0 MHz

;*******************************************************
; PWM MAXIMUM COUNT REGISTER [R/W]                      
;*******************************************************

PWM_MAX_CNT_REG                                    equ 0xc0e8 ; PWM Maximum Count Register [R/W]

; FIELDS 

PWM_MAX_CNT                                        equ 0x03ff ; PWM Maximum Count

;*******************************************************
; PWM n START REGISTERS [R/W]                           
;*******************************************************

PWM0_START_REG                                     equ 0xc0ea ; PWM 0 Start Register [R/W]
PWM1_START_REG                                     equ 0xc0ee ; PWM 1 Start Register [R/W]
PWM2_START_REG                                     equ 0xc0f2 ; PWM 2 Start Register [R/W]
PWM3_START_REG                                     equ 0xc0f6 ; PWM 3 Start Register [R/W]

; FIELDS 

PWM_START_CNT                                      equ 0x03ff ;

;*******************************************************
; PWM n STOP REGISTERS [R/W]                            
;*******************************************************

PWM0_STOP_REG                                      equ 0xc0ec ; PWM 0 Stop Register [R/W]
PWM1_STOP_REG                                      equ 0xc0f0 ; PWM 1 Stop Register [R/W]
PWM2_STOP_REG                                      equ 0xc0f4 ; PWM 2 Stop Register [R/W]
PWM3_STOP_REG                                      equ 0xc0f8 ; PWM 3 Stop Register [R/W]

; FIELDS 

PWM_STOP_CNT                                       equ 0x03ff ; PWM Stop Count

;*******************************************************
; PWM CYCLE COUNT REGISTER [R/W]                        
;*******************************************************

PWM_CYCLE_CNT_REG                                  equ 0xc0fa ; PWM Cycle Count Register [R/W]

;*******************************************************
;*******************************************************
; HPI REGISTERS                                         
;*******************************************************
;*******************************************************

;*******************************************************
; HPI MAILBOX REGISTER [R/W]                            
;*******************************************************

HPI_MBX_REG                                        equ 0xc0c4 ; HPI Mailbox Register [R/W]

;*******************************************************
; HPI BREAKPOINT REGISTER [R]                           
;*******************************************************

HPI_BKPT_REG                                       equ 0x0140 ; HPI Breakpoint Register [R]
;*******************************************************
; INTERRUPT ROUTING REGISTER [R]                        
;*******************************************************
HPI_IRQ_ROUTING_REG                                equ 0x0142 ; HPI Interrupt Routing Register [R]
HPI_SIE_IE                                         equ 0x0142
HPI_SIE1_MSG_ADR                                   equ 0x0144
HPI_RESERVED                                       equ 0x0146
HPI_SIE2_MSG_ADR                                   equ 0x0148

HPI_RGN                                            equ 0xc0c0 ; base address

; HPI DMA Control Register
HPI_DMACtl_ADR                                     equ 0xc0c0
HPI_DMACtl_MSK                                     equ 0x0000
HPI_DMACtl_D0_BIT                                  equ 0x0000
HPI_DMACtl_D1_BIT                                  equ 0x0001
HPI_DMACtl_DREQ_BIT                                equ 0x0002

; HPI Mailbox Register
HPI_MAILBOX_REG                                    equ 0xc0c6
HPI_MailBox_ADR                                    equ 0xc0c6
HPI_MailBox_MSK                                    equ 0x0000
HPI_MailBox_POS                                    equ 0x0000
HPI_MailBox_SIZ                                    equ 0x0010

VBUS_TO_HPI_EN                                     equ 0x8000 ; Route OTG VBUS Interrupt to HPI
ID_TO_HPI_EN                                       equ 0x4000 ; Route OTG ID Interrupt to HPI
SOFEOP2_TO_HPI_EN                                  equ 0x2000 ; Route SIE2 SOF/EOP Interrupt to HPI
SOFEOP2_TO_CPU_EN                                  equ 0x1000 ; Route SIE2 SOF/EOP Interrupt to CPU
SOFEOP1_TO_HPI_EN                                  equ 0x0800 ; Route SIE1 SOF/EOP Interrupt to HPI
SOFEOP1_TO_CPU_EN                                  equ 0x0400 ; Route SIE1 SOF/EOP Interrupt to CPU
RST2_TO_HPI_EN                                     equ 0x0200 ; Route SIE2 Reset Interrupt to HPI
HPI_SWAP_1_EN                                      equ 0x0100 ; Swap HPI MSB/LSB
RESUME2_TO_HPI_EN                                  equ 0x0080 ; Route SIE2 Resume Interrupt to HPI
RESUME1_TO_HPI_EN                                  equ 0x0040 ; Route SIE1 Resume Interrupt to HPI
DONE2_TO_HPI_EN                                    equ 0x0008 ; Route SIE2 Done Interrupt to HPI
DONE1_TO_HPI_EN                                    equ 0x0004 ; Route SIE1 Done Interrupt to HPI
RST1_TO_HPI_EN                                     equ 0x0002 ; Route SIE1 Reset Interrupt to HPI
HPI_SWAP_0_EN                                      equ 0x0001 ; Swap HPI MSB/LSB (*MUST MATCH HPI_SWAP_1)

; ALIASES 

HOST2_SOEOP_TO_HPI_EN                              equ 0x2000 ; Host 2 SOF/EOP Interrupt
HOST1_SOFEOP_TO_HPI_EN                             equ 0x0800 ; Host 1 SOF/EOP Interrupt
DEVICE2_SOFEOP_TO_HPI_EN                           equ 0x2000 ; Device 2 SOF/EOP Interrupt
DEVICE1_SOFEOP_TO_HPI_EN                           equ 0x0800 ; Device 1 SOF/EOP Interrupt

HOST2_SOFEOP_TO_CPU_EN                             equ 0x1000 ; Host 2 SOF/EOP Interrupt
HOST1_SOFEOP_TO_CPU_EN                             equ 0x0400 ; Host 1 SOF/EOP Interrupt
DEVICE2_SOFEOP_TO_CPU_EN                           equ 0x1000 ; Device 2 SOF/EOP Interrupt
DEVICE1_SOFEOP_TO_CPU_EN                           equ 0x0400 ; Device 1 SOF/EOP Interrupt

HOST2_RESUME_TO_HPI_EN                             equ 0x0080 ; Host 2 Resume Interrupt
HOST1_RESUME_TO_HPI_EN                             equ 0x0040 ; Host 1 Resume Interrupt
DEVICE2_RESUME_TO_HPI_EN                           equ 0x0080 ; Device 2 Resume Interrupt
DEVICE1_RESUME_TO_HPI_EN                           equ 0x0040 ; Device 1 Resume Interrupt

HOST2_DONE_TO_HPI_EN                               equ 0x0008 ; Host 2 Done Interrupt
HOST1_DONE_TO_HPI_EN                               equ 0x0004 ; Host 1 Done Interrupt
DEVICE2_DONE_TO_HPI_EN                             equ 0x0008 ; Device 2 Done Interrupt
DEVICE1_DONE_TO_HPI_EN                             equ 0x0004 ; Device 1 Done Interrupt

HOST2_RESET_TO_HPI_EN                              equ 0x0200 ; Host 2 Reset Interrupt
HOST1_RESET_TO_HPI_EN                              equ 0x0002 ; Host 1 Reset Interrupt
DEVICE2_RESET_TO_HPI_EN                            equ 0x0200 ; Device 2 Reset Interrupt
DEVICE1_RESET_TO_HPI_EN                            equ 0x0002 ; Device 1 Reset Interrupt

;*******************************************************
;*******************************************************
; HPI PORTS                                             
;*******************************************************
;*******************************************************

HPI_BASE                                           equ 0x0000

;*******************************************************
; HPI DATA PORT                                         
;*******************************************************

HPI_DATA_PORT                                      equ 0x0000 ; HPI Data Port

;*******************************************************
; HPI ADDRESS PORT                                      
;*******************************************************

HPI_ADDR_PORT                                      equ 0x0001 ; HPI Address Port

;*******************************************************
; HPI MAILBOX PORT                                      
;*******************************************************

HPI_MBX_PORT                                       equ 0x0002 ; HPI Mailbox Port

;*******************************************************
; HPI STATUS PORT                                       
;*******************************************************

;
;** The HPI Status port is only accessible by an external host over the
;** HPI interface. It is accessed by performing an HPI read at the HPI
;** base address + 3.
;

HPI_STAT_PORT                                      equ 0x0003 ; HPI Status Port

VBUS_FLG                                           equ 0x8000 ; OTG VBUS Interrupt
ID_FLG                                             equ 0x4000 ; OTG ID Interrupt
SOFEOP2_FLG                                        equ 0x1000 ; Host 2 SOF/EOP Interrupt
SOFEOP1_FLG                                        equ 0x0400 ; Host 1 SOF/EOP Interrupt
RST2_FLG                                           equ 0x0200 ; Host 2 Reset Interrupt
MBX_IN_FLG                                         equ 0x0100 ; Message in pending (awaiting CPU read)
RESUME2_FLG                                        equ 0x0080 ; Host 2 Resume Interrupt
RESUME1_FLG                                        equ 0x0040 ; Host 1 Resume Interrupt
DONE2_FLG                                          equ 0x0008 ; Host 2 Done Interrupt
DONE1_FLG                                          equ 0x0004 ; Host 1 Done Interrupt
RST1_FLG                                           equ 0x0002 ; Host 1 Reset Interrupt
MBX_OUT_FLG                                        equ 0x0001 ; Message out available (awaiting external host read)

; Aliases 

HOST2_SOF_EOP_FLG                                  equ 0x1000 ; Host 2 SOF/EOP Interrupt
HOST1_SOF_EOP_FLG                                  equ 0x0400 ; Host 1 SOF/EOP Interrupt
DEV2_SOF_EOP_FLG                                   equ 0x1000 ; Device 2 SOF/EOP Interrupt
DEV1_SOF_EOP_FLG                                   equ 0x0400 ; Device 1 SOF/EOP Interrupt

HOST2_RST_FLG                                      equ 0x0200 ; Host 2 Reset Interrupt
HOST1_RST_FLG                                      equ 0x0002 ; Host 1 Reset Interrupt
DEV2_RST_FLG                                       equ 0x0200 ; Device 2 Reset Interrupt
DEV1_RST_FLG                                       equ 0x0002 ; Device 1 Reset Interrupt

HOST2_RESUME_FLG                                   equ 0x0080 ; Host 2 Resume Interrupt
HOST1_RESUME_FLG                                   equ 0x0040 ; Host 1 Resume Interrupt
DEV2_RESUME_FLG                                    equ 0x0080 ; Device 2 Resume Interrupt
DEV1_RESUME_FLG                                    equ 0x0040 ; Device 1 Resume Interrupt

HOST2_DONE_FLG                                     equ 0x0008 ; Host 2 Done Interrupt
HOST1_DONE_FLG                                     equ 0x0004 ; Host 1 Done Interrupt
DEV2_DONE_FLG                                      equ 0x0008 ; Device 2 Done Interrupt
DEV1_DONE_FLG                                      equ 0x0004 ; Device 1 Done Interrupt

;===============================================================
; usb.inc                                                       
;                                                               
;   A header containing the SL16R slave SIE registers           
;   Updated 8/16/01 For SIE1 and SIE2 New Address Assigned      
;===============================================================

O_SIE_CTRL0                                        equ 0x0000
O_SIE_BASE                                         equ 0x0002
O_SIE_LENGTH                                       equ 0x0004
O_SIE_PORT_SEL                                     equ 0x0004
O_SIE_PID                                          equ 0x0006
O_SIE_CTRL5                                        equ 0x000a
O_SIE_INT_EN                                       equ 0x000c
O_SIE_USB_ADDR                                     equ 0x000e
O_SIE_INT_STATUS                                   equ 0x0010
O_SIE_SOF_LO                                       equ 0x0012
O_SIE_PORT_SPD_SEL                                 equ 0x0012 ; slave mode
O_SIE_SOF_HI                                       equ 0x0014

; Endpoint Register Offsets
O_EP_BANK                                          equ 0x0010 ; to EP bank offset

; SIE Bases and Offsets
NUM_EP_PER_SIE                                     equ 0x0008
O_SIE1_EP_BASE                                     equ 0x0000
O_SIE2_EP_BASE                                     equ 0x0080

SIE_EP_BASE                                        equ 0x0200
SIE1_EP_BASE                                       equ 0x0200
SIE2_EP_BASE                                       equ 0x0280

; Bank Offsets wrt SIE Base

O_EP0_BANK                                         equ 0x0000
O_EP1_BANK                                         equ 0x0010
O_EP2_BANK                                         equ 0x0020
O_EP3_BANK                                         equ 0x0030
O_EP4_BANK                                         equ 0x0040
O_EP5_BANK                                         equ 0x0050
O_EP6_BANK                                         equ 0x0060
O_EP7_BANK                                         equ 0x0070

; SIE1 SLAVE EP Register Bank Base Addresses
SIE1_EP0_BASE                                      equ 0x0200
SIE1_EP1_BASE                                      equ 0x0210
SIE1_EP2_BASE                                      equ 0x0220
SIE1_EP3_BASE                                      equ 0x0230
SIE1_EP4_BASE                                      equ 0x0240
SIE1_EP5_BASE                                      equ 0x0250
SIE1_EP6_BASE                                      equ 0x0260
SIE1_EP7_BASE                                      equ 0x0270

; SIE2 SLAVE EP Register Bank Base Addresses
SIE2_EP0_BASE                                      equ 0x0280
SIE2_EP1_BASE                                      equ 0x0290
SIE2_EP2_BASE                                      equ 0x02a0
SIE2_EP3_BASE                                      equ 0x02b0
SIE2_EP4_BASE                                      equ 0x02c0
SIE2_EP5_BASE                                      equ 0x02d0
SIE2_EP6_BASE                                      equ 0x02e0
SIE2_EP7_BASE                                      equ 0x02f0

; Endpoint Register Offsets
O_EP_CONTROL                                       equ 0x0000
O_EP_BASE_ADDR                                     equ 0x0002
O_EP_BASE_LENGTH                                   equ 0x0004
O_EP_PACKET_STAT                                   equ 0x0006 ; Read
O_EP_XFER_COUNT                                    equ 0x0008 ; Read

; Generic Processing EP data
O_EP_MAX_BYTES                                     equ 0x000a
O_EP_GF_BYTES_LEFT                                 equ 0x000c
O_EP_P_GF                                          equ 0x000e


; Endpoint Control Register Bitmasks
bmEP_CTRL_STICKY                                   equ 0x0080
bmEP_CTRL_DATA1                                    equ 0x0040
bmEP_CTRL_STALL                                    equ 0x0020
bmEP_CTRL_ISO                                      equ 0x0010
bmEP_CTRL_NDS_B                                    equ 0x0008
bmEP_CTRL_DIR_IN                                   equ 0x0004
bmEP_CTRL_ENB                                      equ 0x0002
bmEP_CTRL_ARM                                      equ 0x0001
bmEP_CTRL_EP                                       equ 0x0070
EP_CTRL_OUT                                        equ 0x0000

; Endpoint Packet Status Register Bitmasks
bmEP_PSR_ACK                                       equ 0x0001
bmEP_PSR_ERR                                       equ 0x0002
bmEP_PSR_TO                                        equ 0x0004
bmEP_PSR_DAT1                                      equ 0x0008
bmEP_PSR_SETUP                                     equ 0x0010
bmEP_PSR_OVERFLOW                                  equ 0x0020
bmEP_PSR_NAK                                       equ 0x0040
bmEP_PSR_STALL                                     equ 0x0080
bmEP_PSR_IN_ERR                                    equ 0x0100
bmEP_PSR_OUT_ERR                                   equ 0x0200


; SIE Interrupt Status/Enable Register Bitmasks
bmISR_EP0                                          equ 0x0001
bmISR_EP1                                          equ 0x0002
bmISR_EP2                                          equ 0x0004
bmISR_EP3                                          equ 0x0008
bmISR_EP4                                          equ 0x0010
bmISR_EP5                                          equ 0x0020
bmISR_EP6                                          equ 0x0040
bmISR_EP7                                          equ 0x0080

bmISR_USB_RESET                                    equ 0x0100
bmISR_SOF                                          equ 0x0200
bmISR_WAKEUP                                       equ 0x0400


bmISR_USBA                                         equ 0x0001
bmISR_ALL                                          equ 0x0f6f

; SIE#_USB_CONTROL Bitmasks  
bmCTRL_USB_ENABLE                                  equ 0x0001
bmCTRL_SUSPEND                                     equ 0x0004

bmCTRL_STANDBY                                     equ 0x0040
bmCTRL_PULLUP_AC                                   equ 0x0080
bmCTRL_PULLUP_BD                                   equ 0x0100
bmCTRL_HOST_MODE                                   equ 0x0200
bmCTRL_PORTAC_LOWSPD                               equ 0x0400
bmCTRL_PORTBD_LOWSPD                               equ 0x0800
CTRL_SLAVE_MODE                                    equ 0x0000

; Force State Bits 3,4
bmCTRL_FORCE_NORMAL                                equ 0x0000
bmCTRL_FORCE_SEO                                   equ 0x0010
bmCTRL_FORCE_K                                     equ 0x0018
bmCTRL_FORCE_J                                     equ 0x0008

; Port Speed Bitmasks SIE#_USB_PORT_SPEED
bmPSPD_LOW_SPEED_AC                                equ 0x4000
bmPSPD_LOW_SPEED_BD                                equ 0x8000
PSPD_FULL_SPEED                                    equ 0x0000

; Port Select Bitmasks
bmPSEL_BD                                          equ 0x4000
PSEL_AC                                            equ 0x0000

; generic definitions for BIOS
SUSB_NUM_EPS_ALL                                   equ 0x0010
SUSB_NUM_EPS_PER_SIE                               equ 0x0008

;-----------------------------------------
;
;   Chapter 9 Definitions
;-----------------------------------------
;   Device Requests
DR_GET_STATUS                                      equ 0x0000
DR_CLEAR_FEATURE                                   equ 0x0001
DR_SET_FEATURE                                     equ 0x0003
DR_SET_ADDRESS                                     equ 0x0005
DR_GET_DESCRIPTOR                                  equ 0x0006
DR_SET_DESCRIPTOR                                  equ 0x0007
DR_GET_CONFIG                                      equ 0x0008
DR_SET_CONFIG                                      equ 0x0009
DR_GET_INTERFACE                                   equ 0x0010
DR_SET_INTERFACE                                   equ 0x0011

; Device Request Offsets
O_DR_REQTYPE                                       equ 0x0000
O_DR_REQ                                           equ 0x0001
O_DR_VALUE                                         equ 0x0002
O_DR_VALUE_LOBYTE                                  equ 0x0002
O_DR_VALUE_HIBYTE                                  equ 0x0003
O_DR_INDEX                                         equ 0x0004
O_DR_LEN                                           equ 0x0006

;   Descriptor Types
DEVICE                                             equ 0x0001
CONFIGURATION                                      equ 0x0002
STRING                                             equ 0x0003
INTERFACE                                          equ 0x0004
ENDPOINT                                           equ 0x0005


; Request Type Bitmasks
bmRT_DEVICE2HOST                                   equ 0x0080
bmRT_VENDOR_REQ                                    equ 0x0040 ;Request Type
bmRT_CLASS_REQ                                     equ 0x0020
bmRT_INTERFACE                                     equ 0x0001
bmRT_ENDPOINT                                      equ 0x0002
bmRT_RECIPIENT_BITS                                equ 0x000f
RT_DEVICE                                          equ 0x0000

;   Endpoint Types
EP_TYPE_CONTROL                                    equ 0x0000
EP_TYPE_ISO                                        equ 0x0001
EP_TYPE_BULK                                       equ 0x0002
EP_TYPE_INT                                        equ 0x0003

; BIOS Specific Default Configuration Definitions
EP0_BUFFER_LEN                                     equ 0x0040
EP1_BUFFER_LEN                                     equ 0x0040
EP2_BUFFER_LEN                                     equ 0x0040

;   SUSB ERROR CODES
SUSB_ERR_NONE                                      equ 0x0000
SUSB_ERR_OUT_OF_RANGE                              equ 0x0001
SUSB_ERR_WRONG_DIR                                 equ 0x0002
SUSB_ERR_NULL_FRAME                                equ 0x0003
SUSB_ERR_BAD_TRANS_TYPE                            equ 0x0004
SUSB_ERR_OVERFLOW                                  equ 0x0005
SUSB_ERR_SETUP_TERMINATION                         equ 0x0006
SUSB_ERR_EP_Q_FULL                                 equ 0x0007
SUSB_ERR_EP_STALLED                                equ 0x0008
SUSB_ERR_EP_NOT_ENABLED                            equ 0x0009
SUSB_ERR_BAD_STATE_REQ                             equ 0x000a

; Generic Ep - endpoint bitmask to indicate
;   internal call to Generic EP where
;   regs are already loaded
bmGENEP_REGS_LOADED                                equ 0x8000

;   Device Descriptor Offsets
O_DD_LENGTH                                        equ 0x0000
O_DD_TYPE                                          equ 0x0001
O_DD_USB_VERSION                                   equ 0x0002
O_DD_CLASS                                         equ 0x0004
O_DD_SUBCLASS                                      equ 0x0005
O_DD_PROTOCOL                                      equ 0x0006
O_DD_EP0_MAX_BYTES                                 equ 0x0007
O_DD_VID                                           equ 0x0008
O_DD_PID                                           equ 0x000a
O_DD_DEVICE_VERSION                                equ 0x000c
O_DD_MFR_STRING_IDX                                equ 0x000e
O_DD_PRODUCT_STRING_IDX                            equ 0x000f
O_DD_SN                                            equ 0x0010
O_DD_NUM_CONFIGS                                   equ 0x0011

;   Configuration Descriptor Byte Offsets
O_CD_LENGTH                                        equ 0x0000
O_CD_TYPE                                          equ 0x0001
O_CD_TOTAL_LENGTH                                  equ 0x0002
O_CD_NUM_IFS                                       equ 0x0004
O_CD_CONFIG_NUM                                    equ 0x0005
O_CD_STRING_IDX                                    equ 0x0006
O_CD_ATTRIBUTES                                    equ 0x0007
O_CD_MAX_POWER                                     equ 0x0008

;   Configuration Descriptor Attribute Bitmasks
bmCDATTR_RSVD                                      equ 0x001f
bmCDATTR_RWAKEUP                                   equ 0x0020
bmCDATTR_SELF_PWR                                  equ 0x0040
bmCDATTR_BUS_PWR                                   equ 0x0080

;   Interface Descriptor Byte Offsets
O_ID_LENGTH                                        equ 0x0000
O_ID_TYPE                                          equ 0x0001
O_ID_IF_NUM                                        equ 0x0002
O_ID_ALT_SETTING                                   equ 0x0003
O_ID_NUM_EPS                                       equ 0x0004
O_ID_IF_CLASS                                      equ 0x0005
O_ID_IF_SUBCLASS                                   equ 0x0006
O_ID_IF_PROTO                                      equ 0x0007
O_ID_STRING_IDX                                    equ 0x0008

;   Endpoint Descriptor Byte Offsets
O_ED_LENGTH                                        equ 0x0000
O_ED_TYPE                                          equ 0x0001
O_ED_ADDRESS                                       equ 0x0002
O_ED_ATTRIBUTES                                    equ 0x0003
O_ED_MAX_BYTES                                     equ 0x0004
O_ED_ITERVAL                                       equ 0x0006

O_SD_LENGTH                                        equ 0x0000
O_SD_TYPE                                          equ 0x0001

;   EP Descriptor Address Bitmasks
bmEDADDR_EP_NUM                                    equ 0x0007
bmEDADDR_UNUSED                                    equ 0x0070
bmEDADDR_DIR_IN                                    equ 0x0080

;   EP Descriptor Attribute Bitmasks
bmEDATTR_CONTROL                                   equ 0x0000
bmEDATTR_ISO                                       equ 0x0001
bmEDATTR_BULK                                      equ 0x0010
bmEDATTR_INT                                       equ 0x0011
bmEDATTR_UNUSED                                    equ 0x00fc

; GetStatus Bitmasks
bmGS_REMOTE_WAKEUP                                 equ 0x0002
bmGS_SELF_POWERED                                  equ 0x0001
bmGS_EP_HALT                                       equ 0x0001

; Feature Selectors
F_SEL_EP_HALT                                      equ 0x0000
F_SEL_RMT_WAKEUP                                   equ 0x0001
F_SEL_TEST_MODE                                    equ 0x0002

;*******************************************************
;  Hardware/Software Interrupt vectors                  
;*******************************************************
; ========= HARWDARE INTERRUPTS ===========             
TIMER0_INT                                         equ 0x0000
TIMER0_VEC                                         equ 0x0000 ; Vector location
TIMER1_INT                                         equ 0x0001
TIMER1_VEC                                         equ 0x0002

GP_IRQ0_INT                                        equ 0x0002
GP_IRQ0_VEC                                        equ 0x0004
GP_IRQ1_INT                                        equ 0x0003
GP_IRQ1_VEC                                        equ 0x0006

UART_TX_INT                                        equ 0x0004
UART_TX_VEC                                        equ 0x0008
UART_RX_INT                                        equ 0x0005
UART_RX_VEC                                        equ 0x000a

HSS_BLK_DONE_INT                                   equ 0x0006
HSS_BLK_DONE_VEC                                   equ 0x000c
HSS_RX_FULL_INT                                    equ 0x0007
HSS_RX_FULL_VEC                                    equ 0x000e

IDE_DMA_DONE_INT                                   equ 0x0008
IDE_DMA_DONE_VEC                                   equ 0x0010

Reserved9                                          equ 0x0009

HPI_MBOX_RX_FULL_INT                               equ 0x000a
HPI_MBOX_RX_FULL_VEC                               equ 0x0014
HPI_MBOX_TX_EMPTY_INT                              equ 0x000b
HPI_MBOX_TX_EMPTY_VEC                              equ 0x0016

SPI_TX_INT                                         equ 0x000c
SPI_TX_VEC                                         equ 0x0018
SPI_RX_INT                                         equ 0x000d
SPI_RX_VEC                                         equ 0x001a
SPI_DMA_DONE_INT                                   equ 0x000e
SPI_DMA_DONE_VEC                                   equ 0x001c

OTG_ID_VBUS_VALID_INT                              equ 0x000f
OTG_ID_VBUS_VALID_VEC                              equ 0x001e

SIE1_HOST_DONE_INT                                 equ 0x0010
SIE1_HOST_DONE_VEC                                 equ 0x0020
SIE1_HOST_SOF_INT                                  equ 0x0011
SIE1_HOST_SOF_VEC                                  equ 0x0022
SIE1_HOST_INS_REM_INT                              equ 0x0012
SIE1_HOST_INS_REM_VEC                              equ 0x0024

Reserved19                                         equ 0x0013

SIE1_SLAVE_RESET_INT                               equ 0x0014
SIE1_SLAVE_RESET_VEC                               equ 0x0028
SIE1_SLAVE_SOF_INT                                 equ 0x0015
SIE1_SLAVE_SOF_VEC                                 equ 0x002a

Reserved22                                         equ 0x0016
Reserved23                                         equ 0x0017

SIE2_HOST_DONE_INT                                 equ 0x0018
SIE2_HOST_DONE_VEC                                 equ 0x0030
SIE2_HOST_SOF_INT                                  equ 0x0019
SIE2_HOST_SOF_VEC                                  equ 0x0032
SIE2_HOST_INS_REM_INT                              equ 0x001a
SIE2_HOST_INS_REM_VEC                              equ 0x0034

Reserved27                                         equ 0x001b

SIE2_SLAVE_RESET_INT                               equ 0x001c
SIE2_SLAVE_RESET_VEC                               equ 0x0038
SIE2_SLAVE_SOF_INT                                 equ 0x001d
SIE2_SLAVE_SOF_VEC                                 equ 0x003a

Reserved30                                         equ 0x001e
Reserved31                                         equ 0x001f

SIE1_EP0_INT                                       equ 0x0020
SIE1_EP0_VEC                                       equ 0x0040
SIE1_EP1_INT                                       equ 0x0021
SIE1_EP1_VEC                                       equ 0x0042
SIE1_EP2_INT                                       equ 0x0022
SIE1_EP2_VEC                                       equ 0x0044
SIE1_EP3_INT                                       equ 0x0023
SIE1_EP3_VEC                                       equ 0x0046
SIE1_EP4_INT                                       equ 0x0024
SIE1_EP4_VEC                                       equ 0x0048
SIE1_EP5_INT                                       equ 0x0025
SIE1_EP5_VEC                                       equ 0x004a
SIE1_EP6_INT                                       equ 0x0026
SIE1_EP6_VEC                                       equ 0x004c
SIE1_EP7_INT                                       equ 0x0027
SIE1_EP7_VEC                                       equ 0x004e

SIE2_EP0_INT                                       equ 0x0028
SIE2_EP0_VEC                                       equ 0x0050
SIE2_EP1_INT                                       equ 0x0029
SIE2_EP1_VEC                                       equ 0x0052
SIE2_EP2_INT                                       equ 0x002a
SIE2_EP2_VEC                                       equ 0x0054
SIE2_EP3_INT                                       equ 0x002b
SIE2_EP3_VEC                                       equ 0x0056
SIE2_EP4_INT                                       equ 0x002c
SIE2_EP4_VEC                                       equ 0x0058
SIE2_EP5_INT                                       equ 0x002d
SIE2_EP5_VEC                                       equ 0x005a
SIE2_EP6_INT                                       equ 0x002e
SIE2_EP6_VEC                                       equ 0x005c
SIE2_EP7_INT                                       equ 0x002f
SIE2_EP7_VEC                                       equ 0x005e

;*******************************************************
;  Interrupts 48 will be used for SW interrupt          
;*******************************************************
; ========= SOFTWARE INTERRUPTS ===========             
SEND_MSG_INT                                       equ 0x0030
SEND_MSG_LOC                                       equ 0x0060
ASND_MSG_INT                                       equ 0x0031
ASND_MSG_LOC                                       equ 0x0062

I2C_INT                                            equ 0x0040
LI2C_INT                                           equ 0x0041
UART_INT                                           equ 0x0042
SCAN_INT                                           equ 0x0043
SCAN_SIGNATURE                                     equ 0xc3b6
SCAN_SIGNATURE0                                    equ 0x00b6
XROM_SCAN_SIGNATURE                                equ 0xcb36
XROM_SCAN_SIGNATURE0                               equ 0x0036

ALLOC_INT                                          equ 0x0044
IDLE_INT                                           equ 0x0046
IDLER_INT                                          equ 0x0047
INSERT_IDLE_INT                                    equ 0x0048
PUSHALL_INT                                        equ 0x0049
POPALL_INT                                         equ 0x004a
FREE_INT                                           equ 0x004b
REDO_ARENA                                         equ 0x004c
HW_SWAP_REG                                        equ 0x004d
HW_REST_REG                                        equ 0x004e
SCAN_DECODE_INT                                    equ 0x004f

;*******************************************************
; -- INTs 80 to 115 for SUSB ---                        
;*******************************************************
SUSB1_SEND_INT                                     equ 0x0050
SUSB1_RECEIVE_INT                                  equ 0x0051
SUSB1_STALL_INT                                    equ 0x0052
SUSB1_STANDARD_INT                                 equ 0x0053
OTG_SRP_INT                                        equ 0x0054
SUSB1_VENDOR_INT                                   equ 0x0055
REMOTE_WK_INT                                      equ 0x0056
SUSB1_CLASS_INT                                    equ 0x0057
OTG_DESC_VEC                                       equ 0x00b0
SUSB1_FINISH_INT                                   equ 0x0059
SUSB1_DEV_DESC_VEC                                 equ 0x00b4
SUSB1_CONFIG_DESC_VEC                              equ 0x00b6
SUSB1_STRING_DESC_VEC                              equ 0x00b8
SUSB1_RESERVED_93                                  equ 0x005d
SUSB1_LOADER_INT                                   equ 0x005e
SUSB1_DELTA_CONFIG_INT                             equ 0x005f

SUSB2_SEND_INT                                     equ 0x0060
SUSB2_RECEIVE_INT                                  equ 0x0061
SUSB2_STALL_INT                                    equ 0x0062
SUSB2_STANDARD_INT                                 equ 0x0063
SUSB2_RESERVED_100                                 equ 0x0064
SUSB2_VENDOR_INT                                   equ 0x0065
SUSB2_RESERVED_102                                 equ 0x0066
SUSB2_CLASS_INT                                    equ 0x0067
SUSB2_RESERVED_104                                 equ 0x0068
SUSB2_FINISH_INT                                   equ 0x0069
SUSB2_DEV_DESC_VEC                                 equ 0x00d4
SUSB2_CONFIG_DESC_VEC                              equ 0x00d6
SUSB2_STRING_DESC_VEC                              equ 0x00d8
SUSB2_RESERVED_109                                 equ 0x006d
SUSB2_LOADER_INT                                   equ 0x006e
SUSB2_DELTA_CONFIG_INT                             equ 0x006f
USB_INIT_INT                                       equ 0x0070
SUSB_INIT_INT                                      equ 0x0071

;*******************************************************
; --- 114 - 117 for Host SW INT's ---                   
;*******************************************************
HUSB_SIE1_INIT_INT                                 equ 0x0072
HUSB_SIE2_INIT_INT                                 equ 0x0073
HUSB_RESET_INT                                     equ 0x0074

; UART support 
KBHIT_INT                                          equ 0x0075

;*******************************************************
;--- INT 118 - 124 are available for users              
;--- INT 125, 126 and 127 for Debugger ----             
;*******************************************************

#endif
