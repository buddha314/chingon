use graph;

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
