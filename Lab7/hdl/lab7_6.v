module miniGame (
    input wire clk,
    input wire gameReset,
    input wire button,
    output reg [4:0] LED,
    output reg [1:0] mode
);

    reg [3:0] level;
    reg [4:0] led_position;
    reg [1:0] state;
    reg [25:0] counter;

    always @(posedge clk or posedge gameReset) begin
        if (gameReset) begin
            level        <= 4'd0;
            led_position <= 5'b00001;
            mode         <= 2'b00;
            state        <= 2'b00;
            counter      <= 26'd0;
            LED          <= 5'b00001;
        end else begin
            if (button && state == 2'b00) begin
                level <= level + 1;
                case (level + 1)
                    4'd1: mode <= 2'b00;
                    4'd2: mode <= 2'b01;
                    4'd3: mode <= 2'b10;
                    default: mode <= 2'b10;
                endcase
                state <= 2'b01;
            end
            if (state != 2'b11) begin
                counter <= counter + 1;
                case (mode)
                    2'b00: begin
                        if (counter >= 26'd25000000) begin
                            counter      <= 26'd0;
                            led_position <= led_position << 1;
                        end
                    end
                    2'b01: begin
                        if (counter >= 26'd12500000) begin
                            counter      <= 26'd0;
                            led_position <= led_position << 1;
                        end
                    end
                    2'b10: begin
                        if (counter >= 26'd6250000) begin
                            counter      <= 26'd0;
                            led_position <= led_position << 1;
                        end
                    end
                    default: begin
                        counter      <= 26'd0;
                        led_position <= led_position;
                    end
                endcase
                LED <= led_position;
                if (led_position == 5'b10000) begin
                    if (mode == 2'b10) begin
                        LED   <= 5'b11111;
                        state <= 2'b11;
                    end else begin
                        led_position <= 5'b00001;
                        state        <= 2'b00;
                    end
                end
            end else begin
                LED <= 5'b11111;
            end
        end
    end

endmodule

module top_module_extended(
    input wire clk,
    input wire [3:0] button_mb,
    input wire button_2,
    input wire button_1,
    input wire [7:0] dip,
    output wire [4:0] led_mb,
    output wire [9:0] led,
    output wire dig3, dig2, dig1, dig0,
    output wire a, b, c, d, e, f, g,
    output wire colon
);

    wire [4:0] LED;
    wire [1:0] mode;
    wire gameReset;
    wire playerButton;

    miniGame game_inst (
        .clk(clk),
        .gameReset(gameReset),
        .button(playerButton),
        .LED(LED),
        .mode(mode)
    );

    assign gameReset    = button_1;
    assign playerButton = button_2;
    assign led_mb       = LED;s

endmodule
