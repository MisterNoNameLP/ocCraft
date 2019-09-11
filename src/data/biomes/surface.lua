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

--global.conf.showConsole = false --debug

local surface = {
	alreadyGenerated = {},
	seed = 1,
	
	maxHeight = -2,
	minHeight = -10,
	actualHeight = -2,
	
	minDirtLayerSize = 1,
	maxDirtLayerSize = 4,
	
	treeChance = 5,
}

local function addBlock(x, y, b)
	y = -y
	if global.map.blocks[x] == nil then
		global.map.blocks[x] = {}
	end
	if global.map.alreadyGenerated[x] == nil then
		global.map.alreadyGenerated[x] = {}
	end
	
	if global.map.blocks[x][y] == nil and global.map.alreadyGenerated[x][y] == nil then
		global.wre.addBlock(x, y, b, false)
		global.map.alreadyGenerated[x][y] = true
	end
end

local function spawnTree(x, y, s)
	global.log("TREE")
end

math.randomseed(surface.seed)
function surface.generate()
	local fromX, toX, fromY, toY = global.getFOV()
	--toY = 100
	
	for x = fromX, toX do
		if global.map.blocks[x] == nil then
			global.map.blocks[x] = {}
			
			if surface.actualHeight > math.random(surface.minHeight, surface.maxHeight) then
				surface.actualHeight = math.random(surface.actualHeight, surface.maxHeight)
			else
				surface.actualHeight = math.random(surface.minHeight, surface.actualHeight)
			end
			global.map.blocks[x].height = surface.actualHeight
		else
			surface.actualHeight = global.map.blocks[x].height
		end
		
		for y = fromY, toY do
			y = -y
			if y < surface.actualHeight then
				addBlock(x, y, "Stone")
			else
				spawnTree()
			end
			
		end
	end
end	

return surface






