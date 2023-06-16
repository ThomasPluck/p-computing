module AND_system(
    input [2:0] clk,
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    inout A,
    inout B,
    inout C,
    inout c_node,
);

    wire [3:0] A_state;
    wire [3:0] B_state;
    wire [3:0] C_state;

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_state),
        .out(A)
    );
    
    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_state),
        .out(B)
    );

    p_AND_gate AND (
        .in({A, B, C}),
        .A_act(A_state),
        .B_act(B_state),
        .C_act(C_state)
    );

    wire [3:0] C_state_2;

    gate_fusion fusion (
        .in({C_state, c_node}),
        .out(C_state_2)
    );

    p_bit C_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(C_state_2),
        .out(C)
    );
    
endmodule

module HA_system(
    input [3:0] clk,
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    inout A,
    inout B,
    inout S,
    inout C,
    inout a_node,
    inout b_node,
    inout c_node,
    inout s_node,
);

    wire [3:0] A_state;
    wire [3:0] B_state;
    wire [3:0] S_state;
    wire [3:0] C_state;

    wire [3:0] A_state_2;
    wire [3:0] B_state_2;
    wire [3:0] S_state_2;
    wire [3:0] C_state_2;

    p_HA_gate HA (
        .in({A, B, S, C}),
        .A_act(A_state),
        .B_act(B_state),
        .S_act(S_state),
        .C_act(C_state)
    );

    gate_fusion A_fusion (
        .in({A_state, a_node}),
        .out(A_state_2)
    );

    gate_fusion B_fusion (
        .in({B_state, b_node}),
        .out(B_state_2)
    );

    gate_fusion S_fusion (
        .in({S_state, s_node}),
        .out(S_state_2)
    );

    gate_fusion C_fusion (
        .in({C_state, c_node}),
        .out(C_state_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_state_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_state_2),
        .out(B)
    );

    p_bit S_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(S_state_2),
        .out(S)
    );

    p_bit C_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(C_state_2),
        .out(C)
    );
    
endmodule

module FA_system(
    input clk [4:0],
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    inout A,
    inout B,
    inout Cin,
    inout S,
    inout Cout,
    inout a_node,
    inout b_node,
    inout cin_node,
    inout s_node,
    inout cout_node,
);

    wire [3:0] A_state;
    wire [3:0] B_state;
    wire [3:0] Cin_state;
    wire [3:0] S_state;
    wire [3:0] Cout_state;

    wire [3:0] A_state_2;
    wire [3:0] B_state_2;
    wire [3:0] Cin_state_2;
    wire [3:0] S_state_2;
    wire [3:0] Cout_state_2;

    p_FA_gate FA (
        .in({A, B, Cin, S, Cout}),
        .A_act(A_state),
        .B_act(B_state),
        .Cin_act(Cin_state),
        .S_act(S_state),
        .Cout_act(Cout_state)
    );

    gate_fusion A_fusion (
        .in({A_state, a_node}),
        .out(A_state_2)
    );

    gate_fusion B_fusion (
        .in({B_state, b_node}),
        .out(B_state_2)
    );

    gate_fusion Cin_fusion (
        .in({Cin_state, cin_node}),
        .out(Cin_state_2)
    );

    gate_fusion S_fusion (
        .in({S_state, s_node}),
        .out(S_state_2)
    );

    gate_fusion Cout_fusion (
        .in({Cout_state, cout_node}),
        .out(Cout_state_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_state_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_state_2),
        .out(B)
    );

    p_bit Cin_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(Cin_state_2),
        .out(Cin)
    );

    p_bit S_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(S_state_2),
        .out(S)
    );

    p_bit Cout_bit (
        .clk(clk[4]),
        .reset(reset),
        .in(Cout_state_2),
        .out(Cout)
    );

endmodule

module terminal_AND_system(
    input [2:0] clk,
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    inout A,
    inout B,
    inout C,
)

    wire [3:0] A_state;
    wire [3:0] B_state;
    wire [3:0] C_state;

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_state),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_state),
        .out(B)
    );

    p_bit C_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(C_state),
        .out(C)
    );

    p_AND_gate AND (
        .in({A, B, C}),
        .A_act(A_state),
        .B_act(B_state),
        .C_act(C_state)
    );

endmodule

module terminal_HA_system(
    input [3:0] clk,
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    inout A,
    inout B,
    inout S,
    inout C,
    inout a_node,
    inout b_node,
    inout c_node,
)

    wire [3:0] A_state;
    wire [3:0] B_state;
    wire [3:0] S_state;
    wire [3:0] C_state;

    wire [3:0] A_state_2;
    wire [3:0] B_state_2;
    wire [3:0] C_state_2;

    p_HA_gate HA (
        .in({A, B, S, C}),
        .A_act(A_state),
        .B_act(B_state),
        .S_act(S_state),
        .C_act(C_state)
    );

    gate_fusion A_fusion (
        .in({A_state, a_node}),
        .out(A_state_2)
    );

    gate_fusion B_fusion (
        .in({B_state, b_node}),
        .out(B_state_2)
    );

    gate_fusion C_fusion (
        .in({C_state, c_node}),
        .out(C_state_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_state_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_state_2),
        .out(B)
    );

    p_bit S_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(S_state),
        .out(S)
    );

    p_bit C_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(C_state_2),
        .out(C)
    );

endmodule

module terminal_FA_system(
    input clk [4:0],
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    inout A,
    inout B,
    inout Cin,
    inout S,
    inout Cout,
    inout a_node,
    inout b_node,
    inout cin_node,
    inout cout_node,
)

    wire [3:0] A_state;
    wire [3:0] B_state;
    wire [3:0] Cin_state;
    wire [3:0] S_state;
    wire [3:0] Cout_state;

    wire [3:0] A_state_2;
    wire [3:0] B_state_2;
    wire [3:0] Cin_state_2;
    wire [3:0] Cout_state_2;

    p_FA_gate FA (
        .in({A, B, Cin, S, Cout}),
        .A_act(A_state),
        .B_act(B_state),
        .Cin_act(Cin_state),
        .S_act(S_state),
        .Cout_act(Cout_state)
    );

    gate_fusion A_fusion (
        .in({A_state, a_node}),
        .out(A_state_2)
    );

    gate_fusion B_fusion (
        .in({B_state, b_node}),
        .out(B_state_2)
    );

    gate_fusion Cin_fusion (
        .in({Cin_state, cin_node}),
        .out(Cin_state_2)
    );

    gate_fusion Cout_fusion (
        .in({Cout_state, cout_node}),
        .out(Cout_state_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_state_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_state_2),
        .out(B)
    );

    p_bit Cin_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(Cin_state_2),
        .out(Cin)
    );

    p_bit S_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(S_state),
        .out(S)
    );

    p_bit Cout_bit (
        .clk(clk[4]),
        .reset(reset),
        .in(Cout_state_2),
        .out(Cout)
    );

endmodule

module corner_FA_system(
    input clk [4:0],
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    inout A,
    inout B,
    inout Cin,
    inout S,
    inout Cout,
    inout a_node,
    inout b_node,
    inout cin_node,
)

    wire [3:0] A_state;
    wire [3:0] B_state;
    wire [3:0] Cin_state;
    wire [3:0] S_state;
    wire [3:0] Cout_state;

    wire [3:0] A_state_2;
    wire [3:0] B_state_2;
    wire [3:0] Cin_state_2;

    p_FA_gate FA (
        .in({A, B, Cin, S, Cout}),
        .A_act(A_state),
        .B_act(B_state),
        .Cin_act(Cin_state),
        .S_act(S_state),
        .Cout_act(Cout_state)
    );

    gate_fusion A_fusion (
        .in({A_state, a_node}),
        .out(A_state_2)
    );

    gate_fusion B_fusion (
        .in({B_state, b_node}),
        .out(B_state_2)
    );

    gate_fusion Cin_fusion (
        .in({Cin_state, cin_node}),
        .out(Cin_state_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_state_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_state_2),
        .out(B)
    );

    p_bit Cin_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(Cin_state_2),
        .out(Cin)
    );

    p_bit S_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(S_state),
        .out(S)
    );

    p_bit Cout_bit (
        .clk(clk[4]),
        .reset(reset),
        .in(Cout_state),
        .out(Cout)
    );

endmodule