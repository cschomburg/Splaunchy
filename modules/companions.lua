local function addCompanionType(typeID)
	for i=1, GetNumCompanions(typeID) do
		local _, name, _, icon = GetCompanionInfo(typeID, i)
		Splaunchy:RegisterFunction(name, function()
			CallCompanion(typeID, i)
		end).texture = icon
	end
end

addCompanionType("MOUNT")
addCompanionType("CRITTER")