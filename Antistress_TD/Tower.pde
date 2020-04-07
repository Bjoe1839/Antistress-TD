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
    rect(x-40, y-50, xEnd, y-45);
    stroke(0);
  }
}


class FriendlyTower extends Tower {
  int size, alfa, towerNum, worth, upgradePrice;
  boolean placed, upgraded;

  FriendlyTower(int x, int y, boolean placed_, int size_, int alfa_, int towerNum_) {
    super(x, y);
    placed = placed_;
    size = size_;
    alfa = alfa_;
    towerNum = towerNum_;
  }

  void display(boolean offset) {
    stroke(0, alfa);

    switch(towerNum) {
    case 0:
      if (!upgraded) fill(255, 0, 0, alfa);
      else fill(200, 0, 0, alfa);
      break;
    case 1:
      if (!upgraded) fill(0, 255, 0, alfa);
      else fill(0, 200, 0, alfa);
      break;
    case 2:
      if (!upgraded) fill(0, 0, 255, alfa);
      else fill(0, 0, 200, alfa);
      break;
    case 3:
      if (!upgraded) fill(255, 255, 0, alfa);
      else fill(200, 200, 0, alfa);
      break;
    case 4:
      if (!upgraded) fill(0, alfa);
      else fill(100, alfa);
      break;
    }

    if (!offset) circle(x, y, size);
    else circle(x+1, y+3, size);

    stroke(0);

    if (placed) {
      displayHealth();
    }
  }

  void activate() {
  }

  void upgrade() {
  }

  void setStats(int boostingStatus) {
  }
}





class ShooterTower extends FriendlyTower {
  int range, damage, shotSpeed, shotCooldown, laneNum;

  ShooterTower(int x, int y, boolean placed, int size, int alfa, int towerNum, int laneNum_) {
    super(x, y, placed, size, alfa, towerNum);
    laneNum = laneNum_;
  }

  boolean shouldShoot() {
    shotCooldown--;

    boolean inRange = false;
    for (OpponentTower opponent : opponentTowers) {
      if (opponent.laneNum == laneNum && opponent.x-x < range*(width/squares.length-1)) {
        inRange = true;
        break;
      }
    }

    if (inRange && shotCooldown <= 0) {
      shotCooldown = shotSpeed;
      return true;
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
}






class Fighter extends ShooterTower {
  Fighter(int x, int y, boolean placed, int size, int alfa, int boostingStatus, int laneNum) {
    super(x, y, placed, size, alfa, 0, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 100;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new FighterProjectile(x+30, y, damage, laneNum, range));
    }
  }


  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 60;
      maxHealth = 100;
      shotSpeed = 120;
      damage = 15;
      range = 2;
    } else {
      worth = 100;
      //maxHealth = 150; todo: fixx
      shotSpeed = 60;
      damage = 20;
    }

    super.setStats(boostingStatus);
  }
}


class Sniper extends ShooterTower {
  Sniper(int x, int y, boolean placed, int size, int alfa, int boostingStatus, int laneNum) {
    super(x, y, placed, size, alfa, 1, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 150;
  }

  void activate() {
    if (shouldShoot()) {
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
}


class Freezer extends ShooterTower {
  int freezeTime;

  Freezer(int x, int y, boolean placed, int size, int alfa, int boostingStatus, int laneNum) {
    super(x, y, placed, size, alfa, 2, laneNum);
    setStats(boostingStatus);
    health = maxHealth;
    upgradePrice = 150;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new FreezerProjectile(x+30, y, damage, laneNum, range, freezeTime));
    }
  }

  void setStats(int boostingStatus) {
    if (!upgraded) {
      worth = 100;
      maxHealth = 200;
      shotSpeed = 240;
      damage = 0;
      range = 4;
      freezeTime = 60;
    } else {
      freezeTime = 120;
      //add
    }

    super.setStats(boostingStatus);
  }
}



class Blaster extends ShooterTower {
  Blaster(int x, int y, boolean placed, int size, int alfa, int boostingStatus, int laneNum) {
    super(x, y, placed, size, alfa, 4, laneNum);
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
}


class Booster extends FriendlyTower {
  Booster(int x, int y, boolean placed, int size, int alfa) {
    super(x, y, placed, size, alfa, 3);
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
}




class OpponentTower extends Tower {
  int laneNum;
  int speed, damage, damageSpeed, damageCooldown, worth;
  int freezeCooldown;


  OpponentTower(int x, int y, int laneNum_) {
    super(x, y);
    laneNum = laneNum_;
    speed = 1;
    damage = 10;
    damageSpeed = 70;
    maxHealth = 100;
    health = maxHealth;
    worth = 200;
  }

  void move() {

    boolean collision = false;
    //tjekker kun for kollision for tårne på egen lane
    for (int i = 0; i < squares.length; i++) {
      if (squares[i][laneNum].tower != null && squares[i][laneNum].tower.x+40 >= x-40 && squares[i][laneNum].tower.x-40 <= x+40) {
        collision = true;
        if (damageCooldown <= 0) {
          damageCooldown = damageSpeed;
          squares[i][laneNum].tower.health -= damage;
        } else if (freezeCooldown <= 0) {
          damageCooldown--;
        } else if (frameCount%2 == 0) damageCooldown--;
      }
    }

    if (freezeCooldown > 0) freezeCooldown--;

    if (!collision) {
      if (freezeCooldown > 0) {
        if (frameCount%4 == 0) x--;
      } else if (frameCount%2 == 0) x--;

      if (x < -40) gameOver = true;
    }
  }

  void display() {
    if (freezeCooldown <= 0) fill(0);
    else fill(0, 0, 200);
    rect(x-40, y-40, x+40, y+40);

    displayHealth();
  }
}
