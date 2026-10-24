# Burnin-Rubber-by-Dar

Burnin' Rubber (Data East), FPGA core by Dar (<http://darfpga.blogspot.fr>), ported to
Digilent Basys 3 (`xc7a35tcpg236-1`). Upstream:
<https://sourceforge.net/projects/darfpga/files/Software%20VHDL/burnin_rubber/>
(`vhdl_burnin_rubber_rev_0_0_2017_12_22.zip`, rev 0.0).

## Hardware

- Basys 3; VGA monitor (31 kHz, MiST scandoubler) or 15 kHz TV (sw13, not verified).
- Keyboard on the onboard USB HID port.
- Optional: Atari-compatible joystick on Pmod JXADC (pins 1/2/3/4/7 =
  right/left/down/up/jump, active low, pull-ups in the XDC).
- Optional: [PmodAMP2](https://digilent.com/reference/pmod/pmodamp2/start) on Pmod JA,
  pins 1/2/4.

## Build

Requires gcc, unzip, Vivado 2020.2, and
[openFPGALoader](https://github.com/trabucayre/openFPGALoader) (`make load` only).

```
make help        # list all targets
make roms        # brubber.zip from $ROMDIR
make bitstream   # Vivado batch build (runs make roms first if needed)
make load        # program the Basys 3 over USB (SRAM, lost at power-off)
```

Overrides, as make arguments or environment variables:
`VIVADO=<path>/bin/vivado` (default `/tools/Xilinx/Vivado/2020.2/bin/vivado`),
`ROMDIR=<dir>` (default `~/roms`), `ROMZIP=<zip>[,<zip>]`.

ROMs are not included. Do not redistribute roms or anything generated from them.

## IO

Keys follow the MAME defaults. Player 2 shares the player 1 controls.

| Action                 | Keyboard     | Basys 3                       |
|------------------------|--------------|-------------------------------|
| steer                  | Left / Right | JXADC pins 2 / 1              |
| accelerate / slow down | Up / Down    | JXADC pins 4 / 3              |
| jump                   | Left Ctrl    | JXADC pin 7                   |
| start 1P               | 1            | btnL                          |
| start 2P               | 2            | btnR                          |
| coin                   | 5 / 6        | btnU / btnD                   |
| reset                  |              | btnC                          |
| display                |              | sw13 (down 31 kHz, up 15 kHz) |
| amp gain               |              | sw14 (up gain active)         |
| audio                  |              | sw15 (up disabled)            |

## Issues Addressed

- Last 8 active lines lost on the VGA path: vsync starts at vblank onset, vcnt 248
  instead of 240 (`contrib/patches/burnin_rubber_vsync_before_vblank.patch`).
- Vivado rejects MiST `scandoubler.v` as Verilog-2001 (local declarations in unnamed
  blocks, single-value array size): blocks named, full range declared
  (`contrib/basys3/mist_scandoubler.patch`).

## Third-party additions

- MiST `scandoubler.v` (Till Harbaum, GPL-3.0), in `contrib/third_party/mist/`.
  Origin: [mist-devel/mist-modules@147aa5c](https://github.com/mist-devel/mist-modules/blob/147aa5c11b117eaeda3fd9e81dbff2dc5f12cb14/scandoubler.v).
  Vivado fixes in `contrib/basys3/mist_scandoubler.patch`.

## License

- Basys 3 port additions: MIT, see `LICENSE` (scope stated there).
- DarFPGA sources: educational use only; do not redistribute synthesized files with roms
  (see `vhdl_burnin_rubber_rev_0_0_2017_12_22/README.txt`).
- T65 CPU (`t65/`): BSD-style, Daniel Wallner et al.
- YM2149 sound (`rtl_mikej/`): BSD-style, MikeJ.
- MiST `scandoubler.v`: GPL-3.0.
