local frames = {
	["Character Pane"] = function() ToggleCharacter("PaperDollFrame") end,
	["Spellbook"] = function() ToggleSpellBook(BOOKTYPE_SPELL) end,
	["Pet Book"] = function() ToggleSpellBook(BOOKTYPE_PET) end,
	["Glyphs"] = ToggleGlyphFrame,
	["Talent Pane"] = ToggleTalentFrame,
	["PVP Pane"] = TogglePVPFrame,
	["Pet Pane"] = function() ToggleCharacter("PetPaperDollFrame") end,
	["Reputation Pane"] = function() ToggleCharacter("ReputationFrame") end,
	["Skill Pane"] = function() ToggleCharacter("SkillFrame") end,
	["Quest Log"] = function() ToggleFrame(QuestLogFrame) end,
	["Game Menu"] = ToggleGameMenu,
	["Friends Frame"] = function() ToggleFriendsFrame(1) end,
	["Who Pane"] = function() ToggleFriendsFrame(2) end,
	["Guild Pane"] = function() ToggleFriendsFrame(3) end,
	["Chat Pane"] = function() ToggleFriendsFrame(4) end,
	["Raid Pane"] = function() ToggleFriendsFrame(5) end,
	["LFG Pane"] = function() ToggleLFGParentFrame(1) end,
	["LFM Pane"] = function() ToggleLFGParentFrame(2) end,
	["Achievement Pane"] = ToggleAchievementFrame,
	["Statistics Pane"] = function() ToggleAchievementFrame(1) end,
	["Currency Pane"] = function() ToggleCharacter("TokenFrame") end,
	["Help Frame"] = function() HelpFrame_ShowFrame("Welcome") end
}

for name, func in pairs(frames) do
	Splaunchy:RegisterFunction(name, func)
end
frames = nil