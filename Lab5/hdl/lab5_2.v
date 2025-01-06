// behavioral_d_latch
module behavioral_d_latch (
    input wire D,
    input wire En,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @ (D or En) begin
        if (En)
            Q <= D;
    end
endmodule

// behavioral_neg_edge_dff
module behavioral_neg_edge_dff (
    input wire D,
    input wire clk,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @ (negedge clk) begin
        Q <= D;
    end
endmodule

// behavioral_pos_edge_dff
module behavioral_pos_edge_dff (
    input wire D,
    input wire clk,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @ (posedge clk) begin
        Q <= D;
    end
endmodule

// behavioral_dff_async_preset_clear
module behavioral_dff_async_preset_clear (
    input wire D,
    input wire clk,
    input wire preset,
    input wire clear,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @ (posedge clk or posedge preset or posedge clear) begin
        if (preset)
            Q <= 1'b1;
        else if (clear)
            Q <= 1'b0;
        else
            Q <= D;
    end
endmodule

// behavioral_dff_sync_preset_clear
module behavioral_dff_sync_preset_clear (
    input wire D,
    input wire clk,
    input wire preset,
    input wire clear,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @ (posedge clk) begin
        if (preset)
            Q <= 1'b1;
        else if (clear)
            Q <= 1'b0;
        else
            Q <= D;
    end
endmodule

// behavioral_t_flip_flop
module behavioral_t_flip_flop (
    input wire T,
    input wire clk,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @ (posedge clk) begin
        if (T)
            Q <= ~Q;
    end
endmodule

// behavioral_jk_flip_flop
module behavioral_jk_flip_flop (
    input wire J,
    input wire K,
    input wire clk,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @ (posedge clk) begin
        case ({J, K})
            2'b00: Q <= Q;
            2'b01: Q <= 1'b0;
            2'b10: Q <= 1'b1;
            2'b11: Q <= ~Q;
            default: Q <= Q;
        endcase
    end
endmodule

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

    wire d_latch_Q, d_latch_Qn;

    wire neg_dff_Q, neg_dff_Qn;

    wire pos_dff_Q, pos_dff_Qn;

    wire async_dff_Q, async_dff_Qn;

    wire sync_dff_Q, sync_dff_Qn;

    wire t_ff_Q, t_ff_Qn;

    wire jk_ff_Q, jk_ff_Qn;

    wire clk_pos, clk_neg;

    assign clk_pos = ~button_mb[0];
    assign clk_neg = button_mb[0];

    // a) D-Latch
    behavioral_d_latch d_latch_inst (
        .D(dip[0]),
        .En(button_1),
        .Q(d_latch_Q),
        .Q_bar(d_latch_Qn)
    );

    // b) Negative Edge-Triggered D Flip-Flop
    behavioral_neg_edge_dff neg_dff_inst (
        .D(dip[1]),
        .clk(clk_neg),
        .Q(neg_dff_Q),
        .Q_bar(neg_dff_Qn)
    );

    // c) Positive Edge-Triggered D Flip-Flop
    behavioral_pos_edge_dff pos_dff_inst (
        .D(dip[2]),
        .clk(clk_pos),
        .Q(pos_dff_Q),
        .Q_bar(pos_dff_Qn)
    );

    // d) D Flip-Flop with Asynchronous Preset and Clear
    behavioral_dff_async_preset_clear async_dff_inst (
        .D(dip[3]),
        .clk(clk_pos),
        .preset(dip[4]),
        .clear(dip[5]),
        .Q(async_dff_Q),
        .Q_bar(async_dff_Qn)
    );

    // e) D Flip-Flop with Synchronous Preset and Clear
    behavioral_dff_sync_preset_clear sync_dff_inst (
        .D(dip[6]),
        .clk(clk_pos),
        .preset(dip[7]),
        .clear(button_2),
        .Q(sync_dff_Q),
        .Q_bar(sync_dff_Qn)
    );

    // f) T Flip-Flop
    behavioral_t_flip_flop t_ff_inst (
        .T(button_1),
        .clk(clk_pos),
        .Q(t_ff_Q),
        .Q_bar(t_ff_Qn)
    );

    // g) JK Flip-Flop
    behavioral_jk_flip_flop jk_ff_inst (
        .J(button_2),
        .K(dip[0]),
        .clk(clk_pos),
        .Q(jk_ff_Q),
        .Q_bar(jk_ff_Qn)
    );

    assign led[0] = d_latch_Q;
    assign led[1] = d_latch_Qn;
    assign led[2] = neg_dff_Q;
    assign led[3] = neg_dff_Qn;
    assign led[4] = pos_dff_Q;
    assign led[5] = pos_dff_Qn;
    assign led[6] = async_dff_Q;
    assign led[7] = async_dff_Qn;
    assign led[8] = sync_dff_Q;
    assign led[9] = sync_dff_Qn;
    assign led_mb[0] = t_ff_Q;
    assign led_mb[1] = t_ff_Qn;
    assign led_mb[2] = jk_ff_Q;
    assign led_mb[3] = jk_ff_Qn;
endmodule