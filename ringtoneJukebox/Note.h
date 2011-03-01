#ifndef NOTE_H
#define NOTE_H

#include <stdint.h>

class Note {
public:
  // A frequency of 0 indicates a pause
  uint16_t frequency() const { return _frequency; }

  uint32_t duration() const { return _duration; }

  void setFrequency(uint16_t frequency) { _frequency = frequency; }
  
  void setDuration(uint32_t duration) { _duration = duration; }

private:
  uint16_t _frequency;
  uint32_t _duration;
};

#endif

