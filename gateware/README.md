# Gateware for papilio_rgb_led

This directory contains the FPGA-side Verilog modules for the RGB LED peripheral.

Files:
- `wb_simple_rgb_led.v` - 8-bit Wishbone slave presenting simple color registers.
- `wb_rgb_led_ctrl.v` - 32-bit-friendly wrapper and `ws2812b_controller` implementation.

Usage:
- Include these files in your FPGA project and hook up the LED `led_out` signal to the WS2812B data pin.
- The address map maps RGB registers into the 0x00 region used by the example host firmware.

Build:
- Add these source files to your Gowin project and run the standard gateware build.
