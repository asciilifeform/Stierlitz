/*************************************************************************
 *                (c) Copyright 2012 Stanislav Datskovskiy                *
 *                         http://www.loper-os.org                        *
 **************************************************************************
 *                                                                        *
 *  This program is free software: you can redistribute it and/or modify  *
 *  it under the terms of the GNU General Public License as published by  *
 *  the Free Software Foundation, either version 3 of the License, or     *
 *  (at your option) any later version.                                   *
 *                                                                        *
 *  This program is distributed in the hope that it will be useful,       *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *  GNU General Public License for more details.                          *
 *                                                                        *
 *  You should have received a copy of the GNU General Public License     *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *                                                                        *
 *************************************************************************/

`timescale 1ns/1ps

`include "hpi_controller.v"


module stierlitz_demo_top
  (sys_clk,          /* 100MHz main clock line */
   sys_rst_pin,      /* Master reset */
   /************* Cypress CY7C67300 *************/
   sace_usb_a,       /* CY HPI Address bus (two bits) */
   sace_usb_d,       /* CY HPI Data bus */
   sace_usb_oen,     /* CY HPI nRD */
   sace_usb_wen,     /* CY HPI nWR */
   usb_csn,          /* CY HPI nCS */
   usb_hpi_reset_n,  /* CY HPI nRESET */
   usb_hpi_int,      /* CY HPI INT */
   /*********************************************/
   sace_mpce,        /* Xilinx ACE nCS */
   /*********************************************/
   CBUTTON,          /* Center Button */
   EBUTTON,          /* East Button */
   /*********************************************/
   led_byte          /* LED bank, 8 bits wide */
   );

   
   /* The basics */
   input wire sys_clk;
   input wire sys_rst_pin;
   input wire CBUTTON;      /* These buttons are active-high */
   input wire EBUTTON;
   output wire [7:0] led_byte;

   /* Xilinx ACE - must be disabled for Cypress CY to work */
   output wire 	sace_mpce;
   
   /* CY7C67300 */
   output wire 	sace_usb_oen;
   output wire 	sace_usb_wen;
   output wire 	usb_csn;
   input wire  	usb_hpi_int;
   output wire [1:0] sace_usb_a;
   inout wire [15:0] sace_usb_d;
   output wire 	usb_hpi_reset_n;
   
   /* CY manual reset */
   wire 	usbreset = CBUTTON | ~sys_rst_pin; /* tie rst to main rst */
   assign usb_hpi_reset_n = ~usbreset;

   /* 32 MHz (x4) clock for HPI interface */
   wire 	hpi_clock;
   DCM hpi_clock_dcm (.CLKIN(sys_clk), .CLKFX(hpi_clock));
   defparam hpi_clock_dcm.CLKFX_MULTIPLY = 8;
   defparam hpi_clock_dcm.CLKFX_DIVIDE = 25;

   assign sace_mpce = 1; /* Switch off ACE to free the bus it shares with CY */

   wire 	hpi_manual_test = EBUTTON; /* temporary manual toggle to run tester */

   wire 	usb_irq = usb_hpi_int; /* HPI IRQ is active-high */
   assign led_byte[0] = ~usb_irq; /* LEDs are active-high */
   assign led_byte[7:1] = 7'b0;
   
   hpi_controller stierlitz(.clk(hpi_clock),
			    .reset(usbreset),
			    .hpi_resetn(usb_hpi_reset_n),
			    .hpi_csn(usb_csn),
			    .hpi_oen(sace_usb_oen),
			    .hpi_wen(sace_usb_wen),
			    .hpi_irq(usb_hpi_int),
			    .hpi_address(sace_usb_a),
			    .hpi_data(sace_usb_d),
			    .splat(hpi_manual_test)
			    );
   
  
endmodule
