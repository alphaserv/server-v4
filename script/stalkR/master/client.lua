module("master.client", package.seeall)

fetcher_obj = class.new(nil, {
	client = nil,
	adress = {ip = "", port = ""},
	
	__init = function(self)
		self.client = net.tcp_client()
	end,
	
	connect = function(self, host, port)
	
		if not alpha.settings:get("master_extern_sync") then
			return
		end
	
		--disconnect, if not already
		self.client:close()
		self.client = net.tcp_client()
		
		--connect
		self.client:async_connect(host, port, function(errmsg)
			if errmsg then
				self:error("connect", errmsg)
				return
			end
			
			self.adress = self.client:local_endpoint()
			
            master.debug("[Client] : Local socket address %s:%s", self.adress.ip, self.adress.port)
            
            self.client:async_send("list\n", function(errmsg)
                if errmsg then
                    self:error("list", errmsg)
                    return 
                end
                
                self:read() 
            end)
        end)
    end,
    
    read = function(self)
    	self.client:async_read_until("\n", function(data)
    		if data then
    			if data ~= "" then
    				data = data:gsub("\n", "")
					data:gsub("addserver (.-) (.*)", function(ip, port)
						self:addserver(ip, port)
					end)
					self:read()
				end
			else
				self.client:close()
			end
    	end)
    end,
    
    addserver = function(self, ip, port)
    	master.debug("[Client] : adding server %s:%s", ip, port)
    	self.func(ip, port)
    end,
    
    addserver_event = function(self, func)
    	self.func = func
    end,
    
    error = function(self, on, msg)
    	print("error on %(1)q : %(2)s" % {on, msg})
    end,
})

--local lastupdate;

local fetcher = fetcher_obj()

function update()
	master.clear_list()
	fetcher:addserver_event(master.addserver)
	fetcher:connect(alpha.settings:get("master_extern_host"), alpha.settings:get("master_extern_port"))
end

update()
