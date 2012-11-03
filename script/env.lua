--[[
	Initialize the lua enviroment with search paths
]]
BASE_DIR = BASE_DIR or "script"
LIB_DIR = LIB_DIR or "lib"

LUAROCKS_PATH = LUAROCKS_PATH or "%(BASE_DIR)s/luarocks/src/?.lua"
PACKAGE_PATH = PACKAGE_PATH or "%(BASE_DIR)s/package/?.lua;%(BASE_DIR)s/package/?/init.lua;%(BASE_DIR)s/?.lua;%(BASE_DIR)s/?/init.lua"
LIB_PATH = LIB_PATH or "%(LIB_DIR)s/lib?.so"

UTIL_PATH = UTIL_PATH or "script/package/std/string.lua"

dofile (UTIL_PATH)

package.path = package.path .. (
	(";".. LUAROCKS_PATH..";"..PACKAGE_PATH) % {BASE_DIR = BASE_DIR, LIB_DIR = LIB_DIR}
)
package.cpath = package.cpath .. (
	(";".. LIB_PATH) % {BASE_DIR = BASE_DIR, LIB_DIR = LIB_DIR}
)
