local lunajson = require 'lib/lunajson'
local colorHelper = require 'util/colorHelper'

-- Function assigned to layers to allow them to redraw themselves
function redrawLayers(world)

	love.graphics.setColor(1,1,1)

	for _, level in pairs(world.levels) do
		for _, layer in ipairs(level.layers) do
			if layer.canvas then
				-- get the tileset
				local tilesetImage = world.tilesets[layer.tilesetId]
				local gs = layer.gridSize
				love.graphics.setCanvas(layer.canvas)

				-- draw tiles
				for _, t in ipairs(layer.tiles) do					
                    local tile = love.graphics.newQuad(t.src[1],t.src[2],gs,gs,tilesetImage)

                    -- flip the sprite based on it's bit flags
                    local sx = (t.f == 1 or t.f == 3) and -1 or 1
                    local sy = (t.f == 2 or t.f == 3) and -1 or 1
					local ox = (sx == -1) and gs or 0
					local oy = (sy == -1) and gs or 0

                    love.graphics.draw(tilesetImage,tile,t.px[1]+ox,t.px[2]+oy,0,sx,sy)
                end

				love.graphics.setCanvas()
			end

		end
	end

end

--[[
	This file exists to provide a function that can be used to ingest a
		.ldtk file and strip out all the unneeded data, returning a truncated, relevant form
		of the level for use in the scene system.

	It will also load all needed images for tilesets and generate canvases for tile layers to render onto. It does not, on it's own, perform any rendering or computation
	Property names are simplified - world coordinates are just referred to as 'x' and 'y'

	Usage:
	local ldtk_import = require 'ldtk/import'
	local level = ldtk_import('res/levels/example_level.ldtk')
]]
return function(path)

	print('Loading scene from ' .. path .. '...')
	local pathDir = path:match("(.*/)")

	-- read data and convert from string to json
    local worldFile = assert(io.open(path,'r'))
    local json = worldFile:read("*all")
    worldFile:close()
    json = lunajson.decode(json)

	-- Begin extracting needed info
	local world = {
		levels = {},
		tilesets = {},
		redrawLayers = redrawLayers,
	}

	-- Extract Tilemaps
	-- This is only really needed for drawing, and so for now we just take the
	-- image itself
	for _, tileset in ipairs(json.defs.tilesets) do
		-- Get path of tileset
		local imgPath = pathDir .. tileset.relPath
		world.tilesets[tileset.uid] = love.graphics.newImage(imgPath)
	end

	-- Extract levels
	for _, level in ipairs(json.levels) do

		-- basic info
		local newLevel = {
			width = level.pxWid,
			height = level.pxHei,
			id = level.uid,
			name = level.identifier,
			x = level.worldX,
			y = level.worldY,
			neighbors = level.__neighbors,
			fields = {},
			layers = {},
		}
		-- copy background
		if level.__bgColor then
			newLevel.bgColor = colorHelper.hexToRGBA(level.__bgColor)
		end
		if level.bgRelPath then
			newLevel.bg = love.graphics.newImage(pathDir .. level.bgRelPath)
			newLevel.bgPos = level.__bgPos
			local crop = newLevel.bgPos.cropRect
			newLevel.bgQuad = love.graphics.newQuad(crop[1],crop[2],crop[3],crop[4],newLevel.bg)
		end

		-- copy fields
		for _, field in ipairs(level.fieldInstances) do
			newLevel.fields[field.__identifier] = field.__value
		end

		-- copy layers
		for _, layer in ipairs(level.layerInstances) do

			local newLayer = {
				xoff = layer.pxOffsetX,
				yoff = layer.pxOffsetY,
				gridSize = layer.__gridSize,
				tilesetId = nil,
			}

			-- does this layer need a canvas?
			if #layer.autoLayerTiles > 0 or #layer.gridTiles > 0 then
				newLayer.canvas = love.graphics.newCanvas(newLevel.width,newLevel.height)
				-- figure out which tile array to grab
				if #layer.autoLayerTiles > #layer.gridTiles then
					newLayer.tiles = layer.autoLayerTiles
				else
					newLayer.tiles = layer.gridTiles
				end
				newLayer.tilesetId = layer.__tilesetDefUid
			end

			-- Copy int grid data
			if #layer.intGridCsv > 0 then
				newLayer.data = layer.intGridCsv
			end

			-- Copy entities
			-- This isn't meant to be data used by the game directly so much as entity information to have copied over into actual entities
			if #layer.entityInstances > 0 then
				newLayer.entityData = {}
				for _, entity in ipairs(layer.entityInstances) do
					local newEntity = {
						x = entity.px[1],
						y = entity.px[2],
						type = entity.__identifier,
						fields = {}
					}
					-- copy fields
					for _, field in ipairs(entity.fieldInstances) do
						newEntity.fields[field.__identifier] = field.__value
					end

					-- put into layer
					newLayer.entityData[#newLayer.entityData+1] = newEntity
				end
			end

			newLevel.layers[#newLevel.layers+1] = newLayer

		end

		-- assign
		world.levels[level.uid] = newLevel
	end

	print('Load complete!')

	return world
end