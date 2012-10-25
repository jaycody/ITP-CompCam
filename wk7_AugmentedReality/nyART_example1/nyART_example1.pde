// Augmented Reality Basic Example by Amnon Owed (21/12/11)

// Processing 1.5.1 + NyARToolkit 1.1.6



import java.io.*; // for the loadPatternFilenames() function

import processing.opengl.*; // for OPENGL rendering

import jp.nyatla.nyar4psg.*; // the NyARToolkit Processing library



// a central location is used for the camera_para.dat and pattern files, so you don't have to copy them to each individual sketch

// Make sure to change both the camPara and the patternPath String to where the files are on YOUR computer

// the full path to the camera_para.dat file

String camPara = "Volumes/SubThree/Dropbox/_ITP_js5346/Processing/Libraries/nyar4psg/data/camera_para.dat";
//"C:/Users/mainframe/Documents/Processing/libraries/nyar4psg/data/camera_para.dat";

// the full path to the .patt pattern files

String patternPath = "Volumes/SubThree/Dropbox/_ITP_js5346/Processing/Libraries/nyar4psg/patternMaker/examples/ARToolKit_Patterns";

// the dimensions at which the AR will take place. with the current library 1280x720 is about the highest possible resolution.

// it will work just as well at a lower resolution such 640x360, in some case a lower resolution even seems to work better.

int arWidth = 1280;

int arHeight = 720;

// the number of pattern markers (from the complete list of .patt files) that will be detected, here the first 10 from the list.

int numMarkers = 10;



MultiMarker nya;

float displayScale;

color[] colors = new color[numMarkers];

float[] scaler = new float[numMarkers];

PImage input, inputSmall;



void setup() {

  size(1280, 720, OPENGL); // the sketch will resize correctly, so for example setting it to 1920 x 1080 will work as well

  // create a text font for the coordinates and numbers on the boxes at a decent (80) resolution

  textFont(createFont("Arial", 80));

  // load the input image and create a copy at the resolution of the AR detection (otherwise nya.detect will throw an assertion error!)

  input = loadImage("input.jpg");

  inputSmall = input.get();

  inputSmall.resize(arWidth, arHeight);

  // to correct for the scale difference between the AR detection coordinates and the size at which the result is displayed

  displayScale = (float) width / arWidth;

  // create a new MultiMarker at a specific resolution (arWidth x arHeight), with the default camera calibration and coordinate system

  nya = new MultiMarker(this, arWidth, arHeight, camPara, NyAR4PsgConfig.CONFIG_DEFAULT);

  // set the delay after which a lost marker is no longer displayed. by default set to something higher, but here manually set to immediate.

  nya.setLostDelay(1);

  String[] patterns = loadPatternFilenames(patternPath);

  // for the selected number of markers, add the marker for detection

  // create an individual color and scale for that marker (= box)

  for (int i=0; i<numMarkers; i++) {

    nya.addARMarker(patternPath + "/" + patterns[i], 80);

    colors[i] = color(random(255), random(255), random(255), 160); // random color, always at a transparency of 160

    scaler[i] = random(0.5, 1.9); // scaled at half to double size

  }

}



void draw() {

  background(0); // a background call is needed for correct display of the marker results

  image(input, 0, 0, width, height); // display the image at the width and height of the sketch window

  nya.detect(inputSmall); // detect markers in the input image at the correct resolution (incorrect resolution will give assertion error)

  drawMarkers(); // draw the coordinates of the detected markers (2D)

  drawBoxes(); // draw boxes on the detected markers (3D)

}



// this function draws the marker coordinates, note that this is completely 2D and based on the AR dimensions (not the final display size)

void drawMarkers() {

  // set the text alignment (to the left) and size (small)

  textAlign(LEFT, TOP);

  textSize(10);

  noStroke();

  // scale from AR detection size to sketch display size (changes the display of the coordinates, not the values)

  scale(displayScale);

  // for all the markers...

  for (int i=0; i<numMarkers; i++) {

    // if the marker does NOT exist (the ! exlamation mark negates it) continue to the next marker, aka do nothing

    if ((!nya.isExistMarker(i))) { continue; }

    // the following code is only reached and run if the marker DOES EXIST

    // get the four marker coordinates into an array of 2D PVectors

    PVector[] pos2d = nya.getMarkerVertex2D(i);

    // draw each vector both textually and with a red dot

    for (int j=0; j<pos2d.length; j++) {

      String s = "(" + int(pos2d[j].x) + "," + int(pos2d[j].y) + ")";

      fill(255);

      rect(pos2d[j].x, pos2d[j].y, textWidth(s) + 3, textAscent() + textDescent() + 3);

      fill(0);

      text(s, pos2d[j].x + 2, pos2d[j].y + 2);

      fill(255, 0, 0);

      ellipse(pos2d[j].x, pos2d[j].y, 5, 5);

    }

  }

}



// this function draws correctly placed 3D boxes on top of detected markers

void drawBoxes() {

  // set the AR perspective uniformly, this general point-of-view is the same for all markers

  nya.setARPerspective();

  // set the text alignment (full centered) and size (big)

  textAlign(CENTER, CENTER);

  textSize(20);

  // for all the markers...

  for (int i=0; i<numMarkers; i++) {

    // if the marker does NOT exist (the ! exlamation mark negates it) continue to the next marker, aka do nothing

    if ((!nya.isExistMarker(i))) { continue; }

    // the following code is only reached and run if the marker DOES EXIST

    // get the Matrix for this marker and use it (through setMatrix)

    setMatrix(nya.getMarkerMatrix(i));

    scale(1, -1); // turn things upside down to work intuitively for Processing users

    scale(scaler[i]); // scale the box by it's individual scaler

    translate(0, 0, 20); // translate the box by half (20) of it's size (40)

    lights(); // turn on some lights

    stroke(0); // give the box a black stroke

    fill(colors[i]); // fill the box by it's individual color

    box(40); // the BOX! ;-)

    noLights(); // turn off the lights

    translate(0, 0, 20.1); // translate to just slightly above the box (to prevent OPENGL uglyness)

    noStroke();

    fill(255, 50);

    rect(-20, -20, 40, 40); // display a transparent white rectangle right above the box

    translate(0, 0, 0.1); // translate to just slightly above the rectangle (to prevent OPENGL uglyness)

    fill(0);

    text("" + i, -20, -20, 40, 40); // display the ID of the box in black text centered in the rectangle

  }

  // reset to the default perspective

  perspective();

}



// this function loads .patt filenames into a list of Strings based on a full path to a directory (relies on java.io)

String[] loadPatternFilenames(String path) {

  File folder = new File(path);

  FilenameFilter pattFilter = new FilenameFilter() {

    public boolean accept(File dir, String name) {

      return name.toLowerCase().endsWith(".patt");

    }

  };

  return folder.list(pattFilter);
}

