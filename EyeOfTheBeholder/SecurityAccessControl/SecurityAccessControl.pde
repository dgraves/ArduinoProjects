/*
 Eye of the Beholder - Security Access Control

 created 25 Jun 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
*/
#include <NewSoftSerial.h>
#include <MsTimer2.h>
#include "RfidSerial.h"
#include "PirSensor.h"

// Rate for communication with security control system
#define BAUD_RATE 19200

// Pins for sensors
#define RFID_ENABLE_PIN 5
#define RFID_SOUT_PIN   6
#define PIR_PIN         7

// Pins for user feedback
#define BUZZER_PIN 10
#define ACCEPT_PIN 11
#define REJECT_PIN 12

// Number of milliseconds to keep reader acitve after motion is detected
#define ACTIVE_DURATION (5 * 1000)

// Codes received from security control system
#define ID_ACCEPTED 0xAA
#define ID_REJECTED 0xFF

// External sensors
RfidSerial rfid(RFID_SOUT_PIN, RFID_ENABLE_PIN);
PirSensor pir(PIR_PIN);

// Reader state
bool active = false;
String lastId = "";

// Function to be called my timer 2 interrupt service routine
void deactivate_isr() {
  MsTimer2::stop();
  rfid.disable();
  lastId = "";
  active = false;
}

void setup() {
  Serial.begin(BAUD_RATE);
  MsTimer2::set(ACTIVE_DURATION, deactivate_isr);
  
  // Setup feedback pins
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(ACCEPT_PIN, OUTPUT);
  pinMode(REJECT_PIN, OUTPUT);
}

void loop() {
  if (Serial.available()) {
    byte code = readCode();
  }
  
  if (active) {
    // If reader is active, check for a value
    String id;
    if (rfid.available(&id)) {
      // Only send same ID once per active session
      if (id != lastId) {
        sendId(id);
        lastId = id;
      }
    }
  } else {
    // If not currently active, check for motion and activate
    if (pir.detected()) {
      // Activate for specified duration
      active = true;
      rfid.enable();
      MsTimer2::start();
    }
  }
}

// Wait for data to become available for 60 milliseconds before giving up
bool dataAvailable() {
  byte count = 60;
  while (!Serial.available()) {
    delay(1);
    if (--count == 0) {
      return false;
    }
  }
  return true;
}

// Read two byte command code from serial device
// Returns 0 on read failure failure, or 2 byte command code on read success
byte readCode() {
  // Sync on 0xEE
  if (Serial.read() == 0xEE) {
    // Check for second byte
    if (dataAvailable()) {
      return Serial.read();
    }
  }
  
  return 0;
}

void sendId(const String &id) {
  Serial.print("{id,"); Serial.print(id); Serial.println("}");
}

