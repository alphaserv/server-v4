require "json"
require "http.client"

package("neo4j.connection", package.seeall)

result = newclass("Result")
function result:init(string)


connection = newclass("Connection")
connection.host = "localhost"
connection.port = 7474

function connection:init(host, port)
	connection.host = host or connection.host
	connection.port = port or connection.port
end

--dummy
function connection:connect() end

function connection:parseBody(query)
	query
	return
end

function connection:runQuery(query, callback)

	local requestMethod =
		query.type and query.type = neo4j.TYPE_GET		and "GET" or
		query.type and query.type = neo4j.TYPE_UPDATE	and "POST" or
		query.type and query.type = neo4j.TYPE_CREATE	and "PUT" or
		query.type and query.type = neo4j.TYPE_DELETE	and "DELETE" or
		error ("unknown query.type", 1)
	
	
	http.client.connection(self.host, self.port):request {
		method = requestMethod,
		headers = {
			Accept = "application/json",
			body = self:parseBody(query.parseQuery()),
		}
	}

	{
  "extensions" : {
  },
  "node" : "http://localhost:7474/db/data/node",
  "reference_node" : "http://localhost:7474/db/data/node/31",
  "node_index" : "http://localhost:7474/db/data/index/node",
  "relationship_index" : "http://localhost:7474/db/data/index/relationship",
  "extensions_info" : "http://localhost:7474/db/data/ext",
  "relationship_types" : "http://localhost:7474/db/data/relationship/types",
  "batch" : "http://localhost:7474/db/data/batch",
  "cypher" : "http://localhost:7474/db/data/cypher",
  "neo4j_version" : "1.8"
}
end

