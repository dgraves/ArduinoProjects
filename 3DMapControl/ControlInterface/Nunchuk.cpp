// Nunchuk class from Arduino: A Quick-Start Guide, by Maik Schmidt
#include <WProgram.h>
#include <Wire.h>
#include "Nunchuk.h"

const uint8_t NUNCHUK_DEVICE_ID = 0x52;

void NunchukClass::initialize() {
  Wire.begin();
  Wire.beginTransmission(NUNCHUK_DEVICE_ID);
  Wire.send(0x40);
  Wire.send(0x00);
  Wire.endTransmission();
  update();
}

bool NunchukClass::update() {
  delay(1);
  
  Wire.requestFrom(NUNCHUK_DEVICE_ID, NUNCHUK_BUFFER_SIZE);

  int byte_counter = 0;
  while (Wire.available() && byte_counter < NUNCHUK_BUFFER_SIZE) {
    _buffer[byte_counter++] = decode_byte(Wire.receive());
  }

  request_data();

  return byte_counter == NUNCHUK_BUFFER_SIZE;
}

void NunchukClass::request_data() {
  Wire.beginTransmission(NUNCHUK_DEVICE_ID);
  Wire.send(0x00);
  Wire.endTransmission();
}

char NunchukClass::decode_byte(const char b) {
  return (b ^ 0x17) + 0x17;
}

NunchukClass Nunchuk;

