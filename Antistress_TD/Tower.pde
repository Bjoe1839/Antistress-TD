class Tower {
  int x, y;
  int health, maxHealth;

  Tower(int x_, int y_) {
    x = x_;
    y = y_;
  }

  void display() {
  }

  void displayHealth() {
    fill(0, 255, 0);
    noStroke();

    int c = int(map(health, 0, maxHealth, 0, 255));
    fill(255-c, c, 0);

    int xEnd = int(map(health, 0, maxHealth, x-40, x+40));
    rect(x-40, y-75, xEnd, y-70);
    stroke(0);
  }
}


class FriendlyTower extends Tower {
  int towerNum, worth, upgradePrice;
  //int xOffset, wid; //spriten fylder ikke hele billedet
  float spriteIndex;
  boolean placed, upgraded;

  FriendlyTower(int x, int y, boolean placed_, int towerNum_) {
    super(x, y);
    placed = placed_;
    towerNum = towerNum_;
  }

  void display() {
    displayHealth();
  }

  void activate() {
  }

  void upgrade() {
  }

  void setStats(int boostingStatus) {
  }

  void ability() {
  }
}





class ShooterTower extends FriendlyTower {
  int range, damage, shotSpeed, shotCooldown, laneNum;

  ShooterTower(int x, int y, boolean placed, int towerNum, int laneNum_) {
    super(x, y, placed, towerNum);
    laneNum = laneNum_;
  }

  boolean shouldShoot() {
    shotCooldown--;

    if (inRange() && shotCooldown <= 0) {
      shotCooldown = shotSpeed;
      return true;
    }
    return false;
  }

  boolean inRange() {
    for (OpponentTower opponent : opponentTowers) {
      if (opponent.laneNum == laneNum && opponent.x - x < range * (width/squares.length-1)) {
        return true;
      }
    }
    return false;
  }

  void setStats(int boostingStatus) {
    //hvis tårnet er boostet med en almindelig booster
    if (boostingStatus == 1) {
      shotSpeed *= .9;
      damage *= 1.1;
      if (range < 9) range++;

      //hvis tårnet er boostet med en opgraderet booster
    } else if (boostingStatus == 2) {
      shotSpeed *= .5;
      damage *= 1.15;
      range += 2;
      if (range > 9) range = 9;
    }
  }

  void display() {
    super.display();
  }
}






class Fighter extends ShooterTower {
  int abilityCooldown, abilityShotSpeed;
  boolean hasShot;

  Fighter(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, placed, 0, laneNum);

    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 100;
    abilityShotSpeed = int(shotSpeed * .33);
  }

  void activate() {
    //hvis en animation er i gang
    if (spriteIndex > 0) {
      if (spriteIndex >= fighterSprite.length-1) {
        projectiles.add(new FighterProjectile(x+35, y, damage, laneNum, range));
        spriteIndex = 0;
        hasShot = false;
      } else spriteIndex += 0.1;

      //todo:
      //if (!hasShot && spriteIndex >= 4) {
      //  projectiles.add(new FighterProjectile(x+35, y, damage, laneNum, range));
      //  hasShot = true;
      //}
    }

    //hvis cooldown ability er aktiveret
    if (abilityCooldown > 0) {
      shotCooldown--;
      abilityCooldown--;
      if (inRange() && shotCooldown <= shotSpeed-abilityShotSpeed) {
        //hvis en animation allerede er i gang
        //if (spriteIndex > 0 && !hasShot) {
        //  projectiles.add(new FighterProjectile(x+35, y, damage, laneNum, range));
        //}
        shotCooldown = shotSpeed;
        spriteIndex = 1;
        hasShot = false;
      }
    } else if (shouldShoot()) {
      //hvis en animation allerede er i gang
      //if (spriteIndex > 0 && !hasShot) {
      //  projectiles.add(new FighterProjectile(x+35, y, damage, laneNum, range));
      //}
      spriteIndex = 1;
      hasShot = false;
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 60;
      maxHealth = 100;
      shotSpeed = 180;
      damage = 15;
      range = 2;
    } else {
      worth = 100;
      shotSpeed = 120;
      damage = 20;

      //skal have samme procentvise liv som før
      int temp = maxHealth;
      maxHealth = 150;
      health = int(map(health, 0, temp, 0, maxHealth));
    }
    super.setStats(boostingStatus);
  }

  void ability() {
    abilityCooldown = 300;
  }

  void display() {
    image(fighterSprite[floor(spriteIndex)], x, y);

    super.display();
  }
}


class Sniper extends ShooterTower {
  int abilityCooldown;

  Sniper(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, placed, 1, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 150;
  }

  void activate() {
    if (abilityCooldown > 0) {
      if (frameCount%2 == 0) projectiles.add(new SniperProjectile(x+30, y, damage, laneNum, range));
      abilityCooldown--;
    } else if (shouldShoot()) {
      projectiles.add(new SniperProjectile(x+30, y, damage, laneNum, range));
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 60;
      maxHealth = 150;
      shotSpeed = 45;
      damage = 3;
      range = 9;
    } else {
      //add
    }
    super.setStats(boostingStatus);
  }

  void ability() {
    abilityCooldown = 60;
  }

  void display() {
    fill(0, 255, 0);
    circle(x, y, 80);

    super.display();
  }
}


class Freezer extends ShooterTower {
  int slowDur, freezeDur;

  Freezer(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, placed, 2, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 150;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new FreezerProjectile(x+30, y, laneNum, range, slowDur, freezeDur));
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 100;
      maxHealth = 200;
      shotSpeed = 240;
      damage = 0;
      range = 4;
      slowDur = 60;
      freezeDur = 0;
    } else {
      slowDur = 90;
      freezeDur = 60;
      //add
    }
    super.setStats(boostingStatus);
  }

  void ability() {
    for (OpponentTower opponent : opponentTowers) {
      opponent.freezeCooldown += 120;
      opponent.slowCooldown += 120;
    }
  }

  void display() {
    fill(0, 0, 255);
    circle(x, y, 80);

    super.display();
  }
}



class Blaster extends ShooterTower {
  Blaster(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, placed, 4, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 250;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new BlasterProjectile(x+30, y, damage, laneNum, range));
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 150;
      maxHealth = 300;
      shotSpeed = 300;
      damage = 20;
      range = 4;
    } else {
      //add
    }
    super.setStats(boostingStatus);
  }

  void display() {
    fill(0);
    circle(x, y, 80);

    super.display();
  }
}


class Booster extends FriendlyTower {
  Booster(int x, int y, boolean placed) {
    super(x, y, placed, 3);
    setStats();
    health = maxHealth;
    upgradePrice = 200;
  }

  void activate() {
  }

  void setStats() {
    if (!upgraded) {
      worth = 200;
      maxHealth = 200;
    } else {
      //add
    }
  }

  void display() {
    fill(255, 255, 0);
    circle(x, y, 80);

    super.display();
  }
}




class OpponentTower extends Tower {
  int laneNum;
  int speed, damage, damageSpeed, damageCooldown, worth;
  int slowCooldown, freezeCooldown;
  int xOffset, wid;
  float indexAttack, indexWalk;
  boolean collision;


  OpponentTower(int y, int laneNum_) { //todo: check om den 
    super(width + 33, y);
    xOffset = int(vikingWalk[0].width * .5) - 63;
    wid = 33;

    laneNum = laneNum_;
    speed = 1;
    damage = 10;
    damageSpeed = 70;
    maxHealth = 100;
    health = maxHealth;
    worth = 200;
  }

  void move() {
    collision = false;
    //tjekker kun for kollision for tårne på egen lane

    for (int i = 0; i < squares.length; i++) {
      if (squares[i][laneNum].tower != null && squares[i][laneNum].tower.x+40 >= x - xOffset && squares[i][laneNum].tower.x-40 <= x - xOffset + wid) {
        collision = true;
        if (freezeCooldown == 0) {
          if (damageCooldown <= 0) {
            damageCooldown = damageSpeed;
            squares[i][laneNum].tower.health -= damage;
          } else if (slowCooldown == 0) {
            damageCooldown--;
          } else if (frameCount%2 == 0) damageCooldown--;
        }
      }
    }
    if (freezeCooldown > 0) freezeCooldown--;

    if (slowCooldown > 0 && freezeCooldown == 0) slowCooldown--;

    if (!collision && freezeCooldown == 0) {
      if (slowCooldown > 0) {
        if (frameCount%4 == 0) x--;
      } else if (frameCount%2 == 0) x--;

      if (x < -40) gameOver = true;
    }
  }

  void display() {
    if (freezeCooldown > 0) tint(150, 150, 255);
    else if (slowCooldown > 0) tint(200, 200, 255);


    if (freezeCooldown == 0) {
      
      if (slowCooldown > 0) {
        if (collision) indexAttack += 0.075;
        else indexWalk += 0.03;
      } else {
        if (collision) indexAttack += 0.15;
        else indexWalk += 0.06;
      }

      if (indexAttack >= vikingAttack.length) indexAttack = 0;
      if (indexWalk >= vikingAttack.length) indexWalk = 0;
    }
    
    if (collision) {
      image(vikingAttack[floor(indexAttack)], x, y);
    } else {
      image(vikingWalk[floor(indexWalk)], x, y);
    }


    noTint();


    displayHealth();
  }
}
