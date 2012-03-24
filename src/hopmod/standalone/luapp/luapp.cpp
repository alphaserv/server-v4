#include <lua.hpp>
#include "lua/modules.hpp"
#include "lua/event.hpp"
#include "hopmod.hpp"
#include <iostream>
#include <boost/asio.hpp>
using namespace boost::asio;

static io_service main_io_service;

io_service & get_main_io_service()
{
    return main_io_service;
}

template<typename FunctionPointerType>
static void bind_function(lua_State * L, int table, const char * name, FunctionPointerType function)
{
    lua_pushstring(L, name);
    lua::push_function(L, function);
    lua_settable(L, table);
}

static void bind_function(lua_State * L, int table, const char * name, lua_CFunction function)
{
	lua_pushstring(L, name);
	lua_pushcfunction(L, function);
	lua_settable(L, table);
}

int test (lua_State *L)
{
	int i = 10;
	lua_pushinteger(L, i);
	
	return 1;
}

int main(int argc, char ** argv)
{
    if(argc == 1)
    {
        std::cerr<<"Usage: "<<argv[0]<<" filename"<<std::endl;
        return 1;
    }
    
    const char * script = argv[1];
    
    init_lua();
    lua_State * L = get_lua_state();
    
    switch(luaL_loadfile(L, script))
    {
        case 0: //success
            break;
        case LUA_ERRFILE:
        case LUA_ERRSYNTAX:
        case LUA_ERRMEM:
            std::cerr<<lua_tostring(L, -1)<<std::endl;
            return 1;
        default:;
    }
    
    // Create and fill arg table
    lua_newtable(L);
    for(int i = 2; i < argc; i++)
    {
        lua_pushinteger(L, i - 1);
        lua_pushstring(L, argv[i]);
        lua_settable(L, -3);
    }
    lua_setfield(L, LUA_GLOBALSINDEX, "arg");
    
    
	#ifdef LUAPP_TABLE
		lua_newtable(L);
		int T = lua_gettop(L);
		
		bind_function(L, T, "test_func", test);
		bind_function(L, T, "file_exists", file_exists);
		bind_function(L, T, "dir_exists", dir_exists);
		
		
/*		lua_pushliteral(L, "vars");
		lua_newtable(L);
		int vars_table = lua_gettop(L);
		
		luapp::init_constants(L, vars_table);
		luapp::init_variables(L, vars_table);
		
		lua_settable(L, -3); // Add vars table to core table*/
		lua_setglobal(L, "core"); // Add core table to global table
	#endif
    
    if(luaL_dofile(L, script) == 1)
    {
        std::cerr<<lua_tostring(L, -1)<<std::endl;
        return 1;
    }
    
    try
    {
        main_io_service.run();
    }
    catch(const boost::system::system_error & se)
    {
        std::cerr<<se.what()<<std::endl;
        throw;
    }
    
    return 0;
}

