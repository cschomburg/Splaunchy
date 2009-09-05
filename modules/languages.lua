for i=1, GetNumLanguages() do
	local name = GetLanguageByIndex(i)
	Splaunchy:RegisterFunction(name, function()
		ChatFrameEditBox.language = name
		ChatFrame_OpenChat("")
	end)
end