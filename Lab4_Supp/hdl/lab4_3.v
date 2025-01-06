`timescale 1ns / 1ps
module extensionBoard(
    input wire [3:0] button_mb,         //ACTIVE LOW : lsb  -> rightmost on the board ("mb" is the short form of "main board")
    input wire button_2, button_1,      //ACTIVE HIGH
    input wire [7:0] dip,               //ACTIVE HIGH: lsb  -> rightmost on the board
    output wire [4:0] led_mb,           //ACTIVE HIGH: lsb  -> rightmost on the board ("mb" is the short form of "main board")
    output wire [9:0] led,              //ACTIVE HIGH: lsb  -> downmost on the board
    output wire dig3, dig2, dig1, dig0, //ACTIVE HIGH: dig0 -> rightmost on the board
    output wire a,b,c,d,e,f,g,          //ACTIVE LOW
    output wire colon                   //ACTIVE LOW
    );

    assign dig0=1'b1;

    wire [7:0] decoded_out;
    decoder_3to8 decoder (
        .in(dip[2:0]),
        .out(decoded_out)
    );

    assign LEDs[7:0] = decoded_out;

    reg [2:0] active_index;

    always @(*) begin
        if (decoded_out[7])
            active_index = 3'd7;
        else if (decoded_out[6])
            active_index = 3'd6;
        else if (decoded_out[5])
            active_index = 3'd5;
        else if (decoded_out[4])
            active_index = 3'd4;
        else if (decoded_out[3])
            active_index = 3'd3;
        else if (decoded_out[2])
            active_index = 3'd2;
        else if (decoded_out[1])
            active_index = 3'd1;
        else if (decoded_out[0])
            active_index = 3'd0;
        else
            active_index = 3'd0; // Default to 0 if no input is active
    end

    wire [3:0] display_code;
    assign display_code = {1'b0, active_index};

    Hex_to_7_seg display_unit (
        .Hex(display_code),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g)
    );
endmodule

module decoder_3to8 (
    input wire [2:0] in,
    output reg [7:0] out
    );

    always @(*) begin
        out = 8'b00000000;
        case(in)
            3'b000: out[0] = 1'b1;
            3'b001: out[1] = 1'b1;
            3'b010: out[2] = 1'b1;
            3'b011: out[3] = 1'b1;
            3'b100: out[4] = 1'b1;
            3'b101: out[5] = 1'b1;
            3'b110: out[6] = 1'b1;
            3'b111: out[7] = 1'b1;
            default: out = 8'b00000000;
        endcase
    end
endmodule

module Hex_to_7_seg (
    input wire [3:0] Hex,
    output reg a, b, c, d, e, f, g
    );
    always @(Hex) begin
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