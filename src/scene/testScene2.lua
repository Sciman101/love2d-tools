local class = require 'class'

-- extend base scene class
local TestScene = class 'TestScene2'
TestScene:extend(require('scene/scene'))

function TestScene:update()
    if love.keyboard.isDown('space') then
        popScene()
    end
end

function TestScene:draw()
    self.super:draw()

    love.graphics.clear(0,0,0)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle('fill',32+math.sin(love.timer.getTime())*16,32,48,48)

    love.graphics.print("Test scene 2...\nPress space to go to the back",128,32)
end

return TestScene