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
  int size, alfa, towerNum;
  boolean placed;

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
      fill(255, 0, 0, alfa);
      break;
    case 1:
      fill(0, 255, 0, alfa);
      break;
    case 2:
      fill(0, 0, 255, alfa);
      break;
    case 3:
      fill(255, 255, 0, alfa);
      break;
    case 4:
      fill(0, alfa);
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
}






class Fighter extends ShooterTower {
  Fighter(int x, int y, boolean placed, int size, int alfa, int laneNum) {
    super(x, y, placed, size, alfa, 0, laneNum);
    maxHealth = 100;
    health = maxHealth;
    shotSpeed = 120;
    damage = 15;
    range = 2;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new FighterProjectile(x+30, y, damage, laneNum, range));
    }
  }
}


class Sniper extends ShooterTower {
  Sniper(int x, int y, boolean placed, int size, int alfa, int laneNum) {
    super(x, y, placed, size, alfa, 1, laneNum);
    maxHealth = 150;
    health = maxHealth;
    shotSpeed = 45;
    damage = 3;
    range = 9;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new SniperProjectile(x+30, y, damage, laneNum, range));
    }
  }
}


class Freezer extends ShooterTower {
  Freezer(int x, int y, boolean placed, int size, int alfa, int laneNum) {
    super(x, y, placed, size, alfa, 2, laneNum);
    maxHealth = 200;
    health = maxHealth;
    shotSpeed = 240;
    damage = 0;
    range = 4;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new FreezerProjectile(x+30, y, damage, laneNum, range));
    }
  }
}


class Blaster extends ShooterTower {
  Blaster(int x, int y, boolean placed, int size, int alfa, int laneNum) {
    super(x, y, placed, size, alfa, 4, laneNum);
    maxHealth = 300;
    health = maxHealth;
    shotSpeed = 300;
    damage = 20;
    range = 4;
  }

  void activate() {
    if (shouldShoot()) {
      projectiles.add(new BlasterProjectile(x+30, y, damage, laneNum, range));
    }
  }
}


class Booster extends FriendlyTower {
  Booster(int x, int y, boolean placed, int size, int alfa) {
    super(x, y, placed, size, alfa, 3);
    maxHealth = 200;
    health = maxHealth;
  }

  void activate() {
  }
}




class OpponentTower extends Tower {
  int laneNum;
  int speed, damage, damageSpeed, damageCooldown, worth;

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

    damageCooldown--;
    boolean collision = false;
    //tjekker kun for kollision for tårne på egen lane
    for (int i = 0; i < squares.length; i++) {
      if (squares[i][laneNum].tower != null && squares[i][laneNum].tower.x+40 >= x-40 && squares[i][laneNum].tower.x-40 <= x+40) {
        collision = true;
        if (damageCooldown <= 0) {
          damageCooldown = damageSpeed;
          squares[i][laneNum].tower.health -= damage;
        }
      }
    }

    if (!collision) {
      if (frameCount%2 == 0) x -= speed;
      if (x < -40) gameOver = true;
    }
  }

  void display() {
    fill(0);
    rect(x-40, y-40, x+40, y+40);

    displayHealth();
  }
}
