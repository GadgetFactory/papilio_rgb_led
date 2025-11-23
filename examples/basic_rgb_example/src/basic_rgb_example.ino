// Basic example for papilio_rgb_led
// Shows how to initialize and set LED colors using the RGBLed API

#include <SPI.h>
#include "RGBLed.h"

// Adjust pins to your board
#define SPI_CLK   12
#define SPI_MOSI  11
#define SPI_MISO  9
#define SPI_CS    10

SPIClass *fpgaSPI = nullptr;

void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.println("Basic RGBLed Example");

  fpgaSPI = new SPIClass(HSPI);
  fpgaSPI->begin(SPI_CLK, SPI_MISO, SPI_MOSI, SPI_CS);

  // Initialize the high-level RGB LED library (it will use the wishbone helper)
  RGBLed::begin(fpgaSPI, SPI_CS);

  // Set a few colors to verify functionality
  RGBLed::setColor(RGBLed::COLOR_GREEN);
  Serial.println("Set GREEN");
  delay(1000);

  RGBLed::setColor(RGBLed::COLOR_RED);
  Serial.println("Set RED");
  delay(1000);

  RGBLed::setColor(RGBLed::COLOR_BLUE);
  Serial.println("Set BLUE");
}

void loop() {
  // Nothing to do in loop for this simple example
  delay(1000);
}
