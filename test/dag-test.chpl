use LinearAlgebra, Chingon;

var graphName = "Vato";
var vn: [1..0] string;
vn.push_back("star lord");
vn.push_back("gamora");
vn.push_back("groot");
vn.push_back("drax");
vn.push_back("rocket");
vn.push_back("mantis");
vn.push_back("yondu");
vn.push_back("nebula");
vn.push_back("taserface");

var G = new Graph(vnames=vn);
writeln("G.vnames\t", G.vnames);
G.addPath([1,2,5]);
G.addPath([2,6]);
G.addPath([1,3]);
G.addPath([1,4,8]);
G.addPath([1,4,9]);
G.addPath([4,7]);
writeln("G.SD\n", G.SD);
var H = new Graph(vnames=vn);
H.addPath(["star lord", "gamora", "rocket"]);
H.addPath(["gamora", "mantis"]);
H.addPath(["star lord", "groot"]);
H.addPath(["star lord", "drax", "yondu"]);
H.addPath(["star lord", "drax", "nebula"]);
H.addPath(["drax", "taserface"]);

writeln("H.SD\n", H.SD);
