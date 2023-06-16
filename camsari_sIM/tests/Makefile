TOPLEVEL_LANG = verilog

VERILOG_SOURCES = ../pbit.v ../gates.v ../systems.v ../rows.v ../multiplier.v

# Test for lfsr5_galois module
TOPLEVEL = lfsr5_galois
MODULE = test_lfsr5_galois
include $(shell cocotb-config --makefiles)/Makefile.sim

# Test for p_bit module
TOPLEVEL = p_bit
MODULE = test_p_bit
include $(shell cocotb-config --makefiles)/Makefile.sim