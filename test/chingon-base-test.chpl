use Chingon,
    LinearAlgebra;

var g = new Graph("Vato");
writeln(g.name);
var vn: domain(string);
vn.add("star lord");
vn.add("gamora");
vn.add("groot");
vn.add("drax");
vn.add("rocket");
g = new Graph("Vato", vn);
writeln(g.vnames);

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
g = new Graph(A);
