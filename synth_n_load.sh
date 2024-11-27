#!/bin/sh

device="GW2A-LV18PG256C8/I7"
board="tangprimer20k"

# Synthesis into Gowin primitives
if ! yosys -p "read -sv board_top.sv dvi_sync.sv serializer.sv tmds_encoder.sv \
               dvi_top.sv ds_buf.sv image_gen.sv; synth_gowin -json design.json"
then
    echo "Yosys failed"
    exit 1
fi

# PnR
if ! nextpnr-himbaechel --json design.json --write design_pnr.json  \
    --device $device --vopt family=GW2A-18 --vopt cst=pins.cst
then
    echo "Nextpnr failed"
    exit 1
fi

# Generate bitstream
echo "------------------------------------"
echo "Generating bitstream for the board.."
echo "------------------------------------"
if ! gowin_pack -d $device -o pack.fs design_pnr.json
then
    echo "Gowin_pack failed"
    exit 1
fi
echo "DONE!"

# Load into board
echo "--------------------------------"
echo "Loading bitstream into the board"
echo "--------------------------------"
if ! openFPGALoader -b $board pack.fs
then
    echo "openFPGALoader failed"
    exit 1
fi
