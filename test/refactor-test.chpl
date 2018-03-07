use LinearAlgebra,
    LinearAlgebra.Sparse,
    Chingon;

/*
    class BiMap {
      var keys: domain(string),
          ids:  [keys] int,
          idxkey: domain(int),
          idx: [idxkey] string;


      Create an empty BiMap.

      proc init() {
        super.init();
      }

      proc uni(b: BiMap) {
        this.keys += b.keys;
        this.ids += b.ids;
        this.idxkey += b.idxkey;
        this.idx += b.idx;
        return this;
      }
    }

    class NamedMatrix {
      var D: domain(2),
          SD = CSRDomain(D),
          X: [SD] real,  // the actual data
          rows: BiMap = new BiMap(),
          cols: BiMap = new BiMap();

       proc init() {
         super.init();
       }

       proc init(X) {
         this.D = {X.domain.dim(1), X.domain.dim(2)};
         super.init();
         this.loadX(X);
       }
    }

    proc NamedMatrix.loadX(X:[], shape: 2*int =(-1,-1)) {
      if shape(1) > 0 && shape(2) > 0 {
        this.D = {1..shape(1), 1..shape(2)};
      }
      for (i,j) in X.domain {
        this.SD += (i,j);
        this.X(i,j) = X(i,j);
      }
    }

    class Graph: NamedMatrix {
      var name: string,
          directed: bool = false,
          bipartite: bool = false,
          verts: BiMap = new BiMap(),
          uVerts: BiMap = new BiMap(),
          vVerts: BiMap = new BiMap();


      proc init(N: NamedMatrix) {
        super.init(N.X);
        this.verts = super.rows.uni(super.cols);
        this.uVerts = super.rows;
        this.vVerts = super.cols;
  //      this.loadX(N.X);
          }
        }
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

  //  var nm = new NamedMatrix(X=X);
//    writeln(nm.X.domain);



    var g = new Graph(X = X, directed = false, name = "test graph", vnames = vn);
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
    writeln(w.neighbors("nebula"));
    writeln(w.neighbors(2));
    writeln("Boundary of Gamora -> Nebula");
    writeln(w.boundary({2,8}));
//    writeln(w.boundary({"gamora","nebula"}));
    writeln("Degree of Gamora");
    writeln(w.degree("gamora"));
    writeln("Degrees");
    writeln(w.degree());
    writeln("Flow");
//    writeln(w.flow());  // testing breaks down here like before
