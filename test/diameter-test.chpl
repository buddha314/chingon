use LinearAlgebra,
    LinearAlgebra.Sparse,
    Chingon;

/* MERGE WITH chingon-base-test.chpl ONCE REFACTORED
   BRANCH IS MERGED WITH DEVELOP.
*/

    var nv: int = 8,
        D: domain(2) = {1..nv, 1..nv},
        SD: sparse subdomain(D),
        X: [SD] real;

    var vn: [1..0] string;
    vn.push_back("star lord");
    vn.push_back("gamora");
    vn.push_back("groot");
    vn.push_back("drax");
    vn.push_back("rocket");
    vn.push_back("mantis");
    vn.push_back("yondu");
    vn.push_back("nebula");

    writeln(vn);

    SD += (1,2); X[1,2] = 1;
    SD += (2,3); X[2,3] = 1;
    SD += (3,1); X[3,1] = 1;
    SD += (3,4); X[3,4] = 1;
    SD += (4,5); X[4,5] = 1;
    SD += (3,6); X[3,6] = 1;
    SD += (6,8); X[6,8] = 1;
//    SD += (1,4); X[1,4] = 1;
//    SD += (1,5); X[1,5] = 1;
//    SD += (2,6); X[2,6] = 1;
//    SD += (2,7); X[2,7] = 1;

    var nm = new NamedMatrix(X=X, names = vn);
    writeln("NamedMatrix");
    writeln(nm.X);
    writeln("NamedMatrix Powers");
    var nmp = nm;
    for i in 2..nv+1 {
      nmp = nmp.ndot(nm);
      writeln("%n th power is".format(i));
      writeln(nmp.X);
    }

  //  var g = new Graph(X = X, vnames = vn);
//    var g = new Graph(X = X, directed = false, name = "test graph", vnames = vn);
    var g = new Graph(N = nm);
    writeln("Graph from NamedMatrix");
    writeln(g.name);
    writeln(g.verts.keys);
    writeln(g.verts.ids);
    writeln(g.X);

    var w = g;
    w.addEdge("star lord","mantis");
    w.addEdge("gamora","rocket");
    writeln("Added two edges");
    writeln(w.X);
    w.updateEdge("star lord","mantis",3.0);
    writeln("Updated an edge");
    writeln(w.X);
    w.addPath(["gamora","nebula","mantis","rocket","drax"]);
    writeln("Added a 4-path from gamora to drax");
    writeln(w.X);
    writeln("Neighbors of Nebula and Gamora");
    writeln(w.neighbors("nebula").keys);
    writeln(w.neighbors(2).keys);
    writeln("Boundary of Gamora -> Nebula");
    writeln(w.boundary({2,8}));
//    writeln(w.boundary({"gamora","nebula"}));
    writeln("Degree of Gamora");
    writeln(w.degree("gamora"));
    writeln("Degrees");
    writeln(w.degree());
    writeln("Flow");
    writeln(w.flow());  // testing breaks down here like before
