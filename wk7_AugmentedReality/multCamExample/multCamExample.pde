import processing.video.*; 
import hypermedia.video.*;

OpenCV ocv1;
OpenCV ocv2;
Capture myCapture; 
Capture myCapture2; 
String[] captureDevices; 
int threshold = 80;

void setup() 
{ 
  size(640, 780); 
  println (Capture.list()); 
  captureDevices = Capture.list(); 
  
  myCapture = new Capture(this, width/2, height/3, 30); 
  myCapture.settings();  
  
  myCapture2 = new Capture(this, width/2, height/3, 30); 
  myCapture2.settings(); 
  
  ocv1 = new OpenCV( this );   
  ocv1.allocate(width/2,height/3);
  
  ocv2 = new OpenCV( this );        
  ocv2.allocate(width/2,height/3);
 
} 
 
void draw() { 
  if (myCapture.available()) { 
    myCapture.read(); 
    ocv1.copy(myCapture); 
    ocv1.blur(OpenCV.MEDIAN, 13); 
    ocv1.convert( GRAY );
    image(ocv1.image(),0,0);   
    image( ocv1.image(OpenCV.MEMORY), 0, 1*height/3 ); // image in memory
    ocv1.absDiff();
    ocv1.threshold(threshold);
    image( ocv1.image(OpenCV.GRAY), 0, 2*height/3 ); // absolute difference image
  
    ocv1.copy(myCapture);  
    ocv1.blur(OpenCV.MEDIAN, 13); 
  } 
  if (myCapture2.available()) { 
    myCapture2.read(); 
    ocv2.copy(myCapture2); 
    ocv2.blur(OpenCV.MEDIAN, 13); 
    ocv2.convert( GRAY );
   image(ocv2.image(),width/2,0);   
   image( ocv2.image(OpenCV.MEMORY), width/2, 1*height/3 ); // image in memory
   ocv2.absDiff();
   ocv2.threshold(threshold);
   image( ocv2.image(OpenCV.GRAY), width/2, 2*height/3 ); // absolute difference image
  
   ocv2.copy(myCapture2);  
   ocv2.blur(OpenCV.MEDIAN, 13); 
  } 
}

void keyPressed() {
    if ( key==' ' ){ 
      if (myCapture.available()) { 
        ocv1.remember(1,2); //SOURCE,FLIP_HORIZONTAL
      }
      if (myCapture2.available()) { 
      ocv2.remember(1,2); //SOURCE,FLIP_HORIZONTAL
    }}}
    
public void stop() {
    ocv1.stop();
    ocv2.stop();
    super.stop();
}
 
