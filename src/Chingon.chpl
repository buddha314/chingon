/* Documentation for Chingon */
module Chingon {

  class Graph {
    var name: string,
        vnames: domain(string),
        vdom: domain(2),
        SD: sparse subdomain(vdom),
        A: [SD] real;


    proc init(name: string) {
      this.name = name;
      super.init();
    }

    proc init(name:string, vnames: domain) {
      this.name = name;
      this.vnames = vnames;
      this.vdom = {1..vnames.size, 1..vnames.size};
      super.init();
    }


    proc init(A: []) {
      this.vdom = {A.domain.dim(1), A.domain.dim(2)};
      super.init();
      for ij in A.domain {
        this.SD += ij;
        this.A(ij) = A(ij);
      }
    }
  }
}
