
require "script.env"

--when basepath is not set yet
if BASEPATH:match("%{.*%}") then
	BASEPATH = os.getenv("_AS_BASEPATH")
end

require "hopmod_base.pcall"

--Nicer Errors
native_error = error
error = function(message, i)
    message = debug.traceback(message, 2)
	native_error(message, i)
end

require "orbit.model"

local _, errors = pcall(function()

io.write([[
                                                                                                            
                                                               ;XGs                                         
                                                             ,3@@@#,                                        
                                                            rA@@@@B,                                        
                                                          ,S@@@@@@B;                                        
                                                         ;H@@@@@@@Br                                        
                                                       .;A@@@@@@@@Mr.                                       
                                                      .i#@@@@@@@@@#i,                                       
                                                     ;X@@@@@@@@@@@@2:                                       
                                                   .rM@@@@@@@@@@@@@Ar.                                      
                                                  :3@@@@@M22M@@@@@@#5.                                      
                                                .rB@@@@@#r  i@@@@@@@G,                                      
                                               ,2@@@@@@&;   :A@@@@@@#:                                      
                                              rH@@@@@@9:    ,5#@@@@@@r                                      
                                            ,i#@@@@@#s      ,rS25iSX3Sr:,                                   
                                           :9@@@@@@9:   ,:;;rr;;:::;s29Xir;,                                
                                         .sB@@@@@Mi.  ,s9A&32ir;;;;rsi2X9&&2r,                              
                                        ,5@@@@@@3: .;iX33X25SiiissssssiS22Xh9S;.                            
                                       r#@@@@@BXr:;r2XXX2s;. ,3@@@@@H2ssiSS2X9Xs,                           
                                     .i@@@@@@M2;;s2225s;,     2@@@@@@&irsiiiSXhXr.                          
                                    ,X@@@@@@Ai;;rsSSs;,       ;A@@@@@#2;:;sSSS222s:                         
                                   r&@@@@@@&s::rSiir:         ,SM@@@@@h: .r25iS292;.                        
                                 ,s#@@@@@Mr.,;si5Sr,           ;&@@@@@#:  ;225ir:.                          
                                :G@@@@@#X: .:i2iir:            :3@@@@@@r  ,;;:.                             
                              .sM@@@@#G:  .riS5ir,              i@@@@@@S.                                   
                             :3@@@@@@3;   ;S2SSir:.            .S@@@@@@X,                                   
                            r#@@@@@@@@@@#A2isssi3M@@@@@@@@@@@@@@@@@@@@@h;                                   
                          :X@@@@@@@@@@@@@@3srssi9#@@@@@@@@@@@@@@@@@@@@@Ar.                                  
                        .;H@@@@@@@@@@@@@@B2srssss5A@@@@@@@@@@@@@@@@@@@@BS,                                  
                       ,S#@@@@@#######@#Bh2isiisr;iG############@@@@@@@@3:                                  
                      :X@@@@@@5          .rS5iissr;;.            ;h@@@@@Br                                  
                    .r#@@@@@Br            ;52iiissr;,            .5@@@@@@S                                  
                   :3@@@@@#G:             ,riSSiisiiS5s:         ,5@@@@@@X                                  
                  :A@@@@@Ms                .;i5Siiii5X32i:.      .i#@@@@@9,                                 
                .i#@@@@@h;                   :rSSSiiiS2XX5r,     .s#@@@@@G:                                 
               :2@@@@@@A:                     ,rSSiiiii523XS;.    r#@@@@@A;                                 
        ..    ;A@@@@@@X,                       .;i25iiiiS2X3Xs,   ;#@@@@@Hr.                                
      .:ss;,:S#@@@@@Mr                           ,rS5SiiiiS23Xi:  ,H@@@@@#S,                                
     .;2&&3XH@@@@@@2,                              :i5SiiiiS5X92: :&@@@@@@h;                                
      .:s2XXX9A#M3r                                 .;i2Siiii5XXsrsh#@@@@@Mi                                
        rGHXs;rii;                                    ,rS2SiiiS5SisSh#@@@@@5.                               
       ;A@@#G2issr;:.                                  .;SSSiiiiisr;SB@@@@@X.                               
     ,X@@@@@@M3SS2h&3s,                                  :s5Siiiisr;SM@@@@@A,                               
   .rA@@@@@@M;  ,rXAAA9S;,                                ;iSiiiisrrSM@@@@@B:                               
  :&@@@@@@@2,     .;S&HH&2r:.                              :sSSiiirr2#@@@@@@i.                              
  ;XBB&932;         .:sXAHH9s:.                             ;S5iiisrsi233hA2;.                              
                       ,r2GAAAXr,                           ;S2iiiSi:                                       
                          ;SGAA&3S;.                        ;52iii5i:                                       
                            .;S&HH&2s;,                     ;52iiiir:                                       
                              .:r2&HBHXs;,.                .;S5iiir:.                                       
                         .:;:.   .;iXhAHH&5r,.            .:rSSiSi;.                                        
                     .:rSX9Xi:      .:i3&AA&GXi;,        .;iSiiiir:                                         
                     :iG&h9XXS;         ,;SGHHHGXSs;,    :i25S5i;,                                          
                     ,sXXSiSXXr,           ,;s5hHBBA2sr;riS5Ssr:                                            
                      ,;sSSi52i;,              ,;i23GAAAGX225s:.                                            
                       ,r55iiSXXs:                 :iX33X22222Ssr;,.                                        
                        :i5iiS2X32r:.           .,;rsii525ii23G&AG3X5ir;:,,.                                
                         :s22SiSXh92s;;:::::;;rs5XXX25ir:,..,:;r53&HBBBAhX25ir;;::,,,..                     
                          ,rS55552X3hG&&AAAAA&Gh9X5irr:.         ,:;sS2X9G&AHBMMBA&9XSsr;;;,.....           
                            ,riSS552XX3333XXX2225ir:                   .,;rsSXhGG&&&&AAAAAAAAAAhXSisrr;:    
                               .:;sS2XXXX25is;:,                                .,,:;ri5X9GAHBBHHHAAA&3i,   
                                                                                            ..,,:;;rrsr:    
                                                                                                ..,,:::,
	Installer 
]])

local function question(question)
	repeat
	
		print(question.." [y|n]")
	
		local answer = io.read()
	
		if answer == "y"
		or answer == "n"
		then
			return answer == "y"
		end

	until false
end


local function input(question_, default)
	local input
	repeat
		print(question_, "(default = "..default..")")
		input = io.read()

		if input == "" or input == "\n" then
			input = default
		end
		
	until question(string.format("Is this correct? \"%s\"", input))
	
	return input
end


--[[
if not question("Do you want to run the installation wizzard?") then
	print "cancelling .."
	os.exit()
end
]]
local create_scheme

local available_modules = {
	db = {
		{"host", "localhost", "the hostname of the database"},
		{"port", 3306, "the port of the database"},
		{"username", "alphaserv", "the username of the database user"},
		{"password", "alphaserv", "the password of the database user"},
		{"database", "alphaserv", "the name of the database to use"},
		{"META", function()
				create_scheme = question("Do you want to create the table scheme now?")
			end}
	},
	
	core = {
		{"basePath", BASEPATH, "The path to the alphaserv directory"}
	}
}

local settings = {}

for name, module in pairs(available_modules) do
	print(name.." Configuration")
	
	print("Please provide the following fields:")
	
	for i, setting in pairs(module) do
		if setting[1] == "META" then
			setting[2](settings)
		else
			settings[name.."."..setting[1]] = input(setting[3], setting[2])
		end
	end
end

if create_scheme then
	print "Installing database scheme."
	require("luasql_mysql")

	local conn = {
		open = function(self)
			self.db = assert(luasql.mysql():connect(settings['db.username'], settings['db.password'], settings['db.database'], settings['db.hostname'], settings['db.port']))
		
			return self
		end,
	
		escape = function(self, value)
			local s = ("%q"):format(value):sub(2)
			s = s:sub(0, s:len()-1)
			return s
		end,
	
		execute = function(self, ...)
			return assert(self.db:execute(...))
		end,
	
		close = function(self)
			return self.db:close()
		end,
	}
	
	setmetatable(conn, {__call = conn.open})

	conn:open()

	local dbConnection = orbit.model.new("", conn, "mysql", true)

	local file = io.open(BASEPATH..'/scheme.sql')
	file = file:read("*all")

	conn:execute(file)
			
	--TODO: add sample data
	--[[
	local model = dbConnection:new("users")

	for k, v in pairs(model:find_all("name = ?", {"me"})) do
		print (k, "=", v)
		for k2, v2 in pairs(v) do
			print("", k2, "=", v2)
		end
	
		v.priv = 0
		v:save()
	end
	]]
end

BASEPATH = settings['core.basePath']

-- init core settings
if settings['core.basePath'] then
	print "initializing core"
	local file = assert(io.open(BASEPATH.."/script/env.template.lua", "r"))
	local content = file:read("*all")
	file:close()
	content = content:gsub("%{as%.basePath%}", BASEPATH)
	
	print "writing.."
	print (content)
	
	file = assert(io.open(BASEPATH.."/script/env.lua", "w"))
	file:write(content)
	file:close()
end

if settings['db.host'] then
	print "initializing core"
	local file = assert(io.open(BASEPATH.."/script/base_config.template.lua", "r"))
	local content = file:read("*all")
	file:close()
	
	content = content:gsub("%{db%.username%}", settings['db.username'])
	content = content:gsub("%{db%.password%}", settings['db.password'])
	content = content:gsub("%{db%.database%}", settings['db.database'])
	
	content = content:gsub("%{db%.hostname%}", settings['db.host'])
	content = content:gsub("%{db%.port%}", settings['db.port'])
	
	print "writing.."
	print (content)
	
	file = assert(io.open(BASEPATH.."/base_config.lua", "w"))
	file:write(content)
	file:close()
end

print "Congratulations, you have successfully installed alphaserv!"
print "You can now run \"sh newinstance.sh\" to create a new server instance"

end)

for i, row in pairs(errors or {}) do
	print(row)
end
