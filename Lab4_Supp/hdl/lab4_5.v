`timescale 1ns / 1ps

// Hex_to_7_seg module converts a 4-bit hexadecimal input to 7-segment display signals
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

// extensionBoard module integrates comparison logic for A and B
module extensionBoard(
    input wire [3:0] button_mb,        // Button inputs (not used in this design)
    output wire [4:0] led_mb,          // LED outputs
    input wire [1:0] Push_button,      // Push buttons (not used in this design)
    input wire [7:0] DIP_switch,       // DIP switches for inputs A and B
    output wire a, b, c, d, e, f, g,   // 7-segment display signals
    output wire [3:0] digs,            // Digit select lines (unused)
    output wire [9:0] LEDs,            // Additional LEDs (unused)
    output reg dp                      // Decimal point (unused)
    );

    // Initialize decimal point to off
    initial dp = 1'b1;

    // Instantiate the Hex_to_7_seg module (for potential use)
    // Example: Displaying a static value or integrating with other functionalities
    // For this specific question, it's not directly used
    // However, it's instantiated here as per the provided code structure
    Hex_to_7_seg display_unit (
        .Hex(4'd0), // Example: Display '0' initially
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g)
    );

    // Assign unused digit selects and other LEDs as needed
    assign digs = 4'b0000;       // Not used in this implementation
    assign LEDs = 10'b0000000000; // Not used in this implementation

    // Extract A and B from DIP_switch
    wire [3:0] A = DIP_switch[3:0];
    wire [3:0] B = DIP_switch[7:4];

    // Unsigned comparison: A > B
    wire unsigned_gt = (A > B);

    // Signed comparison: A > B (2's complement)
    wire signed_gt = ($signed(A) > $signed(B));

    // Equality check: A == B
    wire equal = (A == B);

    // Assign the comparison results to led_mb[2:0]
    assign led_mb[0] = unsigned_gt; // led[0] = A > B (unsigned)
    assign led_mb[1] = signed_gt;   // led[1] = A > B (signed)
    assign led_mb[2] = equal;       // led[2] = A == B

    // Optionally, you can assign other LEDs or use them for additional indicators
    // For example, led_mb[4:3] can be used for other purposes
    assign led_mb[4:3] = 2'b00; // Not used in this implementation

endmodule
