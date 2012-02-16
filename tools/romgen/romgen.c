/*
  This quick and dirty app generates a Verilog ROM
  given any binary file and the desired bus width.
 */

#include <stdio.h>
#include <stdlib.h>

int width;
FILE *fp;
char *buffer;
long bytes;
int addr_bits;

int nth_bit(int n) {
  int offset = n/8;
  if (offset >= bytes) return 0;
  else return (buffer[offset] & (1 << (n%8)));
}

int main(int argc, char **argv) {
  long t;
  long bit_count;
  long out_lines;
  long line, bitno;

  if ((argc != 3) || (sscanf(argv[1], "%d", &width)) != 1) {
    printf("Usage: %s WIDTH FILE\n", argv[0]);
    exit(0);
  }
  fp = fopen(argv[2], "r");
  if (fp == NULL) {
    printf("Could not open file '%s'!\n", argv[2]);
    exit(1);
  }
  fseek(fp, 0L, SEEK_END);
  bytes = ftell(fp);
  fseek(fp, 0L, SEEK_SET);

  if ((buffer = (char *)malloc(bytes+1)) == NULL) {
    printf("Out of memory!\n");
    exit(1);
  }

  if (fread(buffer, bytes, 1, fp) != 1) {
    printf("Error reading input file!\n");
    exit(1);    
  }
  fclose(fp);

  bit_count = 8*bytes;
  t = out_lines = (bit_count/width) + (bit_count%width);
  for (addr_bits = 0; t; addr_bits++) t >>= 1;

  printf("module rom(clk, address, data);\n"
	 "   input wire clk;\n"
	 "   output reg [%d:0] data;\n"
	 "   input [%d:0] address;\n"
	 "   reg [%d:0] addr_reg;\n\n"
	 "   always @(posedge clk)\n"
	 "      addr_reg <= address;\n\n"
	 "   always @*\n"
	 "     begin\n"
	 "        case (addr_reg)\n", width-1, addr_bits-1, addr_bits-1);

  for (line = 0; line < out_lines; line++) {
    printf("    	  %d'd%ld : data = %d'b", addr_bits, line, width);
    for (bitno = 0; bitno < width; bitno++) {
      if (nth_bit((line*width)+bitno)) {
	printf("1");
      } else {
	printf("0");
      }
    }
    printf(";\n");
  }
  
  printf("    	  default : data = %d'b0;\n"
	 "        endcase\n"
	 "     end\n"
	 "endmodule\n", width);
  
  return 0;
}
