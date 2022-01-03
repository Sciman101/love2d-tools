--[[
    Simple class system based on code by KodaPop#0807 and Bearish#1379
    Example use:

    local Class = require 'class'
    local Entity = Class 'Entity'

    -- Constructor
    function Entity:init(x,y)
        self.x = x
        self.y = y
    end

    -- Instantiation
    local entity_instance = Entity()

    -- Extension
    local Player = Class:extend(Entity)
    local player_instance = Player()
]]

local Class = {}

-- Extend another class
function Class:extend(parent)
    self.super = parent
    getmetatable(self).__index = parent
    return self
end

-- Check for inheritance
function Class:isinstance(inst)
    -- Get the index table for the instance passed
    local meta = getmetatable(inst).__index
    -- While the metatable exists
    while meta do
        -- If it's this class, then yes, it's an instance!
        if meta == self then
            return true
        end
        -- Descend a level deeper
        meta = getmetatable(meta)
        if meta then meta = meta.__index end
    end
    -- Guess not! too bad
    return false
end

function Class:instantiate(...)
    local inst = {}
    -- Call constructor
    if self.init then
        self.init(inst,...)
    end
    setmetatable(inst,self)
    return inst
end

-- Class creator
return function(name)
    local class = {}
    -- Set the class's index to itself and create constructor via __call
    class.__index = class
    setmetatable(class,{
            __index = Class,
            __call = Class.instantiate,
            __tostring = function(self) return 'Class ' .. name end,
        })
    return class
end