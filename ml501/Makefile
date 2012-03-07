# Project Name
PROJ=stierlitz_demo

# FPGA Type
DEVICE=xc5vlx50ff676

# Address of FPGA in the JTAG chain
FPGA_ADDR=4

# Address of PROM in the JTAG chain
PROM_ADDR=2

# Xilinx binaries
BIN=/opt/Xilinx/13.3/ISE_DS/ISE/bin/lin64
#BIN=/opt/Xilinx/13.3/ISE_DS/ISE/bin/lin

# Burner program
BURNER=/opt/Xilinx/13.3/ISE_DS/ISE/bin/lin64/impact
#BURNER=/opt/Xilinx/13.3/ISE_DS/ISE/bin/lin/impact

# Top module name
TOPMOD=stierlitz_demo_top

UCF=ml501

default: $(PROJ).bin

$(PROJ).ngc: $(TOPMOD).v
	echo "run -ifn $(TOPMOD).v -ifmt Verilog -ofn $(PROJ) -top $(TOPMOD) -p \
	$(DEVICE) -opt_mode Speed -opt_level 1" | $(BIN)/xst

$(PROJ).ngd: $(PROJ).ngc
	$(BIN)/ngdbuild -aul -p $(DEVICE) -uc $(UCF).ucf $(PROJ).ngc

$(PROJ).ncd: $(PROJ).ngd
	$(BIN)/map -w -detail -pr b $(PROJ).ngd

$(PROJ).pcf: $(PROJ).ngd
	$(BIN)/map -w -detail -pr b $(PROJ).ngd

parout.ncd: $(PROJ).ncd
	$(BIN)/par -w $(PROJ).ncd parout.ncd $(PROJ).pcf

$(PROJ).bit: parout.ncd
	$(BIN)/bitgen -w parout.ncd $(PROJ).bit $(PROJ).pcf

$(PROJ).bin: $(PROJ).bit
	$(BIN)/promgen -w -p mcs -o $(PROJ).mcs -u 0 $(PROJ).bit

$(PROJ)-jtag.cmd:
	echo "setMode -bs" > $(PROJ)-jtag.cmd;
	echo "setCable -port auto" >> $(PROJ)-jtag.cmd;
	echo "Identify -inferir" >> $(PROJ)-jtag.cmd;
	echo "ReadIdcode -p $(FPGA_ADDR)" >> $(PROJ)-jtag.cmd;
	echo "assignFile -p $(FPGA_ADDR) -file $(PROJ).bit" >> $(PROJ)-jtag.cmd;
	echo "Program -p $(FPGA_ADDR)" >> $(PROJ)-jtag.cmd;
	echo "quit" >> $(PROJ)-jtag.cmd;

#$(PROJ)-prom.cmd:
#	echo "setMode -bs" > $(PROJ)-prom.cmd;
#	echo "setCable -target \"digilent_plugin\"" >> $(PROJ)-jtag.cmd;
#	echo "Identify -inferir" >> $(PROJ)-prom.cmd;
#	echo "ReadIdcode -p $(PROM_ADDR)" >> $(PROJ)-prom.cmd;
#	echo "assignFile -p $(PROM_ADDR) -file $(PROJ).bit" >> $(PROJ)-prom.cmd;
#	echo "Program -p $(PROM_ADDR)" >> $(PROJ)-prom.cmd;
#	echo "quit" >> $(PROJ)-prom.cmd;

jtag:	$(PROJ).bin $(PROJ)-jtag.cmd
	$(BURNER) -batch $(PROJ)-jtag.cmd

#prom:	$(PROJ).bin $(PROJ)-prom.cmd
#	$(BURNER) -batch $(PROJ)-prom.cmd

clean:
	rm -rf $(PROJ).bgn $(PROJ).bin $(PROJ).bit $(PROJ).bld \
	$(PROJ).drc $(PROJ).map $(PROJ)_map.xrpt $(PROJ).mrp \
	$(PROJ).ncd $(PROJ).ngc $(PROJ).ngd $(PROJ)_ngdbuild.xrpt \
	$(PROJ).ngm $(PROJ)_par.xrpt $(PROJ).pcf $(PROJ).prm \
	$(PROJ)_summary.xml $(PROJ)_usage.xml $(PROJ)_xst.xrpt \
	netlist.lst parout.ncd parout.pad parout_pad.csv \
	parout_pad.txt parout.par parout.ptwx parout.unroutes \
	parout.xpi xlnx_auto_0.ise xlnx_auto_0_xdb xst _xmsgs \
	$(PROJ)-prom.cmd $(PROJ)-jtag.cmd $(PROJ).mcs test.txt \
	*.log parout.* *.drc *.xrpt *.xwbt *.cfi *webtalk* *.html *.cmd *.xsl \
	xst xlnx_auto* _x* sim *.vcd
