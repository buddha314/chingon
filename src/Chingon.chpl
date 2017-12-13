/* Documentation for Chingon */
module Chingon {
  use Sort;

  /*
   Much of this library is motivated by the book `Graph Algorithms in the Language of Linear Algebra by Kepner and Gilbert <http://bookstore.siam.org/se22/>`_
   */
  class Graph {
    var vdom: domain(2),
        SD: sparse subdomain(vdom),
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
  returns an array of vertex ids (row/col numbers) for a given vertex id
   */
  proc Graph.neighbors(vid: int) {
    var result: [1..0] int;
    for (i,j) in this.A.domain {
      if i == vid {
        result.push_back(j);
      }
    }
    return result;
  }

  /*
  Returns an array of vertex ids (row/col numbers) for a given vertex name
   */
  proc Graph.neighbors(vname: string) {
    var vid = this.vids[vname];
    return neighbors(vid);
  }
}
