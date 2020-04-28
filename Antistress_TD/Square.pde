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
    if (boostingStatus == 0) noFill();
    else if (boostingStatus > 0) {
      fill(255, 255, 230, 180);
      if (!gameMenu && random(1) < 0.01) {
        int x = int(random(x1, x2));
        int y = int(random(y1, y2));
        particles.add(new Particle(x, y));
      }
    } else fill(255, 255, 230);

    //rect(x1, y1, x2, y2);

    if (tower != null) {
      if (tower.health > 0) {
        tower.display();
        if (money >= tower.upgradePrice && !tower.upgraded) {
          int x = int((x2 - x1) * .7 + x1);
          int y = int((y2 - y1) * .77 + y1);

          image(upgradeIcon, x, y);
        }
      } else {
        if (upgradeMenu != null && upgradeMenu.square == this) upgradeMenu = null;
        if (tower.towerNum == 3) {
          updateBoost();
        }
        tower = null;
      }
    } else if (towerDragStatus > -1 && button.collision()) {
      //tårnet får koordinaterne midt på feltet
      int x = int((x2 + x1) * .5);
      int y = int((y2 + y1) * .5);

      switch(towerDragStatus%5) {
      case 0:
        tint(255, 50);
        image(fighter[0], x, y);
        noTint();
        break;
      case 1:
        tint(255, 50);
        image(archer[0], x, y);
        noTint();
        break;
      case 2:
        fill(0, 0, 255, 50);
        stroke(0, 50);
        circle(x, y, 80);
        stroke(0);
        break;
      case 3:
        tint(255, 50);
        image(booster[0], x, y);
        noTint();
        break;
      case 4:
        fill(0, 50);
        stroke(0, 50);
        circle(x, y, 80);
        stroke(0);
        break;
      }
    }
  }

  void addTower() {
    int x = int((x2 + x1) * .5);
    int y = int((y2 + y1) * .5);

    switch(towerDragStatus%5) {
    case 0:
      tower = new Fighter(x, y, true, boostingStatus, rowNum);
      break;
    case 1:
      tower = new Archer(x, y, true, boostingStatus, rowNum);
      break;
    case 2:
      tower = new Freezer(x, y, true, boostingStatus, rowNum);
      break;
    case 3:
      tower = new Booster(x, y, true);
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
      tower = new Blaster(x, y, true, boostingStatus, rowNum);
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

  void updateBoost() {
    for (int i = -1; i < 2; i++) for (int j = -1; j < 2; j++) {
      int col = colNum + i;
      int row = rowNum + j;
      if (col >= 0 && row >= 0 && col < squares.length && row < squares[0].length) {

        if (squares[col][row].boostingStatus > 0) {
          //der tjekkes om der er en booster i rækkevidde, ellers slettes booststatusen
          squares[col][row].boostingStatus = 0;

          for (int k = -1; k < 2; k++) for (int l = -1; l < 2; l++) {
            int col2 = squares[col][row].colNum + k;
            int row2 = squares[col][row].rowNum + l;

            if (col2 >= 0 && row2 >= 0 && col2 < squares.length && row2 < squares[0].length && !(col2 == colNum && row2 == rowNum)) {

              if (squares[col2][row2].tower != null && squares[col2][row2].tower.towerNum == 3) {
                if (squares[col2][row2].tower.upgraded) squares[col][row].boostingStatus = 2;
                else if (squares[col][row].boostingStatus < 2) {
                  squares[col][row].boostingStatus = 1;
                }
              }
            }
          }
          if (squares[col][row].tower != null) {
            squares[col][row].tower.setStats(squares[col][row].boostingStatus);
          }
        }
      }
    }
  }
}
