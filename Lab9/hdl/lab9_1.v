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

reg [1:0] S_GREEN, S_YELLOW, S_RED;
reg [31:0] YELLOW_TIME;

always @* begin
    S_GREEN      = 2'b00;
    S_YELLOW     = 2'b01;
    S_RED        = 2'b10;
    YELLOW_TIME  = 32'd250000000;
end

reg [1:0] state_reg, state_next;
reg [27:0] count_reg, count_next;

always @(posedge clk or posedge button_1) begin
    if (button_1) begin
        state_reg <= S_GREEN;
        count_reg <= 0;
    end
    else begin
        state_reg <= state_next;
        count_reg <= count_next;
    end
end

always @* begin
    state_next = state_reg;
    count_next = count_reg;

    case (state_reg)
        S_GREEN: 
            if (dip[0]) begin
                state_next = S_YELLOW;
                count_next = 0;
            end
        S_YELLOW: 
            if (count_reg < YELLOW_TIME)
                count_next = count_reg + 1;
            else
                state_next = S_RED;
        S_RED: 
            if (!dip[0])
                state_next = S_GREEN;
        default: 
            state_next = S_GREEN;
    endcase
end

reg [6:0] seg_bits;
always @* begin
    case (state_reg)
        S_RED:    seg_bits = 7'b0001000;
        S_YELLOW: seg_bits = 7'b0000001;
        S_GREEN:  seg_bits = 7'b1000000;
        default:  seg_bits = 7'b0000000;
    endcase
end

assign {a,b,c,d,e,f,g} = ~seg_bits;
assign dig0 = 1'b0;
assign led[0] = (state_reg == S_RED);
endmodule