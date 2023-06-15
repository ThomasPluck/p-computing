module gate_fusion(
    input [7:0] in
    output [3:0] out
);

    // Split the input into 2 sections, A,B
    wire [3:0] A = in[0:3];
    wire [3:0] B = in[4:7];

    // Add the two sections together
    always @(*) begin
        out = (A + B) > 15 ? 15 : (A + B) < 0 ? 0 : (A + B);
    end

endmodule

module COPY_gate(
    input [1:0] in
    output [7:0] out
);

    // Split the input into 2 sections: A --> B
    wire A = in[0];
    wire B = in[1];

    // Split the output into 2 sections: 4-bit activation of A, B...
    wire [3:0] A_act = out[0:3];
    wire [3:0] B_act = out[4:7];

    // Hard coded matrix multiplication
    always @(*) begin
        A_act = (8 + B) > 15 ? 15 : (8 + B) < 0 ? 0 : (8 + B);
        B_act = (8 + A) > 15 ? 15 : (8 + A) < 0 ? 0 : (8 + A);
    end

endmodule

module NOT_gate(
    input [1:0] in
    output [7:0] out
);

    // Split the input into 2 sections: A != B
    wire A = in[0];
    wire B = in[1];

    // Split the output into 2 sections: 4-bit activation of A, B...
    wire [3:0] A_act = out[0:3];
    wire [3:0] B_act = out[4:7];

    // Hard coded matrix multiplication
    always @(*) begin
        A_act = (8 - B) > 15 ? 15 : (8 - B) < 0 ? 0 : (8 - B);
        B_act = (8 - A) > 15 ? 15 : (8 - A) < 0 ? 0 : (8 - A);
    end

endmodule


module p_AND_gate(
    input [2:0] in
    output [11:0] out
);

    // Split the input into 3 sections: A & B == C
    wire A = in[0];
    wire B = in[1];
    wire C = in[2];

    // Split the output into 3 sections: 4-bit activation of A, B, C...
    wire [3:0] A_act = out[0:3];
    wire [3:0] B_act = out[4:7];
    wire [3:0] C_act = out[8:11];

    // Hard coded matrix multiplication
    always @(*) begin
        A_act = (8 - B + C*2 + 1) > 15 ? 15 : (8 - B + C*2 + 1) < 0 ? 0 : (8 - B + C*2 + 1);
        B_act = (8 - A + C*2 + 1) > 15 ? 15 : (8 - A + C*2 + 1) < 0 ? 0 : (8 - A + C*2 + 1);
        C_act = (8 + A*2 + B*2 - 2) > 15 ? 15 : (8 + A*2 + B*2 - 2) < 0 ? 0 : (8 + A*2 + B*2 - 2);
    end

endmodule

module p_OR_gate(
    input [2:0] in
    output [11:0] out
);

    // Split the input into 3 sections: A | B == C
    wire A = in[0];
    wire B = in[1];
    wire C = in[2];

    // Split the output into 3 sections: 4-bit activation of A, B, C...
    wire [3:0] A_act = out[0:3];
    wire [3:0] B_act = out[4:7];
    wire [3:0] C_act = out[8:11];

    // Hard coded matrix multiplication
    always @(*) begin
        A_act = (8 - B + C*2 - 1) > 15 ? 15 : (8 - B + C*2 - 1) < 0 ? 0 : (8 - B + C*2 - 1);
        B_act = (8 - A + C*2 - 1) > 15 ? 15 : (8 - A + C*2 - 1) < 0 ? 0 : (8 - A + C*2 - 1);
        C_act = (8 + A*2 + B*2 + 2) > 15 ? 15 : (8 + A*2 + B*2 + 2) < 0 ? 0 : (8 + A*2 + B*2 + 2);
    end

endmodule

module p_HA_gate(
    input [3:0] in
    output [15:0] out
);

    // Split the input into 4 sections: A + B --> S, C
    wire A = in[0];
    wire B = in[1];
    wire S = in[2];
    wire C = in[3];

    // Split the output into 4 sections: 4-bit activation of A, B, S, C...
    wire [3:0] A_act = out[0:3];
    wire [3:0] B_act = out[4:7];
    wire [3:0] S_act = out[8:11];
    wire [3:0] C_act = out[12:15];

    // Hard coded matrix multiplication
    always @(*) begin
        A_act = (8 - B + S + C*2 - 1) > 15 ? 15 : (8 - B + S + C*2 - 1) < 0 ? 0 : (8 - B + S + C*2 - 1);
        B_act = (8 - A + S + C*2 - 1) > 15 ? 15 : (8 - A + S + C*2 - 1) < 0 ? 0 : (8 - A + S + C*2 - 1);
        S_act = (-A -B + C*2 + 1) > 15 ? 15 : (-A -B + C*2 + 1) < 0 ? 0 : (-A -B + C*2 + 1);
        C_act = (2*A + 2*B - C*2 + 2) > 15 ? 15 : (2*A + 2*B - C*2 + 2) < 0 ? 0 : (2*A + 2*B - C*2 + 2);
    end

endmodule

module p_FA_gate(
    input [4:0] in
    output [19:0] out
);

    // Split the input into 6 sections: A + B + Cin --> S, Cout
    wire A = in[0];
    wire B = in[1];
    wire Cin = in[2];
    wire S = in[3];
    wire Cout = in[4];

    // Split the output into 5 sections: 4-bit activation of A, B, Cin, S, Cout...
    wire [3:0] A_act = out[0:3];
    wire [3:0] B_act = out[4:7];
    wire [3:0] Cin_act = out[8:11];
    wire [3:0] S_act = out[12:15];
    wire [3:0] Cout_act = out[16:19];

    // Hard coded matrix multiplication
    always @(*) begin
        A_act = (8 - B - Cin + S + Cout*2 - 1) > 15 ? 15 : (8 - B - Cin + S + Cout*2 - 1) < 0 ? 0 : (8 - B - Cin + S + Cout*2 - 1);
        B_act = (8 - A - Cin + S + Cout*2 - 1) > 15 ? 15 : (8 - A - Cin + S + Cout*2 - 1) < 0 ? 0 : (8 - A - Cin + S + Cout*2 - 1);
        Cin_act = (8 - A - B + S + Cout*2 - 1) > 15 ? 15 : (8 - A - B + S + Cout*2 - 1) < 0 ? 0 : (8 - A - B + S + Cout*2 - 1);
        S_act = (8 + A + B - Cin - Cout*2 + 1) > 15 ? 15 : (8 + A + B - Cin - Cout*2 + 1) < 0 ? 0 : (8 + A + B - Cin - Cout*2 + 1);
        Cout_act = (8 + 2*A + 2*B + 2*Cin*2 - S*2 + 2) > 15 ? 15 : (8 + 2*A + 2*B + 2*Cin*2 - S*2 + 2) < 0 ? 0 : (8 + 2*A + 2*B + 2*Cin*2 - S*2 + 2);
    end

endmodule