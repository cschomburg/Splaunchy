BINDING_HEADER_SPLAUNCHY = "Splaunchy"
BINDING_NAME_SPLAUNCHY = "Toggle Splaunchy"

local defaultIcon = [[Interface\Icons\INV_Misc_QuestionMark]]
local defaultIconFound = [[Interface\Icons\Ability_Druid_Eclipse]]

local ENTER_TO_START = "|cff00ff00Enter to start!|r"

local Splaunchy = CreateFrame("Frame", "Splaunchy", UIParent)
Splaunchy:SetWidth(400)
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
button:SetWidth(30)
button:SetHeight(30)
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
--label:SetPoint("RIGHT", Splaunchy, "LEFT", -10, 0)
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
		editBox:SetText(ENTER_TO_START)
	end
end)
editBox:SetScript("OnEscapePressed", function() Splaunchy:Close() end)
editBox:SetScript("OnTextChanged", function()
	local search = editBox:GetText()
	if(search == ENTER_TO_START) then return end
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
	Splaunchy:Show()
	editBox:SetFocus()
	SetOverrideBindingClick(Splaunchy, true, "ENTER", "SplaunchyButton", "LeftButton")
	SetOverrideBindingClick(Splaunchy, true, GetBindingKey("SPLAUNCHY"), "SplaunchyButton", "LeftButton")
	SetOverrideBinding(Splaunchy, true, "ESCAPE", "SPLAUNCHY")
end

function Splaunchy:Close()
	AnimatedShine_Stop(button)
	Splaunchy:Hide()
	editBox:ClearFocus()
	ClearOverrideBindings(Splaunchy)
end

function Splaunchy:Set(index)
	local type, action, tex
	if(index) then
		type, attributes, tex = index.type, index.attributes or {}, index.texture

		if(index.func) then
			SplaunchyFunction = index.func
		end
	end

	Splaunchy.Index = index
	button:SetAttribute("type", type)
	icon:SetTexture(tex or (type and defaultIconFound) or defaultIcon)
	label:SetText(index and index.name)
	if(attributes) then
		for name, value in pairs(attributes) do
			button:SetAttribute(name, value)
		end
	end
end

indizes[#indizes+1] = {
	name = "Leatherworking",
	type = "spell",
	texture = "Interface\\Icons\\INV_Misc_ArmorKit_17",
	attributes = {
		["spell"] = "Leatherworking",
	},
}



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
		type = "macro",
		func = func,
		attributes = {
			macrotext = "/script SplaunchyFunction()"
		}
	}
	return self:RegisterIndex(name, index)
end

function Splaunchy:RegisterLua(name, lua)
	local func = loadstring(lua)
	return self:RegisterFunction(name, func)
end