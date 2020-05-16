class Square {
  int x1, y1, x2, y2, colNum, rowNum;
  Button button;
  FriendlyTower tower;
  int boostingStatus; //0=ikke boosted, 1=boosted, 2=boosted med opgraderet priest

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
    if (boostingStatus > 0) {
      if (!gameMenu && random(1) < 0.01) {
        int x = int(random(x1, x2));
        int y = int(random(y1, y2));
        particles.add(new Particle(x, y));
      }
    }


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
      //tegner et gennemsigtigt tårn midt på feltet hvis der trækkes et tårn over det
      int x = int((x2 + x1) * .5);
      int y = int((y2 + y1) * .5);

      tint(255, 80);
      switch(towerDragStatus%5) {
      case 0:
        image(fighter[0], x, y);
        break;
      case 1:
        image(archer[0], x, y);
        break;
      case 2:
        image(freezer[0], x, y);
        break;
      case 3:
        image(priest[0], x, y);
        break;
      case 4:
        image(bomber[0], x, y);
        break;
      }
      noTint();
    }
  }

  void addTower() {
    int x = int((x2 + x1) * .5);
    int y = int((y2 + y1) * .5);

    switch(towerDragStatus%5) {
    case 0:
      tower = new Fighter(x, y, boostingStatus, rowNum);
      break;
    case 1:
      tower = new Archer(x, y, boostingStatus, rowNum);
      break;
    case 2:
      tower = new Freezer(x, y, boostingStatus, rowNum);
      break;
    case 3:
      tower = new Priest(x, y);
      for (int i = -1; i < 2; i++) for (int j = -1; j < 2; j++) {
        int col = colNum + i;
        int row = rowNum + j;

        if (col >= 0 && row >= 0 && col < squares.length && row < squares[0].length) {

          if (squares[col][row].boostingStatus < 1) {
            squares[col][row].boostingStatus = 1;
            if (squares[col][row].tower != null) {
              squares[col][row].tower.setStats(squares[col][row].boostingStatus);
            }
          }
        }
      }
      break;
    case 4:
      tower = new Bomber(x, y, boostingStatus, rowNum);
      break;
    }
  }

  void darken() {
    fill(0, 100);
    rect(x1, y1, x2, y2);
  }

  void lighten() {
    fill(255, 100);
    rect(x1, y1, x2, y2);
  }

  void displayBoostRange() {
    for (int x = -1; x < 2; x++) for (int y = -1; y < 2; y++) {
      if (colNum + x >= 0 && colNum + x < squares.length && rowNum + y >= 0 && rowNum + y < squares[0].length) {
        squares[colNum + x][rowNum + y].lighten();
      }
    }
  }

  void displayShotRange() {
    int range;

    if (tower != null) {
      range = ((ShooterTower)tower).range;
    } else {
      ShooterTower dragTower;
      if (towerDragStatus%5 == 0) dragTower = new Fighter(0, 0, 0, 0);
      else if (towerDragStatus%5 == 1) dragTower = new Archer(0, 0, 0, 0);
      else if (towerDragStatus%5 == 2) dragTower = new Freezer(0, 0, 0, 0);
      else dragTower = new Bomber(0, 0, 0, 0);

      range = dragTower.range;
      if (boostingStatus > 0) range++;
    }

    for (int x = 0; x <= range; x++) {
      if (colNum + x < squares.length) {
        squares[colNum + x][rowNum].lighten();
      }
    }
  }

  void sellTower() {
    money += tower.actualWorth;
    //hvis man sælger en priest skal de boostede felter opdateres
    if (tower.towerNum == 3) {
      updateBoost();
    }
    tower = null;
    upgradeMenu = null;
  }

  void upgradeTower() {
    if (!tower.upgraded && money >= tower.upgradePrice) {
      money -= tower.upgradePrice;

      tower.upgraded = true;
      tower.setStats(boostingStatus);
      upgradeMenu = null;

      if (tower.towerNum == 3) {
        for (int i = -1; i < 2; i++) for (int j = -1; j < 2; j++) {
          int col = colNum + i;
          int row = rowNum + j;

          if (col >= 0 && row >= 0 && col < squares.length && row < squares[0].length) {

            squares[col][row].boostingStatus = 2;
            if (squares[col][row].tower != null) {
              squares[col][row].tower.setStats(squares[col][row].boostingStatus);
            }
          }
        }
      }
    }
  }

  void updateBoost() {
    for (int i = -1; i < 2; i++) for (int j = -1; j < 2; j++) {
      int col = colNum + i;
      int row = rowNum + j;
      if (col >= 0 && row >= 0 && col < squares.length && row < squares[0].length) {

        if (squares[col][row].boostingStatus > 0) {
          //der tjekkes om der er en priest i rækkevidde, ellers slettes booststatusen
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
