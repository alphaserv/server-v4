local DEFAULT_MUTE_TIME = server.default_mute_time or (1000 * 60 * 60)
local KEY_FUNCTION = server.player_iplong

local muted = {}
local mute_triggers = list_to_set(server.parse_list(server.mute_triggers or "")) 

function server.mute(cn, mute_time, reason)

    mute_time = mute_time or DEFAULT_MUTE_TIME
    
    local key = KEY_FUNCTION(cn)
    
    muted[key] = true
    
    for _, cn in ipairs(server.players()) do 
        if KEY_FUNCTION(cn) == key then
            local message = "You have been muted"
            if reason then
                message = message .. " because " .. reason
            end
            server.player_msg(cn, red(message))
        end
    end
    
    server.sleep(mute_time, function()
        muted[key] = nil
    end)
end

function server.unmute(cn)

    local key = KEY_FUNCTION(cn)
    
    muted[key] = nil
    
    for _, cn in ipairs(server.clients()) do
		if KEY_FUNCTION(cn) == key then
			server.player_msg(cn, "You have been unmuted.")
		end
    end
end

function server.is_muted(cn)
	return muted[KEY_FUNCTION(cn)]
end

local function translate_number_letters(text)
    text = text:gsub("4", "a")
    text = text:gsub("3", "e")
    text = text:gsub("1", "i")
    text = text:gsub("0", "o")
    return text
end

local function block_text(cn, text)

    local is_muted = muted[KEY_FUNCTION(cn)]
    
    if is_muted then
        server.player_msg(cn, red("Your chat messages are being blocked."))
        return -1
    else -- Check for mute triggers in their message
        
        text = string.lower(translate_number_letters(text))
        
        for trigger in pairs(mute_triggers) do
            if text:match(trigger) then
                server.mute(cn, DEFAULT_MUTE_TIME, "you used offensive language")
                return -1
            end
        end
    end
end

local text_event = server.event_handler("text", block_text)
local sayteam_event = server.event_handler("sayteam", block_text)

local function unload()
    server.mute = nil
    server.unmute = nil
end

return {unload = unload}
