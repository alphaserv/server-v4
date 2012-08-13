--[[
    A player command to raise privilege to master
]]

local domains = table_unique(server.parse_list(server["master_domains"]))

if not domains then
    server.log_error("master command: no domains set")
    return
end

local function init() end
local function unload() end

local function run(cn)

    local sid = server.player_sessionid(cn)

    for _, domain in pairs(domains) do
        auth.send_request(cn, master_domain, function(cn, user_id, domain, status)

            if not (sid == server.player_sessionid(cn)) or not (status == auth.request_status.SUCCESS) then
                return
            end
            
            local admin_present = server.master ~= -1 and server.player_priv_code(server.master) == server.PRIV_ADMIN
            
            if not admin_present then
                
                if (server.player_priv_code(cn) > 0) then
                    server.unsetpriv(cn)
                end
                
                server.setmaster(cn)
                
                server.msg(server.player_displayname(cn) .. " claimed master as '" .. magenta(user_id) .. "'")
                server.log(string.format("%s playing as %s(%i) used auth to claim master.", user_id, server.player_name(cn), cn))
            else
                server.player_msg(cn,red("An admin or master is already there."))
            end
        end)
    end
end

return {init = init, run = run, unload = unload}

