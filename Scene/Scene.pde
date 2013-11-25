class MeleScene{
  ArrayList<Particle> particles = new ArrayList<Particle>();

  MeleScene(){
    size(800,800,P2D);
    colorMode(RGB, 360, 100, 100, 100);
    background(0);
  }
  
  Particle particle(){
    Particle particle = new Particle();
    particles.add(particle);
    return particle;
  }
  
  void draw(){
    background(0);
    
    ArrayList<Particle> dead = null;
    
    for(Particle particle : particles){
      particle.update();
      if(!particle.life.isAlive()){
        if(dead == null){
          dead = new ArrayList<Particle>();
        }
        dead.add(particle);
      }
    }
    
    if(dead != null){
      for(Particle particle : dead){
        particles.remove(particle);
      }
    }
    
    for(Particle particle : particles){
      particle.render();
    }
  }
}

class Particle {
  Life life;
  Size size;
  Location location;
  Color clr;
  Emitter emitter;
  int depth;
  Particle parent;
  int siblingNumber = 1;
  
  Particle depth(int depth){
    this.depth = depth;
    return this;
  }
  
  Particle siblingNumber(int num){
    this.siblingNumber = num;
    return this;
  }
  
  Particle clr(Color clr){
    this.clr = clr;
    return this;
  }
  
  Particle parent(Particle parent){
    this.parent = parent;
    return this;
  }
  
  Particle size(Size size){
    this.size = size;
    return this;
  }
  
  Particle location(Location location){
    this.location = location;
    return this;
  }
  
  Particle life(Life life){
    this.life = life;
    return this;
  }
  
  Particle emitter(Emitter emitter){
    this.emitter = emitter;
    return this;
  }

  void update() {
    
    if(location != null){
      location.update(this);
    }
    
    if(size != null){
      size.update(this);
    }
    
    if(clr != null){
      clr.update(this);
    }
    
    if(life != null){
      life.update(this);
    }
    
    if(emitter != null){
      emitter.update(this);
      emitter.updateParticles(this);
    }
    
  }

  void render() {
    float opacity = max(min(255, life.lived), 0);
    stroke(clr.clr, opacity);
    fill(clr.clr, opacity);
    ellipse(location.location.x, location.location.y, size.size, size.size);
    if(emitter != null){
      emitter.renderParticles(this);
    }
  }
}

class Size<T extends Size>{
  int size;
  int initialSize;
  
  T init(int initialSize){
    this.initialSize = initialSize;
    this.size = initialSize;
    return (T)this;
  }
  
  void update(Particle p){}
  
  T clone(){
    Size ret = new Size();
    ret.initialSize = initialSize;
    ret.size = size;
    return (T)ret;
  }
}

class Location<T extends Location>{
  PVector location;
  PVector velocity;
  PVector accel;
  
  T velocity(float x, float y){
    this.velocity = new PVector(x,y);
    return (T)this;
  }
  
  T accel(float x, float y){
    this.accel = new PVector(x,y);
    return (T)this;
  }
  
  T init(float x, float y){
    this.location = location = new PVector(x,y);
    return (T)this;
  }
  
  void update(Particle p){}
  
  T clone(){
    return (T)new Location<T>().init(location.x, location.y).velocity(velocity.x, velocity.y).accel(accel.x, accel.y);
  }
}

class Color<T extends Color>{
  color clr;
  
  T hsba(int h, int s, int b, int alpha){
    this.clr = color(h,s,b,alpha);
    return (T)this;
  }
  
  void update(Particle p){}
  
  T clone(){
    Color ret = new Color();
    ret.clr = clr;
    return (T)ret;
  }
}

class Life<T extends Life>{
  int lived = 0;
  int span;
  
  T span(int span){
    this.span = span;
    return (T)this;
  }
  
  boolean isAlive(){
    return lived < span;
  }
  
  void update(Particle p){
    lived++;
  }
  
  T clone(){
    Life ret = new Life();
    ret.span = span;
    return (T)ret;
  }
}

class ImmortalLife extends Life{
  
  ImmortalLife(){
    span = 100;
    lived = 99;
  }
  
  Life span(int span){
    return this;
  }
  
  boolean isAlive(){
    return true;
  }
  
  void update(Particle p){
  }
  
  ImmortalLife clone(){
    ImmortalLife ret = new ImmortalLife();
    return ret;
  }
}

class LinearLocation extends Location<LinearLocation>{
  
  public void update(Particle p){
    if(velocity != null){
      if(accel != null){
        velocity.add(accel);
      }
      location.add(velocity);
    }
  }
  
  LinearLocation clone(){
    return new LinearLocation().init(location.x, location.y).velocity(velocity.x, velocity.y).accel(accel.x, accel.y);
  }
  
};

class Rotation<T extends Rotation>{
  float angle = 0;
  
  public void update(Emitter p, int frame, int step, int total){
    
  }
  
  T angle(float angle){
    this.angle = angle;
    return (T)this;
  }
  
  T clone(){
    Rotation ret = new Rotation();
    ret.angle = angle;
    return (T)ret;
  }
}


class Emitter {
  
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  Life life;
  Size size;
  Location location;
  Color clr;
  int streams = 1;
  Rotation rotation;
  
  Emitter clr(Color clr){
    this.clr = clr;
    return this;
  }
  
  
  Emitter rotation(Rotation rotation){
    this.rotation = rotation;
    return this;
  }
  
  Emitter size(Size size){
    this.size = size;
    return this;
  }
  
  Emitter location(Location location){
    this.location = location;
    return this;
  }
  
  Emitter life(Life life){
    this.life = life;
    return this;
  }
  
  Emitter streams(int streams){
    this.streams = streams;
    return this;
  }

  void update(Particle parent) {
    
    if (frameCount % 1 == 0) {
      addParticles(parent);
    }
  }

  void addParticles(Particle parent) {
    
    for (int i=0; i < streams; i++) {
      rotation.update(this, frameCount, i, streams);
      Location l = location.clone().init(parent.location.location.x, parent.location.location.y);
      l.velocity.rotate(rotation.angle);
      particles.add(
        new Particle()
        .siblingNumber(i)
        .depth(parent.depth+1)
        .parent(parent)
        .clr(clr.clone())
        .location(l)
        .emitter(parent.depth < 0?this.clone():null)
        .size(size.clone())
        .life(life.clone()));      
    }
  }
  
  void updateParticles(Particle parent) {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      if (!p.life.isAlive()) {
        particles.remove(i);
      }
    }
  }
  
  void renderParticles(Particle parent) {
    for(Particle particle : particles){
      particle.render();
    }
  }
  
  Emitter clone(){
    return new Emitter().clr(clr.clone())
                               .size(size.clone())
                               .life(life.clone())
                               .streams(streams);
  }
}



/********/

class MyLocation extends Location<MyLocation>{
  
  public void update(Particle p){
    
    float angle = velocity.heading();
    float x = sin(angle);
    float y = cos(angle);
    this.velocity(x, y);
    //location.add(velocity);
    location.rotate(velocity.heading());
  }
  
  MyLocation clone(){
    return new MyLocation().init(location.x, location.y).velocity(velocity.x, velocity.y).accel(accel.x, accel.y);
  }
};

class MySize extends Size<MySize>{
  
  public void update(Particle p){
    float remainingLife = p.life.span - p.life.lived;
    float percentageOfLifeLeft = remainingLife / (float)p.life.span;
    this.size = int(initialSize * percentageOfLifeLeft);
  }
  
  MySize clone(){
    MySize ret = new MySize();
    ret.initialSize = initialSize;
    ret.size = size;
    return ret;
  }
};

//FIXME - does not work as intended.
class MyRotation extends Rotation<MyRotation>{
  
  public void update(Emitter p, int frame, int step, int total){
    
    float rotation = PI*sin(radians(frame)/2);
    angle = rotation + (step*TWO_PI/total);
  }
  
  MyRotation clone(){
    MyRotation ret = new MyRotation();
    ret.angle = angle;
    return ret;
  }
};

class MyParticle extends Particle{
  
  MyParticle(int x,int y){
    super();
    
    this.clr(new Color().hsba(320,20,50, 20))
        .location(new LinearLocation().init(x,y)
                                    .velocity(0,-.01)
                                    .accel(0,0))
        .size(new Size().init(40))
        .emitter(new Emitter().clr(new Color().hsba(320,20,50, 100))
                              .location(new LinearLocation().init(0,0).velocity(0,5).accel(0,.75))
                              .size(new MySize().init(25))
                              .life(new Life().span(40))
                              .streams(8)
                              .rotation(new MyRotation()))
        .life(new ImmortalLife());
  }
}

MeleScene scene;

void setup() {
  scene = new MeleScene();
  int quarter = width/4;
  for(int i=1;i<4;i++){
    scene.particles.add(new MyParticle(i*quarter, 70));
    scene.particles.add(new MyParticle(i*quarter, 70+quarter/2));
  }
}

void draw() {
  scene.draw();
}
