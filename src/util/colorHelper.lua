--[[
	Miscellaneous functions to help with handling colors
]]
return {
	hexToRGBA = function(hexcode)
		hexcode = hexcode:gsub("#","") -- remove pound symbol, if present
		-- extract values in a format love2d can use
		local r = tonumber(hexcode:sub(1,2),16) / 255
		local g = tonumber(hexcode:sub(3,4),16) / 255
		local b = tonumber(hexcode:sub(5,6),16) / 255
		local a = 1
		-- optional alpha
		if #hexcode > 6 then
			a = tonumber(hexcode:sub(7,8),16) / 255
		end
		-- return values
		return {r,g,b,a}
	end
}