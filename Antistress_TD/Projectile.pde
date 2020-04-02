class Projectile {
  int x, y, rangeX, laneNum;
  int speed, damage, size;
  //boolean upgraded;

  Projectile(int x_, int y_, int laneNum_, int range) {
    x = x_;
    y = y_;
    laneNum = laneNum_;
    rangeX = range*(width/squares.length-1) + x;
  }

  boolean move() {
    x += speed;

    if (x > rangeX) {
      projectiles.remove(this);
      return true;
    }

    for (int i = opponentTowers.size()-1; i >= 0; i--) {
      if (opponentTowers.get(i).laneNum == laneNum && opponentTowers.get(i).x + 40 >= x - size && opponentTowers.get(i).x - 40 <= x + size) {

        hitOpponent(opponentTowers.get(i));

        projectiles.remove(this);
        return true;
      }
    }
    return false;
  }
  
  void display() {
    fill(0);
    circle(x, y, size);
  }

  void hitOpponent(OpponentTower opponent) {
    opponent.health -= damage;
    if (opponent.health <= 0) {
      money += opponent.worth;
      opponentTowers.remove(opponent);
    }
  }
}



class FighterProjectile extends Projectile {
  //roterende knive
  FighterProjectile(int x, int y, int damage_, int laneNum, int range) {
    super(x, y, laneNum, range);
    speed = 5;
    damage = damage_;
    size = 10;
  }
}

class SniperProjectile extends Projectile {
  //pile
  SniperProjectile(int x, int y, int damage_, int laneNum, int range) {
    super(x, y, laneNum, range);
    speed = 8;
    damage = damage_;
    size = 5;
  }
}

class FreezerProjectile extends Projectile {
  //roterende snefnug/snebolde
  FreezerProjectile(int x, int y, int damage_, int laneNum, int range) {
    super(x, y, laneNum, range);
    speed = 4;
    damage = damage_;
    size = 10;
  }
  
  void display() {
    fill(0, 0, 255);
    noStroke();
    circle(x, y, size);
    stroke(0);
  }
}

class BlasterProjectile extends Projectile {
  //roterende bomber/ikke-roterende raketter
  BlasterProjectile(int x, int y, int damage_, int laneNum, int range) {
    super(x, y, laneNum, range);
    speed = 3;
    damage = damage_;
    size = 30;
  }
}
