local module = Splaunchy:RegisterModule("DataBroker")
local LDB = LibStub("LibDataBroker-1.1")

local function clickBroker(index)
	if(not index.onClick) then return end
	index.onClick(Splaunchy, "LeftButton")
end

local function updateObject(event, name, attr, value, dataobj)
	local index = module.Indizes[name]
	if(index) then
		debug(name, attr)
		index.icon = dataobj.icon
		index.onClick = dataobj.OnClick
	end
end

local function initObject(event, name, dataobj)
	if(dataobj.type ~= "launcher") then return end
	module:RegisterIndex{
		name = name,
		icon = dataobj.icon,
		func = clickBroker,
		onClick = dataobj.OnClick,
	}
	LDB.RegisterCallback(module, "LibDataBroker_AttributeChanged_"..name, updateObject)
end

for name, dataobj in LDB:DataObjectIterator() do
	initObject(nil, name, dataobj)
end
LDB.RegisterCallback(module, "LibDataBroker_DataObjectCreated", initObject)
