class Block {
  int size;
  color c;
  float x, y;
  
  Block(color c_) {
    size = 50;
    c = c_;
  }
  
  Block(color c_, float x_, float y_) {
    size = 50;
    c = c_;
    x = x_;
    y = y_;
  }
  
  void display() { // Draws block
    noStroke();
    fill(c);
    rect(x, y, size, size);
  }
  
  void update(float x_, float y_) { // Update block position
    x = x_;
    y = y_;
  }
}
