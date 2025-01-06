`timescale 1ns / 1ps
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
            10: {a,b,c,d,e,f,g} = ~(7'b1110111); // A
            11: {a,b,c,d,e,f,g} = ~(7'b0011111); // B
            12: {a,b,c,d,e,f,g} = ~(7'b1001110); // C
            13: {a,b,c,d,e,f,g} = ~(7'b0111101); // D
            14: {a,b,c,d,e,f,g} = ~(7'b1001111); // E
            15: {a,b,c,d,e,f,g} = ~(7'b1000111); // F
        endcase
    end
endmodule

module lfsr16(
    input wire clk,
    input wire reset,
    input wire enable,
    output reg [15:0] out
);
    always @(posedge clk) begin
        if (reset) begin
            out <= 16'h0001;
        end
        else if (enable) begin
            out <= {out[14:0], out[15] ^ out[13] ^ out[12] ^ out[10]};
        end
    end
endmodule

module debounce(
    input wire clk,
    input wire button_in,
    output reg button_out
);
    reg [15:0] count;
    reg button_sync_0, button_sync_1;

    always @(posedge clk) begin
        button_sync_0 <= button_in;
        button_sync_1 <= button_sync_0;
    end

    always @(posedge clk) begin
        if (button_sync_1 == button_out) begin
            count <= 0;
        end
        else begin
            count <= count + 1;
            if (count == 16'hFFFF) begin
                button_out <= button_sync_1;
                count <= 0;
            end
        end
    end
endmodule

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

    wire [15:0] random_num16;          
    wire reset_n = ~button_mb[0];      
    wire enable_lfsr;                 
    wire button_1_debounced;          

    debounce debounce_button1 (
        .clk(clk),
        .button_in(button_1),
        .button_out(button_1_debounced)
    );

    assign enable_lfsr = button_1_debounced;

    lfsr16 my_lfsr16 (
        .clk(clk),
        .reset(reset_n),
        .enable(enable_lfsr),
        .out(random_num16)
    );

    wire [3:0] random_digit0 = random_num16[3:0];
    wire [3:0] random_digit1 = random_num16[7:4];
    wire [3:0] random_digit2 = random_num16[11:8];
    wire [3:0] random_digit3 = random_num16[15:12];

    wire a0, b0, c0, d0, e0, f0, g0;
    wire a1, b1, c1, d1, e1, f1, g1;
    wire a2, b2, c2, d2, e2, f2, g2;
    wire a3, b3, c3, d3, e3, f3, g3;

    Hex_to_7_seg hex_display0 (
        .Hex(random_digit0),
        .a(a0),
        .b(b0),
        .c(c0),
        .d(d0),
        .e(e0),
        .f(f0),
        .g(g0)
    );
    Hex_to_7_seg hex_display1 (
        .Hex(random_digit1),
        .a(a1),
        .b(b1),
        .c(c1),
        .d(d1),
        .e(e1),
        .f(f1),
        .g(g1)
    );
    Hex_to_7_seg hex_display2 (
        .Hex(random_digit2),
        .a(a2),
        .b(b2),
        .c(c2),
        .d(d2),
        .e(e2),
        .f(f2),
        .g(g2)
    );
    Hex_to_7_seg hex_display3 (
        .Hex(random_digit3),
        .a(a3),
        .b(b3),
        .c(c3),
        .d(d3),
        .e(e3),
        .f(f3),
        .g(g3)
    );

    localparam MUX_MAX_COUNT = 25000 - 1; 

    reg [14:0] mux_count = 0;
    reg mux_clk_en = 0;

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            mux_count <= 0;
            mux_clk_en <= 0;
        end
        else begin
            if (mux_count >= MUX_MAX_COUNT) begin
                mux_count <= 0;
                mux_clk_en <= 1;
            end
            else begin
                mux_count <= mux_count + 1;
                mux_clk_en <= 0;
            end
        end
    end

    reg [1:0] mux_select = 0;

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            mux_select <= 0;
        end
        else if (mux_clk_en) begin
            mux_select <= mux_select + 1;
        end
    end

    assign dig3 = (mux_select == 2'b11) ? 1'b1 : 1'b0;
    assign dig2 = (mux_select == 2'b10) ? 1'b1 : 1'b0;
    assign dig1 = (mux_select == 2'b01) ? 1'b1 : 1'b0;
    assign dig0 = (mux_select == 2'b00) ? 1'b1 : 1'b0;

    assign a = (mux_select == 2'b00) ? a0 :
               (mux_select == 2'b01) ? a1 :
               (mux_select == 2'b10) ? a2 :
                                        a3;
    assign b = (mux_select == 2'b00) ? b0 :
               (mux_select == 2'b01) ? b1 :
               (mux_select == 2'b10) ? b2 :
                                        b3;
    assign c = (mux_select == 2'b00) ? c0 :
               (mux_select == 2'b01) ? c1 :
               (mux_select == 2'b10) ? c2 :
                                        c3;
    assign d = (mux_select == 2'b00) ? d0 :
               (mux_select == 2'b01) ? d1 :
               (mux_select == 2'b10) ? d2 :
                                        d3;
    assign e = (mux_select == 2'b00) ? e0 :
               (mux_select == 2'b01) ? e1 :
               (mux_select == 2'b10) ? e2 :
                                        e3;
    assign f = (mux_select == 2'b00) ? f0 :
               (mux_select == 2'b01) ? f1 :
               (mux_select == 2'b10) ? f2 :
                                        f3;
    assign g = (mux_select == 2'b00) ? g0 :
               (mux_select == 2'b01) ? g1 :
               (mux_select == 2'b10) ? g2 :
                                        g3;
endmodule
