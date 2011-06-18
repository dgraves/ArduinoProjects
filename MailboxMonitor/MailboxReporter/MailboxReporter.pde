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

final int STATUS_FONT_SIZE = 12;
final int ANNOUNCE_FONT_SIZE = 60;
final int PAD_X = 10;
final int PAD_Y = 10;

// Parameters for email notification
final String SMTP_HOST = "smtp.example.com";
final int SMTP_PORT = 25;
final String FROM_ADDRESS = "me@example.com";
final SmtpNotification SMTP_NOTIFIER = new SmtpNotification(SMTP_HOST, SMTP_PORT);

// Threshold value to indicate an object has been placed
// between IR transmitter and receiver.  This is compared
// with the value read from the IR receiver to determine if
// an object is palced between the transmitter and receiver.
// More light reaching the receiver will result in a smaller
// value.  Ideally, a reading of 0 should indicate no
// object is between the receiver and transmitter, and a
// non-zero value would indicate that an object is present.
final int IR_DETECTION_THRESHOLD = 100;

// Email address to receive alerts
String emailAddress = "";

// Port for communicating with Arduino
Serial arduinoPort;

// Interval between MailboxMonitor queries in seconds
long interval = 5000;

// Time of last report from MailboxMonitor
Date lastReportTime = new Date(0);

// Value last reported by MailboxMonitor
int lastReportedValue = -1;

// Last query time
long lastQueryTime = 0;

// Is mail currently present?
boolean haveMail = false;

void setup() {
  size(WIDTH, HEIGHT);
  selectSerialPort(Serial.list()[0]);

  println("\n\n\nWelcome to the Mailbox Reporter!");
  println("Press the 's' key to select the serial port (currently using " + Serial.list()[0] + ").");
  println("Press the 'i' key to select the Mailbox Monitor query interval (currently set to " + interval/1000 + " seconds).");
  println("Press the 'e' key to specify an email address that will receive notifications when mail is available.");
}

void draw() {
  background(0);

  // Display info text
  textAlign(LEFT, BASELINE);
  textSize(STATUS_FONT_SIZE);
  fill(#FFFFFF);
  
  // Line count for positioning each line
  int count = 0;
  
  text("Last report date: " + DateFormat.getDateInstance().format(lastReportTime), PAD_X, height - (PAD_Y + (STATUS_FONT_SIZE * count++)));
  text("Last report time: " + DateFormat.getTimeInstance().format(lastReportTime), PAD_X, height - (PAD_Y + (STATUS_FONT_SIZE * count++)));
  text("Last reading: " + lastReportedValue, PAD_X, height - (PAD_Y + (STATUS_FONT_SIZE * count++)));

  // Draw status message
  textAlign(CENTER, BASELINE);
  textSize(ANNOUNCE_FONT_SIZE);
  if (haveMail) {
    fill(#00FF00);
    text("You", width/2, (height - (ANNOUNCE_FONT_SIZE+ANNOUNCE_FONT_SIZE/2))/2);
    text("have", width/2, height/2);
    text("mail", width/2, (height + (ANNOUNCE_FONT_SIZE+ANNOUNCE_FONT_SIZE/2))/2);
  } else {
    fill(#FF0000);
    text("No", width/2, (height - ANNOUNCE_FONT_SIZE)/2);
    text("mail", width/2, (height + ANNOUNCE_FONT_SIZE)/2);
  }

  // Request reading from Mailbox Monitor
  long now = System.currentTimeMillis();
  if ( now - lastQueryTime > interval) {
    sendQuery();
    lastQueryTime = now;
  }
}

void selectSerialPort(String port) {
  arduinoPort = new Serial(this, port, BAUD_RATE);
  arduinoPort.bufferUntil(LINE_FEED);

  // Get an update immediately
  sendQuery();
}

void sendQuery() {
///  println("Sending query");
  arduinoPort.write(0xEE);
  arduinoPort.write(0xEE);
}

void serialEvent(Serial port) {
  if (port.available() > 0) {
    final String message = port.readStringUntil(LINE_FEED);

    lastReportTime.setTime(System.currentTimeMillis());
    lastReportedValue = Integer.parseInt(trim(message));
    
    // Check for state change
    if (lastReportedValue > IR_DETECTION_THRESHOLD) {
      // An object is present
      if (!haveMail) {
        haveMail = true;
        if (!emailAddress.isEmpty()) {
          SMTP_NOTIFIER.send(FROM_ADDRESS, emailAddress, "You have new mail", "You have new mail waiting to be picked up!");
        }
      }
    } else {
      // No mail is present
      if (haveMail) {
        haveMail = false;
        if (!emailAddress.isEmpty()) {
          SMTP_NOTIFIER.send(FROM_ADDRESS, emailAddress, "Mail retrieved", "Your mail has been picked up!");
        }
      }
    }
  }
}

void keyReleased() {
  if (key == 's') {
    String port = (String)JOptionPane.showInputDialog(this,
        "Select the serial device:",
        "Serial Device",
        JOptionPane.PLAIN_MESSAGE,
        null,
        Serial.list(),
        Serial.list()[0]);

    if (port != null) {
      selectSerialPort(port);
    }
  } else if (key == 'i') {
    String seconds = JOptionPane.showInputDialog(this,
        "Specify the Mailbox Monitor query interval (seconds):",
        "Query Interval Entry",
        JOptionPane.PLAIN_MESSAGE);

    if (seconds != null && !seconds.isEmpty()) {
      int newInterval = Integer.parseInt(seconds, 10);
      if (newInterval > 0) {
        interval = newInterval * 1000;
        println("Set query interval to " + newInterval + " seconds");
      }
    }
  } else if (key == 'e') {
    String newAddress = JOptionPane.showInputDialog(this,
        "Paste a new ringtone into the text entry field below:",
        "Email Address Entry",
        JOptionPane.PLAIN_MESSAGE);

    if (newAddress != null) {
      if (!newAddress.isEmpty()) {
        // Check for validly formed email address
        String[] matches = match(trim(newAddress), "\\w+@(\\w+\\.)+\\w+");
        if (matches != null) {
          emailAddress = matches[0];
          println("Set email address to " + emailAddress);
        }
      } else {
        // Clear the address
        emailAddress = "";
      }
    }
  }
}  

