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

var G = new Graph(vnames=vn);
writeln("G.vnames\t", G.vnames);
