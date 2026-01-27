-- KeepSwiftmendBright
-- Keeps Swiftmend bright on action bars and Cooldown Manager
--
-- TO-DO:
--  - Add options panel to configure which icons to brighten
--  - See if multiple Swiftmend buttons on actions bars can be handled
--  - Figure out why memory usage ticks up over time
--  - in FindSwiftmendInCooldownManager(), check if tex is secret

local SWIFTMEND_SPELLID = 18562
local SWIFTMEND_FILEID = 134914     -- Swiftmend icon texture file ID
local thisAddonName, ns = ...
local KSB_DEBUG = false

local CDM_swiftmend_obj = nil

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function debugPrint(...)
    if KSB_DEBUG then
        print(...)
    end
end

local function BrightenTexture(tex)
    if tex and tex.SetVertexColor then
        debugPrint("KSB: Brightening texture:", tex)
        tex:SetVertexColor(1, 1, 1)
        debugPrint("KSB: tex:GetVertexColor = ", tex:GetVertexColor())
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
        local btn = ActionButtonUtil.GetActionButtonBySpellID(SWIFTMEND_SPELLID)
        if btn then
            BrightenTexture(btn.icon or btn.iconTexture)
            return
        end
    end
end

------------------------------------------------------------
-- Cooldown Manager
------------------------------------------------------------

local function FindSwiftmendInCooldownManager()
    local root = _G["EssentialCooldownViewer"]
    if not root or not root.GetChildren then return end

    local children = { root:GetChildren() }
    for _, child in ipairs(children) do
        local iconObj = child.Icon
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
    debugPrint("KSB: in BCMI(): CDM_swiftmend_obj =", CDM_swiftmend_obj)
    if CDM_swiftmend_obj then
        BrightenTexture(CDM_swiftmend_obj)
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

function f:OnEvent(event, ...)
    if self[event] then
        self[event](self, event, ...)
    else
        otherEvents(event)
    end
end

f:SetScript("OnEvent", f.OnEvent)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_DISABLED")

f:RegisterEvent("SPELL_UPDATE_USABLE")     -- fallback
f:RegisterEvent("UNIT_TARGET")             -- when you or allies change targets
f:RegisterEvent("SPELL_RANGE_CHECK_UPDATE")  --works
f:RegisterEvent("UNIT_AURA")               -- HoTs gained/lost
f:RegisterEvent("SPELL_UPDATE_COOLDOWN")   -- Swiftmend cooldown change

function f:ADDON_LOADED(event, addOnName)
    if addOnName == thisAddonName then
        print("KSB: in " .. event .. " for addon:" .. addOnName)
        --FindSwiftmendInCooldownManager()
    end
end

function f:PLAYER_ENTERING_WORLD(event)
    -- Initial scan soon after load (some icons spawn slightly late)
    --C_Timer.After(0.1, DoRefresh)
    --C_Timer.After(0.3, DoRefresh)

    print("SWIFTMEND_SPELLID =", SWIFTMEND_SPELLID)
    print("SWIFTMEND_FILEID =", SWIFTMEND_FILEID)
    print("thisAddonName =", thisAddonName)
    print("ns =", ns)
    print("KSB_DEBUG =", KSB_DEBUG)
    print("CDM_swiftmend_obj =", CDM_swiftmend_obj)

    --CDM_swiftmend_obj = nil
    C_Timer.After(3, FindSwiftmendInCooldownManager)
    --FindSwiftmendInCooldownManager()
end

function f:PLAYER_REGEN_DISABLED(event)
    --FindSwiftmendInCooldownManager()
end

function otherEvents(event)
    debugPrint("KeepSwiftmendBright: in event: " .. event)
    DoRefresh()
end

------------------------------------------------------------
-- Manual refresh command
------------------------------------------------------------

SLASH_KEEPSWIFTMENDBRIGHT1 = "/ksb"
SLASH_KEEPSWIFTMENDBRIGHT2 = "/keepswiftmendbright"

SlashCmdList.KEEPSWIFTMENDBRIGHT = function()
    if CDM_swiftmend_obj then
        print("KeepSwiftmendBright: Cooldown Manager Swiftmend icon found.")
    else
        print("KeepSwiftmendBright: Cooldown Manager Swiftmend icon NOT found.")
    end
    DoRefresh()
    print("KeepSwiftmendBright: manual refresh executed.")
end
