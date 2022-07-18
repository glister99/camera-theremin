//blob class is not used in the current version of code

class Blob{
  //colour for the cursur
  color col;
  // boundary used to separate blobs and background elements with similar colours
  float maxX;
  float minX;
  float maxY;
  float minY;
  
  Blob(color colour, float x, float y) {
    col = colour;
    maxX = x;
    minX = x;
    maxY = y;
    minY = y;
  }
  
  boolean detectWithin(float x, float y){
    float centreX = (minX + maxX)/2;
    float centreY = (minY + maxY)/2;
  
    //test distance between a new pixel (x, y) and the blob centre at the moment
    int distThreshold = 10;
    float dist = dist(x, y, centreX, centreY);
  
    if (dist > distThreshold) {
      //not within
      return false;
    } else {
      //within
      return true;
    }
  }
  
  void drawCursor(){
    stroke(0);
    fill(col);
    strokeWeight(2);
    rect(minX, minY, (maxX-minX), (maxY-minY));
  }
  
  void drawContour(){
    //commect all the pixels that are not surrounded by pixel with the same tracking colour
  }
}
