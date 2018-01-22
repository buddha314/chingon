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
      LinearAlgebra;

  /*
    A Graph object is a (sparse) matrix with some meta-data attached to it.  The underlying
    matrix
   */
  class Graph {
    var vdom: domain(2),
        SD: sparse subdomain(vdom) dmapped  CS(compressRows=true),
        W: [SD] real,
        //SD = CSRDomain(1..0),
        //A = CSRMatrix(SD),
        name: string,
        vnames: domain(string),
        vids: [vnames] int,
        nameIndex: [1..0] string,
        directed: bool = false;



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
     proc init(W: []) {
       this.vdom = {W.domain.dim(1), W.domain.dim(2)};
       super.init();
       this.loadW(W);
     }

     /*
     Constructor using just vertex names.  Good for things like `DAGS <https://en.wikipedia.org/wiki/Directed_acyclic_graph>`_

:arg vnames string []: Array of string names
      */
     proc init(vnames: [] string) {
       this.vdom = {1..vnames.size, 1..vnames.size};
       super.init();
       for j in 1..vnames.size {
         this.vnames.add(vnames[j]);
         this.vids[vnames[j]] = j;
         this.nameIndex.push_back(vnames[j]);
       }
     }

     /*
     :arg W real []: Array or Matrix representing edges in the graph
     :rtype: Graph
      */
     proc init(W:[], name: string) {
       this.vdom = {W.domain.dim(1), W.domain.dim(2)};
       this.name = name;
       super.init();
       this.loadW(W);
     }

     /*
     In an undirected graph, the lower tri is populated from the upper tri, so given
     values on the lower tri are ignored
      */
     proc init(W:[], directed: bool) {
       this.vdom = {W.domain.dim(1), W.domain.dim(2)};
       this.directed = directed;
       super.init();
       this.loadW(W);
     }

    /*
     */
    proc init(W:[], directed=bool, name: string, vnames: [] string) {
      this.vdom = {W.domain.dim(1), W.domain.dim(2)};
      this.name = name;
      this.directed=directed;
      super.init();
      for j in 1..vnames.size {
        this.vnames.add(vnames[j]);
        this.vids[vnames[j]] = j;
        this.nameIndex.push_back(vnames[j]);
      }
      if vnames.size != W.domain.dim(1).size {
        halt();
      }
      this.loadW(W);
    }
  }

  /*
  :arg W real []: Array or Matrix representing edges in the graph
   */
  proc Graph.loadW(W: []) {
    for (i,j) in W.domain {
      if !this.directed {  // Only persist the upper triangle
        if (i <= j) {
          this.SD += (i,j);
          this.W(i,j) = W(i,j);
          // Create the lower triangular
          if (i != j) {
            this.SD += (j,i);
            this.W(j,i) = W(i,j);
          }
        }
      } else {
        this.SD += (i,j);
        this.W(i,j) = W(i,j);
      }
    }
  }

  /*
   Creates an edge between vertices fromId and toId, adds both entries
   if graph is not directed

   :arg fromId int: vertex id for the tail vertex
   :arg toId int: vertex id for the head vertex
   :arg w real: Weight of the edges
   */
  proc Graph.addEdge(fromId: int, toId: int, w: real) {
    if !this.SD.member(fromId, toId) {
        this.SD += (fromId, toId);
        this.W[fromId, toId] = w;
        if !this.directed {
          this.SD += (toId, fromId);
          this.W[toId, fromId] = w;
        }
    }
  }

  /*
  Adds an edge and sets the weight to 1.0

  :arg fromId int: vertex id for the tail vertex
  :arg toId int: vertex id for the head vertex

   */
  proc Graph.addEdge(fromId: int, toId: int) {
    addEdge(fromId, toId, 1.0);
  }

  /*
  Adds w to the edge between fromId and toId, also the reverse if not directed.
  If the edge does not exist, it is added with weight w.

:arg fromId int: Head vertex id
:arg toId int: Tail vertex id
:arg w real: Weight of the edge
   */
  proc Graph.updateEdge(fromId: int, toId: int, w: real) {
    if this.SD.member(fromId, toId) {
      this.W[fromId, toId] += w;
      if !this.directed {
        this.W[toId, fromId] += w;
      }
    } else {
      this.SD += (fromId, toId);
      this.W[fromId, toId] = w;
      if !this.directed {
        this.SD += (toId, fromId);
        this.W[toId, fromId] = w;
      }
    }
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
      if !this.SD.member(fid, tid) {
        this.SD += (fid, tid);
        if !directed {
          this.SD += (tid,fid);
        }
      }
      this.W[fid,tid] = 1;
      if !directed {
        this.W[tid, fid] = 1;
      }
      fid = tid;
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
  proc Graph.addPath(pathNames: [] string, directed=true) {
    const pathIds = for n in pathNames do this.vids[n];
    this.addPath(pathIds, directed);
  }


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
    var result: [D] int;

    for col in this.SD.dimIter(2,vid) do if col != vid then result.push_back(col);
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
    var vid = this.vids[vname];
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
    for v in vs do boundary += this.neighbors(v): domain(int);
    return boundary - vs;
  }

  /*
   returns: Array of degrees for each vertex.  This the count of edges, not the sum of weights.

:rtype: int []
   */
  proc Graph.degree() {
    var ds: [SD.dim(1)] real;
    forall i in SD.dim(1) {
      ds[i] = neighbors(i).size;
    }
    return ds;
  }

  /*
  Returns the number of edges adjacent to vertex `v`

  :arg v int: Vertex ID of interest

  :rtype: int []
  */
  proc Graph.degree(v: int) {
    return neighbors(v).size;
  }

  /*
  Returns the Adjacency matrix A * 1 to give the total sum of weights, indicating the flow
  around the vertex

:rtype: real []
   */
  proc Graph.flow() {
    const vs: domain(int) = for i in 1..this.W.domain.dim(1).last do i;
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
    var o: [this.W.domain.dim(1)] this.W.eltType = 0;
    forall i in vs {
      o[i] = 1;
    }
    var r: [o.domain] this.W.eltType = this.W.dot(o);

    if interior {
      forall i in 1..o.size {
        if o[i] == 0 {
          r[i] = 0;
        } else if SD.member((i,i)) {
          r[i] -= this.W[i,i];
        }
      }
    } else {
      forall i in 1..o.size {
        if SD.member((i,i)) {
          r[i] -= this.W[i,i];
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
    const vids: domain(int) = for n in vs do this.vids(n);
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
    forall i in e.domain {
      if base[i] ==0 || ws[i] == 0 {
        e[i] = 0;
      } else {
        const x = ws[i] / base[i];
        e[i] = -(xlog2x(x) + xlog2x(1-x));
      }
    }
    return (+ reduce e);
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
  proc buildGraphFromPGTables(con:Connection
      , nameTable:string, nameField:string, idField:string
      , edgeTable:string, toField:string, fromField:string, wField:string
      , directed:bool, graphName:string, weights=true) {
    const vertexNames = vNamesFromPG(con=con, nameTable=nameTable, nameField=nameField, idField=idField);
    const W = wFromPG(con=con, edgeTable=edgeTable, fromField, toField, wField, n=vertexNames.size, weights=weights);
    var g = new Graph(W=W, directed=false, name=graphName, vnames = vertexNames);
    return g;
  }



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
      super.init();
      for f in ftrIds {
        this.ftrIds += f;
      }
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
}
