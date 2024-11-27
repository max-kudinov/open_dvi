module board_top (
    input  logic       clk_i,
    input  logic       rst_n_i,
    output logic       led,
    output logic       tmds_clk_n,
    output logic       tmds_clk_p,
    output logic [2:0] tmds_data_n,
    output logic [2:0] tmds_data_p
);

    logic rst;
    logic serial_clk;
    logic pixel_clk_div2;
    logic pixel_clk;
    logic pll_lock;

    logic [23:0] cnt;

    assign rst = ~rst_n_i;

    always_ff @(posedge pixel_clk) begin
        cnt <= cnt + 1'b1;
    end

    assign led = cnt[23];


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

    `endif

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
