local font = love.graphics.getFont()

local EFFECTS = {["^"] = true,["*"]=true,["_"]=true}

return function(text,x,y,characters_shown,max_width)

	local x1 = x
	local y1 = y
	local effectsTable = {}
	local lastChar = ""
	local numRenderedCharacters = 0

	for i=1,#text do

		-- only render up to a point
		if numRenderedCharacters > characters_shown then return end

		-- get character
		local c = text:sub(i,i)

		-- newline and control characters
		if c == "\n" then

			x = x1
			y = y + font:getHeight(lastChar)
			
		elseif EFFECTS[c] then -- effect chars, toggle an effect
			effectsTable[c] = not effectsTable[c]

		else -- normal text

			local xo, yo = 0, 0

			if effectsTable["^"] then -- wave
				yo = math.sin(love.timer.getTime()*8 + numRenderedCharacters) * 2
			elseif effectsTable["*"] then -- shaky
				yo = (love.math.random()-0.5)*1.5
				xo = (love.math.random()-0.5)*1.5
			elseif effectsTable["_"] then -- bold
				love.graphics.print(c,x-1,y)
			end

			-- render character
			love.graphics.print(c,x+xo,y+yo)

			-- move cursor
			x = x + font:getWidth(c)
			numRenderedCharacters = numRenderedCharacters + 1
			lastChar = c
		end

	end

end