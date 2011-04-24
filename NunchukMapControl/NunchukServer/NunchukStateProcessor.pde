// Normalize raw data, simplifying joystick position and accelerometer
// changes. Joystick position is mapped to the ranges:
//   Joystick X range [-10, 10]
//   Joystick Y range [-10, 10]
//
// Joystick X and Y values will be treated as an acceleration factor for 
// the map control.  The map will be moved (1 * value) units at each update.
// Updates will process periodically.  The joystick will be used to pan the
// map or globe up, down, left, and right.
//
// The Accelerometer values are mapped to the ranges:
//   X range [-10, 10]
//   Y range [-10, 10]
//   Z range [0,1]
// Joystick X and Y values will be treated as an acceleration factor for 
// globe control.  The view of the globe will be moved (1 * value) units
// at each update.  The X value will control camera rotation when the
// Nunchuk is tilted left and right.  The Y value will control camera
// tilt when the Nunchuk is tilted forward and backward.  The Z value
// will reset the camera when the Nunchuk is rapidly jerked up or down.
class NunchukStateProcessor extends NunchukState {
  // Adjustment for joystick "error", basically calculates values in
  // range [adjustment, 255 - adjustment] to [-10, 10].  Values less than
  // adjustment are clamped to -10 and values greater than (255 - adjustment)
  // are clamped to 10.
  final private int JOYSTICK_ADJUSTMENT = 45;
  
  // When tilted, accelerometer values range roughly from [300, 700]
  final private int TILT_MIN = 300;  // Tilted all the way to the left/up
  final private int TILT_MAX = 700;  // Tilted all the way to the right/down
  final private int TILT_ADJUSTMENT = 30;

  private NunchukState _calibratedState;

  public NunchukStateProcessor() {
    // Initialize superclass and calibrated state to store one processed sample
    super(1);
    _calibratedState = new NunchukState(1);
    
    // Set defaults in case calibration is never performed
    // Joystick position seems to range from [0,255] with 127 in the middle
    _calibratedState.updateJoystick(127, 127);
    
    // Accelerometer values seem to be near 500 when Nunchuk is held upright
    _calibratedState.updateAcceleration(500, 500, 500);
  }

  public int calibratedJoystickX() {
    return _calibratedState.joystickX();
  }

  public int calibratedJoystickY() {
    return _calibratedState.joystickY();
  }

  public int calibratedAccelerationX() {
    return _calibratedState.accelerationX();
  }

  public int calibratedAccelerationY() {
    return _calibratedState.accelerationY();
  }

  public int calibratedAccelerationZ() {
    return _calibratedState.accelerationZ();
  }
  
  public void calibrate(NunchukState calibratedState) {
    _calibratedState.updateJoystick(calibratedState.joystickX(),
                                    calibratedState.joystickY());
    _calibratedState.updateAcceleration(calibratedState.accelerationX(),
                                        calibratedState.accelerationY(),
                                        calibratedState.accelerationZ());
  }
  
  public void process(NunchukState currentState) {
    updateJoystick(normalizePosition(currentState.joystickX(),
                                     _calibratedState.joystickX()),
                   normalizePosition(currentState.joystickY(),
                                     _calibratedState.joystickY()));

    updateAcceleration(normalizeAcceleration(currentState.accelerationX(),
                                             _calibratedState.accelerationX()),
                       normalizeAcceleration(currentState.accelerationY(),
                                             _calibratedState.accelerationY()),
                       exceedsLimits(currentState.accelerationZ(), accelerationZ()));

    // Copy button states
    updateButtonZ(currentState.isButtonZDown());
    updateButtonC(currentState.isButtonCDown());
  }
  
  public int latchedAccelerationZ() {
    if (accelerationZ() == 1) {
      updateAcceleration(accelerationX(), accelerationY(), 0);
      return 1;
    }
    
    return 0;
  }
  
  private int clamp(int value, int clampMin, int clampMax) {
    if (value > clampMax) {
     return clampMax;
    } else if (value < clampMin) {
     return clampMin;
    }
    
    return value;
  }
  
  private int normalizePosition(int position, int center) {
    int value = (int)floor(((float)(position - center) / ((float)center - JOYSTICK_ADJUSTMENT)) * 10.0);
    return clamp(value, -10, 10);
  }

  private int normalizeAcceleration(int acceleration, int basis) {
    int value = 0;
    if (acceleration < basis) {
      value = (int)floor(((float)(acceleration - basis) / (float)(TILT_MIN - basis + TILT_ADJUSTMENT)) * -10.0);
    } else if (acceleration > basis) {
      value = (int)floor(((float)(acceleration - basis) / (float)(TILT_MAX - basis - TILT_ADJUSTMENT)) * 10.0);
    }

    return clamp(value, -10, 10);
  }
  
  private int exceedsLimits(int acceleration, int current) {
    // The exceeds limit indicator is latched to 1 when the limit is exceeded.  This is
    // because the "jerk" that causes the limit to be exceeded is quick and the application
    // may not see the change if the indicator is reset to 0 before the value of 1 is read.
    // The limit indicator is cleared by the latchedAccelerationZ() function.
    if (current == 0) {
      if (acceleration < TILT_MIN - TILT_ADJUSTMENT || acceleration > TILT_MAX + TILT_ADJUSTMENT) {
        return 1;
      }
    }
    
    return current;
  }
}

