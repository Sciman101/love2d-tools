local class = require '30log'
local EntityPlayer = require('entity/entity'):extend("EntityPlayer")

function EntityPlayer:init(x,y)
	EntityPlayer.super.init(self,x,y,'player')
end

function EntityPlayer:update(dt)
end

function EntityPlayer:draw()
	love.graphics.setColor(0,0,1)
	love.graphics.rectangle('fill',self.x-8,self.y-8,16,24)
end

return EntityPlayer