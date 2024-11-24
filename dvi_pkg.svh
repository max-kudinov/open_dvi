`ifndef DVI_PKG_SVH
`define DVI_PKG_SVH

package dvi_pkg;

    parameter SCREEN_H_RES  = 640;
    parameter SCREEN_V_RES  = 480;

    parameter COLOR_W       = 8;

    parameter BOARD_CLK_MHZ = 27;

    parameter X_POS_W       = $clog2(SCREEN_H_RES);
    parameter Y_POS_W       = $clog2(SCREEN_V_RES);

endpackage : dvi_pkg

`endif
