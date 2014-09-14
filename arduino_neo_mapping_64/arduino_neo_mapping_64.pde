import processing.serial.*;
import processing.video.*;

Capture video;

Serial port;
int count = 0;
int pixel = 0;
int cur = 0;
float red = 0;
float green = 0;
float blue = 0;
PImage img;
String lastCommand;
int imgX = 0;
int imgY = 0;
float twoPI = 2 * PI;
int d = 200;
int r = d/2;
int centerX = r;
int centerY = r;
float circ = d * PI;
int steps = 64;



void setup(){
  port = new Serial(this, Serial.list()[5], 57600);
  size(640,480);
  shapeMode(CENTER);
  centerX = 640/2;
  centerY = 480/2;
  
  //println(Capture.list());
  //String[] cameras = Capture.list();
  //println(cameras);
  video = new Capture(this,640,480,"Logitech Camera",30);
  video.start();
  
}

void updateNeo(){

  float x, y;
  int j = 0;
  int angle = 0;
  port.write('M');
  for(int i=0;i<steps;i++){
    
    angle += 360/steps;
    
    x = centerX + (r * cos(radians(angle)));
    y = centerY + (r * sin(radians(angle)));
    
    
    /*if(i < 4){
      fill(color(#FF0000));
      ellipse(x,y,30,30);
    }*/
    color clr = color(get( int(x), int(y) ));
    
    
    fill( clr );
    stroke(clr);
      ellipse( x, y, 25, 25 );
    
    if(count % 1 == 0){
      //first byte in a color is alpha, which we don't both sending over
      port.write((clr >> 16) & 0xFF); // second is red
      port.write((clr >> 8) & 0xFF); // third is green
      port.write(clr & 0xFF); //fourth is blue
    }
    /*red = red(clr);
    green = green(clr);
    blue = blue(clr);
    
    String cmd = String.format("A%s,%s,%s,%s", j++, int(red), int(green), int(blue));
    if(!cmd.equals(lastCommand)){
      port.write(cmd);
      lastCommand = cmd;
    }
    */
    //println(red(clr));
    
    
  }
  count++;
  //println(sb.toString());
  //port.write(sb.toString());
}


void draw(){
  PImage img = getReversePImage(video);
  img = avgImage(img);
  image(img,0,0);
  updateNeo();
}

PImage[] images = new PImage[10];
int imageIndex = 0;

PImage avgImage(PImage img){
  PImage ret = new PImage(img.width, img.height);
  images[imageIndex++] = img;
  if(imageIndex == images.length){
    imageIndex = 0;
  }
  
  if(count > images.length){
    for( int i=0; i < img.width; i++ ){
      for(int j=0; j < img.height; j++){
        
        color c = img.get(i,j);
        float tr = 0;
        float tg = 0;
        float tb = 0;
        
        //give a little extra weight to the current
        int weight = images.length / 2;
        for(int m=0;m<weight;m++){
          tr += red(c);
          tg += green(c);
          tb += blue(c);
        }
        for(int k=0;k<images.length;k++){
          c = images[k].get(i,j);
          tr += red(c);
          tg += green(c);
          tb += blue(c);
        }
        tr = tr/(images.length+weight);
        tg = tg/(images.length+weight);
        tb = tb/(images.length+weight);
        
        c = color(tr,tg,tb);
        ret.set( i, j, c);
      }
    }
    return ret;
  }else{
   return img;
  }
}

public PImage getReversePImage( PImage image ) {
 PImage reverse = new PImage( image.width, image.height );
 for( int i=0; i < image.width; i++ ){
  for(int j=0; j < image.height; j++){
   reverse.set( image.width - 1 - i, j, image.get(i, j) );
  }
 }
 return reverse;
}

void captureEvent(Capture v){
  v.read();
}

