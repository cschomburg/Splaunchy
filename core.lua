BINDING_HEADER_SPLAUNCHY = "Splaunchy"
BINDING_NAME_SPLAUNCHY = "Toggle Splaunchy"

local defaultIcon = [[Interface\Icons\INV_Misc_QuestionMark]]
local defaultIconFound = [[Interface\Icons\Ability_Druid_Eclipse]]

local LAUNCH_TEXT = "|cff00ff00Enter to launch!|r"

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

local indizes = {}

local button = CreateFrame("Button", "SplaunchyButton", Splaunchy, "SecureActionButtonTemplate")
button:SetPoint("CENTER")
button:SetWidth(60)
button:SetHeight(60)
button:SetAttribute("type", "action")
button:SetAttribute("action", "1")
button:SetScript("PostClick", function()
	Splaunchy:Close()
end)

local icon = button:CreateTexture(nil, "OVERLAY")
icon:SetAllPoints()
local shine = CreateFrame("Frame", "SplaunchyButtonShine", button, "AnimatedShineTemplate")
shine:SetPoint("CENTER")
shine:SetScale(0.8)

local label = button:CreateFontString(nil, "OVERLAY")
label:SetFont("Fonts\\FRIZQT__.TTF", 16)
label:SetTextColor(0, 1, 0)
label:SetPoint("LEFT", button, "RIGHT", 10, 0)
label:SetPoint("RIGHT", Splaunchy, "LEFT", -10, 0)
label:SetJustifyH("LEFT")

local editBox = CreateFrame("EditBox", nil, Splaunchy)
editBox:SetPoint("TOPLEFT", 10, 0)
editBox:SetPoint("RIGHT", button, "LEFT", -10, 0)
editBox:SetFont("Fonts\\FRIZQT__.TTF", 20)
editBox:SetAutoFocus(nil)
editBox:SetScript("OnEnterPressed", function(self)
	self:ClearFocus()
	if(not Splaunchy.Index) then
		Splaunchy:Close()
	else
		AnimatedShine_Start(button, 0, 1, 0)
		editBox:SetText(LAUNCH_TEXT)
	end
end)
editBox:SetScript("OnEscapePressed", function() Splaunchy:Close() end)
editBox:SetScript("OnTextChanged", function()
	local search = editBox:GetText()
	if(search == LAUNCH_TEXT) then return end
	if(search == "") then return Splaunchy:Set(nil) end

	search = search:lower()
	local firstLetter = search:sub(1,2)
	local matched = indizes[firstLetter]
	if(matched) then
		for _, index in pairs(matched) do
			if(index.match:match(search)) then
				return Splaunchy.Index ~= index and Splaunchy:Set(index)
			end
		end
	end
	Splaunchy:Set(nil)
end)

function Splaunchy:Open()
	editBox:SetText("")
	self:Show()
	editBox:SetFocus()
	SetOverrideBindingClick(Splaunchy, true, "ENTER", "SplaunchyButton", "LeftButton")
	SetOverrideBindingClick(Splaunchy, true, GetBindingKey("SPLAUNCHY"), "SplaunchyButton", "LeftButton")
	SetOverrideBinding(Splaunchy, true, "ESCAPE", "SPLAUNCHY")
end

function Splaunchy:Close()
	AnimatedShine_Stop(button)
	self:Hide()
	editBox:ClearFocus()
	ClearOverrideBindings(Splaunchy)
end

function Splaunchy:Set(index)
	local attributes, tex
	if(index) then
		attributes, tex = index.attributes, index.texture

		if(index.func) then
			SplaunchyFunction = index.func
		end
	end

	self.Index = index
	icon:SetTexture(tex or (attributes and defaultIconFound) or defaultIcon)
	label:SetText(index and index.name)

	if(self.prevAttributes) then
		for name in pairs(prevAttributes) do
			button:SetAttribute(name, nil)
		end
	end
	if(attributes) then
		for name, value in pairs(attributes) do
			button:SetAttribute(name, value)
		end
	end
	self.prevAttributes = attributes
end

function Splaunchy:RegisterIndex(name, index)
	local firstLetter = name:sub(1, 2)
	if(not indizes[firstLetter]) then indizes[firstLetter] = {} end
	indizes[firstLetter][name] = index
	if(not index.name) then index.name = name end
	if(not index.match) then index.match = index.name:lower() end
	return index
end
function Splaunchy:GetIndex(name)
	local firstLetter = name:sub(1, 2)
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