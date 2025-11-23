// RGB LED helper library for controlling FPGA WS2812B controller via Wishbone SPI
#pragma once

#include <Arduino.h>
#include <SPI.h>
#include "WishboneSPI.h"

class RGBLed {
public:
    // Wishbone register addresses (8-bit)
    static const uint16_t REG_LED_GREEN = 0x00;
    static const uint16_t REG_LED_RED   = 0x01;
    static const uint16_t REG_LED_BLUE  = 0x02;
    static const uint16_t REG_LED_CTRL  = 0x03;

    // Common colors in GRB format (dimmed to ~10% for examples)
    static const uint32_t COLOR_OFF;
    static const uint32_t COLOR_RED;
    static const uint32_t COLOR_GREEN;
    static const uint32_t COLOR_BLUE;
    static const uint32_t COLOR_YELLOW;
    static const uint32_t COLOR_CYAN;
    static const uint32_t COLOR_MAGENTA;
    static const uint32_t COLOR_WHITE;
    static const uint32_t COLOR_ORANGE;
    static const uint32_t COLOR_PURPLE;

    // Initialize library (calls wishboneInit)
    static void begin(SPIClass* spi, uint8_t csPin);

    // Set LED color using 24-bit GRB value
    static void setColor(uint32_t color);

    // Set LED color using separate RGB components (0-255)
    static void setColorRGB(uint8_t red, uint8_t green, uint8_t blue);

    // Check LED controller busy flag
    static bool isBusy();

private:
    static uint8_t _csPin;
};
