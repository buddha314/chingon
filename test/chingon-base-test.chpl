use Chingon,
    LinearAlgebra;

//var g = new Graph("Vato");
//writeln(g.name);
var vn: domain(string);
vn.add("star lord");
vn.add("gamora");
vn.add("groot");
vn.add("drax");
vn.add("rocket");
vn.add("mantis");
vn.add("yondu");
vn.add("nebula");

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
var g = new Graph(A=A);
writeln(g.A);
var g2 = new Graph(A=A, name="Vato");
writeln(g2.name);
var g3 = new Graph(A=A, name="Vato", vnames = vn);
writeln(g3.vnames);
