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
    fill(180, 220, 230);
    rect(x, y, x+250, y+200, 10);


    if (square.tower.upgraded) text = "Dette tårn er\nopgraderet.";
    else {
      switch(square.tower.towerNum) {
      case 0:
        text = "Opgrader til ridder for\nat skade mere og skyde\nhurtigere.";
        break;
      case 1:
        text = "Opgrader til armbrøst\nfor at skyde hurtigere og\nskade lidt mere.";
        break;
      case 2:
        text = "Opgrader til at skyde\nmed istapper for at fryse\ntårnet og skade lidt.";
        break;
      case 3:
        text = "Opgrader til biskop for\nat booste tårnene endnu\nmere.";
        break;
      case 4:
        text = "Opgrader til\nbombeskyder for at skade\nmere i et større område.";
        break;
      }
    }

    textSize(.009 * width);
    fill(0);
    textAlign(CORNER);
    text(text, x+7, y+22);

    textAlign(LEFT, BOTTOM);
    textSize(.007 * width);

    if (upgradeButton != null) text("Opgrader (u)", upgradeButton.x1, upgradeButton.y1);
    text("Sælg (s)", sellButton.x1, sellButton.y1);

    textAlign(CENTER, CENTER);

    textSize(.009 * width);

    if (upgradeButton != null) upgradeButton.display(square.tower.upgradePrice+"$", color(100, 255, 100), 255);

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
      square.sellTower();

      //opgraderingsknap
    } else if (upgradeButton != null && upgradeButton.collision()) {
      square.upgradeTower();
    }
  }
}
