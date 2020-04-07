//todo:

//projektil position
//tjek ikke enhanced for-loops
//fix generelle enheder og enheder angivet i pixels 

int draggingStatus = -1;
int money;

boolean gameOver;

ArrayList<OpponentTower> opponentTowers = new ArrayList<OpponentTower>();
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
TowerButton[] towerButtons = new TowerButton[5];
Square[][] squares = new Square[10][5];
UpgradeMenu upgradeMenu;

void setup() {
  fullScreen();
  rectMode(CORNERS);

  PFont font = createFont("Arial Bold", 17);
  textFont(font);

  startUp();
}

void draw() {
  if (!gameOver) {
    fill(200);
    rect(-1, height*0.85-1, width, height);

    //felter
    for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
      fill(255);
      squares[i][j].activateTower();
      squares[i][j].display();
    }

    opponentHandler();
    projectileHandler();

    //musens markør
    if (hovering()) cursor(HAND);
    else cursor(ARROW);


    //tegn towerbuttons
    for (TowerButton tb : towerButtons) {
      if (draggingStatus == tb.towerNum) {
        tb.display(2);
      } else if (tb.collision() && draggingStatus == -1 && money >= tb.price && upgradeMenu == null) {
        tb.display(1);
      } else {
        tb.display(0);
      }
    }

    //upgraderingsmenu
    if (upgradeMenu != null) {
      upgradeMenu.display();
    }


    //trukket tower
    if (draggingStatus > -1) {
      FriendlyTower draggedTower = new FriendlyTower(mouseX, mouseY, false, 80, 255, draggingStatus%5);
      draggedTower.display(false);
    }

    //penge
    fill(255, 200, 0);
    textSize(40);
    text(money+"$", width*0.03, height*0.915);

    //fps
    textSize(15);
    fill(0);
    text(round(frameRate), 10, 20);
  } else {
    textSize(100);
    textAlign(CENTER);
    text("GAME OVER", width*.5, height*.5);
    noLoop();
  }
}


void mousePressed() {
  if (upgradeMenu == null) {
    for (TowerButton tb : towerButtons) {
      if (tb.collision() && money >= tb.price) {
        draggingStatus = tb.towerNum;
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
  if (draggingStatus > -1) {
    for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
      //hvis tårnet slippes over et felt, tilføjes tårnet til det felt 
      if (squares[i][j].button.collision() && squares[i][j].tower == null) {
        squares[i][j].addTower();
        money -= towerButtons[draggingStatus%5].price;
        break;
      }
    }
    draggingStatus = -1;
  }
}


void keyPressed() {
  switch(key) {
  case 'q':
  case 'Q':
    //hvis tårnet allerede er valgt
    if (draggingStatus == 5) draggingStatus = -1;
    //hvis drag-and-drop ikke er i gang
    else if (draggingStatus > 4 || draggingStatus == -1) {
      if (money >= towerButtons[0].price) draggingStatus = 5;
    }
    break;
  case 'w':
  case 'W':
    if (draggingStatus == 6) draggingStatus = -1;
    else if (draggingStatus > 4 || draggingStatus == -1) {
      if (money >= towerButtons[1].price) draggingStatus = 6;
    }
    break;
  case 'e':
  case 'E':
    if (draggingStatus == 7) draggingStatus = -1;
    else if (draggingStatus > 4 || draggingStatus == -1) {
      if (money >= towerButtons[2].price) draggingStatus = 7;
    }
    break;
  case 'r':
  case 'R':
    if (draggingStatus == 8) draggingStatus = -1;
    else if (draggingStatus > 4 || draggingStatus == -1) {
      if (money >= towerButtons[3].price) draggingStatus = 8;
    }
    break;
  case 't':
  case 'T':
    if (draggingStatus == 9) draggingStatus = -1;
    else if (draggingStatus > 4 || draggingStatus == -1) {
      if (money >= towerButtons[4].price) draggingStatus = 9;
    }
    break;
  case '+':
    money += 1000;
    break;
  }
}

void startUp() {
  money = 200;

  //placering af towerbuttons
  for (int i = 0; i < towerButtons.length; i++) {
    towerButtons[i] = new TowerButton(int(width*0.13) + i*int(width*0.13), int(height*0.87), int(width*0.20) + i*int(width*0.13), int(height*0.93), i);
  }
  //placering af hvert felt
  for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
    //-1 fordi der ellers ville være en kant med i venstre side og i toppen
    squares[i][j] = new Square(i*width/squares.length-1, int(j*height*0.85/squares[0].length)-1, (i+1)*width/squares.length-1, int((j+1)*height*0.85/squares[0].length)-1, i, j);
  }
}

void opponentHandler() {
  if (frameCount%600 == 1) {
    int x = width+40;
    //random lane
    int laneNum = int(random(5));
    int y = int((squares[0][laneNum].y1+squares[0][laneNum].y2)*.5);
    int offset = int(random(-(squares[0][laneNum].y2-squares[0][laneNum].y1)*.5 + 60, (squares[0][laneNum].y2-squares[0][laneNum].y1)*.5 - 60));
    y += offset;

    opponentTowers.add(new OpponentTower(x, y, laneNum));
  }
  for (int i = 0; i < opponentTowers.size(); i++) {
    opponentTowers.get(i).move();
    opponentTowers.get(i).display();
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
  if (draggingStatus > -1) return true;

  if (upgradeMenu == null) {
    for (TowerButton tb : towerButtons) if (tb.collision() && money >= tb.price) {
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
