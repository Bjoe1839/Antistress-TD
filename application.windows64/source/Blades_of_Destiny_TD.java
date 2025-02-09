import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Blades_of_Destiny_TD extends PApplet {



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


public void setup() {
  

  //loading skærm
  background(0);
  fill(255);
  text("Loading...", 200, 200);

  rectMode(CORNERS);
  imageMode(CENTER);
  textAlign(CENTER, CENTER);

  initVariables();
}

public void draw() {
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
    textSize(.021f * width);
    text(money+"$", width*0.05f, height*0.9f);

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
      textSize(.1f * width);

      if (gameOver) text("GAME OVER", width * .5f, height * .6f);
      if (gameWon) text("Du vandt!", width * .5f, height * .6f);
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

public void mousePressed() {
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
        if (muted) music.amp(0.5f);
        else music.amp(0.0f);

        muted = !muted;
      }
    } else {
      howToPlay = false;
    }
  }
}


public void mouseReleased() {
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


public void keyPressed() {
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


public void initVariables() {
  music = new SoundFile(this, "Diverse/Relaxing Viking Music.wav");
  music.amp(0.4f);
  music.loop();

  PFont font = createFont("Gadugi Bold", 10);
  textFont(font);

  //billederne er lavet i forhold til en 1920 * 1080 skærmopløsning
  //hvis spillerens skærmopløsning er anderledes vil billeder skaleres op
  resizeX = width/1920.0f;
  resizeY = height/1080.0f;

  gameMenu = true;
  frontPage = true;

  //spillemenu knapper
  int x1 = PApplet.parseInt(width * .35f);
  int x2 = PApplet.parseInt(width * .65f);

  int hei = PApplet.parseInt(height * .05f);

  continueGame = new Button(x1, hei * 8, x2, hei * 9);
  newGame = new Button(x1, hei * 10, x2, hei * 11);
  toFrontPage = new Button(x1, hei * 10, x2, hei * 11);
  howToPlayButton = new Button(x1, hei * 12, x2, hei * 13);
  exit = new Button(x1, hei * 14, x2, hei * 15);

  muteButton = new Button(PApplet.parseInt(width * .013f), PApplet.parseInt(height * .933f), PApplet.parseInt(width * .042f), PApplet.parseInt(height * .982f));

  loadImgs();
}


public void loadImgs() {
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

public PImage loadAndResize(String location) {
  PImage pic = loadImage(location);
  pic.resize(PApplet.parseInt(resizeX * pic.width), PApplet.parseInt(resizeY * pic.height));

  return pic;
}



public PImage[] cutSpriteSheet(String location, int colCount, int rowCount, int spriteCount) {
  PImage spriteSheet = loadImage(location);

  PImage[] sprites = new PImage[spriteCount];

  int wid = spriteSheet.width / colCount;
  int hei = spriteSheet.height / rowCount;

  for (int i = 0; i < spriteCount; i++) {
    int col = i % colCount;
    int row = i / colCount; //floor() tages automatisk da begge tal er heltal

    sprites[i] = spriteSheet.get(col * wid, row * hei, wid, hei);
    sprites[i].resize(PApplet.parseInt(sprites[i].width * resizeX), PApplet.parseInt(sprites[i].height * resizeY));
  }

  return sprites;
}


public void startUp() {
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
  level.nextLevelButton = new Button(PApplet.parseInt(width * .97f), PApplet.parseInt(height * .95f), PApplet.parseInt(width * .99f), PApplet.parseInt(height * .99f));


  //placering af hvert felt
  for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
    //-1 fordi der ellers ville være en kant med i venstre side og i toppen
    squares[i][j] = new Square(i * width / squares.length - 1, PApplet.parseInt(j * (915 * resizeY) / squares[0].length) - 1, (i + 1) * width / squares.length - 1, PApplet.parseInt((j + 1) * (915 * resizeY) / squares[0].length) - 1, i, j);
  }
  //placering af towerbuttons og abilitybuttons
  for (int i = 0; i < towerButtons.length; i++) {
    int x = PApplet.parseInt(i * width * 0.13f + 0.165f * width);

    towerButtons[i] = new TowerButton(x - PApplet.parseInt(width * 0.036f), PApplet.parseInt(0.858f * height), x + PApplet.parseInt(width * 0.036f), PApplet.parseInt(0.923f * height), i);
    abilityButtons[i] = new AbilityButton(x - PApplet.parseInt(0.017f * width), PApplet.parseInt(0.936f * height), x + PApplet.parseInt(0.017f * width), PApplet.parseInt(0.982f * height), i);
  }
}





//om musen holder over en knap og skal markeres med en hånd i stedet for en pil
public boolean hovering() {

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



public void displayGameMenu () {
  if (!howToPlay) {
    if (!frontPage) {
      //når spillet er pauset bliver baggrunden mørkere
      fill(0, 150);
      rect(0, 0, width, height);
    } else {
      background(frontPageScreen);
    }


    image(logo, width * .5f, height * .21f);

    textSize(.012f * width);
    //fortsæt spil knappen kan ikke bruges hvis der ikke er et spil igang
    if (!gameBegun) continueGame.display("Fortsæt spil", color(255, 125), 125);
    else {
      if (!continueGame.collision()) continueGame.display("Fortsæt spil", color(255), 255);
      else continueGame.display("Fortsæt spil", color(240), 255);
    }

    if (frontPage) {
      int c;

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
      int c;
      if (!toFrontPage.collision()) c = color(255);
      else c = color(240);
      toFrontPage.display("Tilbage til forsiden", c, 255);
    }

    //muteknap
    muteButton.display("", color(255), 255);
    image(muteIcon, (muteButton.x1 + muteButton.x2) * .5f, (muteButton.y1 + muteButton.y2) * .5f);
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
class Button {
  int x1, y1, x2, y2;

  Button(int x1_, int y1_, int x2_, int y2_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;
  }

  public boolean collision() {
    if (mouseX >= x1 && mouseX <= x2 && mouseY >= y1 && mouseY <= y2) {
      return true;
    }
    return false;
  }

  public void display(String text, int c, int alfa) {
    fill(c);
    rect(x1, y1, x2, y2, 5);
    fill(0, alfa);
    text(text, (x1 + x2) * .5f, (y1 + y2) * .5f - 5);
  }
}


class DragButton extends Button {
  int towerNum;
  String text;

  DragButton(int x1, int y1, int x2, int y2, int towerNum_) {
    super(x1, y1, x2, y2);
    towerNum = towerNum_;
  }

  public void display(int status) {
    //'skygge' under knappen
    noStroke();
    fill(100, 50, 0);
    rect(x1 + 2, y1 + 6, x2 + 2, y2 + 6, 15);
    stroke(0);

    //status 0 er almidelig, status 1 er holder over, status 2 er har ikke råd og status 3 er trykket ned
    if (status < 3) {
      if (status == 0 || status == 2) fill(255);
      else fill(240);

      rect(x1, y1, x2, y2, 15);
    } else {
      fill(240);
      rect(x1 + 1, y1 + 3, x2 + 1, y2 + 3, 15);
    }


    //beskrivelses boks
    if (status == 1 || status == 2) {
      if (status == 1) fill(255, 200);
      else fill(255, 180, 180, 200);

      int len = PApplet.parseInt(width * 0.07f);
      rect(mouseX - len, y1 - 220, mouseX + len, y1 - 10, 15);
      fill(0);
      textSize(.009f * width);
      textAlign(CORNER);
      text(text, mouseX - len + 7, y1 - 200);
      textAlign(CENTER, CENTER);
    }
    fill(0);
  }
}


class TowerButton extends DragButton {
  int price;
  PImage towerImg;

  TowerButton(int x1, int y1, int x2, int y2, int towerNum) {
    super(x1, y1, x2, y2, towerNum);

    //beskrivelsestekst, pris og tårne
    switch(towerNum) {
    case 0:
      text = "Fodsoldat\nSkader en del.\nKan ikke skyde så langt.\n \nGenvejstast: Q";
      price = 100;
      towerImg = fighter[0].copy();
      break;
    case 1:
      text = "Bueskytte\nKan skyde på hele sin lane.\nSkader ikke så meget.\n \nGenvejstast: W";
      price = 125;
      towerImg = archer[0].copy();
      break;
    case 2:
      text = "Sneboldkaster\nKaster med snebolde der gør\nmodstandere langsommere i et\nstykke tid.\n \nGenvejstast: E";
      price = 175;
      towerImg = freezer[0].copy();
      break;
    case 3:
      text = "Præst\nBooster tårne rundt om ham så\nde skader mere og skyder\nhurtigere og et felt længere.\n \nGenvejstast: R";
      price = 200;
      towerImg = priest[0].copy();
      break;
    case 4:
      text = "Kanon\nSkyder skud der skader i et\nstørre område der også kan\nramme andre lanes.\n \nGenvejstast: T";
      price = 325;
      towerImg = bomber[0].copy();
      break;
    }
    towerImg.resize(0, PApplet.parseInt(towerImg.height * .5f * resizeY));
  }

  public void display(int status) {
    super.display(status);

    int x = PApplet.parseInt((x2 - x1) * .3f + x1);
    int y = PApplet.parseInt((y2 + y1) * .5f);


    if (status == 3) {
      x++;
      y += 3;
    }

    if (money < price) fill(200, 0, 0);
    else fill(0, 200, 0);
    textSize(.012f * width);

    textAlign(RIGHT, CENTER);
    text(price+"$", x + (x2 - x1) * .67f, y);
    textAlign(CENTER, CENTER);

    image(towerImg, x, y);
  }
}



class AbilityButton extends DragButton {
  int cooldown, cooldownDur;

  AbilityButton(int x1, int y1, int x2, int y2, int towerNum) {
    super(x1, y1, x2, y2, towerNum);
    switch(towerNum) {
    case 0:
      text = "Med denne evne skyder\nfodsoldaten tre gange så\nhurtigt i tre sekunder.\n\nGenvejstast: 1\n";
      cooldownDur = 20 * 60;
      break;
    case 1:
      text = "Med denne evne skyder\nbueskytten en masse skud på\nkort tid.\n\nGenvejstast: 2";
      cooldownDur = 20 * 60;
      break;
    case 2:
      text = "Med denne evne fryser\nsneboldskasteren alle tårne på\nskærmen i et stykke tid.\n\nGenvejstast: 3";
      cooldownDur = 20 * 60;
      break;
    case 3:
      text = "Med denne evne heler præsten\nalle dine tårne.\n\nGenvejstast: 4";
      cooldownDur = 30 * 60;
      break;
    case 4:
      text = "Med denne evne bliver\nkanonens næste skud tre gange\nmere skadende og skader et\nstørre område.\n\nGenvejstast: 5";
      cooldownDur = 30 * 60;
      break;
    }
  }

  public void display(int status) {
    super.display(status);

    if (cooldown > 0 && !gameMenu) cooldown--;

    int x = PApplet.parseInt((x2 + x1) * .5f);
    int y = PApplet.parseInt((y2 + y1) * .5f);

    if (status == 3) {
      x++;
      y += 3;
    }
    if (cooldown == 0) image(potion, x, y);
    else {
      tint(255, 150, 150);
      image(potion, x, y);
      noTint();

      //cooldownbar
      int barX = PApplet.parseInt(map(cooldown, 0, cooldownDur, x1, x2));
      fill(0, 0, 200);
      rect(x1, y2 + (9 * resizeY), barX, y2 + (14 * resizeY), 3);
    }
  }
}
class Level {
  int num, dur;
  float cooldown;
  int opponentSpawnRate;
  int startFrame;
  int axemanChance, warriorChance, shieldwallChance;
  boolean finished;
  ArrayList<OpponentTower> opponentTowers;

  Button nextLevelButton;

  Level(int num_) {
    num = num_;
    dur = 30;
    cooldown = dur;
    opponentTowers = new ArrayList<OpponentTower>();
    finished = true;

    setStats();
  }

  public void setStats() {
    switch(num) {
    case 0:
      //i første bane er der 100% chance for at en axeman kommer og de spawner hvert 500. frame
      opponentSpawnRate = 500;
      axemanChance = 100;
      warriorChance = 0;
      shieldwallChance = 0;
      break;
    case 1:
      opponentSpawnRate = 350;
      axemanChance = 75;
      warriorChance = 25;
      shieldwallChance = 0;
      break;
    case 2:
      opponentSpawnRate = 300;
      axemanChance = 40;
      warriorChance = 50;
      shieldwallChance = 10;
      break;
    case 3:
      opponentSpawnRate = 250;
      axemanChance = 10;
      warriorChance = 70;
      shieldwallChance = 20;
      break;
    case 4:
      opponentSpawnRate = 200;
      axemanChance = 0;
      warriorChance = 60;
      shieldwallChance = 30; //de resterende procent er berserkerchance
      break;
    case 5:
      opponentSpawnRate = 100;
      axemanChance = 0;
      warriorChance = 35;
      shieldwallChance = 30;
      break;
    }
  }

  public void opponentHandler() {
    if (!finished) {
      if (cooldown > 0) {
        //progressbaren opdaterer hvert sekund
        if (frameCount%60 == 0) {
          cooldown -= .5f;
          if (cooldown < 0) cooldown = 0;
        }
      } else if (opponentTowers.size() == 0 && projectiles.size() == 0) {
        //banen er først slut når alle modstandere er klaret, projektiler er væk og der ikke er en animation i gang (bortset fra præsten)
        boolean animation = false;
        for (Square[] squareRow : squares) for (Square square : squareRow) {
          if (square.tower != null && square.tower.spriteIndex != 0 && square.tower.towerNum != 3) animation = true;
        }
        if (!animation) {
          //når en bane er slut
          if (num < 5) {
            abilityDragStatus = -1;
            for (AbilityButton ab : abilityButtons) ab.cooldown = 0;
            finished = true;
            nextLevelButton = new Button(PApplet.parseInt(width * .97f), PApplet.parseInt(height * .95f), PApplet.parseInt(width * .99f), PApplet.parseInt(height * .99f));
          } else {
            gameWon = true;
            gameMenu = true;
            gameBegun = false;
          }
        }
      }

      //om der skal spawne en modstander
      if (frameCount % opponentSpawnRate == startFrame && cooldown > 0 || cooldown < dur * .1f && cooldown > 0 && frameCount % (opponentSpawnRate * .2f) == 0) {
        //random lane
        int laneNum = PApplet.parseInt(random(5));
        int y = PApplet.parseInt((squares[0][laneNum].y1 + squares[0][laneNum].y2) * .5f);
        int offset = PApplet.parseInt(random(-height * .02f, height * .02f));
        y += offset;
        int opponentNum;

        int r = PApplet.parseInt(random(100));
        if (r < axemanChance) {
          opponentNum = 0;
        } else {
          r -= axemanChance;
          if (r < warriorChance) opponentNum = 1;
          else {
            r -= warriorChance;
            if (r < shieldwallChance) opponentNum = 2;
            else {
              opponentNum = 3;
            }
          }
        }
        opponentTowers.add(new OpponentTower(y, laneNum, opponentNum));
      }
      for (OpponentTower ot : opponentTowers) {
        ot.move();
        ot.display();
      }
    }
  }

  public void nextLevel() {
    if (cooldown <= 0) num++;
    cooldown = dur;
    setStats();
    nextLevelButton = null;
    finished = false;

    //mostanderne skal spawne med lige lang tid mellem hinanden
    //og den første skal spawne framen efter man har trykket play
    startFrame = frameCount%opponentSpawnRate + 1;
  }

  public void displayProgressbar() {
    fill(255);
    rect(width * .8f, height * .87f, width * .99f, height * .92f);

    int x = round(map(cooldown, 0, dur, width * .8f, width * .99f));
    fill(0, 255, 0);
    rect(x, height * .87f, width * .99f, height * .92f);


    textSize(.012f * width);
    textAlign(RIGHT, TOP);
    fill(0);
    text("Level "+(num+1)+" af 6", width * .99f, height * .92f);
    textAlign(CENTER, CENTER);


    if (nextLevelButton != null) {
      nextLevelButton.display("", color(255), 255);

      if (frameCount%120 < 60 || gameMenu) {
        fill(0, 255, 0);
        triangle(nextLevelButton.x1 + 5, nextLevelButton.y1 + 5, nextLevelButton.x1 + 5, nextLevelButton.y2 - 5, nextLevelButton.x2 - 5, (nextLevelButton.y2 + nextLevelButton.y1) * .5f);
      }
    }
  }
}
class Particle {
  int x, y;
  int lifespan;
  PImage img;

  Particle(int x_, int y_) {
    x = x_;
    y = y_;
    lifespan = 50;
    img = particle;
  }

  public void move() {
    lifespan--;
    y--;
  }

  public void display() {
    //toner mere og mere ud jo mindre lifespan bliver
    int alfa = PApplet.parseInt(map(lifespan, 0, 50, 0, 255));

    tint(255, alfa);
    image(img, x, y);
    noTint();
  }
}


class Explosion extends Particle {
  int size;
  
  Explosion(int x, int y, int size_) {
    super(x, y);
    size = size_;
    img = explosion.copy();
    img.resize(size*2, 0);
  }
  
  public void move() {
    //eksposionen bevæger sig ikke opad og toner dobbelt så hurtigt ud
    lifespan -= 2;
  }
}
class Projectile {
  int x, y, rangeX, laneNum;
  int speed, damage, size;
  boolean upgraded;

  Projectile(int x_, int y_, int offset, int laneNum_, int range, boolean upgraded_) {
    x = x_ + offset; //skal spawne på højre side af spriten
    y = y_;
    laneNum = laneNum_;
    rangeX = PApplet.parseInt(range * (width / squares.length - 1) + (width / squares.length - 1) * .5f) + x - offset;
    upgraded = upgraded_;
  }

  public boolean move() {
    x += speed;

    if (x > rangeX || x + size/2 > width) {
      projectiles.remove(this);
      return true;
    }

    for (OpponentTower ot : level.opponentTowers) {
      //om projektilet rammer en modstander
      if (ot.laneNum == laneNum && ot.x + ot.offsetR >= x - size/2 && ot.x - ot.offsetL <= x + size/2) {

        opponentHit(ot);

        projectiles.remove(this);
        return true;
      }
    }
    return false;
  }

  public void display() {
    fill(0);
    circle(x, y, size);
  }

  public void opponentHit(OpponentTower opponent) {
    opponent.health -= damage;
    
    if (opponent.health <= 0) {
      money += opponent.worth;
      level.opponentTowers.remove(opponent);
    }
  }
}



class FighterProjectile extends Projectile {

  FighterProjectile(int x, int y, int offset, int damage_, int laneNum, int range, boolean upgraded) {
    super(x, y, offset, laneNum, range, upgraded);
    damage = damage_;
    if (!upgraded) {
      size = fighterProjectile.width;
      speed = 6;
    } else {
      size = fighterlv2Projectile.width;
      speed = 7;
    }
  }

  public void display() {
    if (!upgraded) image(fighterProjectile, x, y);
    else image(fighterlv2Projectile, x, y);
  }
}

class ArcherProjectile extends Projectile {
  ArcherProjectile(int x, int y, int offset, int damage_, int laneNum, int range, boolean upgraded) {
    super(x, y, offset, laneNum, range, upgraded);

    damage = damage_;
    if (!upgraded) {
      size = archerProjectile.width;
      speed = 15;
    } else {
      size = archerlv2Projectile.width;
      speed = 20;
    }
  }

  public void display() {
    if (!upgraded) image(archerProjectile, x, y);
    else image(archerlv2Projectile, x, y);
  }
}


class FreezerProjectile extends Projectile {
  int slowDur, freezeDur;
  float angle;
  FreezerProjectile(int x, int y, int offset, int damage_, int laneNum, int range, int slowDur_, int freezeDur_, boolean upgraded) {
    super(x, y, offset, laneNum, range, upgraded);
    speed = 8;
    damage = damage_;
    size = 10;
    slowDur = slowDur_;
    freezeDur = freezeDur_;
  }

  public void display() {
    if (!upgraded) {
      //skal rotere
      if (!gameMenu) angle += .3f;

      pushMatrix();
      translate(x, y);
      rotate(angle);
      image(freezerProjectile, 0, 0);
      popMatrix();
    } else image(freezerlv2Projectile, x, y);
  }

  public void opponentHit(OpponentTower opponent) {
    super.opponentHit(opponent);

    //gør modstandere langsommere
    opponent.slowCooldown += slowDur;
    opponent.freezeCooldown += freezeDur;
  }
}

class BomberProjectile extends Projectile {
  int explosionSize;
  float angle;
  BomberProjectile(int x, int y, int offset, int damage_, int laneNum, int range, boolean upgraded, int explosionSize_) {
    super(x, y, offset, laneNum, range, upgraded);
    speed = 6;
    damage = damage_;
    size = 30;
    explosionSize = explosionSize_;
  }

  public void opponentHit(OpponentTower opponent) {
    //alle modstandere med en hvis afstand til projektilet bliver skadede
    for (int i = level.opponentTowers.size()-1; i >= 0; i--) {
      if (dist(x, y, level.opponentTowers.get(i).x, level.opponentTowers.get(i).y) < explosionSize) {
        level.opponentTowers.get(i).health -= damage;
        
        if (level.opponentTowers.get(i).health <= 0) {
          money += level.opponentTowers.get(i).worth;
          level.opponentTowers.remove(level.opponentTowers.get(i));
        }
      }
    }
    particles.add(new Explosion(x, y, PApplet.parseInt(explosionSize * .75f)));
  }

  public void display() {
    if (!gameMenu) angle += .15f;

    pushMatrix();
    translate(x, y);
    rotate(angle);

    if (!upgraded) image(bomberProjectile, 0, 0);
    else image(bomberlv2Projectile, 0, 0);
    popMatrix();
  }
}
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

  public void activateTower() {
    if (tower != null) tower.activate();
  }

  public void display() {
    if (boostingStatus > 0) {
      //chance for at tilføje en partikel et tilfældigt sted på feltet
      if (!gameMenu && random(1) < 0.01f) {
        int x = PApplet.parseInt(random(x1, x2));
        int y = PApplet.parseInt(random(y1, y2));
        particles.add(new Particle(x, y));
      }
    }

    if (tower != null) {
      if (tower.health > 0) {
        tower.display();
        //tegner opgraderingsikon hvis man har nok penge til at opgradere
        if (money >= tower.upgradePrice && !tower.upgraded) {
          int x = PApplet.parseInt((x2 - x1) * .7f + x1);
          int y = PApplet.parseInt((y2 - y1) * .77f + y1);

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
      int x = PApplet.parseInt((x2 + x1) * .5f);
      int y = PApplet.parseInt((y2 + y1) * .5f);

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

  public void addTower() {
    int x = PApplet.parseInt((x2 + x1) * .5f);
    int y = PApplet.parseInt((y2 + y1) * .5f);

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
      
      //booster omkringliggende felter
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

  public void darken() {
    fill(0, 100);
    rect(x1, y1, x2, y2);
  }

  public void lighten() {
    fill(255, 100);
    rect(x1, y1, x2, y2);
  }

  public void displayBoostRange() {
    //markerer de felter en præst kan booste i et 3*3 tern
    for (int x = -1; x < 2; x++) for (int y = -1; y < 2; y++) {
      if (colNum + x >= 0 && colNum + x < squares.length && rowNum + y >= 0 && rowNum + y < squares[0].length) {
        squares[colNum + x][rowNum + y].lighten();
      }
    }
  }

  public void displayShotRange() {
    int range;

    if (tower != null) {
      range = ((ShooterTower)tower).range;
    } else {
      //laver et midlertidigt tårn for at finde dets rækkevidde
      ShooterTower dragTower;
      if (towerDragStatus%5 == 0) dragTower = new Fighter(0, 0, 0, 0);
      else if (towerDragStatus%5 == 1) dragTower = new Archer(0, 0, 0, 0);
      else if (towerDragStatus%5 == 2) dragTower = new Freezer(0, 0, 0, 0);
      else dragTower = new Bomber(0, 0, 0, 0);

      range = dragTower.range;
      if (boostingStatus > 0) range++;
    }

    //markerer rækkevidden ved at lysne felterne til højre for tårnet
    for (int x = 0; x <= range; x++) {
      if (colNum + x < squares.length) {
        squares[colNum + x][rowNum].lighten();
      }
    }
  }

  public void sellTower() {
    money += tower.actualWorth;
    
    //hvis man sælger en priest skal de boostede felter opdateres
    if (tower.towerNum == 3) {
      updateBoost();
    }
    tower = null;
    upgradeMenu = null;
  }

  public void upgradeTower() {
    if (!tower.upgraded && money >= tower.upgradePrice) {
      money -= tower.upgradePrice;

      tower.upgraded = true;
      tower.setStats(boostingStatus);
      upgradeMenu = null;

      if (tower.towerNum == 3) {
        //booster omkringliggende tårne
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

  public void updateBoost() {
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
class Tower {
  float x;
  int y;
  int health, maxHealth;
  int worth;
  int offsetL, offsetR; //hvor billedets kollision strækker sig over

  Tower(int x_, int y_, int offsetL_, int offsetR_) {
    x = x_;
    y = y_;
    offsetL = PApplet.parseInt(offsetL_ * resizeX);
    offsetR = PApplet.parseInt(offsetR_ * resizeX);
  }

  Tower(int y_) {
    y = y_;
  }

  public void shadow() {
    image(shadow, x, y);
  }

  public void display() {
    //healthbar
    
    stroke(0, 70);

    //farven bliver mere og mere rød jo mere liv der mistes
    int c = PApplet.parseInt(map(health, 0, maxHealth, 0, 255));
    fill(255-c, c, 0, 150);

    int len = PApplet.parseInt(30 * resizeX);
    int hei = PApplet.parseInt(70 * resizeY);

    int xEnd = PApplet.parseInt(map(health, 0, maxHealth, x - len, x + len));
    rect(x - len, y - hei, xEnd, y - hei + PApplet.parseInt(5 * resizeY));
    stroke(0);
  }
}


class FriendlyTower extends Tower {
  PImage[] sprite;
  int towerNum, actualWorth, upgradePrice;
  float spriteIndex;
  boolean upgraded;

  FriendlyTower(int x, int y, int offsetL, int offsetR, int towerNum_) {
    super(x, y, offsetL, offsetR);
    towerNum = towerNum_;
  }

  public void display() {
    super.display();

    image(sprite[floor(spriteIndex)], x, y);
  }

  public void activate() {
  }

  public void setStats(int boostingStatus) {
  }

  public void ability() {
  }
}





class ShooterTower extends FriendlyTower {
  int range, damage, shotSpeed, shotCooldown, laneNum;
  boolean hasShot;

  ShooterTower(int x, int y, int offsetL, int offsetR, int towerNum, int laneNum_) {
    super(x, y, offsetL, offsetR, towerNum);
    laneNum = laneNum_;
  }


  public void activate() {
    //hvis en animation er i gang
    if (spriteIndex > 0) {
      if (spriteIndex >= sprite.length-1) {
        if (!hasShot) {
          shoot();
          hasShot = true;
        }
        if (spriteIndex >= sprite.length) {
          spriteIndex = 0;
          hasShot = false;
        }
      }
    }

    if (shouldShoot()) {
      //hvis en animation allerede er i gang
      if (spriteIndex > 0 && !hasShot) {
        shoot();
      }
      spriteIndex = 1;
      hasShot = false;
    }
  }

  public boolean shouldShoot() {
    shotCooldown--;

    if (inRange() && shotCooldown <= 0) {
      shotCooldown = shotSpeed;
      return true;
    }
    return false;
  }

  public boolean inRange() {
    for (OpponentTower opponent : level.opponentTowers) {
      int d = PApplet.parseInt(opponent.x - opponent.offsetL - x);
      if (opponent.laneNum == laneNum && d < range * (width/squares.length-1) + (width/squares.length-1) * .5f && d >= 0) {
        return true;
      }
    }
    return false;
  }

  public void setStats(int boostingStatus) {
    //hvis tårnet er boostet med en almindelig priest
    if (boostingStatus == 1) {
      shotSpeed *= .9f;
      damage *= 1.1f;
      if (range < 9) range++;

      //hvis tårnet er boostet med en opgraderet priest
    } else if (boostingStatus == 2) {
      shotSpeed *= .8f;
      damage *= 1.2f;
      if (range < 9) range++;
    }
  }

  public void shoot() {
  }
}






class Fighter extends ShooterTower {
  int abilityCooldown, abilityShotSpeed;

  Fighter(int x, int y, int boostingStatus, int laneNum) {
    super(x, y, 13, 19, 0, laneNum);

    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 150;
    abilityShotSpeed = PApplet.parseInt(shotSpeed * .33f);
  }

  public void activate() {
    //hvis cooldown ability er aktiveret
    if (abilityCooldown > 0) {
      shotCooldown--;
      abilityCooldown--;
      if (inRange() && shotCooldown <= shotSpeed-abilityShotSpeed) {
        //hvis en animation allerede er i gang
        if (spriteIndex > 0 && !hasShot) {
          projectiles.add(new FighterProjectile(PApplet.parseInt(x), y, offsetR, damage, laneNum, range, upgraded));
        }
        shotCooldown = shotSpeed;
        spriteIndex = 1;
        hasShot = false;
      }
    }
    if (spriteIndex > 0) spriteIndex += 0.1f;

    super.activate();
  }

  public void shoot() {
    projectiles.add(new FighterProjectile(PApplet.parseInt(x), y, offsetR, damage, laneNum, range, upgraded));
  }

  public void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = fighter;
      worth = 70;
      actualWorth = worth;
      maxHealth = 100;
      shotSpeed = 180;
      damage = 11;
    } else {
      sprite = fighterlv2;
      worth = 175;
      actualWorth = PApplet.parseInt(map(health, 0, maxHealth, 0, worth));
      shotSpeed = 120;
      damage = 16;

      //skal have samme procentvise liv som før
      int temp = maxHealth;
      maxHealth = 150;
      health = PApplet.parseInt(map(health, 0, temp, 0, maxHealth));
    }
    range = 2;
    
    super.setStats(boostingStatus);
  }

  public void ability() {
    abilityCooldown = 120;
  }
}




class Archer extends ShooterTower {
  int abilityCooldown;

  Archer(int x, int y, int boostingStatus, int laneNum) {
    super(x, y, 21, 19, 1, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 175;
  }

  public void activate() {
    //hvis cooldown ability er aktiveret
    if (abilityCooldown > 0) {
      spriteIndex++;
      abilityCooldown--;
      shotCooldown = shotSpeed;
      //hvis cooldown abilityen er slut
      if (abilityCooldown == 0) {
        spriteIndex = 0;
        shotCooldown = 0;
      }
    } else if (spriteIndex > 0) spriteIndex += 0.08f;

    super.activate();
  }

  public void shoot() {
    projectiles.add(new ArcherProjectile(PApplet.parseInt(x), y - PApplet.parseInt(16  * resizeX), offsetR, damage, laneNum, range, upgraded));
  }

  public void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = archer;
      worth = 85;
      actualWorth = worth;
      maxHealth = 100;
      shotSpeed = 100;
      damage = 4;
    } else {
      sprite = archerlv2;
      worth = 205;
      actualWorth = PApplet.parseInt(map(health, 0, maxHealth, 0, worth));
      damage = 8;
      shotSpeed = 85;
    }
    range = 9;
    super.setStats(boostingStatus);
  }

  public void ability() {
    abilityCooldown = 90;
  }
}


class Freezer extends ShooterTower {
  int slowDur, freezeDur;

  Freezer(int x, int y, int boostingStatus, int laneNum) {
    super(x, y, 22, 19, 2, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 225;
  }

  public void activate() {
    if (spriteIndex > 0) spriteIndex += .12f;
    super.activate();
  }

  public void shoot() {
    projectiles.add(new FreezerProjectile(PApplet.parseInt(x), y - PApplet.parseInt(37 * resizeY), offsetR, damage, laneNum, range, slowDur, freezeDur, upgraded));
  }

  public void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = freezer;
      worth = 120;
      actualWorth = worth;
      maxHealth = 125;
      shotSpeed = 240;
      damage = 0;
      slowDur = 60;
      freezeDur = 0;
    } else {
      sprite = freezerlv2;
      slowDur = 90;
      freezeDur = 60;
      worth = 275;
      actualWorth = PApplet.parseInt(map(health, 0, maxHealth, 0, worth));
      damage = 10;
    }
    range = 5;
    
    super.setStats(boostingStatus);
  }

  public void ability() {
    //fryser alle modstandere
    for (OpponentTower opponent : level.opponentTowers) {
      opponent.freezeCooldown += 120;
      opponent.slowCooldown += 120;
    }
  }
}



class Bomber extends ShooterTower {
  boolean ability;
  int explosionSize;
  
  Bomber(int x, int y, int boostingStatus, int laneNum) {
    super(x, y, 35, 58, 4, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 300;
  }


  public void activate() {
    if (spriteIndex > 0) spriteIndex += .1f;
    super.activate();
  }

  public void shoot() {
    if (!ability) projectiles.add(new BomberProjectile(PApplet.parseInt(x), y + PApplet.parseInt(7 * resizeY), offsetR, damage, laneNum, range, upgraded, explosionSize));
    else {
      //ved ability er skaden tredoblet og området større
      projectiles.add(new BomberProjectile(PApplet.parseInt(x), y + PApplet.parseInt(7 * resizeY), offsetR, damage * 3, laneNum, range, upgraded, explosionSize + PApplet.parseInt(50 * resizeX)));
      ability = false;
    }
  }

  public void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = bomber;
      worth = 225;
      actualWorth = worth;
      maxHealth = 175;
      shotSpeed = 300;
      damage = 15;
      explosionSize = PApplet.parseInt(250 * resizeX);
    } else {
      sprite = bomberlv2;
      worth = 435;
      actualWorth = PApplet.parseInt(map(health, 0, maxHealth, 0, worth));
      explosionSize = PApplet.parseInt(300 * resizeX);
      damage = 20;
    }
    range = 4;
    super.setStats(boostingStatus);
  }
  
  public void ability() {
    ability = true;
    if (spriteIndex == 0) spriteIndex = 1;
  }
}


class Priest extends FriendlyTower {
  int cooldown;

  Priest(int x, int y) {
    super(x, y, 27, 19, 3);
    setStats(0);
    health = maxHealth;
    upgradePrice = 150;
  }

  public void activate() {
    if (spriteIndex > 0) {
      spriteIndex += .06f;
      if (spriteIndex >= sprite.length) spriteIndex = 0;
    }
    if (!level.finished) {
      //begynder animation hver gang cooldown når 0
      cooldown--;
      if (cooldown <= 0) {
        cooldown = 150;
        spriteIndex = 1;
      }
    }
  }

  public void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = priest;
      worth = 140;
      actualWorth = worth;
      maxHealth = 125;
    } else {
      sprite = priestlv2;
      worth = 245;
      actualWorth = PApplet.parseInt(map(health, 0, maxHealth, 0, worth));
    }
  }
  
  public void ability() {
    //heler alle tårne med 50%
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      if (square.tower != null) {
        square.tower.health += square.tower.maxHealth * .5f;
        if (square.tower.health > square.tower.maxHealth) square.tower.health = square.tower.maxHealth;
      }
    }
  }
}



class OpponentTower extends Tower {
  int laneNum, opponentNum;
  int damage;
  float speed;
  int slowCooldown, freezeCooldown;
  float indexAttack, indexWalk, indexWalkSpeed, indexAttackSpeed;
  Square collisionTower;
  PImage[] spriteWalk, spriteAttack;


  OpponentTower(int y, int laneNum_, int opponentNum_) {
    super(y);
    laneNum = laneNum_;
    opponentNum = opponentNum_;
    setStats();
  }

  public void move() {
    collisionTower = null;
    //tjekker kun for kollision for tårne på egen lane

    for (int i = 0; i < squares.length; i++) {
      if (squares[i][laneNum].tower != null && squares[i][laneNum].tower.x + squares[i][laneNum].tower.offsetR >= x - offsetL && squares[i][laneNum].tower.x - squares[i][laneNum].tower.offsetL <= x + offsetR) {
        collisionTower = squares[i][laneNum];
      }
    }
    if (freezeCooldown > 0) freezeCooldown--;

    if (slowCooldown > 0 && freezeCooldown == 0) slowCooldown--;

    //skal kun bevæge sig når den ikke er kollideret eller frosset
    if (collisionTower == null && freezeCooldown == 0) {
      
      //bevæger sig halvt så hurtigt hvis den er blevet ramt af frysetårnet
      if (slowCooldown > 0) x -= speed * .5f;
      else x -= speed;

      if (x + offsetR < 0) {
        gameOver = true;
        gameMenu = true;
        gameBegun = false;
      }
    }

    if (freezeCooldown == 0) {
      float indexSpeed;
      //hvis modstanderen er kollideret skal hans animation være at angribe i stedet for at gå
      if (collisionTower != null) indexSpeed = indexAttackSpeed;
      else indexSpeed = indexWalkSpeed;

      if (slowCooldown > 0) {
        indexSpeed *= .5f;
      }

      if (collisionTower != null) indexAttack += indexSpeed;
      else indexWalk += indexSpeed;

      if (indexAttack >= spriteAttack.length) indexAttack = 0;

      //om modstanderen skal skade tårnet (berserker skader to gange på en animation)
      else if (indexAttack >= spriteAttack.length-1 && indexAttack < spriteAttack.length-1 + indexSpeed ||
        opponentNum == 3 && indexAttack >= spriteAttack.length-2 && indexAttack < spriteAttack.length-2 + indexSpeed) {
        if (collisionTower != null) {
          collisionTower.tower.health -= damage;
          collisionTower.tower.actualWorth = PApplet.parseInt(map(collisionTower.tower.health, 0, collisionTower.tower.maxHealth, 0, collisionTower.tower.worth));
        }
      }

      if (indexWalk >= spriteWalk.length) indexWalk = 0;
    }
  }

  public void display() {
    super.display();

    if (freezeCooldown > 0) tint(150, 150, 255);
    else if (slowCooldown > 0) tint(200, 200, 255);

    if (collisionTower != null) image(spriteAttack[floor(indexAttack)], x, y);
    else image(spriteWalk[floor(indexWalk)], x, y);

    noTint();
  }

  public void setStats() {
    if (opponentNum == 0) {
      //axeman
      speed = .6f;
      damage = 10;
      maxHealth = 40;
      worth = 30;
      indexWalkSpeed = 0.05f;
      indexAttackSpeed = 0.15f;

      x = width + PApplet.parseInt(37 * resizeX);
      offsetL = PApplet.parseInt(21 * resizeX);
      offsetR = PApplet.parseInt(19 * resizeX);

      spriteWalk = axemanWalk;
      spriteAttack = axemanAttack;
    } else if (opponentNum == 1) {
      //warrior
      speed = .75f;
      damage = 14;
      maxHealth = 80;
      worth = 60;
      indexWalkSpeed = 0.06f;
      indexAttackSpeed = 0.12f;

      x = width + PApplet.parseInt(39 * resizeX);
      offsetL = PApplet.parseInt(26 * resizeX);
      offsetR = PApplet.parseInt(19 * resizeX);

      spriteWalk = warriorWalk;
      spriteAttack = warriorAttack;
    } else if (opponentNum == 2) {
      //shieldwall
      speed = .5f;
      damage = 22;
      maxHealth = 160;
      worth = 90;
      indexWalkSpeed = 0.04f;
      indexAttackSpeed = 0.05f;

      x = width + PApplet.parseInt(59 * resizeX);
      offsetL = PApplet.parseInt(59 * resizeX);
      offsetR = PApplet.parseInt(13 * resizeX);

      spriteWalk = shieldwallWalk;
      spriteAttack = shieldwallAttack;
    } else if (opponentNum == 3) {
      //berserker
      speed = 1.5f;
      damage = 16;
      maxHealth = 70;
      worth = 70;
      indexWalkSpeed = 0.08f;
      indexAttackSpeed = 0.08f;

      x = width + PApplet.parseInt(51 * resizeX);
      offsetL = PApplet.parseInt(19 * resizeX);
      offsetR = PApplet.parseInt(13 * resizeX);

      spriteWalk = berserkerWalk;
      spriteAttack = berserkerAttack;
    }

    health = maxHealth;
  }
}
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

  public void display() {
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

    textSize(.009f * width);
    fill(0);
    textAlign(CORNER);
    text(text, x+7, y+22);

    textAlign(LEFT, BOTTOM);
    textSize(.007f * width);

    if (upgradeButton != null) text("Opgrader (u)", upgradeButton.x1, upgradeButton.y1);
    text("Sælg (s)", sellButton.x1, sellButton.y1);

    textAlign(CENTER, CENTER);

    textSize(.009f * width);

    if (upgradeButton != null) upgradeButton.display(square.tower.upgradePrice+"$", color(100, 255, 100), 255);

    sellButton.display(square.tower.actualWorth+"$", color(255, 0, 0), 255);


    exitButton.display("X", color(255, 0, 0), 255);
  }

  public void pressed() {
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
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#4000F5", "--stop-color=#cccccc", "Blades_of_Destiny_TD" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
