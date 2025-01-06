// basic_nor_latch
module basic_nor_latch (
    input S,
    input R,
    output Q,
    output Q_bar
);
    nor (Q, S, Q_bar);
    nor (Q_bar, R, Q);
endmodule

// gated_sr_latch
module gated_sr_latch (
    input S,
    input R,
    input En,
    output Q,
    output Q_bar
);
    wire S_en, R_en;

    and (S_en, S, En);
    and (R_en, R, En);

    nor (Q, S_en, Q_bar);
    nor (Q_bar, R_en, Q);
endmodule

// gated_sr_latch_nand
module gated_sr_latch_nand (
    input S_n,
    input R_n,
    input En_n,
    output Q,
    output Q_bar
);
    wire S_en, R_en;

    nand (S_en, S_n, En_n);
    nand (R_en, R_n, En_n);

    nand (Q, S_en, Q_bar);
    nand (nand2_out, R_en, Q);
endmodule

// gated_d_latch
module gated_d_latch (
    input D,
    input En,
    output Q,
    output Q_bar
);
    wire S, R;

    and (S, D, En);
    and (R, ~D, En);

    nor (Q, S, Q_bar);
    nor (Q_bar, R, Q);
endmodule

// master_slave_dff
module master_slave_dff (
    input D,
    input clk,
    output Q,
    output Q_bar
);
    wire clk_bar;
    wire Q_master, Q_master_bar;

    not (clk_bar, clk);

    gated_d_latch master (
        .D(D),
        .En(clk),
        .Q(Q_master),
        .Q_bar(Q_master_bar)
    );

    gated_d_latch slave (
        .D(Q_master),
        .En(clk_bar),
        .Q(Q),
        .Q_bar(Q_bar)
    );
endmodule

// pos_edge_dff
module pos_edge_dff (
    input D,
    input clk,
    output Q,
    output Q_bar
);
    wire p1, p2, p3, p4;

    nand (p3, p1, p4);
    nand (p1, p3, clk);
    nand (p2, p1, p4, clk);
    nand (p4, p2, D);

    nand (Q, p1, Q_bar);
    nand (Q_bar, p2, Q);
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
    wire [3:0] button_mb_n;
    assign button_mb_n = ~button_mb;

    //a) Basic NOR Latch
    wire latch_a_Q, latch_a_Q_bar;
    basic_nor_latch latch_a (
        .S(dip[0]),
        .R(dip[1]),
        .Q(latch_a_Q),
        .Q_bar(latch_a_Q_bar)
    );
    assign led[0] = latch_a_Q;
    assign led[1] = latch_a_Q_bar;

    //b) Gated SR Latch
    wire latch_b_Q, latch_b_Q_bar;
    gated_sr_latch latch_b (
        .S(dip[2]),
        .R(dip[3]),
        .En(button_mb_n[0]),
        .Q(latch_b_Q),
        .Q_bar(latch_b_Q_bar)
    );
    assign led[2] = latch_b_Q;
    assign led[3] = latch_b_Q_bar;

    //c) Gated SR Latch with NAND Gates
    wire latch_c_Q, latch_c_Q_bar;
    gated_sr_latch_nand latch_c (
        .S_n(button_mb_n[1]),
        .R_n(button_mb_n[2]),
        .En_n(button_mb_n[3]),
        .Q(latch_c_Q),
        .Q_bar(latch_c_Q_bar)
    );
    assign led[4] = latch_c_Q;
    assign led[5] = latch_c_Q_bar;

    //d) Gated D Latch
    wire latch_d_Q, latch_d_Q_bar;
    gated_d_latch latch_d (
        .D(dip[4]),
        .En(button_1),
        .Q(latch_d_Q),
        .Q_bar(latch_d_Q_bar)
    );
    assign led[6] = latch_d_Q;
    assign led[7] = latch_d_Q_bar;

    //e) Master-Slave D Flip-Flop
    wire flipflop_e_Q, flipflop_e_Q_bar;
    master_slave_dff flipflop_e (
        .D(dip[5]),
        .clk(button_2),
        .Q(flipflop_e_Q),
        .Q_bar(flipflop_e_Q_bar)
    );
    assign led[8] = flipflop_e_Q;
    assign led[9] = flipflop_e_Q_bar;

    //f) Positive-Edge-Triggered D Flip-Flop
    wire flipflop_f_Q, flipflop_f_Q_bar;
    pos_edge_dff flipflop_f (
        .D(dip[6]),
        .clk(button_1),
        .Q(flipflop_f_Q),
        .Q_bar(flipflop_f_Q_bar)
    );
    assign led_mb[0] = flipflop_f_Q;
    assign led_mb[1] = flipflop_f_Q_bar;
endmodule
