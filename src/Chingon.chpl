/*
Documentation for Chingon v 0.1.1
=================================

Much of this library is motivated by the book `Graph Algorithms in the Language of Linear Algebra by Kepner and Gilbert <http://bookstore.siam.org/se22/>`_

*/
module Chingon {
  use Sort,
      LayoutCS;

  /*
    A Graph object is a (sparse) matrix with some meta-data attached to it.  The underlying
    matrix
   */
  class Graph {
    var vdom: domain(2),
        SD: sparse subdomain(vdom) dmapped CS(),
        A: [SD] real,
        name: string,
        vnames: domain(string),
        vids: [vnames] int,
        nameIndex: [1..0] string;

    proc init(A: []) {
      this.vdom = {A.domain.dim(1), A.domain.dim(2)};
      super.init();
      for ij in A.domain {
        this.SD += ij;
        this.A(ij) = A(ij);
      }
    }

    proc init(A:[], name: string) {
      this.vdom = {A.domain.dim(1), A.domain.dim(2)};
      this.name = name;
      super.init();
      for ij in A.domain {
        this.SD += ij;
        this.A(ij) = A(ij);
      }
    }

    /*
Example object initialization::

  var nv: int = 8,
      D: domain(2) = {1..nv, 1..nv},
      SD: sparse subdomain(D),
      A: [SD] real;

  SD += (1,2); A[1,2] = 1;
  SD += (1,3); A[1,3] = 1;
  SD += (1,4); A[1,4] = 1;
  SD += (2,4); A[2,4] = 1;
  SD += (3,4); A[3,4] = 1;
  SD += (4,5); A[4,5] = 1;
  SD += (5,6); A[5,6] = 1;
  SD += (6,7); A[6,7] = 1;
  SD += (6,8); A[6,8] = 1;
  SD += (7,8); A[7,8] = 1;
  var g3 = new Graph(A=A, name="Vato", vnames = vn);

     */
    proc init(A:[], name: string, vnames: []) {
      this.vdom = {A.domain.dim(1), A.domain.dim(2)};
      this.name = name;
      super.init();
      for j in 1..vnames.size {
        this.vnames.add(vnames[j]);
        this.vids[vnames[j]] = j;
        this.nameIndex.push_back(vnames[j]);
      }
      if vnames.size != A.domain.dim(1).size {
        halt();
      }
      for ij in A.domain {
        this.SD += ij;
        this.A(ij) = A(ij);
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
    for col in this.SD.dimIter(2,vid) do yield col;
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
    const B = this.A;
    // Make sure we are not using the weighted graph
    B[this.SD] = 1;
  }
}
