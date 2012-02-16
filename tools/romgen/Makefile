CFLAGS = -O2 -lm
PROJECT = romgen

all :	$(PROJECT)

main : $(PROJECT).c
	$(CC) $(CFLAGS) -o $(PROJECT) $(PROJECT).c

install: all
	cp $(PROJECT) /usr/bin

clean :
	rm -f core *.o $(PROJECT) *~

check-syntax:
	$(CC) -o nul -Wall -Wextra -pedantic -S $(CHK_SOURCES)