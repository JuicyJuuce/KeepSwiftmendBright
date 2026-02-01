-- KeepSwiftmendBright
-- Keeps Swiftmend bright on action bars and Cooldown Manager
--
-- TO-DO:
--  - Add options panel to configure which icons to brighten
--  - See if multiple Swiftmend buttons on actions bars can be handled
--  - Figure out why memory usage ticks up over time
--  - in SetCooldownManagerHooks(), check if tex is secret

local SWIFTMEND_SPELLID = 18562
local SWIFTMEND_FILEID = 134914     -- Swiftmend icon texture file ID
local thisAddonName, ns = ...
local KSB_DEBUG = 1

local AB_already_hooked = false        -- is action bar already hooked?
local CDM_already_hooked = false       -- is Cooldown Manager already hooked?
--local CDM_swiftmend_obj = nil

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function debugPrint(priority, ...)
    -- priority being low means greater priority
    if KSB_DEBUG >= priority then
        print(...)
    end
end

--[[local function BrightenTexture(tex)
    if tex and tex.SetVertexColor then
        debugPrint(3, "KSB: Brightening texture:", tex)
        --tex:SetVertexColor(1, 1, 1)
        debugPrint(3, "KSB: tex:GetVertexColor = ", tex:GetVertexColor())
    end
    if tex and tex.SetDesaturated then
        --tex:SetDesaturated(false)
    end
end--]]

------------------------------------------------------------
-- Action Bar
------------------------------------------------------------

--[[local function BrightenActionButtons()
    if ActionButtonUtil and ActionButtonUtil.GetActionButtonBySpellID then
        local btn = ActionButtonUtil.GetActionButtonBySpellID(SWIFTMEND_SPELLID)
        if btn then
            --BrightenTexture(btn.icon or btn.iconTexture)
            return
        end
    end
end--]]


------------------------------------------------------------
-- Hooking Cooldown Manager Icon
------------------------------------------------------------

local cdm_vertex_hook_active = false
local cdm_desat_hook_active = false
local function SetCooldownManagerHooks()
    local root = _G["EssentialCooldownViewer"]
    if not root or not root.GetChildren then return end

    local children = { root:GetChildren() }
    for _, child in ipairs(children) do
        local iconObj = child.Icon
        if iconObj and iconObj.GetTexture then
            local tex = iconObj:GetTexture()
            if tex == SWIFTMEND_FILEID or tostring(tex) == tostring(SWIFTMEND_FILEID) then -- check if tex is secret

                debugPrint(1, "KSB: in SetCooldownManagerHooks()")
                if not CDM_already_hooked then
                    hooksecurefunc(iconObj, "SetVertexColor", function(self, r, g, b, a)
                        if not cdm_vertex_hook_active and not (r == 1 and g == 1 and b == 1) then
                            cdm_vertex_hook_active = true
                            iconObj:SetVertexColor(1,1,1)
                            cdm_vertex_hook_active = false
                        end
                    end)
                    hooksecurefunc(iconObj, "SetDesaturated", function(self, desat)
                        if not cdm_desat_hook_active and issecretvalue(desat) or desat ~= false then
                            cdm_desat_hook_active = true
                            iconObj:SetDesaturated(false)
                            cdm_desat_hook_active = false
                        end
                    end)
                    CDM_already_hooked = true
                end

                --CDM_swiftmend_obj = iconObj
                return
            end
        end
    end
end

--[[local function BrightenCooldownManagerIcons()
    debugPrint(3, "KSB: in BCMI(): CDM_swiftmend_obj =", CDM_swiftmend_obj)
    if CDM_swiftmend_obj then
        BrightenTexture(CDM_swiftmend_obj)
    end
end--]]

------------------------------------------------------------
-- Unified refresh
------------------------------------------------------------

--[[local function DoRefresh()
    BrightenActionButtons()
    BrightenCooldownManagerIcons()
end--]]

------------------------------------------------------------
-- Hooking Action Bar button
------------------------------------------------------------

local ab_vertex_hook_active = false
local ab_desat_hook_active = false
local function SetActionBarHooks()
    debugPrint(1, "KSB: in SetActionBarHooks()")
    if not AB_already_hooked then
        local btn = ActionButtonUtil.GetActionButtonBySpellID(SWIFTMEND_SPELLID)
        if btn then
            hooksecurefunc(btn.icon, "SetVertexColor", function(self, r, g, b, a)
                if not ab_vertex_hook_active and not (r == 1 and g == 1 and b == 1) then
                    ab_vertex_hook_active = true
                    btn.icon:SetVertexColor(1,1,1)
                    ab_vertex_hook_active = false
                end
            end)
            hooksecurefunc(btn.icon, "SetDesaturated", function(self, desat)
                if not ab_desat_hook_active and issecretvalue(desat) or desat ~= false then
                    ab_desat_hook_active = true
                    btn:SetDesaturated(false)
                    ab_desat_hook_active = false
                end
            end)
            AB_already_hooked = true
        end
    end
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

--f:RegisterEvent("SPELL_UPDATE_USABLE")     -- fallback
--f:RegisterEvent("UNIT_TARGET")             -- when you or allies change targets
--f:RegisterEvent("SPELL_RANGE_CHECK_UPDATE")  --works
--f:RegisterEvent("UNIT_AURA")               -- HoTs gained/lost
--f:RegisterEvent("SPELL_UPDATE_COOLDOWN")   -- Swiftmend cooldown change

function f:ADDON_LOADED(event, addOnName)
    if addOnName == thisAddonName then
        debugPrint(1, "KSB: in " .. event .. " for addon:" .. addOnName)
        --SetCooldownManagerHooks()
    end
end

function f:PLAYER_ENTERING_WORLD(event)
    -- Initial scan soon after load (some icons spawn slightly late)
    --C_Timer.After(0.1, DoRefresh)
    --C_Timer.After(0.3, DoRefresh)

    debugPrint(2, "SWIFTMEND_SPELLID =", SWIFTMEND_SPELLID)
    debugPrint(2, "SWIFTMEND_FILEID =", SWIFTMEND_FILEID)
    debugPrint(2, "thisAddonName =", thisAddonName)
    debugPrint(2, "ns =", ns)
    debugPrint(2, "KSB_DEBUG =", KSB_DEBUG)
    --debugPrint(2, "CDM_swiftmend_obj =", CDM_swiftmend_obj)
    --CDM_swiftmend_obj = nil
    SetActionBarHooks()
    SetCooldownManagerHooks()
    --C_Timer.After(5, SetCooldownManagerHooks)
end

function f:PLAYER_REGEN_DISABLED(event)
    --SetCooldownManagerHooks()
end

function otherEvents(event)
    debugPrint(3, "KeepSwiftmendBright: in event: " .. event)
    --DoRefresh()
end

------------------------------------------------------------
-- Manual refresh command
------------------------------------------------------------

--[[SLASH_KEEPSWIFTMENDBRIGHT1 = "/ksb"
SLASH_KEEPSWIFTMENDBRIGHT2 = "/keepswiftmendbright"

SlashCmdList.KEEPSWIFTMENDBRIGHT = function()
    if CDM_swiftmend_obj then
        debugPrint(1, "KeepSwiftmendBright: Cooldown Manager Swiftmend icon found.")
    else
        debugPrint(1, "KeepSwiftmendBright: Cooldown Manager Swiftmend icon NOT found.")
    end
    DoRefresh()
    debugPrint(0, "KeepSwiftmendBright: manual refresh executed.")
end--]]
