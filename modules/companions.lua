local module = Splaunchy:RegisterModule("Companions")

local function callCompanion(index)
	CallCompanion(index.typeID, index.id)
end

local function addCompanionType(typeID)
	for i=1, GetNumCompanions(typeID) do
		local _, name, _, icon = GetCompanionInfo(typeID, i)
		local index = module.Indizes[name] or module:RegisterIndex{
			name = name,
			icon = icon,
			func = callCompanion,
			typeID = typeID,
		}
		index.id = i
	end
end

local function update()
	addCompanionType("MOUNT")
	addCompanionType("CRITTER")
end

module:RegisterEvent("PLAYER_LOGIN", update)
module:RegisterEvent("COMPANION_LEARNED", update)