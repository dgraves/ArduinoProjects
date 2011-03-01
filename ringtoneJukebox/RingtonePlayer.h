#ifndef RINGTONEPLAYER_H
#define RINGTONEPLAYER_H

#include <stdint.h>
#include <WString.h>
#include "Note.h"
#include "Ringtone.h"

typedef void (*PlayNoteCallback)(const Note&);

class RingtonePlayerClass {
public:
  RingtonePlayerClass();

  ~RingtonePlayerClass();

  void begin(uint8_t speakerPin);

  bool isPlaying() const;

  void play();

  void stop();

  // Specify a callback to receive notification when a note is played
  void setPlayNoteCallback(PlayNoteCallback callback);

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

  // Name of currently selectd ringtone
  const String& ringtoneName() const;

  // Retrieve the ringtone
  const Ringtone& ringtone() const;

private:
  Ringtone _ringtone;    // Access to our ringtones
  uint8_t  _pin;
};

extern RingtonePlayerClass RingtonePlayer;

#endif


