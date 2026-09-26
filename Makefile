RTL_DIR := rtl
TB_DIR  := tb

RTL_SRCS := $(RTL_DIR)/ALU.sv \
            $(RTL_DIR)/pc_counter.sv \
            $(RTL_DIR)/control_unit.sv \
            $(RTL_DIR)/instruction_memory.sv \
            $(RTL_DIR)/regfile1379.sv \
            $(RTL_DIR)/regfile2468.sv \
            $(RTL_DIR)/regfile5.sv \
            $(RTL_DIR)/regfile9.sv \
            $(RTL_DIR)/core1.sv \
            $(RTL_DIR)/core2.sv \
            $(RTL_DIR)/core5.sv \
            $(RTL_DIR)/core9.sv \
            $(RTL_DIR)/heat_set.sv \
            $(RTL_DIR)/top.sv

VFLAGS := --cc --exe --build --trace --coverage --assert \
          -Wno-fatal -Wno-WIDTH -Wno-UNUSED --top-module top

.PHONY: all sim sim-verbose cov wave clean

all: sim

obj_dir/Vtop: $(RTL_SRCS) $(TB_DIR)/top.cpp
	verilator $(VFLAGS) $(RTL_SRCS) $(TB_DIR)/top.cpp

sim: obj_dir/Vtop
	./obj_dir/Vtop | grep -v "ASSERTION PASS\|Division performed"

sim-verbose: obj_dir/Vtop
	./obj_dir/Vtop

cov: sim
	@echo "--- cover property hit counts ---"
	@tr '\001\002' '|=' < coverage.dat | \
	  sed -n "s/.*|f=\([^|]*\)|l=\([0-9]*\)|.*|o=cover|.*|h=\([^']*\)' \([0-9]*\)/\1:\2  \3  hits=\4/p"

wave:
	gtkwave waveform.vcd &

clean:
	rm -rf obj_dir waveform.vcd coverage.dat
