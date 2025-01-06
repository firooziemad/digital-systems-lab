`timescale 1ns / 1ps
module top_module(
    input wire [3:0] button ,
    output wire [4:0] LED);

    wire ha1_sum, ha1_carry;
    wire ha2_carry;

    half_adder HA1(
        .A(~button[0]),
        .B(~button[1]),
        .S(ha1_sum),
        .C(ha1_carry)
    );
     half_adder HA2(
        .A(ha1_sum),
        .B(~button[2]),
        .S(LED[0]),
        .C(ha2_carry)
    );
    
    or(LED[1], ha1_carry, ha2_carry);
endmodule

module half_adder(
    input wire A,
    input wire B,
    output wire S,
    output wire C);

    assign S=A^B;
    assign C=A&B;
endmodule