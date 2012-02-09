#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define BLOCKSIZE 512

void printusage(int argc, char *argv[]) {
  printf("Usage: %s -n BLOCKNUM -f FILE\n", argv[0]);
}


int main(int argc, char *argv[]) {
  FILE *fp;
  unsigned int blknum, i;
  unsigned char block[BLOCKSIZE];
  char c;

  blknum = 0;

  if (argc != 5) {
    printusage(argc, argv);
    exit(0);
  }

  while ((c = getopt(argc, argv, "n:f:h")) != -1) {
    switch(c) {
    case 'n':
      blknum = atoi(optarg);
      break;
    case 'f':
      fp = fopen(optarg, "r");
      if (fp == NULL) {
	printf("Could not open file: '%s'\n", optarg);
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

  if (fseek(fp, BLOCKSIZE * blknum, SEEK_SET) < 0) {
    printf("Error seeking to block no. %d!\n", blknum);
    fclose(fp);
    exit(1);
  }

  if (fread(&block, BLOCKSIZE, 1, fp) != 1) {
    printf("Error reading block no. %d!\n", blknum);
    fclose(fp);
    exit(1);
  }

  /* Block was actually read; print it. */
  for (i = 0; i < BLOCKSIZE; i++) {
    if ((i % 16) == 0) printf("\n");
    printf("%02x ", block[i]);
  }
  printf("\n");

  fclose(fp);
  return 0;
}
