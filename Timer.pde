class Timer {
  int startTime;
  int timeSoFar;
  boolean running;
  int x, y;
  
  Timer(int x_, int y_) {
    x = x_;
    y = y_;
    running = false;
    timeSoFar = 0;
  }
  
  int currentTime() {
    if (running)
      return int((millis() - startTime) / 1000.0);
    else
      return int(timeSoFar / 1000.0);
  }
  
  void start() {
    running = true;
    startTime = millis();
  }
  
  void restart() {
    start();
  }
  
  void pause() {
    if (running) {
      timeSoFar = millis() - startTime;
      running = false;
    }
  }
  
  void display() {
    String output = "";
    int current = currentTime();
    output += current;
    
    fill(255);
    textSize(40);
    text(output, x, y);
  }
}
