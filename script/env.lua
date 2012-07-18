BASEPATH = "/home/bram/alphaserv-v4"

package.path = BASEPATH.."/script/?/init.lua;" .. package.path
package.path = BASEPATH.."/script/package/?/init.lua;" .. package.path
package.path = BASEPATH.."/script/package/?.lua;" .. package.path
package.path = BASEPATH.."/script/?.lua;" .. package.path
package.cpath = BASEPATH.."/lib/lib?.so;" .. package.cpath
