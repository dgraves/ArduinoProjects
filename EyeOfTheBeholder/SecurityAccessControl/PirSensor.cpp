/*
 Interact with PIR sensor from Parallax

 created 26 Jun 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
*/
#include <WProgram.h>
#include "PirSensor.h"

PirSensor::PirSensor(unsigned int pin) :
 _pin(pin) {
  pinMode(_pin, INPUT);
}

bool PirSensor::detected() const {
  return (digitalRead(_pin) != 0);
}

