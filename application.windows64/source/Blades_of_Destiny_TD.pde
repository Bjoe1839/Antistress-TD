import processing.sound.*;

SoundFile music;

int towerDragStatus, abilityDragStatus;
int money;

float resizeX, resizeY;

boolean gameOver, gameWon, gameBegun;
boolean gameMenu, frontPage, howToPlay;
boolean cursorHand;
boolean muted;

//sprites
PImage[] fighter, fighterlv2, archer, archerlv2, freezer, freezerlv2, priest, priestlv2, bomber, bomberlv2, 
  warriorWalk, warriorAttack, axemanWalk, axemanAttack, shieldwallWalk, shieldwallAttack, berserkerWalk, berserkerAttack;

PImage fighterProjectile, fighterlv2Projectile, archerProjectile, archerlv2Projectile, freezerProjectile, freezerlv2Projectile, bomberProjectile, bomberlv2Projectile;

PImage upgradeIcon, muteIcon, particle, explosion, potion, shadow, background, howToPlayScreen, frontPageScreen, logo;

ArrayList<Projectile> projectiles;
ArrayList<Particle> particles;

TowerButton[] towerButtons;
AbilityButton[] abilityButtons;
Square[][] squares;

UpgradeMenu upgradeMenu;
Level level;
Button continueGame, newGame, howToPlayButton, exit, toFrontPage;
Button muteButton;


void setup() {
  fullScreen();

  //loading skærm
  background(0);
  fill(255);
  text("Loading...", 200, 200);

  rectMode(CORNERS);
  imageMode(CENTER);
  textAlign(CENTER, CENTER);

  initVariables();
}

void draw() {
  if (!frontPage) {
    background(background);

    //hvis opgraderingsmenuen er åben eller et tårn er trukket markeres dets rækkevidde
    if (upgradeMenu != null) {
      if (upgradeMenu.square.tower.towerNum == 3) upgradeMenu.square.displayBoostRange();
      else upgradeMenu.square.displayShotRange();
      
    } else if (towerDragStatus > -1) {
      noStroke();
      if (towerDragStatus%5 == 3) {
        for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) if (squares[i][j].button.collision()) {
          squares[i][j].displayBoostRange();
          break;
        }
      } else {
        for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) if (squares[i][j].button.collision() && squares[i][j].tower == null) {
          squares[i][j].displayShotRange();
          break;
        }
      }
      stroke(0);
    }

    //tern linjer
    stroke(0, 150, 0, 200);
    strokeWeight(3);
    for (int i = 0; i < squares.length-1; i++) line(squares[i][0].x2, 0, squares[i][0].x2, 915 * resizeY - 1);
    for (int i = 0; i < squares[0].length-1; i++) line(0, squares[0][i].y2, width, squares[0][i].y2);
    stroke(0);
    strokeWeight(1);


    //skygger
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      if (square.tower != null) square.tower.shadow();
    }
    for (OpponentTower ot : level.opponentTowers) {
      ot.shadow();
    }


    //partikler
    for (int i = particles.size()-1; i >= 0; i--) {
      if (!gameMenu) particles.get(i).move();
      if (particles.get(i).lifespan <= 0) particles.remove(particles.get(i));
      else particles.get(i).display();
    }

    //felter + tårne
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
      for (OpponentTower ot : level.opponentTowers) ot.display();
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

    //tegn abilitybuttons
    for (AbilityButton ab : abilityButtons) {
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
    fill(255, 210, 135);
    textSize(.021 * width);
    text(money+"$", width*0.05, height*0.9);

    //progressbar
    level.displayProgressbar();

    //upgraderingsmenu
    if (upgradeMenu != null) upgradeMenu.display();

    //trukket tårn
    if (towerDragStatus > -1) {
      switch(towerDragStatus%5) {
      case 0:
        image(fighter[0], mouseX, mouseY);
        break;
      case 1:
        image(archer[0], mouseX, mouseY);
        break;
      case 2:
        image(freezer[0], mouseX, mouseY);
        break;
      case 3:
        image(priest[0], mouseX, mouseY);
        break;
      case 4:
        image(bomber[0], mouseX, mouseY);
        break;
      }
    }

    //trukket ability + mørkning af felter det ikke kan trækkes til
    if (abilityDragStatus > -1) {
      noStroke();
      for (Square[] squareRow : squares) for (Square square : squareRow) {
        if (square.tower != null) {
          if (square.tower.towerNum != abilityDragStatus%5) {
            square.darken();
          } else if (square.button.collision()) {
            square.lighten();
          }
        } else square.darken();
      }
      image(potion, mouseX, mouseY);

      stroke(0);
    }

    if (gameOver || gameWon) {
      textSize(.1 * width);

      if (gameOver) text("GAME OVER", width * .5, height * .6);
      if (gameWon) text("Du vandt!", width * .5, height * .6);
    }
  }
  //cursor
  //bruges variabel for kun at kalde cursor() når det er nødvendigt
  if (hovering()) {
    if (!cursorHand) {
      cursorHand = true;
      cursor(HAND);
    }
  } else {
    if (cursorHand) {
      cursorHand = false;
      cursor(ARROW);
    }
  }
  if (gameMenu) {
    displayGameMenu();
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
      if (!level.finished) {
        for (AbilityButton ab : abilityButtons) {
          if (ab.collision() && ab.cooldown == 0) {
            abilityDragStatus = ab.towerNum;
            break;
          }
        }
      }
      for (Square[] squareRow : squares) for (Square square : squareRow) {
        if (square.button.collision() && square.tower != null && abilityDragStatus == -1) {
          upgradeMenu = new UpgradeMenu(square);
          break;
        }
      }
      if (level.nextLevelButton != null && level.nextLevelButton.collision()) {
        level.nextLevel();
      }
    } else {
      upgradeMenu.pressed();
    }
  } else {
    if (continueGame.collision() && gameBegun) {
      if (frontPage) frontPage = false;
      else gameMenu = false;
    }
    if (!howToPlay) {
      if (frontPage) {
        if (newGame.collision()) {
          gameMenu = false;
          frontPage = false;
          startUp();
        } else if (howToPlayButton.collision()) {
          howToPlay = true;
        } else if (exit.collision()) {
          exit();
        }
      } else if (toFrontPage.collision()) frontPage = true;

      if (muteButton.collision()) {
        if (muted) music.amp(0.5);
        else music.amp(0.0);

        muted = !muted;
      }
    } else {
      howToPlay = false;
    }
  }
}


void mouseReleased() {
  if (!frontPage) {
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
}


void keyPressed() {
  if (!gameMenu) {
    switch(key) {
      //tårne
    case 'q':
    case 'Q':
      if (upgradeMenu == null) {
        //hvis tårnet allerede er valgt
        if (towerDragStatus == 5) towerDragStatus = -1;
        //hvis drag-and-drop ikke er i gang
        else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
          if (money >= towerButtons[0].price) towerDragStatus = 5;
        }
      }
      break;
    case 'w':
    case 'W':
      if (upgradeMenu == null) {
        if (towerDragStatus == 6) towerDragStatus = -1;
        else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
          if (money >= towerButtons[1].price) towerDragStatus = 6;
        }
      }
      break;
    case 'e':
    case 'E':
      if (upgradeMenu == null) {
        if (towerDragStatus == 7) towerDragStatus = -1;
        else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
          if (money >= towerButtons[2].price) towerDragStatus = 7;
        }
      }
      break;
    case 'r':
    case 'R':
      if (upgradeMenu == null) {
        if (towerDragStatus == 8) towerDragStatus = -1;
        else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
          if (money >= towerButtons[3].price) towerDragStatus = 8;
        }
      }
      break;
    case 't':
    case 'T':
      if (upgradeMenu == null) {
        if (towerDragStatus == 9) towerDragStatus = -1;
        else if (towerDragStatus > 4 || towerDragStatus == -1) if (abilityDragStatus == -1) {
          if (money >= towerButtons[4].price) towerDragStatus = 9;
        }
      }
      break;

      //cooldown evner
    case '1':
      if (upgradeMenu == null && !level.finished) {
        if (abilityDragStatus == 5) abilityDragStatus = -1;
        else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
          if (abilityButtons[0].cooldown == 0) {
            abilityDragStatus = 5;
          }
        }
      }
      break;
    case '2':
      if (upgradeMenu == null && !level.finished) {
        if (abilityDragStatus == 6) abilityDragStatus = -1;
        else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
          if (abilityButtons[1].cooldown == 0) {
            abilityDragStatus = 6;
          }
        }
      }
      break;
    case '3':
      if (upgradeMenu == null && !level.finished) {
        if (abilityDragStatus == 7) abilityDragStatus = -1;
        else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
          if (abilityButtons[2].cooldown == 0) {
            abilityDragStatus = 7;
          }
        }
      }
      break;
    case '4':
      if (upgradeMenu == null && !level.finished) {
        if (abilityDragStatus == 8) abilityDragStatus = -1;
        else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
          if (abilityButtons[3].cooldown == 0) {
            abilityDragStatus = 8;
          }
        }
      }
      break;
    case '5':
      if (upgradeMenu == null && !level.finished) {
        if (abilityDragStatus == 9) abilityDragStatus = -1;
        else if (abilityDragStatus > 4 || abilityDragStatus == -1) if (towerDragStatus == -1) {
          if (abilityButtons[4].cooldown == 0) {
            abilityDragStatus = 9;
          }
        }
      }
      break;

      //opgraderingsmenu genvejstaster
    case 'u':
    case 'U':
      if (upgradeMenu != null) {
        upgradeMenu.square.upgradeTower();
      } else {
        for (Square[] squareRow : squares) for (Square square : squareRow) {
          if (square.button.collision() && square.tower != null) {
            square.upgradeTower();
          }
        }
      }
      break;
    case 's':
    case 'S':
      if (upgradeMenu != null) {
        upgradeMenu.square.sellTower();
      } else {
        for (Square[] squareRow : squares) for (Square square : squareRow) {
          if (square.button.collision() && square.tower != null) {
            square.sellTower();
          }
        }
      }
      break;
    case ' ':
      if (level.finished) level.nextLevel();
      break;
    case '+':
      money += 1000;
      break;
    }
  }
  if (keyCode == ESC || key == 'p' || key == 'P') {
    key = 0;
    if (!frontPage) {
      towerDragStatus = -1;
      abilityDragStatus = -1;
      gameMenu = !gameMenu;
    }
  }
  if (howToPlay) howToPlay = false;
}


void initVariables() {
  music = new SoundFile(this, "Diverse/Relaxing Viking Music.wav");
  music.amp(0.4);
  music.loop();

  PFont font = createFont("Gadugi Bold", 10);
  textFont(font);

  //billederne er lavet i forhold til en 1920 * 1080 skærmopløsning
  //hvis spillerens skærmopløsning er anderledes vil billeder skaleres op
  resizeX = width/1920.0;
  resizeY = height/1080.0;

  gameMenu = true;
  frontPage = true;

  //spillemenu knapper
  int x1 = int(width * .35);
  int x2 = int(width * .65);

  int hei = int(height * .05);

  continueGame = new Button(x1, hei * 8, x2, hei * 9);
  newGame = new Button(x1, hei * 10, x2, hei * 11);
  toFrontPage = new Button(x1, hei * 10, x2, hei * 11);
  howToPlayButton = new Button(x1, hei * 12, x2, hei * 13);
  exit = new Button(x1, hei * 14, x2, hei * 15);

  muteButton = new Button(int(width * .013), int(height * .933), int(width * .042), int(height * .982));

  loadImgs();
}


void loadImgs() {
  //sprites
  fighter = cutSpriteSheet("Sprites/Fighter.png", 3, 2, 4);
  fighterlv2 = cutSpriteSheet("Sprites/Fighter_upgraded.png", 3, 2, 4);
  archer = cutSpriteSheet("Sprites/Archer.png", 3, 2, 5);
  archerlv2 = cutSpriteSheet("Sprites/Archer_upgraded.png", 3, 2, 5);
  priest = cutSpriteSheet("Sprites/Priest.png", 3, 2, 4);
  priestlv2 = cutSpriteSheet("Sprites/Priest_upgraded.png", 3, 2, 4);
  bomber = cutSpriteSheet("Sprites/Bomber.png", 3, 2, 6);
  bomberlv2 = cutSpriteSheet("Sprites/Bomber_upgraded.png", 3, 2, 6);
  freezer = cutSpriteSheet("Sprites/Freezer.png", 3, 2, 6);
  freezerlv2 = cutSpriteSheet("Sprites/Freezer_upgraded.png", 3, 2, 6);
  axemanWalk = cutSpriteSheet("Sprites/Axeman_walk.png", 3, 2, 4);
  axemanAttack = cutSpriteSheet("Sprites/Axeman_attack.png", 3, 2, 4);
  warriorWalk = cutSpriteSheet("Sprites/Warrior_walk.png", 3, 2, 4);
  warriorAttack = cutSpriteSheet("Sprites/Warrior_attack.png", 3, 2, 4);
  shieldwallWalk = cutSpriteSheet("Sprites/Shieldwall_walk.png", 3, 2, 4);
  shieldwallAttack = cutSpriteSheet("Sprites/Shieldwall_attack.png", 3, 2, 4);
  berserkerWalk = cutSpriteSheet("Sprites/Berserker_walk.png", 3, 2, 4);
  berserkerAttack = cutSpriteSheet("Sprites/Berserker_attack.png", 3, 2, 6);

  //projektiler
  fighterProjectile = loadAndResize("Projectiles/Fighter_projectile.png");
  fighterlv2Projectile = loadAndResize("Projectiles/Fighter_upgraded_projectile.png");
  archerProjectile = loadAndResize("Projectiles/Archer_projectile.png");
  archerlv2Projectile = loadAndResize("Projectiles/Archer_upgraded_projectile.png");
  freezerProjectile = loadAndResize("Projectiles/Freezer_projectile.png");
  freezerlv2Projectile = loadAndResize("Projectiles/Freezer_upgraded_projectile.png");
  bomberProjectile = loadAndResize("Projectiles/Bomber_projectile.png");
  bomberlv2Projectile = loadAndResize("Projectiles/Bomber_upgraded_projectile.png");

  //diverse
  upgradeIcon = loadAndResize("Diverse/Upgrade_icon.png");
  muteIcon = loadAndResize("Diverse/Sound_icon.png");
  particle = loadAndResize("Diverse/Particle.png");
  explosion = loadAndResize("Diverse/Explosion.png");
  potion = loadAndResize("Diverse/Potion.png");
  shadow = loadAndResize("Diverse/Shadow.png");
  logo = loadAndResize("Diverse/Logo.png");

  background = loadImage("Diverse/Background.png");
  background.resize(width, height);
  howToPlayScreen = loadImage("Diverse/HowToPlay.png");
  howToPlayScreen.resize(width, height);
  frontPageScreen = loadImage("Diverse/Frontpage.png");
  frontPageScreen.resize(width, height);
}

PImage loadAndResize(String location) {
  PImage pic = loadImage(location);
  pic.resize(int(resizeX * pic.width), int(resizeY * pic.height));

  return pic;
}



PImage[] cutSpriteSheet(String location, int colCount, int rowCount, int spriteCount) {
  PImage spriteSheet = loadImage(location);

  PImage[] sprites = new PImage[spriteCount];

  int wid = spriteSheet.width / colCount;
  int hei = spriteSheet.height / rowCount;

  for (int i = 0; i < spriteCount; i++) {
    int col = i % colCount;
    int row = i / colCount; //floor() tages automatisk da begge tal er heltal

    sprites[i] = spriteSheet.get(col * wid, row * hei, wid, hei);
    sprites[i].resize(int(sprites[i].width * resizeX), int(sprites[i].height * resizeY));
  }

  return sprites;
}


void startUp() {
  //starter et nyt spil
  towerDragStatus = -1;
  abilityDragStatus = -1;
  money = 400;
  level = new Level(0);

  projectiles = new ArrayList<Projectile>();
  particles = new ArrayList<Particle>();
  towerButtons = new TowerButton[5];
  abilityButtons = new AbilityButton[5];
  squares = new Square[10][5];

  upgradeMenu = null;
  gameOver = false;
  gameWon = false;
  gameBegun = true;
  level.nextLevelButton = new Button(int(width * .97), int(height * .95), int(width * .99), int(height * .99));


  //placering af hvert felt
  for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
    //-1 fordi der ellers ville være en kant med i venstre side og i toppen
    squares[i][j] = new Square(i * width / squares.length - 1, int(j * (915 * resizeY) / squares[0].length) - 1, (i + 1) * width / squares.length - 1, int((j + 1) * (915 * resizeY) / squares[0].length) - 1, i, j);
  }
  //placering af towerbuttons og abilitybuttons
  for (int i = 0; i < towerButtons.length; i++) {
    int x = int(i * width * 0.13 + 0.165 * width);

    towerButtons[i] = new TowerButton(x - int(width * 0.036), int(0.858 * height), x + int(width * 0.036), int(0.923 * height), i);
    abilityButtons[i] = new AbilityButton(x - int(0.017 * width), int(0.936 * height), x + int(0.017 * width), int(0.982 * height), i);
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
      for (AbilityButton ab : abilityButtons) if (ab.collision() && ab.cooldown == 0) {
        return true;
      }
      for (Square[] squareRow : squares) for (Square square : squareRow) {
        if (square.button.collision() && square.tower != null) {
          return true;
        }
      }
      if (level.nextLevelButton != null && level.nextLevelButton.collision()) return true;
    } else if (upgradeMenu.sellButton.collision() || upgradeMenu.exitButton.collision() || upgradeMenu.upgradeButton != null && upgradeMenu.upgradeButton.collision()) {
      return true;
    }
  } else if (!howToPlay) {
    if (continueGame.collision() && gameBegun || newGame.collision() && frontPage || howToPlayButton.collision() && frontPage || exit.collision() && frontPage || toFrontPage.collision() && !frontPage) {
      return true;
    } else if (muteButton.collision()) {
      return true;
    }
  } else return true;
  return false;
}



void displayGameMenu () {
  if (!howToPlay) {
    if (!frontPage) {
      //når spillet er pauset bliver baggrunden mørkere
      fill(0, 150);
      rect(0, 0, width, height);
    } else {
      background(frontPageScreen);
    }


    image(logo, width * .5, height * .21);

    textSize(.012 * width);
    //fortsæt spil knappen kan ikke bruges hvis der ikke er et spil igang
    if (!gameBegun) continueGame.display("Fortsæt spil", color(255, 125), 125);
    else {
      if (!continueGame.collision()) continueGame.display("Fortsæt spil", color(255), 255);
      else continueGame.display("Fortsæt spil", color(240), 255);
    }

    if (frontPage) {
      color c;

      if (!newGame.collision()) c = color(255);
      else c = color(240);
      newGame.display("Start nyt spil", c, 255);

      if (!howToPlayButton.collision()) c = color(255);
      else c = color(240);
      howToPlayButton.display("Hvordan man spiller", c, 255);

      if (!exit.collision()) c = color(255);
      else c = color(240);
      exit.display("Afslut", c, 255);
    } else {
      color c;
      if (!toFrontPage.collision()) c = color(255);
      else c = color(240);
      toFrontPage.display("Tilbage til forsiden", c, 255);
    }

    //muteknap
    muteButton.display("", color(255), 255);
    image(muteIcon, (muteButton.x1 + muteButton.x2) * .5, (muteButton.y1 + muteButton.y2) * .5);
    if (muted) {
      stroke(255, 0, 0);
      strokeWeight(3);
      line(muteButton.x2 - 2, muteButton.y1 + 2, muteButton.x1 + 2, muteButton.y2 - 2);
      strokeWeight(1);
      stroke(0);
    }
  } else {
    background(howToPlayScreen);
  }
}
