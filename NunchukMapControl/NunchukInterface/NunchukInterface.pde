#include <Wire.h>
#include "Nunchuk.h"

const unsigned int BAUD_RATE = 19200;

const char RECORD_UPDATE[] = "update";

void setup() {
  Serial.begin(BAUD_RATE);
  Nunchuk.initialize();
}

void loop() {
  if (Nunchuk.update()) {
    Serial.print("{");
    Serial.print(RECORD_UPDATE);
    Serial.print(",");
    Serial.print(Nunchuk.joystick_x());
    Serial.print(",");
    Serial.print(Nunchuk.joystick_y());
    Serial.print(",");
    Serial.print(Nunchuk.x_acceleration());
    Serial.print(",");
    Serial.print(Nunchuk.y_acceleration());
    Serial.print(",");
    Serial.print(Nunchuk.z_acceleration());
    Serial.print(",");
    Serial.print(Nunchuk.z_button());
    Serial.print(",");
    Serial.print(Nunchuk.c_button());
    Serial.print("}\n");
  }
}

