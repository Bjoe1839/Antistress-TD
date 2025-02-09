class Projectile {
  int x, y, rangeX, laneNum;
  int speed, damage, size;
  boolean upgraded;

  Projectile(int x_, int y_, int offset, int laneNum_, int range, boolean upgraded_) {
    x = x_ + offset; //skal spawne på højre side af spriten
    y = y_;
    laneNum = laneNum_;
    rangeX = int(range * (width / squares.length - 1) + (width / squares.length - 1) * .5) + x - offset;
    upgraded = upgraded_;
  }

  boolean move() {
    x += speed;

    if (x > rangeX || x + size/2 > width) {
      projectiles.remove(this);
      return true;
    }

    for (OpponentTower ot : level.opponentTowers) {
      //om projektilet rammer en modstander
      if (ot.laneNum == laneNum && ot.x + ot.offsetR >= x - size/2 && ot.x - ot.offsetL <= x + size/2) {

        opponentHit(ot);

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

  void opponentHit(OpponentTower opponent) {
    opponent.health -= damage;
    
    if (opponent.health <= 0) {
      money += opponent.worth;
      level.opponentTowers.remove(opponent);
    }
  }
}



class FighterProjectile extends Projectile {

  FighterProjectile(int x, int y, int offset, int damage_, int laneNum, int range, boolean upgraded) {
    super(x, y, offset, laneNum, range, upgraded);
    damage = damage_;
    if (!upgraded) {
      size = fighterProjectile.width;
      speed = 6;
    } else {
      size = fighterlv2Projectile.width;
      speed = 7;
    }
  }

  void display() {
    if (!upgraded) image(fighterProjectile, x, y);
    else image(fighterlv2Projectile, x, y);
  }
}

class ArcherProjectile extends Projectile {
  ArcherProjectile(int x, int y, int offset, int damage_, int laneNum, int range, boolean upgraded) {
    super(x, y, offset, laneNum, range, upgraded);

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
  int slowDur, freezeDur;
  float angle;
  FreezerProjectile(int x, int y, int offset, int damage_, int laneNum, int range, int slowDur_, int freezeDur_, boolean upgraded) {
    super(x, y, offset, laneNum, range, upgraded);
    speed = 8;
    damage = damage_;
    size = 10;
    slowDur = slowDur_;
    freezeDur = freezeDur_;
  }

  void display() {
    if (!upgraded) {
      //skal rotere
      if (!gameMenu) angle += .3;

      pushMatrix();
      translate(x, y);
      rotate(angle);
      image(freezerProjectile, 0, 0);
      popMatrix();
    } else image(freezerlv2Projectile, x, y);
  }

  void opponentHit(OpponentTower opponent) {
    super.opponentHit(opponent);

    //gør modstandere langsommere
    opponent.slowCooldown += slowDur;
    opponent.freezeCooldown += freezeDur;
  }
}

class BomberProjectile extends Projectile {
  int explosionSize;
  float angle;
  BomberProjectile(int x, int y, int offset, int damage_, int laneNum, int range, boolean upgraded, int explosionSize_) {
    super(x, y, offset, laneNum, range, upgraded);
    speed = 6;
    damage = damage_;
    size = 30;
    explosionSize = explosionSize_;
  }

  void opponentHit(OpponentTower opponent) {
    //alle modstandere med en hvis afstand til projektilet bliver skadede
    for (int i = level.opponentTowers.size()-1; i >= 0; i--) {
      if (dist(x, y, level.opponentTowers.get(i).x, level.opponentTowers.get(i).y) < explosionSize) {
        level.opponentTowers.get(i).health -= damage;
        
        if (level.opponentTowers.get(i).health <= 0) {
          money += level.opponentTowers.get(i).worth;
          level.opponentTowers.remove(level.opponentTowers.get(i));
        }
      }
    }
    particles.add(new Explosion(x, y, int(explosionSize * .75)));
  }

  void display() {
    if (!gameMenu) angle += .15;

    pushMatrix();
    translate(x, y);
    rotate(angle);

    if (!upgraded) image(bomberProjectile, 0, 0);
    else image(bomberlv2Projectile, 0, 0);
    popMatrix();
  }
}
