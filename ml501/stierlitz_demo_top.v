 /*************************************************************************
 *                     This file is part of Stierlitz:                    *
 *               https://github.com/asciilifeform/Stierlitz               *
 *************************************************************************/

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


`include "stierlitz.v"
`include "infer-sram.v"


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
   output wire [6:0] sace_usb_a;
   inout wire [15:0] sace_usb_d;
   output wire 	usb_hpi_reset_n;

   wire [1:0]	usb_addr;

   assign sace_usb_a[2:1] = usb_addr[1:0];

   assign sace_usb_a[0] = 1'bz;
   assign sace_usb_a[6:3] = 4'bz;
      
   /* CY manual reset */
   wire 	usbreset = CBUTTON | ~sys_rst_pin; /* tie rst to main rst */
   // assign usb_hpi_reset_n = ~usbreset;

   /* 16 MHz (x2) clock for HPI interface */
   wire 	hpi_clock;

   reg [1:0] 	clkdiv;
   always @(posedge sys_clk, posedge usbreset)
     if (usbreset)
       begin
   	  clkdiv <= 0;
       end
     else
       begin
   	  clkdiv <= clkdiv + 1;
       end
   assign hpi_clock = clkdiv[1];
   
   // DCM_BASE hpi_clock_dcm (.CLKIN(sys_clk),
   // 			   .CLKFX(hpi_clock),
   // 			   .RST(sys_rst_pin)
   // 			   );
   // defparam hpi_clock_dcm.CLK_FEEDBACK = "NONE";
   // defparam hpi_clock_dcm.CLKFX_MULTIPLY = 4;
   // defparam hpi_clock_dcm.CLKFX_DIVIDE = 25;

   assign sace_mpce = 1; /* Switch off ACE to free the bus it shares with CY */

   wire 	hpi_manual_test = EBUTTON; /* temporary manual toggle to run tester */
   wire 	usb_irq = usb_hpi_int; /* HPI IRQ is active-high */
   
   wire 	sbus_ready;
   wire 	sbus_rw;
   wire 	sbus_start_op;
   wire [40:0] 	sbus_address;
   wire [7:0] 	sbus_data;
   

   assign sbus_ready = 1;


   assign led_byte = sbus_address[16:9];

   
   stierlitz s(.clk(hpi_clock),
	       .reset(usbreset),
	       .enable(1'b1),
	       /* Control wiring */
	       .bus_ready(sbus_ready),
	       .bus_address(sbus_address),
	       .bus_data(sbus_data),
	       .bus_rw(sbus_rw),
	       .bus_start_op(sbus_start_op),
	       /* CY7C67300 connections */
	       .cy_hpi_address(usb_addr),
	       .cy_hpi_data(sace_usb_d),
	       .cy_hpi_oen(sace_usb_oen),
	       .cy_hpi_wen(sace_usb_wen),
	       .cy_hpi_csn(usb_csn),
	       .cy_hpi_irq(usb_hpi_int),
	       .cy_hpi_resetn(usb_hpi_reset_n)
	       );

   // reg [7:0] 	test;
   // wire [7:0] 	test;
   
   // assign sbus_data = sbus_rw ? test : 8'bz;

   // always @(posedge sys_clk)
   //   begin
   // 	case (sbus_address[1:0])
   // 	  2'b00:
   // 	    test <= sbus_address[16:9];
   // 	  2'b01:
   // 	    test <= sbus_address[24:17];
   // 	  2'b10:
   // 	    test <= sbus_address[32:25];
   // 	  2'b11:
   // 	    test <= sbus_address[40:33];
   // 	endcase // case (sbus_address[1:0])
   //   end

   wire 	ram_we;
   wire 	ram_oe;
   assign ram_we = (~sbus_rw) & sbus_start_op;
   assign ram_oe = sbus_rw & sbus_start_op;
   
   infer_sram #(17, 8, 131072)
   ram(.clk(sys_clk),
       .we(ram_we),
       .oe(ram_oe),
       .address(sbus_address[16:0]),
       .data(sbus_data)
       );
      
endmodule
