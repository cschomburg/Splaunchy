BINDING_HEADER_SPLAUNCHY = "Splaunchy"
BINDING_NAME_SPLAUNCHY = "Toggle Splaunchy"

local NUM_RESULTS = 5

local defaultIcon = [[Interface\Icons\INV_Misc_QuestionMark]]
local defaultIconFound = [[Interface\Icons\Ability_Druid_Eclipse]]

local LAUNCH_TEXT = "|cff00ff00Enter to launch!|r"

local prevAttributes, currIndex, currI, currSearch

local backdrop = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local Splaunchy = CreateFrame("Frame", "Splaunchy", UIParent)
Splaunchy:SetWidth(430)
Splaunchy:SetHeight(50)
Splaunchy:SetPoint("CENTER")
Splaunchy:SetBackdrop(backdrop)
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
	if(not currIndex) then return end
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

local prev
for i=1, NUM_RESULTS do
	local frame = CreateFrame("Frame", nil, Splaunchy)
	frame:SetWidth(250)
	frame:SetHeight(35)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0.1, 0.3, 1)
	frame:SetBackdropBorderColor(0.5, 0.7, 1, 1)
	frame:SetPoint("TOP", prev or Splaunchy, "BOTTOM", 0, 4)

	local icon = frame:CreateTexture(nil, "OVERLAY")
	icon:SetWidth(25)
	icon:SetHeight(25)
	icon:SetPoint("RIGHT", -5, 0)
	icon:SetTexture(defaultIcon)
	frame.Icon = icon

	local label = frame:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(GameFontHighlight)
	label:SetPoint("LEFT", 10, 0)
	label:SetPoint("RIGHT", icon, "LEFT")
	label:SetText("omgwtfbbq!")
	label:SetJustifyH("LEFT")
	frame.Label = label

	Splaunchy[i] = frame

	prev = frame
end

local function findIndex(text, min, max, step)
	text = text:lower():trim():gsub(" ", "(.-)")
	local indizes = Splaunchy.Indizes
	for i=(min or 1), (max or #indizes), (step or 1) do
		local index = indizes[i]
		if(index.match:match(text)) then
			return index, i
		end
	end
end

local function setIndex(index, i)
	if(index and index.func) then
		Splaunchy.SelFunction = index.func
		Splaunchy.SelIndex = index
	end

	currIndex = index
	currI = i
	icon:SetTexture(index and (index.icon or defaultIconFound) or defaultIcon)
	label:SetText(index and index.name)

	for row=1, NUM_RESULTS do
		if(index) then
			index, i = findIndex(currSearch, i+1)
			local frame = Splaunchy[row]
			if(index) then
				frame:Show()
				frame.Label:SetText(index.name)
				frame.Icon:SetTexture(index and (index.icon or defaultIconFound) or defaultIcon)
			else
				frame:Hide()
			end
		else
			Splaunchy[row]:Hide()
		end
	end
end

local function lockText()
	editBox:ClearFocus()
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
end

local function reset()
	AnimatedShine_Stop(button)
	editBox:SetText(currSearch or "")
	editBox:SetFocus()
end

editBox:SetScript("OnEnterPressed", lockText)
editBox:SetScript("OnTabPressed", lockText)
editBox:SetScript("OnEscapePressed", function() Splaunchy:Hide() end)
editBox:SetScript("OnTextChanged", function()
	local search = editBox:GetText()
	if(search == LAUNCH_TEXT) then return end

	currSearch = search
	if(search == "") then return setIndex(nil) end

	local index, i = findIndex(search)
	setIndex(index, i)
end)

CreateFrame("Button", "SplaunchyArrowButton"):SetScript("OnClick", function(self, button)
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

CreateFrame("Button", "SplaunchyAdditionalButton"):SetScript("OnClick", reset)

Splaunchy:SetScript("OnShow", function(self)
	if(self.needsUpdate) then
		self:SortIndizes()
	end

	reset()
	editBox:HighlightText()

	SetOverrideBindingClick(self, true, "ENTER", "SplaunchyButton", "LeftButton")
	SetOverrideBindingClick(self, true, "TAB", "SplaunchyAdditionalButton", "LeftButton")

	SetOverrideBindingClick(self, true, GetBindingKey("SPLAUNCHY"), "SplaunchyButton", "LeftButton")

	SetOverrideBindingClick(self, true, "UP", "SplaunchyArrowButton", "LeftButton")
	SetOverrideBindingClick(self, true, "DOWN", "SplaunchyArrowButton", "RightButton")

	SetOverrideBinding(self, true, "ESCAPE", "SPLAUNCHY")
	SetOverrideBinding(self, true, "BUTTON1", "SPLAUNCHY")
	SetOverrideBinding(self, true, "BUTTON2", "SPLAUNCHY")
end)

Splaunchy:SetScript("OnHide", function(self)
	editBox:ClearFocus()
	ClearOverrideBindings(self)
end)

Splaunchy:RegisterEvent("PLAYER_REGEN_DISABLED")
Splaunchy:SetScript("OnEvent", Splaunchy.Hide)