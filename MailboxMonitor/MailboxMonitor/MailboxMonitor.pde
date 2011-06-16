/*
 MailboxMonitor

 Detects the presence of objects placed between an IR emitter and receiver. Requests
 received through the Serial device activate the detection process. The results are
 reported through the Serial device. Designed to be placed in a mailbox, to indicate
 that mail is present and needs to be retrieved.

 circuit:
 * IR receiver emitter on digital pin 3 for reading data
 * IR receiver emitter on digital pin 8, with 100K ohm resistor
 * IR transmitter anode on digital pin 9, with 100 ohm resistor
 * XBee DOUT on digital pin 0 (RX)
 * XBee DIN on digital pin 1 (TX)

 created 26 Apr 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
*/

const unsigned int BAUD_RATE = 19200;
const unsigned int DATA_PIN = 3;
const unsigned int RECEIVER_PIN = 8;
const unsigned int EMITTER_PIN = 9;

const unsigned int COMMAND_GETREADING = 0xEEEE;

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

// Read two byte command code from serial device
// Returns 0 on read failure failure, or 2 byte command code on read success
int readCode() {
  int code = Serial.read();
  
  // Check for second byte
  if (dataAvailable()) {
    code <<= 8;
    code |= (Serial.read() & 0x00FF);
    return code;
  }
  
  return 0;
}

void setup() {
  Serial.begin(BAUD_RATE);
  pinMode(DATA_PIN, INPUT);
  pinMode(RECEIVER_PIN, OUTPUT);
  pinMode(EMITTER_PIN, OUTPUT);
}

void loop() {
  if (Serial.available()) {
    int code = readCode();

    if (code == COMMAND_GETREADING) {
      digitalWrite(RECEIVER_PIN, 1);
      digitalWrite(EMITTER_PIN, 1);

      delay(200);

      int reading = analogRead(DATA_PIN);
      Serial.println(reading);

      digitalWrite(RECEIVER_PIN, 0);
      digitalWrite(EMITTER_PIN, 0);
    }
  }
}

