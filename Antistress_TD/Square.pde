class Square {
  int x1, y1, x2, y2;
  Button button;
  FriendlyTower tower;

  Square(int x1_, int y1_, int x2_, int y2_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;
    button = new Button(x1, y1, x2-1, y2-1);
  }

  void display() {
    fill(255);
    rect(x1, y1, x2, y2);
    
    if (tower != null) {
      tower.display();
    }
    else if (draggingStatus > 0 && button.collision()) {
      int x = int((x2-x1)*.5 + x1);
      int y = int((y2-y1)*.5 + y1);

      displayTower(x, y, draggingStatus, true, false);
    }
  }

  void addTower(int towerNum) {
    if (tower == null) {
      int x = int((x2-x1)*.5 + x1);
      int y = int((y2-y1)*.5 + y1);
      tower = new FriendlyTower(x, y, towerNum, true);
    }
  }
}
