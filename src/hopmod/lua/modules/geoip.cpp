#include <lua.hpp>
#include "../../geoip/GeoIP.h"
#include "../../geoip/GeoIPCity.h"
#include "module.hpp"

static GeoIP * geoip = NULL;
static GeoIP * GeoCity = NULL;

static int load_geoip_database(lua_State * L)
{
    const char * filename = luaL_checkstring(L, 1);
    if(geoip) GeoIP_delete(geoip);
    geoip = GeoIP_open(filename, GEOIP_STANDARD | GEOIP_MEMORY_CACHE);
    lua_pushboolean(L, geoip != NULL);
    return 1;
}

static int load_geocity_database(lua_State * L)
{
    const char * filename = luaL_checkstring(L, 1);
    if(GeoCity) GeoIP_delete(GeoCity);
    GeoCity = GeoIP_open(filename, GEOIP_STANDARD);
    lua_pushboolean(L, GeoCity != NULL);
    return 1;
}

static int ip_to_country(lua_State * L)
{
    if(!geoip) return luaL_error(L, "missing GeoIP database");
    const char * ipaddr = luaL_checkstring(L, 1);
    const char * country = GeoIP_country_name_by_addr(geoip, ipaddr); 
    lua_pushstring(L, (country ? country : ""));
    return 1;
}

static int ip_to_country_code(lua_State * L)
{
    if(!geoip) return luaL_error(L, "missing GeoIP database");
    const char * ipaddr = luaL_checkstring(L, 1);
    const char * code = GeoIP_country_code_by_addr(geoip, ipaddr);
    lua_pushstring(L, (code ? code : ""));
    return 1;
}

static int ip_to_city(lua_State * L)
{
    if(!GeoCity) return luaL_error(L, "missing GeoCity database");
    GeoIPRecord *r = GeoIP_record_by_addr(GeoCity, luaL_checkstring(L, 1));
    lua_pushstring(L, (r && r->city ? r->city : ""));
    if(r) GeoIPRecord_delete(r);
    return 1;
}

static int shutdown_geoip(lua_State * L)
{
    GeoIP_delete(geoip);
    GeoIP_delete(GeoCity);
    geoip = NULL;
    GeoCity = NULL;
    return 0;
}

namespace lua{
namespace module{

void open_geoip(lua_State * L)
{
    static luaL_Reg functions[] = {
        {"load_geoip_database", load_geoip_database},
		{"load_geocity_database", load_geocity_database},
        {"ip_to_country", ip_to_country},
        {"ip_to_country_code", ip_to_country_code},
		{"ip_to_city", ip_to_city},
        {NULL, NULL}
    };
    
    luaL_register(L, "geoip", functions);
    lua_pop(L, 1);
    
    lua::on_shutdown(L, shutdown_geoip);
}

} //namespace module
} //namespace lua
