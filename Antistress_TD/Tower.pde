class Tower {
  float x;
  int y;
  int health, maxHealth;
  int offsetL, offsetR; //hvor billedets kollision strækker sig over

  Tower(int x_, int y_, int offsetL_, int offsetR_) {
    x = x_;
    y = y_;
    offsetL = int(offsetL_ * resizeFactor);
    offsetR = int(offsetR_ * resizeFactor);
  }

  Tower(int y_) {
    y = y_;
  }

  void display() {
  }

  void displayHealth() {
    noStroke();

    int c = int(map(health, 0, maxHealth, 0, 255));
    fill(255-c, c, 0, 150);

    int len = int(30 * resizeFactor);
    int hei = int(70 * resizeFactor);

    int xEnd = int(map(health, 0, maxHealth, x - len, x + len));
    rect(x - len, y - hei, xEnd, y - hei + 5);
    stroke(0);
  }
}


class FriendlyTower extends Tower {
  int towerNum, worth, actualWorth, upgradePrice;
  float spriteIndex;
  boolean placed, upgraded;

  FriendlyTower(int x, int y, int offsetL, int offsetR, boolean placed_, int towerNum_) {
    super(x, y, offsetL, offsetR);
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

  ShooterTower(int x, int y, int offsetL, int offsetR, boolean placed, int towerNum, int laneNum_) {
    super(x, y, offsetL, offsetR, placed, towerNum);
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
      int d = int(opponent.x - opponent.offsetL - x);
      if (opponent.laneNum == laneNum && d < range * (width/squares.length-1) && d >= 0) {
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
      shotSpeed *= .85;
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
    super(x, y, 13, 19, placed, 0, laneNum);

    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 100;
    abilityShotSpeed = int(shotSpeed * .33);
  }

  void activate() {
    //hvis en animation er i gang
    if (spriteIndex > 0) {
      spriteIndex += 0.1;
      if (spriteIndex >= fighter.length) {
        projectiles.add(new FighterProjectile(int(x + offsetR), y, damage, laneNum, range, upgraded));
        spriteIndex = 0;
        hasShot = false;
      }
    }

    //hvis cooldown ability er aktiveret
    if (abilityCooldown > 0) {
      shotCooldown--;
      abilityCooldown--;
      if (inRange() && shotCooldown <= shotSpeed-abilityShotSpeed) {
        //hvis en animation allerede er i gang
        if (spriteIndex > 0 && !hasShot) {
          projectiles.add(new FighterProjectile(int(x + offsetR), y, damage, laneNum, range, upgraded));
        }
        shotCooldown = shotSpeed;
        spriteIndex = 1;
        hasShot = false;
      }
    } else if (shouldShoot()) {
      //hvis en animation allerede er i gang
      if (spriteIndex > 0 && !hasShot) {
        projectiles.add(new FighterProjectile(int(x + offsetR), y, damage, laneNum, range, upgraded));
      }
      spriteIndex = 1;
      hasShot = false;
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 60;
      actualWorth = worth;
      maxHealth = 100;
      shotSpeed = 180;
      damage = 15;
      range = 2;
    } else {
      worth = 100;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
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
    if (!upgraded) image(fighter[floor(spriteIndex)], x, y);
    else image(fighterlv2[floor(spriteIndex)], x, y);

    super.display();
  }
}




class Archer extends ShooterTower {
  int abilityCooldown;
  boolean hasShot;

  Archer(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, 40, 40, placed, 1, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 150;
  }

  void activate() {
    //hvis cooldown ability er aktiveret
    if (abilityCooldown > 0) {
      spriteIndex++;
      abilityCooldown--;
      shotCooldown = shotSpeed;
      if (abilityCooldown == 0) {
        spriteIndex = 0;
        shotCooldown = 0;
      }
    }

    //hvis en animation er i gang
    if (spriteIndex > 0) {
      if (abilityCooldown == 0) spriteIndex += 0.08;
      if (spriteIndex >= archer.length-1) {
        if (!hasShot) projectiles.add(new ArcherProjectile(int(x + offsetR), y - int(16  * resizeFactor), damage, laneNum, range, upgraded));
        hasShot = true;
        if (spriteIndex >= archer.length) {
          spriteIndex = 0;
          hasShot = false;
        }
      }
    }

    if (shouldShoot()) {
      //hvis en animation allerede er i gang
      if (spriteIndex > 0 && !hasShot) {
        projectiles.add(new ArcherProjectile(int(x + offsetR), y - int(16  * resizeFactor), damage, laneNum, range, upgraded));
      }
      spriteIndex = 1;
      hasShot = false;
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 60;
      actualWorth = worth;
      maxHealth = 150;
      shotSpeed = 75;
      damage = 5;
      range = 9;
    } else {
      worth = 150;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
      //add
    }
    super.setStats(boostingStatus);
  }

  void ability() {
    abilityCooldown = 60;
  }

  void display() {
    if (!upgraded) image(archer[floor(spriteIndex)], x, y);
    else image(archerlv2[floor(spriteIndex)], x, y);

    super.display();
  }
}


class Freezer extends ShooterTower {
  int slowDur, freezeDur;

  Freezer(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, 40, 40, placed, 2, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 150;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new FreezerProjectile(int(x + offsetR), y, laneNum, range, slowDur, freezeDur, upgraded));
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 100;
      actualWorth = worth;
      maxHealth = 200;
      shotSpeed = 240;
      damage = 0;
      range = 4;
      slowDur = 60;
      freezeDur = 0;
    } else {
      slowDur = 90;
      freezeDur = 60;
      worth = 200;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
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
    super(x, y, 40, 40, placed, 4, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 250;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new BlasterProjectile(int(x + offsetR), y, damage, laneNum, range, upgraded));
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 150;
      actualWorth = worth;
      maxHealth = 300;
      shotSpeed = 300;
      damage = 20;
      range = 4;
    } else {
      worth = 250;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
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
    super(x, y, 40, 40, placed, 3);
    setStats();
    health = maxHealth;
    upgradePrice = 200;
  }

  void activate() {
    spriteIndex += .08;
  }

  void setStats() {
    if (!upgraded) {
      worth = 200;
      actualWorth = worth;
      maxHealth = 200;
    } else {
      worth = 300;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
      //add
    }
  }

  void display() {
    if (!upgraded) image(booster[floor(spriteIndex%booster.length)], x, y);
    else image(booster[floor(spriteIndex%booster.length)], x, y);

    super.display();
  }
}





class OpponentTower extends Tower {
  int laneNum;
  int damage, damageSpeed, damageCooldown, worth;
  float speed;
  int slowCooldown, freezeCooldown;
  float indexAttack, indexWalk, indexWalkSpeed, indexAttackSpeed;
  boolean collision;
  PImage[] spriteWalk, spriteAttack;


  OpponentTower(int y, int laneNum_, int opponentNum) {
    super(y);
    laneNum = laneNum_;
    setStats(opponentNum);
  }

  void move() {
    collision = false;
    //tjekker kun for kollision for tårne på egen lane

    for (int i = 0; i < squares.length; i++) {
      if (squares[i][laneNum].tower != null && squares[i][laneNum].tower.x + squares[i][laneNum].tower.offsetR >= x - offsetL && squares[i][laneNum].tower.x - squares[i][laneNum].tower.offsetL <= x + offsetR) {
        collision = true;
        if (freezeCooldown == 0) {
          if (damageCooldown <= 0) {
            damageCooldown = damageSpeed;
            squares[i][laneNum].tower.health -= damage;
            squares[i][laneNum].tower.actualWorth = int(map(squares[i][laneNum].tower.health, 0, squares[i][laneNum].tower.maxHealth, 0, squares[i][laneNum].tower.worth));
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
        x -= speed * .5;
      } else {
        x -= speed;
      }

      if (x + offsetR < 0) {
        gameOver = true;
        gameMenu = true;
        gameBegun = false;
      }
    }

    if (freezeCooldown == 0) {
      float indexSpeed;
      if (collision) indexSpeed = indexAttackSpeed;
      else indexSpeed = indexWalkSpeed;

      if (slowCooldown > 0) {
        indexSpeed *= .5;
      }

      if (collision) indexAttack += indexSpeed;
      else indexWalk += indexSpeed;

      if (indexAttack >= spriteAttack.length) indexAttack = 0;
      if (indexWalk >= spriteWalk.length) indexWalk = 0;
    }
  }

  void display() {
    displayHealth();

    if (freezeCooldown > 0) tint(150, 150, 255);
    else if (slowCooldown > 0) tint(200, 200, 255);

    if (collision) image(spriteAttack[floor(indexAttack)], x, y);
    else image(spriteWalk[floor(indexWalk)], x, y);

    noTint();
  }

  void setStats(int opponentNum) {
    if (opponentNum == 0) {
      //axeman
      speed = .5;
      damage = 10;
      damageSpeed = 70;
      maxHealth = 100;
      worth = 200;
      indexWalkSpeed = 0.05;
      indexAttackSpeed = 0.15;

      x = width + int(37 * resizeFactor);
      offsetL = int(21 * resizeFactor);
      offsetR = int(19 * resizeFactor);

      spriteWalk = axemanWalk;
      spriteAttack = axemanAttack;
    } else if (opponentNum == 1) {
      //warrior
      speed = .75;
      damage = 15;
      damageSpeed = 50;
      maxHealth = 150;
      worth = 200;
      indexWalkSpeed = 0.06;
      indexAttackSpeed = 0.12;
      
      x = width + int(39 * resizeFactor);
      offsetL = int(26 * resizeFactor);
      offsetR = int(19 * resizeFactor);
      
      spriteWalk = warriorWalk;
      spriteAttack = warriorAttack;
    } else if (opponentNum == 2) {
      //shieldwall
      speed = .3;
      damage = 5;
      damageSpeed = 100;
      maxHealth = 300;
      worth = 200;
      indexWalkSpeed = 0.04;
      indexAttackSpeed = 0.05;

      x = width + int(59 * resizeFactor);
      offsetL = int(59 * resizeFactor);
      offsetR = int(13 * resizeFactor);
      
      spriteWalk = shieldwallWalk;
      spriteAttack = shieldwallAttack;
    } else if (opponentNum == 3) {
      speed = 1.5;
      damage = 5;
      damageSpeed = 100;
      maxHealth = 50;
      worth = 200;
      indexWalkSpeed = 0.08;
      indexAttackSpeed = 0.08;

      x = width + int(51 * resizeFactor);
      offsetL = int(19 * resizeFactor);
      offsetR = int(13 * resizeFactor);
      
      spriteWalk = berserkerWalk;
      spriteAttack = berserkerAttack;
    }

    health = maxHealth;
  }
}
