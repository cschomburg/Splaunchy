local module = Splaunchy:RegisterModule("Macros")

function module:Init()
	for i=1, GetNumMacros() do
		local name, icon = GetMacroInfo(i)
		if(not self.Indizes[name]) then
			self:RegisterIndex{
				name = name,
				icon = icon,
				attributes = {
					type = "macro",
					macro = name,
				}
			}
		end
	end
end