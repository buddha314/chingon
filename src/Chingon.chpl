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
      gameboard,
      graph,
      energy,
      CdoExtras;
}
