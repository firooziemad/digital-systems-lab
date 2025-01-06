`timescale 1ns / 1ps
module extensionBoard(
    input wire [3:0] button_mb,
    input wire button_2, button_1,
    input wire [7:0] dip,
    output wire [4:0] led_mb,
    output wire [9:0] led,
    output wire dig3, dig2, dig1, dig0,
    output wire a, b, c, d, e, f, g,
    output wire colon
    );

    assign dig0 = 1'b1;

    wire [3:0] x;
    assign x[3] = dip[3];
    assign x[2] = dip[2];
    assign x[1] = dip[1];
    assign x[0] = dip[0];

    wire [7:0] N;
    assign N[0] = dip[4];
    assign N[1] = dip[5];
    assign N[2] = dip[6];
    assign N[3] = dip[7];
    assign N[4] = ~button_mb[0];
    assign N[5] = ~button_mb[1];
    assign N[6] = ~button_mb[2];
    assign N[7] = ~button_mb[3];

    wire p0, p1, p2, p3;
    assign p0 = x[0] ^ x[1] ^ x[3];
    assign p1 = x[0] ^ x[2] ^ x[3];
    assign p2 = x[1] ^ x[2] ^ x[3];
    assign p3 = x[3] ^ x[2] ^ x[1] ^ x[0] ^ p2 ^ p1 ^ p0;

    wire [7:0] code;
    assign code = {p3, x[3], x[2], x[1], p2, x[0], p1, p0};

    wire [7:0] noisy_code;
    assign noisy_code = code ^ N;

    reg [7:0] corrected_code;
    wire [2:0] syndrome;
    wire c0, c1, c2;

    wire p0_received = noisy_code[0]; // position 1
    wire p1_received = noisy_code[1]; // position 2
    wire x0_received = noisy_code[2]; // position 3
    wire p2_received = noisy_code[3]; // position 4
    wire x1_received = noisy_code[4]; // position 5
    wire x2_received = noisy_code[5]; // position 6
    wire x3_received = noisy_code[6]; // position 7
    wire p3_received = noisy_code[7]; // position 8

    assign c0 = p0_received ^ x0_received ^ x1_received ^ x3_received;
    assign c1 = p1_received ^ x0_received ^ x2_received ^ x3_received;
    assign c2 = p2_received ^ x1_received ^ x2_received ^ x3_received;

    assign syndrome = {c2, c1, c0};

    wire parity_code;
    assign parity_code = noisy_code[6] ^ noisy_code[5] ^ noisy_code[4] ^ noisy_code[3] ^ noisy_code[2] ^ noisy_code[1] ^ noisy_code[0];

    wire parity_check;
    assign parity_check = p3_received ^ parity_code;

    reg [1:0] error_type;

    reg [3:0] Hex;

    always @(*) begin
        corrected_code = noisy_code;
        if (syndrome == 3'b000) begin
            if (parity_check == 1'b0) begin
                error_type = 2'b00;
                Hex = 4'b0000;
            end else begin
                error_type = 2'b10;
                Hex = 4'b1110;
            end
        end else begin
            if (parity_check == 1'b1) begin
                error_type = 2'b01;
                case (syndrome)
                    3'b001: corrected_code[0] = ~corrected_code[0];
                    3'b010: corrected_code[1] = ~corrected_code[1];
                    3'b011: corrected_code[2] = ~corrected_code[2];
                    3'b100: corrected_code[3] = ~corrected_code[3];
                    3'b101: corrected_code[4] = ~corrected_code[4];
                    3'b110: corrected_code[5] = ~corrected_code[5];
                    3'b111: corrected_code[6] = ~corrected_code[6];
                    default: corrected_code = noisy_code;
                endcase
                Hex = {1'b0, syndrome};
            end else begin
                error_type = 2'b10;
                Hex = 4'b1110;
            end
        end
    end

    wire [3:0] corrected_data;
    assign corrected_data = {corrected_code[6], corrected_code[5], corrected_code[4], corrected_code[2]};

    assign led[3:0] = (error_type == 2'b10) ? 4'b1111 : corrected_data;

    assign dig3 = 1'b0;
    assign dig2 = 1'b0;
    assign dig1 = (error_type == 2'b10) ? 1'b1 : 1'b0;
    assign dig0 = 1'b1;

    Hex_to_7_seg display (
        .Hex(Hex),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g)
    );

endmodule

module Hex_to_7_seg (
    input wire [3:0] Hex,
    output reg a, b, c, d, e, f, g
    );
    always @(Hex) begin
        case(Hex)
            0  : {a,b,c,d,e,f,g} = ~(7'b1111110);
            1  : {a,b,c,d,e,f,g} = ~(7'b0110000);
            2  : {a,b,c,d,e,f,g} = ~(7'b1101101);
            3  : {a,b,c,d,e,f,g} = ~(7'b1111001);
            4  : {a,b,c,d,e,f,g} = ~(7'b0110011);
            5  : {a,b,c,d,e,f,g} = ~(7'b1011011);
            6  : {a,b,c,d,e,f,g} = ~(7'b1011111);
            7  : {a,b,c,d,e,f,g} = ~(7'b1110000);
            8  : {a,b,c,d,e,f,g} = ~(7'b1111111);
            9  : {a,b,c,d,e,f,g} = ~(7'b1111011);
            10 : {a,b,c,d,e,f,g} = ~(7'b1110111); // A
            11 : {a,b,c,d,e,f,g} = ~(7'b0011111); // B
            12 : {a,b,c,d,e,f,g} = ~(7'b1001110); // C
            13 : {a,b,c,d,e,f,g} = ~(7'b0111101); // D
            14 : {a,b,c,d,e,f,g} = ~(7'b1001111); // E
            15 : {a,b,c,d,e,f,g} = ~(7'b1000111); // F
            default: {a,b,c,d,e,f,g} = ~(7'b0000000); // Default off
        endcase
    end
endmodule