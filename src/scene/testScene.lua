local class = require 'class'

-- extend base scene class
local TestScene = class 'TestScene'
TestScene:extend(require('scene/scene'))

local TestScene2 = require 'scene/testScene2'

function TestScene:update()
    if love.keyboard.isDown('space') then
        pushScene(TestScene2())
    end
end


function TestScene:draw()
    self.super:draw()

    love.graphics.clear(1,1,1)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle('fill',32,32+math.sin(love.timer.getTime()*16)*16,48,48)

    love.graphics.print("Test scene!! Press space to go to the next scene",64,32)
end

return TestScene