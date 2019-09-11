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

local wg = {
	
}
--===== local vars =====--

--===== local functions =====--
local function print(...)
	if global.conf.debug.wgDebug then
		global.debug(...)
	end
end

local function saveTable(t, dir, f)
	local data = "return " .. global.serialization.serialize(t)
	
	local file = io.open(dir .. "/" .. f .. ".lua", "w")
	file:write(data)
	file:close()
end

local function loadTable(t, dir, f)

end

--===== global functions =====--
function wg.generate(biome)
	global.biomes[biome].generate()
end

function wg.save(name, overwrite)
	dir = global.shell.getWorkingDirectory() .. "/saves/" .. name
	local map = {}
	local file = {}
	
	print("[WG]: Save world.")
	
	if global.fs.exists(dir) and overwrite ~= true then
		print("[WG]: Map file already exist.")
		return false, "Map file already exist"
	end
	
	if global.conf.mapBackup ~= false then
		local c = 1
		while global.fs.exists(dir .. "(" .. tostring(c) .. ")") do
			c = c +1
		end
		os.execute("cp -r " .. dir .. " " .. dir .. "(" .. tostring(c) .. ")")
	end
	global.fs.makeDirectory(dir)
	
	
	saveTable(global.map.blocks, dir, "blocks")
	saveTable(global.map.alreadyGenerated, dir, "alreadyGeneratedBlocks")
	global.blocks.name.noBlock = nil
	saveTable(global.blocks.name, dir, "idList")
	global.blocks.name.noBlock = true
	
	return true
end

function wg.load(name, forceLoading)
	local dir = global.shell.getWorkingDirectory() .. "/saves/" .. name
	
	print("[WG]: Load world.")
	
	if not global.fs.exists(dir) then
		return false, "Map file does not exist"
	end

	local blocks = dofile(dir .. "/blocks.lua")
	local alreadyGenerated = dofile(dir .. "/alreadyGeneratedBlocks.lua")
	local idList = dofile(dir .. "/idList.lua")
	local toChange = {}
	
	print("[WG]: Check id changes.")
	
	for id, name in pairs(idList) do
		if global.blocks.name[id] ~= name then
			if global.blocks.id[name] ~= nil or forceLoading then
				if global.blocks.id[name] == nil then
					global.warn("[WG]: Block not found but forced to load the map: ", name, id)
					toChange[id] = -1
				else
					print("[WG]: Change block id \"" .. name .. "#" .. tostring(id) .. "\" to: " .. global.blocks.id[name] .. ".")
					toChange[id] = global.blocks.id[name]
				end
			else
				print("[WG]: Block not found.", name, id)
				return false, "Block not found.", name, id
			end
		end
	end
	
	for x, _ in pairs(blocks) do
		for y, _ in pairs(blocks[x]) do
			local id = -1
			if blocks[x] ~= nil and blocks[x][y] ~= nil then
				id = blocks[x][y]
			end
			
			if toChange[id] ~= nil then
				if toChange[id] == -1 then
					blocks[x][y] = nil
				else
					blocks[x][y] = toChange[id]
				end
			end
		end
	end
	
	global.map.blocks = blocks
	global.map.alreadyGenerated = alreadyGenerated
	
	return true
end

function wg.addBlock(x, y, b)
	if global.map[x] == nil then
		global.map[x] = {}
	end
	if global.map.alreadyGenerated[x] == nil then
		global.map.alreadyGenerated[x] = {}
	end
	
	if global.map[x][y] == nil and global.map.alreadyGenerated[x][y] == nil then
		local suc = global.wre.addBlock(x, y, b)
		if suc then
			global.map.alreadyGenerated[x][y] = true
		end
		return true, suc
	else
		return false, "Already generated or busy."
	end
end

return wg











