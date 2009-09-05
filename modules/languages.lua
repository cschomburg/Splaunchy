local module = Splaunchy:RegisterModule("Languages")

function module:Init()
	for i=1, GetNumLanguages() do
		local name = GetLanguageByIndex(i)
		self:RegisterFunction(name, function()
			ChatFrameEditBox.language = name
			ChatFrame_OpenChat("")
		end)
	end
end
