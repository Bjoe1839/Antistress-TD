int draggingStatus;
TowerButton[] towerButtons = new TowerButton[5];
Tower draggedTower;

void setup() {
  fullScreen();
  rectMode(CORNERS);

  startUp();
}

void draw() {
  background(255);

  fill(200);
  rect(-1, height*0.85, width, height);

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
    draggedTower = new Tower(mouseX, mouseY, draggingStatus);
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
  //hvis der var drag før er der ikke mere
  draggingStatus = 0;
}


void startUp() {
  for (int i = 0; i < towerButtons.length; i++) {
    towerButtons[i] = new TowerButton(int(width*0.13) + i*int(width*0.13), int(height*0.87), int(width*0.20) + i*int(width*0.13), int(height*0.93), "Tårn "+(i+1), i+1);
  }
}
