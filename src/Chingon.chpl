/* Documentation for Chingon */
module Chingon {

  class Graph {
    var vdom: domain(2),
        SD: sparse subdomain(vdom),
        A: [SD] real,
        name: string,
        vnames: domain(string);

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

    proc init(A:[], name: string, vnames: domain) {
      this.vdom = {A.domain.dim(1), A.domain.dim(2)};
      this.name = name;
      this.vnames = vnames;

      super.init();
      if vnames.size != A.domain.dim(1).size {
        //writeln("FOOL!");
        halt();
      }
      for ij in A.domain {
        this.SD += ij;
        this.A(ij) = A(ij);
      }
    }

    /*
    proc init(name:string, vnames: domain) {
      this.vdom = {1..vnames.size, 1..vnames.size};
      this.name = name;
      this.vnames = vnames;
      super.init();
    } */



    /*
    proc init(A:[], vnames: domain) {
      this.vdom = {A.domain.dim(1), A.domain.dim(2)};
      this.vnames = vnames;
      if vnames.size != A.domain.dim(1).size {
        throw new Error();
      }
      super.init();
      for ij in A.domain {
        this.SD += ij;
        this.A(ij) = A(ij);
      }
    } */
  }
}
