--[[
    Entity class, all entities derive from this in terms of functionality
]]
local class = require '30log'
local Entity = class 'Entity'

local uid = 1

-- Note: position is relative to the level the entity is within
function Entity:init(x,y,type)
	self.uid = uid
	uid = uid + 1
	-- All entities have a position
	self.x = x
	self.y = y

	-- What type of entity is this?
	self.type = type
end

function Entity:update(dt)
end

function Entity:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.circle('line',self.x,self.y,16)
	love.graphics.print(tostring(self.type) .. " <Entity>",self.x+18,self.y)
end

return Entity