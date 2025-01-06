`timescale 1ns / 1ps
module extensionBoard(
    input wire [3:0] button_mb,
    input wire button_2, button_1,
    input wire [7:0] dip,
    output wire [4:0] led_mb,
    output wire [9:0] led,
    output wire dig3, dig2, dig1, dig0,
    output wire a, b, c, d, e, f, g,
    output wire colon
);
    assign dig0=1'b1;

    wire mux_out;
    MUX8to1 mux_instance(
        .data(dip),
        .sel(~button_mb),
        .out(mux_out)
    );
    
    assign led_mb[0] = mux_out;
endmodule

module Hex_to_7_seg (
    input wire [3:0] Hex,
    output reg a, b, c, d, e, f, g
    );
    always @(*) begin
        case(Hex)
            0  : {a,b,c,d,e,f,g} = ~(7'b1111110);
            1  : {a,b,c,d,e,f,g} = ~(7'b0110000);
            2  : {a,b,c,d,e,f,g} = ~(7'b1101101);
            3  : {a,b,c,d,e,f,g} = ~(7'b1111001);
            4  : {a,b,c,d,e,f,g} = ~(7'b0110011);
            5  : {a,b,c,d,e,f,g} = ~(7'b1011011);
            6  : {a,b,c,d,e,f,g} = ~(7'b1011111);
            7  : {a,b,c,d,e,f,g} = ~(7'b1110000);
            8  : {a,b,c,d,e,f,g} = ~(7'b1111111);
            9  : {a,b,c,d,e,f,g} = ~(7'b1111011);
            10 : {a,b,c,d,e,f,g} = ~(7'b1110111); // A
            11 : {a,b,c,d,e,f,g} = ~(7'b0011111); // B
            12 : {a,b,c,d,e,f,g} = ~(7'b1001110); // C
            13 : {a,b,c,d,e,f,g} = ~(7'b0111101); // D
            14 : {a,b,c,d,e,f,g} = ~(7'b1001111); // E
            15 : {a,b,c,d,e,f,g} = ~(7'b1000111); // F
            default: {a,b,c,d,e,f,g} = ~(7'b0000000); // Default off
        endcase
    end
endmodule

module MUX8to1 (
    input wire [7:0] data,
    input wire [2:0] sel,
    output wire out
    );
    assign out = data[sel];
endmodule