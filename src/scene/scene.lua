--[[
    Scene class, holds all the base functionality for a class
    All scene types inherit from this
]]
local class = require '30log'
local Scene = class 'Scene'

function Scene:init()
end

function Scene:update(dt)
end

function Scene:draw()
end

-- called when the scene is pushed to the stack
function Scene:onSceneAdded()
end

-- called when the scene is removed from the stack
function Scene:onSceneRemoved()
end

return Scene