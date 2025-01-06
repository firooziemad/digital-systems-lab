`timescale 1ns / 1ps
module top_module_extended(
    input wire clk,                     // PL clk (Programmable Logic clock) - 50 MHz
    input wire [3:0] button_mb,         // ACTIVE LOW: lsb -> rightmost on the board ("mb")
    input wire button_2, button_1,      // ACTIVE HIGH
    input wire [7:0] dip,               // ACTIVE HIGH: lsb -> rightmost on the board
    output wire [4:0] led_mb,           // ACTIVE HIGH: lsb -> rightmost on the board
    output wire [9:0] led,              // ACTIVE HIGH: lsb -> downmost on the board
    output wire dig3, dig2, dig1, dig0, // ACTIVE HIGH: dig0 -> rightmost on the board
    output wire a, b, c, d, e, f, g,    // ACTIVE LOW
    output wire colon                   // ACTIVE LOW
    ); 

    reg toggle_led;

    always @(posedge clk) begin
        if (button_1) begin
            toggle_led <= 0;
        end else begin
            toggle_led <= ~toggle_led;
        end
    end

    assign led[0] = toggle_led;
endmodule