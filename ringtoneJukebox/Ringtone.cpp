#include <../../../../libraries/EEPROM/EEPROM.h>
#include <WProgram.h>
#include "Ringtone.h"
#include "ringtones.h"

#define DEBUG

const uint8_t DEFAULT_DURATION = 4;
const uint8_t DEFAULT_SCALE = 6;
const uint8_t DEFAULT_BPM = 63;

Ringtone::Ringtone()
: _duration(DEFAULT_DURATION),
  _scale(DEFAULT_SCALE),
  _bpm(DEFAULT_BPM),
  _length(0),
  _startPos(0),
  _userSelected(false),
  _currentRingtone(0xFF),
  _currentRingtoneAddr(0) {
}

const String& Ringtone::name() const {
  return _name;
}

uint8_t Ringtone::duration() const {
  return _duration;
}
  
uint8_t Ringtone::scale() const {
  return _scale;
}

uint8_t Ringtone::bpm() const {
  return _bpm;
}

uint16_t Ringtone::length() const {
  return _length;
}

char Ringtone::value(uint16_t index) {
  if (index >= _length) {
    //  Return null character when index exceeds data size
    return '\0';
  }
  
  if (_userSelected) {
    return EEPROM.read(_startPos + index);
  } else {
    // Get the address of the current ringtone from the 
    return pgm_read_byte(&(_currentRingtoneAddr[_startPos + index]));
  }
}

uint16_t Ringtone::total() const {
  return NUM_RINGTONES; // from ringtones.h
}

uint16_t Ringtone::selected() const {
  return _currentRingtone;
}

void Ringtone::select(uint16_t index) {
  if (total() > 0) {
    if (index >= total()) {
      // Clamp value to largest index in ringtone table
      index = total() - 1;
    }
  
    // Only load if the ringtone has changed
    if (_userSelected || (index != _currentRingtone)) {
      _userSelected = false;
      load(index);
    }
  }
}

bool Ringtone::isUserSelected() const {
  return _userSelected;
}

bool Ringtone::hasUser() const {
  // Check eeprom for an entry
  // Byte at 0 index will be 0xFF if not ringtone exists
  uint8_t value = EEPROM.read(0);
  if (value == 0xFF) {
    return false;
  } else {
    return true;
  }
}
  
void Ringtone::selectUser() {
  // Only load if the ringtone has changed
  if (!_userSelected) {
    _userSelected = true;
    loadUser();
  }
}

void Ringtone::clear() {
  _name = "";
  _length = 0;
  _startPos = 0;
}

void Ringtone::defaults() {
  _duration = DEFAULT_DURATION;
  _scale = DEFAULT_SCALE;
  _bpm = DEFAULT_BPM;
}

static PGM_P skipWhiteSpace(PGM_P src, PGM_P end) {
  while(src < end) {
    if(!isspace(pgm_read_byte(src))) {
      break;
    }
    ++src;
  }
  return src;
}

// Load the specified ringtone from program memory.
void Ringtone::load(uint16_t index) {
  _currentRingtone = index;

  // get the address of the ringtone in program memory
  _currentRingtoneAddr = (char*)pgm_read_word(&RINGTONES[_currentRingtone]);

  // Find the end of the ringtone name
  PGM_P end = strchr_P(_currentRingtoneAddr, ':');
  if (end == NULL) {
    clear();
    return;
  }
  
  // Extract the name
  uint16_t namelen = end - _currentRingtoneAddr;
  char name[11] = {0};
  for (uint16_t i = 0; i < namelen; ++i) {
    // Handle case where name is longer than the 10 character max
    if (i < 10) {
      name[i] = pgm_read_byte(&(_currentRingtoneAddr[i]));
    }
  }
  _name = name;

#ifdef DEBUG
  Serial.print("Ringtone name: ");
  Serial.println(_name);
#endif

  // Find the start and end of the control section
  PGM_P pos = end + 1;
  end = strchr_P(pos, ':');
  if (end == NULL) {
    clear();
    return;
  }

  // Load control defaults, in case some are unspecified by string
  defaults();

  // Skip any white space at start of substring
  // Needed in case the control section consists of only white space
  pos = skipWhiteSpace(pos, end);

  // Extract the control data
  while (pos < end) {
    // First char should define a control type
    char control = pgm_read_byte(pos);
    if (control != 'd' && control != 'o' && control != 'b') {
      // Skip unrecognized control type
      do {
        ++pos;
      } while (pos < end && pgm_read_byte(pos) != ',');
    } else {
      // Next character should be '='
      pos = skipWhiteSpace(++pos, end);
      if (pos == end || pgm_read_byte(pos) != '=') {
        clear();
        return;
      }
      
      pos = skipWhiteSpace(++pos, end);
      if (pos == end) {
        // Reaching end in the middle of control-pair expression is an error
        clear();
        return;
      }
  
      // Get the value
      char c = pgm_read_byte(pos);
      if (!isdigit(c)) {
        // Should be a number
        clear();
        return;
      }
      
      // No need to check pos < end because end is the non-digit ':'
      uint16_t value = 0;
      while (isdigit(c)) {
        value *= 10;
        value += c - '0';
        c = pgm_read_byte(++pos);
      }

      // Move on to next token
      pos = skipWhiteSpace(pos, end);
      
      // Should be ',' or ':'
      c = pgm_read_byte(pos);
      if (c != ',' && c != ':') {
        clear();
        return;
      }
      
      // Set the value
      switch (control) {
      case 'd':
        _duration = value;
        break;
      case 'o':
        _scale = value;
        break;
      case 'b':
        _bpm = value;
        break;
      }
    }
    
    // Move past ','
    if (pos < end) {
      pos = skipWhiteSpace(++pos, end);
      if (pos == end) {
        // Encountered a dangling ','
        clear();
        return;
      }
    }
  }

#ifdef DEBUG
  Serial.print("Ringtone duration: ");
  Serial.println((uint16_t)_duration);
  Serial.print("Ringtone scale: ");
  Serial.println((uint16_t)_scale);
  Serial.print("Ringtone bpm: ");
  Serial.println(_bpm);
#endif

  // Set the start position and length of command data
  _startPos = (end - _currentRingtoneAddr) + 1;
  _length = strlen_P(&_currentRingtoneAddr[_startPos]);

#ifdef DEBUG
  Serial.print("Ringtone command data length: ");
  Serial.println(_length);
  Serial.print("Ringtone command data start index: ");
  Serial.println(_startPos);
#endif
}
  
static uint16_t skipWhiteSpaceUser(uint16_t pos, uint16_t len) {
  while(pos < len) {
    if(!isspace(EEPROM.read(pos))) {
      break;
    }
    ++pos;
  }
  return pos;
}

void Ringtone::loadUser() {
  if (!hasUser()) {
    clear();
  } else {
    // Read the length of the ringtone string
    uint16_t length = EEPROM.read(1);
    length <<= 8;
    length |= EEPROM.read(2);
    
    if (length == 0) {
      clear();
      return;
    }
    
    uint16_t pos = 3;  // Start of ringtone data (after flag + size)
    length += 3;       // Full length of EEPROM data (ringtone + flag + size)

    // Read the name
    char name[11] = {0};
    char c = EEPROM.read(pos);
    uint16_t index = 0;
    while (c != ':') {
      if (index < 10) {
        name[index++] = c;
      }
      
      if (++pos == length) {
        // Reaching end of ringtone string while reading name is an error
        clear();
        return;
      }
    }
    
    _name = name;

#ifdef DEBUG
    Serial.print("Ringtone name: ");
    Serial.println(_name);
#endif

    // Increment past ':' and skip whitespace
    pos = skipWhiteSpaceUser(++pos, length);
    if (pos == length) {
      // Data was incomplete
      clear();
      return;
    }

    // Set control defaults in case they are not specified
    defaults();

    // Process the control data
    c = EEPROM.read(pos);
    while (c != ':') {
      char control = c;
      if (control != 'd' && control != 'o' && control != 'b') {
        // Skip unrecognized control type
        do {
          ++pos;
        } while (pos < length && EEPROM.read(pos) != ',');
      } else {
        // Next character should be '='
        pos = skipWhiteSpaceUser(++pos, length);
        if (pos == length || pgm_read_byte(pos) != '=') {
          clear();
          return;
        }
        
        pos = skipWhiteSpaceUser(++pos, length);
        if (pos == length) {
          // Reaching end in the middle of control-pair expression is an error
          clear();
          return;
        }
  
        // Get the value
        c = pgm_read_byte(pos);
        if (!isdigit(c)) {
          // Should be a number
          clear();
          return;
        }

        uint16_t value = 0;
        while (isdigit(c)) {
          value *= 10;
          value += c - '0';

          if (++pos == length) {
            // Reaching end of ringtone string while control value is an error
            clear();
            return;
          }
          c = EEPROM.read(pos);
        }

        // Move on to next token
        pos = skipWhiteSpaceUser(pos, length);
        if (pos == length) {
          clear();
          return;
        }
      
        // Should be ',' or ':'
        c = EEPROM.read(pos);
        if (c != ',' && c != ':') {
          clear();
          return;
        }
      
        // Set the value
        switch (control) {
        case 'd':
          _duration = value;
          break;
        case 'o':
          _scale = value;
          break;
        case 'b':
          _bpm = value;
          break;
        }
      }
    
      // Move past ','
      if (c == ',') {
        pos = skipWhiteSpaceUser(++pos, length);
        if (pos == length) {
          // Encountered a dangling ','
          clear();
          return;
        }
        c = EEPROM.read(pos);
      }
    }

#ifdef DEBUG
    Serial.print("Ringtone duration: ");
    Serial.println((uint16_t)_duration);
    Serial.print("Ringtone scale: ");
    Serial.println((uint16_t)_scale);
    Serial.print("Ringtone bpm: ");
    Serial.println(_bpm);
#endif

    // Set start position to character after ':'
    if (++pos == length) {
      // Reaching end of ringtone string while control value is an error
      clear();
      return;
    }
    
    _startPos = pos;
    _length = length - pos;

#ifdef DEBUG
    Serial.print("Ringtone command data length: ");
    Serial.println(_length);
    Serial.print("Ringtone command data start index: ");
    Serial.println(_startPos);
#endif
  }
}

