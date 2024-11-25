`include "dvi_pkg.svh"

module dvi_top
    // import dvi_pkg::X_POS_W;
    // import dvi_pkg::Y_POS_W;
    // import dvi_pkg::COLOR_W;
(
    input  logic       serial_clk_i,
    input  logic       pixel_clk_i,
    input  logic       rst_i,
    output logic       tmds_clk_p,
    output logic       tmds_clk_n,
    output logic [2:0] tmds_data_p,
    output logic [2:0] tmds_data_n
);

    logic               hsync;
    logic               vsync;
    logic [X_POS_W-1:0] pixel_x;
    logic [Y_POS_W-1:0] pixel_y;
    logic               visible_range;

    logic [9:0] red_tmds;
    logic [9:0] green_tmds;
    logic [9:0] blue_tmds;

    logic red_serial;
    logic green_serial;
    logic blue_serial;

    logic [COLOR_W-1:0] red;
    logic [COLOR_W-1:0] green;
    logic [COLOR_W-1:0] blue;

    logic [134:0] qr_mem [0:134];

    logic [134:0] row;

    initial begin
        $readmemb("qr.mem", qr_mem);
    end

    logic [7:0] scaled_x;
    logic [7:0] scaled_y;

    always_comb begin
            red   = '0;
            green = '0;
            blue  = '0;
            row = '0;

            scaled_x = pixel_x >> 1;
            scaled_y = pixel_y >> 1;

            row = qr_mem[8'(scaled_y)];

        if (visible_range) begin
            if (scaled_x < 135 && scaled_y < 135) begin
                if (row[scaled_x]) begin
                    red   = 8'd255;
                    green = 8'd255;
                    blue  = 8'd255;
                end
            end
        end
    end

    // ------------------------------------------------------------------------
    // Sync
    // ------------------------------------------------------------------------

    dvi_sync i_dvi_sync (
        .clk_i           ( pixel_clk_i   ),
        .rst_i           ( rst_i         ),
        .hsync_o         ( hsync         ),
        .vsync_o         ( vsync         ),
        .pixel_x_o       ( pixel_x       ),
        .pixel_y_o       ( pixel_y       ),
        .visible_range_o ( visible_range )
    );

    // ------------------------------------------------------------------------
    // Encode
    // ------------------------------------------------------------------------

    tmds_encoder blue_encoder (
        .clk_i ( pixel_clk_i   ),
        .rst_i ( rst_i         ),
        .C0    ( hsync         ),
        .C1    ( vsync         ),
        .DE    ( visible_range ),
        .D     ( blue          ),
        .q_out ( blue_tmds     )
    );

    tmds_encoder green_encoder (
        .clk_i ( pixel_clk_i   ),
        .rst_i ( rst_i         ),
        .C0    ( 1'b0          ),
        .C1    ( 1'b0          ),
        .DE    ( visible_range ),
        .D     ( green         ),
        .q_out ( green_tmds    )
    );

    tmds_encoder red_encoder (
        .clk_i ( pixel_clk_i   ),
        .rst_i ( rst_i         ),
        .C0    ( 1'b0          ),
        .C1    ( 1'b0          ),
        .DE    ( visible_range ),
        .D     ( red           ),
        .q_out ( red_tmds      )
    );

    // ------------------------------------------------------------------------
    // Serialize
    // ------------------------------------------------------------------------

    serializer #(
        .DATA_W ( 10 )
    ) blue_serializer (
        .clk_i  ( serial_clk_i ),
        .rst_i  ( rst_i        ),
        .data_i ( blue_tmds    ),
        .data_o ( blue_serial  )
    );

    serializer #(
        .DATA_W ( 10 )
    ) green_serializer (
        .clk_i  ( serial_clk_i ),
        .rst_i  ( rst_i        ),
        .data_i ( green_tmds   ),
        .data_o ( green_serial )
    );

    serializer #(
        .DATA_W ( 10 )
    ) red_serializer (
        .clk_i  ( serial_clk_i ),
        .rst_i  ( rst_i        ),
        .data_i ( red_tmds     ),
        .data_o ( red_serial   )
    );


    // ------------------------------------------------------------------------
    // Create differential signals
    // ------------------------------------------------------------------------


    ds_buf blue_ds_buf (
        .in    ( blue_serial     ),
        .out   ( tmds_data_p [0] ),
        .out_n ( tmds_data_n [0] )
    );

    ds_buf green_ds_buf (
        .in    ( green_serial    ),
        .out   ( tmds_data_p [1] ),
        .out_n ( tmds_data_n [1] )
    );

    ds_buf red_ds_buf (
        .in    ( red_serial      ),
        .out   ( tmds_data_p [2] ),
        .out_n ( tmds_data_n [2] )
    );

    ds_buf clk_ds_buf (
        .in    ( pixel_clk_i ),
        .out   ( tmds_clk_p  ),
        .out_n ( tmds_clk_n  )
    );

endmodule
