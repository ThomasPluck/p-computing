module AND_system(
    input [2:0] clk,
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    output A,
    output B,
    output C,
    input c_node,
);

    wire signed [3:0] A_act;
    wire signed [3:0] B_act;
    wire signed [3:0] C_act;

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_act),
        .out(A)
    );
    
    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_act),
        .out(B)
    );

    p_AND_gate AND (
        .in({A, B, C}),
        .A_act(A_act),
        .B_act(B_act),
        .C_act(C_act)
    );

    wire signed [3:0] C_act_2;

    unsafe_gate_fusion fusion (
        .in({C_act, c_node}),
        .out(C_act_2)
    );

    p_bit C_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(C_act_2),
        .out(C)
    );
    
endmodule

module HA_system(
    input [3:0] clk,
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    output A,
    output B,
    output S,
    output C,
    input a_node,
    input b_node,
    input c_node,
    input s_node,
);

    wire signed [3:0] A_act;
    wire signed [3:0] B_act;
    wire signed [3:0] S_act;
    wire signed [3:0] C_act;

    wire signed [3:0] A_act_2;
    wire signed [3:0] B_act_2;
    wire signed [3:0] S_act_2;
    wire signed [3:0] C_act_2;

    p_HA_gate HA (
        .in({A, B, S, C}),
        .A_act(A_act),
        .B_act(B_act),
        .S_act(S_act),
        .C_act(C_act)
    );

    unsafe_gate_fusion A_fusion (
        .in({A_act, a_node}),
        .out(A_act_2)
    );

    unsafe_gate_fusion B_fusion (
        .in({B_act, b_node}),
        .out(B_act_2)
    );

    unsafe_gate_fusion S_fusion (
        .in({S_act, s_node}),
        .out(S_act_2)
    );

    safe_gate_fusion C_fusion (
        .in({C_act, c_node}),
        .out(C_act_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_act_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_act_2),
        .out(B)
    );

    p_bit S_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(S_act_2),
        .out(S)
    );

    p_bit C_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(C_act_2),
        .out(C)
    );
    
endmodule

module FA_system(
    input clk [4:0],
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    output A,
    output B,
    output Cin,
    output S,
    output Cout,
    input a_node,
    input b_node,
    input cin_node,
    input s_node,
    input cout_node,
);

    wire signed [3:0] A_act;
    wire signed [3:0] B_act;
    wire signed [3:0] Cin_act;
    wire signed [3:0] S_act;
    wire signed [3:0] Cout_act;

    wire signed [3:0] A_act_2;
    wire signed [3:0] B_act_2;
    wire signed [3:0] Cin_act_2;
    wire signed [3:0] S_act_2;
    wire signed [3:0] Cout_act_2;

    p_FA_gate FA (
        .in({A, B, Cin, S, Cout}),
        .A_act(A_act),
        .B_act(B_act),
        .Cin_act(Cin_act),
        .S_act(S_act),
        .Cout_act(Cout_act)
    );

    unsafe_gate_fusion A_fusion (
        .in({A_act, a_node}),
        .out(A_act_2)
    );

    unsafe_gate_fusion B_fusion (
        .in({B_act, b_node}),
        .out(B_act_2)
    );

    unsafe_gate_fusion Cin_fusion (
        .in({Cin_act, cin_node}),
        .out(Cin_act_2)
    );

    unsafe_gate_fusion S_fusion (
        .in({S_act, s_node}),
        .out(S_act_2)
    );

    safe_gate_fusion Cout_fusion (
        .in({Cout_act, cout_node}),
        .out(Cout_act_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_act_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_act_2),
        .out(B)
    );

    p_bit Cin_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(Cin_act_2),
        .out(Cin)
    );

    p_bit S_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(S_act_2),
        .out(S)
    );

    p_bit Cout_bit (
        .clk(clk[4]),
        .reset(reset),
        .in(Cout_act_2),
        .out(Cout)
    );

endmodule

module terminal_AND_system(
    input [2:0] clk,
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    output A,
    output B,
    output C,
)

    wire signed [3:0] A_act;
    wire signed [3:0] B_act;
    wire signed [3:0] C_act;

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_act),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_act),
        .out(B)
    );

    p_bit C_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(C_act),
        .out(C)
    );

    p_AND_gate AND (
        .in({A, B, C}),
        .A_act(A_act),
        .B_act(B_act),
        .C_act(C_act)
    );

endmodule

module terminal_HA_system(
    input [3:0] clk,
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    output A,
    output B,
    output S,
    output C,
    input a_node,
    input b_node,
    input c_node,
)

    wire signed [3:0] A_act;
    wire signed [3:0] B_act;
    wire signed [3:0] S_act;
    wire signed [3:0] C_act;

    wire signed [3:0] A_act_2;
    wire signed [3:0] B_act_2;
    wire signed [3:0] C_act_2;

    p_HA_gate HA (
        .in({A, B, S, C}),
        .A_act(A_act),
        .B_act(B_act),
        .S_act(S_act),
        .C_act(C_act)
    );

    unsafe_gate_fusion A_fusion (
        .in({A_act, a_node}),
        .out(A_act_2)
    );

    unsafe_gate_fusion B_fusion (
        .in({B_act, b_node}),
        .out(B_act_2)
    );

    safe_gate_fusion C_fusion (
        .in({C_act, c_node}),
        .out(C_act_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_act_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_act_2),
        .out(B)
    );

    p_bit S_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(S_act),
        .out(S)
    );

    p_bit C_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(C_act_2),
        .out(C)
    );

endmodule

module terminal_FA_system(
    input clk [4:0],
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    output A,
    output B,
    output Cin,
    output S,
    output Cout,
    input a_node,
    input b_node,
    input cin_node,
    input cout_node,
)

    wire signed [3:0] A_act;
    wire signed [3:0] B_act;
    wire signed [3:0] Cin_act;
    wire signed [3:0] S_act;
    wire signed [3:0] Cout_act;

    wire signed [3:0] A_act_2;
    wire signed [3:0] B_act_2;
    wire signed [3:0] Cin_act_2;
    wire signed [3:0] Cout_act_2;

    p_FA_gate FA (
        .in({A, B, Cin, S, Cout}),
        .A_act(A_act),
        .B_act(B_act),
        .Cin_act(Cin_act),
        .S_act(S_act),
        .Cout_act(Cout_act)
    );

    unsafe_gate_fusion A_fusion (
        .in({A_act, a_node}),
        .out(A_act_2)
    );

    unsafe_gate_fusion B_fusion (
        .in({B_act, b_node}),
        .out(B_act_2)
    );

    unsafe_gate_fusion Cin_fusion (
        .in({Cin_act, cin_node}),
        .out(Cin_act_2)
    );

    safe_gate_fusion Cout_fusion (
        .in({Cout_act, cout_node}),
        .out(Cout_act_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_act_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_act_2),
        .out(B)
    );

    p_bit Cin_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(Cin_act_2),
        .out(Cin)
    );

    p_bit S_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(S_act),
        .out(S)
    );

    p_bit Cout_bit (
        .clk(clk[4]),
        .reset(reset),
        .in(Cout_act_2),
        .out(Cout)
    );

endmodule

module corner_FA_system(
    input clk [4:0],
    input reset,
    input [1:0] bit_shift, // New common bit-shift input
    output A,
    output B,
    output Cin,
    output S,
    output Cout,
    input a_node,
    input b_node,
    input cin_node,
)

    wire signed [3:0] A_act;
    wire signed [3:0] B_act;
    wire signed [3:0] Cin_act;
    wire signed [3:0] S_act;
    wire signed [3:0] Cout_act;

    wire signed [3:0] A_act_2;
    wire signed [3:0] B_act_2;
    wire signed [3:0] Cin_act_2;

    p_FA_gate FA (
        .in({A, B, Cin, S, Cout}),
        .A_act(A_act),
        .B_act(B_act),
        .Cin_act(Cin_act),
        .S_act(S_act),
        .Cout_act(Cout_act)
    );

    unsafe_gate_fusion A_fusion (
        .in({A_act, a_node}),
        .out(A_act_2)
    );

    unsafe_gate_fusion B_fusion (
        .in({B_act, b_node}),
        .out(B_act_2)
    );

    unsafe_gate_fusion Cin_fusion (
        .in({Cin_act, cin_node}),
        .out(Cin_act_2)
    );

    p_bit A_bit (
        .clk(clk[0]),
        .reset(reset),
        .in(A_act_2),
        .out(A)
    );

    p_bit B_bit (
        .clk(clk[1]),
        .reset(reset),
        .in(B_act_2),
        .out(B)
    );

    p_bit Cin_bit (
        .clk(clk[2]),
        .reset(reset),
        .in(Cin_act_2),
        .out(Cin)
    );

    p_bit S_bit (
        .clk(clk[3]),
        .reset(reset),
        .in(S_act),
        .out(S)
    );

    p_bit Cout_bit (
        .clk(clk[4]),
        .reset(reset),
        .in(Cout_act),
        .out(Cout)
    );

endmodule