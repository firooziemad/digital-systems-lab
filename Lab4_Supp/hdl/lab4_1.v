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

    wire [2:0] priority_code;
    wire valid;
    priority_encoder_8to3 priority_enc (
        .in(dip),
        .out(priority_code),
        .valid(valid)
    );

    assign led[7:0] = dip;

    reg [3:0] display_code;

    always @(*) begin
        if (valid) begin
            display_code = {1'b0, priority_code};
        end
        else if (|dip && ~valid) begin
            display_code = 4'd14; // 'E'
        end
        else begin
            display_code = 4'd16;
        end
    end

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

module priority_encoder_8to3 (
    input wire [7:0] in,
    output reg [2:0] out,
    output wire valid
    );

    wire [3:0] count = in[0] + in[1] + in[2] + in[3] + in[4] + in[5] + in[6] + in[7];

    assign valid = (count == 1) ? 1'b1 : 1'b0;

    always @(*) begin
        if (in[7]) out = 3'd7;
        else if (in[6]) out = 3'd6;
        else if (in[5]) out = 3'd5;
        else if (in[4]) out = 3'd4;
        else if (in[3]) out = 3'd3;
        else if (in[2]) out = 3'd2;
        else if (in[1]) out = 3'd1;
        else if (in[0]) out = 3'd0;
        else out = 3'd0;
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