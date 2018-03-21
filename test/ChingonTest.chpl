use Chingon,
    Charcoal;

class ChingonTest : UnitTest {
  proc init(verbose=false) {
    super.init(verbose=verbose);
    this.complete();
  }

  proc setUp(){
    writeln("setUp");
  }
  proc tearDown() {
    writeln("tearDown");
  }

  proc testConstructors() {
    writeln("testConstructors");
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
    SD += (4,5); X[4,5] = 1;
    SD += (5,6); X[5,6] = 1;
    SD += (6,7); X[6,7] = 1;
    SD += (6,8); X[6,8] = 1;
    SD += (7,8); X[7,8] = 1;

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
  }

  proc testOperators() {
    write("testOperators...");
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

    SD += (1,2); X[1,2] = 5;
    SD += (1,3); X[1,3] = 23.0;
    SD += (1,4); X[1,4] = 17;
    SD += (2,2); X[2,2] = 1;
    SD += (2,4); X[2,4] = 71;
    SD += (3,4); X[3,4] = 15.0;
    SD += (4,5); X[4,5] = 1;
    SD += (5,6); X[5,6] = 66.6;
    SD += (6,7); X[6,7] = 1;
    SD += (6,8); X[6,8] = 1;
    SD += (7,8); X[7,8] = 1;

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

    writeln("...done");
  }

  proc testEntropyMethods() {
    write("testEntropyMethods...");
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
    SD += (4,5); X[4,5] = 1;
    SD += (5,6); X[5,6] = 1;
    SD += (6,7); X[6,7] = 1;
    SD += (6,8); X[6,8] = 1;
    SD += (7,8); X[7,8] = 1;
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
    writeln("...done");
  }

  proc testGameBoard() {
    write("testing game board...");
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
    var B = new GameBoard(7);
    assertStringEquals("Game board has a name", expected="Game Board", actual=B.name);
    assertIntEquals("Game board has 49 entries", expected=168, actual=B.nnz());
    assertIntEquals("Game board has 7 rows", expected=7, actual=B.rows);
    assertIntEquals("Game board has 7 cols", expected=7, actual=B.cols);
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

    assertStringArrayEquals("Can only go S E N from B2", expected=["S","E","N"], actual=B.availableActions("B2"));
    writeln(B);
    writeln("...done");
  }

  proc run() {
    testConstructors();
    testOperators();
    testEntropyMethods();
    testGameBoard();
    return 0;
  }
}

proc main(args: [] string) : int {
  var t = new ChingonTest(verbose=false);
  var ret = t.run();
  t.report();
  return ret;
}
