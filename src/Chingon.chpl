/*
Documentation for Chingon v 0.1.5
=================================

View [Chingon on Github](https://github.com/buddha314/chingon)

Much of this library is motivated by the book `Graph Algorithms in the Language of Linear Algebra by Kepner and Gilbert <http://bookstore.siam.org/se22/>`_

Some basic definitions.  We are attempting to operate according to general standards.  Since some of
the literature is inconsistent, we define some important concepts here.

*  A: The Adjacency matrix, A(i,j) is the weight between vertices i and j.  A(i,i) = 0.
   In the case of directed matrices, the edge represents the weight or indicator of i to j.
*  W: The weight matrix, W(i,j) is the weight between vertices i and j and may have non-zero diagonal
*  Laplacian Matrix L = D - A for simple graphs: https://en.wikipedia.org/wiki/Laplacian_matrix#Laplacian_matrix_for_simple_graphs

An "edge" exists between two vertices, the terminology being "from the tail to the head".

*/
module Chingon {
  use Sort,
      NumSuch,
      LinearAlgebra.Sparse,
      LinearAlgebra,
      CdoExtras;

  /*
    A Graph object is a (sparse) matrix with some meta-data attached to it.  The underlying
    matrix

    Notes that uVerts and vVerts are popullated in the case that we have `digraph=true`
    and represent the left (row) and right (col) vertex names
   */
  class Graph: NamedMatrix {
    var name: string,
        directed: bool = false,
        bipartite: bool = false,
        verts: BiMap = new BiMap(),
        uVerts: BiMap = new BiMap(),
        vVerts: BiMap = new BiMap();




    /*
Example object initialization::

  var nv: int = 8,
      D: domain(2) = {1..nv, 1..nv},
      SD: sparse subdomain(D),
      M: [SD] real;

    SD += (1,2); W[1,2] = 1;
    SD += (1,3); W[1,3] = 1;
    SD += (1,4); W[1,4] = 1;
    SD += (2,2); W[2,2] = 1;
    SD += (2,4); W[2,4] = 1;
    SD += (3,4); W[3,4] = 1;
    SD += (4,5); W[4,5] = 1;
    SD += (5,6); W[5,6] = 1;
    SD += (6,7); W[6,7] = 1;
    SD += (6,8); W[6,8] = 1;
    SD += (7,8); W[7,8] = 1;
  var g3 = new Graph(M=M, name="Vato", vnames = vn);

   In ascii, the graph is

::

  (3)--(1)--(2)> (a loop)
   |    |    |
   |    |    |
   ----(4)----
        |
        |--(5)--(6)--(7)--(8)  // TURN TURN KICK TURN!  Bob Fosse Lives!
                 |---------|

The Weighted Matrix (assuming undirected) is thus

::

  1) star lord: 0 1 1 1 0 0 0 0
  2)    gamora: 0 1 0 1 0 0 0 0
  3)     groot: 0 0 0 1 0 0 0 0
  4)      drax: 0 0 0 0 1 0 0 0
  5)    rocket: 0 0 0 0 0 1 0 0
  6)    mantis: 0 0 0 0 0 0 1 1
  7)     yondu: 0 0 0 0 0 0 0 1
  8)    nebula: 0 0 0 0 0 0 0 0

With symmetric version

::

  1) star lord: 0 1 1 1 0 0 0 0
  2)    gamora: 1 1 0 1 0 0 0 0
  3)     groot: 1 0 0 1 0 0 0 0
  4)      drax: 1 1 1 0 1 0 0 0
  5)    rocket: 0 0 0 1 0 1 0 0
  6)    mantis: 0 0 0 0 1 0 1 1
  7)     yondu: 0 0 0 0 0 1 0 1
  8)    nebula: 0 0 0 0 0 1 1 0

  :arg W real []: Array or Matrix representing edges in the graph
     */
     proc init(X: []) {
       super.init(X);
       this.complete();
     }


     /*
     :arg W real []: Array or Matrix representing edges in the graph
     :rtype: Graph
      */
     proc init(X:[], name: string, directed: bool = false, bipartite: bool = false) {
       super.init(X);
       this.complete();
       this.name = name;
     }

     /*
     In an undirected graph, the lower tri is populated from the upper tri, so given
     values on the lower tri are ignored
      */
     proc init(X:[], directed: bool) {
       super.init(X);
       this.complete();
       this.directed = directed;
     }

    /*
     */
    proc init(X:[], vnames) {
      super.init(X, vnames);
      this.complete();
      this.verts = this.rows.uni(this.cols);
    }

    proc init(X:[], directed=bool, name: string, vnames: [] string) {
      this.init(X, vnames);
      this.name = name;
      this.directed=directed;
    }

    proc init(N: NamedMatrix) {
      super.init(N);
      this.verts = this.rows.uni(this.cols);
      this.uVerts = this.rows;
      this.vVerts = this.cols;
    }

    proc init(g:Graph) {
      super.init(g);
    }
  }

  /*
   Factory Method.

   Bipartite Graphs are described here: https://en.wikipedia.org/wiki/Bipartite_graph

   Uses the NamedMatrix class from Chingon to build a graph.
   :arg bool bipartite: Is this a bipartite graph where there are two sets of nodes
   */
  proc Graph.fromNamedEdges(con:Connection
    , edgeTable: string, fromField: string, toField: string
    , bipartite=false) {
    const N = NamedMatrixFromPG(con, edgeTable=edgeTable
      , fromField=fromField, toField=toField, square=bipartite);
    var g = new Graph(NamedMatrix=N);
    return g;
  }

  /*
  :arg W real []: Array or Matrix representing edges in the graph
   */

  /*
  proc Graph.addEdge(fromId: int, toId: int, w: real) {
    this.set(fromId, toId, w);
  }

  proc Graph.addEdge(from: string, to: string, w: real) {
    this.set(from, to, w);
  }

  proc Graph.addEdge(from: string, to: string) {
    this.set(from, to, 1.0);
  }*/

  /*
     Creates an edge between vertices fromId and toId, adds both entries
     if graph is not directed

     :arg fromId int: vertex id for the tail vertex
     :arg toId int: vertex id for the head vertex
     :arg w real: Weight of the edges.  Default = 1.0
   */
  proc Graph.addEdge(fromId: int, toId: int, w: real = 1.0) {
    this.set(fromId, toId, w);
  }

  /*
     Creates an edge between vertices fromId and toId, adds both entries
     if graph is not directed

     :arg from string: vertex name for the tail vertex
     :arg to string: vertex name for the head vertex
     :arg w real: Weight of the edges.  Default = 1.0
   */
  proc Graph.addEdge(from: string, to: string, w: real = 1.0) {
    this.addEdge(fromId=this.vnames.get(from), toId=this.vnames.get(to), w=w);
  }



  /*
  Removes the edge between vertices `fromId` and `toId`.  If `directed=false` (default) it will
  remove both the incoming and outgoing edges.
   */
  proc Graph.removeEdge(fromId: int, toId: int, directed=false) {
    this.remove(i=fromId, j=toId);
  }

  /*
  Remove edge by vertex names
   */
  proc Graph.removeEdge(fromId: string, toId: string, directed=false) {
    this.removeEdge(this.vnames.get(fromId), this.vnames.get(toId));
  }

  /*
  Removes all edges in/out of this vertex id
   */
  proc Graph.isolate(fromId: int, directed=false) {
      for j in this.neighbors(fromId).ids {
        this.removeEdge(fromId = fromId, toId=j, directed=directed);
      }
  }

  /*
  Removes all edges in/out of this vertex by name
   */
  proc Graph.isolate(from: string, directed=false) {
    this.isolate(this.verts.get(string));
  }

  /*
  Adds w to the edge between fromId and toId, also the reverse if not directed.
  If the edge does not exist, it is added with weight w.

:arg fromId int: Head vertex id
:arg toId int: Tail vertex id
:arg w real: Weight of the edge
   */
  proc Graph.updateEdge(fromId: int, toId: int, w: real) {
    this.update(fromId, toId, w);
  }

  proc Graph.updateEdge(from: string, to: string, w:real) {
    this.update(from, to, w);
  }

  /*
Adds a path between multiple nodes with a default edge weight of 1.  Passing in
`[1, 2, 5, 9]` will create three edges between (1,2), (2,5) and (5,9). For larger trees,
it is probably more convenient to build the graph from `W` directly.

For example, to build the following tree

::

  1 - 2
      - 5
      - 6
    - 3
    - 4
      - 7
      - 8
      - 9

You could add the full paths like (1,4,8) or partial paths like (4,7) and in any order

::

  var vn: [1..0] string;
  vn.push_back("star lord");
  vn.push_back("gamora");
  vn.push_back("groot");
  vn.push_back("drax");
  vn.push_back("rocket");
  vn.push_back("mantis");
  vn.push_back("yondu");
  vn.push_back("nebula");
  vn.push_back("taserface");

  G.addPath([1,2,5]);
  G.addPath([2,6]);
  G.addPath([1,3]);
  G.addPath([1,4,8]);
  G.addPath([1,4,9]);
  G.addPath([4,7]);



:arg pathIds int []: Ordered array of vertex Ids
:arg directed bool: ``default=true`` Is the path directed?
   */
  proc Graph.addPath(pathIds: [] int, directed=true) {
    var fid = pathIds[1];
    for j in 2..pathIds.size {
      var tid = pathIds[j];
      this.set(fid, tid, 1.0);
      if !directed {
        this.set(tid, fid, 1.0);
      }
      fid = tid;
    }
  }

  proc Graph.addPath(pathNames: [] string, directed = true) {
    var fin = pathNames[1];
    for j in 2..pathNames.size {
      var tin = pathNames[j];
      this.set(fin, tin, 1.0);
      if !directed {
        this.set(tin, fin, 1.0);
      }
      fin = tin;
    }
  }

  /*
As above, but using vertex names.

::

  star lord - gamora
              - rocket
              - mantis
            - groot
            - drax
              - yondu
              - nebula
              - taserface

Allowing us to build the same graph but using

::

  G.addPath(["star lord", "gamora", "rocket"]);
  G.addPath(["gamora", "mantis"]);
  G.addPath(["star lord", "groot"]);
  G.addPath(["star lord", "drax", "yondu"]);
  G.addPath(["star lord", "drax", "nebula"]);
  G.addPath(["drax", "taserface"]);

:arg pathNames string []: Vertex names of the path
:arg directed bool: ``default=true`` Is the path directed?

   */


  /*
returns an array of vertex ids (row/col numbers) for a given vertex id

::

    for n in g3.neighbors(1).sorted() {
      writeln("neighbor of 1: ", n, ": ", g3.nameIndex[n]);
    }
    >>
    neighbor of 1: 2: gamora
    neighbor of 1: 3: groot
    neighbor of 1: 4: drax

:arg vid int: Vertex Id of interest
:rtype: int []
*/
  proc Graph.neighbors(vid: int) {
    var D = {1..0};
    var ids: [D] int;
    var result: BiMap = new BiMap;
    for col in this.SD.dimIter(2,vid) do if col != vid then ids.push_back(col);
    for id in ids {
      result.add(k = verts.idx[id], id);
    }
    return result;
  }


  /*
  Returns an array of vertex ids (row/col numbers) for a given vertex name.

example::

  for n in g3.neighbors("star lord").sorted() {
    writeln("neighbor of 1: ", n, ": ", g3.nameIndex[n]);
  }
  >>
  neighbor of 1: 2: gamora
  neighbor of 1: 3: groot
  neighbor of 1: 4: drax

:arg  vname string: Vertex name of interest
   */
  proc Graph.neighbors(vname: string) {
    var vid = this.verts.ids[vname];
    return neighbors(vid);
  }

  /*
  Looks for the boundary of a subgraph in G and returns an integer domain of vertex ids.

  :arg vs domain(int): Domain of ints forming the subgraph
  :returns: a set of vertex ids not in `vs` but having an edge to a vertex in `vs`
  :rtype: domain(int)

   */
   proc Graph.boundary(vs: domain(int)) {
     var boundary: domain(int);
     for v in vs do boundary += this.neighbors(v).idxkey: domain(int);
     return boundary - vs;
   }



  /*
   returns: Array of degrees for each vertex.  This the count of edges, not the sum of weights.

:rtype: int []
   */
  proc Graph.degree() {
    var ds: [SD.dim(1)] real;
    forall i in SD.dim(1) {
      ds[i] = neighbors(i).size();
    }
    return ds;
  }

  /*
  Returns the number of edges adjacent to vertex `v`

  :arg v int: Vertex ID of interest

  :rtype: int []
  */
  proc Graph.degree(v: int) {
    return neighbors(v).size();
  }

  proc Graph.degree(vname: string) {
    return neighbors(vname).size();
  }

  /*
  Returns the Adjacency matrix A * 1 to give the total sum of weights, indicating the flow
  around the vertex

:rtype: real []
   */
  proc Graph.flow() {
    const vs: domain(int) = for i in 1..this.X.domain.dim(1).last do i;
    return flow(vs=vs, interior=false);
  }

  /*
  Returns the sum of the incident weights on an "interior" set of vertices.  Calculation is to take
  a vector of ones[interior] and do W.dot(o)

  Calls flow(vs, interior=false)

:arg vs domain(int): Domains of ints forming the subgraph
:rtype: real []
   */
  proc Graph.flow(vs: domain(int)) {
    return flow(vs, false);
  }

  /*
By default, this calculates the sum of the weights for all vertices with edges against the vertices
in the subgraph :param:`vs`.  The return is an array with length nodes(G) with the value of the flow in
each element.  If 'interior=true' then the elements outside `vs` are zeroed out.

:arg vs domain(int): Vertex ids to calculate
:arg interior bool: Indicate if weights should be restricted to vertices in :param:`vs`

:returns: Sum of the weights adjacent to vertex set ``vs`` given subgraph ``interior``
:rtype: int []
  */
  proc Graph.flow(vs: domain(int), interior: bool) {
    var o: [this.X.domain.dim(1)] this.X.eltType = 0;
    forall i in vs {
      o[i] = 1;
    }
    var r: [o.domain] this.X.eltType = this.X.dot(o);

    if interior {
      forall i in 1..o.size {
        if o[i] == 0 {
          r[i] = 0;
        } else if SD.member((i,i)) {
          r[i] -= this.get(i,i);
        }
      }
    } else {
      forall i in 1..o.size {
        if SD.member((i,i)) {
          r[i] -= this.get(i,i);
        }
      }
    }
    return r;
  }

  /*
  By default, this calculates the sum of the weights for all vertices with edges against the vertices
  in the subgraph :param:`vs`.

:arg vs domain(string): Vertex names to calculate
:arg interior bool: Bool to indicate if weights should be restricted to vertices in :param:`vs`

:returns: Sum of the weights adjacent to vertex set ``vs`` given subgraph ``interior``
:rtype: int []

   */
  proc Graph.flow(vs: domain(string), interior: bool) {
    const vids: domain(int) = for n in vs do this.verts.ids[n];
    return this.flow(vids, interior);
  }

  /*
  The vertexEntropy calculates the ratio of edge strength to the interior and exterior of a given subgraph

  :arg subgraph domain(int): A set of vertex string names representing a sub-graph.
  :arg base real []: An array of degrees for the whole graph, should be called by :proc:`Graph.flow()` beforehand
   */
  proc Graph.subgraphEntropy(subgraph: domain(int), base: []) {
     const ws = flow(vs=subgraph, interior=false);
     var e: [base.domain] real;
     for i in e.domain {
       if base[i] ==0 || ws[i] == 0 {
         e[i] = 0;
       } else {
         const x = ws[i] / base[i];
         e[i] = -(xlog2x(x) + xlog2x(1-x));
       }
     }
     return (+ reduce e);
   }

   proc Graph.subgraphEntropy(subgraph: domain(int)) {
     const base = this.flow();
     const ws = flow(vs=subgraph, interior=false);
     var e: [base.domain] real;
     for i in e.domain {
       if base[i] ==0 || ws[i] == 0 {
         e[i] = 0;
       } else {
         const x = ws[i] / base[i];
         e[i] = -(xlog2x(x) + xlog2x(1-x));
       }
     }
     return (+ reduce e);
   }


  proc Graph.intoxicate() {
    var dom = this.X.domain;
    //forall (i,j) in dom {
    for (i,j) in dom {
      if ! this.X.domain.member((j,i)) {
        //writeln("adding edge ", j, " ", i);
        this.addEdge(j,i);
      }
    }
    return this;
  }

  proc Graph.makeForget() {
    var w = new Graph(this);
    forall (i,j) in this.X.domain {
      if ! this.X.domain.member((j,i)) {
        w.addEdge(j,i);
      }
    }
    return w;
  }

  proc Graph.gtropic(g:Graph) {
    var T = new Graph(N = this.N.ntropic(g.N));
    return T;
  }

  proc Graph.tropicLimit(g:Graph) {
    /*
    if this.X == this.gtropic(g).X {
      var R = this;
    } else {
      this.gtropic(g).tropicLimit(g);
    }
    return R;
    */
  }

  proc diameter(g:Graph) {
    var w = new Graph(g);
    //if w == tropic;
  }

  proc buildGraphFromPGTables(con:Connection
      , edgeTable:string, toField:string, fromField:string, wField:string
      , directed:bool, graphName:string) {
    const nm = NamedMatrixFromPG(con=con, edgeTable=edgeTable, fromField=fromField, toField=toField, wField=wField, square=false);
    var g = new Graph(N=nm);
    return g;
}
  /*
   Gives the topological ordering of a graph
   :returns: The array providing the topological sorting of the Graph
   :rtype: int []
   */
  proc Graph.topologicalSort() {
    if !this.directed then halt('The graph must be a Digraph');
    var A: [1..0] int;
    var visi: [D.dim(1)] bool;
    for i in this.D.dim(1).low..this.D.dim(1).high {
      if visi[i] == false then _topologicalUtil(i, visi, A);
    }
    A.reverse();
    return A;
  }

  proc Graph._topologicalUtil(x: int, ref visi: [?D1] bool, ref A: [?D2] int) {
    visi[x] = true;
    var N = neighbors(x);
    for i in N {
      if visi[i] == false then _topologicalUtil(i, visi, A);
    }
    A.push_back(x);
  }

  /*
   Returns the number of vertices in the graph.  For a bipartite graph, this is the number of
   rows + number of columns.  Otherwise, it is the number of rows = number of columns in
   the underlying matrix
   */
  proc Graph.vcount() {
    if this.bipartite {
      return this.X.shape[1] + this.X.shape[2];
    } else {
      return this.X.shape[1];
    }
  }

  /*
   Builds a Graph object using `NumSuch <https://github.com/buddha314/numsuch>`_ MatrixOps module

   :arg nameTable string: The name of the Postgres table containing the pairs
   :arg nameField string: The name of the field in the nameTable containing the names
   :arg idField string: The name of the field in the nameTable containing the feature ids
   :arg con CDO.Connection: A `CDO Connection <https://github.com/marcoscleison/cdo>`_ to Postgres
   :arg edgeTable string: The table in PG of edges
   :arg fromField string: The field of edgeTable containing the id of the head vertex
   :arg toField string: the field of edgeTable containing the id of the tail vertex
   :arg wField string: The field of edgeTable containing the weight of the edge
   :arg directed bool: Indicating whether graph is directed
   :arg graphName string: A name for the graph
   :arg weights bool: Boolean on whether to use the weights in the table or a 1 (indicator)

   */





  /*
   A class to hold sub-graphs.  The language is not standard but convenient.  A "crystal" is
   essentially a sub-graph.  During the "tempering" process, vertices will be added and removed
   until a minimum entropy is accomplished.  The initial vertex Ids are held in :const:`ftrIds`.  The
   derived minimum entropy is in :var:`minEntropy` and the final vertex ids are in
   */
  class Crystal {
    const id: string;
    var ftrIds: domain(int),
        initialEntropy: real,
        minEntropy: real,
        minFtrs: domain(int);

    /*
    Constructor

    :arg id string: Any string identifier for this crystal.
    :arg ftrIds int []: The set of vertex ids that compose the untempered crystal stored as ``domain(int)``
     */
    proc init(id: string, ftrIds: []) {
      this.id = id;
      this.initialEntropy = 0.0;
      this.minEntropy = 0.0;
      for f in ftrIds {
        this.ftrIds += f;
      }
      this.complete();
    }
  }


  /*
  Creates a set of untempered crystals from a Postgres table.
  Requires data within Postgres as in test/data/entropy_base_graph_schema.sql

  :arg constituentTable string: Postgres table with the crystal and their constituent ids
  :arg constituentIdField string: The field in the constituentTable with the constituent id
  :arg idField string: The field in the constituentTable that has the crystal id

  :returns: An array of crystals from a given Postgres table
  :rtype: :class:`Crystal`
   */
  proc buildCrystalsFromPG(
      con: Connection
      , constituentTable: string
      , idField: string
      , constituentIdField: string
    ) {
    var q = "SELECT %s AS cid, array_agg(%s) AS a FROM %s GROUP BY 1 ORDER BY 1, 2";
    var cursor = con.cursor();
    cursor.query(q, (idField, constituentIdField, constituentTable));
    var crystals: [1..0] Crystal;
    for row in cursor {
      var cids: [1..0] int;
      for b in row.getArray('a') {
        cids.push_back(b: int);
      }
      crystals.push_back(new Crystal(row['cid'], cids));
    }
    return crystals;
  }


  /*
  Creates a lattice graph where neighbors are NEWS
  Notice that this creates a node for each square on the board, or
  row x column entries.  Then it creates 2 * {r*c(-1) + (r-1)*c} edges.
   */
  class GameBoard : Graph {
    var rows: int,
        cols: int;
    proc init(r: int) {
      var n: [1..0] string;
      for a in gridNames(r,r) do n.push_back(a);
      var X = buildGameGrid(r,r);
      super.init(X=X, name="Game Board", directed=false, vnames=n);
      this.complete();
      this.rows = r;
      this.cols = r;
    }
  }

  /*
  Builds a wall between the two cells.  Essentially, this removes an entry in the
  underlying matrix.
   */
  proc GameBoard.addWall(cell1: string, cell2: string) {
    var x = this.verts.get(cell1);
    var y = this.verts.get(cell2);
    this.SD -= (x,y);
    //writeln("Removing ", x, ", ", y);
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
        }
        if  i < this.rows * this.cols {
          f <~> "|";
          f <~> "\n |";
        }
      }
    }
  }


  /*
   Creates a sparse matrix with entries at the edges.
   */
  proc buildGameGrid(r: int) {
    return buildGameGrid(r=r, c=r);
  }

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
}
