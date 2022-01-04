local class = require 'class'
local lunajson = require 'lib/lunajson'

-- Set up scene
local ldtkScene = class 'LdtkScene'
ldtkScene:extend(require('scene/scene'))

function ldtkScene:init(path)
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
                layer.canvas = love.graphics.newCanvas(lv.pxWid,lv.pixHei)
            end
        end
    end
    self:redrawTileLayers()

end

-- Loop over every level/layer and redraw canvases
function ldtkScene:redrawTileLayers()
    for i=1,#json.levels do
        local lv = json.levels[i]
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
                local tileArray = layer.gridTiles or layer.autoLayerTiles
                for _, t in ipairs(tileArray) do

                    local tile = love.graphics.newQuad(t.src[1],t.src[2],layer.__gridSize,layer.__gridSize,timg)
                    love.graphics.draw(timg,tile,t.px[1],t.px[2])

                end

                -- reset canvas
                love.graphics.setCanvas()
            end
        end
    end
end

function ldtkScene:update()
end

function ldtkScene:draw()
    -- Draw levels
    for i=1,#json.levels do
        local lv = json.levels[i]
        -- Draw each layer in the canvas
        for j=1,#lv.layerInstances do
            local layer = lv.layerInstances[j]
            if layer.canvas then
                love.graphics.draw(layer.canvas,lv.worldX+layer.pxOffsetX,lv.worldY+layer.pxOffsetY)
            end
        end
    end
end

return ldtkScene