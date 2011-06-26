/*
 Reader for the RFID Serial module from Parallax

 created 25 Jun 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
*/
#ifndef RFIDSERIAL_H
#define RFIDSERIAL_H

#include <WString.h>
#include <NewSoftSerial.h>

class RfidSerial {
public:
  RfidSerial(int soutPin, int enablePin);

  // Retrieve an ID from reader, if available
  // Returns true if an ID was available, and false if not
  bool available(String *id);

  bool isEnabled() const;

  void enable();

  void disable();

private:
  NewSoftSerial _reader;
  String _buffer;
  const unsigned int _soutPin;
  const unsigned int _enablePin;
  bool _enabled;
  bool _started;            // Has started reading an ID
};

#endif

