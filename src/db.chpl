use graph, energy, CdoExtras;
/*
 Factory Method.

 Bipartite Graphs are described here: https://en.wikipedia.org/wiki/Bipartite_graph

 Uses the NamedMatrix class from Chingon to build a graph.
 :arg bool bipartite: Is this a bipartite graph where there are two sets of nodes
 */
proc Graph.fromNamedEdges(con:Connection
  , edgeTable: string, fromField: string, toField: string
  , bipartite=false) {
  const N = NamedMatrixFromPG(con, edgeTable=edgeTable
    , fromField=fromField, toField=toField, square=bipartite);
  var g = new Graph(NamedMatrix=N);
  return g;
}

/*
 Builds a Graph object using `NumSuch <https://github.com/buddha314/numsuch>`_ MatrixOps module

 :arg nameTable string: The name of the Postgres table containing the pairs
 :arg nameField string: The name of the field in the nameTable containing the names
 :arg idField string: The name of the field in the nameTable containing the feature ids
 :arg con CDO.Connection: A `CDO Connection <https://github.com/marcoscleison/cdo>`_ to Postgres
 :arg edgeTable string: The table in PG of edges
 :arg fromField string: The field of edgeTable containing the id of the head vertex
 :arg toField string: the field of edgeTable containing the id of the tail vertex
 :arg wField string: The field of edgeTable containing the weight of the edge
 :arg directed bool: Indicating whether graph is directed
 :arg graphName string: A name for the graph
 :arg weights bool: Boolean on whether to use the weights in the table or a 1 (indicator)

 */
proc buildGraphFromPGTables(con:Connection
    , edgeTable:string, toField:string, fromField:string, wField:string
    , directed:bool, graphName:string) {
  const nm = NamedMatrixFromPG(con=con, edgeTable=edgeTable, fromField=fromField, toField=toField, wField=wField, square=false);
  var g = new Graph(N=nm);
  return g;
}

/*
Creates a set of untempered crystals from a Postgres table.
Requires data within Postgres as in test/data/entropy_base_graph_schema.sql

:arg constituentTable string: Postgres table with the crystal and their constituent ids
:arg constituentIdField string: The field in the constituentTable with the constituent id
:arg idField string: The field in the constituentTable that has the crystal id

:returns: An array of crystals from a given Postgres table
:rtype: :class:`Crystal`
 */
proc buildCrystalsFromPG(
    con: Connection
    , constituentTable: string
    , idField: string
    , constituentIdField: string
  ) {
  var q = "SELECT %s AS cid, array_agg(%s) AS a FROM %s GROUP BY 1 ORDER BY 1, 2";
  var cursor = con.cursor();
  cursor.query(q, (idField, constituentIdField, constituentTable));
  var crystals: [1..0] Crystal;
  for row in cursor {
    var cids: [1..0] int;
    for b in row.getArray('a') {
      cids.push_back(b: int);
    }
    crystals.push_back(new Crystal(row['cid'], cids));
  }
  return crystals;
}
}
