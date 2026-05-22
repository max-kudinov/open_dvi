`include "dvi_pkg.svh"

`default_nettype none

module board_top
    import dvi_pkg::W_H_RES;
    import dvi_pkg::W_V_RES;
    import dvi_pkg::W_COLOR;
(
    // verilator lint_off UNUSEDSIGNAL
    input  var logic       clk,
    // verilator lint_on UNUSEDSIGNAL
    input  var logic       rst_n,
    output var logic       tmds_clk_n,
    output var logic       tmds_clk_p,
    output var logic [2:0] tmds_data_n,
    output var logic [2:0] tmds_data_p
);

logic               rst;
// verilator lint_off UNUSEDSIGNAL
// verilator lint_off UNDRIVEN
logic               serial_clk;
logic               pixel_clk_div2;
logic               pixel_clk;
logic               pll_lock;
logic               in_range_nc;
// verilator lint_on UNDRIVEN
// verilator lint_on UNUSEDSIGNAL

logic [W_H_RES-1:0] pos_x;
logic [W_V_RES-1:0] pos_y;

logic [W_COLOR-1:0] red;
logic [W_COLOR-1:0] green;
logic [W_COLOR-1:0] blue;

assign rst = !rst_n;

// Hide vendor black boxes from linters
`ifdef GOWIN

    // Create 252 MHz clock for serializer
    rPLL #(
        .FCLKIN    ("27"),
        .IDIV_SEL  (2   ),
        .FBDIV_SEL (27  ),
        .ODIV_SEL  (4   )
    ) rpll_inst (
        .CLKIN   (clk       ), // 27 MHZ
        .CLKOUT  (serial_clk), // 252 MHz
        .LOCK    (pll_lock  ),
        .RESET   ('0        ),
        .RESET_P ('0        ),
        .CLKFB   ('0        ),
        .FBDSEL  ('0        ),
        .IDSEL   ('0        ),
        .ODSEL   ('0        ),
        .PSDA    ('0        ),
        .DUTYDA  ('0        ),
        .FDLY    ('0        )
    );

    // Divide by 10 to get 25.2 MHz pixel clock

    CLKDIV2 div_2 (
        .HCLKIN (serial_clk    ),
        .CLKOUT (pixel_clk_div2),
        .RESETN (pll_lock      )
    );

    CLKDIV #(
        .DIV_MODE ("5")
    ) div_5 (
        .HCLKIN (pixel_clk_div2),
        .CLKOUT (pixel_clk     ),
        .RESETN (pll_lock      )
    );

`endif // GOWIN

dvi_top dvi_top (
    .serial_clk  (serial_clk ),
    .pixel_clk   (pixel_clk  ),
    .rst         (rst        ),
    .red_i       (red        ),
    .green_i     (green      ),
    .blue_i      (blue       ),
    .px_x_o      (pos_x      ),
    .px_y_o      (pos_y      ),
    .in_range_o  (in_range_nc),
    .tmds_clk_p  (tmds_clk_p ),
    .tmds_clk_n  (tmds_clk_n ),
    .tmds_data_p (tmds_data_p),
    .tmds_data_n (tmds_data_n)
);

image_gen image_gen (
    .clk     (pixel_clk),
    .x_i     (pos_x    ),
    .y_i     (pos_y    ),
    .red_o   (red      ),
    .green_o (green    ),
    .blue_o  (blue     )
);

endmodule

`resetall
