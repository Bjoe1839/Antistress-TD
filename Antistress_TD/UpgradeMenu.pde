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
      if (!square.tower.upgraded) text = "";
      else text = "";
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
  }

  void display() {
    fill(200);
    rect(x, y, x+250, y+200, 10);

    textFont(normalFont);
    fill(0);
    text(text, x+7, y+22);

    textAlign(CENTER, CENTER);

    if (upgradeButton != null) {
      fill(0, 255, 0);
      upgradeButton.display("up");
    }

    fill(255, 0, 0);
    sellButton.display("$");

    fill(255, 0, 0);
    exitButton.display("X");

    textAlign(CORNER);
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
      money += square.tower.worth;
      //hvis man sælger en booster skal de boostede felter opdateres
      if (square.tower.towerNum == 3) {
        for (int i = -1; i < 2; i++) for (int j = -1; j < 2; j++) {
          int col = square.colNum + i;
          int row = square.rowNum + j;
          if (col >= 0 && row >= 0 && col < squares.length && row < squares[0].length) {

            if (squares[col][row].boostingStatus > 0) {
              //der tjekkes om der er en booster i rækkevidde, ellers slettes booststatusen
              squares[col][row].boostingStatus = 0;

              for (int k = -1; k < 2; k++) for (int l = -1; l < 2; l++) {
                int col2 = squares[col][row].colNum + k;
                int row2 = squares[col][row].rowNum + l;

                if (col2 >= 0 && row2 >= 0 && col2 < squares.length && row2 < squares[0].length && squares[col2][row2] != square) {

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
      upgradeMenu.square.tower = null;
      upgradeMenu = null;
      
    //opgraderingsknap
    } else if (upgradeButton != null && upgradeButton.collision()) {
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
}
