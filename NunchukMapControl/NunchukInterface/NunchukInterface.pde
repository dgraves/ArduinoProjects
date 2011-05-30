/*
 Reads data from the Wii Nunchuk, decodes it, and writes
 it to the serial device.

 circuit:
 * Nunhcuk data line on analog pin 4
 * Nunhcuk clock line on analog pin 5

 Nunchuk pin diagram:

                 NC
             __  |  __
            |  \___/  |
  Clock ->  | *  *  * |  <- GND
   3.3V ->  |_*__*__*_|  <- Data
                 |
                 NC

 created 10 Apr 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
 */
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

