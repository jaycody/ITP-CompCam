/* infinite thanks to Greg Borenstein for his detailed description of this process in his book
 Making Things See
 
 NOTES:
 each HOTSPOT has its own CENTER.  with the push/popMatrix, the drawings do not interfere with each other.
 each HOTSPOT has its own OSC address to receive signals from the ipad
 */


class Hotspot {
  PVector center;
  color fillColor;
  color strokeColor;
  int size;
  int pointsIncluded;
  int maxPoints;
  boolean wasJustHit;
  int threshold;

  int triggered ;  //is incoming osc value, this will add one to itself.  if greater than 1 and !wasJustHit, then GO

  float oscAddress; //gots to have an address from the iPad

  // thr CONSTRUCTOR; it takes 5 arguments representing position size, color.  SAVES these as "instance variables"
  Hotspot (float centerX, float centerY, float centerZ, int boxSize) {
    center = new PVector (centerX, centerY, centerZ);
    size = boxSize;
    pointsIncluded = 0;
    maxPoints = 1000;
    threshold = 0; 
    fillColor = strokeColor = color(random(255), random(255), random(255)); // I can then change this with pass in the color c somehow like color c1 = color (204,255,0);
    //gregs code has fillColor and strokeColor filled at random, but I'd like to pass these variables in.

    // oscAddress = osc;  //coming in from this instance's related touchOSC value
  }

  //now time for some METHODS (aka functions for classes)

  void setThreshold (int newThreshold) {
    threshold = newThreshold;
  }

  void setMaxPoints (int newMaxPoints) {
    maxPoints = newMaxPoints;
  }

  void setColor (float red, float blue, float green) {  //ahhhhh, this is slick how he did this!  it's random unless otherwise specified!
    fillColor = strokeColor = color(red, blue, green);
  }

  boolean check (PVector point) {  //the float comes from iPad, the PVector passed in from point cloud drawing
    //this Method is saying, constantly return false, unless either the boundary conditions are met (it gets touch in 3D space
    // or  unless the related iPad control gets touched
    boolean result = false;
    //boundary conditions:
    if (point.x > center.x - size/2 && point.x < center.x + size/2) {
      if (point.y > center.y -size/2 && point.y < center.y + size/2) {
        if (point.z > center.z -size/2 && point.z < center.z + size/2) {
          result = true;
          pointsIncluded ++;  //looks at everypoint and check if it's in the box, and if so, says TRUE and adds that point as a pointIncluded
        }
      }
    }
    return result;
  }

  boolean checkOSC (float osc) {   //maybe a string goes here?  or place each object inside their OSC receiver function.
    boolean result = false;
    if (osc ==1 ) {
      triggered ++; //this could be how we pass this into debouncing strategy bellow.  
      result = true;
    }
    return result;
  }


  void draw() {
    pushMatrix();
    translate (center.x, center.y, center.z);
    //strokeWeight (2);
    fill(red(fillColor), green(fillColor), blue(fillColor), 255 * percentIncluded()); // fill could go here. genius
    stroke(red(fillColor), green(fillColor), blue (fillColor), 255); // full alpha at the end there
    box (size);
    popMatrix ();
  }

  float percentIncluded () {
    return map(pointsIncluded, 0, maxPoints, 0, 1); // wow, so simple so elegant.  thanks Greg!
  }

  boolean currentlyHit () { //  so, if the either the 3D version, or the iPad version is hit, then return true.  
    boolean result = false;
    if (pointsIncluded > threshold) {
      result = true;
    }
    if (triggered > 0) {
      result = true;
    }
    return result;
  }


  boolean isHit() {
    return currentlyHit() && !wasJustHit;
  }

  void clear () {  //clear the variables
    wasJustHit = currentlyHit () ;
    pointsIncluded = 0 ;
    triggered = 0;
  }
}

