class Button {
  int x1, y1, x2, y2;

  Button(int x1_, int y1_, int x2_, int y2_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;
  }

  boolean collision() {
    if (mouseX >= x1 && mouseX <= x2 && mouseY >= y1 && mouseY <= y2) return true;
    return false;
  }

  void display() {
  }
}


class DragButton extends Button {
  String text;

  DragButton(int x1, int y1, int x2, int y2) {
    super(x1, y1, x2, y2);
  }

  void display(int status) {

    //status 0 er hvid, status 1 er grå og status 2 er trykket ned
    if (status < 2) {
      fill(50);
      rect(x1+2, y1+6, x2+2, y2+6, 10);

      if (status == 0) fill(255);
      else fill(240);

      rect(x1, y1, x2, y2, 10);
    } else {
      fill(50);
      rect(x1+2, y1+6, x2+2, y2+6, 10);

      fill(240);
      rect(x1+1, y1+3, x2+1, y2+3, 10);
    }

    fill(0);

    if (collision() && draggingStatus == -1) {
      fill(255, 200);
      int len = x2-x1;
      rect(mouseX-len, y1-220, mouseX+len, y1-10, 10);
      fill(0);
      textSize(17);
      text(text, mouseX-len+5, y1-200);
    }
  }
}


class TowerButton extends DragButton {
  int towerNum, price;
  FriendlyTower tower;

  TowerButton(int x1, int y1, int x2, int y2, int towerNum_) {
    super(x1, y1, x2, y2);
    towerNum = towerNum_;

    //beskrivelsestekst, pris og tårne
    text = "Tårn "+(towerNum+1)+"\n";
    int x = int((x2-x1)*.3 + x1);
    int y = int((y2+y1)*.5);
    
    switch(towerNum) {
    case 0:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: Q";
      price = 100;
      tower = new Fighter(x, y, false, 50, 255, 0);
      break;
    case 1:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: W";
      price = 100;
      tower = new Sniper(x, y, false, 50, 255, 0);
      break;
    case 2:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: E";
      price = 150;
      tower = new Freezer(x, y, false, 50, 255, 0);
      break;
    case 3:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: R";
      price = 250;
      tower = new Booster(x, y, false, 50, 255);
      break;
    case 4:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: T";
      price = 300;
      tower = new Blaster(x, y, false, 50, 255, 0);
      break;
    }
  }

  void display(int status) {
    super.display(status);

    int x = int((x2-x1)*.3 + x1);
    int y = int((y2+y1)*.5);

    if (status == 2) {
      tower.display(true);
    }
    else tower.display(false);

    if (money < price) fill(200, 0, 0);
    else fill(0, 200, 0);
    textSize(23);

    text(price+"$", x+35, y+9);
    textSize(15);
  }
}
