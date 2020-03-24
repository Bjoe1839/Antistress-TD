class Button {
  int x1, y1, x2, y2;
  
  Button(int x1_, int y1_, int x2_, int y2_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;
  }
  
  boolean collision() {
    if (mouseX > x1 && mouseX < x2 && mouseY > y1 && mouseY < y2) return true;
    return false;
  }
  
  void display() {
  }
}


class DragButton extends Button {
  boolean dragging;
  String text;
  
  DragButton(int x1, int y1, int x2, int y2, String text_) {
    super(x1, y1, x2, y2);
    text = text_;
  }
  
  void display(int status) {
    if (status == 0) fill(255);
    else if (status == 1) fill(220);
    else fill(190);
    
    rect(x1, y1, x2, y2);
    fill(0);
    text(text, x1, y1);
  }
}


class TowerButton extends DragButton {
  int towerNum;
  
  TowerButton(int x1, int y1, int x2, int y2, String text, int towerNum_) {
    super(x1, y1, x2, y2, text);
    towerNum = towerNum_;
  }
  
}
