`include "pbit.v"
`include "systems.v"

// This module is the top row HA-gates in the sparse multiplier
// Offset of top_row is always assumed to be zero.
// At each A,B of the HALF adders, we connect the output of AND_system
module top_row
#(
    parameter N_BITS = 8;
)
(
    input [4:0] clk,A
    input [1:0] bitshift,
    input reset,
    inout [(N_BITS >>> 1)-1:0] A,
    inout [(N_BITS >>> 1)-1:0] B,
    inout [(N_BITS >>> 1)-1:0] S,
    input [(N_BITS >>> 1)-1:0] s_node
);

    terminal_AND_system AND_00(
        .clk(clk[0:2]),
        .reset(reset),
        .bit_shift(bitshift),
        .A(A[0]),
        .B(B[0]),
        .C(S[0])
    );

    AND_system AND_01(
        .clk(clk[1:3]),
        .reset(reset),
        .bit_shift(bitshift),
        .A(A[0]),
        .B(B[1])
    );

    AND_system AND_10(
        .clk(clk[2:4]),
        .reset(reset),
        .bit_shift(bitshift),
        .A(A[1]),
        .B(B[0]),
    );

    terminal_HA_system HA_0110(
        .clk(clk[1:3]),
        .reset(reset),
        .bit_shift(bitshift),
        .A(AND_10.c_node)
        .B(AND_01.c_node)
        .S(S[1])
    );

    generate
        genvar i;
        for (i = 0; i < (N_BITS >>> 1); i = i + 1) begin : top_row_gen
            genvar COL_OFFSET = i % 5;
            AND_system AND_0_inst(
                .clk(clk[(2+COL_OFFSET) % 5:COL_OFFSET]),
                .reset(reset),
                .bit_shift(bitshift),
                .A(A[i]),
                .B(B[0])
            );

            AND_system AND_1_inst(
                .clk(clk[(3+COL_OFFSET) % 5:(1+COL_OFFSET)]),
                .reset(reset),
                .bit_shift(bitshift),
                .A(A[i]),
                .B(B[1])
            );
            
            HA_system HA_inst(
                .clk(clk[(4+COL_OFFSET) % 5:(2+COL_OFFSET)]),
                .reset(reset),
                .bit_shift(bitshift),
                .a_node(AND_0_inst.C),
                .b_node(AND_1_inst.C),
                .s_node(s_node[i])
                .S(S[i])
                .C(S[])
            );

            assign AND_0_inst.c_node = HA_system.A;
            assign AND_1_inst.c_node = HA_system.B;

        end
    endgenerate

endmodule

// Intermediate rows consist of nothing put FA's capped with a terminal FA
module middle_row
#(
    parameter N_BITS = 8;
    parameter OFFSET = 0;
)
(
    input [4:0] clk,
    inout [(N_BITS >>> 1)-1:0] A,
    inout [(N_BITS >>> 1)-1:0] B,
    output [(N_BITS >>> 1)-1:0] S
);

    generate
        genvar i;
        for (i = 0; i < (N_BITS >>> 1); i = i + 1) begin : middle_row_gen
            genvar COL_OFFSET = i % 5;
            AND_system(
                .clk(clk[(3+COL_OFFSET) % 5:COL_OFFSET]),
                .reset(1'b0),
                .bit_shift(2'b00),
                .A(A[i]),
                .B(B[i]),
                .C(S[i])
        end
    endgenerate

endmodule

// Bottom row has no offset, but is terminal FA's followed by a terminal HA
module bottom_row
#(
    parameter N_BITS = 8;
)
(
    input [4:0] clk,
    inout [(N_BITS >>> 1)-1:0] A,
    inout [(N_BITS >>> 1)-1:0] B,
    output [(N_BITS >>> 1)-1:0] S
);

    generate
        genvar i;
        for (i = 0; i < (N_BITS >>> 1); i = i + 1) begin : bottom_row_gen
            genvar COL_OFFSET = i % 5;
            AND_system(
                .clk(clk[(3+COL_OFFSET) % 5:COL_OFFSET]),
                .reset(1'b0),
                .bit_shift(2'b00),
                .A(A[i]),
                .B(B[i]),
                .C(S[i])
        end
    endgenerate

endmodule
