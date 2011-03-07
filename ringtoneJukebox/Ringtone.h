#ifndef RINGTONE_H
#define RINGTONE_H

#include <stdint.h>
#include <WString.h>

// Facade providing access to both the built-in ring tones stored in program
// memory and a user specified ringtone stored in EEPROM
class Ringtone {
public:
  Ringtone();

  void init();

  // Retrieves the name of the ringtone. The ringtone's name is found at the
  // start of the ringtone string, followed by the ':' character.
  const String& name() const;

  // Duration control value for current ringtone.
  uint8_t duration() const;

  // Scale control value for current ringtone.
  uint8_t scale() const;

  // Beats per minute control value for current ringtone.
  uint16_t bpm() const;

  // Length of the currently selected ringtone's command data. The reported length only describes
  // the portion of the ringtone string conaining the ringtone command data. The lengths of
  // the ringtone name and control section are not inlcuded.
  uint16_t length() const;

  // Retrieve the character from ringtone data stored at the specified location.
  char value(uint16_t index) const;

  // Number of built-in ringtones.
  uint16_t total() const;

  // Currently selected ringtone. Returns 0xFF if no selection has been made.
  uint16_t selected() const;

  // Set the current ringtone to the built-in ringtone specified.
  void select(uint16_t index);

  // Determine if user specified ring tone is selected.
  bool isUserSelected() const;

  // Check for presence of a user specified ringtone in EEPROM.
  bool hasUser() const;

  // Set the current ringtone to the ringtone stored in EEPROM.
  void selectUser();

private:
  void clear();
  void defaults();
  void load(uint16_t index);
  void loadUser();

private:
  String      _name;
  uint8_t     _duration;
  uint8_t     _scale;
  uint16_t    _bpm;
  uint16_t    _length;
  uint16_t    _startPos;
  bool        _userSelected;
  uint16_t    _currentRingtone;
  const char* _currentRingtoneAddr;
};

#endif

