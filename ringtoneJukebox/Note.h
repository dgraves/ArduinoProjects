#ifndef NOTE_H
#define NOTE_H

#include <stdint.h>

class Note {
public:
  // Numerical identifier for note, using same mappings as RingtonePlayer:
  // [0 -> pause, 1 -> C, 2 -> C# 3 -> D, 4 -> D#, 5-> E,
  //  6 -> F, 7-> F#, 8-> G, 9 -> G#, 10 -> A, 11 -> A#, 12 -> B]
  uint8_t id() const { return _id; }

  // A frequency of 0 indicates a pause
  uint16_t frequency() const { return _frequency; }

  uint32_t duration() const { return _duration; }

  void setId(uint8_t id) { _id = id; }

  void setFrequency(uint16_t frequency) { _frequency = frequency; }
  
  void setDuration(uint32_t duration) { _duration = duration; }

private:
  uint8_t _id;
  uint16_t _frequency;
  uint32_t _duration;
};

#endif

