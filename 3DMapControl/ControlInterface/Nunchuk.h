// Nunchuk class from Arduino: A Quick-Start Guide, by Maik Schmidt
#ifndef NUNCHUK_H
#define NUNCHUK_H

const unsigned int NUNCHUK_BUFFER_SIZE = 6;

class NunchukClass {
public:
  void initialize();
  bool update();

  int joystick_x() const { return _buffer[0]; }
  int joystick_y() const { return _buffer[1]; }

  int x_acceleration() const { return ((int)(_buffer[2]) << 2) | ((_buffer[5] >> 2) & 0x03); }
  int y_acceleration() const { return ((int)(_buffer[3]) << 2) | ((_buffer[5] >> 4) & 0x03); }
  int z_acceleration() const { return ((int)(_buffer[4]) << 2) | ((_buffer[5] >> 6) & 0x03); }

  bool z_button() const { return !(_buffer[5] & 0x01); }
  bool c_button() const { return !(_buffer[5] & 0x02); }

private:
  void request_data();
  char decode_byte(const char);
  
private:
  unsigned char _buffer[NUNCHUK_BUFFER_SIZE];
};

extern NunchukClass Nunchuk;

#endif

