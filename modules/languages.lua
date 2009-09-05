local module = Splaunchy:RegisterModule("Languages")

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function()
	for i=1, GetNumLanguages() do
		local name = GetLanguageByIndex(i)
		module:RegisterFunction(name, function()
			ChatFrameEditBox.language = name
			ChatFrame_OpenChat("")
		end)
	end
end)
frame:RegisterEvent("PLAYER_LOGIN")