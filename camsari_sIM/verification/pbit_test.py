import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.regression import TestFactory


@cocotb.test()
async def test_tb_p_bit(dut):
    """Test the p_bit module."""

    # Reset the DUT
    dut.reset = 1
    await RisingEdge(dut.clk)
    dut.reset = 0

    mm = lambda x : max(min(7,x),-8)

    # Map bit shift keys to expected transforms
    bit_shift_map = {
        0: lambda x: mm(x),
        1: lambda x: mm(x // 2),
        2: lambda x: mm(x * 2),
        3: lambda x: mm(x * 4),
    }

    # Test case 1: Test all possible values of input_val and bit_shift
    for input_val in range(-8, 8):
        for bit_shift in range(4):

            dut.input_val = input_val
            dut.bit_shift = bit_shift

            await FallingEdge(dut.clk)
            await RisingEdge(dut.clk)

            expected_output = int(
                dut.UUT.shifted_A.value.signed_integer
                < dut.UUT.rng_val.value.signed_integer
            )
            print(dut.UUT.shifted_A.value.signed_integer)

            assert (
                dut.out.value.integer == expected_output
            ), f"p-bit test failed for input_val={input_val}, bit_shift={bit_shift}"

    # Test case 2: Test reset functionality
    dut.reset = 1
    await RisingEdge(dut.clk)
    assert dut.out.value.integer == 0, "Reset test failed"
    dut.reset = 0