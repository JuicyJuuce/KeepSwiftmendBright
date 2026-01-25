-- KeepSwiftmendBright
-- Keeps Swiftmend bright on action bars and Cooldown Manager
--
-- TO-DO:
--  - Add options panel to configure which icons to brighten
--  - See if multiple Swiftmend buttons on actions bars can be handled
--  - Figure out why memory usage ticks up over time

local SWIFTMEND_SPELLID = 18562
local SWIFTMEND_FILEID = 134914     -- Swiftmend icon texture file ID
local thisAddonName, ns = ...
--local thisAddonTitle = "Keep Swiftmend Bright"
local KSB_DEBUG = false

local CDM_swiftmend_obj = nil
--local last_texture_value = {}
--local current_texture_value = {}
--local current_event_name = ""

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function debugPrint(...)
    if KSB_DEBUG then
        print(...)
    end
end

local function areArraysEqual(a1, a2)
    -- Check if the lengths are different (using the '#' operator)
    if #a1 ~= #a2 then
        return false
    end

    -- Check each element in order
    for i, v in ipairs(a1) do
        -- If any element is not equal to its counterpart in a2, return false
        if v ~= a2[i] then
            return false
        end
    end

    -- If the loop finishes, all elements were equal
    return true
end

local function BrightenTexture(tex)
    if tex and tex.SetVertexColor then
        --debugPrint("KeepSwiftmendBright: SetVertexColor pre-print:")
        --debugPrint(tex:GetVertexColor())
        --last_texture_value = { tex:GetVertexColor() }
        --debugPrint("KeepSwiftmendBright: last_texture_value:")
        --debugPrint(unpack(last_texture_value))
        tex:SetVertexColor(1, 1, 1)
        --debugPrint("KeepSwiftmendBright: SetVertexColor post-print:")
        --debugPrint(tex:GetVertexColor())
        --current_texture_value = { tex:GetVertexColor() }
        --if not areArraysEqual(last_texture_value, current_texture_value) then            
        --    debugPrint("KSB: event = ", current_event_name, ", Texture changed from ", unpack(last_texture_value))
        --    debugPrint("to ", unpack(current_texture_value))
        --end
    end
    if tex and tex.SetDesaturated then
        tex:SetDesaturated(false)
    end
end

--[[local function ReadTexture(tex)
    print("KeepSwiftmendBright: GetVertexColor:")
    if tex and tex.GetVertexColor then
        print(tex:GetVertexColor())
        --current_texture_value = { tex:GetVertexColor() }
    end
    --if tex and tex.GetDesaturated then
    --    print(tex:GetDesaturated())
    --end
end--]]

------------------------------------------------------------
-- Action Bar
------------------------------------------------------------

local function BrightenActionButtons()
    if ActionButtonUtil and ActionButtonUtil.GetActionButtonBySpellID then
        local btn = ActionButtonUtil.GetActionButtonBySpellID(SWIFTMEND_SPELLID)
        if btn then
            BrightenTexture(btn.icon or btn.iconTexture)
            return
        end
    end

    --[[if ActionBarButtonEventsFrame and ActionBarButtonEventsFrame.frames then
        for _, btn in pairs(ActionBarButtonEventsFrame.frames) do
            if btn and btn.GetSpellId and btn.icon then
                local ok, sid = pcall(btn.GetSpellId, btn)
                if ok and sid == SWIFTMEND_SPELLID then
                    BrightenTexture(btn.icon)
                    return
                end
            end
        end
    end--]]
end

--[[local function ReadActionButtons()
    if ActionButtonUtil and ActionButtonUtil.GetActionButtonBySpellID then
        local btn = ActionButtonUtil.GetActionButtonBySpellID(SWIFTMEND_SPELLID)
        if btn then
            ReadTexture(btn.icon or btn.iconTexture)
            return
        end
    end

    if 0 and ActionBarButtonEventsFrame and ActionBarButtonEventsFrame.frames then
        for _, btn in pairs(ActionBarButtonEventsFrame.frames) do
            if btn and btn.GetSpellId and btn.icon then
                local ok, sid = pcall(btn.GetSpellId, btn)
                if ok and sid == SWIFTMEND_SPELLID then
                    BrightenTexture(btn.icon)
                    return
                end
            end
        end
    end
end--]]

------------------------------------------------------------
-- Cooldown Manager
------------------------------------------------------------

local function FindSwiftmendInCooldownManager()
    local root = _G["EssentialCooldownViewer"]
    if not root or not root.GetChildren then return end

    local children = { root:GetChildren() }
    for _, child in ipairs(children) do
        local iconObj = child.Icon -- or child.icon or child.IconTexture or child.iconTexture
        if iconObj and iconObj.GetTexture then
            local tex = iconObj:GetTexture()
            if tex == SWIFTMEND_FILEID or tostring(tex) == tostring(SWIFTMEND_FILEID) then
                CDM_swiftmend_obj = iconObj
                return
            end
        end
    end
end

local function BrightenCooldownManagerIcons()
    if CDM_swiftmend_obj then
        BrightenTexture(CDM_swiftmend_obj)
    end
end

--[[local function ReadCooldownManagerIcons()
    local root = _G["EssentialCooldownViewer"]
    if not root or not root.GetChildren then return end

    local children = { root:GetChildren() }
    for _, child in ipairs(children) do
        local iconObj = child.Icon or child.icon or child.IconTexture or child.iconTexture
        if iconObj and iconObj.GetTexture then
            local tex = iconObj:GetTexture()
            --if tex == SWIFTMEND_FILEID or tostring(tex) == tostring(SWIFTMEND_FILEID) then
                ReadTexture(iconObj)
            --end
        end
    end
end--]]

------------------------------------------------------------
-- Unified refresh
------------------------------------------------------------

local function DoRefresh()
    BrightenActionButtons()
    BrightenCooldownManagerIcons()
end

------------------------------------------------------------
-- Unified read
------------------------------------------------------------

--[[local function DoRead()
    ReadActionButtons()
    ReadCooldownManagerIcons()
end--]]

------------------------------------------------------------
-- Event driver
------------------------------------------------------------

local f = CreateFrame("Frame")
function f:OnEvent(event, ...)
    if self[event] then
        self[event](self, event, ...)
    else
        otherEvents(event)
    end
end
f:SetScript("OnEvent", f.OnEvent)

f:RegisterEvent("ADDON_LOADED")
--f:RegisterEvent("PLAYER_LOGIN")
--f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
--f:RegisterEvent("CHAT_MSG_CHANNEL")


f:RegisterEvent("SPELL_UPDATE_USABLE")     -- fallback
f:RegisterEvent("UNIT_TARGET")             -- when you or allies change targets
f:RegisterEvent("SPELL_RANGE_CHECK_UPDATE")  --works
f:RegisterEvent("UNIT_AURA")               -- HoTs gained/lost
f:RegisterEvent("SPELL_UPDATE_COOLDOWN")   -- Swiftmend cooldown change

--f:RegisterEvent("PLAYER_TARGET_CHANGED")   -- target swap (common dim cause)
--f:RegisterEvent("ACTIONBAR_UPDATE_USABLE") -- general usability updates
--f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")  -- bar updates (e.g., talent swap)
--f:RegisterEvent("ACTIONBAR_UPDATE_STATE")  -- 
--f:RegisterEvent("UNIT_MANA")               --

--f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN") --works
--f:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")  --works
--f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
--f:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED")
--f:RegisterEvent("PLAYER_SOFT_FRIEND_CHANGED")
--f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
--f:RegisterEvent("GLOBAL_MOUSE_DOWN")
--f:RegisterEvent("GLOBAL_MOUSE_UP")
----f:RegisterEvent("AssistedCombatManager.OnAssistedHighlightSpellChange")
----f:RegisterEvent("ActionButton.OnActionChanged")

function f:ADDON_LOADED(event, addOnName)
    print("KSB: in " .. event .. " for addon:" .. addOnName)
    if addOnName == thisAddonName then
        --self.category, self.layout = Settings.RegisterVerticalLayoutCategory(thisAddonTitle)
        --Settings.RegisterAddOnCategory(self.category)
        FindSwiftmendInCooldownManager()
    end
end

function f:PLAYER_ENTERING_WORLD(event)
    FindSwiftmendInCooldownManager()
end

function f:PLAYER_REGEN_DISABLED(event)
    --FindSwiftmendInCooldownManager()
end

--[[function f:PLAYER_LOGIN(event)
    print("KeepSwiftmendBright: in PLAYER_LOGIN")
    -- Initial scan soon after load (some icons spawn slightly late)
    --C_Timer.After(0.1, DoRefresh)
    --C_Timer.After(0.3, DoRefresh)
end--]]

function otherEvents(event)
    debugPrint("KeepSwiftmendBright: in event: " .. event)
    --current_event_name = event
    DoRefresh()
end

------------------------------------------------------------
-- Manual refresh command
------------------------------------------------------------

SLASH_KEEPSWIFTMENDBRIGHT1 = "/ksb"
SLASH_KEEPSWIFTMENDBRIGHT2 = "/keepswiftmendbright"
--SLASH_KEEPSWIFTMENDBRIGHTREAD1 = "/ksbread"

SlashCmdList.KEEPSWIFTMENDBRIGHT = function()
    if CDM_swiftmend_obj then
        print("KeepSwiftmendBright: Cooldown Manager Swiftmend icon found.")
    else
        print("KeepSwiftmendBright: Cooldown Manager Swiftmend icon NOT found.")
    end
    DoRefresh()
    print("KeepSwiftmendBright: manual refresh executed.")
end

--[[SlashCmdList.KEEPSWIFTMENDBRIGHTREAD = function()
    DoRead()
    print("KeepSwiftmendBright: manual read executed.")
end--]]

--[[
SLASH_KSB1 = "/ksb"
SLASH_KSB2 = "/keepswiftmendbright"

SlashCmdList.KSB = function(msg, editBox)
    Settings.OpenToCategory(f.category:GetID())
end

function KeepSwiftmendBright_OnAddonCompartmentClick(addonName, buttonName, menuButtonFrame)
    Settings.OpenToCategory(f.category:GetID())
end
--]]