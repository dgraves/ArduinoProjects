/*
 Interact with PIR sensor from Parallax

 created 26 Jun 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
*/
#ifndef PIRSENSOR_H
#define PIRSENSOR_H

class PirSensor {
public:
  PirSensor(unsigned int pin);

  // Indicates that motion has been detected
  // The Parallax PIR sensor asserts a signal for about 1 second after detection
  bool detected() const;

private:
  const unsigned int _pin;
};

#endif

