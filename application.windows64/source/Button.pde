class Button {
  int x1, y1, x2, y2;

  Button(int x1_, int y1_, int x2_, int y2_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;
  }

  boolean collision() {
    if (mouseX >= x1 && mouseX <= x2 && mouseY >= y1 && mouseY <= y2) {
      return true;
    }
    return false;
  }

  void display(String text, color c, int alfa) {
    fill(c);
    rect(x1, y1, x2, y2, 5);
    fill(0, alfa);
    text(text, (x1 + x2) * .5, (y1 + y2) * .5 - 5);
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


      int len = int(width * 0.07);
      rect(mouseX - len, y1 - 220, mouseX + len, y1 - 10, 15);
      fill(0);
      textSize(.009 * width);
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
      text = "Præst\nBooster tårne rundt om ham så\nde skader mere og skyder\nhurtigere.\n \nGenvejstast: R";
      price = 200;
      towerImg = priest[0].copy();
      break;
    case 4:
      text = "Kanon\nSkyder skud der skader i et\nstørre område der også kan\nramme andre lanes.\n \nGenvejstast: T";
      price = 325;
      towerImg = bomber[0].copy();
      break;
    }
    towerImg.resize(0, int(resizeY * towerImg.height * .5));
  }

  void display(int status) {
    super.display(status);

    int x = int((x2 - x1) * .3 + x1);
    int y = int((y2 + y1) * .5);


    if (status == 3) {
      x++;
      y += 3;
    }

    if (money < price) fill(200, 0, 0);
    else fill(0, 200, 0);
    textSize(.012 * width);

    textAlign(RIGHT, CENTER);
    text(price+"$", x2 - 5, y);
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
      text = "Med denne evne skyder\nbueskytten en masse skud på\net sekund.\n\nGenvejstast: 2";
      cooldownDur = 20 * 60;
      break;
    case 2:
      text = "Med denne evne fryser\nsneboldskasteren alle tårne på\nskærmen i et stykke tid.\n\nGenvejstast: 3";
      cooldownDur = 20 * 60;
      break;
    case 3:
      text = "Med denne evne heler præsten\nalle dine tårne.\n\nGenvejstast: 4";
      cooldownDur = 20 * 60;
      break;
    case 4:
      text = "Med denne evne bliver\nkanonens næste skud tre gange\nmere skadende og skader et\nstørre område.\n\nGenvejstast: 5";
      cooldownDur = 30 * 60;
      break;
    }
  }

  void display(int status) {
    super.display(status);

    if (cooldown > 0 && !gameMenu) cooldown--;

    int x = int((x2 + x1) * .5);
    int y = int((y2 + y1) * .5);

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
      int barX = int(map(cooldown, 0, cooldownDur, x1, x2));
      fill(0, 0, 200);
      rect(x1, y2 + 11, barX, y2 + 16, 3);
    }
  }
}
