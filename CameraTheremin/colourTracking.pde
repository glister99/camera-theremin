void trackColour() {
  float aAvgX = 0;
  float aAvgY = 0;
  float bAvgX = 0;
  float bAvgY = 0;
  int aPixelCount = 0;
  int bPixelCount = 0;
  float prevAavgX = -1;
  float prevAavgY = -1;
  float prevBavgX = -1;
  float prevBavgY = -1;

  pushMatrix();
  scale(-1, 1);
  for (int x = 0; x < cam.width; x++ ) {
    for (int y = 0; y < cam.height; y++ ) {
      
      // colour detection, going through all the pixels on screen
      int pixNo = x + (y * cam.width);
      color currentColour = cam.pixels[pixNo];
      float r1 = red(currentColour);
      float g1 = green(currentColour);
      float b1 = blue(currentColour);

      float r2 = red(trackColourA);
      float g2 = green(trackColourA);
      float b2 = blue(trackColourA);

      float r3 = red(trackColourB);
      float g3 = green(trackColourB);
      float b3 = blue(trackColourB);

      float ad = compareCol(r1, g1, b1, r2, g2, b2); 
      float bd = compareCol(r1, g1, b1, r3, g3, b3);

      // if current col is close enough to trackCol 
      if ((ad < threshold)) {
        float aBlobMaxX = 0;
        float aBlobMaxY = 0;
        float aBlobMinX = cam.width;
        float aBlobMinY = cam.height;

        if (x>aBlobMaxX) {
          aBlobMaxX = x;
        }
        if (x<=aBlobMinX) {
          aBlobMinX = x;
        }
        if (y>aBlobMaxY) {
          aBlobMaxY = y;
        }
        if (y<=aBlobMinY) {
          aBlobMinY = y;
        }
        /* if the new pixel is too far, do not increase pixelCount 
        (currently not working for some unidentified reason)*/
        if (withinBlob(x, y, aBlobMinX, aBlobMaxX, aBlobMinY, aBlobMaxY)) {
          //Assist function, highlight tracking area
          /*fill(trackColourA);
          noStroke();
          ellipse(x-cam.width, y, 1, 1);*/
          aAvgX = aAvgX + x;
          aAvgY = aAvgY + y;
          aPixelCount++;
        }
      }

      if (bd < threshold) {
        float bBlobMaxX = 0;
        float bBlobMaxY = 0;
        float bBlobMinX = cam.width;
        float bBlobMinY = cam.height;

        if (x>bBlobMaxX) {
          bBlobMaxX = x;
        }
        if (x<=bBlobMinX) {
          bBlobMinX = x;
        }
        if (y>bBlobMaxY) {
          bBlobMaxY = y;
        }
        if (y<=bBlobMinY) {
          bBlobMinY = y;
        }


        if (withinBlob(x, y, bBlobMinX, bBlobMaxX, bBlobMinY, bBlobMaxY)) {
          //Assist function, highlight tracking area
          /*fill(trackColourB);
          noStroke();
          ellipse(x-cam.width, y, 1, 1);*/
          bAvgX = bAvgX + x;
          bAvgY = bAvgY + y;
          bPixelCount++;
        }
      }
    }
  }

  if (aPixelCount > 0) { 
    aAvgX = aAvgX / aPixelCount;
    aAvgY = aAvgY / aPixelCount;
    
    //ignore small movements to steady sound output
    if( movementSignificant(prevAavgX, prevAavgY, aAvgX, aAvgY) ){
      // Draw a ellp at the first col
      fill(trackColourA);
      strokeWeight(2);
      stroke(255);
      ellipse(aAvgX-cam.width, aAvgY, 30, 30);
  
      if (scene == "main") {
        float amp = map( aAvgY, 0, height, 1, 0 );
        wave.setAmplitude(amp);
        sat = map (aAvgY, 0, height, 0, 255);
  
        //beam lines
        colorMode(HSB, 360, 255, 70);
        for (int j = 0; j < 50; j++) {
          //stroke((hue-150)+ random(150), sat, 255);
          stroke(trackColourA);
          strokeWeight(2);
          line( aAvgX-cam.width, aAvgY, random(cam.width/2, cam.width)-cam.width, random(cam.height));
        }
        colorMode(RGB, 255, 255, 255);
      }
    }
    prevAavgX = aAvgX;
    prevAavgY = aAvgY;
  }
  if (bPixelCount > 0) { 
    bAvgX = bAvgX / bPixelCount;
    bAvgY = bAvgY / bPixelCount;
    
    //ignore small movements to steady sound output
    if( movementSignificant(prevBavgX, prevBavgY, bAvgX, bAvgY) ){
      // Draw a rect at the second col
      fill(trackColourB);
      strokeWeight(2);
      stroke(255);
      rectMode(CENTER);
      rect(bAvgX-cam.width, bAvgY, 30, 30);
  
      if (scene == "main") {
        
        //map movement on x to C3(130.81) - B5(987.77)
        float freq = map( bAvgX, width, 0, 130.81, 987.77);
        //patching freq to the output should be more elegant than setting freq
        //as a result the sound should be more smooth, attempts have been made but failed
        wave.setFrequency(freq);
        hue = map (bAvgX, 0, width, 0, 360);
        
        colorMode(HSB, 360, 255, 70);
        for (int j = 0; j < 50; j++) {
          //stroke(hue, (sat-150)+random(150), 255);
          stroke(trackColourB);
          strokeWeight(2);
          line(bAvgX-cam.width, bAvgY, random(0, cam.width/2)-cam.width, random(cam.height));
        }
        colorMode(RGB, 255, 255, 255);
      }
    }
    prevBavgX = bAvgX;
    prevBavgY = bAvgY;
  }
  popMatrix();
}

float compareCol(float r1, float g1, float b1, float r2, float g2, float b2) {
  //calculates the difference between tracking col and current col
  float d = (r2-r1)*(r2-r1) + (g2-g1)*(g2-g1) +(b2-b1)*(b2-b1);
  return d;
}

boolean withinBlob(float x, float y, float minX, float maxX, float minY, float maxY) {
  float centreX = (minX + maxX)/2;
  float centreY = (minY + maxY)/2;

  //test distance between a new pixel (x, y) and the blob centre pixel
  int distThreshold = 80;
  float dist = dist(x, y, centreX, centreY);

  if (dist > distThreshold) {
    return false;
  } else {
    return true;
  }
}

boolean movementSignificant(float prevX, float prevY, float x, float y){
  int movementThreshold = 80;
  if(dist(prevX, prevY, x, y) > movementThreshold){
    return true;
  }
  else{
    return false;
  }  
}
