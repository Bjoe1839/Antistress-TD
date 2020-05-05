class Particle {
  int x, y;
  int lifeSpan;
  PImage img;

  Particle(int x_, int y_) {
    x = x_;
    y = y_;
    lifeSpan = 50;
    img = particle;
  }

  void move() {
    lifeSpan--;
    y--;
  }

  void display() {
    int alfa = int(map(lifeSpan, 0, 50, 0, 255));

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
    lifeSpan--;
  }

  //void display() {
  //  int alfa = int(map(lifeSpan, 0, 50, 0, 255));

  //  tint(255, alfa);
    
  //  PImage img = explosion.copy();
  //  img.resize(size*2, 0);
    
  //  image(img, x, y);
  //  noTint();
  //  noFill();
  //  circle(x, y, size*2);
  //}
}
