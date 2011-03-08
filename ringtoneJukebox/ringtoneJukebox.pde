/*
 Ringtone Jukebox

 Plays ringtones

 circuit:
 * Button on pin 5 to play the tune (ProtoShield button with 10K pulldown resistor)
 * Button on pin 6 for tune selection (select next) with 10K pulldown resistor
 * Button on pin 7 for tune selection (select previous) with 10K pulldown resistor
 * 8-ohm speaker on digital pin 8 with 100 Ohm resistor
 * LED on pin 12 to blink tune (ProtoShield LED with 330 Ohm resistor)

 created 21 Feb 2011
 by Dustin Graves

 This code is in the public domain.

 http://www.dgraves.org
 */
#include <Bounce.h>
#include <EEPROM.h>
#include "RingtonePlayer.h"

/* Label pins with a name describing the associated function.
 * Simply change the pin number if you wish to use a different
 * pin to perform a function.
 */
const unsigned int PLAY_BUTTON_PIN = 5;
const unsigned int NEXT_BUTTON_PIN = 6;
const unsigned int PREV_BUTTON_PIN = 7;
const unsigned int SPEAKER_PIN     = 8;
const unsigned int LED_PIN         = 12;

const unsigned int BAUD_RATE = 19200;
const unsigned int MAX_RINGTONE_LENGTH = 500;

void setup() {
  pinMode(PLAY_BUTTON_PIN, INPUT);
  pinMode(NEXT_BUTTON_PIN, INPUT);
  pinMode(PREV_BUTTON_PIN, INPUT);
  pinMode(SPEAKER_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);

  Serial.begin(BAUD_RATE);

  RingtonePlayer.begin(SPEAKER_PIN);
  RingtonePlayer.setPlayNoteCallback(playNoteCallback);
  RingtonePlayer.selectRingtone(0);
  sendStateChange("Select", RingtonePlayer.ringtoneName());
}

const unsigned int DEBOUNCE_DELAY = 20;
Bounce playButton(PLAY_BUTTON_PIN, DEBOUNCE_DELAY);
Bounce nextButton(NEXT_BUTTON_PIN, DEBOUNCE_DELAY);
Bounce prevButton(PREV_BUTTON_PIN, DEBOUNCE_DELAY);

void loop() {
  if (Serial.available()) {
    readRingtone();
  }

  handlePlayButton();
  handleNextButton();
  handlePrevButton();

  // Make the LED pulse with the music
  digitalWrite(LED_PIN, digitalRead(SPEAKER_PIN));
}

// Wait for data to become available for 60 milliseconds before giving up
bool dataAvailable() {
  uint8_t count = 60;
  while (!Serial.available()) {
    delay(1);
    if (--count == 0) {
      return false;
    }
  }
  return true;
}

// Recieve ringtone data from PC. Ringtone data should be formatted as:
// RING:<size>:<data>
// Where 'RING' is the "magic number" identifying the data as a ringtone,
// 'size' is the length of the data, and 'data' is the actual ringtone data
void readRingtone() {
  if (readMagicNumber()) {
    unsigned int length = readLength();
    if (length > 0 && length <= MAX_RINGTONE_LENGTH) {
      char data[MAX_RINGTONE_LENGTH];
      const unsigned int offset = 6;
      unsigned int count = offset;
      length += offset;
      while (dataAvailable() && count < length) {
        data[count - offset] = Serial.read();
        ++count;
      }

      // Make sure all data was received
      if (count == length) {
        // Write magic number and size
        EEPROM.write(0, 'R');
        EEPROM.write(1, 'I');
        EEPROM.write(2, 'N');
        EEPROM.write(3, 'G');
        EEPROM.write(4, (length >> 8) & 0xFF);
        EEPROM.write(5, length & 0xFF);

        for (int i = offset; i < length; ++i) {
          EEPROM.write(i, data[i - offset]);
        }

        // Select the new ringtone
        RingtonePlayer.selectUserRingtone();
        sendStateChange("Select", RingtonePlayer.ringtoneName());
      }
    }
  }
}

// Read the magic number segment. Four characters, RING, followed by ':'
bool readMagicNumber() {
  const uint8_t MAX = 5;
  uint8_t count = 0;
  const char magic[MAX] = { 'R', 'I', 'N', 'G', ':' };

  while (dataAvailable() && count < MAX) {
    char next = Serial.read();
    if (next != magic[count++]) {
      break;
    }
  }

  return (count < MAX) ? false : true;
}

// Read the length of the data. Sequence of digits followed by ':'
uint16_t readLength() {
  // Read until the ':' segment terminator is received
  // Count should not exceed 6 (5 for max uint16 value and 1 for ':')
  const uint8_t MAX = 6;
  uint8_t count = 0;
  uint16_t length = 0;

  while (dataAvailable() && count < MAX) {
    char next = Serial.read();

    if (isdigit(next)) {
      length *= 10;
      length += next - '0';
    } else if (next == ':') {
      return length;
    } else {
      return 0;     // Read an unexpected value
    }
  }

  return 0;         // Too many digits before ':'
}

void handlePlayButton() {
  if (playButton.update()) {
    if (playButton.read() == HIGH) {
      // Play the ringtone; restart if already playing
      if (RingtonePlayer.isPlaying()) {
        sendStateChange("Stop", RingtonePlayer.ringtoneName());
        RingtonePlayer.stop();
      } else {
        sendStateChange("Play", RingtonePlayer.ringtoneName());
        RingtonePlayer.play();
      }
    }
  }
}

void handleNextButton() {
  if (nextButton.update()) {
    if (nextButton.read() == HIGH) {
      bool play = false;
      if (RingtonePlayer.isPlaying()) {
        play = true;
        RingtonePlayer.stop();
      }

      if (RingtonePlayer.isUserRingtoneSelected()) {
        RingtonePlayer.selectRingtone(0);
      } else {
        unsigned int current = RingtonePlayer.selectedRingtone() + 1;

        // If we have reached the end of the ringtones in the list we select
        // the user ringtone, if specified, or move to start of list
        if (current == RingtonePlayer.numRingtones()) {
          if (RingtonePlayer.hasUserRingtone()) {
            RingtonePlayer.selectUserRingtone();
          } else {
            RingtonePlayer.selectRingtone(0);
          }
        } else {
          RingtonePlayer.selectRingtone(current);
        }
      }

      sendStateChange("Select", RingtonePlayer.ringtoneName());

      if (play) {
        RingtonePlayer.play();
      }
    }
  }
}

void handlePrevButton() {
  if (prevButton.update()) {
    if (prevButton.read() == HIGH) {
      bool play = false;
      if (RingtonePlayer.isPlaying()) {
        play = true;
        RingtonePlayer.stop();
      }

      if (RingtonePlayer.isUserRingtoneSelected()) {
        RingtonePlayer.selectRingtone(RingtonePlayer.numRingtones() - 1);
      } else {
        unsigned int current = RingtonePlayer.selectedRingtone();
        if (current == 0) {
          if (RingtonePlayer.hasUserRingtone()) {
            RingtonePlayer.selectUserRingtone();
          } else {
            RingtonePlayer.selectRingtone(RingtonePlayer.numRingtones() - 1);
          }
        } else {
          RingtonePlayer.selectRingtone(current - 1);
        }
      }

      sendStateChange("Select", RingtonePlayer.ringtoneName());

      if (play) {
        RingtonePlayer.play();
      }
    }
  }
}

void playNoteCallback(const Note& note) {
  if (note.id() != 0xFF) {
    Serial.print("{");
    Serial.print("Note");
    Serial.print(",");
    Serial.print((int)note.id());
    Serial.print(",");
    Serial.print(note.frequency());
    Serial.print(",");
    Serial.print(note.duration());
    Serial.println("}");
  } else {
    sendStateChange("Stop", RingtonePlayer.ringtoneName());
  }
}

// Send a state change indicator to the display software
// Formatted as {<action>, <value>}
void sendStateChange(const String& action, const String& value) {
  Serial.print("{");
  Serial.print(action);
  Serial.print(",");
  Serial.print(value);
  Serial.println("}");
}

