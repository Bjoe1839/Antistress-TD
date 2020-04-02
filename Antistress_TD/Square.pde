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

  void activateTower() {
    if (tower != null) {
      tower.activate();
    }
  }

  void display(int laneNum) {
    fill(255);
    rect(x1, y1, x2, y2);

    if (tower != null) {
      if (tower.health > 0) {
        tower.display(false);
      } else tower = null;
    } else if (draggingStatus > -1 && button.collision()) {
      //tårnet får koordinaterne midt på feltet
      int x = int((x2+x1)*.5);
      int y = int((y2+y1)*.5);

      FriendlyTower transparentTower;
      switch(draggingStatus%5) {
      case 0:
        transparentTower = new Fighter(x, y, false, 80, 50, laneNum);
        break;
      case 1:
        transparentTower = new Sniper(x, y, false, 80, 50, laneNum);
        break;
      case 2:
        transparentTower = new Freezer(x, y, false, 80, 50, laneNum);
        break;
      case 3:
        transparentTower = new Booster(x, y, false, 80, 50);
        break;
      case 4:
        transparentTower = new Blaster(x, y, false, 80, 50, laneNum);
        break;
      default:
        transparentTower = new Fighter(x, y, false, 80, 50, laneNum);
        break;
      }
      transparentTower.display(false);
    }
  }

  void addTower(int laneNum) {
    int x = int((x2+x1)*.5);
    int y = int((y2+y1)*.5);

    switch(draggingStatus%5) {
    case 0:
      tower = new Fighter(x, y, true, 80, 255, laneNum);
      break;
    case 1:
      tower = new Sniper(x, y, true, 80, 255, laneNum);
      break;
    case 2:
      tower = new Freezer(x, y, true, 80, 255, laneNum);
      break;
    case 3:
      tower = new Booster(x, y, true, 80, 255); //do stuff
      break;
    case 4:
      tower = new Blaster(x, y, true, 80, 255, laneNum);
      break;
    }
  }
}
