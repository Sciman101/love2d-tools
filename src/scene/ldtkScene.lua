local class = require '30log'
local lunajson = require 'lib/lunajson'
local colorHelper = require 'util/colorHelper'

-- Set up scene
local LdtkScene = require('scene/scene'):extend("LdtkScene")

function LdtkScene:init(world)
    self.world = world
    self.world:redrawLayers()

    -- basic camera movement
    self.x = 0
    self.y = 0
end

function LdtkScene:update(dt)
    -- move
    if love.keyboard.isDown('a') then self.x = self.x + 8 end
    if love.keyboard.isDown('d') then self.x = self.x - 8 end
    if love.keyboard.isDown('w') then self.y = self.y + 8 end
    if love.keyboard.isDown('s') then self.y = self.y - 8 end

    self.x = math.floor(self.x)
    self.y = math.floor(self.y)
end

function LdtkScene:draw()

    love.graphics.push()
    love.graphics.setColor(1,1,1)
    love.graphics.translate(self.x,self.y)

    -- Draw levels
    for id, lv in pairs(self.world.levels) do

        -- draw background color
        if lv.bgColor then
            love.graphics.setColor(lv.bgColor)
            love.graphics.rectangle('fill',lv.x,lv.y,lv.width,lv.height)
        end
        love.graphics.setColor(1,1,1)
        -- draw background image
        if lv.bg then
            local rect = lv.bgPos.cropRect
            love.graphics.draw(lv.bg,lv.bgQuad,lv.x+lv.bgPos.topLeftPx[1],lv.y+lv.bgPos.topLeftPx[2],0,lv.bgPos.scale[1],lv.bgPos.scale[2])
        end

        -- Draw each layer in the canvas
        for j=1,#lv.layers do
            local layer = lv.layers[j]
            if layer.canvas then
                love.graphics.draw(layer.canvas,lv.x+layer.xoff,lv.y+layer.yoff)

                -- draw level boundaries (DEBUG)
                love.graphics.rectangle('line',lv.x,lv.y,lv.width,lv.height)
                love.graphics.print(lv.name,lv.x+8,lv.y+8)
            end
        end
    end

    love.graphics.pop()
end

return LdtkScene