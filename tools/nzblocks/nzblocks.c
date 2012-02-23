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

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define BLOCKSIZE 512

void printusage(int argc, char *argv[]) {
  printf("Usage: %s OPTS -f FILE\n", argv[0]);
  printf("\t-b\tSave non-zero blocks as binary files.\n");
  printf("\t-a\tSave non-zero blocks as ASM-include files, with DB statements.\n\n");
}


void saveblock_binary(unsigned int n, unsigned char *block) {
  FILE *fp;
  char filename[128];
  sprintf(filename, "blk-%d.bin", n);
  fp = fopen(filename, "w");
  if (fwrite(block, BLOCKSIZE, 1, fp) <= 0) {
    printf("Error saving block %d to file: '%s'\n", n, filename);
    exit(1);
  }
  fclose(fp);
}


void saveblock_asm(unsigned int n, unsigned char *block) {
  FILE *fp;
  char filename[128];
  unsigned int i;
  sprintf(filename, "blk-%d.inc", n);
  fp = fopen(filename, "w");
  fprintf(fp, ";; Block no. %d\n", n);
  fprintf(fp, "block_%d:\n", n);
  for (i = 0; i < BLOCKSIZE; i++) {
    fprintf(fp, "\tdb\t0x%02x\n", block[i]);
  }
  fclose(fp);
}


int main(int argc, char *argv[]) {
  FILE *fp;
  unsigned int nzblocks, blk_count, i;
  unsigned char block[BLOCKSIZE];
  char c;
  void (*saver)(unsigned int, unsigned char*);

  if (argc != 4) {
    printusage(argc, argv);
    exit(0);
  }

  saver = saveblock_binary; /* default */

  while ((c = getopt(argc, argv, "baf:h")) != -1) {
    switch(c) {
    case 'a':
      printf("Saving blocks as ASM Include...\n");
      saver = saveblock_asm;
      break;
    case 'b':
      printf("Saving blocks as BINARY...\n");
      break;
    case 'f':
      fp = fopen(optarg, "r");
      if (fp == NULL) {
	printf("Could not open file: '%s'\n", optarg);
	exit(1);
      }
      printf("Reading file: '%s'\n", optarg);
      break;
    case 'h':
      printusage(argc, argv);
      exit(0);
      break;
    }
  }

  if (fp == NULL) {
    printf("Must specify filename!\n");
    exit(1);
  }

  blk_count = 0;
  nzblocks = 0;

  while (fread(&block, BLOCKSIZE, 1, fp) > 0) {
    for (i = 0; i < BLOCKSIZE; i++) {
      if (block[i] != 0) {
	printf("Block %d non-zero\n", blk_count);
	(*saver)(blk_count, block);
	nzblocks++;
	break;
      }
    }
    blk_count++;
  }

  printf("%d non-zero blocks\n", nzblocks);

  fclose(fp);
  return 0;
}
