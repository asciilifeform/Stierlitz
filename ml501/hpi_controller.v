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
   splat,
   test_out
   /* ... */
   );

   /* There are exactly four HPI addresses: */
   localparam [1:0]
     HPI_REG_DATA = 2'b00,     /* R/W */
     HPI_REG_MAILBOX = 2'b01,  /* R/W */
     HPI_REG_ADDRESS = 2'b10,  /* W */
     HPI_REG_STATUS = 2'b11;   /* R */

   /* States for FSM */
   localparam [2:0]
     STATE_IDLE = 0,
     STATE_AD1 = 1,
     STATE_AD2 = 2,
     STATE_AD3 = 3,
     STATE_WR1 = 4,
     STATE_WR2 = 5,
     STATE_WR3 = 6;


   // localparam [2:0]
   //   STATE_IDLE = 0,
   //   STATE_A = 1,
   //   STATE_B = 2,
   //   STATE_C = 3,
   //   STATE_D = 4,
   //   STATE_E = 5,
   //   STATE_F = 6,
   //   STATE_G = 7;
   

   /****************************************/
   input 	     splat; /* For testing */
   /****************************************/
   
   input clk; /* 16MHz (2x max HPI freq.) */
   input reset; /* Active-high */
   
   output wire [1:0] hpi_address;
   inout wire [15:0] hpi_data;
   output wire 	     hpi_oen;
   output wire 	     hpi_wen;
   output wire 	     hpi_csn;
   input wire 	     hpi_irq;
   output wire 	     hpi_resetn;

   output wire [7:0] test_out;
    

   assign hpi_resetn = ~reset; /* reset with FPGA */
   
   assign hpi_csn = 0; /* For now, pretend ACE doesn't exist */
   
   reg [1:0] 	     hpi_ctl_addr_reg;
   assign hpi_address[1:0] = hpi_ctl_addr_reg[1:0];

   reg 		     wen_reg;
   reg 		     oen_reg;
   
   assign hpi_wen = wen_reg;

   // assign hpi_oen = oen_reg;
   assign hpi_oen = 1;
   

   // reg [15:0] 	     hpi_address_out;
   parameter HPI_ADDRESS_OUT = 16'h1324; /* io_test */
   // parameter HPI_ADDRESS_OUT = 16'h0500; /* io_test */
   
   reg [15:0] 	     hpi_data_out;

   reg [15:0] 	     hpi_data_in;

   assign test_out = hpi_data_in[7:0];


   reg 		     tris;
      
   assign hpi_data = tris ? 16'bz : hpi_data_out;
   // assign hpi_data = hpi_data_out;
   
   // assign hpi_data = 16'bz;
   
   // reg [15:0] 	     hpi_data_in;
   // wire       rw; /* high=write low=read */
   // assign rw = 1; /* write test */

   reg [2:0] st; /* FSM */

   // always @(posedge clk, posedge reset)
   //   if (reset)
   //     begin
   // 	  hpi_data_in <= 0;
   // 	  wen_reg <= 1;
   // 	  oen_reg <= 1;
   // 	  tris <= 1;
   // 	  st = STATE_IDLE;
   //     end
   //   else
   //     begin
   // 	  case (st)
   // 	    STATE_IDLE:
   // 	      begin
   // 		 tris <= 0;
   // 		 hpi_ctl_addr_reg <= HPI_REG_ADDRESS;
   // 		 hpi_data_out <= HPI_ADDRESS_OUT;
   // 		 wen_reg <= 1;
   // 		 oen_reg <= 1;
   // 		 st = splat ? STATE_A : STATE_IDLE;
   // 	      end
   // 	    STATE_A:
   // 	      begin
   // 		 wen_reg <= 0;
   // 		 st = STATE_B;
   // 	      end
   // 	    STATE_B:
   // 	      begin
   // 		 wen_reg <= 1;
   // 		 st = STATE_C;
   // 	      end
   // 	    STATE_C:
   // 	      begin
   // 		 tris <= 1;
   // 		 st = STATE_D;
   // 	      end
   // 	    STATE_D:
   // 	      begin
   // 		 hpi_ctl_addr_reg <= HPI_REG_DATA;
   // 		 st = STATE_E;
   // 	      end
   // 	    STATE_E:
   // 	      begin
   // 		 oen_reg <= 0;
   // 		 st = STATE_F;
   // 	      end
   // 	    STATE_F:
   // 	      begin
   // 		 hpi_data_in <= hpi_data;
   // 		 st = STATE_G;
   // 	      end
   // 	    STATE_G:
   // 	      begin
   // 		 oen_reg <= 1;
   // 		 st = STATE_IDLE;
   // 	      end
   // 	    default:
   // 	      begin
   // 		 st = STATE_IDLE;
   // 	      end
   // 	  endcase
   //     end
  
   always @(posedge clk, posedge reset)
     if (reset)
       begin
	  tris <= 0;
   	  wen_reg <= 1;
   	  st = STATE_IDLE;
       end
     else
       begin
   	  case (st)
   	    STATE_IDLE:
   	      begin
		 tris <= 0;
   		 hpi_ctl_addr_reg <= HPI_REG_ADDRESS;
   		 hpi_data_out <= HPI_ADDRESS_OUT;
   		 wen_reg <= 1;
   		 st = splat ? STATE_AD1 : STATE_IDLE;
   	      end
   	    STATE_AD1:
   	      begin
   		 wen_reg <= 0;
   		 st = STATE_AD2;
   	      end
   	    STATE_AD2:
   	      begin
   		 // st = rw ? STATE_WR1 : STATE_RD1;
   		 st = STATE_AD3;
   	      end
   	    STATE_AD3:
   	      begin
   		 wen_reg <= 1;
   		 st = STATE_WR1;
   	      end
   	    STATE_WR1:
   	      begin
   		 hpi_ctl_addr_reg <= HPI_REG_DATA;
   		 hpi_data_out <= 16'hCAFE;
   		 st = STATE_WR2;
   	      end
   	    STATE_WR2:
   	      begin
   		 wen_reg <= 0;
   		 st = STATE_WR3;
   	      end
   	    STATE_WR3:
   	      begin
   		 wen_reg <= 1;
   		 // st = splat ? STATE_WR1 : STATE_IDLE;
   		 st = STATE_IDLE;
   	      end
   	    default:
   	      begin
   		 st = STATE_IDLE;
   	      end
   	  endcase
       end
endmodule // hpi_controller
