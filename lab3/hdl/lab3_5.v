`timescale 1ns / 1ps
module top_module(
    input wire [3:0] button ,
    output wire [4:0] LED);
    
    assign LED[2] = ~button[3];
    assign LED[1] = (button[3] & ~button[2]) | (~button[1] & button[2] & button[3]);
    assign LED[0] = (~button[2] & button[3]) | (~button[0] & button[1] & button[2] & button[3]);
endmodule