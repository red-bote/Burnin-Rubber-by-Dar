#!/bin/bash
# Port of make_burnin_rubber_proms.bat for the Basys3 build. Run from this
# directory (the unzipped brubber.zip) by contrib/tools/roms.sh, which sets:
#   MAKE_VHDL_PROM  path of the compiled make_vhdl_prom
#   PROM_DIR        output directory for the PROM VHDL
# make_vhdl_prom names the entity after its output argument, so it runs inside
# PROM_DIR with bare output file names.

set -euo pipefail

: "${MAKE_VHDL_PROM:?}" "${PROM_DIR:?}"
roms="$(pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat brubber.12c brubber.12d > "$tmp/burnin_rubber_prog.bin"

cd "$PROM_DIR"
"$MAKE_VHDL_PROM" "$tmp/burnin_rubber_prog.bin" burnin_rubber_prog.vhd
"$MAKE_VHDL_PROM" "$roms/bnj4e.bin"             fg_sp_graphx_1.vhd
"$MAKE_VHDL_PROM" "$roms/bnj4f.bin"             fg_sp_graphx_2.vhd
"$MAKE_VHDL_PROM" "$roms/bnj4h.bin"             fg_sp_graphx_3.vhd
"$MAKE_VHDL_PROM" "$roms/bnj10e.bin"            bg_graphx_1.vhd
"$MAKE_VHDL_PROM" "$roms/bnj10f.bin"            bg_graphx_2.vhd
"$MAKE_VHDL_PROM" "$roms/bnj6c.bin"             burnin_rubber_sound_prog.vhd
