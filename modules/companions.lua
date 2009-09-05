local module = Splaunchy:RegisterModule("Companions")

local function addCompanionType(typeID)
	for i=1, GetNumCompanions(typeID) do
		local _, name, _, icon = GetCompanionInfo(typeID, i)
		module:RegisterIndex{
			name = name,
			texture = icon,
			func = function()
				CallCompanion(typeID, i)
			end
		}
	end
end

addCompanionType("MOUNT")
addCompanionType("CRITTER")