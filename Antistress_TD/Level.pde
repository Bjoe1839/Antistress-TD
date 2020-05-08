class Level {
  int num, dur;
  float cooldown;
  int opponentSpawnRate;
  int startFrame;
  int axemanChance, warriorChance, shieldwallChance;
  ArrayList<OpponentTower> opponentTowers;

  Button nextLevel;

  Level(int num_) {
    num = num_;
    dur = 30;
    cooldown = dur;
    opponentTowers = new ArrayList<OpponentTower>();

    setStats();
  }

  void setStats() {
    switch(num) {
    case 0:
      opponentSpawnRate = 500;
      axemanChance = 100;
      warriorChance = 0;
      shieldwallChance = 0;
      break;
    case 1:
      opponentSpawnRate = 350;
      axemanChance = 80;
      warriorChance = 20;
      shieldwallChance = 0;
      break;
    case 2:
      opponentSpawnRate = 300;
      axemanChance = 30;
      warriorChance = 45;
      shieldwallChance = 15;
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
      shieldwallChance = 30;
      break;
    case 5:
      opponentSpawnRate = 100;
      axemanChance = 0;
      warriorChance = 35;
      shieldwallChance = 30;
      break;
    }
  }

  void opponentHandler() {
    //level
    if (!levelFinished) {
      if (cooldown > 0) {
        if (frameCount%60 == 0) {
          cooldown -= .5;
          if (cooldown < 0) cooldown = 0;
        }
      } else {
        if (opponentTowers.size() == 0 && projectiles.size() == 0) {
          boolean animation = false;
          for (Square[] squareRow : squares) for (Square square : squareRow) {
            if (square.tower != null && square.tower.spriteIndex != 0 && square.tower.towerNum != 3) animation = true;
          }
          if (!animation) {
            if (num < 5) {
              abilityDragStatus = -1;
              for (AbilityButton ab : abilityButtons) ab.cooldown = 0;
              levelFinished = true;
              nextLevel = new Button(int(width * .97), int(height * .95), int(width * .99), int(height * .99));
            } else {
              gameWon = true;
              gameMenu = true;
              gameBegun = false;
            }
          }
        }
      }

      if (frameCount % opponentSpawnRate == startFrame && cooldown > 0 || cooldown < dur * .1 && cooldown > 0 && frameCount % (opponentSpawnRate * .2) == 0) {
        //random lane
        int laneNum = int(random(5));
        int y = int((squares[0][laneNum].y1 + squares[0][laneNum].y2) * .5);
        int offset = int(random(-height * .02, height * .02));
        y += offset;
        int opponentNum;

        int r = int(random(100));
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

  void nextLevel() {
    if (cooldown <= 0) num++;
    cooldown = dur;
    setStats();
    nextLevel = null;
    levelFinished = false;

    startFrame = frameCount%opponentSpawnRate + 1;
  }

  void displayProgressbar() {
    fill(255);
    rect(width * .8, height * .87, width * .99, height * .92);

    int x = round(map(cooldown, 0, dur, width * .8, width * .99));
    fill(0, 255, 0);
    rect(x, height * .87, width * .99, height * .92);


    textSize(.012 * width);
    textAlign(RIGHT, TOP);
    fill(0);
    text("Level "+(num+1)+" af 6", width * .99, height * .92);
    textAlign(CENTER, CENTER);


    if (nextLevel != null) {
      nextLevel.display("", color(255), 255);

      if (frameCount%120 < 60 || gameMenu) {
        fill(0, 255, 0);
        triangle(nextLevel.x1 + 5, nextLevel.y1 + 5, nextLevel.x1 + 5, nextLevel.y2 - 5, nextLevel.x2 - 5, (nextLevel.y2 + nextLevel.y1) * .5);
      }
    }
  }
}
