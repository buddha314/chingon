use Postgres,
    LinearAlgebra,
    Chingon,
    Assert;

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
    X: [SD] real;

SD += (1,2); X[1,2] = 1;
SD += (1,3); X[1,3] = 1;
SD += (1,4); X[1,4] = 1;
SD += (2,2); X[2,2] = 1;
SD += (2,4); X[2,4] = 1;
SD += (3,4); X[3,4] = 1;
SD += (4,5); X[4,5] = 1;
SD += (5,6); X[5,6] = 1;
SD += (6,7); X[6,7] = 1;
SD += (6,8); X[6,8] = 1;
SD += (7,8); X[7,8] = 1;
var g = new Graph(X=X, directed = false);
writeln(g.X);

assert(g.directed == false, "g.directed is ", g.directed, " expected false");
var gd = new Graph(X=X, directed=false);
assert(gd.directed == false, "gd.directed is ", gd.directed, " expected false");
assert(gd.vcount() == 8, "gd.vcount() is ", gd.vcount(), " expected 8");
var g2 = new Graph(X=X, name="Vato");
assert(g2.name == "Vato", "g2.name is ", g2.name, " expected 'Vato'");
var g3 = new Graph(X=X, directed=false, name="Vato", vnames = vn);
assert(g3.name == "Vato", "g3.name is ", g3.name, " expected 'Vato'");
assert(1 == 1, "Yay!");
const g3nvs = g3.verts.keys.sorted();
assert(g3nvs[1] == 'drax', "g3nvs[1] is ", g3nvs[1] , " expected 'drax'");
assert(g3nvs[3] == 'groot', "g3nvs[3] is ", g3nvs[3] , " expected 'groot'");
assert(g3nvs[4] == 'mantis', "g3nvs[4] is ", g3nvs[4] , " expected 'mantis'");
assert(g3nvs[8] == 'yondu', "g3nvs[8] is ", g3nvs[8] , " expected 'yondu'");

for v in g3.verts.idxkey.sorted() {
  writeln("g3 vids[", v, "]: ", g3.verts.idx[v]);
}
const p:int = 4;
// Check for list of vertex IDs adjacent to p
for n in g3.neighbors(p).idxkey.sorted() {
  writeln("neighbor of ", g3.verts.idx[p], ": ", n, ": ", g3.verts.idx[n]);
}
// Check for list of vertex IDs adjacent to vertex with name "drax"
for n in g3.neighbors("drax").idxkey.sorted() {
  writeln("neighbor of drax: ", n, ": ", g3.verts.idx[n]);
}
var dgs = g3.degree();
writeln("\ndegrees:\n", dgs);

var ws = g3.flow();
writeln("\nFlow:\n", ws);

// Get the flow of vertices by vertex id
var wsi = g3.flow(vs={1,2,4}, interior=false);
writeln("\nFlow (1,2,4):\n", wsi);

// Get the flow of vertices by name
var wsin = g3.flow(vs={"star lord", "gamora", "drax"}, interior=false);
writeln("\nFlow (star lord, gamora, drax):\n", wsin);

var wsii = g3.flow(vs={1,2,4}, interior=true);
writeln("\nFlow (1,2,4) interior:\n", wsii);

var ve = g3.subgraphEntropy(subgraph={1,2,3,4}, base=g3.flow());
writeln("graph entropy [1,2,3,4]: ", ve);
var vf = g3.subgraphEntropy(subgraph={1,2,3,4,5}, base=g3.flow());
writeln("graph entropy [1,2,3,4,5]: ", vf);

writeln("g3.W:\n", g3.X);
g3.addEdge(3,5, 2.71);
writeln("g3.W with (3,5) = 2.71\n", g3.X);
g3.updateEdge(3,6, -4.24);
writeln("g3.W with (3,6) += -4.24\n", g3.X);
g3.updateEdge(3,6, 1.10);
writeln("g3.W with (3,6) += 1.10\n", g3.X);


/*
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
      wField = "w";  */
/*
var con = PgConnectionFactory(host=DB_HOST, user=DB_USER, database=DB_NAME, passwd=DB_PWD);

var g4 = buildGraphFromPGTables(con=con
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

// Check boundary function
writeln("Boundary of vs: ", g4.boundary({1,3,4}));
*/
