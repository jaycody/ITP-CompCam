/* jason stephens
 Computational Cameras
 FaceOSC -> Controls Generative System
 (aka: Control Noise With Mouth)
 
 Objective:
 Create a series of generative events that are eventually controlled by FaceOSC.
 
 Method:
 Create a push button increase of complexity 1-9.  Then add Face Control to final
 
 TODO:
 ____push '1' creates sin movement on X axis
 ____push '2' creates sin movement on Y axis (osicllate up/down)
 ____push '3' creates circle
 ____push '4' adds noise
 ____push '5' control noise with mouth
 
 NOTES:
 locationX = amplitude * cos (angle); // where cos(angle) = 0-1
 locationY = amplitude * sin (angle); // where sin(angle) = 0-1
 
 */
 
 PVector amplitude;
 PVector location;
 PVector angularVelocity; 

float centerX;
float centerY;
float radius = 100;
float moveX;

float angle = 0;
float aVelocity = .05;
float amplitudeX = 100;
float amplitudeY = 100;
float theta = 0;

int lastKey = 0;

void setup () {
  size (500, 500);
  smooth (); 
  background(255);
  strokeWeight (5);

  centerX = width/2;
  centerY = height/2;
}

void draw () {
  //start by doing the math
  //this function returns a PVector and stores it here, right???
  // pass the angle and the angle velocity through calculations
  //PVector angularVelocity = new PVector (angle, aVelocity);
PVector angularVelocity = new PVector (angle, aVelocity); //initial angle = 0, angular velocity
  PVector amplitude = new PVector (amplitudeX, amplitudeY);
  PVector location = calculations(angularVelocity,amplitude);

  if (lastKey == 1) {
    drawOscillatingX(location.x);
  }
  if (lastKey == 2) {
    drawOscillatingY(location.y);
  }
  if (lastKey == 3) {
    drawCircle(location); //send the location PVector (containing both X and Y coordinates
  }
}

// This function takes 4 argumments and returns 1 PVector
PVector calculations (PVector _angularVelocity, PVector _amplitude) {
  float x = _amplitude.x * cos (theta); 
  float y = _amplitude.y * sin (theta);
  location = new PVector (x, y);
  theta = theta + _angularVelocity.y; // 
  return location;
}

void drawOscillatingX (float _x) {
  float x = _x;  // returned from the calculations 
  translate (centerX, centerY);
  ellipse (0, 0, 50, 50); 
  point (0, 0);
  point (x, 0);
}

void drawOscillatingY (float _y) {
  float y = _y;
  translate (centerX, centerY);
  ellipse (0, 0, 50, 50); 
  point (0, 0);
  point (0, y);
}

void drawCircle (PVector _location) {
  translate (centerX, centerY);
  ellipse (0,0,50,50);
  point (0,0);
  point (_location.x, _location.y);
}

// this allows me to increase the complexity with keypad
void keyPressed() {
  if (key == '0') {
    lastKey=0;
  }
  if (key == '1') {
    lastKey=1;
  }
  if (key == '2') {
    lastKey=2;
  }
  if (key== '3') {
    lastKey=3;
  }
  background(255);
}

//  if (key == CODED) {
//    if (keyCode == UP) {
//      fillVal = 255;
//    } else if (keyCode == DOWN) {
//      fillVal = 0;
//    } 
//  } else {
//    fillVal = 126;
//  }




