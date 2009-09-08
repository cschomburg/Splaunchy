BINDING_HEADER_SPLAUNCHY = "Splaunchy"
BINDING_NAME_SPLAUNCHY = "Toggle Splaunchy"

local defaultIcon = [[Interface\Icons\INV_Misc_QuestionMark]]
local defaultIconFound = [[Interface\Icons\Ability_Druid_Eclipse]]

local LAUNCH_TEXT = "|cff00ff00Enter to launch!|r"

local prevAttributes, currIndex, currI, currSearch

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
	local name = currIndex.name
	local history = Splaunchy.History
	history[name] = (history[name] or 0) + 1
	Splaunchy.needsUpdate = true
end)

local icon = button:CreateTexture(nil, "OVERLAY")
icon:SetAllPoints()
local shine = CreateFrame("Frame", "SplaunchyButtonShine", button, "AnimatedShineTemplate")
shine:SetPoint("CENTER")
shine:SetScale(1.6)

local label = button:CreateFontString(nil, "OVERLAY")
label:SetFont("Fonts\\FRIZQT__.TTF", 16)
label:SetTextColor(0, 1, 0)
label:SetPoint("LEFT", Splaunchy, "CENTER", 40, 0)
label:SetPoint("RIGHT", Splaunchy, "RIGHT", -10, 0)
label:SetJustifyH("LEFT")

local editBox = CreateFrame("EditBox", nil, Splaunchy)
editBox:SetPoint("TOPLEFT", 10, 0)
editBox:SetPoint("RIGHT", button, "LEFT", -10, 0)
editBox:SetFont("Fonts\\FRIZQT__.TTF", 20)
editBox:SetAutoFocus(nil)
editBox:SetAltArrowKeyMode(true)
editBox:SetScript("OnEnterPressed", function(self)
	self:ClearFocus()
	if(not currIndex) then
		Splaunchy:Hide()
	else
		AnimatedShine_Start(button, 0, 1, 0)
		editBox:SetText(LAUNCH_TEXT)

		local attributes = currIndex and currIndex.attributes
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

local function setIndex(index, i)
	if(index == currIndex) then return end

	local attributes, tex
	if(index) then
		attributes, tex = index.attributes, index.icon

		if(index.func) then
			Splaunchy.SelFunction = index.func
			Splaunchy.SelIndex = index
		end
	end

	currIndex = index
	currI = i
	icon:SetTexture(tex or (attributes and defaultIconFound) or defaultIcon)
	label:SetText(index and index.name)
end

local function findIndex(text, min, max, step)
	local indizes = Splaunchy.Indizes
	for i=(min or 1), (max or #indizes), (step or 1) do
		local index = indizes[i]
		if(index.match:match(text)) then
			return index, i
		end
	end
end

editBox:SetScript("OnEscapePressed", function() Splaunchy:Hide() end)
editBox:SetScript("OnTextChanged", function()
	local search = editBox:GetText()
	if(search == LAUNCH_TEXT) then return end

	search = search:lower():trim():gsub(" ", "(.-)")
	currSearch = search
	if(search == "") then return setIndex(nil) end

	setIndex(findIndex(search))
end)

local arrowFrame = CreateFrame("Button", "SplaunchyArrowButton")
arrowFrame:SetScript("OnClick", function(self, button)
	local min, max, step
	if(not currI or not currSearch) then return end

	if(button == "LeftButton") then
		min = currI-1
		max = 1
		step = -1
	else
		min = currI+1
	end
	
	local index, i = findIndex(currSearch, min, max, step)
	if(index) then setIndex(index, i) end
end)

Splaunchy:SetScript("OnShow", function(self)
	if(self.needsUpdate) then
		self:SortIndizes()
	end
	editBox:SetText(currSearch or "")
	editBox:HighlightText()
	editBox:SetFocus()

	SetOverrideBindingClick(self, true, "ENTER", "SplaunchyButton", "LeftButton")
	SetOverrideBindingClick(self, true, GetBindingKey("SPLAUNCHY"), "SplaunchyButton", "LeftButton")

	SetOverrideBindingClick(self, true, "UP", "SplaunchyArrowButton", "LeftButton")
	SetOverrideBindingClick(self, true, "DOWN", "SplaunchyArrowButton", "RightButton")

	SetOverrideBinding(self, true, "ESCAPE", "SPLAUNCHY")
	SetOverrideBinding(self, true, "BUTTON1", "SPLAUNCHY")
	SetOverrideBinding(self, true, "BUTTON2", "SPLAUNCHY")
end)

Splaunchy:SetScript("OnHide", function(self)
	AnimatedShine_Stop(button)
	editBox:ClearFocus()
	ClearOverrideBindings(self)
end)