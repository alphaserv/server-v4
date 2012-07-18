require "script.env"

for filetype, filename in filesystem.dir(BASEPATH.."/instances") do
	if filename ~= "template" and filename ~= ".." and filename ~= "." then
		os.execute("cd "..BASEPATH.."/instances/"..filename..";bin/server")
		print ("starting server "..filename)
	end
end

print "started all servers"
