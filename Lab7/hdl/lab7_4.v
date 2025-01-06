`timescale 1ns / 1ps
module LED_flow(
    input wire clk,
    input wire button1,
    input wire button2,
    input wire reset,
    output reg [4:0] LED
);

    reg [4:0] led_pattern[0:9];
    reg [3:0] state = 0;

    reg [31:0] counter = 0;
    reg [31:0] divisor = 2500000;

    reg button1_reg = 0;
    reg button2_reg = 0;
    reg button1_reg_d = 0;
    reg button2_reg_d = 0;

    wire button1_rise;
    wire button2_rise;

    assign button1_rise = (button1_reg && !button1_reg_d);
    assign button2_rise = (button2_reg && !button2_reg_d);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            LED <= 5'b00000;
            state <= 0;
            counter <= 0;
            divisor <= 2500000;
        end else begin
            button1_reg_d <= button1_reg;
            button2_reg_d <= button2_reg;
            button1_reg   <= button1;
            button2_reg   <= button2;

            if (button1_rise) begin
                if (divisor > 10) 
                    divisor <= divisor >> 1;
            end

            if (button2_rise) begin
                if (divisor < 312500)
                    divisor <= divisor << 1;
            end

            counter <= counter + 1;
            if (counter >= divisor - 1) begin
                counter <= 0;
                if (state == 9)
                    state <= 0;
                else
                    state <= state + 1;

                LED <= led_pattern[state];
            end
        end
    end

    always @(posedge reset) begin
        led_pattern[0] = 5'b00000;
        led_pattern[1] = 5'b00001;
        led_pattern[2] = 5'b00011;
        led_pattern[3] = 5'b00111;
        led_pattern[4] = 5'b01111;
        led_pattern[5] = 5'b11111;
        led_pattern[6] = 5'b11110;
        led_pattern[7] = 5'b11100;
        led_pattern[8] = 5'b11000;
        led_pattern[9] = 5'b10000;
    end

endmodule

module top_module_extended(
    input wire clk,
    input wire [3:0] button_mb,
    output wire [4:0] led_mb
); 

    LED_flow u_led_flow (
        .clk       (clk),
        .button1   (button_mb[0]),
        .button2   (button_mb[1]),
        .reset     (button_mb[2]),
        .LED       (led_mb)
    );

endmodule
