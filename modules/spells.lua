local module = Splaunchy:RegisterModule("Spells")

local function addSpellBook(type)
	local i = 1
	while true do
		local name = GetSpellName(i, type)
		local next = GetSpellName(i+1, type)
		if(not name) then break end
 
		if(not module.Indizes[name] and name ~= next and not IsPassiveSpell(i, type)) then
			local texture = GetSpellTexture(i, type)

			module:RegisterIndex{
				name = name,
				icon = texture,
				attributes = {
					["type"] = "spell",
					["spell"] = name,
				}
			}
		end
		i = i + 1
	end
end

local function update()
	addSpellBook(BOOKTYPE_SPELL)
end

module:RegisterEvent("SPELLS_CHANGED", update)
module:RegisterEvent("PLAYER_LOGIN", update)