/*
Creates a lattice graph where neighbors are NEWS
Notice that this creates a node for each square on the board, or
row x column entries.  Then it creates 2 * {r*c(-1) + (r-1)*c} edges.
 */

use graph;

class GameBoard : Graph {
  var rows: int,
      cols: int,
      actions: BiMap = new BiMap();


  proc init(r: int) {
    var n: [1..0] string;
    for a in gridNames(r,r) do n.push_back(a);
    var X = buildGameGrid(r,r);
    super.init(X=X, name="Game Board", directed=false, vnames=n);
    this.complete();
    this.rows = r;
    this.cols = r;
    //this.actions = new Bimap();
    actions.add("N", -this.cols);
    actions.add("E", 1);
    actions.add("W", -1);
    actions.add("S", this.cols);
    /*
    this.actions.push_back("N");
    this.actions.push_back("E");
    this.actions.push_back("W");
    this.actions.push_back("S");
    */
  }
}

/*
Builds a wall between the two cells.  Essentially, this removes an entry in the
underlying matrix.
 */
proc GameBoard.addWall(cell1: string, cell2: string) {
  var x = this.verts.get(cell1);
  var y = this.verts.get(cell2);
  this.removeEdge(x,y, directed=this.directed);
}


  /*
   Intends to print an ascii representation of the world.  Don't use it on large boards
   */
  proc GameBoard.writeThis(f) {
    f <~> " |";
    for i in 1..this.rows * this.cols {
      f <~> " . ";
      if !this.SD.member((i, i+1)) {
        f <~> " | ";
      } else {
        f <~> "   ";
      }
      // Now write the row separators
      if i % this.rows == 0 {
        f <~> "\n |";
        for j in 0..this.cols-2 {
          if !this.SD.member((i + j - this.cols +1 , i + j + 1)) {
            f <~> "---";
          } else {
            f <~> "   ";
          }
          f <~> "   ";
        }
        if !this.SD.member((i, i+this.cols)) {
          f <~> "---";
        } else {
          f <~> "   ";
        }
        if  i < this.rows * this.cols {
          f <~> " |";
          f <~> "\n |";
        }
      }
    }
  }

/*
Returns the available actions for a given state, e.g. grid location
 */
proc GameBoard.availableActions(state: int) {
  var x = this.verts.get(state);
  //var a: [1..0] string;
  var a: domain(string);
  var ns = this.neighbors(state).ids;
  for n in ns {
      //write("\n considering: ", n);
      var r: string;
      if this.SD.member(state, n) {
        var d = state - n;
        if d == this.cols then r = "N";
        if d == -1 then r = "E";
        if d == 1 then r = "W";
        if d == -this.cols then r = "S";
        //a.push_back(r);
        a += r;
      }
  }
  return a;
}

/*
 Returns the string names of the available actions
 */
proc GameBoard.availableActions(state: string) {
  return this.availableActions(this.verts.get(state));
}

/*
 Creates a sparse matrix with entries at the edges.
 */
proc buildGameGrid(r: int) {
  return buildGameGrid(r=r, c=r);
}

/*
 Creates a sparse matrix with entries at the edges with defined number of rows/cols
*/
proc buildGameGrid(r: int, c:int) {
  var D: domain(2) = {1..r*c, 1..r*c},
      SD: sparse subdomain(D),
      X: [SD] real,
      m: int = 1,
      n: int = 1;

  var k = 1;
  for 1..r*c {
    if !(k % c == 0){
      SD += (k, k+1);
      SD += (k+1, k);
    }
    if !((k+c) > r*c) {
      SD += (k, k+c);
      SD += (k+c, k);
    }
    k += 1;
  }
  for a in SD {
    X[a] = 1;
  }
  return X;
}
