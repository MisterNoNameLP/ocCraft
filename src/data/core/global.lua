local args = {...}
local conf = args[1]

--===== global vars =====--
local global = {
	isRunning = true,
	isDev = conf.debug.isDev,
	
	conf = conf,
	controls = dofile("controls.lua"),
	
	state = "",
	dt = 0, --deltaTime
	lastUptime = 0,
	fps = 0,
	
	cameraPosX = 0,
	cameraPosY = 0,
	lastCameraPosX = 0, --regenerated every update.
	lastCameraPosY = 0,--regenerated every update.
	cameraSubPosX = 0,
	cameraSubPosY = 0,
	
	backgroundColor = 0x00409f,
	
	map = {
		idMap = {},
		blocks = {}, --2D
		alreadyGenerated = {}, --2D
		entities = {},
		loadedEntities = {},
	},
	textures = {},
	blocks = { --the noBlock tag is necessary 'til the item system is implemented to avoid states["game"].init() crash.
		name = {noBlock = true},
		id = {noBlock = true},
		info = {noBlock = true, amout = 0},
	},
	entities = {
		name = {}, 
		id = {}, 
		info = {amout = 0},
	},
	biomes = {},
	items = {}, --not implemented yet.
	
	orgPrint = print,
	
	alreadyLoaded = {},
	loadedMods = {},
}

--===== global functions =====--
function global.log(...)
	local t = {...}
	local s = "[INFO] " .. tostring(t[1])
	global.tbConsole:add(s, select(2, ...))
	global.ocl.add(s, select(2, ...))
end

function global.warn(...)
	local t = {...}
	local s = "[WARN] " .. tostring(t[1])
	global.tbConsole:add(s, select(2, ...))
	global.ocl.add(s, select(2, ...))
end

function global.error(...)
	local t = {...}
	local s = "[ERROR] " .. tostring(t[1])
	global.tbConsole:add(s, select(2, ...))
	global.ocl.add(s, select(2, ...))
end

function global.fatal(...)
	local t = {...}
	local s = "[FATAL] " .. tostring(t[1])
	global.tbConsole:add(s, select(2, ...))
	global.ocl.add(s, select(2, ...))
	global.isRunning = false
	global.state = ""
end

function global.debug(...)
	if global.isDev then
		local t = {...}
		local s = "[DEBUG] " .. tostring(t[1])
		global.tbConsole:add(s, select(2, ...))
		global.ocl.add(s, select(2, ...))
	end
end

function global.slog(...)
	local t = {...}
	local s = "[SINFO]: Start: " .. tostring(t[1])
	global.tbConsole:add(s, select(2, ...))
	global.ocl.add(s, select(2, ...))
	for i, s in ipairs(t) do
		local ss = global.serialization.serialize(t[i]) .. ";"
		global.tbConsole:add(ss)
		global.ocl.add(ss)
	end
	global.tbConsole:add("[SINFO]: End.")
	global.ocl.add("[SINFO]: End.")
end

function global.run(func, ...)
	if func ~= nil then
		func(...)
	end
end

function global.load(...)
	loadfile("data/core/dataLoading.lua")(global, ...)
end

function global.drawDebug(...)
	if global.conf.showDebug then
		local debugString = ""
		local fillString = "                                                           "
		global.gpu.setForeground(0xaaaaaa)
		global.gpu.setBackground(0x333333)
		
		debugString = debugString .. 
			"CX:" .. tostring(global.cameraPosX) .. " CY:" .. tostring(global.cameraPosY) .. 
			" | freeMemory: " .. tostring(math.floor((global.computer.freeMemory() /1024) +.5)) .. "KB" ..
			" | FPS" .. tostring(math.floor((global.fps) +.5))
			
		for _, s in pairs({...}) do
			debugString = debugString .. " | " .. s
		end
		
		global.gpu.set(1, 1, debugString .. fillString)
	end
end

function global.clear()
	global.gpu.setBackground(global.backgroundColor)
	global.gpu.fill(1, 1, global.resX, global.resY, " ")
	global.wre.newDraw()
end

function global.loadData(target, dir, func, print)
	local id = 1
	if target.info ~= nil and target.info.amout ~= nil then
		id = target.info.amout +1
	end
	
	path = global.shell.getWorkingDirectory() .. "/" .. dir .. "/"
	print = print or global.orgPrint
	
	for file in global.fs.list(path) do
		if global.isDev then
			local debugString = "[global]: Loading file: " .. dir .. "/" .. file .. ": "
			
			local suc, err = loadfile(path .. file)
			
			if suc == nil then
				print(debugString .. tostring(err))
			else
				print(debugString .. tostring(suc))
			end
		end
		
		local name = string.sub(file, 0, #file -4)
		target[name] = loadfile(path .. file)(global)
		
		if func ~= nil then
			func(name, id)
		end
		
		id = id +1
	end
	return id
end

function global.moveCamera(x, y)
	global.cameraSubPosX = global.cameraSubPosX +x
	global.cameraSubPosY = global.cameraSubPosY +y
	
	global.cameraPosX = math.floor(global.cameraSubPosX)
	global.cameraPosY = math.floor(global.cameraSubPosY)
	
	global.gpu.setBackground(global.backgroundColor) --debug: wip: todo:...
	global.gpu.fill(1, 1, global.resX, global.resY, " ")----debug: wip: todo:...
end

function global.setConsoleSize(size)
	local resX, resY = global.gpu.getResolution()
	size = size or global.conf.consoleSizeY
	global.tbConsole.sizeX = resX
	global.tbConsole.sizeY = resY - (resY - size)
	global.tbConsole.posY = resY - size
end

function global.getFOVPixel() --gives the FOV in pixels.
	return global.cameraPosX, global.cameraPosX + global.resX, global.cameraPosY, global.cameraPosY + global.resY
end

function global.getFOV() --gives the FOV in blocks.
	local startX = global.cameraPosX / (global.texturePack.size *2)
	local startY = global.cameraPosY / (global.texturePack.size)
	return math.floor(startX), math.floor(startX + (global.resX / (global.texturePack.size *2))), math.floor(startY), math.floor(startY + (global.resY / (global.texturePack.size)))
end

function global.getBlockPos(x, y) --gives the block pos and id from relative pixel.
	local posX = math.floor(((x + global.cameraPosX) / (global.texturePack.size *2)))
	--local posY = math.floor((((y +1) + global.cameraPosY) / global.texturePack.size))
	local posY = math.floor(((y + global.cameraPosY) / global.texturePack.size))
	if global.map.blocks[posX] ~= nil then
		return posX, posY, global.map.blocks[posX][posY]
	else
		return posX, posY, nil
	end
end

function global.getBlock(x, y) --gives the block id, name and object (if loaded) from block pos in map.
	local id, name, object = nil, nil, nil
	if global.map[x] ~= nil then
		id = global.map.blocks[x][y]
		name = global.blocks.name[id]
	end
	if global.wre.blocks[x] ~= nil then
		object = global.wre.blocks[x][y]
	end
	return id, name, object
end

function global.getPixel(x, y) --give the relative pixel pos from a block
	local posX = math.floor(((x * global.texturePack.size) *2) - global.cameraPosX)
	local posY = math.floor((y * global.texturePack.size) - global.cameraPosY)
	return posX, posY
end

return global