IVERILOG ?= iverilog
VVP      ?= vvp
VERILATOR?= verilator
SIMDIR   := sim_build
RTL      := $(wildcard rtl/*.v)
TB       := $(wildcard tb/tb_*.v)

.PHONY: all test lint clean

all: test

$(SIMDIR):
	mkdir -p $(SIMDIR)

$(SIMDIR)/tb_alu.vvp: tb/tb_alu.v rtl/ALU.v | $(SIMDIR)
	$(IVERILOG) -g2012 -Wall -o $@ $^

$(SIMDIR)/tb_register_file.vvp: tb/tb_register_file.v rtl/Register_File.v | $(SIMDIR)
	$(IVERILOG) -g2012 -Wall -o $@ $^

$(SIMDIR)/tb_memory.vvp: tb/tb_memory.v rtl/Memory_Top.v rtl/Instruction_ROM.v rtl/Data_RAM.v rtl/Video_Memory.v | $(SIMDIR)
	$(IVERILOG) -g2012 -Wall -o $@ $^

$(SIMDIR)/tb_soc.vvp: tb/tb_soc.v $(RTL) | $(SIMDIR)
	$(IVERILOG) -g2012 -Wall -o $@ $^

$(SIMDIR)/tb_task3.vvp: tb/tb_task3.v $(RTL) | $(SIMDIR)
	$(IVERILOG) -g2012 -Wall -o $@ $^

test: $(SIMDIR)/tb_alu.vvp $(SIMDIR)/tb_register_file.vvp $(SIMDIR)/tb_memory.vvp $(SIMDIR)/tb_soc.vvp $(SIMDIR)/tb_task3.vvp
	@set -e; \
	for t in tb_alu tb_register_file tb_memory tb_soc tb_task3; do \
		echo "== $$t =="; \
		$(VVP) $(SIMDIR)/$$t.vvp | tee $(SIMDIR)/$$t.log; \
		grep -q '^PASS' $(SIMDIR)/$$t.log; \
	done

lint:
	$(VERILATOR) --lint-only -Wall -Wno-DECLFILENAME $(RTL)

clean:
	rm -rf $(SIMDIR)
