`timescale 1ns / 1ps
module top_module(
    input wire [3:0] button ,
    output wire [4:0] LED);

    wire gate00;
    wire gate10;
    
    assign gate00 = ~button[0]|~button[1];
    assign gate10 = ~button[2]&~button[3];

    assign LED [0] = gate10;
    assign LED [1] = gate00^gate10;
    
    assign LED [4:2]=3'b000;
endmodule