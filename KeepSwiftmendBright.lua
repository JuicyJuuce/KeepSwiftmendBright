-- KeepSwiftmendBright — Event-only Build
-- Keeps Swiftmend bright on action bars and EssentialCooldownViewer
-- Uses only WoW events (no hooksecurefunc, no timers).

local SPELL_ID = 18562              -- Swiftmend
local SWIFTMEND_FILEID = 134914     -- Swiftmend icon texture file ID
--local thisAddonName, ns = ...
--local thisAddonTitle = "Keep Swiftmend Bright"

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function BrightenTexture(tex)
    if tex and tex.SetVertexColor then
        tex:SetVertexColor(1, 1, 1)
    end
    if tex and tex.SetDesaturated then
        tex:SetDesaturated(false)
    end
end

------------------------------------------------------------
-- Action Bar
------------------------------------------------------------

local function BrightenActionButtons()
    if ActionButtonUtil and ActionButtonUtil.GetActionButtonBySpellID then
        local btn = ActionButtonUtil.GetActionButtonBySpellID(SPELL_ID)
        if btn then
            BrightenTexture(btn.icon or btn.iconTexture)
            return
        end
    end

    if 0 and ActionBarButtonEventsFrame and ActionBarButtonEventsFrame.frames then
        for _, btn in pairs(ActionBarButtonEventsFrame.frames) do
            if btn and btn.GetSpellId and btn.icon then
                local ok, sid = pcall(btn.GetSpellId, btn)
                if ok and sid == SPELL_ID then
                    BrightenTexture(btn.icon)
                    return
                end
            end
        end
    end
end

------------------------------------------------------------
-- Cooldown Manager
------------------------------------------------------------

local function BrightenCooldownManagerIcons()
    local root = _G["EssentialCooldownViewer"]
    if not root or not root.GetChildren then return end

    local children = { root:GetChildren() }
    for _, child in ipairs(children) do
        local iconObj = child.Icon or child.icon or child.IconTexture or child.iconTexture
        if iconObj and iconObj.GetTexture then
            local tex = iconObj:GetTexture()
            if tex == SWIFTMEND_FILEID or tostring(tex) == tostring(SWIFTMEND_FILEID) then
                BrightenTexture(iconObj)
            end
        end
    end
end

------------------------------------------------------------
-- Unified refresh
------------------------------------------------------------

local function DoRefresh()
    BrightenActionButtons()
    BrightenCooldownManagerIcons()
end

------------------------------------------------------------
-- Event driver
------------------------------------------------------------

local f = CreateFrame("Frame")
--f:RegisterEvent("ADDON_LOADED")
--f:RegisterEvent("PLAYER_LOGIN")
--f:RegisterEvent("PLAYER_TARGET_CHANGED")   -- target swap (common dim cause)
--f:RegisterEvent("UNIT_AURA")               -- HoTs gained/lost
--f:RegisterEvent("SPELL_UPDATE_COOLDOWN")   -- Swiftmend cooldown change
--f:RegisterEvent("ACTIONBAR_UPDATE_USABLE") -- general usability updates
f:RegisterEvent("SPELL_UPDATE_USABLE")     -- fallback
--f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")  -- bar updates (e.g., talent swap)

f:SetScript("OnEvent", function(_, event)

    if event == "asdfADDON_LOADED" then
        if addOnName == thisAddonName then -- need addOnName passed to this function
            self.category, self.layout = Settings.RegisterVerticalLayoutCategory(thisAddonTitle)
            Settings.RegisterAddOnCategory(self.category)
        end
    elseif event == "asdfPLAYER_LOGIN" then
        -- Initial scan soon after load (some icons spawn slightly late)
        C_Timer.After(0.1, DoRefresh)
        C_Timer.After(0.3, DoRefresh)
    else
        DoRefresh()
    end
end)

------------------------------------------------------------
-- Manual refresh command
------------------------------------------------------------

SLASH_KEEPSWIFTMENDBRIGHT1 = "/ksb"
SLASH_KEEPSWIFTMENDBRIGHT2 = "/keepswiftmendbright"

SlashCmdList.KEEPSWIFTMENDBRIGHT = function()
    DoRefresh()
    print("KeepSwiftmendBright: manual refresh executed (event-only build).")
end

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