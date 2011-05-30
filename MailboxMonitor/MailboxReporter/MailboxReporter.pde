/*
 MailboxReporter

 Queries the MailboxMonitor device to determine if it has detected the presence
 of objects placed between the MailboxMonitor's  IR emitter and receiver. The
 presence of an object is reported visually.
 
 created 26 Apr 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
*/

import javax.swing.JOptionPane;
import processing.serial.*;

final int WIDTH = 200;
final int HEIGHT = 200;

final int LINE_FEED = 10;
final int BAUD_RATE = 19200;

// Port for communicating with Arduino
Serial arduinoPort;

// Interval between MailboxMonitor queries in seconds
int interval = 30;

void setup() {
  size(WIDTH, HEIGHT);

  arduinoPort = new Serial(this, "COM5", BAUD_RATE);
  arduinoPort.bufferUntil(LINE_FEED);
}

void serialEvent(Serial port) {
  if (port.available() > 0) {
    final String message = port.readStringUntil(LINE_FEED);
    print(message);
  }
}

void keyPressed() {
  if (key == 'p') {
    // Get a ringtone from the user
    String ringtone = JOptionPane.showInputDialog(this,
        "Paste a new ringtone into the text entry field below:",
        "RTTTL Entry",
        JOptionPane.PLAIN_MESSAGE);

    if (ringtone != null && !ringtone.isEmpty()) {
    }
  } else if (key == 'd') {
  }
}  
void draw() {
  background(0);
  arduinoPort.write(0xEE);
  arduinoPort.write(0xEE);
  delay(1000);
}

void selectSerialPort() {
}

void setIrDetectionThreshold() {
}

