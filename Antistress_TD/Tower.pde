class Tower {
  int x, y;
  int towerNum;

  Tower(int x_, int y_, int towerNum_) {
    x = x_;
    y = y_;
    towerNum = towerNum_;
  }

  void display() {
    switch(towerNum) {
    case 1:
      fill(255, 0, 0);
      break;
    case 2:
      fill(0, 255, 0);
      break;
    case 3:
      fill(0, 0, 255);
      break;
    case 4:
      fill(255, 255, 0);
      break;
    case 5:
      fill(0);
      break;
    }
    circle(x, y, 30);
  }
}
