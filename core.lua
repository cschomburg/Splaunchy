BINDING_HEADER_SPLAUNCHY = "Splaunchy"
BINDING_NAME_SPLAUNCHY = "Toggle Splaunchy"

local defaultIcon = [[Interface\Icons\INV_Misc_QuestionMark]]
local defaultIconFound = [[Interface\Icons\Ability_Druid_Eclipse]]

local LAUNCH_TEXT = "|cff00ff00Enter to launch!|r"

local indizes = {}
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
editBox:SetAltArrowKeyMode(true)
editBox:SetScript("OnEnterPressed", function(self)
	self:ClearFocus()
	if(not selectedIndex) then
		Splaunchy:Hide()
	else
		AnimatedShine_Start(button, 0, 1, 0)
		editBox:SetText(LAUNCH_TEXT)
	end
end)

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

editBox:SetScript("OnEscapePressed", function() Splaunchy:Hide() end)
editBox:SetScript("OnTextChanged", function()
	local search = editBox:GetText()
	if(search == LAUNCH_TEXT) then return end
	if(search == "") then return setIndex(nil) end

	search = search:lower()
	local firstLetter = search:sub(1,2)
	local matched = indizes[firstLetter]
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
	SetOverrideBindingClick(self, true, "RIGHT", "SplaunchyButton", "LeftButton")
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

function Splaunchy:RegisterIndex(name, index)
	local firstLetter = name:sub(1, 2):lower()
	if(not indizes[firstLetter]) then indizes[firstLetter] = {} end
	indizes[firstLetter][name] = index
	if(not index.name) then index.name = name end
	if(not index.match) then index.match = index.name:lower() end
	return index
end
function Splaunchy:GetIndex(name)
	local firstLetter = name:sub(1, 2):lower()
	return indizes[firstLetter] and indizes[firstLetter][name]
end

function Splaunchy:RegisterFunction(name, func)
	local index = {
		func = func,
		attributes = {
			type = "macro",
			macrotext = "/script SplaunchyFunction()"
		}
	}
	return self:RegisterIndex(name, index)
end

function Splaunchy:RegisterLua(name, lua)
	local func = loadstring(lua)
	return self:RegisterFunction(name, func)
end