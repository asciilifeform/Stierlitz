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

module stierlitz_demo_top (sys_clk, usb_hpi_reset_n, CBUTTON);

   output wire RLED;
   output wire TLED;
   output wire GLED;
   input wire 	CBUTTON;
   output wire 	usb_hpi_reset_n;

   wire 	usbreset = CBUTTON;
   assign GLED = usbreset;

   assign usb_hpi_reset_n = ~usbreset;
  
   
endmodule

