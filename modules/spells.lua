local function addSpellBook(type)
	local i = 1
	while true do
		local name = GetSpellName(i, type)
		local next = GetSpellName(i+1, type)
		if(not name) then break end
 
		if(name ~= next and not IsPassiveSpell(i, type)) then
			local texture = GetSpellTexture(i, type)
			Splaunchy:RegisterIndex(name, {
				texture = texture,
				attributes = {
					["type"] = "spell",
					["spell"] = name,
				}
			})
		end
		i = i + 1
	end
end

addSpellBook(BOOKTYPE_SPELL)