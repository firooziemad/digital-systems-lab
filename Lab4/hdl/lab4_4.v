module extensionBoard(
    input wire [1:0] Push_button,
    input wire [7:0] DIP_switch,
    output wire a,b,c,d,e,f,g,
    output wire [3:0] digs,
    output wire [9:0] LEDs,
    output reg dp
    );
    
    assign digs [3:0] = 4'b0001;

    wire x0, x1, x2, x3;
    wire p0, p1, p2;
    wire [7:0] px; 
    assign px=LEDs[6:0];

    assign x0 = DIP_switch[0];
    assign x1 = DIP_switch[1];
    assign x2 = DIP_switch[2];
    assign x3 = DIP_switch[3];

    assign p0 = x0 ^ x1 ^ x3;
    assign p1 = x0 ^ x2 ^ x3;
    assign p2 = x1 ^ x2 ^ x3;
    assign px = {p0, p1, x0, p2, x1, x2, x3};
endmodule