use LinearAlgebra,
    LinearAlgebra.Sparse,
    Chingon;

/* MERGE WITH chingon-base-test.chpl ONCE REFACTORED
   BRANCH IS MERGED WITH DEVELOP.
*/

    var nv: int = 8,
        D: domain(2) = {1..nv, 1..nv},
        SD = CSRDomain(D),
        X: [SD] real;

    SD += (1,2); X[1,2] = 1;
    SD += (2,3); X[2,3] = 1;
//    SD += (3,4); X[3,4] = 1;
//    SD += (3,4); X[3,4] = 1;
//    SD += (4,5); X[4,5] = 1;
//    SD += (3,6); X[3,6] = 1;
//    SD += (6,8); X[6,8] = 1;


    writeln(aMax(0,X));
    writeln(argMin(1,X));



//    writeln(maxdim(axis = 2,id = 2,X));
//    writeln(maxiloc(axis = 2,id = 2,X));
//    writeln((axis = 1,id = 2,X));
//    writeln(maxiloc(axis = 1,id = 2,X));
/*
    var idm: (int,int),
        maximum: real = 0;
    if axis == 0 {
      for (i,j) in X.domain {
        if X(i,j) > maximum {
          maximum = X(i,j);
          idm = (i,j);
        }
      }
      writeln(maximum);
    }
    if axis == 2 {
      for a in X.domain.dimIter(2, id:int) {
        if X(id,a) > maximum {
          maximum = X(id,a);
          idm = (id,a);
        }
      }
      writeln(maximum);
    }*/
