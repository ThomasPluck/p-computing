import cocotb
from cocotb.regression import TestFactory
from cocotb.triggers import RisingEdge

async def lfsr5_galois_test(dut):
    """Test for lfsr5_galois module."""

    # Reset the module
    dut.reset <= 1
    await RisingEdge(dut.clk)
    dut.reset <= 0
    
    # Check the initial state of the LFSR
    assert dut.lfsr.value == 1, "Wrong initial state of LFSR"

    # Apply a few clock cycles and check if the LFSR produces the correct sequence
    expected_sequence = [1, 16, 8, 4, 2]
    for i, expected_val in enumerate(expected_sequence):
        await RisingEdge(dut.clk)
        assert dut.lfsr.value == expected_val, f"LFSR output was incorrect on cycle {i+1}"

# Set up the test
tf = TestFactory()
tf.add_option("-sv")
tf.generate_tests()