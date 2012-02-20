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
module stierlitz
  (clk,
   reset,
   /* Control wiring */
   ce,
   block_address,
   byte_address,
   data_byte_in,
   data_byte_out,
   start_op,
   rw,
   bus_ready,
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
     STATE_READ_STATUS     = 0,
     STATE_MONITOR_STATUS  = 1,
     STATE_LATCH_ADDRESS   = 2,
     STATE_DMA_WRITE       = 3,
     STATE_DMA_READ        = 4,
     STATE_MAILBOX_WRITE   = 5,
     STATE_MAILBOX_READ    = 6,
     STATE_COMMAND         = 7;
   /**************************************************************************/

   
   /**************************************************************************/
   /* System */
   input wire clk; /* ? MHz (? x max HPI freq.) */
   input wire reset; /* Active-high */

   /* Control connections */
   input wire ce;                     /* Enable (active-high.) */
   output wire [31:0] block_address;  /* LBA of active block */
   output wire [8:0]  byte_address;   /* Byte offset into block. */
   input wire  [7:0]  data_byte_in;   /* Byte-wide input */
   output wire [7:0]  data_byte_out;  /* Byte-wide output */
   output wire 	      start_op;       /* Start OP Signal to bus controller */
   output wire 	      rw;             /* Read (1) or Write (0) operation. */
   input wire 	      bus_ready;      /* If bus controller is ready for op.*/
      
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
   reg [1:0] 	     hpi_ctl_addr_reg; /* Selected HPI register. */
   assign hpi_address[1:0] = hpi_ctl_addr_reg[1:0];


   reg [2:0] 	     state;       /* Current FSM state */
   reg [2:0] 	     next_state;  /* Next FSM state */
   reg 		     rw_in_progress; /* If a read or write cycle is ongoing. */

   reg 		     hpi_io_dir;  /* Read (1) or Write (0) of current HPI state. */
   reg 		     hpi_io_cycle;
   
   assign cy_hpi_oen = ~(hpi_io_dir & hpi_io_cycle);
   assign cy_hpi_wen = ~((~hpi_io_dir) & hpi_io_cycle);

   reg [15:0] 	     hpi_data_out; /* Current HPI Data Out */
   reg [15:0] 	     hpi_data_in; /* Current HPI Data In */
   
   reg [15:0] 	     hpi_dma_address; /* Address to latch on next HPI DMA */
   
   /* HPI State register flags (valid when read) */
   /* Outgoing msg is waiting in CY's mailbox */
   wire 	     hpi_mbx_out_flag = hpi_data_in[0];
   /* CY has not yet read msg that we sent */
   wire 	     hpi_mbx_in_flag = hpi_data_in[8];
   
   assign cy_hpi_data = hpi_io_dir ? 16'bz : hpi_data_out; /* Tristate if Reading */
   /**************************************************************************/

   
   /**************************************************************************/
   always @(posedge clk, posedge reset)
     if (reset)
       begin
	  state <= STATE_MONITOR_STATUS;
       end
     else
       begin
	  state <= next_state;
       end

   
   /**************************************************************************/
   always @(posedge clk, posedge reset)
     if (reset)
       begin
	  hpi_io_dir = 1;
	  next_state = STATE_READ_STATUS;
       end
     else
       begin
	  case (state)
	    STATE_READ_STATUS:
	      begin
		 hpi_ctl_addr_reg = HPI_REG_STATUS;
		 next_state = STATE_MONITOR_STATUS;
		 hpi_io_dir = 1;
	      end
	    STATE_MONITOR_STATUS:
	      begin
		 hpi_ctl_addr_reg = HPI_REG_STATUS;
		 hpi_io_dir = 1;
		 /* If message is waiting in CY, on next cycle mbx is read. */
		 if (hpi_mbx_out_flag)
		   begin
		      next_state = STATE_MAILBOX_READ;
		   end
		 else /* If not, we read status register again... */
		   begin
		      next_state = STATE_READ_STATUS;
		   end
	      end
	    STATE_LATCH_ADDRESS:
	      begin
		 hpi_ctl_addr_reg = HPI_REG_DMA_ADDRESS;
		 hpi_io_dir = 0;
		 hpi_data_out = hpi_dma_address;
	      end
	    STATE_DMA_WRITE:
	      begin
		 hpi_ctl_addr_reg = HPI_REG_DMA_DATA;
		 hpi_io_dir = 0;
	      end
	    STATE_DMA_READ:
	      begin
		 hpi_ctl_addr_reg = HPI_REG_DMA_DATA;
		 hpi_io_dir = 1;
	      end
	    STATE_MAILBOX_WRITE:
	      begin
		 hpi_ctl_addr_reg = HPI_REG_MAILBOX;
		 hpi_io_dir = 0;
	      end
	    STATE_MAILBOX_READ:
	      begin
		 hpi_ctl_addr_reg = HPI_REG_MAILBOX;
		 hpi_io_dir = 1;
	      end
	    STATE_COMMAND:
	      begin
		 next_state = STATE_READ_STATUS;
		 hpi_io_dir = 1;
	      end
	    default:
	      begin
		 next_state = STATE_READ_STATUS;
		 hpi_io_dir = 1;
	      end
	  endcase // case (state)
       end // else: !if(reset)
   /**************************************************************************/
endmodule
/**************************************************************************/