/*
 Easy Program Launcher for Teensy USB
  
 Emulates a keyboard that sends a command to a pesonal
 computer to launch an application when a button is
 pressed (preferrably a hacked Easy Button from Staples).
 A switch selects between Windows and Linux operating
 system mode.  When Windows mode is enabled, 'Ctrl+R' is
 sent, followed by the name of a batch file to be executed,
 'easylauncher.bat'.  When Linux mode is selected, 'Alt+F2'
 is sent, followed by a command to launch a script, 
 'sh easylauncher.sh'.

 The files 'easylauncher.bat' and 'easylauncher.sh' can
 contain any set of commands for launching an application.
 They must be in your path to work correctly.

 EasyProgramLauncher is a program for the Teensy USB
 Development Board.  A Teensy USB board, the Teensy
 USB loader application and Teensyduino add-on for the
 Arduino IDE are required to use this program.
 
 EasyProgramLauncher was designed to be use with a
 modified Easy Button from Staples and is a slightly
 modified version of the Awesome Button, created by
 Matt Richardson:
   http://blog.makezine.com/archive/2011/04/the-awesome-button.html
 
 circuit:
 * Pin B0 to push button
 * Pin B1 to slide switch

 created 08 Jun 2011
 by Dustin Graves

 This code is licensed with the MIT License.

 http://www.dgraves.org
 */
const unsigned int BUTTON_PIN = PIN_B0;
const unsigned int SWITCH_PIN = PIN_B1;
const char win32_program[] = "easylauncher.bat";
const char linux_program[] = "sh easylauncher.sh";

void setup() {
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(SWITCH_PIN, INPUT_PULLUP);
  delay(1000);
}

void loop()                     
{
  if (digitalRead(BUTTON_PIN) != HIGH) {
    if (digitalRead(SWITCH_PIN) != HIGH) {
      // Send the key commands to open the run dialog
      Keyboard.set_modifier(MODIFIERKEY_ALT);
      Keyboard.set_key1(KEY_F2);
      Keyboard.send_now();

      Keyboard.set_modifier(0);
      Keyboard.set_key1(0);
      Keyboard.send_now();

      delay(250);

      // Send the name of the program to run
      Keyboard.println(linux_program);
    } else {
      // Send the key commands to open the run dialog
      Keyboard.set_modifier(MODIFIERKEY_GUI);
      Keyboard.set_key1(KEY_R);
      Keyboard.send_now();

      Keyboard.set_modifier(0);
      Keyboard.set_key1(0);
      Keyboard.send_now();
      
      delay(250);

      // Send the name of the program to run
      Keyboard.println(win32_program);
    }
  }

  delay(250);
}

