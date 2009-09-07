local module = Splaunchy:RegisterModule("Companions")

local function callCompanion(index)
	CallCompanion(index.typeID, index.id)
end

local function addCompanionType(typeID)
	for i=1, GetNumCompanions(typeID) do
		local _, name, _, icon = GetCompanionInfo(typeID, i)
		module:RegisterIndex{
			name = name,
			icon = icon,
			func = callCompanion,
			typeID = typeID,
			id = i,
		}
	end
end

function module:Init()
	addCompanionType("MOUNT")
	addCompanionType("CRITTER")
end