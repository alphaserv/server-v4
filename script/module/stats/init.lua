local using_sqlite = (server.stats_use_sqlite == 1)
local using_json = (server.stats_use_json == 1)
local using_mysql = (server.stats_use_mysql == 1)
local query_backend_name = server.stats_query_backend

local commit_backends = {}
local query_backend = nil

if using_sqlite then    
    (function()
        
        if not sqlite3 then
            server.log_error("Cannot use sqlite3 backend for the stats module: missing lsqlite3 support")
            return
        end
        
        commit_backends.sqlite3 = dofile("./script/module/stats/sqlite3.lua")
        
        catch_error(commit_backends.sqlite3.open, {
            filename = server.stats_db_filename, 
            schemafile = "./script/module/stats/schema.sql",
            exclusive_locking = server.stats_sqlite_exclusive_locking,
            synchronous = server.stats_sqlite_synchronous
        })
    end)()
end

if using_json then
    commit_backends.json = catch_error(loadfile("./script/module/stats/json.lua"))    
end

if using_mysql then
    
    commit_backends.mysql = dofile("./script/module/stats/mysql.lua")
    
    catch_error(commit_backends.mysql.open, {
        hostname    = server.stats_mysql_hostname,
        port        = server.stats_mysql_port,
        username    = server.stats_mysql_username,
        password    = server.stats_mysql_password,
        database    = server.stats_mysql_database,
        schema      = "./script/module/stats/mysql_schema.sql",
        triggers    = "./script/module/stats/mysql_triggers.sql",
        install     = server.stats_mysql_install == 0,
        servername  = server.stats_servername
    })
end

query_backend = commit_backends[server.stats_query_backend]

if query_backend then
    
    local global_query_interface = {"find_names_by_ip"}
    
    for _, query_function_name in pairs(global_query_interface) do
        if query_backend[query_function_name] then
            server[query_function_name] = query_backend[query_function_name]
        else
            server.log_error(string.format("Stats module error: %s query backend is missing function %s", query_backend_name, query_function_name))
        end
    end
else
    server.find_names_by_ip = function() return nil end
    
    if server.stats_query_backend ~= "" then
        server.log_error(string.format("Error in stats module: unused/unknown %s commit backend is trying to be used for the query backend.")) 
    end
end

dofile("./script/module/stats/core.lua").initialize(commit_backends, query_backend, {
    using_auth = server.stats_use_auth,
    auth_domain = server.stats_auth_domain,
    gamemodes = list_to_set(server.parse_list(server.stats_enabled_gamemodes))
})

-- Load and register the #stats player command
local stats_command = dofile("./script/module/stats/playercmd.lua")
stats_command.initialize(query_backend)

