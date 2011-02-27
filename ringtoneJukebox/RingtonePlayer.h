#ifndef RINGTONEPLAYER_H
#define RINGTONEPLAYER_H

#include <stdint.h>
#include <WString.h>
#include "Note.h"
#include "Ringtone.h"

typedef void (*PlayNoteNotification)(const Note&);

class RingtonePlayer {
public:
  RingtonePlayer();

  ~RingtonePlayer();

  // Number of built-in ringtones.
  uint16_t numRingtones() const;

  // Currently selected ringtone. Returns 0xFF if no selection has been made. 
  uint16_t selectedRingtone() const;

  // Select one of the built-in ringtones
  void selectRingtone(uint16_t index);
  
  // Determine if user specified ring tone is selected.
  bool isUserRingtoneSelected() const;

  // Check for presence of a user specified ringtone in EEPROM.
  bool hasUserRingtone() const;
  
  // Set the current ringtone to the ringtone stored in EEPROM.
  void selectUserRingtone();

  String ringtoneName() const;

  bool isPlaying() const;

  void play(uint8_t speakerPin);

  void stop();

  static void test(uint8_t speakerPin, uint8_t numScales);  // Valid numScale values are 1 through 5

private:
  Ringtone _ringtone;    // Access to our ringtones
  uint16_t _currentPos;  // Current position in the ring tone string
  uint8_t  _pin;
  int8_t   _timer;
};

#endif


