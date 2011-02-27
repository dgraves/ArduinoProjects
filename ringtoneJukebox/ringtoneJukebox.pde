#include <EEPROM.h>

/*
 Ringtone Jukebox
 
 Plays ringtones 
 
 circuit:
 * 8-ohm speaker on digital pin 8 with 100 Ohm resistor
 * Button on pin 0 for tune selection (select next) with 10K pulldown resistor
 * Button on pin 1 for tune selection (select previous) with 10K pulldown resistor
 * Button on pin 9 to play the tune (ProtoShield button with 10K pulldown resistor)
 * LED on pin 12 to blink tune (ProtoShield LED with 330 resistor)
 
 created 21 Feb 2011
 by Dustin Graves

 This code is in the public domain.
 
 http://www.dgraves.org

 */
#include <Bounce.h>
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

const unsigned int BAUD_RATE = 9600;

RingtonePlayer player;

void setup() {
  pinMode(PLAY_BUTTON_PIN, INPUT);
  pinMode(NEXT_BUTTON_PIN, INPUT);
  pinMode(PREV_BUTTON_PIN, INPUT);
  pinMode(SPEAKER_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  
  Serial.begin(BAUD_RATE);
  
  // Reset EEPROM address 0 to 0xFF; this will make it appear that no user
  // specified ringtone is present.  We do this because the EEPROM is not
  // cleared when new programs are uploaded, and the EEPROM may contain 
  // non-ringtone data.  To keep the user specified ringtone in memory
  // after program reset, comment this line.  
  EEPROM.write(0, 0xFF);

  player.selectRingtone(0);
//  RingtonePlayer::test(SPEAKER_PIN, 1);
}

const unsigned int DEBOUNCE_DELAY = 20;
Bounce playButton(PLAY_BUTTON_PIN, DEBOUNCE_DELAY);
Bounce nextButton(NEXT_BUTTON_PIN, DEBOUNCE_DELAY);
Bounce prevButton(PREV_BUTTON_PIN, DEBOUNCE_DELAY);

void loop() {
  handlePlayButton();
  handleNextButton();
  handlePrevButton();
}

void handlePlayButton() {
  if (playButton.update()) {
    if (playButton.read() == HIGH) {
      // Play the ringtone; restart if already playing
      if (player.isPlaying()) {
        player.stop();
      }

      Serial.print("Playing ringtone: ");
      Serial.println(player.ringtoneName());      
      player.play(SPEAKER_PIN);
    }
  }
}

void handleNextButton() {
  if (nextButton.update()) {
    if (nextButton.read() == HIGH) {
      if (player.isUserRingtoneSelected()) {
        player.selectRingtone(0);
      } else {
        unsigned int current = player.selectedRingtone() + 1;
        
        // If we have reached the end of the ringtones in the list we select
        // the user ringtone, if specified, or move to start of list
        if (current == player.numRingtones()) {
          if (player.hasUserRingtone()) {
            player.selectUserRingtone();
          } else {
            player.selectRingtone(0);
          }
        } else {
          player.selectRingtone(current);
        }
      }
    }
  }
}

void handlePrevButton() {
  if (prevButton.update()) {
    if (prevButton.read() == HIGH) {
      if (player.isUserRingtoneSelected()) {
        player.selectRingtone(player.numRingtones() - 1);
      } else {
        unsigned int current = player.selectedRingtone();
        if (current == 0) {
          if (player.hasUserRingtone()) {
            player.selectUserRingtone();
          } else {
            player.selectRingtone(player.numRingtones() - 1);
          }
        } else {
          player.selectRingtone(current - 1);
        }
      }
    }
  }
}

