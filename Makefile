ASM = qtasm/qtasm.exe
WINE = wine
BURNER = /usr/local/bin/ezotgdbg
BIN = stierlitz

all :	$(BIN)

stierlitz : $(BIN).asm
	$(WINE) $(ASM) -r $(BIN).asm build/$(BIN)

burn :
	$(BURNER) -w $(BIN).bin

clean :
	rm -f *.bin *.dat *.fix *.lst *.obj *.sym build/*.*
