`timescale 1ns / 1ps
module extensionBoard(
    input wire [3:0] button_mb,         //ACTIVE LOW : lsb  -> rightmost on the board ("mb" is the short form of "main board")
    input wire button_2, button_1,      //ACTIVE HIGH
    input wire [7:0] dip,               //ACTIVE HIGH: lsb  -> rightmost on the board
    output wire [4:0] led_mb,           //ACTIVE HIGH: lsb  -> rightmost on the board ("mb" is the short form of "main board")
    output wire [9:0] led,              //ACTIVE HIGH: lsb  -> downmost on the board
    output wire dig3, dig2, dig1, dig0, //ACTIVE HIGH: dig0 -> rightmost on the board
    output wire a,b,c,d,e,f,g,          //ACTIVE LOW
    output wire colon 
    );

    assign dig0=1'b1;

    wire [3:0] input_A = dip[3:0];
    wire [3:0] input_B = dip[7:4];
    
    wire valid_A = (input_A <= 4'd9);
    wire valid_B = (input_B <= 4'd9);
    
    wire [4:0] sum = input_A + input_B;
    wire sum_ge10 = (sum >= 5'd10);
    
    wire [3:0] sum_units = sum_ge10 ? (sum - 5'd10) : sum[3:0];
    
    wire sum_tens = sum_ge10 ? 1'b1 : 1'b0;
    
    reg [3:0] display_value;
    
    reg display_tens_led;
    
    always @(*) begin
        if (valid_A && valid_B) begin
            if (sum_ge10) begin
                display_value = sum_units;
                display_tens_led = 1'b1;
            end else begin
                display_value = sum_units;
                display_tens_led = 1'b0;
            end
        end else if (!valid_A && !valid_B) begin
            display_value = 4'd14;
            display_tens_led = 1'b1;
        end else begin
            display_value = 4'd14;
            display_tens_led = 1'b0;
        end
    end
    
    Hex_to_7_seg display_unit (
        .Hex(display_value),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g)
    );
    
    assign led[0] = display_tens_led;
    assign led[1] = (!valid_A && !valid_B) ? 1'b1 : 1'b0;
endmodule

module Hex_to_7_seg (
    input wire [3:0] Hex,
    output reg a,b,c,d,e,f,g
    );
    always @(Hex) begin
        case(Hex)
            0 : {a,b,c,d,e,f,g} = ~(7'b1111110);
            1 : {a,b,c,d,e,f,g} = ~(7'b0110000);
            2 : {a,b,c,d,e,f,g} = ~(7'b1101101);
            3 : {a,b,c,d,e,f,g} = ~(7'b1111001);
            4 : {a,b,c,d,e,f,g} = ~(7'b0110011);
            5 : {a,b,c,d,e,f,g} = ~(7'b1011011);
            6 : {a,b,c,d,e,f,g} = ~(7'b1011111);
            7 : {a,b,c,d,e,f,g} = ~(7'b1110000);
            8 : {a,b,c,d,e,f,g} = ~(7'b1111111);
            9 : {a,b,c,d,e,f,g} = ~(7'b1111011);
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
