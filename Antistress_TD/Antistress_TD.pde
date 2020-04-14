//todo:

//sæge når tårn har taget skade
//projektil position
//fix generelle enheder og enheder angivet i pixels 

int towerDragStatus, abilityDragStatus;
int money;

boolean gameOver;

PImage arrowCursor, handCursor;
PFont normalFont, mediumFont, bigFont;
ArrayList<OpponentTower> opponentTowers = new ArrayList<OpponentTower>();
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
TowerButton[] towerButtons = new TowerButton[5];
AbilityButton[] abilityButtons = new AbilityButton[5];
Square[][] squares = new Square[10][5];
UpgradeMenu upgradeMenu;

void setup() {
  fullScreen(P2D);
  rectMode(CORNERS);
  noCursor();
  smooth(3);

  arrowCursor = loadImage("cursor-arrow - Kopi.png");
  handCursor = loadImage("cursor-hand - Kopi.png");

  //fonte skal loades separat med P2D renderer når textSize() gør kvaliteten sløret
  normalFont = loadFont("NirmalaUI-Bold-17.vlw");
  mediumFont = loadFont("NirmalaUI-Bold-23.vlw");
  bigFont = loadFont("NirmalaUI-Bold-40.vlw");

  startUp();
}

void draw() {
  /*if (frameCount == 1) {
    text("Loading :)", 200, 200);
  } else */if (!gameOver) {
    fill(200);
    rect(-1, 917, width, height);

    //felter
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      fill(255);
      square.activateTower();
      square.display();
    }

    projectileHandler();
    opponentHandler();


    //tegn towerbuttons
    for (TowerButton tb : towerButtons) {
      if (towerDragStatus == tb.towerNum) {
        tb.display(3);
      } else if (tb.collision() && towerDragStatus == -1 && abilityDragStatus == -1 && upgradeMenu == null) {
        if (money >= tb.price) tb.display(1);
        else tb.display(2);
      } else {
        tb.display(0);
      }
    }

    //abilitybuttons
    for (AbilityButton ab : abilityButtons) {
      if (ab.cooldown > 0) ab.cooldown--;

      if (abilityDragStatus == ab.towerNum) {
        ab.display(3);
      } else if (ab.collision() && towerDragStatus == -1 && abilityDragStatus == -1 && upgradeMenu == null) {
        if (ab.cooldown == 0) ab.display(1);
        else ab.display(2);
      } else {
        ab.display(0);
      }
    }
    
    //penge
    fill(255, 200, 0);
    textFont(bigFont);
    text(money+"$", 57, 990);

    //upgraderingsmenu
    if (upgradeMenu != null) {
      upgradeMenu.display();
    }


    //trukket tower
    if (towerDragStatus > -1) {
      FriendlyTower draggedTower = new FriendlyTower(mouseX, mouseY, false, 80, 255, towerDragStatus%5);
      draggedTower.display(false);
    }

    //trukket ability + markerede felter det kan trækkes til
    if (abilityDragStatus > -1) {
      for (Square[] squareRow : squares) for (Square square : squareRow) {
        if (square.tower != null) {
          if (square.tower.towerNum != abilityDragStatus) square.darken();
          else if (square.button.collision()) square.lighten();
        } else square.darken();
      }
      fill(0);
      triangle(mouseX-30, mouseY+30, mouseX+30, mouseY+30, mouseX, mouseY-30);
    }

    //fps
    textFont(normalFont);
    fill(0);
    //text(round(frameRate), 10, 20);

    //musens markør
    if (hovering()) image(handCursor, mouseX-7, mouseY);
    else image(arrowCursor, mouseX, mouseY);
    
    //if (hovering()) cursor(handCursor, 11, 2);
    //else cursor(arrowCursor, 6, 0);

    //if (hovering()) cursor(HAND);
    //else cursor(ARROW);
    
  } else {
    textFont(bigFont);
    textAlign(CENTER);
    text("GAME OVER", 960, 540);
    noLoop();
  }
}


void mousePressed() {
  if (upgradeMenu == null) {
    for (TowerButton tb : towerButtons) {
      if (tb.collision() && money >= tb.price) {
        towerDragStatus = tb.towerNum;
        break;
      }
    }
    for (AbilityButton ab : abilityButtons) {
      if (ab.collision() && ab.cooldown == 0) {
        abilityDragStatus = ab.towerNum;
      }
    }
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      if (square.button.collision() && square.tower != null) {
        upgradeMenu = new UpgradeMenu(square);
        break;
      }
    }
  } else {
    upgradeMenu.pressed();
  }
}


void mouseReleased() {
  if (towerDragStatus > -1) {
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      //hvis tårnet slippes over et felt, tilføjes tårnet til det felt 
      if (square.button.collision() && square.tower == null) {
        square.addTower();
        money -= towerButtons[towerDragStatus%5].price;
        break;
      }
    }
    towerDragStatus = -1;
  }
  if (abilityDragStatus > -1) {
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      if (square.button.collision() && square.tower != null && square.tower.towerNum == abilityDragStatus) {
        square.tower.ability();
        abilityButtons[abilityDragStatus].cooldown = abilityButtons[abilityDragStatus].cooldownDur;
        break;
      }
    }
    abilityDragStatus = -1;
  }
}


void mouseMoved() {
  //musens markør opdateres kun når den bevæger sig

  //if (hovering()) cursor(HAND);
  //else cursor(ARROW);

  //if (hovering()) cursor(handCursor, 11, 2);
  //else cursor(arrowCursor, 6, 0);
}


void keyPressed() {
  switch(key) {
  case 'q':
  case 'Q':
    //hvis tårnet allerede er valgt
    if (towerDragStatus == 5) towerDragStatus = -1;
    //hvis drag-and-drop ikke er i gang
    else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
      if (money >= towerButtons[0].price) towerDragStatus = 5;
    }
    break;
  case 'w':
  case 'W':
    if (towerDragStatus == 6) towerDragStatus = -1;
    else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
      if (money >= towerButtons[1].price) towerDragStatus = 6;
    }
    break;
  case 'e':
  case 'E':
    if (towerDragStatus == 7) towerDragStatus = -1;
    else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
      if (money >= towerButtons[2].price) towerDragStatus = 7;
    }
    break;
  case 'r':
  case 'R':
    if (towerDragStatus == 8) towerDragStatus = -1;
    else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
      if (money >= towerButtons[3].price) towerDragStatus = 8;
    }
    break;
  case 't':
  case 'T':
    if (towerDragStatus == 9) towerDragStatus = -1;
    else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
      if (money >= towerButtons[4].price) towerDragStatus = 9;
    }
    break;
  case '+':
    money += 1000;
    break;
  }

  //if (keyCode == ESC) {
  //  key = 0;
  //}
}


void startUp() {
  towerDragStatus= -1;
  abilityDragStatus = -1;
  money = 200;

  //placering af hvert felt
  for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
    //-1 fordi der ellers ville være en kant med i venstre side og i toppen
    squares[i][j] = new Square(i * width / squares.length - 1, int(j * 918 / squares[0].length) - 1, (i + 1) * width / squares.length - 1, int((j + 1) * 918 / squares[0].length) - 1, i, j);
  }
  //placering af towerbuttons og abilitybuttons
  for (int i = 0; i < towerButtons.length; i++) {
    int x = i*250 + 317;

    towerButtons[i] = new TowerButton(x - 67, 932, x + 67, 1002, i);
    abilityButtons[i] = new AbilityButton(x - 30, 1015, x + 30, 1063, i);
  }
}


void opponentHandler() {
  if (frameCount%600 == 1) {
    int x = 1920 + 40;
    //random lane
    int laneNum = int(random(5));
    int y = int((squares[0][laneNum].y1 + squares[0][laneNum].y2) * .5);
    int offset = int(random(-(squares[0][laneNum].y2 - squares[0][laneNum].y1) * .5 + 60, (squares[0][laneNum].y2 - squares[0][laneNum].y1) * .5 - 60));
    y += offset;

    opponentTowers.add(new OpponentTower(x, y, laneNum));
  }
  for (OpponentTower ot : opponentTowers) {
    ot.move();
    ot.display();
  }
}


void projectileHandler() {
  for (int i = projectiles.size()-1; i >= 0; i--) {
    boolean removed = projectiles.get(i).move();
    if (!removed) projectiles.get(i).display();
  }
}


//om musen holder over en knap og skal markeres med en hånd i stedet for en pil
boolean hovering() {
  if (towerDragStatus > -1 || abilityDragStatus > -1) return true;

  if (upgradeMenu == null) {
    for (TowerButton tb : towerButtons) if (tb.collision() && money >= tb.price) {
      return true;
    }
    for (AbilityButton ab : abilityButtons) if (ab.collision()) {
      return true;
    }
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      if (square.button.collision() && square.tower != null) {
        return true;
      }
    }
  } else if (upgradeMenu.sellButton.collision() || upgradeMenu.exitButton.collision() || upgradeMenu.upgradeButton != null && upgradeMenu.upgradeButton.collision()) {
    return true;
  }
  return false;
}
