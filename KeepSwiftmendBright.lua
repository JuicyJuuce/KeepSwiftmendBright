-- KNOWN BUGS:
--
-- TO DO:

local thisAddonName, ns = ...
local thisAddonTitle = "Keep Swiftmend Bright"

local oldDefaults = {
    someOption = true,
    r = 255/255, g = 200/255, b = 0/255, -- yellow-orange
}

local defaults = {
    recolorOthers = false,
    player = {r = 255/255, g = 200/255, b = 0/255}, -- yellow-orange
    others = {r = 0/255, g = 255/255, b = 0/255}, -- green
}

local function myPrintTable(yourTable, recurseLevel, maxRecurseLevel)
    if type(yourTable) == "table" then
        recurseLevel = recurseLevel or 0
        maxRecurseLevel = maxRecurseLevel or 0
        indentString = string.rep("  ", recurseLevel)    
        for key, value in pairs(yourTable) do
            if type(value) == "table" then
                print(indentString, key.." is table:")
                if (maxRecurseLevel == 0 or recurseLevel < maxRecurseLevel) then
                    myPrintTable(value, recurseLevel + 1, maxRecurseLevel)
                end
            else
                print(indentString, key, value)
            end
        end
    else
        print(indentString, " is not a table.")
    end
end

local function myPrintTable2(yourTable, recurseLevel, maxRecurseLevel, searchString, showParentKey, parentKey)
    if type(yourTable) == "table" then
        --print("myPrintTable2 was sent a table")
        recurseLevel = recurseLevel or 0
        maxRecurseLevel = maxRecurseLevel or 0
        searchString = searchString or ""
        showParentKey = showParentKey or false
        parentKey = showParentKey and (parentKey or "") or ""
        indentString = string.rep("  ", recurseLevel) 
        local stringFound
        for key, value in pairs(yourTable) do
            --print("myPrintTable2 in loop")
            if (searchString ~= "") then
                --print("searchString is ", searchString, ", parentKey is ", parentKey, ", key is ", key)
                stringFound = string.find(indentString, searchString)
            else
                stringFound = nil
            end
            if type(value) == "table" then
                print(indentString, parentKey, key.." is table:")
                if (maxRecurseLevel == 0 or recurseLevel < maxRecurseLevel) then
                    myPrintTable2(value, recurseLevel + 1, maxRecurseLevel, searchString, showParentKey, key)
                end
            elseif (not searchString or (stringFound)) then
                    if (stringFound) then
                        indentString = indentString.."    ---->  "
                    end
                    print(parentKey, indentString, key, value)
            end
        end
    else
        print(indentString, " is not a table.")
    end
end

local function dump(o,level,maxlevel,singleline)
    maxlevel = maxlevel or 0
    level = level or 1
    singleline = singleline or false
    if maxlevel > 0 and level >= maxlevel then
        return ""
    end
    if type(o) == 'table' then
        local s = {}
        s[1] = '{ '
        o_sorted = {}
        for n in pairs(o) do
            table.insert(o_sorted, n)
        end
        --table.sort(o_sorted)
        for i,k in ipairs(o_sorted) do
            local v = o[k]
            if type(k) ~= 'number' then 
                k = '"'..k..'"' 
            end
            s[#s+1] = string.rep('  ',level).. '['..k..'] = ' .. dump(v, level+1, maxlevel, singleline) .. ','
        end
        s[#s+1] = string.rep('  ',level) .. '} '
        if singleline then
            return table.concat(s)
        else
            return table.concat(s , "\n")
        end
    else
        return tostring(o or 'nil')
    end
end

local function myPrintTable3(o, maxlevel, singleline)
    for i in string.gmatch(dump(o,1,maxlevel,singleline), "[^\n]+") do
        print(i)
    end
end

local f = CreateFrame("Frame")
f.category = {}

--[[
local frame = CreateFrame("Frame")
local background = frame:CreateTexture()
background:SetAllPoints(frame)
background:SetColorTexture(1, 0, 1, 0.5)

local category = Settings.RegisterCanvasLayoutCategory(frame, "My AddOn")
Settings.RegisterAddOnCategory(category)
]]

---[[
--[[
KeepSwiftmendBright_RaidFramePreviewMixin = { };

function KeepSwiftmendBright_RaidFramePreviewMixin:OnLoad()
    --print("in KeepSwiftmendBright_RaidFramePreviewMixin:OnLoad()")
    CompactUnitFrame_SetUpFrame(self.RaidFrame, DefaultCompactUnitFrameSetup);
    CompactUnitFrame_SetUnit(self.RaidFrame, "player");
    CompactUnitFrame_SetUpdateAllEvent(self.RaidFrame, "GROUP_ROSTER_UPDATE");

    self.UserColorPreview:SetColorTexture(f.db.player.r, f.db.player.g, f.db.player.b);
    self.OthersColorPreview:SetColorTexture(f.db.others.r, f.db.others.g, f.db.others.b);

    --print("self in KeepSwiftmendBright_RaidFramePreviewMixin:")
    --myPrintTable(self, 0, 1)
    --print("end self in KeepSwiftmendBright_RaidFramePreviewMixin")
--]]
--[[
    CompactUnitFrame_SetUpFrame(self.RaidFrame2, DefaultCompactUnitFrameSetup);
    CompactUnitFrame_SetUnit(self.RaidFrame2, "player");
    CompactUnitFrame_SetUpdateAllEvent(self.RaidFrame2, "GROUP_ROSTER_UPDATE");
end
--]]

--function KeepSwiftmendBright_OnUpdate(self, elapsed)
--end

--[[
function KeepSwiftmendBright_RaidFramePreviewMixin:OnUpdate(elapsed)
    print("in KeepSwiftmendBright_RaidFramePreviewMixin:OnUpdate()")
    self.UserColorPreview:SetColorTexture(f.db.player.r, f.db.player.g, f.db.player.b);
    self.OthersColorPreview:SetColorTexture(f.db.others.r, f.db.others.g, f.db.others.b);
    self.RaidFrame.needsUpdate = true
    self.RaidFrame:TryUpdate()
end
--]]
--[[
function SettingsCategoryListButtonMixin:Init(initializer)
	local category = initializer.data.category;

	self.Label:SetText(category:GetName());
	self.Toggle:SetShown(category:HasSubcategories());
	
	local anyNew = false;
	local layout = SettingsPanel:GetLayout(category);
	if layout and layout:IsVerticalLayout() then
		for _, initializer in layout:EnumerateInitializers() do
			local setting = initializer.data.setting;
			if setting and IsNewSettingInCurrentVersion(setting:GetVariable()) then
				anyNew = true;
				break;
			end
		end
	end

	self.NewFeature.BGLabel:SetPoint("RIGHT", 0.5, -0.5);
	self.NewFeature.Label:SetPoint("RIGHT", 0, 0);
	self.NewFeature:SetShown(anyNew);

	self:SetExpanded(category.expanded);
	self:SetSelected(g_selectionBehavior:IsSelected(self));
end
--]]
function f:doNewADDON_LOADED(event, addOnName)
    KeepSwiftmendBright_SavedVars = KeepSwiftmendBright_SavedVars or CopyTable(defaults)
    --print("printing KeepSwiftmendBright_SavedVars:")
    --myPrintTable3(KeepSwiftmendBright_SavedVars)
    self.db = KeepSwiftmendBright_SavedVars
    --print("in f:doNewADDON_LOADED, printing self.db:")
    --myPrintTable3(self.db)

    local function OnSettingChanged(_, setting, value)
        local variable = setting:GetVariable()
        KeepSwiftmendBright_SavedVars[variable] = value
        --print("print OnSettingsChanged(): KeepSwiftmendBright_SavedVars")
        --myPrintTable3(KeepSwiftmendBright_SavedVars)
    end

    --function Settings.SetupCVarDropdown(category, variable, variableType, options, label, tooltip)

    self.category, self.layout = Settings.RegisterVerticalLayoutCategory(thisAddonTitle)

    --layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(PING_SYSTEM_LABEL));

    --[[
    local function ShowColorPicker(r, g, b, changedCallback)
        local info = {}
        info.r, info.g, info.b = r, g, b
        info.swatchFunc, info.func, info.opacityFunc, info.cancelFunc = changedCallback, changedCallback, changedCallback, changedCallback;
        --print("in ShowColorPicker, info:")
        --myPrintTable3(info)
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end

    local function newRGB(restore)
        if restore then
            -- User canceled (probably)
            return restore.r, restore.g, restore.b
        else
            -- Something changed
            return ColorPickerFrame:GetColorRGB();
        end
    end

    local function userColorCallback(restore)
        -- Update our internal storage.
        local p = self.db.player
        p.r, p.g, p.b = newRGB(restore)
        -- And update any UI elements that use this color...
        -- EventRegistry:TriggerEvent("ActionBarShownSettingUpdated")
        CompactPartyFrame:RefreshMembers()
        CompactRaidFrameContainer:TryUpdate()

        --local data = { };
        --local initializer = Settings.CreatePanelInitializer("KeepSwiftmendBright_RaidFramePreviewTemplate", data);
        --self.layout:AddInitializer(initializer);


        --print("KeepSwiftmendBright_RaidFramePreviewTemplate in userColorCallback: ")
        --myPrintTable3(KeepSwiftmendBright_RaidFramePreviewTemplate)
        --print("end KeepSwiftmendBright_RaidFramePreviewTemplate in userColorCallback")
        --print(KeepSwiftmendBright_RaidFramePreviewTemplate)
        --print("self.OthersColorPreview")
        --myPrintTable3(self.OthersColorPreview)
        --print(" end self.OthersColorPreview")
        --print(self.OthersColorPreview)
        --self.RaidFrame:TryUpdate()
        --print("KeepSwiftmendBright_RaidFramePreviewMixin: ")
        --myPrintTable(KeepSwiftmendBright_RaidFramePreviewMixin, 0, 2)
        --print("self.layout: ")
        --myPrintTable(self.layout, 0, 3)
        --CompactUnitFrameProfiles:ApplyCurrentSettings()
    end

    local function othersColorCallback(restore)
        -- Update our internal storage.
        local o = self.db.others
        o.r, o.g, o.b = newRGB(restore)
        -- And update any UI elements that use this color...
        CompactPartyFrame:RefreshMembers()
        CompactRaidFrameContainer:TryUpdate()
        --self.RaidFrame:TryUpdate()
        --CompactUnitFrameProfiles:ApplyCurrentSettings()
    end
    -- Select user's color
    do
        local function OnButtonClick()
            --print("button: Your Raid Frame Color")
            --print("print self.db:")
            --myPrintTable3(self.db)
            --print("self.layout.settings: ")
            --myPrintTable3(self.layout.settings)
            --print("button: Select Your Color")
            ShowColorPicker(self.db.player.r, self.db.player.g, self.db.player.b, userColorCallback);
            --print("print self.db after ShowColorPicker():")
            --myPrintTable3(self.db)
        end

        local addSearchTags = true;
        local tooltip = "Select the color that you want your own raid frame to be. Note: due to how raid frames are shaded, the result will appear a little darker."
        local initializer = CreateSettingsButtonInitializer("Your Raid Frame Color", "Select Color", OnButtonClick, tooltip, addSearchTags);
        self.layout:AddInitializer(initializer);
    end
    --]]
    --[[
    do
        local setting = Settings.RegisterCVarSetting(category, "showPingsInChat", Settings.VarType.Boolean, SHOW_PINGS_IN_CHAT);
        local function OnButtonClick()
                ShowUIPanel(ChatConfigFrame);
                ChatConfigFrameChatTabManager:UpdateSelection(DEFAULT_CHAT_FRAME:GetID());
        end;
        local initializer = CreateSettingsCheckboxWithButtonInitializer(setting, PING_CHAT_SETTINGS, OnButtonClick, true, OPTION_TOOLTIP_SHOW_PINGS_IN_CHAT);
        local initializer = CreateSettingsCheckboxWithButtonInitializer("Your raid frame color", "Select Color", OnButtonClick, tooltip, addSearchTags);
    end
    ]]
    -- Select other players's color
    --[[
    do
        local function OnButtonClick()
            --print("button: Re-color Other Players")
            --print("print self.db:")
            --myPrintTable3(self.db)
            --print("self.layout.settings: ")
            --print(self.layout.settings)
            ShowColorPicker(self.db.others.r, self.db.others.g, self.db.others.b, othersColorCallback);
        end

        local variable = "recolorOthers"
        local name = "Re-color Other Players"
        local tooltip = "Change the colors of OTHER players' frames. Class colors must be disabled."
        local defaultValue = defaults.recolorOthers
        local value = KeepSwiftmendBright_SavedVars[variable] or defaultValue

        local variableColor = "others"
        local nameColor = "Re-color Other Players"
        local tooltipColor = "The color other players frames will be set to."
        local defaultValueColor = {defaults.othersR, defaults.othersG, defaults.othersB}
        local valueColor = KeepSwiftmendBright_SavedVars[variableColor] or defaultValueColor

        --function Settings.RegisterAddOnSetting(categoryTbl, name, variable, variableType, defaultValue)
		assert(type(KeepSwiftmendBright_SavedVars) == "table", "hey man, 'variableTbl' argument must be a table.");
        local setting = Settings.RegisterAddOnSetting(self.category, variable, variable, KeepSwiftmendBright_SavedVars, type(value), name, defaultValue)
        local settingColor = Settings.RegisterAddOnSetting(self.category, variableColor, variableColor, KeepSwiftmendBright_SavedVars, type(valueColor), nameColor, defaultValueColor)
        --Settings.CreateCheckBox(self.category, setting, tooltip)
        local initializer = CreateSettingsCheckboxWithButtonInitializer(setting, "Select Color", OnButtonClick, true, tooltip) --addSearchTags?
        Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
        self.layout:AddInitializer(initializer);
    end
    --]]
--[[
	do
		local colorText2 = self:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		colorText2:SetText("Yourrrrrrrrrrrrr raid frame color: r = "..self.db.player.r..", g = "..self.db.player.g..", b = "..self.db.player.b);
		colorText2:SetPoint("TOP", bddddddtn, 0, -8);
	end

    do
        local colorText = self:CreateFontString("ARTWORK", nil, "GameFontNormal")
        colorText:SetPoint("TOPLEFT", 0, -40)
        colorText:SetText("Your raiddddddddd frame color: r = "..self.db.player.r..", g = "..self.db.player.g..", b = "..self.db.player.b)
    end

    local splot = CreateFrame('Frame', nil, self);
    splot:SetSize(64, 64);
    splot:SetPoint("TOPLEFT", 0, -100);
    local t = splot:CreateTexture(nil, 'ARTWORK');
    t:SetAllPoints(splot);
    t:SetColorTexture(self.db.player.r, self.db.player.g, self.db.player.b);
--]]
    --[[
    -- Raid Frame Preview
    do
        local data = { };
        local initializer = Settings.CreatePanelInitializer("KeepSwiftmendBright_RaidFramePreviewTemplate", data);
        self.layout:AddInitializer(initializer);
    end
    --]]

    Settings.RegisterAddOnCategory(self.category)
end
--]]

function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("ACTION_USABLE_CHANGED")
f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
f:RegisterEvent("WORLD_CURSOR_TOOLTIP_UPDATE")
--f:RegisterEvent("PLAYER_ENTERING_WORLD")
--f:RegisterEvent("CHAT_MSG_CHANNEL")
f:SetScript("OnEvent", f.OnEvent)

-- this function is the actual meat of the addon
function f:myUpdateHealthColor(frame)
    local unit = frame.unit
    local useClassColors = CVarCallbackRegistry:GetCVarValueBool("raidFramesDisplayClassColor")
    local pvpUseClassColors = CVarCallbackRegistry:GetCVarValueBool("pvpFramesDisplayClassColor")
    --print("useClassColors is ", useClassColors)
    --print("pvpUseClassColors is ", pvpUseClassColors)
    --print('UnitIsFriend(unit, "player") is ', UnitIsFriend(unit, "player"))
    --print('UnitIsEnemy(unit, "player") is ', UnitIsEnemy(unit, "player"))

    -- color user's frame
    if ( UnitIsUnit(unit, "player") ) then
        --print("frame in myUpdateHealthColor:", unit, ", r,g,b = ", r, ",",g,",",b,", recolorOthers = ", self.db.recolorOthers)
        --print("printing frame:")
        --myPrintTable(frame, 0, 1)
        --print("in UnitIsUnit, printing self.db:")
        --myPrintTable3(self.db)
        --print("end")
        local r, g, b = self.db.player.r, self.db.player.g, self.db.player.b
        if ( r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b ) then
            frame.healthBar:SetStatusBarColor(r, g, b);
        end
    -- color other players' frames
    elseif  ( self.db.recolorOthers and not useClassColors and UnitPlayerOrPetInParty(unit) ) then
        local r, g, b = self.db.others.r, self.db.others.g, self.db.others.b
        --print("color other's frame in myUpdateHealthColor:", unit, ", r,g,b = ",r,",",g,",",b,", recolorOthers = ", self.db.recolorOthers)
        --myPrintTable2(frame, 0, 1, "lass", true)
        if ( r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b ) then
            --print("color other's frame in myUpdateHealthColor:", unit, ", r,g,b = ",r,",",g,",",b,", recolorOthers = ", self.db.recolorOthers)
            frame.healthBar:SetStatusBarColor(r, g, b);
        end
    end
end

function f:actuallyMakeSwiftmendBright()
    --print("global table:")
    --myPrintTable2(_G, 0, 1)
    --print("is swiftmend on any active hotbar:", ActionButtonUtil.IsSpellOnAnyActiveActionBar(18562, true, true))
    --print("places where swiftmend was found:")
    --myPrintTable3(C_ActionBar.FindSpellActionButtons(18562))
    local swiftmendButton = ActionButtonUtil.GetActionButtonBySpellID(18562, true, true)
    if swiftmendButton then
        local icon = swiftmendButton.icon
        icon:SetVertexColor(1.0, 1.0, 1.0)
        --icon:SetDesaturated(1)

        --print("swiftmendButton.icon:")
        --myPrintTable3(swiftmendButton.icon, 4)
        --print("swiftmendButton:IsFlashing():", swiftmendButton:IsFlashing())
    end
end

function f:WORLD_CURSOR_TOOLTIP_UPDATE(event, anchorType)
    self:actuallyMakeSwiftmendBright()
    --print("WORLD_CURSOR_TOOLTIP_UPDATE, anchorType:")
    --myPrintTable3(anchorType, 0, true)
end

function f:ACTION_USABLE_CHANGED(event, changes)
    self:actuallyMakeSwiftmendBright()
    --print("ACTION_USABLE_CHANGED, changes:")
    --myPrintTable3(changes, 0, true)
end

function f:ACTIONBAR_SLOT_CHANGED(event, slot)
    self:actuallyMakeSwiftmendBright()
    --print("ACTION_USABLE_CHANGED, changes:")
    --myPrintTable3(changes, 0, true)
end

function f:ADDON_LOADED(event, addOnName)
    if addOnName == thisAddonName then
        print("KeepSwiftmendBright loaded.")
        self:doNewADDON_LOADED(event, addOnName)

        --hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
        --    self:myUpdateHealthColor(frame)
        --end)

        --[[hooksecurefunc(ActionBarActionButtonMixin, "UpdateUsable", function(action, isUsable, notEnoughMana)
            --self:actuallyMakeSwiftmendBright()

            print("hooksecurefunc, icon:")
            --myPrintTable3(icon, 2, false)
            
            --icon:SetVertexColor(1.0, 1.0, 1.0)
        end)--]]
        hooksecurefunc(CooldownViewerCooldownItemMixin, "RefreshIconColor", function()
            --self:actuallyMakeSwiftmendBright()
            iconTexture:SetVertexColor(CooldownViewerConstants.ITEM_USABLE_COLOR:GetRGBA());

            print("hooksecurefunc, icon:")
        end)

    end
end

SLASH_KSB1 = "/ksb"
SLASH_KSB2 = "/keepswiftmendbright"

SlashCmdList.KSB = function(msg, editBox)
    Settings.OpenToCategory(f.category:GetID())
end

function KeepSwiftmendBright_OnAddonCompartmentClick(addonName, buttonName, menuButtonFrame)
    Settings.OpenToCategory(f.category:GetID())
end
