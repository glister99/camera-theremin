/*
  A webcam is required
  Once the sketch starts and shows camera live view, 
  use mouse left click the on-screen image of the first beacon to set the colour tracked as the left hand, 
  right click the image of another beacon to set the colour tracked as the right hand.
*/

//processing sound library causes errors, processing forum official recommended minim
//import minim library for sound
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import processing.video.*;

Capture cam;

Minim       minim;
AudioOutput out;
Oscil       wave;

color trackColourA; 
color trackColourB;
float threshold = 1225;

float hue;
float sat;

String scene;

//for blob objects
//ArrayList<Blob> aBlobs = new ArrayList<Blob>();
//ArrayList<Blob> bBlobs = new ArrayList<Blob>();

void setup() {
  size(5, 5);
  surface.setResizable(true);
  startCam();
  surface.setSize(cam.width, cam.height);
  //alleviate sync issues caused by flipping the video output
  frameRate(cam.frameRate - 10);
  minim = new Minim(this);

  out = minim.getLineOut();
  wave = new Oscil(0, 0.5f, Waves.SINE);
  //patch the wave to output
  wave.patch(out);
  
  trackColourA = -100;
  trackColourB = -100;
}

void draw() {
  cam.read();
  cam.loadPixels();

  //flip the camera
  pushMatrix();
  scale(-1, 1);
  //darken the capture video
  tint(100);
  image(cam, -cam.width, 0);
  popMatrix();

  //improves frame rate slightly, but makes tracking less responsive
  /*if (frameRate>=5) {
    faces = opencvFace.detect();
    detectNose();
  }*/

  // improves frame noticably, causes errors through
  /*if (frameCount % 3 == 0) {
    faces = opencvFace.detect();
    thread("detectNose");
    thread("detectHand");
  }*/
  
  trackColour();
  if((trackColourA != -100)&&(trackColourB != -100)){
    scene = "main";
  }
  
  if(scene == "main"){
    // C4: 261.63Hz; C3: 130.81Hz
    //initialise freq
    boolean freqInitialised = false;
    if(freqInitialised){
      wave.setFrequency(261.63);
      freqInitialised = true;
    }
    
    //waveform
    colorMode(HSB, 360, 255, 70);
  
    stroke(hue, sat, 100);
    strokeWeight(5);
    for (int i = 0; i < out.bufferSize() - 1; i++)
    {
      //try some other shapes
      line( i, (cam.height/2)  - out.left.get(i)*50, i+1, (cam.height/2)  - out.left.get(i+1)*50 );
      //rect(i, height/2, 10,  out.left.get(i)*90);
  }
    colorMode(RGB, 255, 255, 255);
  }
}

void startCam() {
  String[] cameras = Capture.list();
  printArray(cameras);
  
  if(cameras.length > 1) {
    println("Using  " + cameras[1]); 
    cam = new Capture(this, cameras[1]);
    cam.start();  
    while(!cam.available()){ 
      print();
    }
    cam.read();
    cam.loadPixels();
  } 
  else{
    println("No camera detected or there's no available camera!");
    exit();
  }
}

void mousePressed() {
  //caliberate colour to conpensate auto white balance, also provides flexibility
  //left click to setup colour for volume hand
  //right click to setup colour for pitch hand
  int pix = (mouseY*cam.width) - mouseX;
  if (mouseButton == LEFT){
    trackColourA = cam.pixels[pix];
  }
  else if (mouseButton == RIGHT){
    trackColourB = cam.pixels[pix];
  }
  //alternative: trackColour = get(-mouseX, mouseY);
}
