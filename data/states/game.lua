local global = ...

--===== shared vars =====--
local game = {
	blocks = {},
	alreadyGenerated = {},
	alreadyRendered = {},
	
	player = {},
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function game.init()
	game.camera = loadfile("data/stateData/game/camera.lua")(global)
	global.cameraPosX = 0
	global.cameraPosY = 0
	
	print("[game]: Start init.")
	
	
	global.load({
		blocks = true,
		entities = true,
		biomes = true,
		textures = true,
		mods = true,
	})
	
	--===== debug start =====--
	
	
	--=== reload player ===--
	global.map.loadedEntities = {}
	game.player = global.wre.addEntity(5, 2, "Player")
	--game.testEnt = global.wre.addEntity(7, 2, "TestEnt")
	
	for n, b in pairs(global.blocks) do
		if not b.noBlock and type(b) ~= "function" then
			--print(n, 100)
			game.player:addToInv(n, 100)
		end
	end
	
	if not global.hasPlayer then
		--global.wre.addEntity(1, 1, "Player")
		--global.hasPlayer = true
	end
	
	
	global.wg.load(global.conf.map, true)
	
	
	--===== debug end =====--
	
	print("[game]: init done.")
end

function game.start()
	global.wg.generate(global.conf.worldGen)
	global.wre.update()
	
end

function game.update()
	game.camera.update(game)
	
	--===== calculate game tick =====--
	global.wg.generate(global.conf.worldGen)
	global.wre.update()
	
end

function game.draw()
	global.wre.draw()
	
	game.player:draw()
	
	global.drawDebug()
end

function game.keyDown(c, k)
	if k == 28 and global.isDev then
		print("--===== EINGABE =====--")
	end 
	
	game.player:keyDown(c, k, p)
	
	--print(c, k)
end

function game.keyUp(c, k)
	game.player:keyUp(c, k, p)
end

function game.touch(x, y, b, p)
	local posX, posY = global.getBlockPos(x, y)
	
	game.player:touch(x, y, b, p)
end

function game.stop()
	print("Save world: ", global.wg.save(global.conf.map, true))
end

return game





