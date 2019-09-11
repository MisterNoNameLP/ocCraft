--occWorldEenderEngine
local global = ...
local wre = {
	blocks = {},
	alreadyGenerated = {},
	alreadyRendered = {},
}

--===== local vars =====--
local fromX, toX, fromY, toY = 0, 0, 0, 0 --regenerated every update.
local fromPixelX, toPixelX, fromPixelY, toPixelY = 0, 0, 0, 0 --regenerated every update.

--===== local functions =====--
local function consolePrint(...)
	if global.conf.debug.wreDebug then
		global.debug(...)
	end
end

local function garbageCollection() --bug: "clears" to much
	local removedBlocks = 0
	for x, t in pairs(wre.blocks) do
		for y, b in pairs(wre.blocks[x]) do
			if x < fromX or x > toX or y < fromY or y > toY then
				if wre.alreadyGenerated[x] ~= nil then
					wre.alreadyGenerated[x][y] = nil
				end
				if wre.alreadyRendered[x] ~= nil then
					wre.alreadyRendered[x][y] = nil
				end
				if wre.blocks[x] ~= nil then
					if wre.blocks[x][y] ~= nil then
						global.run(wre.blocks[x][y].pStop, wre.blocks[x][y])
						wre.blocks[x][y]:pClear(true)
					end
					wre.blocks[x][y] = nil
					removedBlocks = removedBlocks +1
				end
			end
		end
	end
	if removedBlocks > 0 then
		consolePrint("[WRE]:Blocks unloaded: " ..tostring(removedBlocks))
	end
end

local function addBlock(x, y, b, draw)
	draw = global.ut.parseArgs(draw, false)
	if wre.blocks[x] == nil then
		wre.blocks[x] = {}
	end
	
	local block = b
	if type(b) == "number" then
		block = global.blocks.name[b]
	end
	
	local px, py = global.getPixel(x, y)
	wre.blocks[x][y] = global.blocks[block].new({posX = px, posY = py})
	global.run(wre.blocks[x][y].pStart, wre.blocks[x][y])
	if draw then
		wre.blocks[x][y]:pDraw()
	end
	return wre.blocks[x][y]
end

local function updateWorld()
	local generatedBlocks = 0
	for x = fromX, toX do
		for y = fromY, toY do
			if wre.alreadyGenerated[x] == nil then
				wre.alreadyGenerated[x] = {}
			end
			
			if wre.alreadyGenerated[x][y] == nil then
				local block = nil --string
				if global.map.blocks[x] ~= nil then
					block = global.map.blocks[x][y]
				end
				
				if block ~= nil then
					addBlock(x, y, block)
					generatedBlocks = generatedBlocks +1
				end
				wre.alreadyGenerated[x][y] = true
			elseif global.lastCameraPosX ~= global.cameraPosX or global.lastCameraPosY ~= global.cameraPosY then 
				if wre.blocks[x] ~= nil and wre.blocks[x][y] ~= nil then
					wre.blocks[x][y].gameObject:move(global.lastCameraPosX - global.cameraPosX, global.lastCameraPosY - global.cameraPosY)
					if wre.alreadyRendered[x] ~= nil then
						wre.alreadyRendered[x][y] = nil
					end
				end
			end
			if wre.blocks[x] ~= nil and wre.blocks[x][y] ~= nil and wre.blocks[x][y].update ~= nil then
				wre.blocks[x][y]:pUpdate()
			end
		end
	end
	if generatedBlocks > 0 then
		consolePrint("[WRE]:Generated block: " .. tostring(generatedBlocks))
	end
end

local function drawWorld()
	local c, d = 0, 0
	
	for x, t in pairs(wre.blocks) do
		for y, b in pairs(t) do
			if wre.alreadyRendered[x] == nil then
				wre.alreadyRendered[x] = {}
			end
			if wre.alreadyRendered[x][y] == nil then
				b:pClear()
				c = c +1
			end
		end
	end
	for x, t in pairs(wre.blocks) do
		for y, b in pairs(t) do
			if wre.alreadyRendered[x] == nil then
				wre.alreadyRendered[x] = {}
			end
			if wre.alreadyRendered[x][y] == nil then
				b:pDraw()
				d = d +1
				wre.alreadyRendered[x][y] = true
			end
		end
	end
	
	if c > 0 then
		consolePrint("[WRE]:Clears: " .. tostring(c))
	end
	if d > 0 then
		consolePrint("[WRE]:Draws: " .. tostring(c))
	end
end

local function updateEntities() --WIP
	for _, e in ipairs(global.map.loadedEntities) do --unload entites
		
		if (e.gameObject.posX -1) + e.sizeX <= 0 or e.gameObject.posX > global.resX or 
			(e.gameObject.posY -1) + e.sizeY <= 0 or e.gameObject.posY > global.resY
		then --not on screen
			consolePrint("[WRE]: Unload entity")
			
			e.gameObject:moveTo(
				e.gameObject.posX - (global.cameraPosX - global.lastCameraPosX), 
				e.gameObject.posY - (global.cameraPosY - global.lastCameraPosY)
			)
			
			e.posX, e.posY = global.getBlockPos(e.gameObject.posX, e.gameObject.posY)
			
			local index = #global.map.entities +1
			global.map.entities[index] = e
			global.map.loadedEntities[e.index] = nil
			e.index = index
			global.run(e.pStop, e, index)
		end
	end
	
	for _, e in ipairs(global.map.entities) do --load entities.
		if e.posX + (e.sizeX / (global.texturePack.size *2)) <= fromX or e.posX > toX or
			e.posY + (e.sizeY / (global.texturePack.size)) <= fromY or e.posY > toY
		then else
			consolePrint("[WRE]: Load entity")
			local index = #global.map.loadedEntities +1
			global.map.loadedEntities[index] = e
			global.map.entities[e.index] = nil
			e.index = index
			
			local x, y = global.getPixel(e.posX, e.posY)
			local offsetX = global.cameraPosX - global.lastCameraPosX
			local offsetY = global.cameraPosY - global.lastCameraPosY
			e:moveTo(x + offsetX, y + offsetY)
			
			global.run(e.pStart, e, index)
		end
	end
	
	for _, e in ipairs(global.map.loadedEntities) do --update entities
		local gameObjects = {}
		for x = fromX, toX do
			for y = fromY, toY do
				if global.wre.blocks[x] ~= nil and global.wre.blocks[x][y] ~= nil then
					if global.wre.blocks[x][y].gameObject.getCollider ~= nil then
						table.insert(gameObjects, global.wre.blocks[x][y].gameObject)
					end
				end
			end
		end
		
		if global.cameraPosX ~= global.lastCameraPosX or global.cameraPosY ~= global.lastCameraPosY then
			e.gameObject:moveTo(
				e.gameObject.posX - (global.cameraPosX - global.lastCameraPosX), e.gameObject.posY - (global.cameraPosY - global.lastCameraPosY)
			)
			e.gameObject:clear(global.backgroundColor)
			global.run(e.pClear, e, global.backgroundColor)
		end
		
		if global.dt > global.conf.maxTickTime then
			global.warn("Delta time too high (" .. tostring(global.dt) .. "s)!")
			global.dt = global.conf.maxTickTime
		end
		
		e.gameObject:updatePhx(gameObjects, global.dt)
		e.gameObject:update(gameObjects)
		global.run(e.pUpdate, e)
	end
end

local function drawEntities() --WIP
	for _, e in ipairs(global.map.loadedEntities) do
		e.gameObject:clear(global.backgroundColor)
		global.run(e.pClear, e)
		e.gameObject:draw()
		global.run(e.pDraw, e)
	end
end

--===== global functions =====--
function wre.addEntity(x, y, e)
	local entity = e
	if type(e) == "number" then
		entity = global.entities.name[e]
	end
	
	if global.entities[entity].new == nil then
		return false, "Entity not found."
	end
	
	local index = #global.map.entities +1
	global.map.entities[index] = global.entities[entity].new({posX = x, posY = y, index = index})
	global.run(global.map.entities[index].pSpawn, global.map.entities[index], index)
	return global.map.entities[index]
end

function wre.addBlock(x, y, b, draw)
	if global.map.blocks[x] == nil then
		global.map.blocks[x] = {}
	end
	
	
	local block = b
	if type(b) == "string" then
		block = global.blocks.id[b]
	end
	
	if global.map.blocks[x][y] == nil then
		global.map.blocks[x][y] = block
		local b = addBlock(x, y, block, draw)
		global.run(b.pPlaced, b, x, y)
		return true
	else
		return false
	end
end

function wre.removeBlock(x, y)
	local block = -1
	if global.map.blocks[x] == nil then
		return false
	else
		block = global.map.blocks[x][y]
		global.map.blocks[x][y] = nil
	end
	if wre.alreadyGenerated[x] ~= nil then
		wre.alreadyGenerated[x][y] = nil
	end
	if wre.alreadyRendered[x] ~= nil then
		wre.alreadyRendered[x][y] = nil
	end
	if wre.blocks[x] ~= nil and wre.blocks[x][y] ~= nil then
		global.run(wre.blocks[x][y].pRemoved, wre.blocks[x][y])
		global.run(wre.blocks[x][y].pStop, wre.blocks[x][y])
		wre.blocks[x][y]:pClear(true)
		wre.blocks[x][y] = nil
		return true, block
	end
	return false
end

function wre.update(phx)
	fromX, toX, fromY, toY = global.getFOV()
	fromPixelX, toPixelX, fromPixelY, toPixelY = global.getFOVPixel()
	
	--fromPixelX, toPixelX, fromPixelY, toPixelY = 0, global.resX, 0, global.resY
	--global.log(global.getFOVPixel())
	
	updateWorld()
	if phx == nil or phx == true then
		updateEntities()
	end
	
	garbageCollection()
end

function wre.draw()
	drawWorld()
	drawEntities()
end

function wre.newUpdate()
	wre.alreadyGenerated = {}
	wre.update()
end

function wre.newDraw()
	wre.alreadyRendered = {}
	wre.draw()
end

return wre