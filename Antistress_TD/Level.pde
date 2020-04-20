class Level {
  int num, dur;
  float cooldown;
  int opponentSpawnRate;
  Button nextLevel;
  //opponent1chance, opponent2chance..

  Level(int num_) {
    num = num_;
    dur = 15;
    cooldown = dur;

    setStats();
  }

  void setStats() {
    switch(num) {
    case 0:
      opponentSpawnRate = 600;
      break;
    case 1:
      opponentSpawnRate = 300;
      break;
    case 2:
      opponentSpawnRate = 200;
      break;
    case 3:
      opponentSpawnRate = 100;
      break;
    case 4:
      opponentSpawnRate = 50;
      break;
    }
  }

  void opponentHandler() {
    //level
    if (!levelFinished) {
      if (frameCount%60 == 0) {
        cooldown -= .5;
      }
      if (cooldown <= 0) {
        if (num < 4) {
          cooldown = 0;
          if (opponentTowers.size() == 0 && projectiles.size() == 0) {
            levelFinished = true;
            nextLevel = new Button(int(width * .97), int(height * .95), int(width * .99), int(height * .99));
          }
        } else gameWon = true;
      }

      if (frameCount%opponentSpawnRate == 2 && cooldown > 0) {
        //random lane
        int laneNum = int(random(5));
        int y = int((squares[0][laneNum].y1 + squares[0][laneNum].y2) * .5);
        int offset = int(random(-height * .02, height * .02));
        y += offset;

        opponentTowers.add(new OpponentTower(y, laneNum));
      }
      for (OpponentTower ot : opponentTowers) {
        ot.move();
        ot.display();
      }
    }
  }

  void nextLevel() {
    level.cooldown = level.dur;
    level.num++;
    level.setStats();
    level.nextLevel = null;
    levelFinished = false;
  }

  void displayProgressbar() {
    fill(255);
    rect(width * .8, height * .87, width * .99, height * .92);

    int x = int(map(cooldown, 0, dur, width * .8, width * .99));
    fill(0, 255, 0);
    rect(x, height * .87, width * .99, height * .92);

    textFont(mediumFont);
    textAlign(RIGHT, TOP);
    fill(0);
    text("Level "+(num+1), width * .99, height * .92);

    textAlign(LEFT);

    if (nextLevel != null) {
      fill(255);
      nextLevel.display("");
      fill(0, 255, 0);
      triangle(nextLevel.x1 + 5, nextLevel.y1 + 5, nextLevel.x1 + 5, nextLevel.y2 - 5, nextLevel.x2 - 5, (nextLevel.y2 + nextLevel.y1) * .5);
    }
  }
}
