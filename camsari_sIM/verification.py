import cocotb
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.regression import TestFactory

@cocotb.test()
async def test_p_bit(dut):
    dut.reset <= 1
    await RisingEdge(dut.clk)
    dut.reset <= 0

    for input_val in range(-8, 8):  # Test all possible 4-bit signed values
        for bit_shift in range(4):  # Test all possible 2-bit values
            dut.input_val <= input_val
            dut.bit_shift <= bit_shift
            await RisingEdge(dut.clk)
            await FallingEdge(dut.clk)

            # Calculate the expected output
            shifted_A = input_val
            if bit_shift == 1:
                shifted_A = input_val >> 1
            elif bit_shift == 2:
                shifted_A = input_val << 1
            elif bit_shift == 3:
                shifted_A = input_val << 2

            # The 4 least significant bits of the LFSR
            rng_val = int(dut.lfsr.value) & 0xF

            expected_out = 1 if shifted_A < rng_val else 0

            # Check the output
            assert dut.out.value == expected_out, f"For input_val={input_val} and bit_shift={bit_shift}, expected out={expected_out} but got {dut.out.value}"

factory = TestFactory(test_p_bit)
factory.generate_tests()
