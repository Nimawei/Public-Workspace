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
        DEFAULT_CHAT_FRAME:AddMessage("Type /wmc or click the 'Check Opposing Faction' button to manually check for opposing faction players in the current zone.")
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        CheckOpposingFaction()
    end
end

frame:SetScript("OnEvent", function(_, event, ...) OnEvent(event) end)

-- Function to print the /who results in a custom UI chat box
local function PrintWhoResults(...)
    local numResults = select("#", ...)
    if numResults > 0 then
        local chatFrame = CreateFrame("Frame", nil, UIParent)
        chatFrame:SetSize(400, 200)
        chatFrame:SetPoint("CENTER")
        chatFrame:EnableMouse(true)
        chatFrame:SetMovable(true)
        chatFrame:RegisterForDrag("LeftButton")
        chatFrame:SetScript("OnDragStart", chatFrame.StartMoving)
        chatFrame:SetScript("OnDragStop", chatFrame.StopMovingOrSizing)
        chatFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        chatFrame:SetBackdropColor(0, 0, 0, 0.8)

        local scrollFrame = CreateFrame("ScrollFrame", nil, chatFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", chatFrame, "TOPLEFT", 8, -8)
        scrollFrame:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMRIGHT", -8, 8)

        local editBox = CreateFrame("EditBox", nil, chatFrame)
        editBox:SetMultiLine(true)
        editBox:SetMaxLetters(0)
        editBox:EnableMouse(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(GameFontNormal)
        editBox:SetWidth(scrollFrame:GetWidth() - 16)
        editBox:SetHeight(scrollFrame:GetHeight() - 16)
        editBox:SetScript("OnEscapePressed", function() chatFrame:Hide() end)

        scrollFrame:SetScrollChild(editBox)

        local scrollbar = _G[scrollFrame:GetName().."ScrollBar"]
        scrollbar:SetPoint("TOPLEFT", chatFrame, "TOPRIGHT", -16, -16)
        scrollbar:SetPoint("BOTTOMLEFT", chatFrame, "BOTTOMRIGHT", -16, 16)

        local function AddMessageToChatBox(msg)
            editBox:AddMessage(msg)
        end

        -- Function to print the /who results in the custom UI chat box
        local function PrintWhoResults(...)
            local numResults = select("#", ...)
            if numResults > 0 then
                AddMessageToChatBox("--- Opposing Faction Players in Zone ---")
                for i = 1, numResults do
                    local info = { ... }
                    local name = info[(i - 1) * 14 + 1]
                    local level = info[(i - 1) * 14 + 6]
                    local race = info[(i - 1) * 14 + 11]
                    local class = info[(i - 1) * 14 + 12]
                    AddMessageToChatBox(name .. " (" .. level .. " " .. race .. " " .. class .. ")")
                end
                AddMessageToChatBox("---------------------------------------")
            else
                AddMessageToChatBox("No opposing faction players found in the zone.")
            end
        end

        -- Function to handle manual check
        local function ManualCheckOpposingFaction()
            CheckOpposingFaction()
        end

        -- Create the UI button
        local button = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
        button:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
        button:SetSize(160, 30)
        button:SetText("Check Opposing Faction")
        button:SetScript("OnClick", ManualCheckOpposingFaction)

        -- Event handling for displaying the custom chat box
        local function DisplayChatBox()
            if chatFrame:IsShown() then
                chatFrame:Hide()
            else
                chatFrame:Show()
            end
        end

        -- Create a slash command to toggle the custom chat box
        SLASH_MYADDON1 = "/wmc"
        SlashCmdList["WMC"] = DisplayChatBox
    end
end
