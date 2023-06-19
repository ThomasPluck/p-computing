# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES := $(PWD)/pbit_tb.v
VERILOG_SOURCES += $(PWD)/gates_tb.v

# use VHDL_SOURCES for VHDL files

# pbit test variables
PBIT_TOPLEVEL = tb_p_bit
PBIT_MODULE = pbit_test

# gates test variables
GATES_TOPLEVEL = tb_gates
GATES_MODULE = gates_test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

test_pbit:
	$(MAKE) TOPLEVEL=$(PBIT_TOPLEVEL) MODULE=$(PBIT_MODULE)

test_gates:
	$(MAKE) TOPLEVEL=$(GATES_TOPLEVEL) MODULE=$(GATES_MODULE)

test_all: test_pbit test_gates