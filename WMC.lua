local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local faction
local zones = {
    ["Arathi Highlands"] = true,
    ["Ashenvale"] = true,
    ["Azshara"] = true,
    ["Badlands"] = true,
    ["Blasted Lands"] = true,
    ["Burning Steppes"] = true,
    ["Darkshore"] = true,
    ["Deadwind Pass"] = true,
    ["Dun Morogh"] = true,
    ["Duskwood"] = true,
    ["Eastern Plaguelands"] = true,
    ["Elwynn Forest"] = true,
    ["Felwood"] = true,
    ["Feralas"] = true,
    ["Hillsbrad Foothills"] = true,
    ["Loch Modan"] = true,
    ["Moonglade"] = true,
    ["Mulgore"] = true,
    ["Redridge Mountains"] = true,
    ["Searing Gorge"] = true,
    ["Silithus"] = true,
    ["Silverpine Forest"] = true,
    ["Stonetalon Mountains"] = true,
    ["Stranglethorn Vale"] = true,
    ["Swamp of Sorrows"] = true,
    ["Tanaris"] = true,
    ["Teldrassil"] = true,
    ["The Barrens"] = true,
    ["The Hinterlands"] = true,
    ["Thousand Needles"] = true,
    ["Tirisfal Glades"] = true,
    ["Un'Goro Crater"] = true,
    ["Western Plaguelands"] = true,
    ["Westfall"] = true,
    ["Wetlands"] = true,
    ["Winterspring"] = true,
}

local function CheckOpposingFaction()
    local currentZone = GetRealZoneText()

    if zones[currentZone] then
        local opposingFaction
        if faction == "Alliance" then
            opposingFaction = "Horde"
        else
            opposingFaction = "Alliance"
        end

        local races
        if opposingFaction == "Horde" then
            races = { "Orc", "Undead", "Goblin", "Tauren", "Troll" }
        elseif opposingFaction == "Alliance" then
            races = { "Human", "Dwarf", "Gnome", "Night Elf", "High Elf" }
        end

        local index = 1
        local timer
        timer = C_Timer.NewTicker(2, function()
            if index <= #races then
                local race = races[index]
                SendWho('r-"' .. race .. '" z-' .. currentZone)
                index = index + 1
            else
                timer:Cancel()
            end
        end)
    end
end

local function OnEvent(event)
    if event == "PLAYER_LOGIN" then
        local _, playerFaction = UnitFactionGroup("player")
        if playerFaction == "Alliance" or playerFaction == "Horde" then
            faction = playerFaction
        end

        -- Reminder message upon game loading completion
        DEFAULT_CHAT_FRAME:AddMessage("Type /wmc to manually check for opposing faction players in the current zone.")
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        CheckOpposingFaction()
    end
end

frame:SetScript("OnEvent", function(_, event, ...) OnEvent(event) end)

-- Slash command handler
local function SlashCommandHandler(msg)
    if msg == "wmc" then
        CheckOpposingFaction()
    end
end

-- Register slash commands
SLASH_MYADDON1 = "/wmc"
SlashCmdList["MYADDON"] = SlashCommandHandler

-- Function to print the /who results in the chat box
local function PrintWhoResults(...)
    local numResults = select("#", ...)
    if numResults > 0 then
        DEFAULT_CHAT_FRAME:AddMessage("--- Opposing Faction Players in Zone ---")
        for i = 1, numResults do
            local info = { ... }
            local name = info[(i - 1) * 14 + 1]
            local level = info[(i - 1) * 14 + 6]
            local race = info[(i - 1) * 14 + 11]
            local class = info[(i - 1) * 14 + 12]
            DEFAULT_CHAT_FRAME:AddMessage(name .. " (" .. level .. " " .. race .. " " .. class .. ")")
        end
        DEFAULT_CHAT_FRAME:AddMessage("---------------------------------------")
    else
        DEFAULT_CHAT_FRAME:AddMessage("No opposing faction players found in the zone.")
    end
end

-- Hook into the default chat frame to capture the /who results
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
    if string.find(message, "Players found") then
        local _, _, results = string.find(message, "(.*)Players found:")
        if results then
            local name, level, race, class
            local whoResults = {}

            for w in results:gmatch("%S+") do
                if w == "player" then
                    if name then
                        whoResults[#whoResults + 1] = {
                            name = name,
                            level = level,
                            race = race,
                            class = class
                        }
                        name, level, race, class = nil, nil, nil, nil
                    end
                elseif not name then
                    name = w
                elseif not level then
                    level = w
                elseif not race then
                    race = w
                elseif not class then
                    class = w
                end
            end

            if #whoResults > 0 then
                PrintWhoResults(unpack(whoResults))
            end
        end
    end
    return false
end
