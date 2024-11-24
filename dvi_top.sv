`include "dvi_pkg.svh"

module dvi
    import dvi_pkg::*;
(
    input  logic               clk_i,
    input  logic               rst_i,
    input  logic               tmds_clk_i,

    input  logic [COLOR_W-1:0] red_i,
    input  logic [COLOR_W-1:0] green_i,
    input  logic [COLOR_W-1:0] blue_i,

    output logic [X_POS_W-1:0] x_pos_o,
    output logic [Y_POS_W-1:0] y_pos_o,

    output logic               TMDS_CLK_N,
    output logic               TMDS_CLK_P,
    output logic [2:0]         TMDS_DATA_N,
    output logic [2:0]         TMDS_DATA_P
);


endmodule

