class Square {
  int x1, y1, x2, y2, colNum, rowNum;
  Button button;
  FriendlyTower tower;
  int boostingStatus; //0=ikke boosted, 1=boosted, 2=boosted med opgraderet booster

  Square(int x1_, int y1_, int x2_, int y2_, int colNum_, int rowNum_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;
    button = new Button(x1, y1, x2-1, y2-1);
    colNum = colNum_;
    rowNum = rowNum_;
  }

  void activateTower() {
    if (tower != null) {
      tower.activate();
    }
  }

  void display() {
    if (boostingStatus == 0) fill(255);
    else if (boostingStatus == 1) fill(230, 230, 255);
    else fill(210, 210, 255);

    rect(x1, y1, x2, y2);

    if (tower != null) {
      if (tower.health > 0) {
        tower.display(false);
      } else {
        if (upgradeMenu != null && upgradeMenu.square == this) upgradeMenu = null;
        tower = null;
      }
    } else if (towerDragStatus > -1 && button.collision()) {
      //tårnet får koordinaterne midt på feltet
      int x = int((x2+x1)*.5);
      int y = int((y2+y1)*.5);

      FriendlyTower transparentTower;
      switch(towerDragStatus%5) {
      case 0:
        transparentTower = new Fighter(x, y, false, 80, 50, boostingStatus, rowNum);
        break;
      case 1:
        transparentTower = new Sniper(x, y, false, 80, 50, boostingStatus, rowNum);
        break;
      case 2:
        transparentTower = new Freezer(x, y, false, 80, 50, boostingStatus, rowNum);
        break;
      case 3:
        transparentTower = new Booster(x, y, false, 80, 50);
        break;
      case 4:
        transparentTower = new Blaster(x, y, false, 80, 50, boostingStatus, rowNum);
        break;
      default:
        transparentTower = new Sniper(x, y, false, 80, 50, boostingStatus, rowNum);
        break;
      }
      transparentTower.display(false);
    }
  }

  void addTower() {
    int x = int((x2+x1)*.5);
    int y = int((y2+y1)*.5);

    switch(towerDragStatus%5) {
    case 0:
      tower = new Fighter(x, y, true, 80, 255, boostingStatus, rowNum);
      break;
    case 1:
      tower = new Sniper(x, y, true, 80, 255, boostingStatus, rowNum);
      break;
    case 2:
      tower = new Freezer(x, y, true, 80, 255, boostingStatus, rowNum);
      break;
    case 3:
      tower = new Booster(x, y, true, 80, 255);
      for (int i = -1; i < 2; i++) for (int j = -1; j < 2; j++) {
        int col = colNum + i;
        int row = rowNum + j;

        if (col >= 0 && row >= 0 && col < squares.length && row < squares[0].length)

          if (squares[col][row].boostingStatus < 1) {
            squares[col][row].boostingStatus = 1;
            if (squares[col][row].tower != null) {
              squares[col][row].tower.setStats(squares[col][row].boostingStatus);
            }
          }
      }
      break;
    case 4:
      tower = new Blaster(x, y, true, 80, 255, boostingStatus, rowNum);
      break;
    }
  }

  void darken() {
    fill(0, 100);
    rect(x1, y1, x2, y2);
  }

  void lighten() {
    fill(255, 150);
    rect(x1, y1, x2, y2);
  }
}
