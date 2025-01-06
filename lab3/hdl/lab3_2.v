`timescale 1ns / 1ps
module top_module(
    input wire [3:0] button ,
    output wire [4:0] LED);

    wire min0;
    wire min2;
    wire min4;
    wire min5;
    wire min8;
    wire min10;
    wire min12;
    wire min13;

    assign min0=button[0]&button[1]&button[2]&button[3];
    assign min2=button[0]&button[1]&~button[2]&button[3];
    assign min4=button[0]&~button[1]&button[2]&button[3];
    assign min5=button[0]&~button[1]&button[2]&~button[3];
    assign min8=~button[0]&button[1]&button[2]&button[3];
    assign min10=~button[0]&button[1]&~button[2]&button[3];
    assign min12=~button[0]&~button[1]&button[2]&button[3];
    assign min13=~button[0]&~button[1]&button[2]&~button[3];
    assign LED[0]=min0|min2|min4|min5|min8|min10|min12|min13;
endmodule