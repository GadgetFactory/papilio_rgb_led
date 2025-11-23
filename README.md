# Papilio RGB LED Software Library — `lib/papilio_rgb_led`

This small Arduino/PlatformIO library provides a simple API to control the FPGA-side WS2812B RGB LED controller (exposed as Wishbone registers) used in the Papilio Arcade template.

Files
- `src/RGBLed.h` — Public header with API and color constants.
- `src/RGBLed.cpp` — Implementation that calls the existing `wishbone_spi` helpers (`wishboneInit`, `wishboneWrite8`, `wishboneRead8`).

Dependencies
- `lib/wishbone_spi` — the library providing `wishboneInit` and register read/write helpers. Ensure it is available to your build.

Color format
- The library uses GRB ordering (Green high byte, Red middle byte, Blue low byte) to match WS2812B LED ordering.

Public API
- `void RGBLed::begin(SPIClass* spi, uint8_t csPin)`
  - Initialize the library and the underlying Wishbone SPI helper. Call once in `setup()`.
- `void RGBLed::setColor(uint32_t grbColor)`
  - Set the LED color using a 24-bit GRB value (0xGGRRBB).
- `void RGBLed::setColorRGB(uint8_t red, uint8_t green, uint8_t blue)`
  - Set color using separate RGB components (0-255). The library converts to GRB internally.
- `bool RGBLed::isBusy()`
  - Returns true while the WS2812B transmission is in progress.

Color constants
- Use `RGBLed::COLOR_RED`, `RGBLed::COLOR_GREEN`, `RGBLed::COLOR_BLUE`, etc. for example colors.

Example (Arduino / PlatformIO)

Assuming the same SPI pin defines used in the template (`SPI_CLK`, `SPI_MOSI`, `SPI_MISO`, `SPI_CS`):

```cpp
SPIClass *fpgaSPI = new SPIClass(HSPI);
fpgaSPI->begin(SPI_CLK, SPI_MISO, SPI_MOSI, SPI_CS);
pinMode(SPI_CS, OUTPUT);
digitalWrite(SPI_CS, HIGH);

// Initialize library (this calls wishboneInit internally)
RGBLed::begin(fpgaSPI, SPI_CS);

// Set LED to green
RGBLed::setColor(RGBLed::COLOR_GREEN);

// Or set RGB components directly
RGBLed::setColorRGB(25, 0, 0); // dim red

// Optionally check busy
if (RGBLed::isBusy()) {
  // wait or do other work
}
```

Notes
- The library adds a short `delay(100)` after writing the color to give the FPGA controller time to latch and update the LED. If you need non-blocking behavior or tighter timing, let me know and I can add a non-blocking version.
- The library intentionally delegates low-level Wishbone operations to `wishbone_spi` so the same code works with the existing SPI-to-Wishbone bridge used by the template.

Suggestions
- Add an `examples/` folder in the library with a minimal sketch showing initialization and a color-cycle demo.
- If you'd like, I can add a `README.md` that includes wiring diagrams, or add unit-like tests using a host-side mock of `wishbone_spi`.
