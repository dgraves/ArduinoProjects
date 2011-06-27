/*
 Reader for the RFID Serial module from Parallax

 created 25 Jun 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
*/
#include <WProgram.h>
#include "RfidSerial.h"

const unsigned int MAX_READS = 64;        // Maximum number of reads for available()
const unsigned int RFID_BAUDRATE = 2400;  // Baud rate for Parallax RFID reader

RfidSerial::RfidSerial(int soutPin, int enablePin) :
 _reader(soutPin, enablePin),
 _soutPin(soutPin),
 _enablePin(enablePin),
 _enabled(false),
 _started(false) {
  _reader.begin(RFID_BAUDRATE);
  pinMode(_enablePin, OUTPUT);
  disable();
}

bool RfidSerial::available(String *id) {
  unsigned int reads = 0;

  while (_reader.available()) {
    char c = _reader.read();

    // IDs read from the Parallax serial RFID reader start with '\n'
    if (!_started) {
      if (c == '\n') {
        _started = true;
      }
    } else {
      if (c == '\r') {
        // Finished reading
        _started = false;
        *id = _buffer;
        _buffer = "";
        return true;
      } else {
        _buffer += c;
      }
    }

    if (++reads >= MAX_READS) {
      break;
    }
  }

  return false;
}

bool RfidSerial::isEnabled() const {
  return _enabled;
}

void RfidSerial::enable() {
  digitalWrite(_enablePin, 0);
  _enabled = true;
}

void RfidSerial::disable() {
  digitalWrite(_enablePin, 1);
  _enabled = false;
}

