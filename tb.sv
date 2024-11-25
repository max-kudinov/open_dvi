module tb;
    logic pixel_clk;
    logic serial_clk;
    logic rst;

    logic       tmds_clk_p;
    logic       tmds_clk_n;
    logic [2:0] tmds_data_p;
    logic [2:0] tmds_data_n;

    initial begin
        rst <= '1;
        @(posedge pixel_clk);
        rst <= '0;
    end

    initial begin
        serial_clk = '0;
        forever begin
            #1 serial_clk = ~serial_clk;
        end
    end

    initial begin
        pixel_clk = '0;
        forever begin
            #10 pixel_clk = ~pixel_clk;
        end
    end

    initial begin
        $dumpvars;

        repeat (100) begin
            @(posedge pixel_clk);
        end

        $finish;
    end

    dvi_top dut (
        .serial_clk_i (serial_clk),
        .pixel_clk_i  (pixel_clk),
        .rst_i        (rst),
        .tmds_clk_p   (tmds_clk_p),
        .tmds_clk_n   (tmds_clk_n),
        .tmds_data_p  (tmds_data_p),
        .tmds_data_n  (tmds_data_n)
    );
endmodule
