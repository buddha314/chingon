.. default-domain:: chpl

.. module:: Chingon
   :synopsis: Documentation for Chingon v 0.1.1

Chingon
=======
**Usage**

.. code-block:: chapel

   use Chingon;


Documentation for Chingon v 0.1.1
=================================

Much of this library is motivated by the book `Graph Algorithms in the Language of Linear Algebra by Kepner and Gilbert <http://bookstore.siam.org/se22/>`_


.. class:: Graph

   
   A Graph object is a (sparse) matrix with some meta-data attached to it.  The underlying
   matrix
   


   .. attribute:: var vdom: domain(2)

   .. attribute:: var SD: vdom.defaultSparseDistchpl__buildSparseDomainRuntimeTypevdom

   .. attribute:: var A: [SD] real

   .. attribute:: var name: string

   .. attribute:: var vnames: domain(string)

   .. attribute:: var vids: [vnames] int

   .. attribute:: var nameIndex: [1..0] string

   .. method:: proc init(A: [])

   .. method:: proc init(A: [], name: string)

   .. method:: proc init(A: [], name: string, vnames: [])

      
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
      
           

.. method:: proc Graph.neighbors(vid: int)

   
   returns an array of vertex ids (row/col numbers) for a given vertex id
   
   well, I don't know about that::
   
       for n in g3.neighbors(1).sorted() {
         writeln("neighbor of 1: ", n, ": ", g3.nameIndex[n]);
       }
       >>
       neighbor of 1: 2: gamora
       neighbor of 1: 3: groot
       neighbor of 1: 4: drax

.. method:: proc Graph.neighbors(vname: string)

   
     Returns an array of vertex ids (row/col numbers) for a given vertex name.
   
   example::
   
     for n in g3.neighbors("star lord").sorted() {
       writeln("neighbor of 1: ", n, ": ", g3.nameIndex[n]);
     }
     >>
     neighbor of 1: 2: gamora
     neighbor of 1: 3: groot
     neighbor of 1: 4: drax
      

