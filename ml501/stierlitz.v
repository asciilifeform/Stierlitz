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
   enable,
   /* Control wiring */
   bus_ready,
   bus_address,
   bus_data,
   bus_rw,
   bus_start_op,
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
     STATE_MBX_READ_1      =  1,
     STATE_MBX_READ_2      =  2,
     STATE_MBX_WRITE_1     =  3,
     STATE_MBX_WRITE_2     =  4,
     STATE_CMD             =  5,
     STATE_BUS_READ        =  6,
     STATE_BUS_WRITE       =  7;

   /**************************************************************************/

   
   /**************************************************************************/
   /* System */
   input wire clk;    /* ? MHz (? x max HPI freq.) */
   input wire reset;  /* Active-high */
   input wire enable; /* Active-high. */
   
   /* Bus interface */
   output wire [39:0] bus_address;  /* LBA of active block and Word offset. */
   inout wire  [15:0] bus_data;     /* Word-wide data in/out on bus. */
   output wire 	      bus_rw;       /* Bus Op type: 1=Read 0=Write*/
   output wire 	      bus_start_op; /* Start of operation (active-high.) */
   input wire 	      bus_ready;    /* Bus is ready (high) if no op is in progress. */
      
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
   /* Bus (user) side */
   reg [7:0] 	     LBA [3:0]; /* Current LBA address */
   reg [7:0] 	     word_offset; /* Offset of current word. */

   assign bus_address[7:0]   = word_offset;
   assign bus_address[15:8]  = LBA[0];
   assign bus_address[23:16] = LBA[1];
   assign bus_address[31:24] = LBA[2];
   assign bus_address[39:32] = LBA[3];

   reg [15:0] 	     bus_word_out;
   reg 		     bus_rw_control; /* Bus Op type: 1=Read 0=Write*/
   assign bus_rw = bus_rw_control;
   
   assign bus_data = bus_rw_control ? 16'bz : bus_word_out;

   reg 		     bus_op;
   assign bus_start_op = bus_op;
   /**************************************************************************/
   
   /**************************************************************************/
   /* HPI side */
   assign cy_hpi_csn = ~enable;
   assign cy_hpi_resetn = ~reset; /* TODO: proper reset logic? */
      
   assign cy_hpi_address[1:0] = HPI_REG_MAILBOX; /* For now, no DMA support. */      

   reg 		     read_enable;
   reg 		     write_enable;
   assign cy_hpi_oen = ~read_enable;
   assign cy_hpi_wen = ~write_enable;

   wire 	     output_enable;
   assign output_enable = write_enable & enable;

   reg [15:0] 	     hpi_data_out_reg;
   assign cy_hpi_data = output_enable ? hpi_data_out_reg : 16'bz;

   reg [15:0] 	     hpi_data_in_reg;
   /**************************************************************************/
   
   reg [2:0] 	     hpi_state;       /* Current FSM state */   

   reg 		     is_bus_reading;
   reg 		     is_bus_writing;

   always @(posedge clk, posedge reset)
     if (reset)
       begin
	  read_enable <= 0;
	  write_enable <= 0;
	  is_bus_reading <= 0;
	  is_bus_writing <= 0;
	  bus_op <= 0;
	  hpi_data_in_reg <= 0;
	  hpi_data_out_reg <= 0;
	  LBA[0] <= 0;
	  LBA[1] <= 0;
	  LBA[2] <= 0;
	  LBA[3] <= 0;
	  hpi_state = STATE_IDLE;
       end
     else
       begin
	  case (hpi_state)
	    STATE_IDLE:
	      begin
		 read_enable <= 0;
		 write_enable <= 0;
		 /* Idle forever until IRQ is received. */
		 hpi_state = cy_hpi_irq ? STATE_MBX_READ_1 : STATE_IDLE;
	      end
	    STATE_MBX_READ_1:
	      begin
		 read_enable <= 1;
		 write_enable <= 0;
		 hpi_state = STATE_MBX_READ_2;
	      end
	    STATE_MBX_READ_2:
	      begin
		 read_enable <= 1;
		 write_enable <= 0;
		 hpi_data_in_reg <= cy_hpi_data;
		 hpi_state = is_bus_writing ? STATE_BUS_WRITE : STATE_CMD;
	      end
	    STATE_MBX_WRITE_1:
	      begin
		 read_enable <= 0;
		 write_enable <= 1;
		 hpi_state = STATE_MBX_WRITE_2;
	      end
	    STATE_MBX_WRITE_2:
	      begin
		 read_enable <= 0;
		 write_enable <= 0;
		 hpi_state = is_bus_reading ? STATE_BUS_READ : STATE_IDLE;
	      end
	    STATE_CMD:
	      begin
		 read_enable <= 0;
		 write_enable <= 0;
		 case (hpi_data_in_reg[15:14])
		   2'b00:
		     begin
			/* Set nth byte of LBA address (0...3) */
			LBA[(hpi_data_in_reg[9:8])] <= hpi_data_in_reg[7:0];
			word_offset <= 0; /* Reset block offset word when setting LBA */
			hpi_state = STATE_IDLE;
		     end
		   2'b10:
		     begin
			/* Next HPI word will be written on bus. */
			is_bus_reading <= 0;
			is_bus_writing <= 1;
			hpi_state = STATE_IDLE;
		     end
		   2'b01:
		     begin
			/* Word will be read from bus and sent back on HPI. */
			is_bus_reading <= 1;
			is_bus_writing <= 0;
			hpi_state = STATE_BUS_READ;
		     end
		   default:
		     begin
			/* Malformed command? Do nothing. */
			is_bus_reading <= 0;
			is_bus_writing <= 0;
			hpi_state = STATE_IDLE;
		     end
		 endcase // case (hpi_data_in_reg[15:14])
		 
	      end
	    STATE_BUS_READ:
	      begin
		 read_enable <= 0;
		 write_enable <= 0;
		 bus_rw_control <= 1; /* READ */
		 
		 bus_op <= 1;   /* Begin op */
		 hpi_data_out_reg <= bus_data; /* Read a word off the bus. */

		 /* Increment word offset only if op is done. */
		 word_offset <= bus_ready ? (word_offset + 1) : word_offset;
		 
		 /* Spin until the bus is READY again. Then send back the word read. */
		 hpi_state = bus_ready ? STATE_MBX_WRITE_1 : STATE_BUS_READ;
	      end
	    STATE_BUS_WRITE:
	      begin
		 read_enable <= 0;
		 write_enable <= 0;
		 bus_rw_control <= 0; /* WRITE */
		 
		 bus_word_out <= hpi_data_in_reg; /* Put a word on the bus. */
		 bus_op <= 1;   /* Begin op */

		 /* Increment word offset only if op is done. */
		 word_offset <= bus_ready ? (word_offset + 1) : word_offset;
		 
		 /* Spin until the bus is READY again. Then send back the word read. */
		 hpi_state = bus_ready ? STATE_MBX_WRITE_1 : STATE_BUS_WRITE;
	      end
	    default:
	      begin
		 read_enable <= 0;
		 write_enable <= 0;
		 hpi_state = STATE_IDLE;
	      end
	  endcase // case (state)
       end // else: !if(reset)
   /**************************************************************************/
endmodule
/**************************************************************************/