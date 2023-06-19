// Takes an activation and adds a p-bit to it
// used to mimic the action of a COPY-gate

// Unsafe because it will overflow
module unsafe_gate_fusion(
    input signed [3:0] A_act,
    input b_node,
    output signed [3:0] out
);

    wire signed [1:0] B_act = 2*b_node - 1;

    // This is the unsafe part
    assign out = A_act + B_act;

endmodule

// Safe because it will saturate
module safe_gate_fusion(
    input signed [3:0] A_act,
    input b_node,
    output signed [3:0] out
);

    wire signed [1:0] B_act = 2*b_node - 1;

    // This is the safe part
    assign out_reg = (A_act + b_node) > 7 ? 7 : (A_act + b_node) < -8 ? -8 : (A_act + b_node);

endmodule

module COPY_gate(
    input [1:0] in,
    output signed [3:0] A_act,
    output signed [3:0] B_act
);

    // Split the input into 2 sections: A, B
    wire signed A = 2*in[0] - 1;
    wire signed B = 2*in[1] - 1;

    // Hard coded matrix multiplication
    // Saturation isn't needed
    assign A_act = B;
    assign B_act = A;

endmodule

module NOT_gate(
    input [1:0] in,
    output signed [3:0] A_act,
    output signed [3:0] B_act
);

    // Split the input into 2 sections: A != B
    wire signed [1:0] A = 2*in[0] - 1;
    wire signed [1:0] B = 2*in[1] - 1;

    // Hard coded matrix multiplication
    // Saturation isn't needed
    assign A_act = -1*B;
    assign B_act = -1*A;

endmodule

module p_AND_gate(
    input [2:0] in,
    output signed [3:0] A_act,
    output signed [3:0] B_act,
    output signed [3:0] C_act
);

    // Create signed input
    wire signed [1:0] A = 2*in[0] - 1;
    wire signed [1:0] B = 2*in[1] - 1;
    wire signed [1:0] C = 2*in[2] - 1;

    // Hard coded matrix multiplication
    // Saturation isn't needed
    assign A_act = -1*B + C*2 + 1;
    assign B_act = -1*A + C*2 + 1;
    assign C_act = A*2 + B*2 - 2;

endmodule

module p_OR_gate(
    input [2:0] in,
    output signed [3:0] A_act,
    output signed [3:0] B_act,
    output signed [3:0] C_act
);

    // Create signed input
    wire signed [1:0] A = 2*in[0] - 1;
    wire signed [1:0] B = 2*in[1] - 1;
    wire signed [1:0] C = 2*in[2] - 1;

    // Hard coded matrix multiplication
    // Saturation isn't needed
    assign A_act = B + C*2 - 1;
    assign B_act = A + C*2 - 1;
    assign C_act = A*2 + B*2 + 2;

endmodule

module p_HA_gate(
    input [3:0] in,
    output signed [3:0] A_act,
    output signed [3:0] B_act,
    output signed [3:0] S_act,
    output signed [3:0] C_act
);

    // Create signed input
    wire signed [1:0] A = 2*in[0] - 1;
    wire signed [1:0] B = 2*in[1] - 1;
    wire signed [1:0] S = 2*in[2] - 1;
    wire signed [1:0] C = 2*in[3] - 1;

    // Hard coded matrix multiplication
    assign A_act = -1*B + S + C*2 - 1;
    assign B_act = -1*A + S + C*2 - 1;
    assign S_act = -1*A + -1*B + C*2 + 1;
        // Saturation is needed
    assign C_act = (2*A + 2*B - C*2 + 2) > 7 ? 7 : (2*A + 2*B - C*2 + 2) < -8 ? -8 : (2*A + 2*B - C*2 + 2);

endmodule

module p_FA_gate(
    input [4:0] in,
    output signed [3:0] A_act,
    output signed [3:0] B_act,
    output signed [3:0] Cin_act,
    output signed [3:0] S_act,
    output signed [3:0] Cout_act
);

    // Create signed input
    wire signed [1:0] A = 2*in[0] - 1;
    wire signed [1:0] B = 2*in[1] - 1;
    wire signed [1:0] Cin = 2*in[2] - 1;
    wire signed [1:0] S = 2*in[3] - 1;
    wire signed [1:0] Cout = 2*in[4] - 1;

    // Hard coded matrix multiplication
    assign A_act = -1*B - Cin + S + Cout*2 - 1;
    assign B_act = -1*A - Cin + S + Cout*2 - 1;
    assign Cin_act = -1*A - B + S + Cout*2 - 1;
    assign S_act = A + B - Cin - Cout*2 + 1;
    // Saturation is needed
    assign Cout_act = (2*A + 2*B + 2*Cin - S*2 + 2) > 7 ? 7 : (2*A + 2*B + 2*Cin - S*2 + 2) < -8 ? -8 : (2*A + 2*B + 2*Cin - S*2 + 2);

endmodule