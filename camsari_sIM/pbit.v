module lfsr5_galois (
    input clk,
    input reset,
    output [4:0] lfsr
);
    reg [4:0] r_lfsr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_lfsr <= 5'b00001;  // Non-zero initial state
        end else begin
            r_lfsr <= {r_lfsr[3:0], r_lfsr[4] ^ r_lfsr[2]};
        end
    end

    assign lfsr = r_lfsr;

endmodule

module p_bit (
    input clk,
    input reset,
    input signed [3:0] input_val,
    input [1:0] bit_shift,
    output out
);

    // Instantiate the lfsr5_galois module
    wire [4:0] lfsr;
    lfsr5_galois lfsr_inst (
        .clk(clk),
        .reset(reset),
        .lfsr(lfsr)
    );

    // Use only the 4 least significant bits of the LFSR for rng_val
    wire signed [3:0] rng_val = lfsr[3:0];

    // Create out register
    reg out_reg;

    // Apply the bit shift to A according to the value of BS
    reg signed [3:0] shifted_A;
    always @(posedge clk) begin
        case (bit_shift)
            2'b00: shifted_A = input_val > 7 ? 7 : input_val < -8 ? -8 : input_val;
            2'b01: shifted_A = input_val >>> 1 > 7 ? 7 : input_val >>> 1 < -8 ? -8 : input_val >>> 1;
            2'b10: shifted_A = input_val <<< 1 > 7 ? 7 : input_val <<< 1 < -8 ? -8 : input_val <<< 1;
            2'b11: shifted_A = input_val <<< 2 > 7 ? 7 : input_val <<< 2 < -8 ? -8 : input_val <<< 2;
            default: shifted_A = input_val;
        endcase
    end

    // Compare the shifted value of A with R and assign the result to out
    always @(negedge clk) begin
        out_reg = (shifted_A < rng_val) ? 1'b1 : 1'b0;
    end

    // Assign the output
    assign out = out_reg;

endmodule

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
