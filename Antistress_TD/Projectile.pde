class Projectile { //<>//
  int x, y, rangeX, laneNum;
  int speed, damage, size;
  boolean upgraded;

  Projectile(int x_, int y_, int laneNum_, int range, boolean upgraded_) {
    x = x_;
    y = y_;
    laneNum = laneNum_;
    rangeX = range*(width/squares.length-1) + x;
    upgraded = upgraded_;
  }

  boolean move() {
    x += speed;

    if (x > rangeX || x + size/2 > width) {
      projectiles.remove(this);
      return true;
    }

    for (OpponentTower ot : opponentTowers) {
      if (ot.laneNum == laneNum && ot.x + ot.offsetR >= x - size/2 && ot.x - ot.offsetL <= x + size/2) {

        hitOpponent(ot);

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

  FighterProjectile(int x, int y, int damage_, int laneNum, int range, boolean upgraded) {
    super(x, y, laneNum, range, upgraded);
    damage = damage_;
    if (!upgraded) {
      size = fighterProjectile.width;
      speed = 5;
    }
    else {
      size = fighterlv2Projectile.width;
      speed = 6;
    }
  }

  void display() {
    if (!upgraded) image(fighterProjectile, x, y);
    else image(fighterlv2Projectile, x, y);
  }
}

class ArcherProjectile extends Projectile {

  ArcherProjectile(int x, int y, int damage_, int laneNum, int range, boolean upgraded) {
    super(x, y, laneNum, range, upgraded);

    damage = damage_;
    if (!upgraded) {
      size = archerProjectile.width;
      speed = 15;
    } else {
      size = archerlv2Projectile.width;
      speed = 20;
    }
  }

  void display() {
    if (!upgraded) image(archerProjectile, x, y);
    else image(archerlv2Projectile, x, y);
  }
}

class FreezerProjectile extends Projectile {
  //roterende snefnug/snebolde
  int slowDur, freezeDur;
  FreezerProjectile(int x, int y, int laneNum, int range, int slowDur_, int freezeDur_, boolean upgraded) {
    super(x, y, laneNum, range, upgraded);
    speed = 4;
    damage = 0;
    size = 10;
    slowDur = slowDur_;
    freezeDur = freezeDur_;
  }

  void display() {
    fill(0, 0, 255);
    noStroke();
    circle(x, y, size);
    stroke(0);
  }

  void hitOpponent(OpponentTower opponent) {
    opponent.slowCooldown += slowDur;
    opponent.freezeCooldown += freezeDur;
  }
}

class BlasterProjectile extends Projectile {
  int explosionSize;
  //roterende bomber/ikke-roterende raketter
  BlasterProjectile(int x, int y, int damage_, int laneNum, int range, boolean upgraded) {
    super(x, y, laneNum, range, upgraded);
    speed = 3;
    damage = damage_;
    size = 30;
    explosionSize = 250;
  }

  void hitOpponent(OpponentTower opponent) {
    for (int i = opponentTowers.size()-1; i >= 0; i--) {
      if (dist(x, y, opponentTowers.get(i).x, opponentTowers.get(i).y) < explosionSize) {
        opponentTowers.get(i).health -= damage;
        if (opponentTowers.get(i).health <= 0) {
          money += opponentTowers.get(i).worth;
          opponentTowers.remove(opponentTowers.get(i));
        }
      }
    }
  }
}
