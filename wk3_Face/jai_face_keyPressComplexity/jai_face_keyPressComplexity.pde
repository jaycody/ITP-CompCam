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
 
 */
float centerX;
float centerY;
float radius = 100;
float moveX;

float angle = 0;
float aVelocity = .05;

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

  if (lastKey == 1) {
    drawOscillatingX();
  }
}

void drawOscillatingX () {
  // Amplitude is the maximum movement (aka radius or deviation from 0)
  float amplitude = 100;

  // cos(angle) = 0-1 (or a percentage.  
  //thus, at every increment angle, X is somewhere between 0 and radius)
  float x = amplitude * cos (angle);

  //now increment the angle by the velocity
  angle = angle + aVelocity; // where velocity is distance/frame

  translate (centerX, centerY);
  ellipse (0, 0, 50, 50); 
  point (0, 0);
  point (x, 0);
}

void keyPressed() {
  if (key == '1') {
    lastKey=1;
  }
  else {
    lastKey=0;
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
}






