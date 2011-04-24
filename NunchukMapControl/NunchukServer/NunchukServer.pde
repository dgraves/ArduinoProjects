/*
Nunchuk Server

For reading Nunchuk state data from the Arduino and
making it available through RESTful HTTP requests.

created 10 Apr 2011
by Dustin Graves

This code is licensed with the MIT License.

http://www.dgraves.org
*/

import com.sun.net.httpserver.*;
import processing.serial.*;

final int WIDTH = 480;
final int HEIGHT = 480;
final int FRAME_RATE = 20;

final int LINE_FEED = 10;
final int BAUD_RATE = 19200;
final int SERVER_PORT = 8049;

final int FONT_SIZE = 12;

// Samples for smoothing acceleration with NunchukStateBuffer
final int MAX_SAMPLES = 16;

// Types for records received from Arduino
final String RECORD_UPDATE = "update";

// RESTful URLs
final String RAW_URL = "/nunchuk/state/raw";
final String PROCESSED_URL = "/nunchuk/state/processed";

// String storing information for last page served
String lastPage;

// HTTP server to provide Nunchuk state data to clients
HttpServer httpServer;

// Last Nunchuk state update received from Arduino
NunchukState nunchukState;

// Normalizes Nunchuk state data for easy use with map controls
NunchukStateProcessor nunchukStateProcessor;

// Port for communicating with the Arduino
Serial arduinoPort;

void setup() {
  size(WIDTH, HEIGHT);
  frameRate(FRAME_RATE);

  nunchukState = new NunchukState(MAX_SAMPLES);
  nunchukStateProcessor = new NunchukStateProcessor();
  
  lastPage = "(No HTTP requests processed)";
  setupHttpServer();
  
  arduinoPort = new Serial(this, Serial.list()[0], BAUD_RATE);
  arduinoPort.bufferUntil(LINE_FEED);
}

void serialEvent(Serial port) {
  if (port.available() > 0) {
    final String message = port.readStringUntil(LINE_FEED);
//    print(message);

    String[] result = match(trim(message), "\\{(\\w+)((,\\w+)+)\\}");
    if (result != null) {
      final String command = result[1];
      final String[] parameters = splitTokens(result[2], ",");
      processCommand(command, parameters);
    }
  }
}

void keyPressed() {
  // Calibrate the nunchuk
  if (key == 'c' || key == 'C') {
    nunchukStateProcessor.calibrate(nunchukState);
  } else if (key == ' ') {
    // Clear the latched value
    nunchukStateProcessor.latchedAccelerationZ();
  }
}

void draw() {
  background(0);

  // Display status text
  textAlign(LEFT, BASELINE);
  textSize(FONT_SIZE);
  fill(#FFFFFF);

  // Line count for positioning each line
  int count = 1;

  // Server data
  text("HTTP Server Status", 10, 10 + (FONT_SIZE * count++));
  text("  URL: http://localhost:" + SERVER_PORT, 10, 10 + (FONT_SIZE * count++));
  text("  Last Activity: " + lastPage, 10, 10 + (FONT_SIZE * count++));
    
  // Raw state data
  count++;
  text("Nunchuk Raw Data", 10, 10 + (FONT_SIZE * count++));
  text("  Joystick X: " + nunchukState.joystickX(), 10, 10 + (FONT_SIZE * count++));
  text("  Joystick Y: " + nunchukState.joystickY(), 10, 10 + (FONT_SIZE * count++));
  text("  Acceleration X: " + nunchukState.accelerationX(), 10, 10 + (FONT_SIZE * count++));
  text("  Acceleration Y: " + nunchukState.accelerationY(), 10, 10 + (FONT_SIZE * count++));
  text("  Acceleration Z: " + nunchukState.accelerationZ(), 10, 10 + (FONT_SIZE * count++));
  text("  Button C: " + (nunchukState.isButtonCDown() ? "Down" : "Up"), 10, 10 + (FONT_SIZE * count++));
  text("  Button Z: " + (nunchukState.isButtonZDown() ? "Down" : "Up"), 10, 10 + (FONT_SIZE * count++));
 
  // Processed state data
  count++;
  text("Nunchuk Processed Data", 10, 10 + (FONT_SIZE * count++));
  text("  Joystick X: " + nunchukStateProcessor.joystickX(), 10, 10 + (FONT_SIZE * count++));
  text("  Joystick Y: " + nunchukStateProcessor.joystickY(), 10, 10 + (FONT_SIZE * count++));
  text("  Rotation: " + nunchukStateProcessor.accelerationX(), 10, 10 + (FONT_SIZE * count++));
  text("  Tilt: " + nunchukStateProcessor.accelerationY(), 10, 10 + (FONT_SIZE * count++));
  text("  Reset: " + nunchukStateProcessor.accelerationZ(), 10, 10 + (FONT_SIZE * count++));
  text("  Button C: " + (nunchukStateProcessor.isButtonCDown() ? "Down" : "Up"), 10, 10 + (FONT_SIZE * count++));
  text("  Button Z: " + (nunchukStateProcessor.isButtonZDown() ? "Down" : "Up"), 10, 10 + (FONT_SIZE * count++));

  // Calibration data values
  count++;
  text("Calibration Values", 10, 10 + (FONT_SIZE * count++));
  text("  Joystick X: " + nunchukStateProcessor.calibratedJoystickX(), 10, 10 + (FONT_SIZE * count++));
  text("  Joystick Y: " + nunchukStateProcessor.calibratedJoystickY(), 10, 10 + (FONT_SIZE * count++));
  text("  Acceleration X: " + nunchukStateProcessor.calibratedAccelerationX(), 10, 10 + (FONT_SIZE * count++));
  text("  Acceleration Y: " + nunchukStateProcessor.calibratedAccelerationY(), 10, 10 + (FONT_SIZE * count++));
  text("  Acceleration Z: " + nunchukStateProcessor.calibratedAccelerationZ(), 10, 10 + (FONT_SIZE * count++));
}

void setupHttpServer() {
  try {
    httpServer = HttpServer.create(new InetSocketAddress(SERVER_PORT), 8);

    // Create context to handle requests for raw nunchuk state data request
    httpServer.createContext(RAW_URL, new HttpHandler() {
      public void handle(HttpExchange ex) throws IOException {
        String response = nunchukRawState();
        ex.sendResponseHeaders(200, response.length());
        OutputStream os = ex.getResponseBody();
        os.write(response.getBytes());
        setLastPageRequested(RAW_URL, ex.getRemoteAddress().toString());
        os.close();
      }
    });

    // Create context to handle requests for processed nunchuk state data request
    httpServer.createContext(PROCESSED_URL, new HttpHandler() {
      public void handle(HttpExchange ex) throws IOException {
        String response = nunchukProcessedState();
        ex.sendResponseHeaders(200, response.length());
        OutputStream os = ex.getResponseBody();
        os.write(response.getBytes());
        setLastPageRequested(PROCESSED_URL, ex.getRemoteAddress().toString());
        os.close();
      }
    });

    httpServer.setExecutor(null);
    httpServer.start();
  } catch(Exception e) {
    println("Failed to start HTTP server: ");
    println(e.getMessage());
  }
}

void setLastPageRequested(String url, String hostinfo) {
  lastPage = "Served " + url + " to host " + hostinfo;
}

// Provide Nunchuk raw data as an XML string
String nunchukRawState() {
  StringBuffer s = new StringBuffer("<NunchukState>\n\t<JoystickX>");
  s.append("" + nunchukState.joystickX());
  s.append("</JoystickX>\n\t<JoystickY>");
  s.append(nunchukState.joystickY());
  s.append("</JoystickY>\n\t<AccelerationX>");
  s.append(nunchukState.accelerationX());
  s.append("</AccelerationX>\n\t<AccelerationY>");
  s.append(nunchukState.accelerationY());
  s.append("</AccelerationY>\n\t<AccelerationZ>");
  s.append(nunchukState.accelerationZ());
  s.append("</AccelerationZ>\n\t<ButtonZ>");
  s.append(nunchukState.isButtonZDown() ? 1 : 0);
  s.append("</ButtonZ>\n\t<ButtonC>");
  s.append(nunchukState.isButtonCDown() ? 1 : 0);
  s.append("</ButtonC>\n</NunchukState>");  
  return s.toString();
}

// Provide Nunchuk processed data as an XML string
String nunchukProcessedState() {
  StringBuffer s = new StringBuffer("<NunchukState>\n\t<JoystickX>");
  s.append("" + nunchukStateProcessor.joystickX());
  s.append("</JoystickX>\n\t<JoystickY>");
  s.append(nunchukStateProcessor.joystickY());
  s.append("</JoystickY>\n\t<Rotation>");
  s.append(nunchukStateProcessor.accelerationX());
  s.append("</Rotation>\n\t<Tilt>");
  s.append(nunchukStateProcessor.accelerationY());
  s.append("</Tilt>\n\t<Reset>");
  s.append(nunchukStateProcessor.latchedAccelerationZ());
  s.append("</Reset>\n\t<ButtonZ>");
  s.append(nunchukStateProcessor.isButtonZDown() ? 1 : 0);
  s.append("</ButtonZ>\n\t<ButtonC>");
  s.append(nunchukStateProcessor.isButtonCDown() ? 1 : 0);
  s.append("</ButtonC>\n</NunchukState>");  
  return s.toString();
}

void processCommand(final String command, final String[] parameters) {
  if (command.equals(RECORD_UPDATE)) {
    // Must have 7 parameters
    if (parameters.length == 7) {
      // Update the nunchuk's raw state buffer
      nunchukState.updateJoystick(Integer.parseInt(parameters[0]),
                                  Integer.parseInt(parameters[1]));
      nunchukState.updateAcceleration(Integer.parseInt(parameters[2]),
                                      Integer.parseInt(parameters[3]),
                                      Integer.parseInt(parameters[4]));
      nunchukState.updateButtonZ(Integer.parseInt(parameters[5]) == 1);
      nunchukState.updateButtonC(Integer.parseInt(parameters[6]) == 1);
      
      // Process command
      nunchukStateProcessor.process(nunchukState);
    }
  }
}

