import cocotb
from cocotb.triggers import Timer
from cocotb.regression import TestFactory


@cocotb.test()
async def test_unsafe_gate_fusion(dut):
    for A_act in range(-7, 7):
        for b_node in range(2):
            dut.A_act = A_act
            dut.b_node = b_node
            await Timer(1, units='ns') 

            print(f"Wire A_act Value: {dut.A_act.value.signed_integer}")
            print(f"A_act Reg: {dut.unsafe_gate_fusion.A_act.value.signed_integer}")
            print(f"b_node Reg: {dut.unsafe_gate_fusion.b_node.value.signed_integer}")
            print(f"out Reg: {dut.out.value}")

            expected_output = A_act + (2 * b_node - 1)
            assert (
                dut.out.value.signed_integer == expected_output
            ), f"Error: {dut.out.value.signed_integer}, Expected: {expected_output}"

@cocotb.test()
async def test_safe_gate_fusion(dut):
    for A_act in range(-8, 8):
        for b_node in range(2):
            dut.A_act = A_act
            dut.b_node = b_node
            await Timer(1, units="ns")

            expected_output = min(max(A_act + b_node, -8), 7)
            assert (
                dut.out.value.signed_integer == expected_output
            ), f"Error: {dut.out.value.signed_integer}, Expected: {expected_output}"


@cocotb.test()
async def test_COPY_gate(dut):
    for in_val in range(4):
        dut.in_ = in_val
        await Timer(1, units="ns")

        expected_A_act = 2 * (in_val & 1) - 1
        expected_B_act = 2 * ((in_val >> 1) & 1) - 1
        assert (
            dut.A_act.value == expected_A_act
        ), f"Error: {dut.A_act.value}, Expected: {expected_A_act}"
        assert (
            dut.B_act.value == expected_B_act
        ), f"Error: {dut.B_act.value}, Expected: {expected_B_act}"


@cocotb.test()
async def test_NOT_gate(dut):
    for in_val in range(4):
        dut.in_ = in_val
        await Timer(1, units="ns")

        expected_A_act = -1 * (2 * ((in_val >> 1) & 1) - 1)
        expected_B_act = -1 * (2 * (in_val & 1) - 1)
        assert (
            dut.A_act.value == expected_A_act
        ), f"Error: {dut.A_act.value}, Expected: {expected_A_act}"
        assert (
            dut.B_act.value == expected_B_act
        ), f"Error: {dut.B_act.value}, Expected: {expected_B_act}"


@cocotb.test()
async def test_p_AND_gate(dut):
    for in_val in range(8):
        dut.in_ = in_val
        await Timer(1, units="ns")

        A = 2 * (in_val & 1) - 1
        B = 2 * ((in_val >> 1) & 1) - 1
        C = 2 * ((in_val >> 2) & 1) - 1

        expected_A_act = -1 * B + C * 2 + 1
        expected_B_act = -1 * A + C * 2 + 1
        expected_C_act = A * 2 + B * 2 - 2

        assert (
            dut.A_act.value == expected_A_act
        ), f"Error: {dut.A_act.value}, Expected: {expected_A_act}"
        assert (
            dut.B_act.value == expected_B_act
        ), f"Error: {dut.B_act.value}, Expected: {expected_B_act}"
        assert (
            dut.C_act.value == expected_C_act
        ), f"Error: {dut.C_act.value}, Expected: {expected_C_act}"


@cocotb.test()
async def test_p_OR_gate(dut):
    for in_val in range(8):
        dut.in_ = in_val
        await Timer(1, units="ns")

        A = 2 * (in_val & 1) - 1
        B = 2 * ((in_val >> 1) & 1) - 1
        C = 2 * ((in_val >> 2) & 1) - 1

        expected_A_act = B + C * 2 - 1
        expected_B_act = A + C * 2 - 1
        expected_C_act = A * 2 + B * 2 + 2

        assert (
            dut.A_act.value == expected_A_act
        ), f"Error: {dut.A_act.value}, Expected: {expected_A_act}"
        assert (
            dut.B_act.value == expected_B_act
        ), f"Error: {dut.B_act.value}, Expected: {expected_B_act}"
        assert (
            dut.C_act.value == expected_C_act
        ), f"Error: {dut.C_act.value}, Expected: {expected_C_act}"


@cocotb.test()
async def test_p_HA_gate(dut):
    for in_val in range(4):
        dut.in_ = in_val
        await Timer(1, units="ns")

        A = 2 * (in_val & 1) - 1
        B = 2 * ((in_val >> 1) & 1) - 1

        expected_A_act = B + A * 2 - 1
        expected_B_act = A + B * 2 - 1

        assert (
            dut.A_act.value == expected_A_act
        ), f"Error: {dut.A_act.value}, Expected: {expected_A_act}"
        assert (
            dut.B_act.value == expected_B_act
        ), f"Error: {dut.B_act.value}, Expected: {expected_B_act}"


@cocotb.test()
async def test_p_FA_gate(dut):
    for in_val in range(8):
        dut.in_ = in_val
        await Timer(1, units="ns")

        A = 2 * (in_val & 1) - 1
        B = 2 * ((in_val >> 1) & 1) - 1
        C = 2 * ((in_val >> 2) & 1) - 1

        expected_A_act = B + C * 2 - 1
        expected_B_act = A + C * 2 - 1
        expected_C_act = A * 2 + B * 2 + C * 2

        assert (
            dut.A_act.value == expected_A_act
        ), f"Error: {dut.A_act.value}, Expected: {expected_A_act}"
        assert (
            dut.B_act.value == expected_B_act
        ), f"Error: {dut.B_act.value}, Expected: {expected_B_act}"
        assert (
            dut.C_act.value == expected_C_act
        ), f"Error: {dut.C_act.value}, Expected: {expected_C_act}"
