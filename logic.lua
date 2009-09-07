local defaultModules = {
	["Spells"] = true,
	["Panels"] = true,
	["Languages"] = true,
	["Inventory"] = true,
	["Companions"] = true,
}

local indizes_priority, indizes_name = {}, {}
local modules, Module = {}, {}
local mt_module = {__index = Module}
local historyCount

Splaunchy.Modules = modules
Splaunchy.Indizes = indizes_priority
Splaunchy.IndizesByName = indizes_name

local function sortFunc(a, b)
	return (a and historyCount[a.name] or 0) > (b and historyCount[b.name] or 0)
end

local function addIndex(index)
	local name = index.name
	if(indizes_name[name]) then return end

	indizes_name[name] = index
	indizes_priority[#indizes_priority+1] = index
	Splaunchy.needsUpdate = true
end

local function removeIndex(index)
	local name = index.name
	if(not indizes_name[name]) then return end

	indizes_name[name] = nil
	for k,v in pairs(indizes_priority) do
		if(v == index) then
			indizes_priority[k] = nil
			return
		end
	end
	Splaunchy.needsUpdate = true
end

--[[##############################
	Splaunchy functions
################################]]

local mt_module_index = {
	__newindex = function(t, key, new)
		local self = t.module
		if(not self.enabled) then return rawset(t, key, new) end
		local old = rawget(t, k)
		rawset(t, key, new)

		if(not new and old) then removeIndex(old) end
		if(new) then addIndex(new) end
	end
}

function Splaunchy:SortIndizes()
	sort(indizes_priority, sortFunc)
end

function Splaunchy:RegisterModule(name)
	local module = setmetatable({}, mt_module)
	module.Indizes = setmetatable({module = module}, mt_module_index)
	modules[name] = module
	module.needInit = true
	return module
end

function Splaunchy:EnableModule(module)
	if(type(module) == "string") then
		module = modules[module]
	end
	if(module.needInit and module.Init) then
		module.needInit = nil
		module:Init()
	end
	module.enabled = true
	for name, index in pairs(module.Indizes) do
		if(name ~= "module") then
			addIndex(index)
		end
	end
end

function Splaunchy:DisableModule(module)
	if(type(module) == "string") then
		module = modules[module]
	end
	module.enabled = nil
	for name, index in pairs(module.Indizes) do
		if(name ~= "module") then
			removeIndex(index)
		end
	end
end

--[[##############################
	Module functions
################################]]

local funcAttributes = {
	type = "macro",
	macrotext = "/script Splaunchy.SelFunction(Splaunchy.SelIndex)",
}

function Module:RegisterIndex(name, index)
	if(type(name) == "table") then
		index = name
		name = index.name
	end

	self.Indizes[name] = index
	if(not index.name) then index.name = name end
	if(not index.match) then index.match = index.name:lower() end
	index.module = self

	if(index.func and not index.attributes) then
		index.attributes = funcAttributes
	end

	return index
end

function Module:GetIndex(name)
	return self.Indizes[name]
end

function Module:RegisterFunction(name, func)
	return self:RegisterIndex{name = name, func = func}
end

function Module:Enable() Splaunchy:EnableModule(self) end
function Module:Disable() Splaunchy:DisableModule(self) end

Splaunchy:RegisterEvent("PLAYER_LOGIN")
Splaunchy:SetScript("OnEvent", function(self)
	SplaunchyHistory = SplaunchyHistory or {}
	historyCount = SplaunchyHistory
	Splaunchy.History = historyCount

	for k,v in pairs(defaultModules) do
		if(v and modules[k]) then
			self:EnableModule(k)
		end
	end
	defaultModules = nil
end)