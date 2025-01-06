`timescale 1ns / 1ps
module freq_converter(
    input wire in_clk,
    input wire [1:0] mode,
    output reg out_clk
);

    reg [31:0] divisor;
    reg [31:0] counter;

    always @(mode) begin
        case (mode)
            2'b00: divisor = 12_500_000;
            2'b01: divisor = 8_333_333;
            2'b10: divisor = 6_250_000;
            2'b11: divisor = 5_000_000;
            default: divisor = 12_500_000;
        endcase
    end
    initial begin
        counter = 0;
        out_clk = 0;
    end
    always @(posedge in_clk) begin
        if (counter >= divisor - 1) begin
            counter <= 0;
            out_clk <= ~out_clk;
        end else begin
            counter <= counter + 1;
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
    output wire a,b,c,d,e,f,g,
    output wire colon
);

    wire out_clk;
    freq_converter u_freq_converter (
        .in_clk(clk),
        .mode(dip[1:0]),
        .out_clk(out_clk)
    );

    assign led_mb = out_clk ? 5'b11111 : 5'b00000;

endmodule
