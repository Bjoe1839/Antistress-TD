class Particle {
  int x, y;
  float size;
  int lifeSpan;

  Particle(int x_, int y_) {
    x = x_;
    y = y_;
    size = random(1, 5);
    lifeSpan = 50;
  }


  void move() {
    y--;
    lifeSpan--;
  }

  void display() {
    int alfa = int(map(lifeSpan, 0, 50, 0, 255));
    
    tint(255, alfa);
    image(particle, x, y);
    noTint();

  }
}
