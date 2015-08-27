import codeanticode.syphon.*;

PGraphics canvas;
SyphonClient client;

import processing.serial.*;

Serial myPort;  // Create object from Serial class

boolean projecting = false;

int PreviousClock = 0;
int FrameClock = 0;
int FrameTime = 100;
int LineCount = 0;

void setup()
{
  size(200,200); //make our canvas 200 x 200 pixels big

  // List all the Serial Ports so we can decide which to use...
  printArray(Serial.list());

  // ... here.  Probably could do this automagically.
  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 115200 );

  // List all the Syphon Servers visible
  println(SyphonClient.listServers());

  // Create syhpon client to receive frames
  // from the first available running server:
  client = new SyphonClient(this);

  background(0);
}

void keyPressed() {                           //if we clicked in the window
  if ( !projecting ) {
    projecting = true;
    // Make the PlayaThing do master mode
    myPort.write('M');
    // Set the PlayaThing to be Video mode
    myPort.write('L');
    myPort.write("10");
  } else {
    projecting = false;
    myPort.write('N');
  }
}

void draw() {
  int currentClock = millis();
  int deltaClock = currentClock - PreviousClock;
  PreviousClock = currentClock;

  //print( "DT " );
  //println( deltaClock );

  while ( myPort.available() > 0 ) {
    char inByte = myPort.readChar();
    print(inByte);
   }

  FrameClock += deltaClock;

  if ( LineCount == 0 ) {
    if ( projecting ) {
      if ( client.available() ) {

        canvas = client.getGraphics(canvas);
        image(canvas, 0, 0, 14, 8);

        //rect( 4, 4, 6, 6 );

        for ( int y = 0; y < 8; y++ ) {
           myPort.write( 'X' );
           myPort.write( y + '0' );
           for ( int x = 3; x < 11; x++ ) {
             // RGB
             int c = get( x, y );
             myPort.write( (char)red( c )  );
             myPort.write( (char)green( c ) );
             myPort.write( (char)blue( c ) );
           }
         }
      }
    }
    LineCount++;
  }

/*
  if ( LineCount < 8 ) {
     int y = LineCount++;
     if ( projecting ) {
       myPort.write( 'X' );
       myPort.write( y + '0' );
       for ( int x = 0; x < 8; x++ ) {
         myPort.write( 10 + 10 * x  );
         myPort.write( 10 );
         myPort.write( 10 );
       }
     }
  }
*/

  if ( FrameClock > FrameTime ) {
    FrameClock = 0;
    LineCount = 0;
  }
}