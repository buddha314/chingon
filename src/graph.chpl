use NumSuch;

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

  /*
  Build a graph from another graph
   */
  proc init(g:Graph) {
    super.init(g);
  }
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
  this.addEdge(fromId=this.verts.get(from), toId=this.verts.get(to), w=w);
}

proc Graph.hasEdge(fromId: int, toId: int) {
  return this.SD.member(fromId, toId);
}

proc Graph.hasEdge(from: string, to:string) {
  return this.hasEdge(fromId=this.verts.get(from),toId=this.verts.get(to));
}

/*
Removes the edge between vertices `fromId` and `toId`.  If `directed=false` (default) it will
remove both the incoming and outgoing edges.
 */
proc Graph.removeEdge(fromId: int, toId: int, directed=false) {
  this.remove(i=fromId, j=toId);
  if !this.directed {
    this.remove(i=toId, j=fromId);
  }
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
  this.isolate(this.verts.get(from));
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
  return neighbors(this.verts.get(vname));
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

/*
 Returns the degree by vertex name
 */
proc Graph.degree(vname: string) {
  return neighbors(vname).size();
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

proc distMatrix(g:Graph) {
  return tropicLimit(g.X,g.X);
}


proc Graph.connected() {
  var dom = this.D;
  var sps = this.SD;
  var s = true;
  for (i,j) in dom {
    s &&= sps.member((i,j));
    if s == false then break;
  }
  return s;
}


proc diameter(g:Graph) {
  return aMax(tropicLimit(g.X,g.X), axis = 0);
}


proc components(g:Graph) {
  var dist = distMatrix(g);
  var dom: domain(1) = dist.domain.dim(1);
  var comps: [dom] int;
  var ignore: sparse subdomain(dom);
  var count = 1;
  for i in dom {
    if ! ignore.member(i) {
      comps[i] = count;
      for j in dist.domain.dimIter(2,i) {
        ignore += j;
        comps[j] = count;
      }
      count += 1;
    }
  }
  return comps;
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

record NodeDTO{
  var id: int,
      name: string,
      community: int;
}

record LinkDTO {
  var source: int,
      target: int,
      strength: real;
}

record GraphDTO {
  var nodes:[1..0] NodeDTO,
      links:[1..0] LinkDTO;
  proc init() {}
}

proc Graph.DTO() {
  var dto = new GraphDTO();
  for key in this.verts.keys {
    dto.nodes.push_back(new NodeDTO(id=this.verts.get(key), name=key, community=1));
    for nbs in this.neighbors(key).keys {
      dto.links.push_back(new LinkDTO(source=this.verts.get(key), target=this.verts.get(nbs), strength=1.0));
    }
  }
  return dto;
}
