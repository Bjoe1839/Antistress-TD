class Tower {
  int x, y;
  int health;

  Tower(int x_, int y_) {
    x = x_;
    y = y_;
  }

  void display() {
  }

  void displayHealth() {
    fill(0, 255, 0);
    noStroke();
    rect(x-40, y-50, x+40, y-45);
    stroke(0);
  }
}


class FriendlyTower extends Tower {
  int towerNum;
  int price;
  boolean placed;

  FriendlyTower(int x, int y, int towerNum_, boolean placed_) {
    super(x, y);
    placed = placed_;
    towerNum = towerNum_;
    switch (towerNum) {
    case 1:
      health = 100;
      break;
    case 2:
      health = 150;
      break;
    case 3:
      health = 200;
      break;
    case 4:
      health = 200;
      break;
    case 5:
      health = 300;
      break;
    }
  }

  void display() {
    displayTower(x, y, towerNum, false, false);

    if (placed) {
      displayHealth();
    }
  }
}


class OpponentTower extends Tower {
  OpponentTower(int x, int y) {
    super(x, y);
  }
}
