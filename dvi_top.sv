`include "dvi_pkg.svh"

`default_nettype none

module dvi_top
    // import dvi_pkg::X_POS_W;
    // import dvi_pkg::Y_POS_W;
    // import dvi_pkg::COLOR_W;
(
    input  logic               serial_clk_i,
    input  logic               pixel_clk_i,
    input  logic               rst_i,

    input  logic [COLOR_W-1:0] red_i,
    input  logic [COLOR_W-1:0] green_i,
    input  logic [COLOR_W-1:0] blue_i,

    output logic [X_POS_W-1:0] x_o,
    output logic [Y_POS_W-1:0] y_o,

    output logic [        2:0] tmds_data_p,
    output logic [        2:0] tmds_data_n,
    output logic               tmds_clk_p,
    output logic               tmds_clk_n
);

    logic               hsync;
    logic               vsync;
    logic               visible_range;
    logic               hsync_r;
    logic               vsync_r;
    logic               visible_range_r;

    logic [        9:0] red_tmds;
    logic [        9:0] green_tmds;
    logic [        9:0] blue_tmds;

    logic               red_serial;
    logic               green_serial;
    logic               blue_serial;

    // ------------------------------------------------------------------------
    // Sync
    // ------------------------------------------------------------------------

    dvi_sync i_dvi_sync (
        .clk_i           ( pixel_clk_i   ),
        .rst_i           ( rst_i         ),
        .hsync_o         ( hsync         ),
        .vsync_o         ( vsync         ),
        .pixel_x_o       ( x_o           ),
        .pixel_y_o       ( y_o           ),
        .visible_range_o ( visible_range )
    );

    // ------------------------------------------------------------------------
    // Encode
    // ------------------------------------------------------------------------

    // Delay hsync/vsync and visible_range by 1 clock cycle to account for color
    // delay in image_gen
    always_ff @(posedge pixel_clk_i) begin
        if (rst_i) begin
            hsync_r         <= '0;
            vsync_r         <= '0;
            visible_range_r <= '0;
        end else begin
            hsync_r         <= hsync;
            vsync_r         <= vsync;
            visible_range_r <= visible_range;
        end
    end

    tmds_encoder blue_encoder (
        .clk_i ( pixel_clk_i     ),
        .rst_i ( rst_i           ),
        .C0    ( hsync_r         ),
        .C1    ( vsync_r         ),
        .DE    ( visible_range_r ),
        .D     ( blue_i          ),
        .q_out ( blue_tmds       )
    );

    tmds_encoder green_encoder (
        .clk_i ( pixel_clk_i     ),
        .rst_i ( rst_i           ),
        .C0    ( 1'b0            ),
        .C1    ( 1'b0            ),
        .DE    ( visible_range_r ),
        .D     ( green_i         ),
        .q_out ( green_tmds      )
    );

    tmds_encoder red_encoder (
        .clk_i ( pixel_clk_i     ),
        .rst_i ( rst_i           ),
        .C0    ( 1'b0            ),
        .C1    ( 1'b0            ),
        .DE    ( visible_range_r ),
        .D     ( red_i           ),
        .q_out ( red_tmds        )
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
        .clk_i ( serial_clk_i    ),
        .in    ( blue_serial     ),
        .out   ( tmds_data_p [0] ),
        .out_n ( tmds_data_n [0] )
    );

    ds_buf green_ds_buf (
        .clk_i ( serial_clk_i    ),
        .in    ( green_serial    ),
        .out   ( tmds_data_p [1] ),
        .out_n ( tmds_data_n [1] )
    );

    ds_buf red_ds_buf (
        .clk_i ( serial_clk_i    ),
        .in    ( red_serial      ),
        .out   ( tmds_data_p [2] ),
        .out_n ( tmds_data_n [2] )
    );

    ds_buf clk_ds_buf (
        .clk_i ( serial_clk_i ),
        .in    ( pixel_clk_i  ),
        .out   ( tmds_clk_p   ),
        .out_n ( tmds_clk_n   )
    );

endmodule
