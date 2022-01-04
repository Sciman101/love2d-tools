local class = require 'class'

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