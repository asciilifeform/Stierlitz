/**************************************************************************
 *                            Stierlitz (FPGA side)                       *
 *************************************************************************/

/**************************************************************************
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


/**************************************************************************/
module hpi_controller
  (clk,
   reset,
   /* Control wiring */
   ce,
   data_out,
   data_in,
   ready,
   rw,
   start_op,
   irq,
   /* CY7C67300 wiring */
   cy_hpi_address,
   cy_hpi_data,
   cy_hpi_oen,
   cy_hpi_wen,
   cy_hpi_csn,
   cy_hpi_irq,
   cy_hpi_resetn
   );
   
   /**************************************************************************/
   localparam [1:0] /* The four HPI addresses: */
     HPI_REG_DMA_DATA = 2'b00,    /* Put or get DMA data. (R/W) */
     HPI_REG_MAILBOX = 2'b01,     /* Send or receive data using Mailbox. (R/W) */
     HPI_REG_DMA_ADDRESS = 2'b10, /* Latch address for start of DMA transaction. (W) */
     HPI_REG_STATUS = 2'b11;      /* Read chip status register, for free. (R) */

   localparam [2:0]
     STATE_IDLE            =  0,
     STATE_READ_1          =  1,
     STATE_READ_2          =  2,
     STATE_WRITE_1         =  3,
     STATE_WRITE_2         =  4;

   /**************************************************************************/

   
   /**************************************************************************/
   /* System */
   input wire clk; /* ? MHz (? x max HPI freq.) */
   input wire reset; /* Active-high */

   input wire ce; /* chip enable, active-low */
   output wire [15:0] data_out;
   input wire  [17:0] data_in;   /* Includes the two reg address bits. */
   output wire 	      ready;     /* Active-high. */
   input wire 	      rw;        /* Op type: 1=Read 0=Write*/
   input wire 	      start_op;  /* Start of operation (active-high.) */
   output wire 	      irq;       /* Mailbox has message. */
      
   /* Connections to CY7C67300 */
   output wire [1:0] cy_hpi_address;  /* Select HPI register. */
   inout wire [15:0] cy_hpi_data;     /* Bidirectional HPI data. */
   output wire 	     cy_hpi_oen;      /* HPI Read Enable (active-low) */
   output wire 	     cy_hpi_wen;      /* HPI Write Enable (active-low) */
   output wire 	     cy_hpi_csn;      /* HPI Chip Select (active-low) */
   input wire 	     cy_hpi_irq;      /* HPI IRQ line (active-high) */
   output wire 	     cy_hpi_resetn;   /* HPI Chip Reset (active-low) */
   /**************************************************************************/


   /**************************************************************************/
   assign cy_hpi_resetn = ~reset;
   
   assign cy_hpi_csn = ce; /* Chip enable */
   wire 	     enabled = ~ce;
   
   reg 		     read_enable;
   reg 		     write_enable;
   assign cy_hpi_oen = ~read_enable;
   assign cy_hpi_wen = ~write_enable;
   
   reg [15:0] 	     hpi_data_read; /* Current HPI Data In */
   assign data_out[15:0] = hpi_data_read[15:0];
      
   wire 	     output_enable;
   assign output_enable = write_enable & enabled;

   reg [17:0] 	     hpi_data_reg;
   assign cy_hpi_data = output_enable ? hpi_data_reg[15:0] : 16'bz;
   assign cy_hpi_address[1:0] = hpi_data_reg[17:16];

   /**************************************************************************/
   reg               hpi_ready; /* HPI is accepting R/W op. */
   assign ready = hpi_ready;

   assign irq = cy_hpi_irq;
   
   reg [2:0] 	     hpi_state;       /* Current FSM state */   
  
   always @(posedge clk, posedge reset)
     if (reset)
       begin
	  hpi_ready <= 0;
	  read_enable <= 0;
	  write_enable <= 0;
	  hpi_data_reg <= 0;
	  hpi_state = STATE_IDLE;
       end
     else
       begin
	  case (hpi_state)
	    STATE_IDLE:
	      begin
		 hpi_ready <= enabled;
		 read_enable <= 0;
		 write_enable <= 0;
		 /* Begin new R/W operation? */
		 if (start_op & enabled)
		   begin
		      hpi_state = rw ? STATE_READ_1 : STATE_WRITE_1;
		   end
		 else
		   begin
		      hpi_state = STATE_IDLE;
		   end
	      end
	    STATE_READ_1:
	      begin
		 hpi_ready <= 0;
		 read_enable <= 1; /* READ */
		 write_enable <= 0;
		 hpi_state = STATE_READ_2;
	      end
	    STATE_READ_2:
	      begin
		 hpi_ready <= 0;
		 read_enable <= 1; /* READ */
		 write_enable <= 0;
		 hpi_data_read <= cy_hpi_data;
		 hpi_state = STATE_IDLE;
	      end
	    STATE_WRITE_1:
	      begin
		 hpi_ready <= 0;
		 read_enable <= 0;
		 write_enable <= 0;
		 hpi_data_reg <= data_in; /* Data and reg address */
		 hpi_state = STATE_WRITE_2;
	      end
	    STATE_WRITE_2:
	      begin
		 hpi_ready <= 0;
		 read_enable <= 0;
		 write_enable <= 1; /* WRITE */
		 hpi_state = STATE_IDLE;
	      end
	    default:
	      begin
		 hpi_ready <= enabled;
		 read_enable <= 0;
		 write_enable <= 0;
		 hpi_state = STATE_IDLE;
	      end
	  endcase // case (state)
       end // else: !if(reset)
   /**************************************************************************/
endmodule
/**************************************************************************/