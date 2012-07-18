BASEPATH = "{as.basePath}"
SERVERPATH = "{as.serverPath}"

dofile(BASEPATH.."/script/env.lua")

package.path = SERVERPATH.."/script/package/?.lua;" .. package.path
package.path = SERVERPATH.."/script/?.lua;" .. package.path
