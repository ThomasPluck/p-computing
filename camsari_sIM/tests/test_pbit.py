import cocotb
from cocotb.regression import TestFactory
from cocotb.triggers import RisingEdge, FallingEdge

async def p_bit_test(dut):
    """Test for p_bit module."""

    # Reset the module
    dut.reset <= 1
    await RisingEdge(dut.clk)
    dut.reset <= 0

    # Test the bit shift functionality
    dut.input_val <= 4
    for shift_val in range(4):
        dut.bit_shift <= shift_val
        await RisingEdge(dut.clk)
        expected_shifted_val = 4 >> shift_val if shift_val < 3 else 0
        assert dut.shifted_A.value == expected_shifted_val, f"Shifted value was incorrect for bit_shift {shift_val}"

    # Test the output based on shifted_A and rng_val
    dut.input_val <= 6
    dut.bit_shift <= 1
    await RisingEdge(dut.clk)
    rng_val = dut.rng_val.value
    expected_output = 1 if 3 < rng_val else 0
    await FallingEdge(dut.clk)
    assert dut.out.value == expected_output, "Output was incorrect based on shifted_A and rng_val comparison"

# Set up the test
tf = TestFactory()
tf.add_option("-sv")
tf.generate_tests()