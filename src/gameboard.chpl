/*
Creates a lattice graph where neighbors are NEWS
Notice that this creates a node for each square on the board, or
row x column entries.  Then it creates 2 * {r*c(-1) + (r-1)*c} edges.
 */

use graph;

class GameBoard : Graph {
  var width: int,
      height: int,
      actions: BiMap = new BiMap();


  proc init(w: int) {
    this.init(w=w, h=w);
    //this.complete();
    /*
    var n: [1..0] string;
    for a in gridNames(w,w) do n.push_back(a);
    var X = buildGameGrid(w,w);
    super.init(X=X, name="Game Board", directed=false, vnames=n);
    actions.add("N", -this.ncols());
    actions.add("E", 1);
    actions.add("W", -1);
    actions.add("S", this.ncols());
    */
  }

  proc init(w: int, h: int) {
    var n: [1..0] string;
    for a in gridNames(i=h,j=w) do n.push_back(a);
    var X = buildGameGrid(c=w,r=h);
    super.init(X=X, name="Game Board", directed=false, vnames=n);
    this.complete();
    this.width=w;
    this.height=h;
    actions.add("N", -this.width);
    actions.add("E", 1);
    actions.add("W", -1);
    actions.add("S", this.width);
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

proc GameBoard.canMove(fromId: int, dir: string) {
  if dir == "N" {
    return this.hasEdge(fromId=fromId, toId=fromId-this.width);
  } else if dir == "E" {
    return this.hasEdge(fromId=fromId, toId=fromId+1);
  } else if dir == "W" {
    return this.hasEdge(fromId=fromId, toId=fromId-1);
  } else if dir == "S" {
    return this.hasEdge(fromId=fromId, toId=fromId+this.width);
  } else if dir == "NE" {
    return this.hasEdge(fromId=fromId, toId=fromId-this.width+1);
  } else if dir == "NW" {
    return this.hasEdge(fromId=fromId, toId=fromId-this.width-1);
  } else if dir == "SE" {
    return this.hasEdge(fromId=fromId, toId=fromId+this.width+1);
  } else if dir == "SW" {
    return this.hasEdge(fromId=fromId, toId=fromId+this.width-1);
  } else {
    return false;
  }
}
proc GameBoard.canMove(from: string, dir: string) {
  return this.canMove(fromId=this.verts.get(from), dir=dir);
}

  /*
   Intends to print an ascii representation of the world.  Don't use it on large boards
   */
  proc GameBoard.writeThis(f) {
    f <~> " |";
    for i in 1..this.height * this.width {
      f <~> " . ";
      if !this.SD.member((i, i+1)) {
        f <~> " | ";
      } else {
        f <~> "   ";
      }
      // Now write the row separators
      if i % this.height == 0 {
        f <~> "\n |";
        for j in 0..this.width-2 {
          if !this.SD.member((i + j - this.width +1 , i + j + 1)) {
            f <~> "---";
          } else {
            f <~> "   ";
          }
          f <~> "   ";
        }
        if !this.SD.member((i, i+this.width)) {
          f <~> "---";
        } else {
          f <~> "   ";
        }
        if  i < this.height * this.width {
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
      var r: string;
      if this.SD.member(state, n) {
        var d = state - n;
        if d == this.width then r = "N";
        if d == -1 then r = "E";
        if d == 1 then r = "W";
        if d == -this.width then r = "S";
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
 Creates a sparse matrix with entries at the edges with defined number of nrows/ncols
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
