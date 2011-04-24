/*
 Ringtone Visualizer

 For visualizing notes from ringtones played by the Arduino Ringtone
 Jukebox project.

 created 1 Mar 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
 */
import javax.swing.JOptionPane;
import processing.serial.*;
import processing.video.*;

final int WIDTH = 480;
final int HEIGHT = 480;
final int CENTER_X = WIDTH/2;
final int CENTER_Y = HEIGHT/2;
final int CIRCLE_DIAMETER = (HEIGHT / 3) - (int)(HEIGHT * 0.1);

final int VIDEO_FRAME_RATE = 30;

final int LINE_FEED = 10;
final int BAUD_RATE = 19200;
final int MAX_RINGTONE_LENGTH = 500;

// Command received from Arduino
final String COMMAND_NOTE = "note";
final String COMMAND_SELECT = "select";

// Indexes for color values
final int WHITE = 0;
final int RED = 1;
final int ORANGE = 2;
final int YELLOW = 3;
final int GREEN = 4;
final int BLUE = 5;
final int INDIGO = 6;
final int VIOLET = 7;

final int NUM_COLORS = 8;

// Color values: roygbiv values from http://www.lexipixel.com/graphics/roygbiv.htm
final int[] COLORS = { #FFFFFF /*white*/, #FF0000 /*red*/, #FFA500 /*orange*/,
                       #FFFF00 /*yellow*/, #008000 /*green*/, #0000FF /*blue*/,
                       #4B0082 /*indigo*/, #EE82EE /*violet*/};

// Map note ids used by ringtone player to names
// [0 -> pause, 1 -> C, 2 -> C# 3 -> D, 4 -> D#, 5-> E,
//  6 -> F, 7-> F#, 8-> G, 9 -> G#, 10 -> A, 11 -> A#, 12 -> B]
final String[] NOTE_NAMES = { "P", "C", "C#", "D", "D#", "E", "F",
                              "F#", "G", "G#", "A", "A#", "B" };

// Map note ids to colored circles, standard and sharp notes map to same circle
final int[] NOTE_CIRCLES = { 0, 1, 1, 2, 2, 3, 4, 4, 5, 5, 6, 6, 7 };

// Our blinking/fading lights
FadingCircle[] circles;
FadingText noteName;
FadingText toneName;

// Port for communicating with Arduino
Serial arduinoPort;

// Object for creating videos of the visualizer
MovieMaker movieMaker;

void setup() {
  size(WIDTH, HEIGHT);
  frameRate(VIDEO_FRAME_RATE);

  createCircles();
  for(FadingCircle circle: circles) {
    circle.on(500);
  }

  noteName = new FadingText(CENTER_X, CENTER_Y, CIRCLE_DIAMETER, #404040);
  noteName.setFadedValue(0.0);

  toneName = new FadingText(10, 10, CIRCLE_DIAMETER/5, #FFFFFF);
  toneName.setFadedValue(1.0/3.0);
  toneName.setAlignment(LEFT, TOP);

  movieMaker = null;
  
  arduinoPort = new Serial(this, Serial.list()[0], BAUD_RATE);
  arduinoPort.bufferUntil(LINE_FEED);

  println("\n\n\nWelcome to the Arduino ringtone visualizer!");
  println("Press the spacebar to send a custom ringtone to the Arduino.");
}

void serialEvent(Serial port) {
  if (port.available() > 0) {
    final String message = port.readStringUntil(LINE_FEED);
    print(message);

    String[] result = match(trim(message), "\\{(\\w+)((,\\w+)+)\\}");
    if (result != null) {
      final String command = result[1];
      final String[] parameters = splitTokens(result[2], ",");
      processCommand(command, parameters);
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    // Get a ringtone from the user
    String ringtone = JOptionPane.showInputDialog(this,
        "Paste a new ringtone into the text entry field below:",
        "RTTTL Entry",
        JOptionPane.PLAIN_MESSAGE);

    if (ringtone != null && !ringtone.isEmpty()) {
      ringtone = trim(ringtone);

      if (ringtone.length() > MAX_RINGTONE_LENGTH) {
        JOptionPane.showMessageDialog(this,
          "Ringtone is too long. Max ringtone length is" + MAX_RINGTONE_LENGTH + " characters.",
          "RTTTL length error",
          JOptionPane.ERROR_MESSAGE);
      } else {
        // Validate the ringtone pattern
        String[] result = match(ringtone,
          "s*\\w\\s*=\\s*\\d+\\s*(,\\s*\\w\\s*=\\s*\\d+\\s*)*:\\s*(\\w|#|\\.)+(\\s*,\\s*(\\w|#|\\.)+)");

        if (result == null) {
          String errorMessage = "Specified ringtone does not appear to be valid. For more information see:\n";
          String rtttlUrl = "http://en.wikipedia.org/wiki/Ring_Tone_Transfer_Language";
          JOptionPane.showMessageDialog(this,
            errorMessage + rtttlUrl,
            "RTTTL format error",
            JOptionPane.ERROR_MESSAGE);
        } else {
          String data = "RING:" + Integer.toString(ringtone.length()) + ":" + ringtone;

          print("Transmitting ringtone: ");
          println(data);

          // Send the data with "magic number" and size so the Arduino will recognize it
          arduinoPort.write(data);
        }
      }
    }
  } else if (key == '\n') {
    if (movieMaker == null) {
      // Start recording a video
      println("Video recording started.");
      movieMaker = new MovieMaker(this, WIDTH, HEIGHT, "ringtoneVisualizer.mov",
                                  VIDEO_FRAME_RATE, MovieMaker.JPEG, MovieMaker.LOSSLESS);
    } else {
      // Stop video recording
      movieMaker.finish();
      movieMaker = null;
      println("Video recording stopped.");
    }
  }
}

void initScreen() {
  background(0);
  noStroke();
}

void draw() {
  initScreen();

  noteName.draw();
  toneName.draw();

  for (FadingCircle circle: circles) {
    circle.draw();
  }

  if (movieMaker != null) {
    movieMaker.addFrame();
  }
}

void createCircles() {
  // Make the radius 1/3 of window height - 10% for padding
  int x = 0;
  int y = 0;

  final int degreeInc = 360 / NUM_COLORS;
  final int start = HEIGHT / 3;

  circles = new FadingCircle[NUM_COLORS];
  for (int i = 0; i < NUM_COLORS; ++i) {
    x = (int)(start * Math.sin(degreeInc * i * Math.PI / 180));
    y = (int)(start * Math.cos(degreeInc * i * Math.PI / 180));
    circles[i] = new FadingCircle(CENTER_X + x, CENTER_Y + y, CIRCLE_DIAMETER, COLORS[i]);
  }
}

void processCommand(final String command, final String[] parameters) {
  if (command.equals(COMMAND_NOTE)) {
    // Must have 3 parameters
    if (parameters.length == 3) {
      int id = Integer.parseInt(parameters[0]);

      // Turn the circle on
      int duration = Integer.parseInt(parameters[2]);
      int circle = NOTE_CIRCLES[id];

      // Start fading halfway through note duration
      circles[circle].on(duration/2);

      // Continue fading after duration expires, for one half the time of
      // the total duration
      circles[circle].setFadeDuration(duration*2);

      // Draw the note name
      noteName.setMessage(NOTE_NAMES[id]);
      noteName.on(duration);
      noteName.setFadeDuration(duration);
    }
  } else if (command.equals(COMMAND_SELECT)) {
    if (parameters.length == 1) {
      toneName.setMessage(parameters[0]);
      toneName.on(1000);
    }
  }
}

