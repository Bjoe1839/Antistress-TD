int draggingStatus;
int money;

TowerButton[] towerButtons = new TowerButton[5];
FriendlyTower draggedTower;
Square[][] squares = new Square[10][5];

void setup() {
  fullScreen();
  rectMode(CORNERS);

  PFont font = createFont("Arial Bold", 20);
  textFont(font);

  startUp();
}

void draw() {
  fill(200);
  rect(-1, height*0.85-1, width, height);

  for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
    fill(255);
    squares[i][j].display();
  }

  //towerButtons
  boolean hovering = false;
  for (TowerButton t : towerButtons) if (t.collision()) {
    hovering = true;
  }

  if (hovering || draggingStatus > 0) cursor(HAND);
  else cursor(ARROW);


  //display towerbuttons
  for (TowerButton t : towerButtons) {
    if (draggingStatus == t.towerNum) {
      t.display(2);
    } else if (t.collision() && draggingStatus < 1) {
      t.display(1);
    } else {
      t.display(0);
    }
  }

  //dragged tower
  if (draggingStatus > 0) {
    draggedTower = new FriendlyTower(mouseX, mouseY, draggingStatus, false);
    draggedTower.display();
  }
}

void mousePressed() {
  for (TowerButton t : towerButtons) {
    if (t.collision()) {
      draggingStatus = t.towerNum;
    }
  }
}

void mouseReleased() {
  if (draggingStatus > 0) {
    for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
      //hvis tårnet slippes over et felt, tilføjes tårnet til det felt 
      if (squares[i][j].button.collision()) {
        squares[i][j].addTower(draggingStatus);
        break;
      }
    }
    draggingStatus = 0;
  }
}

void keyPressed() {
  switch(key) {
  case 'q':
  case 'Q':
    //hvis tårnet allerede er valgt
    if (draggingStatus == 6) draggingStatus = 0;
    //hvis drag-and-drop ikke er i gang
    else if (draggingStatus > 5 || draggingStatus < 1) draggingStatus = 6;
    break;
  case 'w':
  case 'W':
    if (draggingStatus == 7) draggingStatus = 0;
    else if (draggingStatus > 5 || draggingStatus < 1) draggingStatus = 7;
    break;
  case 'e':
  case 'E':
    if (draggingStatus == 8) draggingStatus = 0;
    else if (draggingStatus > 5 || draggingStatus < 1) draggingStatus = 8;
    break;
  case 'r':
  case 'R':
    if (draggingStatus == 9) draggingStatus = 0;
    else if (draggingStatus > 5 || draggingStatus < 1) draggingStatus = 9;
    break;
  case 't':
  case 'T':
    if (draggingStatus == 10) draggingStatus = 0;
    else if (draggingStatus > 5 || draggingStatus < 1) draggingStatus = 10;
    break;
  }
}

void startUp() {
  money = 200;
  
  //placering af towerbuttons
  for (int i = 0; i < towerButtons.length; i++) {
    towerButtons[i] = new TowerButton(int(width*0.13) + i*int(width*0.13), int(height*0.87), int(width*0.20) + i*int(width*0.13), int(height*0.93), i+1);
  }
  //placering af hvert felt
  for (int i = 0; i < squares.length; i++) for (int j = 0; j < squares[0].length; j++) {
    //-1 fordi der ellers ville være en kant med i venstre side og i toppen
    squares[i][j] = new Square(i*width/squares.length-1, int(j*height*0.85/squares[0].length)-1, (i+1)*width/squares.length-1, int((j+1)*height*0.85/squares[0].length)-1);
  }
}


void displayTower(int x, int y, int towerNum, boolean transparent, boolean smaller) { //todo: fix forskellige numre
  switch(towerNum) {
  case 1:
  case 6:
    if (!transparent) fill(255, 0, 0);
    else fill(255, 0, 0, 50);
    break;
  case 2:
  case 7:
    if (!transparent) fill(0, 255, 0);
    else fill(0, 255, 0, 50);
    break;
  case 3:
  case 8:
    if (!transparent) fill(0, 0, 255);
    else fill(0, 0, 255, 50);
    break;
  case 4:
  case 9:
    if (!transparent) fill(255, 255, 0);
    else fill(255, 255, 0, 50);
    break;
  case 5:
  case 10:
    if (!transparent) fill(0);
    else fill(0, 50);
    break;
  }
  if (transparent) stroke(0, 50);

  if (!smaller) circle(x, y, 80);
  else circle(x, y, 50);
  stroke(0);
}
