`timescale 1ns / 1ps
module LEDBlinkPL(
    input wire clk,
    input wire reset,
    output reg LED
    );

    reg [26:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            LED <= 0;
        end else begin
            if (counter >= 99_999_999) begin
                counter <= 0;
                LED <= ~LED;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule

module top_module_extended(
    input wire clk,
    input wire [3:0] button_mb,
    input wire button_2, button_1,
    input wire [7:0] dip,
    output wire [4:0] led_mb,
    output wire [9:0] led,
    output wire dig3, dig2, dig1, dig0,
    output wire a, b, c, d, e, f, g,
    output wire colon
); 

    LEDBlinkPL led_blink_inst (
        .clk(clk),
        .reset(~button_mb[3]),
        .LED(led[0])
    );

endmodule
