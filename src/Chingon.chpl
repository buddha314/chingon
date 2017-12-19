/*
Documentation for Chingon v 0.1.1
=================================

Much of this library is motivated by the book `Graph Algorithms in the Language of Linear Algebra by Kepner and Gilbert <http://bookstore.siam.org/se22/>`_

Some basic definitions.  We are attempting to operate according to general standards.  Since some of
the literature is inconsistent, we define some important concepts here.

*  A: The Adjacency matrix, A(i,j) is the weight between vertices i and j.  A(i,i) = 0.
   In the case of directed matrices, the edge represents the weight or indicator of i to j.
*  W: The weight matrix, W(i,j) is the weight between vertices i and j and may have non-zero diagonal
*  Laplacian Matrix L = D - A for simple graphs: https://en.wikipedia.org/wiki/Laplacian_matrix#Laplacian_matrix_for_simple_graphs

*/
module Chingon {
  use Sort,
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
        nameIndex: [1..0] string;

    proc init(W: []) {
      this.vdom = {W.domain.dim(1), W.domain.dim(2)};
      super.init();
      for ij in W.domain {
        this.SD += ij;
        this.W(ij) = W(ij);
      }
    }

    proc init(W:[], name: string) {
      this.vdom = {W.domain.dim(1), W.domain.dim(2)};
      this.name = name;
      super.init();
      for ij in W.domain {
        this.SD += ij;
        this.W(ij) = W(ij);
      }
    }

    /*
Example object initialization::

  var nv: int = 8,
      D: domain(2) = {1..nv, 1..nv},
      SD: sparse subdomain(D),
      M: [SD] real;

  SD += (1,2); M[1,2] = 1;
  SD += (1,3); M[1,3] = 1;
  SD += (1,4); M[1,4] = 1;
  SD += (2,4); M[2,4] = 1;
  SD += (3,4); M[3,4] = 1;
  SD += (4,5); M[4,5] = 1;
  SD += (5,6); M[5,6] = 1;
  SD += (6,7); M[6,7] = 1;
  SD += (6,8); M[6,8] = 1;
  SD += (7,8); M[7,8] = 1;
  var g3 = new Graph(M=M, name="Vato", vnames = vn);

     */
    proc init(W:[], name: string, vnames: []) {
      this.vdom = {W.domain.dim(1), W.domain.dim(2)};
      this.name = name;
      super.init();
      for j in 1..vnames.size {
        this.vnames.add(vnames[j]);
        this.vids[vnames[j]] = j;
        this.nameIndex.push_back(vnames[j]);
      }
      if vnames.size != W.domain.dim(1).size {
        halt();
      }
      for ij in W.domain {
        this.SD += ij;
        this.W(ij) = W(ij);
      }
    }
  }

  /*
Internal iterator to get vertex ids that are neighbors of "vid"
:arg vid: A vertex id
:type vid: int

:rtype: iterator

TODO: Make sure the diagonal is removed.
   */
  iter Graph.nbs(vid: int) {
    for col in this.SD.dimIter(2,vid) do if col != vid then yield col;
  }

  /*
returns an array of vertex ids (row/col numbers) for a given vertex id

well, I don't know about that::

    for n in g3.neighbors(1).sorted() {
      writeln("neighbor of 1: ", n, ": ", g3.nameIndex[n]);
    }
    >>
    neighbor of 1: 2: gamora
    neighbor of 1: 3: groot
    neighbor of 1: 4: drax
*/
  proc Graph.neighbors(vid: int) {
    var result: [1..0] int;
    for x in nbs(vid) do result.push_back(x);
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
   */
  proc Graph.neighbors(vname: string) {
    var vid = this.vids[vname];
    return neighbors(vid);
  }

  /*
   returns: Array of degrees for each vertex.  This the count of edges, not the sum of weights.
   rtype: int []
   */
  proc Graph.degree() {
    var ds: [SD.dim(1)] real;
    forall i in SD.dim(1) {
      ds[i] = neighbors(i).size;
      if SD.member((i,i)) {
        ds[i] -= W[i,i];
      }
    }
    return ds;
    /*
    var diagDom = CSRDomain(SD.dim(1));
    var one: [SD.dim(1)] A.eltType = 1;
    // B will be the diagonal vector
    var B: [diagDom] A.eltType;
    for i in 1..vdom.size {
      if SD.member((i,i)) {
        writeln("yep");
        diagDom += (i,i);
        //B[i,i] = A[i,i];
        B[i,i] = neighbors(i).size;
      }
    }
    //return A.dot(one);
    //return B;
    */
  }

  /*
  Returns the Adjacency matrix A * 1 to give the total sum of weights
  :rtype: real []
   */
  proc Graph.weights() {
    return 0;
  }

  /*
  The vertexEntropy calculates the ratio of edge strength to the interior and exterior of a given subgraph


  :arg interior: A set of vertex string names representing a sub-graph.
   */
  proc Graph.vertexEntropy(interior: domain, vertex: int) {
    var dims = for v in interior do vids[v];
  }
}
