//todo:

//sælge når tårn har taget skade
//projektil position

int towerDragStatus, abilityDragStatus;
int money;

float resizeFactor;

boolean gameOver, gameWon, levelFinished;
boolean cursorHand;

PImage[] fighterSprite, vikingAttack, vikingWalk;

PImage arrowCursor, handCursor;
PFont normalFont, mediumFont, bigFont;
ArrayList<OpponentTower> opponentTowers = new ArrayList<OpponentTower>();
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
TowerButton[] towerButtons = new TowerButton[5];
AbilityButton[] abilityButtons = new AbilityButton[5];
Square[][] squares = new Square[10][5];
UpgradeMenu upgradeMenu;
Level level;

void setup() {
  //size(1600, 900);
  fullScreen(P2D);

  arrowCursor = loadImage("cursor-arrow.png");
  cursor(arrowCursor, 0, 0);

  text("Loading...", 200, 200);
  rectMode(CORNERS);
  imageMode(CENTER);
  smooth(3);

  handCursor = loadImage("cursor-hand.png");

  resizeFactor = width/1920.0; //billederne er lavet i forhold til en 1920 * 1080 skærmopløsning

  //fonte skal loades separat med P2D renderer når textSize() gør kvaliteten sløret
  //fontenes størrelser er lavet i forhold til skærmbredden
  normalFont = createFont("Gadugi Bold", int(0.009*width));
  mediumFont = createFont("Gadugi Bold", int(0.012*width));
  bigFont = createFont("Gadugi Bold", int(0.021*width));

  createSprites();
  startUp();
}

void draw() {
  if (frameCount == 1) {
    text("Loading...", 200, 200);
  } else if (!gameOver && !gameWon) {

    fill(200);
    rect(-1, height * 0.85-1, width, height);

    //felter
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      fill(255);
      square.activateTower();
      square.display();
    }

    //projektiler
    for (int i = projectiles.size()-1; i >= 0; i--) {
      boolean removed = projectiles.get(i).move();
      if (!removed) projectiles.get(i).display();
    }

    //modstandere
    level.opponentHandler();


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
    text(money+"$", width*0.03, height*0.92);

    //progressbar
    level.displayProgressbar();
    
    //upgraderingsmenu
    if (upgradeMenu != null) {
      upgradeMenu.display();
    }

    //trukket tower
    if (towerDragStatus > -1) {
      switch(towerDragStatus%5) {
      case 0:
        image(fighterSprite[0], mouseX, mouseY);
        break;
      case 1:
        fill(0, 255, 0);
        circle(mouseX, mouseY, 80);
        break;
      case 2:
        fill(0, 0, 255);
        circle(mouseX, mouseY, 80);
        break;
      case 3:
        fill(255, 255, 0);
        circle(mouseX, mouseY, 80);
        break;
      case 4:
        fill(0);
        circle(mouseX, mouseY, 80);
        break;
      }
    }

    //trukket ability + markerede felter det kan trækkes til
    if (abilityDragStatus > -1) {
      for (Square[] squareRow : squares) for (Square square : squareRow) {
        if (square.tower != null) {
          if (square.tower.towerNum != abilityDragStatus%5) square.darken();
          else if (square.button.collision()) square.lighten();
        } else square.darken();
      }
      fill(0);
      triangle(mouseX-30, mouseY+30, mouseX+30, mouseY+30, mouseX, mouseY-30);
    }

    //fps
    textFont(normalFont);
    fill(0);
    text(round(frameRate), 10, 20);

    if (hovering()) {
      if (!cursorHand) {
        cursorHand = true;
        cursor(handCursor, 9, 0);
      }
    } else {
      if (cursorHand) {
        cursorHand = false;
        cursor(arrowCursor, 0, 0);
      }
    }
  } else {
    message();
  }
}

void message() {
  fill(255);
  rect(width * .33, height * .33, width * .67, height * .67);
  fill(0);
  textFont(bigFont);
  textAlign(CENTER);

  if (gameOver) text("GAME OVER", width/2, height/2);
  else text("Du vandt!", width/2, height/2);

  textFont(mediumFont);

  text("Tryk på mellemrum for at spille igen", width/2, height * .55);

  noLoop();
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
      if (square.button.collision() && square.tower != null && abilityDragStatus == -1) {
        upgradeMenu = new UpgradeMenu(square);
        break;
      }
    }
    if (level.nextLevel != null && level.nextLevel.collision()) {
      level.nextLevel();
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
      if (square.button.collision() && square.tower != null && square.tower.towerNum == abilityDragStatus%5) {
        square.tower.ability();
        abilityButtons[abilityDragStatus%5].cooldown = abilityButtons[abilityDragStatus%5].cooldownDur;
        break;
      }
    }
    abilityDragStatus = -1;
  }
}


void keyPressed() {
  if (!gameOver && !gameWon) {
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

    case '1':
      if (abilityDragStatus == 5) abilityDragStatus = -1;
      else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
        if (abilityButtons[0].cooldown == 0) {
          abilityDragStatus = 5;
        }
      }
      break;
    case '2':
      if (abilityDragStatus == 6) abilityDragStatus = -1;
      else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
        if (abilityButtons[1].cooldown == 0) {
          abilityDragStatus = 6;
        }
      }
      break;
    case '3':
      if (abilityDragStatus == 7) abilityDragStatus = -1;
      else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
        if (abilityButtons[2].cooldown == 0) {
          abilityDragStatus = 7;
        }
      }
      break;
    case '4':
      if (abilityDragStatus == 8) abilityDragStatus = -1;
      else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
        if (abilityButtons[3].cooldown == 0) {
          abilityDragStatus = 8;
        }
      }
      break;
    case '5':
      if (abilityDragStatus == 9) abilityDragStatus = -1;
      else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
        if (abilityButtons[4].cooldown == 0) {
          abilityDragStatus = 9;
        }
      }
      break;

      //opgraderingsmenu genvejstaster
    case 'u':
    case 'U':
      if (upgradeMenu != null) {
        upgradeMenu.upgradePressed();
      }
      break;
    case 's':
    case 'S':
      if (upgradeMenu != null) {
        upgradeMenu.sellPressed();
      }
      break;

    case '+':
      money += 1000;
      break;
    }

    //if (keyCode == ESC) {
    //  key = 0;
    //}
  } else if (key == ' ') {
    startUp();
    loop();
  }
}


void createSprites() {
  PImage spriteSheet = loadImage("Fighter.png");
  fighterSprite = cutSpriteSheet(spriteSheet, 3, 2, 4);

  spriteSheet = loadImage("Viking_attack.png");
  vikingAttack = cutSpriteSheet(spriteSheet, 3, 2, 4);

  spriteSheet = loadImage("Viking_walk.png");
  vikingWalk = cutSpriteSheet(spriteSheet, 3, 2, 4);
}


PImage[] cutSpriteSheet(PImage spriteSheet, int colCount, int rowCount, int spriteCount) {
  PImage[] sprites = new PImage[spriteCount];

  int wid = spriteSheet.width / colCount;
  int hei = spriteSheet.height / rowCount;

  for (int i = 0; i < spriteCount; i++) {
    int col = i % colCount;
    int row = i / colCount; //floor() tages automatisk da begge tal er heltal

    sprites[i] = spriteSheet.get(col * wid, row * hei, wid, hei);
    sprites[i].resize(int(sprites[i].width * resizeFactor), 0);
  }

  return sprites;
}


void startUp() {
  towerDragStatus= -1;
  abilityDragStatus = -1;
  money = 200;
  level = new Level(0);


  //placering af hvert felt
  for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
    //-1 fordi der ellers ville være en kant med i venstre side og i toppen
    squares[i][j] = new Square(i * width / squares.length - 1, int(j * height * 0.85 / squares[0].length) - 1, (i + 1) * width / squares.length - 1, int((j + 1) * height * 0.85 / squares[0].length) - 1, i, j);
  }
  //placering af towerbuttons og abilitybuttons
  for (int i = 0; i < towerButtons.length; i++) {
    int x = int(i * width * 0.13 + 0.165 * width);

    towerButtons[i] = new TowerButton(x - int(width * 0.036), int(0.862 * height), x + int(width * 0.036), int(0.93 * height), i);
    abilityButtons[i] = new AbilityButton(x - int(0.015 * width), int(0.942 * height), x + int(0.015 * width), int(0.987 * height), i);
  }



  if (gameOver) {
    gameOver = false;
    for (int i = opponentTowers.size()-1; i >= 0; i--) {
      opponentTowers.remove(opponentTowers.get(i));
    }
    for (int i = projectiles.size()-1; i >= 0; i--) {
      projectiles.remove(projectiles.get(i));
    }
    upgradeMenu = null;
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
    if (level.nextLevel != null && level.nextLevel.collision()) return true;
  } else if (upgradeMenu.sellButton.collision() || upgradeMenu.exitButton.collision() || upgradeMenu.upgradeButton != null && upgradeMenu.upgradeButton.collision()) {
    return true;
  }
  return false;
}
