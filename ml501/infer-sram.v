 /*************************************************************************
 *                     This file is part of Stierlitz:                    *
 *               https://github.com/asciilifeform/Stierlitz               *
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
module infer_sram
  #(parameter
    ADDR_WIDTH=8,
    DATA_WIDTH=8,
    SIZE=1024)
   (input                   clk,
    input  [ADDR_WIDTH-1:0] address,
    input                   we,
    input                   oe,
    inout  [DATA_WIDTH-1:0] data
    );

   reg [DATA_WIDTH-1:0]     mem [0:SIZE-1];

   wire [DATA_WIDTH-1:0] data_out;

   /* synthesis syn_ramstyle="block_ram" */
   reg [ADDR_WIDTH-1:0]  read_address;
      
   always @(posedge clk)
     if (we) mem[address] <= data + 1;

   always @(posedge clk)
     if (oe) read_address <= address;
   
   assign data_out = mem[read_address];

   assign data = oe ? data_out : 'bz;

endmodule // infer_sram
/**************************************************************************/
