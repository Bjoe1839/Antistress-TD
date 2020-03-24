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
  rect(0, height*0.85, width, height);

  //towerButtons
  boolean hovering = false;
  for (TowerButton t : towerButtons) { //todo: skal være for alle tårne
    if (t.collision()) {
      hovering = true;
      t.display(1);
    } else {
      t.display(0);
    }
  }
  for (TowerButton t : towerButtons) {
    if (t.dragging) {
      t.display(2);
      hovering = true;
    }
  }
  if (hovering) cursor(HAND);
  else cursor(ARROW);


  //dragged tower
  for (TowerButton t : towerButtons) {
    if (t.dragging) {
      draggedTower = new Tower(mouseX, mouseY, t.towerNum);
      draggedTower.display();
      break;
    }
  }
}

void mousePressed() {
  for (TowerButton t : towerButtons) {
    if (t.collision()) {
      t.dragging = true;
    }
  }
}

void mouseReleased() {
  for (TowerButton t : towerButtons) {
    t.dragging = false;
  }
}

void startUp() {
  for (int i = 0; i < towerButtons.length; i++) {
    towerButtons[i] = new TowerButton(int(width*0.13) + i*int(width*0.13), int(height*0.87), int(width*0.20) + i*int(width*0.13), int(height*0.93), "Tårn "+(i+1), i+1);
  }
}
