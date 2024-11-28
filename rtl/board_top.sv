`include "dvi_pkg.svh"

`default_nettype none

module board_top
    import dvi_pkg::X_POS_W;
    import dvi_pkg::Y_POS_W;
    import dvi_pkg::COLOR_W;
(
    // verilator lint_off UNUSEDSIGNAL
    input  logic       clk_i,
    // verilator lint_on UNUSEDSIGNAL
    input  logic       rst_n_i,
    output logic       tmds_clk_n,
    output logic       tmds_clk_p,
    output logic [2:0] tmds_data_n,
    output logic [2:0] tmds_data_p
);

    logic               rst;
    // verilator lint_off UNUSEDSIGNAL
    // verilator lint_off UNDRIVEN
    logic               serial_clk;
    logic               pixel_clk_div2;
    logic               pixel_clk;
    logic               pll_lock;
    // verilator lint_on UNDRIVEN
    // verilator lint_on UNUSEDSIGNAL

    logic [X_POS_W-1:0] pos_x;
    logic [Y_POS_W-1:0] pos_y;

    logic [COLOR_W-1:0] red;
    logic [COLOR_W-1:0] green;
    logic [COLOR_W-1:0] blue;

    assign rst = ~rst_n_i;

    // Hide vendor black boxes from Verilator lint

    `ifndef VERILATOR

        // Create 252 MHz clock for serializer

        rPLL #(
            .FCLKIN    ( "27" ),
            .IDIV_SEL  ( 2    ),
            .FBDIV_SEL ( 27   ),
            .ODIV_SEL  ( 4    )
        ) rpll_inst (
            .CLKIN   ( clk_i      ), // 27 MHZ
            .CLKOUT  ( serial_clk ), // 252 MHz
            .LOCK    ( pll_lock   ),
            .RESET   ( '0         ),
            .RESET_P ( '0         ),
            .CLKFB   ( '0         ),
            .FBDSEL  ( '0         ),
            .IDSEL   ( '0         ),
            .ODSEL   ( '0         ),
            .PSDA    ( '0         ),
            .DUTYDA  ( '0         ),
            .FDLY    ( '0         )
        );

        // Divide by 10 to get 25.2 MHz pixel clock

        CLKDIV2 div_2 (
            .HCLKIN ( serial_clk     ),
            .CLKOUT ( pixel_clk_div2 ),
            .RESETN ( pll_lock       )
        );

        CLKDIV #(
            .DIV_MODE ("5")
        ) div_5 (
            .HCLKIN ( pixel_clk_div2 ),
            .CLKOUT ( pixel_clk      ),
            .RESETN ( pll_lock       )
        );

    `endif // VERILATOR

    dvi_top i_dvi_top (
        .serial_clk_i ( serial_clk  ),
        .pixel_clk_i  ( pixel_clk   ),
        .rst_i        ( rst         ),
        .red_i        ( red         ),
        .green_i      ( green       ),
        .blue_i       ( blue        ),
        .x_o          ( pos_x       ),
        .y_o          ( pos_y       ),
        .tmds_clk_p   ( tmds_clk_p  ),
        .tmds_clk_n   ( tmds_clk_n  ),
        .tmds_data_p  ( tmds_data_p ),
        .tmds_data_n  ( tmds_data_n )
    );

    image_gen i_image_gen (
        .clk_i   ( pixel_clk ),
        .x_i     ( pos_x     ),
        .y_i     ( pos_y     ),
        .red_o   ( red       ),
        .green_o ( green     ),
        .blue_o  ( blue      )
    );

endmodule
