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
    input [5:0] in,
    output wire out
);

    // Split the input into 2 sections: activation (A), bit shift (BS)
    wire [3:0] input_val = in[5:2];
    wire [1:0] bit_shift = in[1:0];

    // Instantiate the lfsr5_galois module
    wire [4:0] rng_val;
    lfsr5_galois lfsr_inst (
        .clk(clk),
        .reset(reset),
        .lfsr(rng_val)
    );

    // Apply the bit shift to A according to the value of BS
    wire [3:0] shifted_A;
    always @(*) begin
        case (bit_shift)
            2'b00: shifted_A = input_val;
            2'b01: shifted_A = input_val >> 1;
            2'b10: shifted_A = input_val << 1;
            2'b11: shifted_A = input_val << 2;
            default: shifted_A = 4'b0;
        endcase
    end

    // Compare the shifted value of A with R and assign the result to out
    always @(*) begin
        out = (shifted_A < rng_val) ? 1'b1 : 1'b0;
    end

endmodule