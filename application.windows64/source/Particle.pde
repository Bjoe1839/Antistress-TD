class Particle {
  int x, y;
  int lifespan;
  PImage img;

  Particle(int x_, int y_) {
    x = x_;
    y = y_;
    lifespan = 50;
    img = particle;
  }

  void move() {
    lifespan--;
    y--;
  }

  void display() {
    //toner mere og mere ud jo mindre lifespan bliver
    int alfa = int(map(lifespan, 0, 50, 0, 255));

    tint(255, alfa);
    image(img, x, y);
    noTint();
  }
}


class Explosion extends Particle {
  int size;
  
  Explosion(int x, int y, int size_) {
    super(x, y);
    size = size_;
    img = explosion.copy();
    img.resize(size*2, 0);
  }
  
  void move() {
    //eksposionen bevæger sig ikke opad og toner dobbelt så hurtigt ud
    lifespan -= 2;
  }
}
