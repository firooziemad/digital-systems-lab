`timescale 1ns / 1ps
module top_module_extended(
    input wire clk,                     //PL clk (Programmable Logic clock) - 50_MHz
    input wire [3:0] button_mb,         //ACTIVE LOW : lsb  -> rightmost on the board ("mb" is the short form of "main board")
    input wire button_2, button_1,      //ACTIVE HIGH
    input wire [7:0] dip,               //ACTIVE HIGH: lsb  -> rightmost on the board
    output wire [4:0] led_mb,           //ACTIVE HIGH: lsb  -> rightmost on the board ("mb" is the short form of "main board")
    output wire [9:0] led,              //ACTIVE HIGH: lsb  -> downmost on the board
    output wire dig3, dig2, dig1, dig0, //ACTIVE HIGH: dig0 -> rightmost on the board
    output wire a,b,c,d,e,f,g,          //ACTIVE LOW
    output wire colon                   //ACTIVE LOW
    );
    
    reg [3:0] student_digits [8:0];
    reg digits_loaded = 0;

    wire reset = button_2;

    always @(posedge clk) begin
        if (reset) begin
            student_digits[0] <= 4'd4;
            student_digits[1] <= 4'd0;
            student_digits[2] <= 4'd1;
            student_digits[3] <= 4'd2;
            student_digits[4] <= 4'd3;
            student_digits[5] <= 4'd5;
            student_digits[6] <= 4'd6;
            student_digits[7] <= 4'd7;
            student_digits[8] <= 4'd8;
            digits_loaded <= 1'b1;
        end
    end

    reg [25:0] clk_divider_shift = 0;
    reg one_sec_clk = 0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider_shift <= 0;
            one_sec_clk <= 0;
        end
        else begin
            if (clk_divider_shift < 49999999) begin
                clk_divider_shift <= clk_divider_shift + 1;
            end 
            else begin
                clk_divider_shift <= 0;
                one_sec_clk <= ~one_sec_clk;
            end
        end
    end

    reg [3:0] shift_index = 0;
    always @(posedge one_sec_clk or posedge reset) begin
        if (reset) begin
            shift_index <= 0;
        end
        else if (digits_loaded) begin
            if (shift_index < 5) begin
                shift_index <= shift_index + 1;
            end 
            else begin
                shift_index <= 0;
            end
        end
    end

    reg [15:0] clk_divider_mux = 0;
    reg refresh_clk_mux = 0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider_mux <= 0;
            refresh_clk_mux <= 0;
        end
        else begin
            if (clk_divider_mux < 49999) begin
                clk_divider_mux <= clk_divider_mux + 1;
            end 
            else begin
                clk_divider_mux <= 0;
                refresh_clk_mux <= ~refresh_clk_mux;
            end
        end
    end

    reg [1:0] digit_select = 0;
    always @(posedge refresh_clk_mux or posedge reset) begin
        if (reset) begin
            digit_select <= 0;
        end
        else begin
            if (digit_select < 2'd3) begin
                digit_select <= digit_select + 1;
            end 
            else begin
                digit_select <= 2'd0;
            end
        end
    end

    reg active_dig3, active_dig2, active_dig1, active_dig0;
    always @(*) begin
        active_dig3 = 1'b0;
        active_dig2 = 1'b0;
        active_dig1 = 1'b0;
        active_dig0 = 1'b0;
        
        case(digit_select)
            2'd0: active_dig3 = 1'b1;
            2'd1: active_dig2 = 1'b1;
            2'd2: active_dig1 = 1'b1;
            2'd3: active_dig0 = 1'b1;
            default: {active_dig3, active_dig2, active_dig1, active_dig0} = 4'b0000;
        endcase
    end

    wire [3:0] current_digit;
    assign current_digit = student_digits[shift_index + digit_select];

    Hex_to_7_seg hex_display (
        .Hex(current_digit),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g)
    );

    assign dig3 = active_dig3;
    assign dig2 = active_dig2;
    assign dig1 = active_dig1;
    assign dig0 = active_dig0;
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
        endcase
    end
endmodule