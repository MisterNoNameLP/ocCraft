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
local tt = {

}

--===== local vars =====--

--===== local functions =====--
local orgPrint = print
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function tt.init()
	--tt.ocui = global.ocui.initiate(global.ocgl)
	
	--[[
	local textures = {}
	
	print(global.shell.getWorkingDirectory() .. "texturePacks/" .. global.conf.texturePack .. "/textures")
	
	--=== loading textures ===--
	global.texturePack = dofile("texturePacks/" .. global.conf.texturePack .. "/info.lua")
	global.textures = {}
	for file in global.fs.list(global.shell.getWorkingDirectory() .. "texturePacks/" .. global.conf.texturePack .. "/textures") do
		if global.isDev then
			print(loadfile("texturePacks/" .. global.conf.texturePack .. "/textures/" .. file))
		end
		
		local name = string.sub(file, 0, #file -4)
		global.textures[name] = dofile("texturePacks/" .. global.conf.texturePack ..  "/textures/" .. file)
	end
	
	print(#textures)
	
	local sizeY  = 0
	if global.isDev then 
		sizeY = global.resY - global.conf.consoleSizeY -2
	else
		sizeY = global.resY -2
	end
	tt.list = tt.ocui.List.new(tt.ocui, 1, 1, 20, sizeY, textures, {listedFunction = function(...) global.log(...) end})
	]]
end

function tt.start()
	
end

function tt.update()
	
end

function tt.draw()
	tt.ocui:draw()
end

function tt.touch(x, y, b, p)
	tt.ocui:update(x, y)
end

function tt.stop()
	
end

return tt