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

  void display(String text) {
    rect(x1, y1, x2, y2, 5);
    fill(0);
    text(text, (x1+x2)*.5, (y1+y2)*.5);
  }
}


class DragButton extends Button {
  int towerNum;
  String text;

  DragButton(int x1, int y1, int x2, int y2, int towerNum_) {
    super(x1, y1, x2, y2);
    towerNum = towerNum_;
  }

  void display(int status) {

    //status 0 er hvid, status 1 er grå, status 2 er har ikke råd og status 3 er trykket ned
    if (status < 3) {
      fill(50);
      rect(x1+2, y1+6, x2+2, y2+6, 15);

      if (status == 0 || status == 2) fill(255);
      else fill(240);

      rect(x1, y1, x2, y2, 15);
    } else {
      fill(50);
      rect(x1+2, y1+6, x2+2, y2+6, 15);

      fill(240);
      rect(x1+1, y1+3, x2+1, y2+3, 15);
    }


    //beskrivelses boks
    if (status == 1 || status == 2) {
      if (status == 1) fill(255, 200);
      else fill(255, 200, 200, 200); //hvis man ikke har råd til det farves feltet rødt
      
      
      int len = int(width * 0.07);
      rect(mouseX-len, y1-220, mouseX+len, y1-10, 15);
      fill(0);
      textFont(normalFont);
      text(text, mouseX-len+7, y1-200);
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
    text = "Tårn "+(towerNum+1)+"\n";
    int x = int((x2-x1)*.3 + x1);
    int y = int((y2+y1)*.5);
    
    switch(towerNum) {
    case 0:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: Q";
      price = 100;
      towerImg = fighterSprite[0].copy();
      towerImg.resize(int(0.055 * width), 0);
      break;
    case 1:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: W";
      price = 100;
      break;
    case 2:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: E";
      price = 150;
      break;
    case 3:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: R";
      price = 250;
      break;
    case 4:
      text += "Dette er et tårn. Tester teksten.\nWow det er på flere linjer.\nDet her tårn kan skyde.\n \nGenvejstast: T";
      price = 300;
      break;
    }
  }

  void display(int status) {
    super.display(status);

    int x = int((x2-x1)*.3 + x1);
    int y = int((y2+y1)*.5);
    

    if (status == 3) {
      x++;
      y += 3;
    }

    if (money < price) fill(200, 0, 0);
    else fill(0, 200, 0);
    textFont(mediumFont);

    text(price+"$", x+35, y+9);
    
    if (towerImg != null) {
      pushMatrix();
      translate(x-5, y-30);
      scale(-1, 1);
      image(towerImg, 0, 0);
      popMatrix();
    }
  }
}



class AbilityButton extends DragButton{
  int cooldown, cooldownDur;
  
  AbilityButton(int x1, int y1, int x2, int y2, int towerNum) {
    super(x1, y1, x2, y2, towerNum);
    switch(towerNum) {
    case 0:
      text = "Boost tårn 1 med denne evne\nDen her evne gør tårn 1 bedre.\nTårnet bliver bedre i et lille\nstykke tid\n\nGenvejstast: 1";
      cooldownDur = 10 * 60;
      break;
    case 1:
      text = "Boost tårn 2 med denne evne\nDen her evne gør tårn 2 bedre.\nTårnet bliver bedre i et lille\nstykke tid\n\nGenvejstast: 2";
      cooldownDur = 15 * 60;
      break;
    case 2:
      text = "Boost tårn 3 med denne evne\nDen her evne gør tårn 3 bedre.\nTårnet bliver bedre i et lille\nstykke tid\n\nGenvejstast: 3";
      cooldownDur = 20 * 60;
      break;
    case 3:
      text = "Boost tårn 4 med denne evne\nDen her evne gør tårn 4 bedre.\nTårnet bliver bedre i et lille\nstykke tid\n\nGenvejstast: 4";
      cooldownDur = 25 * 60;
      break;
    case 4:
      text = "Boost tårn 5 med denne evne\nDen her evne gør tårn 5 bedre.\nTårnet bliver bedre i et lille\nstykke tid\n\nGenvejstast: 5";
      cooldownDur = 30 * 60;
      break;
    }
  }
  
  void display(int status) {
    super.display(status);
    
    int x = int((x2+x1)*.5);
    int y = int((y2+y1)*.5);
    
    if (status == 3) {
      x++;
      y += 3;
    }
    triangle(x-15, y+15, x+15, y+15, x, y-15);
  }
}
