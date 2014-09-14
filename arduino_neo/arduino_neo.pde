import processing.serial.*;

Serial port;
int pixel = 0;
int cur = 0;
float r = 0;
float g = 0;
float b = 0;

void setup(){
  port = new Serial(this, Serial.list()[5], 38400);
  
}

void draw(){
  /*if(cur <200){
    port.write("B30");
  }*/
  pixel ++;
  if (pixel > 15) pixel = 0;
  cur++;
  //if(cur > 255) cur = 0;
  r = sin(.03 * cur) * 128 + 128;
  g = sin(.03 * cur + 2) * 128 + 128;
  b = sin(.03 * cur + 4) * 128 + 128;
       
  String cmd = String.format("C%s,%s,%s,%s", 15-pixel, int(r), int(g), int(b));
  //println(cmd);
  port.write(cmd);
  //delay(10);
  //String input = port.readString();
  //println(input);
  
}
