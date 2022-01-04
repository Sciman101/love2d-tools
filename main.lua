-- Boilerplate initialization
package.path = ";src" .. package.path -- Add the source directory to path
love.graphics.setDefaultFilter("nearest", "nearest") -- This is a pixel art game!

-- imports
local Console = require 'debug/console'
require 'debug/commands'

local TestScene = require 'scene/testScene'

-- Create a canvas to be used for rendering the pixel art assets at higher resolutions
-- Note: this is applied to the window size (i.e. scale of 2 takes half the window size)
local mainCanvasScale = 2
local mainCanvas

-- Scene management
-- The current scene is at the top of the stack
local sceneStack = {}
local currentScene = nil

-- override mouse get function to scale with canvas
do
    local oldMousePos = love.mouse.getPosition
    love.mouse.getPosition = function()
        local mx, my = oldMousePos()
        return mx/mainCanvasScale, my/mainCanvasScale
    end
end

-- game start
function love.load()
    Console.print("love2d-tools loaded! type 'help' to see all commands","START")
    -- set the main canvas to the right size
    resizeMainCanvas(love.graphics.getWidth(),love.graphics.getHeight())

    pushScene(TestScene())
end

function love.update(dt)
    if currentScene then
        currentScene:update(dt)
    end
end

function love.draw()
    -- reset color
    love.graphics.setColor(1,1,1)

    -- Set scaled canvas
    love.graphics.setCanvas(mainCanvas)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")

    -- start normal drawing here
    if currentScene then
        currentScene:draw()
    else
        -- no scene
        love.graphics.clear(0.6,0.6,0.6)
        love.graphics.setColor(0,0,0)
        love.graphics.print("No scene loaded :/",16,16)
    end
    -- end normal drawing

    -- Reset canvas and draw
    love.graphics.setCanvas()
    love.graphics.setColor(1,1,1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(mainCanvas,0,0,0,mainCanvasScale,mainCanvasScale)

    -- Draw console
    Console.draw()
end

-- Resize the main canvas to match the new resolution
function love.resize(w,h)
    resizeMainCanvas(w,h)
end

-- passthrough callbacks to the console
function love.keypressed(key,code,isRepeat)
    Console.keypressed(key,code,isRepeat)
end
function love.textinput(text)
    Console.textinput(text)
end
function love.wheelmoved(x,y)
    Console.scroll(y*5)
end

-- non-callback functions

-- Scene management
function pushScene(scene)
    sceneStack[#sceneStack+1] = scene
    currentScene = scene
    scene:onSceneAdded()
    return scene
end
function popScene()
    local scene = sceneStack[#sceneStack]
    sceneStack[#sceneStack] = nil
    currentScene = sceneStack[#sceneStack]
    scene:onSceneRemoved()
    return scene
end

-- canvas resizing
function resizeMainCanvas(w,h)
    mainCanvas = love.graphics.newCanvas(w/mainCanvasScale,h/mainCanvasScale)
end