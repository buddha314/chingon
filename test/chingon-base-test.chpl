use Chingon,
    LinearAlgebra;

//var g = new Graph("Vato");
//writeln(g.name);
var vn: [1..0] string;
vn.push_back("star lord");
vn.push_back("gamora");
vn.push_back("groot");
vn.push_back("drax");
vn.push_back("rocket");
vn.push_back("mantis");
vn.push_back("yondu");
vn.push_back("nebula");

var nv: int = 8,
    D: domain(2) = {1..nv, 1..nv},
    SD: sparse subdomain(D),
    W: [SD] real;

SD += (1,2); W[1,2] = 1;
SD += (1,3); W[1,3] = 1;
SD += (1,4); W[1,4] = 1;
SD += (2,2); W[2,2] = 1;
SD += (2,4); W[2,4] = 1;
SD += (3,4); W[3,4] = 1;
SD += (4,5); W[4,5] = 1;
SD += (5,6); W[5,6] = 1;
SD += (6,7); W[6,7] = 1;
SD += (6,8); W[6,8] = 1;
SD += (7,8); W[7,8] = 1;
var g = new Graph(W=W);
writeln(g.W);
writeln("g.directed: ", g.directed);
var gd = new Graph(W=W, directed=false);
writeln("\ngd.directed: ", gd.directed);
writeln("\ngd.W\n", gd.W);
var g2 = new Graph(W=W, name="Vato");
writeln("g2 name: ", g2.name);
var g3 = new Graph(W=W, directed=false, name="Vato", vnames = vn);
writeln("g3 name: ", g3.name);

for v in g3.vnames.sorted() {
  writeln("g3 vids[", v, "]: ", g3.vids[v]);
}
const p:int = 4;
for n in g3.neighbors(p).sorted() {
  writeln("neighbor of ", g3.nameIndex[p], ": ", n, ": ", g3.nameIndex[n]);
}
for n in g3.neighbors("drax").sorted() {
  writeln("neighbor of drax: ", n, ": ", g3.nameIndex[n]);
}
var dgs = g3.degree();
writeln("\ndegrees:\n", dgs);

var ws = g3.weights();
writeln("\nWeights:\n", ws);

var wsi = g3.weights([1,2,4]);
writeln("\nWeights (1,2,4):\n", wsi);
