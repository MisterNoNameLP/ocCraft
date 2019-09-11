--[[
	ocCraft Copyright (C) 2019 MisterNoNameLP.
	
    This file is part of ocCraft.

    ocCraft is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ocCraft is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ocCraft.  If not, see <https://www.gnu.org/licenses/>.
]]

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
	game.player = global.wre.addEntity(2, 2, "Player")
	
	
	for n, b in pairs(global.blocks) do
		if not b.noBlock and type(b) ~= "function" then
			game.player:addToInv(n, 1000)
		end
	end
	
	local count = 4
	for n, e in pairs(global.entities) do
		if n ~= "Player" then
			if global.wre.addEntity(count, 2, n) then
				count = count +2
			end
		end
	end
	
	--===== debug end =====--
	
	print("[game]: init done.")
end

function game.start()
	global.wg.load(global.conf.map, true)
	global.clear()
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
	global.run(game.player.keyUp, game.player, c, k, p)
end

function game.touch(x, y, b, p)
	local posX, posY = global.getBlockPos(x, y)
	
	global.run(game.player.touch, game.player, x, y, b, p)
end

function game.drag(x, y, b, p)
	global.run(game.player.drag, game.player, x, y, b, p)
end

function game.drop(x, y, b, p)
	global.run(game.player.drop, game.player, x, y, b, p)
end

function game.stop()
	print("Save world: ", global.wg.save(global.conf.map, true))
end

return game





