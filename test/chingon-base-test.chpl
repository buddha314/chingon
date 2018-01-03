use Postgres,
    LinearAlgebra,
    Chingon;

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
// Check for list of vertex IDs adjacent to p
for n in g3.neighbors(p).sorted() {
  writeln("neighbor of ", g3.nameIndex[p], ": ", n, ": ", g3.nameIndex[n]);
}
// Check for list of vertex IDs adjacent to vertex with name "drax"
for n in g3.neighbors("drax").sorted() {
  writeln("neighbor of drax: ", n, ": ", g3.nameIndex[n]);
}
var dgs = g3.degree();
writeln("\ndegrees:\n", dgs);

var ws = g3.flow();
writeln("\nFlow:\n", ws);

var wsi = g3.flow(vs=[1,2,4]);
writeln("\nFlow (1,2,4):\n", wsi);
var wsii = g3.flow(vs=[1,2,4], interior=true);
writeln("\nFlow (1,2,4) interior:\n", wsii);

var ve = g3.subgraphEntropy(subgraph=[1,2,3,4], base=g3.flow());
writeln("graph entropy [1,2,3,4]: ", ve);
var vf = g3.subgraphEntropy(subgraph=[1,2,3,4,5], base=g3.flow());
writeln("graph entropy [1,2,3,4,5]: ", vf);

writeln("g3.W:\n", g3.W);
g3.addEdge(3,5, 2.71);
writeln("g3.W with (3,5) = 2.71\n", g3.W);
g3.updateEdge(3,6, -4.24);
writeln("g3.W with (3,6) += -4.24\n", g3.W);
g3.updateEdge(3,6, 1.10);
writeln("g3.W with (3,6) += 1.10\n", g3.W);

// Start to test against Postgres using NumSuch
// Data must be loaded as in data/entropy_base_graph_schema.sql
// This only needs to be done once, if you have tested with NumSuch, the data should exist already.
config const DB_HOST: string = "localhost";
config const DB_USER: string = "buddha";
config const DB_NAME: string = "buddha";
config const DB_PWD: string = "buddha";
const nameTable = "r.cho_names",
      idField = "ftr_id",
      nameField = "name",
      edgeTable = "r.cho_edges",
      fromField = "from_fid",
      toField = "to_fid",
      wField = "w";

var con = PgConnectionFactory(host=DB_HOST, user=DB_USER, database=DB_NAME, passwd=DB_PWD);

var g4 = buildGraphFromPGTables(con=con
  , nameTable=nameTable, nameField=nameField, idField=idField
  , edgeTable=edgeTable, toField=toField, fromField=fromField, wField=wField
  , directed=false, graphName=graphName);
writeln("g4.name: ", g4.name);

const constituentTable = "r.cho_constituents",
      crystalIdField = "crystal_id",
      constituentIdField = "constituent_id";

var crystals = buildCrystalsFromPG(
      con=con
    , constituentTable: string
    , idField=crystalIdField
    , constituentIdField=constituentIdField);
for c in crystals {
  writeln("crystal id: ", c.id, " -> ", c.ftrIds);
}
