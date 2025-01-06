`timescale 1ns / 1ps
module top_module (
    input wire [3:0] button ,
    output wire [4:0] LED);

    wire min5;
    wire min7;
    wire min8;
    wire min10;
    wire min13;
    wire min15;

    assign min5=button[0]&~button[1]&button[2]&~button[3];
    assign min7=button[0]&~button[1]&~button[2]&~button[3];
    assign min8=~button[0]&button[1]&button[2]&button[3];
    assign min10=~button[0]&button[1]&~button[2]&button[3];
    assign min13=~button[0]&~button[1]&button[2]&~button[3];
    assign min15=~button[0]&~button[1]&~button[2]&~button[3];

    assign LED[0]=~(min5|min7|min8|min10|min13|min15);
endmodule