class Board {
  color[] colors = new color[7];
  Block[][] blockGrid = new Block[7][9];
  Block[] random1 = new Block[2];
  Block[] random2 = new Block[2];
  boolean isHard;
  boolean recheck = false;
  float dropSpeed;
  float greyBlockSpeed;
  int clears = 0;
  
  Board(boolean isHard_) {
    isHard = isHard_;
    blocksSetup();
    
    for (int i = 0; i < blockGrid.length; i++) {
      for (int j = 0; j < blockGrid[i].length; j++) {
        blockGrid[i][j] = new Block(0, width/3 + 58 * i + i, height/5 + 58 * j + j);
      }
    }
    // If isHard is true, set dropSpeed and greyBlockSpeed higher
    if (isHard == false) {
      dropSpeed = 1.8;
      //greyBlockSpeed = 5;
    }
    // Else, set them at normal values
    else {
      dropSpeed = 0.9;
      //greyBlockSpeed = 3.5;
    }
  }
  
  void drawBoard() { // Draw board
    noStroke();
    fill(0);
    rectMode(CORNER);
    rect(width/3, height/5, width/3, height/5 * 3);
    rect(width/3 * 2 + 50, height/5 + 20, 200, 400);
    
    // Board borders
    fill(255);
    rect(width/3 - 10, height/5, 10, height/5 * 3);
    rect(width/3 - 10, height/5 * 4, width/3 + 20, 10);
    rect(width/3 * 2, height/5, 10, height/5 * 3);
    
    // Side box showing next blocks
    rect(width/3 * 2 + 50, height/5 - 50, 200, 70);
    rect(width/3 * 2 + 50, height/5 + 20, 5, 400);
    rect(width/3 * 2 + 245, height/5 + 20, 5, 400);
    rect(width/3 * 2 + 50, height/5 + 420, 200, 5);
    fill(0);
    textSize(50);
    text("Next", width/3 * 2 + 150, height/5 - 20);
    
    // Draw blocks on the board
    for (int i = 0; i < blockGrid.length; i++) {
      for (int j = 0; j < blockGrid[i].length; j++) {
        blockGrid[i][j].display();
      }
    }
    // Display next blocks
    for (int i = 0; i < random1.length; i++) {
      random1[i].display();
      random2[i].display();
    }
  }
  
  void blocksSetup() {
    // Generate block colors and store them in array
    colors[0] = color(255, 0, 0); // Red
    colors[1] = color(#FF40FC); // Pink
    colors[2] = color(#5DFF5E); // Lime
    colors[3] = color(#4045FF); // Blue
    colors[4] = color(#74FCFF); // Teal
    colors[5] = color(#FFF63B); // Yellow
    colors[6] = color(#9D9D9D); // Grey
    
    // Randomly generate colors of the next blocks and set their locations
    for (int i = 0; i < random1.length; i++) {
      random1[i] = new Block(colors[int(random(6))], width/3 * 2 + 125, height/5 + 70 + 58 * i);
      random2[i] = new Block(colors[int(random(6))], width/3 * 2 + 125, height/5 + 260 + 58 * i);
    }
  }
  
  void updateBoard(int x1, int y1, int x2, int y2, color c1, color c2, boolean rotated) { // Update blockGrid
    blockGrid[x1][y1].c = c1;
    blockGrid[x2][y2].c = c2;
    if (y1 >= 0 && y2 > y1) { // 1 ontop of 2
      if (y1 > 0)
        blockGrid[x1][y1 - 1].c = 0;
      if (rotated)
        blockGrid[x1 - 1][y2].c = 0;
    }
    else if (x1 > x2 && y1 == y2) { // 1 right of 2
      blockGrid[x2][y2 - 1].c = 0;
      blockGrid[x1][y1 - 1].c = 0;
    }
    else if (y2 > 0 && y2 < y1) { // 2 ontop of 1
      blockGrid[x2][y2 - 1].c = 0;
      if (rotated)
        blockGrid[x2 + 1][y2].c = 0;
    }
    else if (x1 < x2 && y1 == y2) { // 1 left of 2
      blockGrid[x2][y2 - 1].c = 0;
      blockGrid[x1][y1 - 1].c = 0;
      if (y2 < 8 && rotated)
        blockGrid[x2][y2 + 1].c = 0;
    }
  }
  
  void updateNext() { // Move bottom two blocks up and generate new ones on the bottom
    for (int i = 0; i < random1.length; i++) {
      random1[i].c = random2[i].c;
      random2[i].c = colors[int(random(6))];
    }
  }
  
  int checkStack(int x2, int y2) { // Check if blocks reached top of stack
    for (int i = y2 + 1; i < blockGrid[x2].length; i++) {
      if (blockGrid[x2][i].c != 0)
        return i - 1;
    }
    return 8;
  }
  
  void checkConnect(int x1, int y1, int x2, int y2, SoundFile clear) {
    boolean check2 = checkConn(x2, y2, clear);
    boolean check1 = checkConn(x1, y1, clear);
    boolean checkAgain = false;
    recheck = check1 || check2;
    
    while (recheck) { //if erase takes place, all blocks needs to be checked
      recheck = false;
      for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 9; j++) {
          if (blockGrid[i][j].c != 0)
            checkAgain = checkConn(i, j, clear);
          recheck = recheck || checkAgain;
        }
      }
    }
  }
  
  boolean checkConn(int x, int y, SoundFile clear) { //check connection of block i,j
    boolean check = false;   //no need to recheck
    int[][] statusA = new int[7][9];   //indicate the status of visited, connected
    int[] colA = new int[7];
    
    for (int i = 0; i < statusA.length; i++) {
      for (int j = 0; j < statusA[i].length; j++)
        statusA[i][j] = 0;
    } //reset
    
    for (int i = 0; i < colA.length; i++)
      colA[i] = 0; //reset for the columns to be updated
    int count = 0;       //reset for the number of connected blocks
    count = recursiveUpdate(x, y, count, statusA, colA);  //check Up, Down, Right, Left
    
    // update statusA to indicate visited or connected
    if (count >= 4) {  //there are more than 4 blocks connected
      check = eraseBlock(colA, statusA, clear);
    }
    return check;//erase blocks and move blocks down
  }

  boolean eraseBlock(int[] colA, int[][] statusA, SoundFile clear) {
    boolean check = false;
    for (int k = 0; k < 7; k++) { //check all columns
      if (colA[k] == 1) { //this column needs to be updated
        check = true;
        color[] temp = new color[9];
        
        for (int i = 0; i < temp.length; i++)
          temp[i] = 0;
        
        int i = 8;
        for (int index = 8; index >= 0; index--) {
          if (statusA[k][index] != 1) {  //skipping those blocks to be erased
            temp[i] = blockGrid[k][index].c;
            i--;
          }
        }
        for (int index = 0; index < 9; index++) {
          blockGrid[k][index].c = temp[index];  //move temp to the column k
        }
      }
    }
    clear.play();
    clears++;
    return check;
  }
  
  int recursiveUpdate(int i, int j, int count, int[][] statusA, int[] colA) {  //find blocks which are connected with block[i][j] to be indicated in statusA
    //statusA[i][j]=0 means not yet visited;  =-1 means visited and not connected
    //   =1 means visited and connected
    statusA[i][j] = 1;   //the block[i][j] is marked as visited
    colA[i] = 1;       // column i may be checked for erase and move-down
    count++;
    
    if (j > 0) { //there is a block above  (j-1)>=0
      if (statusA[i][j - 1] == 0) {  // check only those not yet visited
        if ((blockGrid[i][j].c == blockGrid[i][j - 1].c) && (blockGrid[i][j].c != 0)) { //the next is connected 
          count = recursiveUpdate(i, j - 1, count, statusA, colA);  //check the next
        }
        else   //mark as visited and not connected
        {
          statusA[i][j - 1] = -1;  //block[i][j-1] is not connected
        }
      }
    }
    if (j < blockGrid[i].length - 1) { //there is a block blow  (j+1)<= blockGrid[i].length 
      if (statusA[i][j + 1] == 0) {  // check only those not yet visited 
        if ((blockGrid[i][j].c == blockGrid[i][j + 1].c)  && (blockGrid[i][j].c != 0)) {
          count = recursiveUpdate(i, j + 1, count, statusA, colA);
        }
        else
        {
          statusA[i][j + 1] = -1;  //block[i][j+1] is not connected
        }
      }
    }
    if (i > 0) { //there is a block on the left  (i-1)>=0
      if (statusA[i-1][j] == 0) { // check only those not yet visited 
        if ((blockGrid[i][j].c == blockGrid[i-1][j].c)  && (blockGrid[i][j].c != 0)) {
          count = recursiveUpdate(i - 1, j, count, statusA, colA);
        }
        else {
          statusA[i - 1][j] = -1;  //block[i-1][j] is not connected
        }
      }
    }
    if (i < blockGrid.length - 1) { //there is a block on the right  (i+1)>= blockGrid.length 
      if (statusA[i + 1][j] == 0) {  // check only those not yet visited 
        if ((blockGrid[i][j].c == blockGrid[i + 1][j].c) && (blockGrid[i][j].c != 0)) {
          count = recursiveUpdate(i + 1, j, count, statusA, colA);
        }
        else {
          statusA[i + 1][j]=-1;  //block[i+1][j] is not connected
        }
      }
    }
    return count;
  }

  /*void updateErase() { //function called to update whether erase is needed
    //change to true once the repCol or repRow is called
    do {
      recheck = false;
      for (int i = 0; i < blockGrid.length; i++) {    //check each column
        updateCol(i, recheck);   //check column i 
      }
      for (int j=0; j< blockGrid[0].length; j++)  // check each row
        updateRow(j, recheck);  //check row j
      } while (recheck);
  }
  
  void updateCol(int x, boolean recheck) {
    int count = 0;
    color current;
    if (blockGrid[x][8].c == 0) //there is no block on this column so no check is needed
      return;
    else {
      current = blockGrid[x][8].c; //check from the bottom up
      count = 1;
    }
    
    for (int j = blockGrid[x].length - 2; j >= 0; j--) {
      if (current == blockGrid[x][j].c  && current != 0)
        count++;    // find one more in a row, go to the next
      else {
        if (current != blockGrid[x][j].c) {
          if (count >= 3) {  //find more than 3 in a row to be erased
            repCol(x, j, count);   //erase the consecutive row
            j = j + count;        // continue to check in the column
            recheck = true;      //recheck all rows and columns
          }
          if (blockGrid[x][j].c == 0)    //reaching the top of the column
            return;
          current = blockGrid[x][j].c;    //a different color
          count = 1;                 //reset count
        }
      }
    }
  }
  
  void repCol(int x, int j, int count) { //fix the column x, move block j down
    int k = j;
    for (int i = 1; i <= count; i++)
      blockGrid[x][j + i].c = 0;   // set the color of the block to be erased to black
    
    while (blockGrid[x][k].c != 0 && (k >= 0)) { //the blocks above the erased blocks
      blockGrid[x][k + count].c = blockGrid[x][k].c;  //move block down count steps
      blockGrid[x][k].c = 0;
      if (k > 0)
        k--;
      else
        return;
    }
  }
  
  void updateRow(int y, boolean recheck) {
    color current = 0;
    int count = 0;
    for (int i = 0; i < blockGrid.length; i++) {
      if (current == blockGrid[i][y].c  && current != 0)
        count ++;
      else {
        if (current != blockGrid[i][y].c) {
          if (count >= 3) {
            for (int k = 1; k <= count; k++) //update those columns of erased blocks
              repCol(i - k, y - 1, 1);
              
            recheck = true;  // recheck all rows and columns
            i = i - count;   //continue on checking the column
          }
          current = blockGrid[i][y].c;   //a different color
          count = 1;   //reset count
        }
      }
      if ((count >= 3) && (i == blockGrid.length - 1) ){
            for (int k = 0; k < count; k++) //update those columns of erased blocks
              repCol(i - k, y - 1, 1);
              
            recheck = true;  // recheck all rows and columns
            i = i - count+1 ;   //continue on checking the column
            current = blockGrid[i][y].c;   
            count = 1;  //reset count
          }
      if (current == 0)
        count = 0;  //no need to count black
    }
  }*/
  
  boolean checkIfLost() { // Check if blocks have stacked to the top row
    int count = 0;
    for (int i = 0; i < blockGrid.length; i++) {
      for (int j = 0; j < blockGrid[i].length; j++) {
        if (blockGrid[i][j].c == 0) {
          count = 0;
          break;
        }
        else
          count++;
      }
      if (count == 9)
        return true;
      else
        count = 0;
    }
    return false;
  }
  
  void reset() { // Reset board
    for (int i = 0; i < blockGrid.length; i++) {
      for (int j = 0; j < blockGrid[i].length; j++) {
        blockGrid[i][j].c = 0;
      }
    }
  }
}
