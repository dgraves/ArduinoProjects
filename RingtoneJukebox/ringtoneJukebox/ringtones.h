#ifndef RINGTONES_H
#define RINGTONES_H

#include <avr/pgmspace.h>

// Our ringtone selection consists of 16 ringtones: 8 television themes and 8 songs.
// The ringtone data is too large for SRAM and must be stored in flash memory.
// Ringtones are represented with the RTTTL format: http://merwin.bespin.org/t4a/specs/nokia_rtttl.txt

// Themes
const char tone_0[] PROGMEM  = "MacGyver:d=8,o=5,b=160:c6,c6,c6,c6,c6,c6,c6,c6,2b,f#,4a,2g,p,c6,4c6,4b,a,b,a,4g,4e6,2a,c6,4c6,2b,p,f#,4a,2g,p,c6,4c6,4b,a,b,a,4g,4e6,2a,2b,c6,b,a,4c6,b,a,4d6,c6,b,4d6,c6,b,4e6,d6,e6,4f#6,4b,1g6";
const char tone_1[] PROGMEM  = "Yaketysax:d=4,o=5,b=125:8d.,16e,8g,8g,16e,16d,16a4,16b4,16d,16b4,8e,16d,16b4,16a4,16b4,8a4,16a4,16a#4,16b4,16d,16e,16d,g,p,16d,16e,16d,8g,8g,16e,16d,16a4,16b4,16d,16b4,8e,16d,16b4,16a4,16b4,8d,16d,16d,16f#,16a,8f,d,p,16d,16e,16d,8g,16g,16g,8g,16g,16g,8g,8g,16e,8e.,8c,8c,8c,8c,16e,16g,16a,16g,16a#,8g,16a,16b,16a#,16b,16a,16b,8d6,16a,16b,16d6,8b,8g,8d,16e6,16b,16b,16d,8a,8g,g";
const char tone_2[] PROGMEM  = "Ateam:d=4,o=5,b=140:4f6,8c6,2f6,8a#,4c6,2f,16a,16c6,8f6,8f6,8g6,2f6,8d#.6,16d6,16c6,8a#.,2c6,8f6,8f6,8c6,2f6,8a,8a#,8g,8c6,2f,8g#.,8a#.,2d#6,8d#6,8d6,8p,8a#,8d#.6,16p,8d6,8p,8a.,16a#,8c6,2f6,8c6,8a#,8p,8f,4c6,8a#.,16p,8a#,8a,8f,8e,2f,8a,8a,8g,4a,8g.,16p,8a.,16p,8g.,16p,8g,8d.6,16p,4c6,8a,8a,8g,8a.,16p,8g.,16p,8f.,16p,8f.,16p,8f,4g.,16p,8a,8a,8g,8a.,16p,8g.,16p,8a,8p,8g.,16p,8g,8d.6,16p,8c.6,16p,8a,8a,8g,8a.,16p,8g.,16p,8f,8p,8f.,16p,8f,4e.";
const char tone_3[] PROGMEM  = "HogansHero:d=16,o=6,b=45:f.5,g#.5,c#.,f.,f#,32g#,32f#.,32f.,8d#.,f#,32g#,32f#.,32f.,d#.,g#.5,c#,32c,32c#.,32a#.5,8g#.5,f.5,g#.5,c#.,f.5,32f#.5,a#.5,32f#.5,d#.,f#.,32f.,g#.,32f.,c#.,d#.,8c#.";
const char tone_4[] PROGMEM  = "Bananas:d=4,o=5,b=200:8c,8c,8c,8c,8e,8e,8e,8e,8g,8g,8g,8g,8e,8p,p,8f,8f,8f,8f,8f,8f,8f,8f,8e,8c,8c,8p,8c,8p,p,8c,8c,8c,8c,e,e,8g,8g,8g,8g,8e,8p,p,8f,8f,p,8f,8f,p,8e,8c,8c,8p,8c,8p,p,c6,a,g.,c6,8c6,a,2g,c6,a,g.,e,8e,d,2c,c6,a,g.,c6,8c6,a,2g,c6,a,g.,e,8e,d,1c";
const char tone_5[] PROGMEM  = "Sanford:d=8,o=5,b=112:g,g,e6,d6,4p,g,g,e6,d6,a#,b,4g,g,g,b,a,4p,b,d6,b,a,e,f,4d,d,d,e,g,g,e,a#,c6,4p,4d6,4g.6,g6,g,a,a#,b,4g6,a,4f6,g,4e6,f,4d6,g,a,a#,b,c6,4b,c6";
const char tone_6[] PROGMEM  = "SuperMario:d=4,o=5,b=100:16e6,8e6,8e6,16c6,8e6,8g6,8p,8c,8p,8c.6,16g,8p,8e,16p,8a,8b,16a#,16a,16p,16g,8e6,16g6,8a6,16e6,8g6,8e6,16c6,16e6,8b.,8c.6,16g,8p,8e,16p,8a,8b,16a#,16a,16p,16g,8e6,16g6,8a6,16e6,8g6,8e6,16c6,16e6,8b.,8c.6";
const char tone_7[] PROGMEM  = "MahnaMahna:d=16,o=6,b=125:c#,c.,b5,8a#.5,8f.,4g#,a#,g.,4d#,8p,c#,c.,b5,8a#.5,8f.,g#.,8a#.,4g,8p,c#,c.,b5,8a#.5,8f.,4g#,f,g.,8d#.,f,g.,8d#.,f,8g,8d#.,f,8g,d#,8c,a#5,8d#.,8d#.,4d#,8d#.";

// Songs
const char tone_8[] PROGMEM  = "SweetChild:d=8,o=5,b=140:a4,a,e,d,d6,e,c#6,e,a4,a,e,d,d6,e,c#6,e,h4,a,e,d,d6,e,c#6,e,h4,a,e,d,d6,e,c#6,e,d,a,e,d,d6,e,c#6,e,d,a,e,d,d6,e,c#6,e,a4,a,e,d,d6,e,c#6,e,a4,a,e,d,d6,e,c#6,e";
const char tone_9[] PROGMEM  = "Reaper:d=8,o=5,b=140:a,a,4a,4g,d,4e,g,4p.,c,c,c,4a.,a,h,h,h,4c6.,a,a,h,4h,4h,4c6.,c6,4h,4h,c6,4a,4h,h,4h,c6,4a,h,4h,4h,c6,a,a,h,4h,4c6.,4a,h,4h,4h,4c6";
const char tone_10[] PROGMEM = "MoneyFor:d=8,o=5,b=125:4d,4d6.,c6,a,4c6.,a,g,g,4f,d,4p,4d.,f,d,p,4f,4g,4g,f,d,4p,4a.,g,a,4a,c6,a,a,g,4f,d,4p,4d.,f,d,p,4c,4d,4d";
const char tone_11[] PROGMEM = "FinalCount:d=4,o=5,b=125:p,8p,16b,16a,b,e,p,8p,16c6,16b,8c6,8b,a,p,8p,16c6,16b,c6,e,p,8p,16a,16g,8a,8g,8f#,8a,g.,16f#,16g,a.,16g,16a,8b,8a,8g,8f#,e,c6,2b.,16b,16c6,16b,16a,1b";
const char tone_12[] PROGMEM = "TakeOnMe:d=4,o=4,b=160:8f#5,8f#5,8f#5,8d5,8p,8b,8p,8e5,8p,8e5,8p,8e5,8g#5,8g#5,8a5,8b5,8a5,8a5,8a5,8e5,8p,8d5,8p,8f#5,8p,8f#5,8p,8f#5,8e5,8e5,8f#5,8e5,8f#5,8f#5,8f#5,8d5,8p,8b,8p,8e5,8p,8e5,8p,8e5,8g#5,8g#5,8a5,8b5,8a5,8a5,8a5,8e5,8p,8d5,8p,8f#5,8p,8f#5,8p,8f#5,8e5,8e5,8f#5,8e5";
const char tone_13[] PROGMEM = "WannaBe:d=4,o=5,b=125:16g,16g,16g,16g,8g,8a,8g,8e,8p,16c,16d,16c,8d,8d,8c,e,p,8g,8g,8g,8a,8g,8e,8p,c6,8c6,8b,8g,8a,16b,16a,g";
const char tone_14[] PROGMEM = "Finnegans:d=8,o=5,b=90:4e,16e,16e,e,e,d,e,g,a.,16h,c6,h,a,g,e,d,d,16p,16e,16e,16e,16e,e,e,d,e,g,g,16a,16h,c6,16h,16h,a,g,a,16a,16h,c6,16g,16g,c6,16c6,16c6,c6,16c6,16d6,c6,h,a,16g,16g,c6,c6,c6,d6,c6,h,a,16g,16g,c6,c6,c6,d6,c6,h,a,16g,16g,a,16a,16a,a,g,a,h,4c6,p,e,16e,16e,e,d,e,g,a,h,c6,h,a,g,e,d,4d";
const char tone_15[] PROGMEM = "TheWildR:d=4,o=5,b=160:d,g.,8a,g,e,d,h,h,a,h,2c6.,16p,8h,8c6,d6,h,d6,c6,a,f#,d,h.,8a,2g.,8p,d,g.,8a,g,e,d,h,h,a,h,2c6.,8p,8h,8c6,d6,h,d6,c6,a,f#,d,h,a,g,8p,f#,g,2a.,2a.,f#,2d,h,h,h,a,h,2c6.,h,c6,2d6.,h,g,f#,2e.,e,d,2h.,a,2g.";

// Setup the string table
PROGMEM const char* RINGTONES[] = {
  tone_0,
  tone_1,
  tone_2,
  tone_3,
  tone_4,
  tone_5,
  tone_6,
  tone_7,
  tone_8,
  tone_9,
  tone_10,
  tone_11,
  tone_12,
  tone_13,
  tone_14,
  tone_15,
};

const uint16_t NUM_RINGTONES = 16;

#endif

