`timescale 1ns / 1ps
module clocking_wizard(
    input  wire        clk_in,
    input  wire        rst,
    input  wire [31:0] in_freq,
    input  wire [31:0] out_freq,
    output reg         clk_out
);
    reg [31:0] count    = 0;
    reg [31:0] div_max  = 0;

    initial begin
        div_max = in_freq / (2 * out_freq);
    end

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            count   <= 0;
            clk_out <= 1'b0;
        end else begin
            if (count == (div_max - 1)) begin
                count   <= 0;
                clk_out <= ~clk_out;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule

module counter(
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    input  wire [3:0]  n_max,
    output reg  [3:0]  out,
    output wire        done
);
    assign done = (out == n_max) && enable;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 4'd0;
        end else if (enable) begin
            if (out == n_max)
                out <= 4'd0;
            else
                out <= out + 1'b1;
        end
    end
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

    wire [31:0] in_freq  = 32'd50000000;
    wire [31:0] out_freq = 32'd10;
    wire       rst       = ~button_mb[0];

    wire clk_10Hz;
    clocking_wizard clk_div_inst(
        .clk_in  (clk),
        .rst     (rst),
        .in_freq (in_freq),
        .out_freq(out_freq),
        .clk_out (clk_10Hz)
    );

    wire [3:0] n_max_9 = 4'd9;
    wire [3:0] n_max_5 = 4'd5;

    wire [3:0] seconds_ones;
    wire       done_sec_ones;
    counter cnt_sec_ones(
        .clk   (clk_10Hz),
        .rst   (rst),
        .enable(1'b1),
        .n_max (n_max_9),
        .out   (seconds_ones),
        .done  (done_sec_ones)
    );

    wire [3:0] seconds_tens;
    wire       done_sec_tens;
    counter cnt_sec_tens(
        .clk   (clk_10Hz),
        .rst   (rst),
        .enable(done_sec_ones),
        .n_max (n_max_9),
        .out   (seconds_tens),
        .done  (done_sec_tens)
    );

    wire [3:0] minutes_ones;
    wire       done_min_ones;
    counter cnt_min_ones(
        .clk   (clk_10Hz),
        .rst   (rst),
        .enable(done_sec_tens),
        .n_max (n_max_5),
        .out   (minutes_ones),
        .done  (done_min_ones)
    );

    wire [3:0] minutes_tens;
    wire       done_min_tens;
    counter cnt_min_tens(
        .clk   (clk_10Hz),
        .rst   (rst),
        .enable(done_min_ones),
        .n_max (n_max_9),
        .out   (minutes_tens),
        .done  (done_min_tens)
    );

    reg [15:0] refresh_counter = 0;
    always @(posedge clk or posedge rst) begin
        if (rst)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    wire [1:0] mux_sel = refresh_counter[15:14];
    reg  [3:0] current_digit_val;

    always @(*) begin
        case (mux_sel)
            2'b00: current_digit_val = seconds_ones;
            2'b01: current_digit_val = seconds_tens;
            2'b10: current_digit_val = minutes_ones;
            2'b11: current_digit_val = minutes_tens;
        endcase
    end

    Hex_to_7_seg seg_encoder (
        .Hex (current_digit_val),
        .a   (a),
        .b   (b),
        .c   (c),
        .d   (d),
        .e   (e),
        .f   (f),
        .g   (g)
    );

    always @(*) begin
        dig0 = 1'b0;
        dig1 = 1'b0;
        dig2 = 1'b0;
        dig3 = 1'b0;
        case (mux_sel)
            2'b00: dig0 = 1'b1;
            2'b01: dig1 = 1'b1;
            2'b10: dig2 = 1'b1;
            2'b11: dig3 = 1'b1;
        endcase
    end
endmodule
