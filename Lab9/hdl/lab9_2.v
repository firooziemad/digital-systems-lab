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
        10 : {a,b,c,d,e,f,g} = ~(7'b1110111); // A
        11 : {a,b,c,d,e,f,g} = ~(7'b0011111); // B
        12 : {a,b,c,d,e,f,g} = ~(7'b1001110); // C
        13 : {a,b,c,d,e,f,g} = ~(7'b0111101); // D
        14 : {a,b,c,d,e,f,g} = ~(7'b1001111); // E
        15 : {a,b,c,d,e,f,g} = ~(7'b1000111); // F
        endcase
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

module lfsr3(
    input wire clk,
    input wire reset,
    input wire enable,
    output reg [2:0] out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out <= 3'b001;
        end
        else if (enable) begin
            out <= {out[1:0], out[2] ^ out[0]};
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

    wire reset_n = ~button_mb[0];
    wire button_1_debounced;
    wire lfsr_enable;
    wire [2:0] lfsr_out;
    reg [3:0] dice_num;

    debounce debounce_button1 (
        .clk(clk),
        .button_in(button_1),
        .button_out(button_1_debounced)
    );

    reg button_prev;
    wire button_rising_edge;

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            button_prev <= 1'b0;
        end
        else begin
            button_prev <= button_1_debounced;
        end
    end

    assign button_rising_edge = button_1_debounced & ~button_prev;
    assign lfsr_enable = button_rising_edge;

    lfsr3 my_lfsr3 (
        .clk(clk),
        .reset(reset_n),
        .enable(lfsr_enable),
        .out(lfsr_out)
    );

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            dice_num <= 4'd1;
        end
        else if (lfsr_enable) begin
            case(lfsr_out)
                3'b000: dice_num <= 4'd1;
                3'b001: dice_num <= 4'd2;
                3'b010: dice_num <= 4'd3;
                3'b011: dice_num <= 4'd4;
                3'b100: dice_num <= 4'd5;
                3'b101: dice_num <= 4'd6;
                3'b110: dice_num <= 4'd1;
                3'b111: dice_num <= 4'd1;
                default: dice_num <= 4'd1;
            endcase
        end
    end

    wire a0, b0, c0, d0, e0, f0, g0;

    Hex_to_7_seg hex_display (
        .Hex(dice_num),
        .a(a0),
        .b(b0),
        .c(c0),
        .d(d0),
        .e(e0),
        .f(f0),
        .g(g0)
    );

    assign dig0 = 1'b1;

    assign a = a0;
    assign b = b0;
    assign c = c0;
    assign d = d0;
    assign e = e0;
    assign f = f0;
    assign g = g0;

    assign led_mb = {1'b0, dice_num};
    assign led[3:0] = dice_num;
endmodule