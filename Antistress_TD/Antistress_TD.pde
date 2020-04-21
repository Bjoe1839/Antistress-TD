//todo:

//projektil position

int towerDragStatus, abilityDragStatus;
int money;

float resizeFactor;

boolean gameOver, gameWon, levelFinished;
boolean gameMenu;
boolean cursorHand;

//sprites
PImage[] fighter, fighterlv2, viking1Walk, viking1Attack, viking2Walk, viking2Attack;

PImage fighterProjectile, fighterlv2Projectile;

PImage arrowCursor, handCursor;
PFont normalFont, mediumFont, bigFont;

ArrayList<OpponentTower> opponentTowers;
ArrayList<Projectile> projectiles;

TowerButton[] towerButtons;
AbilityButton[] abilityButtons;
Square[][] squares;

UpgradeMenu upgradeMenu;
Level level;
Button continueGame, newGame, howToPlay, exit;


void setup() {
  size(1920, 1000);
  //fullScreen(P2D);

  arrowCursor = loadImage("cursor-arrow.png");
  cursor(arrowCursor, 0, 0);

  text("Loading...", 200, 200);
  rectMode(CORNERS);
  imageMode(CENTER);
  smooth(3);

  initVariables();

  startUp();
}

void draw() {
  if (frameCount == 1) {
    text("Loading...", 200, 200);
  } else {

    fill(200);
    rect(-1, height * 0.85-1, width, height);

    //felter
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      fill(255);
      if (!gameMenu) square.activateTower();
      square.display();
    }

    //projektiler
    for (int i = projectiles.size()-1; i >= 0; i--) {
      boolean removed = false;
      if (!gameMenu) removed = projectiles.get(i).move();
      if (!removed) projectiles.get(i).display();
    }

    //modstandere
    if (!gameMenu) level.opponentHandler();
    else {
      for (OpponentTower ot : opponentTowers) ot.display();
    }


    //tegn towerbuttons
    for (TowerButton tb : towerButtons) {
      if (towerDragStatus == tb.towerNum) {
        tb.display(3);
      } else if (tb.collision() && towerDragStatus == -1 && abilityDragStatus == -1 && !gameMenu && upgradeMenu == null) {
        if (money >= tb.price) tb.display(1);
        else tb.display(2);
      } else {
        tb.display(0);
      }
    }

    //abilitybuttons
    for (AbilityButton ab : abilityButtons) {
      if (ab.cooldown > 0 && !gameMenu) ab.cooldown--;

      if (abilityDragStatus == ab.towerNum) {
        ab.display(3);
      } else if (ab.collision() && towerDragStatus == -1 && abilityDragStatus == -1 && !gameMenu && upgradeMenu == null) {
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
    if (upgradeMenu != null) upgradeMenu.display();

    //trukket tower
    if (towerDragStatus > -1) {
      switch(towerDragStatus%5) {
      case 0:
        image(fighter[0], mouseX, mouseY);
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

    if (gameOver || gameWon) {
      textFont(bigFont);
      textAlign(CENTER);

      if (gameOver) text("GAME OVER", width/2, height/2);
      if (gameWon) text("Du har vundet!", width/2, height/2);

      textAlign(CORNER);
    }

    if (gameMenu) displayGameMenu();

    //fps
    textFont(normalFont);
    fill(0);
    text(round(frameRate), 10, 20);

    //cursor
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
  }
}


void mousePressed() {
  if (!gameMenu) {
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
  } else {
    if (continueGame.collision()) gameMenu = false;
    else if (newGame.collision()) {
      gameMenu = false;
      startUp();
    } else if (exit.collision()) exit();
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
    case ' ':
      if (levelFinished) level.nextLevel();
      break;
    case '+':
      money += 1000;
      break;
    }

    if (keyCode == ESC) { //todo: fix
      key = 0;
      gameMenu = true;
      towerDragStatus = -1;
      abilityDragStatus = -1;
    }
  } else if (key == ' ') {
    startUp();
  }
}

void initVariables() {
  handCursor = loadImage("cursor-hand.png");

  resizeFactor = width/1920.0; //billederne er lavet i forhold til en 1920 * 1080 skærmopløsning

  //fonte skal loades separat med P2D renderer når textSize() gør kvaliteten sløret
  normalFont = createFont("Gadugi Bold", int(0.009*width));
  mediumFont = createFont("Gadugi Bold", int(0.012*width));
  bigFont = createFont("Gadugi Bold", int(0.021*width));

  gameMenu = true;

  //spillemenu knapper
  int x1 = int(width * .35);
  int x2 = int(width * .65);

  int hei = int(height * .05);

  continueGame = new Button(x1, hei * 4, x2, hei * 5);
  newGame = new Button(x1, hei * 6, x2, hei * 7);
  howToPlay = new Button(x1, hei * 8, x2, hei * 9);
  exit = new Button(x1, hei * 10, x2, hei * 11);

  loadSprites();
}

void loadSprites() {
  PImage spriteSheet = loadImage("Fighter.png");
  fighter = cutSpriteSheet(spriteSheet, 3, 2, 3);

  spriteSheet = loadImage("Fighter_upgraded.png");
  fighterlv2 = cutSpriteSheet(spriteSheet, 3, 2, 4);

  spriteSheet = loadImage("Viking_lv1_walk.png");
  viking1Walk = cutSpriteSheet(spriteSheet, 3, 2, 4);

  spriteSheet = loadImage("Viking_lv1_attack.png");
  viking1Attack = cutSpriteSheet(spriteSheet, 3, 2, 4);

  spriteSheet = loadImage("Viking_lv2_walk.png");
  viking2Walk = cutSpriteSheet(spriteSheet, 3, 2, 4);

  spriteSheet = loadImage("Viking_lv2_attack.png");
  viking2Attack = cutSpriteSheet(spriteSheet, 3, 2, 5);


  fighterProjectile = loadImage("Fighter_projectile.png");
  fighterlv2Projectile = loadImage("Fighter_upgraded_projectile.png");
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

  opponentTowers = new ArrayList<OpponentTower>();
  projectiles = new ArrayList<Projectile>();
  towerButtons = new TowerButton[5];
  abilityButtons = new AbilityButton[5];
  squares = new Square[10][5];

  upgradeMenu = null;
  gameOver = false;
  gameWon = false;
  levelFinished = true;
  level.nextLevel = new Button(int(width * .97), int(height * .95), int(width * .99), int(height * .99));


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
}





//om musen holder over en knap og skal markeres med en hånd i stedet for en pil
boolean hovering() {

  if (!gameMenu) {
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
  } else {
    if (continueGame.collision() || newGame.collision() || howToPlay.collision() || exit.collision()) {
      return true;
    }
  }
  return false;
}



void displayGameMenu() {
  fill(255, 150);
  rect(0, 0, width, height);
  
  stroke(0);
  textAlign(CENTER);
  textFont(bigFont);
  fill(0);
  text("Antistress-TD", width * .5, height * .1);

  textFont(mediumFont);
  fill(200, 255, 255);
  continueGame.display("Spil");
  fill(200, 255, 255);
  newGame.display("Start forfra");
  fill(200, 255, 255);
  howToPlay.display("Hvordan man spiller");
  fill(200, 255, 255);
  exit.display("Afslut");

  textAlign(CORNER);
}
