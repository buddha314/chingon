use Chingon,
    gameboard,
    Charcoal;

class ChingonTest : UnitTest {
  // Globals we use every time
  var nv: int = 8,
      D: domain(2) = {1..nv, 1..nv},
      SD: sparse subdomain(D),
      X: [SD] real,
      graphName:string ="vato",
      vnDom = {1..0},
      vn:[vnDom] string,
      g: Graph;


  proc init(verbose=false) {
    super.init(verbose=verbose);
    this.complete();
  }


  proc setUp(name: string = "name") {
    nv = 8;
    D.clear();
    SD.clear();
    D = {1..nv, 1..nv};
    vnDom = {1..0};
    vn.push_back("star lord");
    vn.push_back("gamora");
    vn.push_back("groot");
    vn.push_back("drax");
    vn.push_back("rocket");
    vn.push_back("mantis");
    vn.push_back("yondu");
    vn.push_back("nebula");

    SD += (1,2); X[1,2] = 1;
    SD += (1,3); X[1,3] = 1;
    SD += (1,4); X[1,4] = 1;
    SD += (2,2); X[2,2] = 1;
    SD += (2,4); X[2,4] = 1;
    SD += (3,4); X[3,4] = 1;
    SD += (4,5); X[4,5] = 1;
    SD += (5,6); X[5,6] = 1;
    SD += (6,7); X[6,7] = 1;
    SD += (6,8); X[6,8] = 1;
    SD += (7,8); X[7,8] = 1;
    g = new Graph(X=X, name=graphName, directed = false, vnames=vn);

    return super.setUp(name);
  }
  proc tearDown(ref t: Timer) {
    return super.tearDown(t);
  }

  proc testConstructors() {
    var t = this.setUp("Constructors");

    var g = new Graph(X=X, name=graphName, directed = false, vnames=vn);
    assertStringEquals("Graph gets a name", expected=graphName, actual=g.name);
    assertBoolEquals("Graph gets directed", expected=false, actual=g.directed);
    assertIntEquals("Graph has 8 vertices", expected=8, actual=g.vcount());

    const vns = g.verts.keys.sorted();
    assertStringEquals("First entry is 'drax'", expected="drax", actual=vns[1]);
    assertStringEquals("Fourth entry is 'mantis'", expected="mantis", actual=vns[4]);

    const nbs = g.neighbors("star lord");
    assertBoolEquals("'Star Lord' neighbors 'groot'", expected=true
      , actual=nbs.keys.member("groot"));
    assertBoolEquals("'Star Lord' does not neighbor 'rocket'", expected=false
      , actual=nbs.keys.member("rocket"));

    const dgs: [1..nv] real = [3.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 0.0];
    assertArrayEquals("Graph has correct degrees", expected=dgs, actual=g.degree());
    assertIntEquals("'Star Lord' has correct degree", expected=3, actual=g.degree('star lord'));

    assertBoolEquals(msg="Edge exists from Star Lord to Gamora by ID", expected=true
      ,actual=g.hasEdge(fromId=1, toId=2));
    assertBoolEquals(msg="Edge exists from Star Lord to Gamora by name", expected=true
      ,actual=g.hasEdge(from="star lord", to="gamora"));
    assertBoolEquals(msg="Edge does not exist between Gamora and Nebula by name", expected=false
      ,actual=g.hasEdge(from="gamora", to="nebula"));

    this.tearDown(t);
  }

  proc testConnectedness() {
    var t = this.setUp("Connectedness");
    var nv: int = 8,
        D: domain(2) = {1..nv, 1..nv},
        SD: sparse subdomain(D),
        X: [SD] real;

    var graphName = "Vato";
    var vn: [1..0] string;
    vn.push_back("star lord");
    vn.push_back("gamora");
    vn.push_back("groot");
    vn.push_back("drax");
    vn.push_back("rocket");
    vn.push_back("mantis");
    vn.push_back("yondu");
    vn.push_back("nebula");

    SD += (1,2); X[1,2] = 1;
    SD += (1,3); X[1,3] = 1;
    SD += (1,4); X[1,4] = 1;
    SD += (2,2); X[2,2] = 1;
    SD += (2,4); X[2,4] = 1;
    SD += (3,4); X[3,4] = 1;
//    SD += (4,5); X[4,5] = 1;
//    SD += (5,6); X[5,6] = 1;
    SD += (6,7); X[6,7] = 1;
    SD += (6,8); X[6,8] = 1;
    SD += (7,8); X[7,8] = 1;

    var g = new Graph(X=X, name=graphName, directed = false, vnames = vn);
//    var limit = tropicLimit(g.X,g.X);
//    writeln(limit);
//    writeln(aMax(limit, axis = 0));
    writeln(distMatrix(g));
    writeln(diameter(g));
    writeln(g.D);
    writeln(g.SD);
    var dist = distMatrix(g);
    var conMat = elemMult(dist,transpose(dist));
    writeln(conMat);
    writeln(conMat.domain);
    g.intoxicate();
    var distance = distMatrix(g);
    writeln(distance);
    writeln(distance.domain);
    var diam = diameter(g);
    writeln(diam);
    writeln(distance.domain.dim(1).last);
    writeln(components(g));

    this.tearDown(t);
  }

  proc testOperators() {
    var t = this.setUp("Operators");

    // Update the edge weights
    X[1,2] = 5;
    X[1,3] = 23.0;
    X[1,4] = 17;
    X[2,2] = 1;
    X[2,4] = 71;
    X[3,4] = 15.0;
    X[4,5] = 1;
    X[5,6] = 66.6;
    X[6,7] = 1;
    X[6,8] = 1;
    X[7,8] = 1;

    var g = new Graph(X=X, name=graphName, directed = false, vnames=vn);
    assertRealEquals("Graph rowMax(1)", expected=23.0, actual=g.rowMax(1));
    assertIntEquals("Graph rowArgMax(1)", expected=3, actual=g.rowArgMax(1)(2));

    g.addEdge(3,5, 2.71);
    assertRealEquals("Graph can add edge", expected=2.71, actual=g.get(3,5));
    g.updateEdge(3,6, -4.24);
    assertRealEquals("Graph can update edge on null", expected=-4.24, actual=g.get(3,6));
    g.updateEdge(3,6, 1.10);
    assertRealEquals("Graph can update edge on value", expected=-3.14, actual=g.get(3,6));
    g.removeEdge(3,5);

    assertIntEquals("Vertex 3 has two neighbors", expected=2, actual=g.neighbors(3).size());
    g.isolate(3);
    assertIntEquals("Vertex 3 can be isolated", expected=0, actual=g.neighbors(3).size());

    this.tearDown(t);
  }

  proc testEntropyMethods() {
    var t = this.setUp("Entropy Methods");

    var g = new Graph(X=X, name=graphName, directed = true, vnames=vn);
    //g.intoxicate();  // g needs to be undirected


    const ef: [1..nv] real = [3.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 0.0];
    assertArrayEquals("Graph has correct flow", expected=ef, actual=g.flow());

    const sef: [1..nv] real = [2.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    const seft: [1..nv] real = [2.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    assertArrayEquals("Subgraph {'star lord', 'gamora', 'drax'}' has correct flow (interior false)"
      , expected=sef, actual=g.flow(vs={"star lord", "gamora", "drax"}, interior=false));

    assertArrayEquals("Subgraph {'star lord', 'gamora', 'drax'}' has correct flow (interior true)"
      , expected=seft, actual=g.flow(vs={"star lord", "gamora", "drax"}, interior=true));

    g.intoxicate();

    assertRealApproximates("Subgraph entropy is correct {1,2,3,4}", expected=1.81128
      , actual=g.subgraphEntropy(subgraph={1,2,3,4}, base=g.flow()));

    assertRealApproximates("Subgraph entropy is correct {1,2,3,4,5}", expected=1.9183
      , actual=g.subgraphEntropy(subgraph={1,2,3,4,5}, base=g.flow()));

    this.tearDown(t);
  }

  proc testGameBoard() {
    var t = this.setUp("Game Board");
    //var b = new GameBoard(7);
    /*
      1  2  3  4  5
      6  7  8  9 10
     11 12 13 14 15
     16 17 18 19 20
     */
    var gg = buildGameGrid(r=4,c=5);
    var n:int = 0;
    for i in gg do n+=1;
    assertIntEquals("Game Grid has 62 entries", expected=62, actual=n);

    // Now try the game board
    var B = new GameBoard(w=7);
    assertStringEquals("Game board has a name", expected="Game Board", actual=B.name);
    assertIntEquals("Game board has 49 entries", expected=168, actual=B.nnz());
    assertIntEquals("Game board has width 7 ", expected=7, actual=B.width);
    assertIntEquals("Game board has heigh 7 ", expected=7, actual=B.height);
    assertIntEquals("Only 2 neighbors of A1", expected=2, actual=B.neighbors("A1").size());
    assertIntEquals("Neighbors of A1 include A2", expected=2, actual=B.neighbors("A1").get("A2"));
    assertIntEquals("Neighbors of A1 include B1", expected=8, actual=B.neighbors("A1").get("B1"));
    assertIntEquals("There are 4 neighbors of C3", expected=4, actual=B.neighbors("C3").size());
    assertBoolEquals("No wall between A1 and A2", expected=true, actual=B.SD.member((1,2)));
    B.addWall("A1", "A2");
    B.addWall("A1", "B1");
    B.addWall("B1", "B2");
    B.addWall("D3", "E3");
    B.addWall("F7", "G7");
    assertBoolEquals("Wall between A1 and A2", expected=false, actual=B.SD.member((1,2)));
    assertIntEquals("C6 has 4 neighbors", expected=4, actual=B.neighbors("C6").size());
    B.isolate("C6");
    assertIntEquals("C6 now has no neighbors", expected=0, actual=B.neighbors("C6").size());

    assertBoolEquals(msg="A2 is not a neighbor of A1", expected=false
      ,actual=B.hasEdge(from="A1", to="A2"));
    assertBoolEquals(msg="B2 is  a neighbor of B3", expected=true
      ,actual=B.hasEdge(from="B2", to="B3"));

    assertBoolEquals(msg="You can move North from B1", expected=true
      ,actual=B.canMove(fromId=9, dir="N"));

    assertBoolEquals(msg="You can move North from B1", expected=true
      ,actual=B.canMove(from="B2", dir="N"));
    assertBoolEquals(msg="You can move South from B1", expected=true
      ,actual=B.canMove(from="B2", dir="S"));
    assertBoolEquals(msg="You can move East from B1", expected=true
      ,actual=B.canMove(from="B2", dir="E"));
    assertBoolEquals(msg="You can't move West from B1", expected=false
      ,actual=B.canMove(from="B2", dir="W"));

    assertBoolEquals(msg="You can't move NE from B1", expected=false
      ,actual=B.canMove(from="B2", dir="NE"));

    // Add an edge for NE travel
    B.addEdge(from="B2", to="A3");
    assertBoolEquals(msg="You can now move NE from B1", expected=true
      ,actual=B.canMove(from="B2", dir="NE"));

    writeln("\n",B);
    this.tearDown(t);
  }

  proc testDTO() {
    var t = this.setUp("DTO ");
    var dto = g.DTO();
    assertIntEquals(msg="DTO has correct number of nodes", expected=8, actual=dto.nodes.size);
    assertIntEquals(msg="DTO has correct number of links", expected=10, actual=dto.links.size);

    this.tearDown(t);
  }

  proc run() {
    testConstructors();
    //testConnectedness();
    testOperators();
    testEntropyMethods();
    testGameBoard();
    testDTO();
    return 0;
  }
}

proc main(args: [] string) : int {
  var t = new ChingonTest(verbose=false);
  var ret = t.run();
  t.report();
  return ret;
}
