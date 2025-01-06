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

    wire [3:0] display_value;
    
    three_bit_adder main_adder(
        .A(DIP_switch[2:0]),
        .B(DIP_switch[5:3]),
        .Cin(DIP_switch[6]),
        .final_display(display_value)
    );
    
    Hex_to_7_seg hex_display(
        .Hex(display_value),
        .a(a),
        .b(b),
        .c(c),
        .d(c),
        .e(d),
        .f(f),
        .g(g)
    );
endmodule

module three_bit_adder (
    input wire [2:0] A,
    input wire [2:0] B,
    input wire Cin,
    output wire [3:0] final_display
);
    wire Cout;
    wire [2:0] sum;
    wire carry1, carry2;

    full_adder FA0(
        .A(A[0]),
        .B(B[0]),
        .Cin(Cin),
        .Sum(sum[0]),
        .Cout(carry1)
    );
    
    full_adder FA1(
        .A(A[1]),
        .B(B[1]),
        .Cin(carry1),
        .Sum(sum[1]),
        .Cout(carry2)
    );
    
    full_adder FA2(
        .A(A[2]),
        .B(B[2]),
        .Cin(carry2),
        .Sum(sum[2]),
        .Cout(Cout)
    );
    
    assign final_display = {{Cout}, {sum}};
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