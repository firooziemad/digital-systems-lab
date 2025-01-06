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

    wire rst = 1'b0;

    dance_light_pro dance_light_inst (
        .clk  (clk),
        .rst  (rst),
        .leds (led_16)
    );
endmodule

module dance_light_pro (
    input  wire       clk,
    input  wire       rst,
    output reg [15:0] leds
);

    localparam SLOW_COUNT_MAX = 2_500_000;

    reg [21:0] slow_count = 0;
    reg [7:0]  pattern_select = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            slow_count     <= 0;
            pattern_select <= 0;
        end
        else begin
            if (slow_count < SLOW_COUNT_MAX - 1) begin
                slow_count <= slow_count + 1;
            end
            else begin
                slow_count <= 0;
                pattern_select <= pattern_select + 1;
            end
        end
    end

    wire [2:0] mode    = pattern_select[7:5];
    wire [4:0] substep = pattern_select[4:0];

    reg [15:0] lfsr_reg = 16'hACE1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr_reg <= 16'hACE1;
        end
        else if (slow_count == SLOW_COUNT_MAX - 1) begin
            wire feedback = lfsr_reg[15] ^ lfsr_reg[13] ^ lfsr_reg[12] ^ lfsr_reg[10];
            lfsr_reg <= {lfsr_reg[14:0], feedback};
        end
    end

    reg [15:0] pattern_data;
    reg [31:0] i;
    reg [31:0] pos;
    reg [31:0] dist;
    reg [31:0] shift_amount;

    always @(*) begin
        pattern_data = 16'b0000_0000_0000_0000;
        case (mode)
        3'd0: begin
            if (substep <= 15)
                pos = substep;
            else
                pos = 31 - substep;
            pattern_data = 16'b1 << pos;
        end
        3'd1: begin
            if (substep < 8)
                dist = substep;
            else
                dist = 8;
            reg [31:0] left  = (7 - dist < 0)  ? 0  : (7 - dist);
            reg [31:0] right = (8 + dist > 15) ? 15 : (8 + dist);
            pattern_data = 16'b0;
            for (i = 0; i < 16; i = i + 1) begin
                if ((i >= left) && (i <= right))
                    pattern_data[i] = 1'b1;
            end
        end
        3'd2: begin
            if (substep < 8)
                dist = 7 - substep;
            else
                dist = 0;
            reg [31:0] left  = (7 - dist < 0)  ? 0  : (7 - dist);
            reg [31:0] right = (8 + dist > 15) ? 15 : (8 + dist);
            pattern_data = 16'b0;
            for (i = 0; i < 16; i = i + 1) begin
                if ((i >= left) && (i <= right))
                    pattern_data[i] = 1'b1;
            end
        end
        3'd3: begin
            shift_amount = substep % 16;
            pattern_data = (16'h0001 << shift_amount) | (16'h0001 >> (16 - shift_amount));
        end
        3'd4: begin
            shift_amount = substep % 16;
            pattern_data = (16'h8000 >> shift_amount) | (16'h8000 << (16 - shift_amount));
        end
        3'd5: begin
            if (substep[0] == 1'b0)
                pattern_data = 16'b1010_1010_1010_1010;
            else
                pattern_data = 16'b0101_0101_0101_0101;
        end
        3'd6: begin
            pattern_data = lfsr_reg;
        end
        3'd7: begin
            if (substep == 31)
                pattern_data = 16'b0000_0000_0000_0000;
            else
                pattern_data = 16'b1111_1111_1111_1111;
        end
        default: pattern_data = 16'b0000_0000_0000_0000;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) 
            leds <= 16'b0000_0000_0000_0000;
        else if (slow_count == 0)
            leds <= pattern_data;
    end
endmodule