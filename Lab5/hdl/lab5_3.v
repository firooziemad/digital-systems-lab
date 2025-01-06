module top_module_behavioral(
    input wire [3:0] button_mb,
    input wire button_2, button_1,
    input wire [7:0] dip,
    output wire [4:0] led_mb,
    output wire [9:0] led,
    output reg dig3, dig2, dig1, dig0,
    output wire a, b, c, d, e, f, g,
    output wire colon
);
    wire button_press_raw;
    assign button_press_raw = ~button_mb[0];

    wire clk = button_1;

    reg [1:0] digit_counter = 2'd0;
    reg [3:0] number [0:3];
    reg [3:0] current_digit;

    reg clk_state, clk_state_prev;

    initial begin
        number[0] = 4'd1;
        number[1] = 4'd2;
        number[2] = 4'd3;
        number[3] = 4'd4;
    end

    always @(posedge clk) begin
        if (digit_counter == 2'd3)
            digit_counter <= 2'd0;
        else
            digit_counter <= digit_counter + 1;
    end

    always @(*) begin
        current_digit = number[digit_counter];
    end

    always @(*) begin
        dig3 = 1'b0;
        dig2 = 1'b0;
        dig1 = 1'b0;
        dig0 = 1'b0;
        case (digit_counter)
            2'd0: dig0 = 1'b1;
            2'd1: dig1 = 1'b1;
            2'd2: dig2 = 1'b1;
            2'd3: dig3 = 1'b1;
        endcase
    end

    Hex_to_7_seg hex_decoder (
        .Hex(current_digit),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g)
    );
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
            default: {a,b,c,d,e,f,g} = 7'b0000000; // Default off
        endcase
    end
endmodule