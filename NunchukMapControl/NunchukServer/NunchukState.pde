// Buffers raw state data 
class NunchukState {
  private int _joystickX;
  private int _joystickY;
  private NunchukAccelerationBuffer _acceleration;
  private boolean _buttonZ;
  private boolean _buttonC;
  
  public NunchukState(final int maxSamples) {
    _joystickX = 0;
    _joystickY = 0;
    _acceleration = new NunchukAccelerationBuffer(maxSamples);
    _buttonZ = false;
    _buttonC = false;
  }

  public int joystickX() {
    return _joystickX;
  }

  public int joystickY() {
    return _joystickY;
  }

  public int accelerationX() {
    return _acceleration.getX();
  }

  public int accelerationY() {
    return _acceleration.getY();
  }

  public int accelerationZ() {
    return _acceleration.getZ();
  }

  public boolean isButtonZDown() {
    return _buttonZ;
  }

  public boolean isButtonCDown() {
    return _buttonC;
  }

  public void updateJoystick(int x, int y) {
    _joystickX = x;
    _joystickY = y;
  }

  public void updateAcceleration(int x, int y, int z) {
    _acceleration.addData(x, y, z);
  }

  public void updateButtonZ(boolean isDown) {
    _buttonZ = isDown;
  }

  public void updateButtonC(boolean isDown) {
    _buttonC = isDown;
  }
}

