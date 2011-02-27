#include <WProgram.h>
#include "RingtonePlayer.h"

// Frequency * 100
static const uint16_t FREQ[12] = {
  22000,      // Frequencies for four octaves for A
  23308,      // Frequencies for four octaves for A# / Bb
  24694,      // Frequencies for four octaves for B / Cb
  26163,      // Frequencies for four octaves for C
  27718,      // Frequencies for four octaves for C# / Db
  29366,      // Frequencies for four octaves for D
  31113,      // Frequencies for four octaves for D# / Eb
  32963,      // Frequencies for four octaves for E / Fb 
  34923,      // Frequencies for four octaves for F / E#
  36999,      // Frequencies for four octaves for F# / Gb
  39200,      // Frequencies for four octaves for G
  41530,      // Frequencies for four octaves for G# / Ab
};

static const uint8_t NUM_FREQS = 12;

RingtonePlayer::RingtonePlayer()
: _pin(8),
  _timer(0) {
}

RingtonePlayer::~RingtonePlayer() {
  stop();
}

// Number of built-in ringtones.
uint16_t RingtonePlayer::numRingtones() const {
  return _ringtone.total();
}

// Currently selected ringtone.
uint16_t RingtonePlayer::selectedRingtone() const {
  return _ringtone.selected();
}

// Select one of the built-in ringtones
void RingtonePlayer::selectRingtone(uint16_t index) {
  _ringtone.select(index);
}
  
// Determine if user specified ring tone is selected.
bool RingtonePlayer::isUserRingtoneSelected() const {
  return _ringtone.isUserSelected();
}

// Check for presence of a user specified ringtone in EEPROM.
bool RingtonePlayer::hasUserRingtone() const {
  return _ringtone.hasUser();
}
  
// Set the current ringtone to the ringtone stored in EEPROM.
void RingtonePlayer::selectUserRingtone() {
  _ringtone.selectUser();
}

String RingtonePlayer::ringtoneName() const {
  return _ringtone.name();
}

bool RingtonePlayer::isPlaying() const {
  return false;
}

void RingtonePlayer::play(uint8_t speakerPin) {
  if (!isPlaying()) {
    _pin = speakerPin;
  }
}

void RingtonePlayer::stop() {
  if (isPlaying()) {
  }
}

void RingtonePlayer::test(uint8_t speakerPin, uint8_t numScales) {
  if (numScales < 1) {
    numScales = 1;
  } else if (numScales > 5) {
    numScales = 5;
  }
    
  uint8_t i, j;

  for(i = 0; i < numScales; i++) {
    for(j = 0; j < NUM_FREQS; j++) {
      unsigned short t = (FREQ[j]*pow(2, i))/100;
      Serial.print("Playing ");
      Serial.print(t);
      Serial.println(" Hz for 1 second\n");
      tone(speakerPin, t, 1000);
      delay(1300);
    }
  }
}

