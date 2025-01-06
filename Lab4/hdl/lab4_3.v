`timescale 1ns / 1ps
module extensionBoard(
    input wire [1:0] Push_button,
    input wire [7:0] DIP_switch,
    output wire a,b,c,d,e,f,g,
    output wire [3:0] digs,
    output wire [9:0] LEDs,
    output reg dp
    );
    
    assign digs [3:0] = 4'b0001;

    wire [3:0] A, B;
    wire [3:0] B_adjusted;
    wire overflow;
    wire op;
    wire [3:0] sum;

    assign A = DIP_switch[3:0];
    assign B = DIP_switch[7:4];
    assign op = Push_button[0];
    
    assign B_adjusted = op ? ~B + 4'b0001 : B;

    four_bit_adding main_adder(
        .A(A),
        .B(B_adjusted),
        .sum(sum)
    );

    assign overflow = (A[3] == B_adjusted[3]) && (sum[3] != A[3]);
    assign LEDs[0] = overflow;
    
    wire [3:0] display_value;
    wire is_negative;
    assign is_negative = sum[3];
    assign display_value = is_negative ? (~sum[3:0] + 4'b0001) : sum[3:0];
    assign LEDs[1] = is_negative;

    Hex_to_7_seg hex_display(
        .Hex(overflow ? 4'b0000 : display_value),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g)
    );
endmodule

module four_bit_adding (
    input wire [3:0] A,
    input wire [3:0] B,
    output wire [3:0] sum
);
    wire Cout;
    wire [3:0] carries;

    full_adder FA0(
        .A(A[0]),
        .B(B[0]),
        .Cin(1'b0),
        .Sum(sum[0]),
        .Cout(carries[0])
    );
    
    full_adder FA1(
        .A(A[1]),
        .B(B[1]),
        .Cin(carries[0]),
        .Sum(sum[1]),
        .Cout(carries[1])
    );
    
    full_adder FA2(
        .A(A[2]),
        .B(B[2]),
        .Cin(carries[1]),
        .Sum(sum[2]),
        .Cout(carries[2])
    );
    
    full_adder FA3(
        .A(A[3]),
        .B(B[3]),
        .Cin(carries[2]),
        .Sum(sum[3]),
        .Cout(carries[3])
    );
endmodule

module full_adder(
    input wire A,
    input wire B,
    input wire Cin,
    output wire Sum,
    output wire Cout
);
    wire ha1_sum, ha1_carry, ha2_carry;
    
    half_adder HA1(
        .A(A),
        .B(B),
        .S(ha1_sum),
        .C(ha1_carry)
    );
    
    half_adder HA2(
        .A(ha1_sum),
        .B(Cin),
        .S(Sum),
        .C(ha2_carry)
    );
    
    assign Cout = ha1_carry | ha2_carry;
endmodule

module half_adder(
    input wire A,
    input wire B,
    output wire S,
    output wire C
);
    assign S = A ^ B;
    assign C = A & B;
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