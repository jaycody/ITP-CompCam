/* jason stephens
 Computational Cameras
 FaceOSC -> Controls Generative System
 (aka: Control Noise With Mouth)
 
 Objective:
 Demonstrate FaceOSC with a series of generative sketches with face controlled parameters.
 
 Method:
 Create a baseline series of animations increasing in complexity between keyPress 1-6.
 Add perlin noise to each 
 Add faceControl to replace perlin noise
 
 TODO:
 DONE____print directions
 ____add 6 spiral
 
 ____add toggle for perlin noise for each
 ____add toggle for lines
 ____add toggle for faceControl to function
 ____push '1' creates sin movement on X axis
 ____push '2' creates cos movement on Y axis (osicllate up/down)
 ____push '3' creates circle from circulating dots
 ____push '4' adds Noise to circle
 ____push '5' controls to 1 (mouth width, centroid, size of center circle = eye size)
 ____push '6' adds controls to 2 (mouth height)
 ____push '7' adds controls to circle (mouth area)
 ____add center location based on center of face
 ____blink changes rotation direction
 ____mouth width changes X amplitude
 ____mouth heigh changes Y amplitude
 ____eyes change center circle 
 
 NOTES:
 locationX = amplitude * cos (angle); // where cos(angle) = 0-1
 locationY = amplitude * sin (angle); // where sin(angle) = 0-1
 
 */

PVector amplitude;
PVector location;
PVector angularVelocity; 
PVector centerCircle;

float centerX;
float centerY;
float radius = 100;
float moveX;

float angle = 0;
float aVelocity = .05;
float amplitudeX = 200;
float amplitudeY = 200;
float theta = 0;
float spiralTheta = 0;
float spiralSize =1;
float spiralAcceleration = .01;

int lastKey = 0;
boolean showLines = false;
boolean mouseVelocity = false;
boolean mouseYspiralAcceleration = false;
boolean faceControl = false;

void setup () {
  size (750, 750);
  smooth (); 
  background(255);
  strokeWeight (5);

  centerX = width/2;
  centerY = height/2;

  printDirections();
}

void draw () {

  semiTransparent();

  //returns the velocity (either mouseControlled or hardCoded depending on 'v' keyPress
  float varVelocity = calcVelocity(aVelocity); //calculate the variable velocity. take angular velocity as argument

  // Create the PVectors for motion and prepare them for following calcultion function
  PVector angularVelocity = new PVector (angle, varVelocity); //stores initial angle and the deltaAngle
  PVector amplitude = new PVector (amplitudeX, amplitudeY); //stores the maxX maxY (aka radius)

  //this PVector holds the return value of the calculation function, which sends radius and velocity info to calc
  PVector location = calculateCircle(angularVelocity, amplitude);
  //figure out where the translation of the entire circle
  PVector centerCircle = calculateCenter(centerX, centerY);

  if (lastKey == 1) {
    drawOscillatingX(location, centerCircle);
  }
  if (lastKey == 2) {
    drawOscillatingY(location, centerCircle);
  }
  if (lastKey == 3) {
    drawCircle(location, centerCircle); //send the location PVector (containing both X and Y coordinates
  }
  if (lastKey == 4) {
    drawCircleDual(location, centerCircle); // this time add noise
  }
  if (lastKey == 5) {
    drawCircleQuad(location, centerCircle); // this time add noise
  }
  if (lastKey == 6) {
    drawSpiral(location, centerCircle); // this time add noise
  }
}

//Start the Machine
void printDirections() {
  println("Controls:  animation = 1-6  :  showLines = SpaceBar    :   mouseX Velocity = 'v'  :  mouseY Sprial = 's'");
println("faceControl = 'f'");
}

void semiTransparent() {
  rectMode(CORNER);
  noStroke();
  fill(255, 10);
  rect(0, 0, width, height);
  stroke(0);
  noFill();
}

//calculate Variable velocity.  take Angular Velocity as an argument
float calcVelocity(float aVelocity) { 
  float velocity = aVelocity;
  //if boolean for mouse controlled velocity is false, then return the standard velocity
  if (mouseVelocity == false) {
  }
  //if boolean for mouse control is true, then set velocity
  if (mouseVelocity == true) {  
    velocity = map(mouseX, 0, width, -1, 1);
  }
  return velocity;
}

// This function takes 4 argumments and returns 1 PVector
PVector calculateCircle (PVector angularVelocity, PVector amplitude) {
  float x = amplitude.x * cos (theta); 
  float y = amplitude.y * sin (theta);
  location = new PVector (x, y);
  theta = theta + angularVelocity.y; // 
  return location;
}

// this function returns calculates where the circle is (translates) and returns as PVector
PVector calculateCenter(float centerX, float centerY) {
  PVector centerCircle = new PVector (centerX, centerY);
  return centerCircle;
}

// Do '1':  draw the osicallating X
void drawOscillatingX (PVector location, PVector centerCircle) { 
  translate (centerCircle.x, centerCircle.y);
  ellipse (0, 0, amplitudeX *.5, amplitudeY*.5); 
  point (0, 0);
  point (location.x, 0);
}

//Do '2':  draw the oscillating Y
void drawOscillatingY (PVector location, PVector centerCircle) {
  translate (centerCircle.x, centerCircle.y);  //use the PVector to determine the translate
  ellipse (0, 0, amplitudeX *.5, amplitudeY*.5); 
  point (location.x*.1, location.y*.1); 
  point (0, 0);
  point (0, location.y);
}

//Do '3': draw the circle from points
void drawCircle (PVector location, PVector centerCircle) {
  translate (centerCircle.x, centerCircle.y);
  ellipse (0, 0, amplitudeX *.5, amplitudeY*.5); 
  point (0, 0);
  point (location.x, location.y);
  if (showLines) {
    line(0, 0, location.x, location.y);
  }
}

//Do '4': draw the circle from points
void drawCircleDual (PVector location, PVector centerCircle) {
  translate (centerCircle.x, centerCircle.y);
  ellipse (0, 0, amplitudeX *.5, amplitudeY*.5); 
  point (0, 0);
  //line(0, 0, width-location.x, height-location.y);
  float backWardsY = location.y*-1;
  point (location.x, backWardsY);
  point (location.x, location.y);
  if (showLines) {
    line(0, 0, location.x, location.y);
    line (0, 0, location.x, backWardsY);
  }
}

//Do '5': draw the circle from points
void drawCircleQuad (PVector location, PVector centerCircle) {
  translate (centerCircle.x, centerCircle.y);
  ellipse (0, 0, amplitudeX *.5, amplitudeY*.5); 
  point (0, 0);
  //line(0, 0, width-location.x, height-location.y);
  float backWardsY = location.y*-1;
  float backWardsX = location.x*-1;
  point (location.x, backWardsY);
  point (location.x, location.y);
  point (backWardsX, backWardsY);
  point (backWardsX, location.y);
  if (showLines) {
    line(0, 0, location.x, location.y);
    line (0, 0, location.x, backWardsY);
    line (0, 0, backWardsX, backWardsY);
    line (0, 0, backWardsX, location.y);
  }
}

//Do '6': draw the circle from points
void drawSpiral (PVector location, PVector centerCircle) {
  translate (centerCircle.x, centerCircle.y);
  ellipse (0, 0, amplitudeX *.5, amplitudeY*.5); 
  point (0, 0);
  //create the spiraling for loop.  use absolute value to determine boundary conditions.
  //use spiralTheta as a SCALAR
  if (mouseYspiralAcceleration) {
    spiralAcceleration = map(mouseY, 0, height, .001, 1);
  }
  spiralTheta = spiralTheta+ spiralSize * spiralAcceleration;
  if (abs(spiralTheta) > 2) {
    spiralSize =spiralSize*-1;
  }
  location.mult(spiralTheta);
  point (location.x, location.y);
  if (showLines) {
    line(0, 0, location.x, location.y);
  }
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
  if (key =='4') {
    lastKey=4;
  }
  if (key =='5') {
    lastKey=5;
  }
  if (key == '6') {
    lastKey=6;
  }
  if (key == ' ') {
    showLines = !showLines;
  }
  if (key == 'v') {
    mouseVelocity = !mouseVelocity;
  }
  if (key == 's') {
    mouseYspiralAcceleration = !mouseYspiralAcceleration;
  }
  if (key == 'f') {
    faceControl = !faceControl;
  }
}

