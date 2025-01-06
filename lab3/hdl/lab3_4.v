`timescale 1ns / 1ps
module top_module(
    input wire [3:0] button ,
    output wire [4:0] LED);

    wire a;
    wire b;
    wire c;

    assign a=~button[0];
    assign b=~button[1];
    assign c=~button[2];
    
    assign LED[0] = c ? (a&b) : ~(a|b);
endmodule