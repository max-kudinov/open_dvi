`include "dvi_pkg.svh"

`default_nettype none

module image_gen
    import dvi_pkg::X_POS_W;
    import dvi_pkg::Y_POS_W;
    import dvi_pkg::COLOR_W;
(
    input  var logic               clk_i,
    input  var logic [X_POS_W-1:0] x_i,
    input  var logic [Y_POS_W-1:0] y_i,
    output var logic [COLOR_W-1:0] red_o,
    output var logic [COLOR_W-1:0] green_o,
    output var logic [COLOR_W-1:0] blue_o
);

    localparam IMG_RES   = 256;
    localparam QR_RES    = 135;

    localparam IX_OFFSET = 20;
    localparam IY_OFFSET = 20;

    localparam QX_OFFSET = 180;
    localparam QY_OFFSET = 75;

    logic [COLOR_W-1:0] red;
    logic [COLOR_W-1:0] green;
    logic [COLOR_W-1:0] blue;

    logic [X_POS_W-1:0] x_scaled;
    logic [Y_POS_W-1:0] y_scaled;

    logic [7:0]         img_mem [65536];
    logic [7:0]         color;

    // Big-endian is needed to read the image in the correct order
    // verilator lint_off ASCRANGE
    logic [0:134]       qr_mem [135];
    logic               qr_pixel;
    // verilator lint_on ASCRANGE

    initial begin
        $readmemh("images/lena.mem", img_mem);
        $readmemb("images/qr.mem", qr_mem);
    end

    always_ff @(posedge clk_i) begin
        if ((x_i > IX_OFFSET) && (x_i < IMG_RES + IX_OFFSET) &&
            (y_i > IY_OFFSET) && (y_i < IMG_RES + IY_OFFSET)) begin

            color <= img_mem[((y_i - IY_OFFSET) << 8)
                            + (x_i - IX_OFFSET)];
        end
    end

    always_ff @(posedge clk_i) begin
        if ((x_scaled > QX_OFFSET) && (x_scaled < QR_RES + QX_OFFSET) &&
            (y_scaled > QY_OFFSET) && (y_scaled < QR_RES + QY_OFFSET)) begin

            qr_pixel <= qr_mem[8'(y_scaled - 10'(QY_OFFSET))]
                              [8'(x_scaled - 10'(QX_OFFSET))];
        end
    end

    always_comb begin
        red   = '0;
        green = '0;
        blue  = '0;

        if (x_i == 320) begin
            red   = '1;
        end

        if (y_i == 240) begin
            blue   = '1;
        end

        x_scaled = x_i >> 1;
        y_scaled = y_i >> 1;

        // QR code
        if ((x_scaled > QX_OFFSET) && (x_scaled < QR_RES + QX_OFFSET) &&
            (y_scaled > QY_OFFSET) && (y_scaled < QR_RES + QY_OFFSET)) begin

            red   = '1;
            green = '1;
            blue  = '1;

            if (qr_pixel) begin
                red   = y_i[$left(y_i) -: 8];
                green = '0;
                blue  = x_i[$left(x_i) -: 8];
            end
        end

        // Lena image
        if ((x_i > IX_OFFSET) && (x_i < IMG_RES + IX_OFFSET) &&
            (y_i > IY_OFFSET) && (y_i < IMG_RES + IY_OFFSET)) begin

            red   = color;
            green = color;
            blue  = color;
        end
    end

    always_ff @(posedge clk_i) begin
        red_o   <= red;
        green_o <= green;
        blue_o  <= blue;
    end

endmodule
