local defaultModules = {
	["Spells"] = true,
	["Panels"] = true,
	["Languages"] = true,
	["Inventory"] = true,
	["Companions"] = true,
}

BINDING_HEADER_SPLAUNCHY = "Splaunchy"
BINDING_NAME_SPLAUNCHY = "Toggle Splaunchy"

local INDEX_NUM_FIRSTLETTERS = 1

local defaultIcon = [[Interface\Icons\INV_Misc_QuestionMark]]
local defaultIconFound = [[Interface\Icons\Ability_Druid_Eclipse]]

local LAUNCH_TEXT = "|cff00ff00Enter to launch!|r"

local indizes = {}
local modules, Module = {}, {}
local module_mt = {__index = Module}
local prevAttributes, selectedIndex

local Splaunchy = CreateFrame("Frame", "Splaunchy", UIParent)
Splaunchy:SetWidth(430)
Splaunchy:SetHeight(50)
Splaunchy:SetPoint("CENTER")
Splaunchy:SetBackdrop{
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
Splaunchy:SetBackdropColor(0, 0.1, 0.3, 1)
Splaunchy:SetBackdropBorderColor(0.5, 0.7, 1, 1)
Splaunchy:Hide()

Splaunchy.Modules = modules
Splaunchy.Indizes = indizes

local button = CreateFrame("Button", "SplaunchyButton", Splaunchy, "SecureActionButtonTemplate")
button:SetPoint("CENTER")
button:SetWidth(60)
button:SetHeight(60)
button:SetAttribute("type", "action")
button:SetAttribute("action", "1")
button:SetScript("PostClick", function()
	Splaunchy:Hide()
end)

local icon = button:CreateTexture(nil, "OVERLAY")
icon:SetAllPoints()
local shine = CreateFrame("Frame", "SplaunchyButtonShine", button, "AnimatedShineTemplate")
shine:SetPoint("CENTER")
shine:SetScale(1.6)

local label = button:CreateFontString(nil, "OVERLAY")
label:SetFont("Fonts\\FRIZQT__.TTF", 16)
label:SetTextColor(0, 1, 0)
label:SetPoint("LEFT", button, "RIGHT", 10, 0)
label:SetJustifyH("LEFT")

local editBox = CreateFrame("EditBox", nil, Splaunchy)
editBox:SetPoint("TOPLEFT", 10, 0)
editBox:SetPoint("RIGHT", button, "LEFT", -10, 0)
editBox:SetFont("Fonts\\FRIZQT__.TTF", 20)
editBox:SetAutoFocus(nil)
editBox:SetScript("OnEnterPressed", function(self)
	self:ClearFocus()
	if(not selectedIndex) then
		Splaunchy:Hide()
	else
		AnimatedShine_Start(button, 0, 1, 0)
		editBox:SetText(LAUNCH_TEXT)

		local attributes = selectedIndex and selectedIndex.attributes
		if(prevAttributes) then
			for name in pairs(prevAttributes) do
				button:SetAttribute(name, nil)
			end
		end
		if(attributes) then
			for name, value in pairs(attributes) do
				button:SetAttribute(name, value)
			end
		end
		prevAttributes = attributes
	end
end)

local function modifyIndex(name, index)
	if(INDEX_NUM_FIRSTLETTERS > 0) then
		local firstLetter = name:sub(1, INDEX_NUM_FIRSTLETTERS)
		indizes[firstLetter] = indizes[firstLetter] or {}
		indizes[firstLetter][name] = index
	else
		indizes[name] = index
	end
end

local function setIndex(index)
	local attributes, tex
	if(index) then
		attributes, tex = index.attributes, index.texture

		if(index.func) then
			SplaunchyFunction = index.func
		end
	end

	selectedIndex = index
	icon:SetTexture(tex or (attributes and defaultIconFound) or defaultIcon)
	label:SetText(index and index.name)
end

editBox:SetScript("OnEscapePressed", function() Splaunchy:Hide() end)
editBox:SetScript("OnTextChanged", function()
	local search = editBox:GetText()
	if(search == LAUNCH_TEXT) then return end
	if(search == "") then return setIndex(nil) end

	search = search:lower():trim():gsub(" ", "(.-)")
	local matched
	if(INDEX_NUM_FIRSTLETTERS > 0) then
		local firstLetter = search:sub(1, INDEX_NUM_FIRSTLETTERS)
		matched = indizes[firstLetter]
	else
		matched = indizes
	end

	if(matched) then
		for _, index in pairs(matched) do
			if(index.match:match(search)) then
				return selectedIndex ~= index and setIndex(index)
			end
		end
	end
	setIndex(nil)
end)

Splaunchy:SetScript("OnShow", function(self)
	editBox:SetText("")
	editBox:SetFocus()
	SetOverrideBindingClick(self, true, "ENTER", "SplaunchyButton", "LeftButton")
	SetOverrideBindingClick(self, true, GetBindingKey("SPLAUNCHY"), "SplaunchyButton", "LeftButton")

	SetOverrideBinding(self, true, "ESCAPE", "SPLAUNCHY")
	SetOverrideBinding(self, true, "BUTTON1", "SPLAUNCHY")
	SetOverrideBinding(self, true, "BUTTON2", "SPLAUNCHY")
end)

Splaunchy:SetScript("OnHide", function(self)
	AnimatedShine_Stop(button)
	editBox:ClearFocus()
	ClearOverrideBindings(self)
end)

--[[##############################
	Splaunchy functions
################################]]

function Splaunchy:RegisterModule(name)
	local module = setmetatable({}, module_mt)
	module.indizes = {}
	modules[name] = module
	module.needInit = true
	return module
end

function Splaunchy:EnableModule(module)
	if(type(module) == "string") then
		module = modules[module]
	end
	if(module.needInit and module.Init) then
		module:Init()
	end
	module.enabled = true
	for name, index in pairs(module.indizes) do
		modifyIndex(index.match, index)
	end
end

function Splaunchy:DisableModule(module)
	if(type(module) == "string") then
		module = modules[module]
	end
	module.enabled = nil
	for name, index in pairs(module.indizes) do
		modifyIndex(index.match, nil)
	end
end

--[[##############################
	Module functions
################################]]

function Module:RegisterIndex(name, index)
	if(type(name) == "table") then
		index = name
		name = index.name
	end

	self.indizes[name] = index
	if(not index.name) then index.name = name end
	if(not index.match) then index.match = index.name:lower() end
	index.module = self

	self.indizes[name] = index

	if(self.enabled) then
		modifyIndex(index.match, index)
	end
	return index
end

function Module:GetIndex(name)
	return self.indizes[name]
end

function Module:RegisterFunction(name, func)
	local index = {
		name = name,
		func = func,
		attributes = {
			type = "macro",
			macrotext = "/script SplaunchyFunction()"
		}
	}
	return self:RegisterIndex(index)
end

function Module:RegisterLua(name, lua)
	local func = loadstring(lua)
	return self:RegisterFunction(name, func)
end

function Module:Enable() Splaunchy:EnableModule(self) end
function Module:Disable() Splaunchy:DisableModule(self) end

Splaunchy:RegisterEvent("PLAYER_LOGIN")
Splaunchy:SetScript("OnEvent", function(self)
	for k,v in pairs(defaultModules) do
		if(v and modules[k]) then
			self:EnableModule(k)
		end
	end
end)