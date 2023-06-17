# Makefile

# Specify the simulator to use
SIM=icarus

# Specify the Verilog source files
VERILOG_SOURCES=$(PWD)/pbit.v

# Include cocotb's make rules
include $(shell cocotb-config --makefiles)/Makefile.sim

# Add a rule for the p_bit module
test_p_bit:
    MODULE=verification TOPLEVEL=p_bit $(MAKE) sim

# Add a rule to run all tests
all: test_p_bit

.PHONY: all test_p_bit