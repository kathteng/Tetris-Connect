import processing.sound.*;
SoundFile menuMusic;
SoundFile click;
SoundFile clear;
SoundFile gameOver;

PImage menuBg;
PFont titleFont;
PFont buttonFont;

Button start;
Button quit;
Button normalLevel;
Button hardLevel;
Button back;
Button menu;
Button quit2;

Timer timer;
Board b;
boolean startGame = true;
boolean gameIsOver = false;
int menuPage = 1;
int x1, y1 = 0, x2, y2 = 1; // Location of current blocks, start at top row
color c1, c2;
int savedTime1;
int savedTime2;

void setup() {
  menuMusic = new SoundFile(this, "menu_music.wav");
  click = new SoundFile(this, "click.wav");
  clear = new SoundFile(this, "clear.wav");
  gameOver = new SoundFile(this, "game_over.wav");
  
  menuMusic.amp(0.3);
  clear.amp(0.4);
  gameOver.amp(0.6);
  
  menuBg = loadImage("tetris_wallpaper.jpg");
  titleFont = loadFont("Impact-120.vlw");
  buttonFont = loadFont("Impact-80.vlw");
  
  timer = new Timer(350, height/5 * 3 + 100);
  start = new Button("Start", width/3, height/2);
  quit = new Button("Quit", width/3 * 2, height/2);
  normalLevel = new Button("Normal", width/3, height/2, 250);
  hardLevel = new Button("Hard", width/3 * 2, height/2);
  back = new Button("Back", width - 100, 50);
  menu = new Button("Menu", width/2, height/3 * 2 - 10);
  quit2 = new Button("Quit", width/2, height/4 * 3 + 50);
  
  size(1217, 871);
  textAlign(CENTER, CENTER);
  menuMusic.loop();
}

void draw() {
  if (startGame == true) {
    drawMenu();
  }
  else {
    menuMusic.stop();
    background(50);
    b.drawBoard();
    
    fill(255);
    textSize(40);
    text("Clears: " + b.clears, 285, height/5 * 3);
    timer.display(); // Draw stop watch timer
    
    if (b.checkIfLost() && gameIsOver == false) { // Game over
      menuMusic.stop();
      gameOver.play();
      gameIsOver = true;
      timer.pause();
    }
    else if (gameIsOver == false) {
      int passedTime1 = millis() - savedTime1;
      //int passedTime2 = millis() - savedTime2;
      if (passedTime1 > b.dropSpeed * 1000) {
        // Move current blocks down 1
        if ((y2 > y1 && y2 == b.checkStack(x2, y2)) || (y1 > y2 && y1 == b.checkStack(x1, y1))) {
          b.checkConnect(x1, y1, x2, y2, clear);
          newCurrentBlocks();
          //b.updateErase();
          b.updateNext();
        }
        else if (y1 == y2) {
          if (y1 == b.checkStack(x1, y1) && y2 == b.checkStack(x2, y2)) {
            b.checkConnect(x1, y1, x2, y2, clear);
            newCurrentBlocks();
            //b.updateErase();
            b.updateNext();
          }
          else if (y1 == b.checkStack(x1, y1) && y2 != b.checkStack(x2, y2)) {
            b.blockGrid[x2][y2].c = 0;
            y2 = b.checkStack(x2, y2);
            b.updateBoard(x1, y1, x2, y2, c1, c2, false);
            b.checkConnect(x1, y1, x2, y2, clear);
            newCurrentBlocks();
            //b.updateErase();
            b.updateNext();
          }
          else if (y2 == b.checkStack(x2, y2) && y1 != b.checkStack(x1, y1)) {
            b.blockGrid[x1][y1].c = 0;
            y1 = b.checkStack(x1, y1);
            b.updateBoard(x1, y1, x2, y2, c1, c2, false);
            b.checkConnect(x1, y1, x2, y2, clear);
            newCurrentBlocks();
            //b.updateErase();
            b.updateNext();
          }
          else {
            y1++;
            y2++;
            b.updateBoard(x1, y1, x2, y2, c1, c2, false);
            savedTime1 = millis();
          }
        }
        else {
          y1++;
          y2++;
          b.updateBoard(x1, y1, x2, y2, c1, c2, false);
          savedTime1 = millis();
        }
      }
      //if (passedTime2 > b.greyBlockSpeed * 1000) {
        // Generate random location and amount of grey blocks and drop them
        //int num = int(random(1, 5));
        //for (int i = 0; i < num; i++) {
          //int greyX = int(random(7));
          //b.blockGrid[greyX][0].c = b.colors[6];
        //}
        //savedTime2 = millis();
      //}
      
      if (y2 == 8 || y1 == 8) {
        b.checkConnect(x1, y1, x2, y2, clear);
        newCurrentBlocks();
        //b.updateErase();
        b.updateNext();
      }
    }
    
    if (gameIsOver) {
      drawGameOver();
    }
  }
}

void drawMenu() { // Draw main menu
  background(menuBg);
  
  if (menuPage == 1) { // Start page
    fill(255);
    textFont(titleFont);
    text("Tetris - Connect", width/2, 150);
    start.drawButton();
    quit.drawButton();
  }
  else if (menuPage == 2) { // Choose difficulty level page
    fill(255);
    textFont(buttonFont);
    text("Choose Difficulty", width/2, 150);
    normalLevel.drawButton();
    hardLevel.drawButton();
    back.drawButton();
  }
}

void drawGameOver() { // draw Game Over menu
  stroke(255);
  strokeWeight(3);
  fill(0, 190);
  rect(width/2 - 300, 200 - 100, 600, 700);
  textFont(titleFont);
  fill(255);
  text("Game Over", width/2, 200);
  textFont(buttonFont);
  text("Clears: " + b.clears, width/2, height/2 - 100);
  text("Time: " + timer.currentTime() + " s", width/2, height/2);
  menu.drawButton();
  quit2.drawButton();
}

void mousePressed() {
  if (startGame == true && menuPage == 1) {
    if (quit.checkInButton()) {
      exit();
    }
    if (start.checkInButton()) {
      menuPage++;
    }
  }
  else if (startGame == true && menuPage == 2) {
    if (back.checkInButton()) {
      menuPage--;
    }
    if (normalLevel.checkInButton()) {
      startGame = false;
      b = new Board(false);
      timer.start();
      savedTime1 = millis();
      savedTime2 = millis();
      x1 = 3;
      x2 = x1;
      c1 = b.colors[int(random(6))];
      c2 = b.colors[int(random(6))];
      b.updateBoard(x1, y1, x2, y2, c1, c2, false);
    }
    if (hardLevel.checkInButton()) {
      startGame = false;
      b = new Board(true);
      timer.start();
      savedTime1 = millis();
      savedTime2 = millis();
      x1 = 3;
      x2 = x1;
      c1 = b.colors[int(random(6))];
      c2 = b.colors[int(random(6))];
      b.updateBoard(x1, y1, x2, y2, c1, c2, false);
    }
  }
  if (gameIsOver) {
    if (menu.checkInButton())
      reset();
    if (quit2.checkInButton())
      exit();
  }
}

void keyPressed() {
  // When spacebar is pressed, play click sound
    // Update block location and call b.checkConnected()
  if (startGame == false && key == ' ' && gameIsOver == false) {
    click.play();
    b.blockGrid[x1][y1].c = 0;
    b.blockGrid[x2][y2].c = 0;
    if (y1 == y2) {
      y1 = b.checkStack(x1, y1);
      y2 = b.checkStack(x2, y2);
    }
    else if (y2 < y1) {
      y1 = b.checkStack(x1, y1);
      y2 = y1 - 1;
    }
    else {
      y2 = b.checkStack(x2, y2);
      y1 = y2 - 1;
    }
    
    b.updateBoard(x1, y1, x2, y2, c1, c2, false);
    b.checkConnect(x1, y1, x2, y2, clear);
    newCurrentBlocks();
    //b.updateErase();
    b.updateNext();
  }
  
  if (startGame == false && key == BACKSPACE && gameIsOver == false) {
    reset();
  }
  
  // When left or right key is pressed, move block left or right
  if (key == CODED) {
    if (keyCode == UP && gameIsOver == false) { // Rotate blocks
      if ((y1 < y2 && x2 + 1 < 7) || (x1 > x2 && y2 + 1 < 9) || (y2 < y1 && x2 - 1 >= 0) || (x1 < x2 && y2 - 1 >= 0)) {
        if ((y1 < y2 && b.blockGrid[x2 + 1][y2].c == 0) || (x1 > x2 && b.blockGrid[x2][y2 + 1].c == 0) || (y2 < y1 && b.blockGrid[x2 - 1][y2].c == 0) || (x1 < x2 && b.blockGrid[x2][y2 - 1].c == 0)) {
          rotate();
          b.updateBoard(x1, y1, x2, y2, c1, c2, true);
        }
      }
    }
    else if (keyCode == LEFT && gameIsOver == false) { // Move blocks left
      if (x1 > 0 && x2 > 0) {
        if (x2 > x1 || y1 > y2) {
          if (b.blockGrid[x1 - 1][y1].c == 0) {
            b.blockGrid[x1][y1].c = 0;
            b.blockGrid[x2][y2].c = 0;
            x1--;
            x2--;
            b.updateBoard(x1, y1, x2, y2, c1, c2, false);
          }
        }
        else {
          if (b.blockGrid[x2 - 1][y2].c == 0) {
            b.blockGrid[x1][y1].c = 0;
            b.blockGrid[x2][y2].c = 0;
            x1--;
            x2--;
            b.updateBoard(x1, y1, x2, y2, c1, c2, false);
          }
        } 
      }
    }
    else if (keyCode == RIGHT && gameIsOver == false) { // Move blocks right
      if (x1 < 6 && x2 < 6) {
        if (x1 > x2 || y1 > y2) {
          if (b.blockGrid[x1 + 1][y1].c == 0) {
            b.blockGrid[x1][y1].c = 0;
            b.blockGrid[x2][y2].c = 0;
            x1++;
            x2++;
            b.updateBoard(x1, y1, x2, y2, c1, c2, false);
          }
        }
        else {
          if (b.blockGrid[x2 + 1][y2].c == 0) {
            b.blockGrid[x1][y1].c = 0;
            b.blockGrid[x2][y2].c = 0;
            x1++;
            x2++;
            b.updateBoard(x1, y1, x2, y2, c1, c2, false);
          }
        }
      }
    }
  }
}

void rotate() { // Rotate blocks
  if (x1 == x2 && y1 < y2) { // 1 ontop of 2
    x1 = x2 + 1;
    y1 = y2;
  }
  else if (x1 > x2 && y1 == y2) { // 1 right of 2
    x1 = x2;
    y1 = y2 + 1;
  }
  else if (x1 == x2 && y2 < y1) { // 2 ontop of 1
    x1 = x2 - 1;
    y1 = y2;
  }
  else if (x1 < x2 && y1 == y2) { // 1 left of 2
    x1 = x2;
    y1 = y2 - 1;
  }
}

void newCurrentBlocks() { // Set new current blocks
  x1 = 3;
  x2 = 3;
  y1 = 0;
  y2 = 1;
  if (b.blockGrid[x2][y2].c == 0)
    c2 = b.random1[1].c;
  else
    c2 = c1;
  
  c1 = b.random1[0].c;
  b.updateBoard(x1, y1, x2, y2, c1, c2, false);
}

void reset() { // Reset the game
  y1 = 0;
  y2 = 1;
  startGame = true;
  gameIsOver = false;
  menuPage = 1;
  b.clears = 0;
  b.reset();
  menuMusic.loop();
}
