#include <WProgram.h>
#include <pins_arduino.h>
#include "RingtonePlayer.h"

// Frequencies for 4th octave
// Octaves 5, 6, and 7 are computed from these values
static const uint16_t FREQ[13] = {
  0,
  262,      // Frequencies for four octaves for C
  277,      // Frequencies for four octaves for C# / Db
  294,      // Frequencies for four octaves for D
  311,      // Frequencies for four octaves for D# / Eb
  330,      // Frequencies for four octaves for E / Fb 
  349,      // Frequencies for four octaves for F / E#
  370,      // Frequencies for four octaves for F# / Gb
  392,      // Frequencies for four octaves for G
  415,      // Frequencies for four octaves for G# / Ab
  440,      // Frequencies for four octaves for A * 100
  466,      // Frequencies for four octaves for A# / Bb * 100
  494,      // Frequencies for four octaves for B / Cb
};

const uint8_t NUM_FREQS = 13;
const uint8_t BASE_FREQ_SCALE = 4;

// Note indexes to frequency table
const uint8_t P    = 0;               // Pause
const uint8_t C    = 1;               // C
const uint8_t CSF  = 2;               // C# / Db
const uint8_t D    = 3;               // D
const uint8_t DSF  = 4;               // D# / Eb
const uint8_t E    = 5;               // E  / Fb
const uint8_t F    = 6;               // F  / E#
const uint8_t FSF  = 7;               // F# / Gb
const uint8_t G    = 8;               // G
const uint8_t GSF  = 9;               // G# / Ab
const uint8_t A    = 10;              // A
const uint8_t ASF  = 11;              // A# / Bb
const uint8_t H    = 12;              // B  / Cb

// Current position in the ringtone command data string
volatile uint16_t currentPos = 0xFFFF;

// Max string length for a RTTL tone command segment
const uint8_t MAX_TONE_COMMAND_LEN = 6;

// Timer setup for tone generation.  This code is based on the Arduino tone() implementation,
// and has been modified to play a series of tones, instead of a single tone.
volatile uint32_t timerToggleCount;
volatile bool timerPause;
volatile uint8_t *timerPinPort;
volatile uint8_t timerPinMask;
volatile uint8_t timerPin = 8;
volatile PlayNoteCallback playNoteCallback = NULL;

static void timerSetup(uint8_t pin) {
  TCCR2A = 0;
  TCCR2B = 0;
  bitWrite(TCCR2A, WGM21, 1);
  bitWrite(TCCR2B, CS20, 1);
  timerPin = pin;
  timerPinPort = portOutputRegister(digitalPinToPort(pin));
  timerPinMask = digitalPinToBitMask(pin);
}

static bool timerStart(uint16_t frequency, uint32_t duration) {
  // Set the pinMode as OUTPUT
  pinMode(timerPin, OUTPUT);

  // Handle pause with timer
  if (frequency == 0) {
    frequency = 1000;     // 1 millisecond; timer will count duration for a pause
    timerPause = true;
  } else {
    timerPause = false;
  }

  uint32_t ocr = F_CPU / frequency / 2 - 1;
  uint8_t prescalarbits = 0b001;

  // Determine scale value
  if (ocr > 255) {
    ocr = F_CPU / frequency / 2 / 8 - 1;
    prescalarbits = 0b010;

    if (ocr > 255) {
      ocr = F_CPU / frequency / 2 / 32 - 1;  // Timer 2 only
      prescalarbits = 0b011;

      if (ocr > 255) {
        ocr = F_CPU / frequency / 2 / 64 - 1;
        prescalarbits = 0b100;

        if (ocr > 255) {
          ocr = F_CPU / frequency / 2 / 128 - 1;  // Timer 2 only
          prescalarbits = 0b101;

          if (ocr > 255) {
            ocr = F_CPU / frequency / 2 / 256 - 1;
            prescalarbits = 0b110;

            if (ocr > 255) {
              ocr = F_CPU / frequency / 2 / 1024 - 1;
              prescalarbits = 0b111;
            }
          }
        }
      }
    }
  }

  timerToggleCount = 2 * frequency * duration / 1000;

  TCCR2B = prescalarbits;
  OCR2A = ocr;
  bitWrite(TIMSK2, OCIE2A, 1);
}

static void timerStop() {
  TIMSK2 &= ~(1 << OCIE2A);
  digitalWrite(timerPin, 0);
}

static bool timerActive() {
  return (TIMSK2 & (1 << OCIE2A));
}

static uint16_t skipWhiteSpace(const Ringtone& ringtone, uint16_t pos, uint16_t len) {
  while(pos < len) {
    if(!isspace(ringtone.value(pos))) {
      break;
    }
    ++pos;
  }
  return pos;
}

// Retrieve next note from ringtone player
static bool nextNote(Note* next) {
  const Ringtone& ringtone = RingtonePlayer.ringtone();
  if (currentPos < ringtone.length()) {
    // Get the segment
    char segment[MAX_TONE_COMMAND_LEN+1] = {0};  // Max num characters in a segment is 6
    uint8_t count = 0;
    char c = ringtone.value(currentPos);;
    while (c != ',') {
      if (!isspace(c)) {
        if (count == MAX_TONE_COMMAND_LEN) {
          // Invalid ringtone
          currentPos = 0xFFFF;
          return false;
        }

        segment[count++] = c;
      }

      if (++currentPos == ringtone.length()) {
        // We hit the end
        break;
      } else {
        c = ringtone.value(currentPos);;
      }
    }

    // Skip the ','
    if (c == ',') {
      if (++currentPos == ringtone.length()) {
        // Dangling comma
        currentPos = 0xFFFF;
        return false;
      }
    }

    // Process the captured data
    bool dotted = false;
    uint8_t duration = ringtone.duration();  // Default duration
    uint8_t scale = ringtone.scale();        // Default scale
    uint8_t note;

    count = 0;
    // Check for optional duration
    if (isdigit(segment[count])) {
      duration = segment[count++] - '0';

      // Check for two digit number
      if (isdigit(segment[count])) {
        duration *= 10;
        duration += segment[count++] - '0';
      }
    }

    // Should now be on a letter
    if (!isalpha(segment[count])) {
      // Invalid ringtone
      currentPos = 0xFFFF;
      return false;
    }

    // Get the note
    switch(tolower(segment[count])) {
    case 'a':
      if (segment[count + 1] == '#') {
        note = ASF;
        ++count;
      } else {
        note = A;
      }
      break;
    case 'b':
    case 'h':
      note = H;
      break;
    case 'c':
      if (segment[count + 1] == '#') {
        note = CSF;
        ++count;
      } else {
        note = C;
      }
      break;
    case 'd':
      if (segment[count + 1] == '#') {
        note = DSF;
        ++count;
      } else {
        note = D;
      }
      break;
    case 'e':
      note = E;
      break;
    case 'f':
      if (segment[count + 1] == '#') {
        note = FSF;
        ++count;
      } else {
        note = F;
      }
      break;
    case 'g':
      if (segment[count + 1] == '#') {
        note = GSF;
        ++count;
      } else {
        note = G;
      }
      break;
    case 'p':
      note = P;
      break;
    default:
      // Invalid note value
      currentPos = 0xFFFF;
      return false;
    }

    // Docs say '.' comes last, but some ringtones have it before scale so we check both
    ++count;
    if (segment[count] == '.') {
      dotted = true;
      if (isdigit(segment[++count])) {
        scale = segment[count++] - '0';
      }
    } else if (isdigit(segment[count])) {
      scale = segment[count] - '0';
      if (segment[++count] == '.') {
        dotted = true;
        ++count;
      }
    }

    // We should now be at the null terminator
    if (segment[count] != '\0') {
      currentPos = 0xFFFF;
      return false;
    }

    // Valid durations are 1, 2, 4, 8, 16, 32
    if (duration != 1 && duration != 2 && duration != 4 &&
        duration != 8 && duration != 16 && duration != 32) {
      currentPos = 0xFFFF;
      return false;
    }

    // Valid scales are 4, 5, 6, 7
    if (scale != 4 && scale != 5 && scale != 6 && scale != 7) {
      currentPos = 0xFFFF;
      return false;
    }

    // Compute the frequency
    // Scales are: A4 = 440Hz, A5 = 880Hz, A6 = 1.76kHz, A7 = 3.52kHz
    // Our freq table starts with A = 220Hz, so we multiply by the appropriate
    // power of 2 (A4 -> 1, A5 -> 2, A6 -> 4, A7 -> 8
    uint16_t frequency = ((uint32_t)FREQ[note]) * (1 << (scale - BASE_FREQ_SCALE));
    next->setFrequency(frequency);

    // Get number of milliseconds per note
    // (1 minute * (60000 milliseconds/minute)) / (tempo beats * (1 note/ 4 beats))
    uint32_t ms = (60000 / ringtone.bpm()) * 4;

    // Now compute the note information
    next->setDuration(ms / duration);
    if (dotted) {
      next->setDuration(next->duration() * 1.5);
    }

    // Set note id
    next->setId(note);

#ifdef DEBUG
    Serial.print("Note: ");
    Serial.println((uint16_t)note);
    Serial.print("Note duration: ");
    Serial.println((uint16_t)duration);
    Serial.print("Note dotted: ");
    Serial.println(dotted);
    Serial.print("Note scale: ");
    Serial.println((uint16_t)scale);
    Serial.print("Tone frequency: ");
    Serial.println(next->frequency());
    Serial.print("Tone duration: ");
    Serial.println(next->duration());
#endif

    return true;
  }

  // No more notes to play
  return false;
}

// Extract the next note and start playing it
static bool playNextNote() {
  Note next;
  if (nextNote(&next)) {
    if (playNoteCallback) {
      playNoteCallback(next);
    }
    timerStart(next.frequency(), next.duration());
    return true;
  }

#ifdef DEBUG
  Serial.println("Ringtone: No more notes");
#endif

  // Signal that playing stopped
  next.setId(0xFF);
  playNoteCallback(next);

  return false;
}

ISR(TIMER2_COMPA_vect)
{
  if (timerToggleCount > 0)
  {
    if (timerPause) {
      *timerPinPort &= ~timerPinMask;
    } else {
      *timerPinPort ^= timerPinMask;
    }

    timerToggleCount--;
  }
  else
  {
    timerStop();
    playNextNote();
  }
}

RingtonePlayerClass::RingtonePlayerClass() {
}

RingtonePlayerClass::~RingtonePlayerClass() {
  stop();
}

void RingtonePlayerClass::begin(uint8_t pin) {
  stop();
  timerSetup(pin);
}

bool RingtonePlayerClass::isPlaying() const {
  return timerActive();
}

void RingtonePlayerClass::play() {
  if (!isPlaying()) {
    currentPos = 0;
    playNextNote();
  }
}

void RingtonePlayerClass::stop() {
  if (isPlaying()) {
    timerStop();
  }
}

void RingtonePlayerClass::setPlayNoteCallback(PlayNoteCallback callback) {
  playNoteCallback = callback;
}

// Number of built-in ringtones.
uint16_t RingtonePlayerClass::numRingtones() const {
  return _ringtone.total();
}

// Currently selected ringtone.
uint16_t RingtonePlayerClass::selectedRingtone() const {
  return _ringtone.selected();
}

// Select one of the built-in ringtones
void RingtonePlayerClass::selectRingtone(uint16_t index) {
  _ringtone.select(index);
}
  
// Determine if user specified ring tone is selected.
bool RingtonePlayerClass::isUserRingtoneSelected() const {
  return _ringtone.isUserSelected();
}

// Check for presence of a user specified ringtone in EEPROM.
bool RingtonePlayerClass::hasUserRingtone() const {
  return _ringtone.hasUser();
}
  
// Set the current ringtone to the ringtone stored in EEPROM.
void RingtonePlayerClass::selectUserRingtone() {
  _ringtone.selectUser();
}

const String& RingtonePlayerClass::ringtoneName() const {
  return _ringtone.name();
}

const Ringtone& RingtonePlayerClass::ringtone() const {
  return _ringtone;
}

RingtonePlayerClass RingtonePlayer;

