#!/bin/sh

device="GW2A-LV18PG256C8/I7"
board="tangprimer20k"

source ~/oss-cad-suite/environment

# Synthesis into Gowin primitives
if ! yosys -m slang -p "read_slang                 \
                        --single-unit              \
                        --libraries-inherit-macros \
                        -DGOWIN                    \
                        -Irtl/include              \
                        rtl/*                      \
                        rtl/blackboxes/*;          \
                        synth_gowin -json design.json"
then
    echo "Yosys failed"
    exit 1
fi

# PnR
if ! nextpnr-himbaechel --json design.json --write design_pnr.json  \
    --device $device --vopt family=GW2A-18 --vopt cst=pins.cst --sdc constraints.sdc
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
