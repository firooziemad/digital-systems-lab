module extensionBoard(
    input wire [1:0] Push_button,
    input wire [7:0] DIP_switch,
    output wire a,b,c,d,e,f,g,
    output wire [3:0] digs,
    output wire [9:0] LEDs,
    output reg dp
    );
    
    assign digs [3:0] = 4'b1111;

    wire c0, c1, c2;
    wire [2:0] syndrome;
    reg [3:0] display_value;

    wire p0_rx = DIP_switch[6];  // p0'
    wire p1_rx = DIP_switch[5];  // p1'
    wire x0_rx = DIP_switch[4];  // x0'
    wire p2_rx = DIP_switch[3];  // p2'
    wire x1_rx = DIP_switch[2];  // x1'
    wire x2_rx = DIP_switch[1];  // x2'
    wire x3_rx = DIP_switch[0];  // x3'

    assign c0 = p0_rx ^ x0_rx ^ x1_rx ^ x3_rx;
    assign c1 = p1_rx ^ x0_rx ^ x2_rx ^ x3_rx;
    assign c2 = p2_rx ^ x1_rx ^ x2_rx ^ x3_rx;
    
    assign syndrome = {c2, c1, c0};

    always @(*) begin        
    display_value = {x0_rx, x1_rx, x2_rx, x3_rx};        
        case(syndrome)
            3'b011: begin  // Error in x0 (position 3)
                display_value[0] = ~x0_rx;
            end
            3'b101: begin  // Error in x1 (position 5)
                display_value[1] = ~x1_rx;
            end
            3'b110: begin  // Error in x2 (position 6)
                display_value[2] = ~x2_rx;
            end
            3'b111: begin  // Error in x3 (position 7)
                display_value[3] = ~x3_rx;
            end
        endcase
    end

    Hex_to_7_seg seg_decoder(
        .Hex(display_value),
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