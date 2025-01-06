`timescale 1ns / 1ps
module top_module (
    input wire [3:0] button ,
    output wire [4:0] LED);

    wire min0;
    wire min1;
    wire min2;
    wire min3;
    wire min4;
    wire min6;
    wire min9;
    wire min11;
    wire min12;
    wire min14;

    assign min0=button[0]&button[1]&button[2]&button[3];
    assign min1=button[0]&button[1]&button[2]&~button[3];
    assign min2=button[0]&button[1]&~button[2]&button[3];
    assign min3=button[0]&button[1]&~button[2]&~button[3];
    assign min4=button[0]&~button[1]&button[2]&button[3];
    assign min6=button[0]&~button[1]&~button[2]&button[3];
    assign min9=~button[0]&button[1]&button[2]&~button[3];
    assign min11=~button[0]&button[1]&~button[2]&~button[3];
    assign min12=~button[0]&~button[1]&button[2]&button[3];
    assign min14=~button[0]&~button[1]&~button[2]&button[3];

    assign LED[0]=min0|min1|min2|min3|min4|min6|min9|min11|min12|min14;
endmodule