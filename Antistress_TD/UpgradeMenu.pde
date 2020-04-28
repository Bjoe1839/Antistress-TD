class UpgradeMenu {
  int x, y;
  String text;
  Square square;
  Button upgradeButton, sellButton, exitButton, upgradeMenuButton;

  UpgradeMenu(Square square_) {
    x = mouseX;
    y = mouseY;
    square = square_;
    if (!square.tower.upgraded) {
      upgradeButton = new Button(x+160, y+130, x+230, y+180);
    }
    sellButton = new Button(x+20, y+130, x+90, y+180);
    exitButton = new Button(x+210, y+10, x+240, y+40);
    //bruges til at undersøge om man trykker inden for opgraderingsmenuen eller om den skal lukkes
    upgradeMenuButton = new Button(x, y, x+250, y+200);
  }

  void display() {
    fill(200);
    rect(x, y, x+250, y+200, 10);
    
    switch(square.tower.towerNum) {
    case 0:
      if (!square.tower.upgraded) text = "Opgrader dette tårn for\nat det bliver bedre ved\nat blive bedre";
      else text = "Dette tårn er opgraderet\n(spurgt)";
      break;
    case 1:
      if (!square.tower.upgraded) text = "Opgrader til ";
      else text = "";
      break;
    case 2:
      if (!square.tower.upgraded) text = "Dette tårn er værd: "+square.tower.actualWorth;
      else text = "Dette tårn er værd: "+square.tower.actualWorth;
      break;
    case 3:
      if (!square.tower.upgraded) text = "";
      else text = "";
      break;
    case 4:
      if (!square.tower.upgraded) text = "";
      else text = "";
      break;
    }

    textFont(normalFont);
    fill(0);
    textAlign(CORNER);
    text(text, x+7, y+22);
    
    textAlign(LEFT, BOTTOM);
    textFont(smallFont);
    
    if (upgradeButton != null) text("Opgrader", upgradeButton.x1, upgradeButton.y1);
    text("Sælg", sellButton.x1, sellButton.y1);
    
    textAlign(CENTER, CENTER);
    
    textFont(normalFont);
    
    if (upgradeButton != null) {
      
      upgradeButton.display(square.tower.upgradePrice+"$", color(100, 255, 100), 255);
    }

    sellButton.display(square.tower.actualWorth+"$", color(255, 0, 0), 255);
    

    exitButton.display("X", color(255, 0, 0), 255);

  }

  void pressed() {
    if (!upgradeMenuButton.collision()) {
      upgradeMenu = null;
    }
    //exit knap
    else if (exitButton.collision()) {
      upgradeMenu = null;

      //sælgknap
    } else if (sellButton.collision()) {
      sellPressed();

      //opgraderingsknap
    } else if (upgradeButton != null && upgradeButton.collision()) {
      upgradePressed();
    }
  }
  
  void sellPressed() {
    money += square.tower.actualWorth;
    //hvis man sælger en booster skal de boostede felter opdateres
    if (square.tower.towerNum == 3) {
      square.updateBoost();
    }
    upgradeMenu.square.tower = null;
    upgradeMenu = null;
  }

  void upgradePressed() {
    if (money >= square.tower.upgradePrice) {
      money -= square.tower.upgradePrice;
      square.tower.upgraded = true;
      square.tower.setStats(square.boostingStatus);
      upgradeMenu = null;

      if (square.tower.towerNum == 3) {
        for (int i = -1; i < 2; i++) for (int j = -1; j < 2; j++) {
          int col = square.colNum + i;
          int row = square.rowNum + j;

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
}
