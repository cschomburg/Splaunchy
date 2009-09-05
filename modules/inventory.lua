local module = Splaunchy:RegisterModule("Inventory")

local frame = CreateFrame"Frame"
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", function()
	for bagID = 0, 4 do
		for slotID = 1, GetContainerNumSlots(bagID) do
			
		end
	end
end)