local class = require '30log'
local lunajson = require 'lib/lunajson'

-- Set up scene
local LdtkScene = require('scene/scene'):extend("LdtkScene")

function LdtkScene:init(path)
    print('Loading scene from ' .. path)

    -- read data
    local levelFile = assert(io.open(path,'r'))
    local jsonString = levelFile:read("*all")
    levelFile:close()

    print('Data loaded, parsing JSON')
    -- parse
    local json = lunajson.decode(jsonString)
    print('JSON decoded')

    -- Load relevant definitions from json
    self.tilesets = {}
    local tilesetDefs = json.defs.tilesets
    for i=1,#tilesetDefs do
        local tileset = tilesetDefs[i]
        self.tilesets[tileset.uid] = {
            image = love.graphics.newImage("res/" .. tileset.relPath)
        }
    end

    -- Load levels from json
    self.levels = {}
    for i=1,#json.levels do
        local lv = json.levels[i]
        self.levels[lv.uid] = lv

        -- each level needs a canvas for each layer
        for j=1,#lv.layerInstances do
            local layer = lv.layerInstances[j]
            if layer.__type == 'Tiles' or layer.__type == 'AutoLayer' or (layer.__type == 'IntGrid' and layer.autoLayerTiles) then
                layer.canvas = love.graphics.newCanvas(lv.pxWid,lv.pxHei)
                -- figure out what array of tiles to draw
                layer.tileArray = layer.gridTiles
                if not layer.tileArray or #layer.tileArray == 0 then
                    layer.tileArray = layer.autoLayerTiles
                end
            end
        end
    end
    self:redrawTileLayers()

    -- basic camera movement
    self.x = 0
    self.y = 0

end

-- Loop over every level/layer and redraw canvases
function LdtkScene:redrawTileLayers()
    for id, lv in pairs(self.levels) do
        -- Draw each layer in the canvas
        for j=1,#lv.layerInstances do
            local layer = lv.layerInstances[j]
            if layer.canvas then
                
                -- figure out the tileset being referenced
                local tset = self.tilesets[layer.__tilesetDefUid]
                local timg = tset.image
                -- Draw the tiles
                love.graphics.setCanvas(layer.canvas)

                love.graphics.clear(0,0,0,0)
                love.graphics.setColor(1,1,1)

                -- get array of tiles
                local tileArray = layer.tileArray

                for _, t in ipairs(tileArray) do
                    local tile = love.graphics.newQuad(t.src[1],t.src[2],layer.__gridSize,layer.__gridSize,timg)

                    -- flip the sprite based on it's bit flags
                    local sx = (t.f == 1 or t.f == 3) and -1 or 1
                    local sy = (t.f == 2 or t.f == 3) and -1 or 1

                    -- TODO remove magic numbers
                    love.graphics.draw(timg,tile,t.px[1]+8,t.px[2]+8,0,sx,sy,8,8)
                end

                -- reset canvas
                love.graphics.setCanvas()
            end
        end
    end
end

function LdtkScene:update(dt)
    -- move
    if love.keyboard.isDown('a') then self.x = self.x + dt * 128 end
    if love.keyboard.isDown('d') then self.x = self.x - dt * 128 end
    if love.keyboard.isDown('w') then self.y = self.y + dt * 128 end
    if love.keyboard.isDown('s') then self.y = self.y - dt * 128 end
end

function LdtkScene:draw()

    love.graphics.push()
    love.graphics.translate(self.x,self.y)

    love.graphics.setColor(1,1,1)
    -- Draw levels
    for id, lv in pairs(self.levels) do

        -- Draw each layer in the canvas
        for j=1,#lv.layerInstances do
            local layer = lv.layerInstances[j]
            if layer.canvas then
                -- draw level boundaries (DEBUG)
                love.graphics.rectangle('line',lv.worldX,lv.worldY,lv.pxWid,lv.pxHei)
                love.graphics.draw(layer.canvas,lv.worldX+layer.pxOffsetX,lv.worldY+layer.pxOffsetY)
            end
        end
    end

    love.graphics.pop()
end

return LdtkScene