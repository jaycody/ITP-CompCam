
/*jason stephens
 Proprioception Enhancement Tool (PET)
 Computational Cameras - Midterm - ITP
 
 -Infinite thanks to Greg Borenstein for his detailed description of this process in his book Making Things See-
 
 Possible PET uses:  
 1. a system and method for improving proprioception
 and encouraging healthy body mechanics in massage therapists through realtime self-evaluation from multiple perspectives.
 2. a system for inducing out-of-body experiences in massage therapy clients able to view themselves
 from an out-of-body virutal camera perspective with nearly infinite degrees of freedom.
 
 SETUP:  A Microsoft Kinect  is placed 6 feet above the front left corner of a massage table. 
 A MacBookPro running Processing and iPad running touchOSC commnicate through an adhoc peer to peer wireless
 connection.  The iPad uses touchOSC to send Open Sound Control information to the Mac  An applicatin written in Processing
 listens for OSC messages that control the variables of the Kinect.  From the depth information, the software creates point clouds,
 point cloud with RGB data, while theKinect's standard camera creates 2D RGB images.
 
 
NEXT:
 ____create hotspot class
 ____establish edge detection with iPad input
 ____add hotspots toggle to see in in 3D
 ____create LookAt with Peasy
 ____enable camera controls (gimble)
 ____map gimble controls to z values of iPad?
 ____Look at Center of Gravity
 ____toggle vectors to camera
 ____creat a 3D place holder for table as reference.
 
 ____fix zoom
 ____add snapshot
 ____draw the floor (see UserScene3D example)
 ____remove background leaving only user and massage table.
 
 FUTURE FUNCTIONALITY:
 ____create Kinect switching
 ____hotspot above therpists head
 ____where toggling between Kinects, return to previous camera angle
 
 
 */
import processing.opengl.*;
import SimpleOpenNI.*;
import peasy.*;
import oscP5.*;  // ipad action
import netP5.*;

SimpleOpenNI kinect1;
PeasyCam pCam;
OscP5 oscP5;

PeasyDragHandler ZoomDragHandler;

Hotspot hotspotF; //front
Hotspot hotspotFR;
Hotspot hotspotMR;
Hotspot hotspotBR;
Hotspot hotspotB;  //back
Hotspot hotspotBL;// front left
Hotspot hotspotML; //middle left
Hotspot hotspotFL; //backleft

//iPad recepticles
//controls peasy.rotateY
float lookLR = 0; //  Look Left/Right = /1/lookLR :  range 0-1 incoming 
float pLookLR =0; // previous val, so that Peasy aint flying around
float rcvLookLR = 0; //takes the value directly from the oscP5 event
//controls peasy.rotateX
float lookUD = 0; // Look up down.  gonna change incoming range to -6,6 (or close to -2PI,2PI)
float pLookUD = 0;
float rcvLookUD = 0; //need a repository from incoming osc messages
//controls peasy.rotateZ
float tiltLR = 0;
float pTiltLR = 0;
float rcvTiltLR = 0;

float zoomIO = 0; //
float pZoomIO = 0;
float rcvZoomIO = 0;
float pAmountZoomIO = 0;

float moveLR = 0;
float pMoveLR = 0;
float rcvMoveLR = 0;

float moveUD = 0;
float pMoveUD = 0;
float rcvMoveUD = 0;

float reset = 0;
float pCamReset = 0;

boolean setMirror = false;
boolean pSetMirror= false;

float swCam = 0; //DEBOUNCING !!
float pSwCam = 0;
boolean wasOn = true;
boolean isOn = true;

int lastKeyPress = 1;  //default start mode 1 = drawPointCloud
PImage rgbImage;

color[] userColors = { 
  color(255, 0, 0), color(0, 255, 0), color(255, 255, 100), color(255, 255, 0), color(255, 0, 255), color(250, 200, 255)
};
color[] userCoMColors = { 
  color(255, 100, 255), color(255, 255, 100), color(255, 100, 255), color(255, 0, 100), color(255, 100, 255), color(100, 255, 255)
};



void setup () {
  size (1024, 768, OPENGL);
  smooth();

  //start oscP5 listening for incoming messages at port 8000
  oscP5 = new OscP5(this, 8000);
  pCam = new PeasyCam(this, 0, 0, -900, 1000); //initialize peasy
  ZoomDragHandler = pCam.getZoomDragHandler();//getting control of zoom action
  pCam.setWheelScale(1);
  //pCam.setMinimumDistance(0);
  //pCam.setMaximumDistance(6000);

  kinect1 = new SimpleOpenNI (this);  //initialize 1 kinect
  kinect1.setMirror(true);//disable mirror and renable with set mirror button
  kinect1.enableDepth();

  // enable skeleton generation for all joints
  kinect1.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  // enable the scene, to get the floor
  kinect1.enableScene();

  //for color alignment
  kinect1.enableRGB();
  kinect1.alternativeViewPointDepthToImage();

  hotspotB = new Hotspot (-1300, 0, 2000, 200);
  hotspotBL = new Hotspot (-950, -600, 2000, 200);
  hotspotML = new Hotspot (0, -600, 800, 200);
  hotspotFL = new Hotspot (950, -600, 2000, 200);
  hotspotF = new Hotspot (1300, 0, 2000, 100);
  hotspotFR = new Hotspot (750, 600, 1500, 100);
  hotspotMR = new Hotspot (0, 600, 1500, 100);
  hotspotBR = new Hotspot (-1000, 800, 1500, 100);
}

// create function to recv and parse oscP5 messages
void oscEvent (OscMessage theOscMessage) {

  String addr = theOscMessage.addrPattern();  //never did fully understand string syntaxxx
  float val = theOscMessage.get(0).floatValue(); // this is returning the get float from bellow

  if (addr.equals("/1/lookLR")) {  //remove the if statement and put it in draw
    rcvLookLR = val; //assign received value.  then call function in draw to pass parameter
  }
  else if (addr.equals("/1/lookUD")) {
    rcvLookUD = val;// assigned receive val. prepare to pass parameter in called function: end of draw
  }
  else if (addr.equals("/1/tiltLR")) {
    rcvTiltLR = val;// assigned received val from tilt and prepare to pass in function
  }
  else if (addr.equals("/1/zoomIO")) {
    rcvZoomIO = val;
  }
  else if (addr.equals("/1/moveLR")) {
    rcvMoveLR = val;
  }
  else if (addr.equals("/1/moveUD")) {
    rcvMoveUD= val;
  }
  else if (addr.equals("/1/reset")) {
    reset = val;
  }
  else if (addr.equals("/1/setMirror")) {
    setMirror = true;
  }
  else if (addr.equals("/1/showCamera")) {
    swCam = val;
  }

  //left column green buttons
  else if (addr.equals("/1/virtualCamera")) {
    lastKeyPress = 1;
  }
  else if (addr.equals("/1/virtualCameraRGB")) {
    lastKeyPress = 2;
  }
  else if (addr.equals("/1/RGB")) {
    lastKeyPress = 3;
  }
  else if (addr.equals("/1/skeleton")) {
    lastKeyPress = 4;
  }

  else if (addr.equals("/1/hotspotB")) {
    hotspotB.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotBL")) {
    hotspotBL.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotML")) {
    hotspotML.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotFL")) {
    hotspotFL.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotF")) {
    hotspotF.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotFR")) {
    hotspotFR.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotMR")) {
    hotspotMR.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
  else if (addr.equals("/1/hotspotBR")) {
    hotspotBR.checkOSC(val) ; //check out this vector, bro IF Val = 1, then isHit returns positive
  }
}

void draw() {
  //2nd part of Shiffman's suggestion for starting up full screen in second monitor
  //frame.setLocation(0, 0);  //set this to -1024 if secondary monitor is on the left

  background (0);
  kinect1.update();

  rotateX(PI); //rotate along the xPole 180 degrees
  //stroke(255);

  //__________________________left Green Column Camera PushButtons
  // do 1
  if (lastKeyPress==1) {
    drawPointCloud();
  }

  // do 2
  if (lastKeyPress==2) {
    drawRealWorldDepthMap();
  }

  // do 3
  if (lastKeyPress ==3) {
    drawRGB();
  }

  // do 4
  if (lastKeyPress ==4 ) {
    drawSkeleton();
  }
  //_______________________________leftGreen Column Camera PushButtons



  //_________________________
  //here come the hotspots to draw
  hotspotB.draw(); 
  if (hotspotB.isHit()) {
    pCam.lookAt(hotspotB.center.x, hotspotB.center.y *-1, hotspotB.center.z *-1, 400, 1500);
    //x,y,z | then HOW CLOSE, then duration to get there
  }
  hotspotB.clear();

  //_________________________
  //here come the hotspots to draw
  hotspotBL.draw(); 
  if (hotspotBL.isHit()) {
    pCam.lookAt(hotspotBL.center.x, hotspotBL.center.y *-1, hotspotBL.center.z *-1, 400, 1500);
    //x,y,z | then HOW CLOSE, then duration to get there
  }
  hotspotBL.clear();

  hotspotML.draw(); 
  if (hotspotML.isHit()) {
    pCam.lookAt(hotspotML.center.x, hotspotML.center.y *-1, hotspotML.center.z *-1, 400, 1500);
    //x,y,z | then HOW CLOSE, then duration to get there
  }
  hotspotML.clear();


  hotspotFL.draw(); 
  if (hotspotFL.isHit()) {
    pCam.lookAt(hotspotFL.center.x, hotspotFL.center.y *-1, hotspotFL.center.z *-1, 400, 1500);
    //x,y,z | then HOW CLOSE, then duration to get there
  }
  hotspotFL.clear();


  hotspotF.draw(); 
  if (hotspotF.isHit()) {
    pCam.lookAt(hotspotF.center.x, hotspotF.center.y *-1, hotspotF.center.z *-1, 400, 1500);
    //x,y,z | then HOW CLOSE, then duration to get there
  }
  hotspotF.clear();


  hotspotFR.draw(); 
  if (hotspotFR.isHit()) {
    pCam.lookAt(hotspotFR.center.x, hotspotFR.center.y *-1, hotspotFR.center.z *-1, 400, 1500);
    //x,y,z | then HOW CLOSE, then duration to get there
  }
  hotspotFR.clear();


  hotspotMR.draw(); 
  if (hotspotMR.isHit()) {
    pCam.lookAt(hotspotMR.center.x, hotspotMR.center.y *-1, hotspotMR.center.z *-1, 400, 1500);
    //x,y,z | then HOW CLOSE, then duration to get there
  }
  hotspotMR.clear();


  hotspotBR.draw(); 
  if (hotspotBR.isHit()) {
    pCam.lookAt(hotspotBR.center.x, hotspotBR.center.y *-1, hotspotBR.center.z *-1, 400, 1500);
    //x,y,z | then HOW CLOSE, then duration to get there
  }
  hotspotBR.clear();


  //___TOGGLE SWITCHES
  //___________________
  //SET MIRROR DEBOUNCED TOGGLR:  if setMirror goes HIGH, then toggle mirror  
  if (setMirror !=pSetMirror) {
    if (setMirror) {
      kinect1.setMirror(!kinect1.mirror());
    }
  }
  pSetMirror = setMirror;
  setMirror = false;  //clear the boolean
  //_________________

  //_______
  //SHOW CAMERA DEBOUNCE TOGGLE:  
  //Please take picture of these few lines of code (3 hours easy);
  //4 variables needed to debounce a pushbutton used to toggle...
  if (swCam==1 && (swCam != pSwCam)) {
    if (wasOn) {
      isOn = false;
      wasOn =isOn;
    }
    else if (wasOn == false) {
      isOn = true;
      wasOn = isOn;
    }
  }
  pSwCam = swCam;

  if (isOn) {
    kinect1.drawCamFrustum();
  }
  //__________________
  //________________
  //"RESET CAMERA" PUSH BUTTON
  //ahhhh, this debounce works.  placed after the formation of the point cloud
  //also made a difference with the flicker
  //reset cam position but only if we need to
  if (reset != pCamReset) {
    if (reset == 1) {
      pCam.reset(2000); //only move cam if we need to
    }
  }
  pCamReset = reset;
  //________________

  //++CALL FUNCTIONS++++++++_____________________________________
  peasyVectors(); //function to get PVector info for position and look at.



  calcLookLR(rcvLookLR);
  calcLookUD(rcvLookUD);
  calcTiltLR(rcvTiltLR);

  calcZoomIO(rcvZoomIO);  //going to the drag Handler

  calcMoveLR(rcvMoveLR);
  calcMoveUD(rcvMoveUD);

  print("rcvLookLR = " + rcvLookLR);
  print(" rcvLookUD = " + rcvLookUD);
  println(" rcvTiltLR = " + rcvTiltLR);
  print("rcvZoomIO = " + rcvZoomIO);
  print(" rcvMoveLR = " + rcvMoveLR);
  println(" rcvMoveUD = " + rcvMoveUD);
}//end draw

//defining the functions for rotations around Y_Pole
void calcLookLR (float v) {
  lookLR = v;
  float amountLookLR = map(lookLR - pLookLR, -1, 1, -2*PI, 2*PI);
  pCam.rotateY (amountLookLR);
  print("aLookLR = " + amountLookLR);
  pLookLR = lookLR;
}
//+++++DEFINE FUNCTIONS FOR ROTATIONS around Z_Pole
void calcLookUD(float v) {  //receive from fucntion calling at end of draw
  lookUD = v;
  float amountLookUD = map(lookUD-pLookUD, -1, 1, -2 *PI, 2*PI);  //giving one rotation each direction
  pCam.rotateX(amountLookUD);
  print (" LookUD = " + amountLookUD);
  pLookUD = lookUD;// resetting the acceleration so it's not additive.  start at zero difference
}
//++++++DEFINE FUNCTION FOR TILT
void calcTiltLR (float v) {
  tiltLR = v;
  float amountTiltLR = map (tiltLR-pTiltLR, -1, 1, PI, -PI);
  pCam.rotateZ(amountTiltLR);
  println (" aTiltLR = " + amountTiltLR);
  pTiltLR = tiltLR;
}
//_____DEFINE FUNCTION FOR ZOOM
void calcZoomIO (float v) {
  zoomIO = v;
  //float [] nowLookAt;
  //nowLookAt = pCam.getLookAt();
  //float zLookAt = map (zoomIO, -1,1,-3000,3000);
  //pCam.lookAt(nowLookAt[0], nowLookAt[1], nowLookAt[2] + zLookAt);  //ideally this will add or substract from wherever we currently are

  float amountZoomIO = map (zoomIO, -1, 1, -10, 10); //ws zoomIO only and -10,10
  ZoomDragHandler.handleDrag(amountZoomIO, amountZoomIO); // (was amountZoomIo, zooomIo
  float pAmountZoomIO = amountZoomIO;
  pZoomIO=zoomIO;


  //pCam.setDistance(amountZoomIO); //distance from looked at point.  i think this distance no differen
  double d = pCam.getDistance();// how far away is look-at point
  print("dist_lookAt = " +d);
  // print(" aZoomIO = " + amountZoomIO);
  //println(" pAZoomIO = " + pAmountZoomIO);
}
void calcMoveLR (float v) {
  moveLR = v;
  double amountMoveLR = map (moveLR-pMoveLR, -1, 1, 5000, -5000);  //camera.pan(double dx, double dy);
  pCam.pan(amountMoveLR, 0);  // y =0 because we're only moving on the x-axis.
  print(" aMoveLR = " + amountMoveLR);
  pMoveLR = moveLR;
}

void calcMoveUD (float v) {
  moveUD = v;
  double amountMoveUD = map (moveUD-pMoveUD, -1, 1, 5000, -5000);
  pCam.pan(0, amountMoveUD);
  pMoveUD = moveUD;
  println(" aMoveUD = " + amountMoveUD);
}




void peasyVectors() {
  float[] pCamPosition; 
  float[] pCamLookAt;
  pCamPosition = pCam.getPosition(); 
  pCamLookAt = pCam.getLookAt(); 
  PVector pCamPos = new PVector(pCamPosition[0], pCamPosition[1], pCamPosition[2]);
  PVector pCamLook = new PVector(pCamLookAt[0], pCamLookAt[1], pCamLookAt[2]);
  print("pCamPos = " + pCamPos.x + " " + pCamPos.y + " " + pCamPos.z);
  println(" pCamLook = " + pCamLook.x +" " + pCamLook.y +" " + pCamLook.z);
}


// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}




void drawRealWorldDepthMap() {

  PImage rgbImage = kinect1.rgbImage(); // jacked this line from the draw.  hope it works wrapped up in this method.
  // Draw RealWorld Depth Map
  PVector[] depthPoints = kinect1.depthMapRealWorld();
  // don't skip any depth points
  for (int i = 0; i < depthPoints.length; i+=2) {
    //original increment of for loop counter set to 1
    PVector currentPoint = depthPoints[i];
    //    // set the stroke color based on the color pixel
    stroke(rgbImage.pixels[i]);
    point(currentPoint.x, currentPoint.y, currentPoint.z);
  }
}

//_____________________Function for Drawing the Point Cloud "Virtual Camera"
void drawPointCloud() {
  ////  //____DRAW POINT CLOUD____
  PVector [] depthPoints1 = kinect1.depthMapRealWorld(); //returns an array loads array
  for (int i = 0; i<depthPoints1.length; i+=3) {
    PVector currentPoint = depthPoints1 [i]; //extract PVector from this location and store it locally
    point (currentPoint.x, currentPoint.y, currentPoint.z);
  }

  //just go ahead and call the drqw users here.  Are you really going to want to have the option of callling this separate
  drawUsers();
}

//____DRAW USERS

void drawUsers() {
  int[]   depthMap = kinect1.depthMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;

  int userCount = kinect1.getNumberOfUsers();
  int[] userMap = null;
  if (userCount > 0) {
    userMap = kinect1.getUsersPixels(SimpleOpenNI.USERS_ALL);
  }

  for (int y=0;y < kinect1.depthHeight();y+=steps)
  {
    for (int x=0;x < kinect1.depthWidth();x+=steps)
    {
      index = x + y * kinect1.depthWidth();
      if (depthMap[index] > 0)
      { 
        // get the realworld points
        realWorldPoint = kinect1.depthMapRealWorld()[index];

        // check if there is a user
        if (userMap != null && userMap[index] != 0)
        {  // calc the user color
          int colorIndex = userMap[index] % userColors.length;
          stroke(userColors[colorIndex]);
        }
        else
          // default color

          stroke(70); 

        point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);

        //here come the hotspots, if we want to use them to trigger look at points
        // CHECK -> DRAW -> isHIT? -> IF YES, lookAT -> CLEAR
        hotspotB.check(realWorldPoint) ; //check out this vector, bro
      }
    }
  }

  drawCenterOfMass (userCount);
}

void drawCenterOfMass (int userCount) {
  // draw the center of mass
  PVector pos = new PVector();
  pushStyle();
  strokeWeight(15);
  for (int userId=1;userId <= userCount;userId++)
  {
    kinect1.getCoM(userId, pos);

    stroke(userCoMColors[userId % userCoMColors.length]);
    point(pos.x, pos.y, pos.z);
  }  
  popStyle();
}


void drawRGB() {
  PImage rgbImage = kinect1.rgbImage(); // jacked this line from the draw.  hope it works wrapped up in this method.
  // Draw RealWorld Depth Map
  image(rgbImage, 0, 0);
}


void drawSkeleton () {
}


//Shiffman's advice for starting full screen undecorated windows in second monitor
//void init() { 
//  frame.removeNotify();
// frame.setUndecorated(true);
// frame.addNotify();
//  super.init();
//}
//then in draw add:  frame.setLocation(0,0); // to place an undecorated screen at origin
//or in the case of second monitor (1024, 0) if my primary screen is (1024,768)

