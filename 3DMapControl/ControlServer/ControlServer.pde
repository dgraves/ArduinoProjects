/*
Control Server

For reading Nunchuk state data from the Arduino and
making it available through a RESTful web service.

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
final int PAD_X = 10;
final int PAD_Y = 10;

// Samples for smoothing acceleration with NunchukStateBuffer
final int MAX_SAMPLES = 16;

// Types for records received from Arduino
final String RECORD_UPDATE = "update";

// RESTful URLs
final String RAW_URL = "/nunchuk/state/raw";
final String PROCESSED_URL = "/nunchuk/state/processed";

// Location of files to be loaded by web server
final String ROOT_URL = "/";
String webRoot;

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

  webRoot = System.getProperty("user.home") + "/Documents/Arduino/3DMapControl/MapPages";

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
  text("HTTP Server Status", PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  URL: http://localhost:" + SERVER_PORT, PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  WWW Root: " + webRoot, PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Last Activity: " + lastPage, PAD_X, PAD_Y + (FONT_SIZE * count++));
    
  // Raw state data
  count++;
  text("Nunchuk Raw Data", PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Joystick X: " + nunchukState.joystickX(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Joystick Y: " + nunchukState.joystickY(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Acceleration X: " + nunchukState.accelerationX(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Acceleration Y: " + nunchukState.accelerationY(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Acceleration Z: " + nunchukState.accelerationZ(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Button C: " + (nunchukState.isButtonCDown() ? "Down" : "Up"), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Button Z: " + (nunchukState.isButtonZDown() ? "Down" : "Up"), PAD_X, PAD_Y + (FONT_SIZE * count++));
 
  // Processed state data
  count++;
  text("Nunchuk Processed Data", PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Pan X: " + nunchukStateProcessor.joystickX(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Pan Y: " + nunchukStateProcessor.joystickY(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Rotation: " + nunchukStateProcessor.accelerationX(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Tilt: " + nunchukStateProcessor.accelerationY(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Reset: " + nunchukStateProcessor.accelerationZ(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Zoom In: " + (nunchukStateProcessor.isButtonCDown() ? "Down" : "Up"), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Zoom Out: " + (nunchukStateProcessor.isButtonZDown() ? "Down" : "Up"), PAD_X, PAD_Y + (FONT_SIZE * count++));

  // Calibration data values
  count++;
  text("Calibration Values", PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Joystick X: " + nunchukStateProcessor.calibratedJoystickX(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Joystick Y: " + nunchukStateProcessor.calibratedJoystickY(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Acceleration X: " + nunchukStateProcessor.calibratedAccelerationX(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Acceleration Y: " + nunchukStateProcessor.calibratedAccelerationY(), PAD_X, PAD_Y + (FONT_SIZE * count++));
  text("  Acceleration Z: " + nunchukStateProcessor.calibratedAccelerationZ(), PAD_X, PAD_Y + (FONT_SIZE * count++));
}

void setupHttpServer() {
  try {
    httpServer = HttpServer.create(new InetSocketAddress(SERVER_PORT), 8);

    // Create context to serve files
    httpServer.createContext(ROOT_URL, new RequestHandler(new FileResponseGenerator(webRoot)));

    // Create context to handle requests for raw nunchuk state data request
    httpServer.createContext(RAW_URL, new RequestHandler(new ResponseGenerator() {
      public String generateResponse(HttpExchange ex) {
        setLastPageRequested(RAW_URL, ex.getRemoteAddress().toString());
        return nunchukRawResponse();
      }
    }));

    // Create context to handle requests for processed nunchuk state data request
    httpServer.createContext(PROCESSED_URL, new RequestHandler(new ResponseGenerator() {
      public String generateResponse(HttpExchange ex) {
        setLastPageRequested(PROCESSED_URL, ex.getRemoteAddress().toString());
        return nunchukProcessedResponse();
      }
    }));

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
String nunchukRawResponse() {
  StringBuffer s = new StringBuffer("<NunchukRawState>\n\t<JoystickX>");
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
  s.append("</ButtonC>\n</NunchukRawState>");  
  return s.toString();
}

// Provide Nunchuk processed data as an XML string
String nunchukProcessedResponse() {
  StringBuffer s = new StringBuffer("<NunchukProcessedState>\n\t<PanX>");
  s.append("" + nunchukStateProcessor.joystickX());
  s.append("</PanX>\n\t<PanY>");
  s.append(nunchukStateProcessor.joystickY());
  s.append("</PanY>\n\t<Rotation>");
  s.append(nunchukStateProcessor.accelerationX());
  s.append("</Rotation>\n\t<Tilt>");
  s.append(nunchukStateProcessor.accelerationY());
  s.append("</Tilt>\n\t<Reset>");
  s.append(nunchukStateProcessor.latchedAccelerationZ());
  s.append("</Reset>\n\t<ZoomOut>");
  s.append(nunchukStateProcessor.isButtonZDown() ? 1 : 0);
  s.append("</ZoomOut>\n\t<ZoomIn>");
  s.append(nunchukStateProcessor.isButtonCDown() ? 1 : 0);
  s.append("</ZoomIn>\n</NunchukProcessedState>");  
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

