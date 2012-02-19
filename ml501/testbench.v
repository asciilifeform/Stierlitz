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

`include "hpi_controller.v"

module stierlitz_testbench;

   /* The basics */
   // input wire sys_clk;
   reg sys_clk;
   
   // input wire sys_rst_pin;
   reg sys_rst_pin;
   
   input wire CBUTTON;      /* These buttons are active-high */
   input wire EBUTTON;
   output wire [7:0] led_byte;

   /* CY7C67300 */
   output wire 	sace_usb_oen;
   output wire 	sace_usb_wen;
   output wire 	usb_csn;
   input wire  	usb_hpi_int;
   output wire [1:0] sace_usb_a;
   inout wire [15:0] sace_usb_d;
   output wire 	usb_hpi_reset_n;

   // wire 	hpi_manual_test; /* temporary manual toggle to run tester */
   reg 		hpi_manual_test;
   
   
   wire 	usbreset = ~sys_rst_pin;
   
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

   /* 16 MHz (x2) clock for HPI interface */
   wire 	hpi_clock;

   reg [6:0] 	clkdiv;
   always @(posedge sys_clk, posedge usbreset)
     if (usbreset)
       begin
	  clkdiv <= 0;
       end
     else
       begin
	  clkdiv <= clkdiv + 1;
       end
   assign hpi_clock = clkdiv[6];


   // 100MHz
   always
     begin
	sys_clk = 1'b1;
	#5;
	sys_clk = 1'b0;
	#5;
     end

   initial
     begin: Init
	#0 $display ("Init!\n");
	#0 sys_rst_pin = 1;
	#0 hpi_manual_test = 0;
	// system reset active
	#1000 sys_rst_pin = 0;
	#10000 sys_rst_pin = 1;
	// end of system reset
	// start of test
	#20000 hpi_manual_test = 1;
	#1000000 hpi_manual_test = 0;
	// end of test
     end

   always
     begin
	#5000000
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
		  hpi_manual_test
		  );
     end
   
endmodule