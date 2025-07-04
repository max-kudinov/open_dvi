# Open DVI driver

![dvi_demo](images/dvi.jpg)

I've done this project with a purpose to learn low-level implementation of DVI
protocol and stuff around it.

The idea was to make it vendor agnostic, portable and capable of running on open
source toolchain ([Yosys](https://github.com/YosysHQ/yosys)).
The only vendor specific black-boxes are PLL, `CLKDIV` for proper clocking and `TLVDS_OBUF`
for LVDS output. If the target is not Gowin FPGA, generic RTL solution is provided as a fallback.

Generic DS started to have problems after certain Yosys update, and nextpnr gives
clock net routing warning, so it was decided to use a vendor primitive in this case.

Clocking primitives are in `board_top.sv` file and could be easily avoided by adapting
`dvi_top.sv` module for your needs instead. `TLVDS_OBUF` is in `ds_buf.sv` and can
be replaced with a primitive for your target.

If you happen to have Tang Primer 20K, then you can use `pins.cst` file
and `synth_n_load.sh` script to try this design.

## How to run on open source toolchain

You'll need Yosys and one of the supported FPGA Place and Route and bitstream tools.
For Tang Primer 20K it is [nextpnr](https://github.com/YosysHQ/nextpnr) and
[Project Apicula](https://github.com/YosysHQ/apicula).

The easiest option to start with is to download everything in binary from
[OSS CAD SUITE](https://github.com/YosysHQ/oss-cad-suite-build).

You'll also need a tool to translate SystemVerilog packages to something that
Yosys understands, for example to Verilog 2005. You can use
[SV2V](https://github.com/zachjs/sv2v) for that.
