`include "../pbit.v"

`timescale 1ns / 1ps

module tb_p_bit;

    // Parameters
    parameter CLK_PERIOD = 10;
    parameter RESET_PERIOD = 50;

    // Inputs
    reg clk;
    reg reset;
    reg signed [3:0] input_val;
    reg [1:0] bit_shift;

    // Outputs
    wire out;

    // Instantiate the unit under test (UUT)
    p_bit UUT (
        .clk(clk),
        .reset(reset),
        .input_val(input_val),
        .bit_shift(bit_shift),
        .out(out)
    );

    // Clock process definitions
    always begin
        #CLK_PERIOD clk = ~clk;
    end

    // Stimulus process
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        input_val = 4'b0000;
        bit_shift = 2'b00;
    end

endmodule

