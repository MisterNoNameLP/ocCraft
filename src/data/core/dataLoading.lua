local args = {...}
local global = args[1]
local toLoad = args[2]
local path = "data"
local loadingMods = false

if args[4] ~= nil then --onay on mod loading.
	path = "mods/" .. args[4]
	loadingMods = true
end
if global.alreadyLoaded[path] == nil then
	global.alreadyLoaded[path] = {}
end

--===== local functions =====--
local print = args[3] or function(...) 
	global.log(...)
	if global.conf.showConsole then
		global.tbConsole:draw()
	end
end
do
	local p = print
	print = function(...)
		if global.conf.debug.dlDebug then
			p(...)
		end
	end
end

local function reloadFile(target, path, ...)
	local debugString = "[DL]: Reloading file: " .. path .. ": "
	
	local suc, err = loadfile(path)
	if suc == nil then
		print(debugString .. tostring(err))
	else
		print(debugString .. tostring(suc))
		target = nil
		return loadfile(path)(...)
	end
end

local reloadString = ""
for i, c in pairs(toLoad) do
	if c then
		if #reloadString > 0 then
			reloadString = reloadString .. ", " .. i
		else
			reloadString = reloadString .. i
		end
	end
end
if loadingMods then
	global.log("[DL]: Loading mod data groups: " .. reloadString .. ".")
else
	global.log("[DL]: Loading data groups: " .. reloadString .. ".")
end

--===== reloadings =====--
if toLoad.map then
	if toLoad.reload then
		print("[INFO]: Reload: global.map.")
		global.map = {blocks = {}, alreadyGenerated = {}, entities = {}, loadedEntities = {}, blockMap = {}}
		global.wg.load(global.conf.map)
	end
end

if toLoad.conf then
	global.conf = reloadFile(global.conf, "conf.lua", global)
end

if toLoad.wg then
	global.wg = reloadFile(global.wg, "data/core/wg.lua", global)
end

if toLoad.wre then
	global.wre = reloadFile(global.wre, "data/core/wre.lua", global)
end

if toLoad.states then
	global.states = {} 
	global.loadData(global.states, "data/states", nil, print)
end

--===== data loading =====--
if toLoad.textures then
	if global.alreadyLoaded[path].textures ~= true or toLoad.reload then
		if not loadingMods then
			if global.isDev then
				print("[DL]: Loading texturepack info.lua: " .. tostring(loadfile("texturePacks/" .. global.conf.texturePack .. "/info.lua")))
			end
			global.texturePack = loadfile("texturePacks/" .. global.conf.texturePack .. "/info.lua")(global)
			print("[DL]: Loading textures.")
			global.textures = {}
			global.loadData(global.textures, "texturePacks/" .. global.conf.texturePack .. "/textures", nil, print)
		else
			print("[DL]: Loading textures.")
			global.loadData(global.textures, path .. "/textures", nil, print)
		end
		global.alreadyLoaded[path].textures = true
	else
		print("[DL]: Textures are loaded already.")
	end
end	

if toLoad.blocks then
	if global.alreadyLoaded[path].blocks ~= true or toLoad.reload then
		if not loadingMods then
			if global.isDev then
				print("[DL]: Loading parrent: Block: " .. tostring(loadfile("data/parents/Block.lua")))
			end
			global.Block = loadfile("data/parents/Block.lua")(global)
			global.Block:init()
			global.blocks = {
				name = {noBlock = true},
				id = {noBlock = true},
				info = {noBlock = true, amout = 0},
			}
		end
		print("[DL]: Loading blocks.")
		global.loadData(global.blocks, path .. "/blocks", function(name, id)
			global.blocks.id[name] = id
			global.blocks.name[id] = name
			global.blocks.info.amout = global.blocks.info.amout +1
			global.run(global.blocks[name].init, id)
		end, print)
		global.alreadyLoaded[path].blocks = true
	else
		print("[DL]: Blocks are loaded already.")
	end
end

if toLoad.entities then
	if global.alreadyLoaded[path].entities ~= true or toLoad.reload then
		if not loadingMods then
			if global.isDev then
				print("[DL]: Loading parrent: Entity: " .. tostring(loadfile("data/parents/Entity.lua")))
			end
			global.Entity = loadfile("data/parents/Entity.lua")(global)
			global.entities = {name = {}, id = {}, info = {amout = 0}}
		end
		print("[DL]: Loading entities.")
		global.loadData(global.entities, path .. "/entities", function(name, id)
			global.entities.id[name] = id
			global.entities.name[id] = name
			global.entities.info.amout = global.entities.info.amout +1
			global.run(global.entities[name].init, id)
		end, print)
		global.alreadyLoaded[path].entities = true
	else
		print("[DL]: Entities are loaded already.")
	end
end

if toLoad.biomes then
	if global.alreadyLoaded[path].biomes ~= true or toLoad.reload then
		if not loadingMods then
			global.biomes = {}
		end
		print("[DL]: Loading biomes.")
		global.loadData(global.biomes, path .. "/biomes", nil, print)
		global.alreadyLoaded[path].biomes = true
	else
		print("[DL]: Biomes are loaded already.")
	end
end


if toLoad.mods then --WIP
	if global.alreadyLoaded.mods ~= true or toLoad.reload then
		print("[DL]: Loading mods.")
		for file in global.fs.list(global.shell.getWorkingDirectory() .. "/mods/") do
			print("[DL]: Loading mod: " .. file)
			global.load({
				blocks = toLoad.blocks,
				entities = toLoad.entities,
				biomes = toLoad.biomes,
				textures = toLoad.textures,
				reload = toLoad.reload
			}, print, file)
		end
	else
		print("[DL]: Mods are loaded already.")
	end
end

if loadingMods then
	global.log("[DL]: Mod data loading done.")
else
	global.log("[DL]: Data loading done.")
end

return true