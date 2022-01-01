class Button {
  String s;
  int x, y; // center of the button
  int w, h;
  
  Button(String s_, int x_, int y_) {
    s = s_;
    x = x_;
    y = y_;
    w = 200;
    h = 100;
  }
  
  Button(String s_, int x_, int y_, int w_) {
    s = s_;
    x = x_;
    y = y_;
    w = w_;
    h = 100;
  }
  
  void drawButton() { // Draw button, with text
    if (checkInButton()) {
      fill(60);
    }
    else {
      noFill();
    }
    stroke(255);
    strokeWeight(3);
    rectMode(CENTER);
    rect(x, y, w, h);
    
    if (checkInButton()) {
      fill(200);
    }
    else {
      fill(255);
    }
    textAlign(CENTER, CENTER);
    textFont(buttonFont);
    text(s, x, y);
  }
  
  boolean checkInButton() { // Check if mouse is within button
    if (mouseX < x + w/2 && mouseX > x - w/2 && mouseY < y + h/2 && mouseY > y - h/2) {
      return true;
    }
    return false;
  }
}
