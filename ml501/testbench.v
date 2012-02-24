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

`timescale 1ns/100ps

`include "stierlitz.v"

module stierlitz_testbench;

   /* The basics */
   // input wire sys_clk;
   reg hpi_clock = 0;
   
   // input wire sys_rst_pin;
   reg sys_rst_pin;
   
   input wire CBUTTON;      /* These buttons are active-high */
   input wire EBUTTON;
   output wire [7:0] led_byte;

   /* CY7C67300 */
   output wire 	sace_usb_oen;
   output wire 	sace_usb_wen;
   output wire 	usb_csn;
   wire  	usb_hpi_int;
   output wire [1:0] sace_usb_a;
   wire [15:0] sace_usb_d;
   output wire 	usb_hpi_reset_n;

   // reg   	usb_hpi_int;
   // reg [15:0]	sace_usb_d;

   reg 		hpi_int = 0;
   reg [15:0]	usb_d = 0;
   assign usb_hpi_int = hpi_int;

   assign sace_usb_d = ~sace_usb_oen ? usb_d : 'bz;
   
   
   wire 	usbreset = ~sys_rst_pin;

   wire 	sbus_ready;
   wire 	sbus_rw;
   wire 	sbus_start_op;
   wire [40:0] 	sbus_address;
   wire [7:0] 	sbus_data;

   reg 		sb_data = 0;
   assign sbus_data = sbus_rw ? sb_data : 'bz;
   
   
   assign sbus_ready = 1;
   
   stierlitz s(.clk(hpi_clock),
	       .reset(usbreset),
	       .enable(1),
	       /* Control wiring */
	       .bus_ready(sbus_ready),
	       .bus_address(sbus_address),
	       .bus_data(sbus_data),
	       .bus_rw(sbus_rw),
	       .bus_start_op(sbus_start_op),
	       /* CY7C67300 connections */
	       .cy_hpi_address(sace_usb_a),
	       .cy_hpi_data(sace_usb_d),
	       .cy_hpi_oen(sace_usb_oen),
	       .cy_hpi_wen(sace_usb_wen),
	       .cy_hpi_csn(usb_csn),
	       .cy_hpi_irq(usb_hpi_int),
	       .cy_hpi_resetn(usb_hpi_reset_n)
	       );

   /* 16 MHz (x2) clock for HPI interface */
   // wire 	hpi_clock;

   // reg [2:0] 	clkdiv;
   // always @(posedge sys_clk, posedge usbreset)
   //   if (usbreset)
   //     begin
   // 	  clkdiv <= 0;
   //     end
   //   else
   //     begin
   // 	  clkdiv <= clkdiv + 1;
   //     end
   // assign hpi_clock = clkdiv[2];


   // 100MHz
   always
     begin
	hpi_clock <= 1'b1;
	#5;
	hpi_clock <= 1'b0;
	#5;
     end

   parameter T = 1;
   parameter P = 160;

   always @(posedge hpi_clock)
     if (~sace_usb_oen)
       begin
	  #T;
	  hpi_int <= 0;
       end

   initial
     begin: Init
	#0 $display ("Init!\n");
	#0 sys_rst_pin = 1;
	// system reset active
	sys_rst_pin = 0;
	#P;
	#P;
	sys_rst_pin = 1;
	#P;
	#P;
	// end of system reset
     end

   always
     begin
	// start of test
	#P;
	#P;
	#P;
	#P;
	#P;
	// Set up LBA address:

	// LBA-0
	usb_d = 'h00AA;
	hpi_int = 1;
	#P;
	// LBA-1
	usb_d = 'h01BB;
	hpi_int = 1;
	#P;
	// LBA-2
	usb_d = 'h02CC;
	hpi_int = 1;
	#P;
	// LBA-3
	usb_d = 'h03DD;
	hpi_int = 1;
	#P;

	// Write '0x01'
	usb_d = 'h8001;
	hpi_int = 1;
	#P;

	// Write '0x02'
	usb_d = 'h8002;
	hpi_int = 1;
	#P;

	// Write '0x03'
	usb_d = 'h8003;
	hpi_int = 1;
	#P;

	// Write '0x04'
	usb_d = 'h8004;
	hpi_int = 1;
	#P;

	// Write '0x05'
	usb_d = 'h8005;
	hpi_int = 1;
	#P;
	
	// // Read
	// sb_data = 'h01;
	// usb_d = 'h4000;
	// hpi_int = 1;
	// #P;

	// // Read
	// sb_data = 'h02;
	// usb_d = 'h4000;
	// hpi_int = 1;
	// #P;

	// // Read
	// sb_data = 'h03;
	// usb_d = 'h4000;
	// hpi_int = 1;
	// #P;

	// // Read
	// sb_data = 'h04;
	// usb_d = 'h4000;
	// hpi_int = 1;
	// #P;

	// // Read
	// sb_data = 'h05;
	// usb_d = 'h4000;
	// hpi_int = 1;
	// #P;

	
	// end of test
	#P;
	#P;
	#P;
	#P;
	#P;
        $finish;
     end

   initial
     begin
	$dumpfile("wave.vcd");
	$dumpvars(0,
		  hpi_clock,
		  usbreset,
		  usb_csn,
		  sace_usb_oen,
		  sace_usb_wen,
		  usb_hpi_int,
		  sace_usb_a,
		  sace_usb_d,
		  sbus_ready,
		  sbus_rw,
		  sbus_start_op,
		  sbus_address,
		  sbus_data
		  );
     end
   
endmodule