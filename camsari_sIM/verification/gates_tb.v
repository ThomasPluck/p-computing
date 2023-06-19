`include "../gates.v"

`timescale 1ns/1ps

module tb_gates;

    reg signed [3:0] A_act;
    reg b_node;
    wire signed [3:0] out;

    reg [1:0] in;
    wire signed [3:0] out_A_act;
    wire signed [3:0] out_B_act;

    reg [2:0] in_3bit;
    wire signed [3:0] out_A_act_3bit;
    wire signed [3:0] out_B_act_3bit;
    wire signed [3:0] out_C_act_3bit;

    reg [3:0] in_4bit;
    wire signed [3:0] out_A_act_4bit;
    wire signed [3:0] out_B_act_4bit;
    wire signed [3:0] out_S_act;
    wire signed [3:0] out_C_act_4bit;

    reg [4:0] in_5bit;
    wire signed [3:0] out_A_act_5bit;
    wire signed [3:0] out_B_act_5bit;
    wire signed [3:0] out_Cin_act;
    wire signed [3:0] out_S_act_5bit;
    wire signed [3:0] out_Cout_act;

    unsafe_gate_fusion unsafe_gate_fusion(.A_act(A_act), .b_node(b_node), .out(out));
    safe_gate_fusion safe_gate_fusion(.A_act(A_act), .b_node(b_node), .out(out));

    COPY_gate COPY_gate(.in(in), .A_act(out_A_act), .B_act(out_B_act));
    NOT_gate NOT_gate(.in(in), .A_act(out_A_act), .B_act(out_B_act));

    p_AND_gate p_AND_gate(.in(in_3bit), .A_act(out_A_act_3bit), .B_act(out_B_act_3bit), .C_act(out_C_act_3bit));
    p_OR_gate p_OR_gate(.in(in_3bit), .A_act(out_A_act_3bit), .B_act(out_B_act_3bit), .C_act(out_C_act_3bit));

    p_HA_gate p_HA_gate(.in(in_4bit), .A_act(out_A_act_4bit), .B_act(out_B_act_4bit), .S_act(out_S_act), .C_act(out_C_act_4bit));
    p_FA_gate p_FA_gate(.in(in_5bit), .A_act(out_A_act_5bit), .B_act(out_B_act_5bit), .Cin_act(out_Cin_act), .S_act(out_S_act_5bit), .Cout_act(out_Cout_act));

endmodule