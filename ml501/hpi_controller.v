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

/*
 Maximum data rate of CY7C67300 is 8MHz.
 */

module hpi_controller
  (clk,
   reset,
   /* CY7C67300 wiring */
   hpi_address,
   hpi_data,
   hpi_oen,
   hpi_wen,
   hpi_csn,
   hpi_irq,
   hpi_resetn,
   /* Control */
   splat
   /* ... */
   );

   /* There are exactly four HPI addresses: */
   localparam [1:0]
     HPI_REG_DATA = 2'b00,     /* R/W */
     HPI_REG_MAILBOX = 2'b01,  /* R/W */
     HPI_REG_ADDRESS = 2'b10,  /* W */
     HPI_REG_STATUS = 2'b11;   /* R */

   /* States for FSM */
   localparam [1:0]
     STATE_IDLE = 0,
     STATE_SET_ADDR_REG, = 1,
     STATE_ADDRESS_WRITE = 2,
     STATE_DATA_WRITE = 3;
   
     

     
   /****************************************/
   input 	     splat; /* For testing */
   /****************************************/
   
   input clk; /* 32MHz (4x max HPI freq.) */
   input reset; /* Active-high */
   
   output wire [1:0] hpi_address;
   inout wire [15:0] hpi_data;
   output wire 	     hpi_oen;
   output wire 	     hpi_wen;
   output wire 	     hpi_csn;
   input wire 	     hpi_irq;
   output wire 	     hpi_resetn;

   assign hpi_csn = 0; /* For now, pretend ACE doesn't exist */
   
   reg [1:0] 	     hpi_ctl_addr_reg;
   assign hpi_address[1:0] = hpi_ctl_addr_reg;

   reg 		     hpi_ctl_dir; /* HPI direction; 0: read, 1: write. */
   
   reg [15:0] 	     hpi_data_out;
   assign hpi_data = hpi_ctl_dir ? hpi_data_out : 16'bz;

   reg [31:0] 	     foo; /* For test */
   
   always @(posedge clk, posedge reset, posedge splat)
     if (reset)
       begin
	  foo <= 32'b0;
       end
     else
       begin
	  if (splat)
	    begin
	       foo <= foo + 1;
	    end
       end

   reg [23:0] tmr;
   wire       one_hz;
   assign one_hz = tmr[23];

   wire       eight_mhz; /* Max data rate */
   assign eight_mhz = tmr[2];

   reg [1:0] st; /* FSM */

   wire      idling;
   assign idling = (st == STATE_IDLE);
   
   /* write if not reading */
   assign hpi_wen = (~hpi_ctl_dir) && eight_mhz && (~idling);

   /* read is already active-low */
   assign hpi_oen = hpi_ctl_dir && eight_mhz && (~idling);

   
   always @(posedge clk, posedge reset)
     if (reset)
       begin
	  tmr <= 0;
       end
     else
       begin
	  tmr <= tmr + 1;
       end
   
   always @(posedge clk, posedge reset)
     if (reset)
       begin
	  hpi_ctl_dir <= 0; /* Tristate the HPI bus on reset */
	  hpi_ctl_addr_reg <= HPI_REG_STATUS;
	  st = STATE_IDLE;
       end
     else
       begin
	  case (st)
	    STATE_IDLE:
	      begin
		 hpi_ctl_dir <= 0;
		 st = one_hz ? STATE_SET_ADDR_REG ? STATE_IDLE;
	      end
	    STATE_SET_ADDR_REG:
	      begin
		 hpi_ctl_addr_reg <= HPI_REG_ADDRESS;
		 hpi_ctl_dir <= 1; /* Write */
		 st = STATE_ADDRESS_WRITE;
	      end
	    STATE_ADDRESS_WRITE:
	      begin
		 
		 st = STATE_DATA_WRITE;
	      end
	    STATE_DATA_WRITE:
	      begin
		 st = STATE_IDLE;
	      end
       end
endmodule