-- KeepSwiftmendBright
-- Keeps Swiftmend bright on action bars and Cooldown Manager
--
-- TO-DO:
--  - Add options panel to configure which icons to brighten
--  - Add option to allow desaturation (black & white when on cooldown)
--  - Allow multiple Swiftmend buttons on actions bars can be handled
--  - might need to in SetCooldownManagerHooks() check if tex is secret

local SWIFTMEND_SPELLID = 18562
local SWIFTMEND_FILEID = 134914     -- Swiftmend icon texture file ID
--local thisAddonName, ns = ...
local KSB_DEBUG = 0

local ab_already_hooked = false        -- is action bar already hooked?
local cdm_already_hooked = false       -- is Cooldown Manager already hooked?

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function debugPrint(priority, ...)
    -- priority being low means greater priority
    if KSB_DEBUG >= priority then
        print(...)
    end
end

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
            if tex == SWIFTMEND_FILEID or tostring(tex) == tostring(SWIFTMEND_FILEID) then -- check if tex is secret?
                debugPrint(1, "KSB: in SetCooldownManagerHooks()")
                if not cdm_already_hooked then
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
                    cdm_already_hooked = true
                end
                return
            end
        end
    end
end

------------------------------------------------------------
-- Hooking Action Bar button
------------------------------------------------------------

local ab_vertex_hook_active = false
local ab_desat_hook_active = false
local function SetActionBarHooks()
    debugPrint(1, "KSB: in SetActionBarHooks()")
    if not ab_already_hooked then
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
            ab_already_hooked = true
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
    end
end

f:SetScript("OnEvent", f.OnEvent)
f:RegisterEvent("PLAYER_ENTERING_WORLD")

function f:PLAYER_ENTERING_WORLD(event)
    SetActionBarHooks()
    SetCooldownManagerHooks()
end
