class Tower {
  float x;
  int y;
  int health, maxHealth;
  int offsetL, offsetR; //hvor billedets kollision strækker sig over

  Tower(int x_, int y_, int offsetL_, int offsetR_) {
    x = x_;
    y = y_;
    offsetL = int(offsetL_ * resizeX);
    offsetR = int(offsetR_ * resizeX);
  }

  Tower(int y_) {
    y = y_;
  }

  void shadow() {
    image(shadow, x, y);
  }

  void display() {
    //healthbar
    stroke(0, 70);

    int c = int(map(health, 0, maxHealth, 0, 255));
    fill(255-c, c, 0, 150);

    int len = int(30 * resizeX);
    int hei = int(70 * resizeX);

    int xEnd = int(map(health, 0, maxHealth, x - len, x + len));
    rect(x - len, y - hei, xEnd, y - hei + 5);
    stroke(0);
  }
}


class FriendlyTower extends Tower {
  PImage[] sprite;
  int towerNum, worth, actualWorth, upgradePrice;
  float spriteIndex;
  boolean placed, upgraded;

  FriendlyTower(int x, int y, int offsetL, int offsetR, boolean placed_, int towerNum_) {
    super(x, y, offsetL, offsetR);
    placed = placed_;
    towerNum = towerNum_;
  }

  void display() {
    super.display();

    image(sprite[floor(spriteIndex)], x, y);
  }

  void activate() {
  }

  void setStats(int boostingStatus) {
  }

  void ability() {
  }
}





class ShooterTower extends FriendlyTower {
  int range, damage, shotSpeed, shotCooldown, laneNum;
  boolean hasShot;

  ShooterTower(int x, int y, int offsetL, int offsetR, boolean placed, int towerNum, int laneNum_) {
    super(x, y, offsetL, offsetR, placed, towerNum);
    laneNum = laneNum_;
  }


  void activate() {
    //hvis en animation er i gang
    if (spriteIndex > 0) {
      if (spriteIndex >= sprite.length-1) {
        if (!hasShot) {
          shoot();
          hasShot = true;
        }
        if (spriteIndex >= sprite.length) {
          spriteIndex = 0;
          hasShot = false;
        }
      }
    }

    if (shouldShoot()) {
      //hvis en animation allerede er i gang
      if (spriteIndex > 0 && !hasShot) {
        shoot();
      }
      spriteIndex = 1;
      hasShot = false;
    }
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
    for (OpponentTower opponent : level.opponentTowers) {
      int d = int(opponent.x - opponent.offsetL - x);
      if (opponent.laneNum == laneNum && d < range * (width/squares.length-1) && d >= 0) {
        return true;
      }
    }
    return false;
  }

  void setStats(int boostingStatus) {
    //hvis tårnet er boostet med en almindelig priest
    if (boostingStatus == 1) {
      shotSpeed *= .9;
      damage *= 1.1;
      if (range < 9) range++;

      //hvis tårnet er boostet med en opgraderet priest
    } else if (boostingStatus == 2) {
      shotSpeed *= .85;
      damage *= 1.15;
      range += 2;
      if (range > 9) range = 9;
    }
  }

  void shoot() {
  }

  void display() {
    super.display();
  }
}






class Fighter extends ShooterTower {
  int abilityCooldown, abilityShotSpeed;

  Fighter(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, 13, 19, placed, 0, laneNum);

    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 100;
    abilityShotSpeed = int(shotSpeed * .33);
  }

  void activate() {
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
    }
    if (spriteIndex > 0) spriteIndex += 0.1;

    super.activate();
  }

  void shoot() {
    projectiles.add(new FighterProjectile(int(x + offsetR), y, damage, laneNum, range, upgraded));
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = fighter;
      worth = 60;
      actualWorth = worth;
      maxHealth = 100;
      shotSpeed = 180;
      damage = 15;
      range = 2;
    } else {
      sprite = fighterlv2;
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
}




class Archer extends ShooterTower {
  int abilityCooldown;

  Archer(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, 21, 19, placed, 1, laneNum);
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
    } else if (spriteIndex > 0) spriteIndex += 0.08;

    super.activate();
  }

  void shoot() {
    projectiles.add(new ArcherProjectile(int(x + offsetR), y - int(16  * resizeX), damage, laneNum, range, upgraded));
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = archer;
      worth = 60;
      actualWorth = worth;
      maxHealth = 150;
      shotSpeed = 75;
      damage = 5;
      range = 9;
    } else {
      sprite = archerlv2;
      worth = 150;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
      //add
    }
    super.setStats(boostingStatus);
  }

  void ability() {
    abilityCooldown = 60;
  }
}


class Freezer extends ShooterTower {
  int slowDur, freezeDur;

  Freezer(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, 22, 19, placed, 2, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 150;
  }

  void activate() {
    if (spriteIndex > 0) spriteIndex += .12;
    super.activate();
  }

  void shoot() {
    projectiles.add(new FreezerProjectile(int(x + offsetR), y - int(37 * resizeY), laneNum, range, slowDur, freezeDur, upgraded));
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = freezer;
      worth = 100;
      actualWorth = worth;
      maxHealth = 200;
      shotSpeed = 240;
      damage = 0;
      range = 4;
      slowDur = 60;
      freezeDur = 0;
    } else {
      sprite = freezerlv2;
      slowDur = 90;
      freezeDur = 60;
      worth = 200;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
      //add
    }
    super.setStats(boostingStatus);
  }

  void ability() {
    for (OpponentTower opponent : level.opponentTowers) {
      opponent.freezeCooldown += 120;
      opponent.slowCooldown += 120;
    }
  }
}



class Bomber extends ShooterTower {
  boolean ability;
  
  Bomber(int x, int y, boolean placed, int boostingStatus, int laneNum) {
    super(x, y, 35, 58, placed, 4, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 250;
  }


  void activate() {
    if (spriteIndex > 0) spriteIndex += .1;
    super.activate();
  }

  void shoot() {
    if (!ability) projectiles.add(new BomberProjectile(int(x + offsetR), y + int(7 * resizeY), damage, laneNum, range, upgraded));
    else {
      projectiles.add(new BomberProjectile(int(x + offsetR), y + int(7 * resizeY), damage*3, laneNum, range*2, upgraded));
      ability = false;
    }
  }


  void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = bomber;
      worth = 150;
      actualWorth = worth;
      maxHealth = 300;
      shotSpeed = 300;
      damage = 20;
      range = 4;
    } else {
      sprite = bomberlv2;
      worth = 250;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
      //add
    }
    super.setStats(boostingStatus);
  }
  
  void ability() {
    ability = true;
    if (spriteIndex == 0) spriteIndex = 1;
  }
}


class Priest extends FriendlyTower {
  int cooldown;

  Priest(int x, int y, boolean placed) {
    super(x, y, 27, 19, placed, 3);
    setStats(0);
    health = maxHealth;
    upgradePrice = 200;
  }

  void activate() {
    if (spriteIndex > 0) {
      spriteIndex += .06;
      if (spriteIndex >= sprite.length) spriteIndex = 0;
    }
    if (!levelFinished) {
      cooldown--;
      if (cooldown <= 0) {
        cooldown = 150;
        spriteIndex = 1;
      }
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      sprite = priest;
      worth = 200;
      actualWorth = worth;
      maxHealth = 200;
    } else {
      sprite = priestlv2;
      worth = 300;
      actualWorth = int(map(health, 0, maxHealth, 0, worth));
      //add
    }
  }
  
  void ability() {
    //heler alle tårne med 50%
    for (Square[] squareRow : squares) for (Square square : squareRow) {
      if (square.tower != null) {
        square.tower.health += square.tower.maxHealth * .5;
        if (square.tower.health > square.tower.maxHealth) square.tower.health = square.tower.maxHealth;
      }
    }
  }
}



class OpponentTower extends Tower {
  int laneNum, opponentNum;
  int damage, worth;
  int[] damageAt;
  float speed;
  int slowCooldown, freezeCooldown;
  float indexAttack, indexWalk, indexWalkSpeed, indexAttackSpeed;
  Square collisionTower;
  PImage[] spriteWalk, spriteAttack;


  OpponentTower(int y, int laneNum_, int opponentNum_) {
    super(y);
    laneNum = laneNum_;
    opponentNum = opponentNum_;
    setStats();
  }

  void move() {
    collisionTower = null;
    //tjekker kun for kollision for tårne på egen lane

    for (int i = 0; i < squares.length; i++) {
      if (squares[i][laneNum].tower != null && squares[i][laneNum].tower.x + squares[i][laneNum].tower.offsetR >= x - offsetL && squares[i][laneNum].tower.x - squares[i][laneNum].tower.offsetL <= x + offsetR) {
        collisionTower = squares[i][laneNum];
      }
    }
    if (freezeCooldown > 0) freezeCooldown--;

    if (slowCooldown > 0 && freezeCooldown == 0) slowCooldown--;

    if (collisionTower == null && freezeCooldown == 0) {
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
      if (collisionTower != null) indexSpeed = indexAttackSpeed;
      else indexSpeed = indexWalkSpeed;

      if (slowCooldown > 0) {
        indexSpeed *= .5;
      }

      if (collisionTower != null) indexAttack += indexSpeed;
      else indexWalk += indexSpeed;

      if (indexAttack >= spriteAttack.length) indexAttack = 0;

      else if (indexAttack >= spriteAttack.length-1 && indexAttack < spriteAttack.length-1 + indexSpeed ||
        opponentNum == 3 && indexAttack >= spriteAttack.length-2 && indexAttack < spriteAttack.length-2 + indexSpeed) {
        if (collisionTower != null) {
          collisionTower.tower.health -= damage;
          collisionTower.tower.actualWorth = int(map(collisionTower.tower.health, 0, collisionTower.tower.maxHealth, 0, collisionTower.tower.worth));
        }
      }

      if (indexWalk >= spriteWalk.length) indexWalk = 0;
    }
  }

  void display() {
    super.display();

    if (freezeCooldown > 0) tint(150, 150, 255);
    else if (slowCooldown > 0) tint(200, 200, 255);

    if (collisionTower != null) image(spriteAttack[floor(indexAttack)], x, y);
    else image(spriteWalk[floor(indexWalk)], x, y);

    noTint();
  }

  void setStats() {
    if (opponentNum == 0) {
      //axeman
      speed = .5;
      damage = 2;
      maxHealth = 100;
      worth = 200;
      indexWalkSpeed = 0.05;
      indexAttackSpeed = 0.15;

      x = width + int(37 * resizeX);
      offsetL = int(21 * resizeX);
      offsetR = int(19 * resizeX);

      spriteWalk = axemanWalk;
      spriteAttack = axemanAttack;
    } else if (opponentNum == 1) {
      //warrior
      speed = .75;
      damage = 15;
      maxHealth = 150;
      worth = 200;
      indexWalkSpeed = 0.06;
      indexAttackSpeed = 0.12;

      x = width + int(39 * resizeX);
      offsetL = int(26 * resizeX);
      offsetR = int(19 * resizeX);

      spriteWalk = warriorWalk;
      spriteAttack = warriorAttack;
    } else if (opponentNum == 2) {
      //shieldwall
      speed = .3;
      damage = 5;
      maxHealth = 300;
      worth = 200;
      indexWalkSpeed = 0.04;
      indexAttackSpeed = 0.05;

      x = width + int(59 * resizeX);
      offsetL = int(59 * resizeX);
      offsetR = int(13 * resizeX);

      spriteWalk = shieldwallWalk;
      spriteAttack = shieldwallAttack;
    } else if (opponentNum == 3) {
      //berserker
      speed = 1.5;
      damage = 5;
      maxHealth = 50;
      worth = 200;
      indexWalkSpeed = 0.08;
      indexAttackSpeed = 0.08;

      x = width + int(51 * resizeX);
      offsetL = int(19 * resizeX);
      offsetR = int(13 * resizeX);

      spriteWalk = berserkerWalk;
      spriteAttack = berserkerAttack;
    }

    health = maxHealth;
  }
}
