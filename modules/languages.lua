local module = Splaunchy:RegisterModule("Languages")

local function switchLanguage(index)
	ChatFrameEditBox.language = index.name
	ChatFrame_OpenChat("")
end

function module:Init()
	for i=1, GetNumLanguages() do
		local name = GetLanguageByIndex(i)
		local index = self:RegisterFunction(name, switchLanguage)
	end
end
