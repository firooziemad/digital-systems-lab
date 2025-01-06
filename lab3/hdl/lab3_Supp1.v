`timescale 1ns / 1ps
module top_module (
    input wire [3:0] button ,
    output wire [4:0] LED);

    wire min3;
    wire min7;
    wire min10;
    wire min11;
    wire min13;
    wire min14;
    wire min15;

    assign min3=button[0]&button[1]&~button[2]&~button[3];
    assign min7=button[0]&~button[1]&~button[2]&~button[3];
    assign min10=~button[0]&button[1]&~button[2]&button[3];
    assign min11=~button[0]&button[1]&~button[2]&~button[3];
    assign min13=~button[0]&~button[1]&button[2]&~button[3];
    assign min14=~button[0]&~button[1]&~button[2]&button[3];
    assign min15=~button[0]&~button[1]&~button[2]&~button[3];

    assign LED[0]=min3|min7|min10|min11|min13|min14|min15;
endmodule