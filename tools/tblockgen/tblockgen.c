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
  printf("Usage: %s -n BLOCKCOUNT -f FILE\n", argv[0]);
}


void make_block(unsigned int i, char *block) {
  int j;
  /*
  for (j = 0; j < BLOCKSIZE; j += 16) {
    sprintf(block + j, "%16d", i);
  }
  */
  for (j = 0; j < BLOCKSIZE; j += 4) {
    block[j] = (unsigned char)(i & 0xFF);
    block[j + 1] = (unsigned char)((i & 0xFF00) >> 8);
    block[j + 2] = (unsigned char)((i & 0xFF0000) >> 16);
    block[j + 3] = (unsigned char)((i & 0xFF000000) >> 24);
  }
}


int main(int argc, char *argv[]) {
  FILE *fp;
  unsigned int blk_count, i;
  char block[BLOCKSIZE];
  char c;

  blk_count = 0;

  if (argc != 5) {
    printusage(argc, argv);
    exit(0);
  }

  while ((c = getopt(argc, argv, "n:f:h")) != -1) {
    switch(c) {
    case 'n':
      blk_count = atoi(optarg);
      printf("Writing %d blocks...\n", blk_count);
      break;
    case 'f':
      fp = fopen(optarg, "w");
      if (fp == NULL) {
	printf("Could not create file: '%s'\n", optarg);
	exit(1);
      }
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

  if (blk_count == 0) {
    printf("Must specify block count!\n");
    exit(1);
  }

  for (i = 0; i < blk_count; i++) {
    make_block(i, block);
    if (fwrite(block, BLOCKSIZE, 1, fp) <= 0) {
      printf("Error saving block %d!\n", i);
      exit(1);
    }
  }

  fclose(fp);
  return 0;
}
