#include "RGBLed.h"

// Color constants (GRB format)
const uint32_t RGBLed::COLOR_OFF     = 0x000000;
const uint32_t RGBLed::COLOR_RED     = 0x001900; // G=0, R=25, B=0
const uint32_t RGBLed::COLOR_GREEN   = 0x190000; // G=25, R=0, B=0
const uint32_t RGBLed::COLOR_BLUE    = 0x000019; // G=0, R=0, B=25
const uint32_t RGBLed::COLOR_YELLOW  = 0x191900;
const uint32_t RGBLed::COLOR_CYAN    = 0x190019;
const uint32_t RGBLed::COLOR_MAGENTA = 0x001919;
const uint32_t RGBLed::COLOR_WHITE   = 0x191919;
const uint32_t RGBLed::COLOR_ORANGE  = 0x0C1900;
const uint32_t RGBLed::COLOR_PURPLE  = 0x000C0C;

uint8_t RGBLed::_csPin = 0xFF;

void RGBLed::begin(SPIClass* spi, uint8_t csPin) {
    _csPin = csPin;
    wishboneInit(spi, csPin);
}

void RGBLed::setColor(uint32_t color) {
    uint8_t g = (color >> 16) & 0xFF;
    uint8_t r = (color >> 8) & 0xFF;
    uint8_t b = color & 0xFF;

    wishboneWrite8(REG_LED_GREEN, g);
    wishboneWrite8(REG_LED_RED, r);
    wishboneWrite8(REG_LED_BLUE, b);

    delay(100);
}

void RGBLed::setColorRGB(uint8_t red, uint8_t green, uint8_t blue) {
    uint32_t color = ((uint32_t)green << 16) | ((uint32_t)red << 8) | blue;
    setColor(color);
}

bool RGBLed::isBusy() {
    uint8_t status = wishboneRead8(REG_LED_CTRL);
    return (status & 0x01) != 0;
}
