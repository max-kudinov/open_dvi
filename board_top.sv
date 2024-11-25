module board_top (
    input  logic       clk_i,
    input  logic       rst_n_i,
    output logic       tmds_clk_n,
    output logic       tmds_clk_p,
    output logic [2:0] tmds_data_n,
    output logic [2:0] tmds_data_p
);

    logic rst;
    logic serial_clk;
    logic pixel_clk_raw;
    logic pixel_clk;
    logic pll_lock;

    assign rst = ~rst_n_i;

    CLKDIV #(
        .DIV_MODE ("5")
    ) div_5 (
        .HCLKIN (serial_clk),
        .CLKOUT (pixel_clk_raw),
        .RESETN (pll_lock)
    );

    CLKDIV #(
        .DIV_MODE ("2")
    ) div_2 (
        .HCLKIN (pixel_clk_raw),
        .CLKOUT (pixel_clk),
        .RESETN (pll_lock)
    );

    rPLL #(
        .FCLKIN    ( "27" ),
        .IDIV_SEL  ( 2    ), // -> PFD = 9 MHz (range: 3-400 MHz)
        .FBDIV_SEL ( 27   ), // -> CLKOUT = 252 MHz (range: 3.125-600 MHz)
        .ODIV_SEL  ( 4    )  // -> VCO = 1008 MHz (range: 400-1200 MHz)
    ) pll (
        .RESET   ( 1'b0       ),
        .RESET_P ( 1'b0       ),
        .CLKFB   ( 1'b0       ),
        .FBDSEL  ( 6'b0       ),
        .IDSEL   ( 6'b0       ),
        .ODSEL   ( 6'b0       ),
        .PSDA    ( 4'b0       ),
        .DUTYDA  ( 4'b0       ),
        .FDLY    ( 4'b0       ),
        .CLKIN   ( clk_i      ), // 27 MHz
        .CLKOUT  ( serial_clk ),  // 252 MHz
        .LOCK    ( pll_lock   )
    );

    dvi_top i_dvi_top (
        .serial_clk_i ( serial_clk  ),
        .pixel_clk_i  ( pixel_clk   ),
        .rst_i        ( rst         ),
        .tmds_clk_p   ( tmds_clk_p  ),
        .tmds_clk_n   ( tmds_clk_n  ),
        .tmds_data_p  ( tmds_data_p ),
        .tmds_data_n  ( tmds_data_n )
    );

endmodule
