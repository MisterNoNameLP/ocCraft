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
--[[ocCraft:
	Bugs:
		Unconstant jump height (jump glitch):
			Higher FPS higher jump glitch effect (trigger more then 1 frame tiggerd)(add collision side return to ocgf.updatePhx()).
			
		Memory leak on game restart/stop.
		
		Resolution bug:
			You need to restart the PC after you changed the resolution to avoid graphic issues (only if occ was running befor the res change).
			Block placing/breaking are working (not properly) but no rendering (ent and blocks).
		
		Entities:
			Speed shouldn't be more as the texturePack size (ocgf.RigidBody).
			Graphc errors if sprite was over a block.
			Despawns sometimes if it goes out of screen (will fixed after wre.updateEntities() rewrite).
	
	ToDo:
		Add items:
			Basic item class.
		
		Modding:
			Database what content is from what mod (wg (save()/load())).
		
		Player.lua:
			Add Player.breakDamage > Block.hardness check.
			Add way to activate blocks/enities.
			Inv rewrite (after new item system).
		
		Add dynamic texture color system (ocgl/ocgf).
		
		Write own event handler.
		
		Source code clean up:
			Outsource some functions from "global.lua" to seperate file.
			Outsource event handling from "occCore.lua" (after new event handler).
		
		wre.lua:
			updateEntities():
				Better implementation in the map, may rewrite.
		
		wg.lua:
			save()/load():
				Save/load entities (after wre entity system rewrite).
				Compress file size.
	
	Written by:
		MisterNoNameLP.
]]
local version = "v0.1.2"

local licenseNotice = [[
    ocCraft Copyright (C) 2019 MisterNoNameLP.
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

--===== prog start =====--
do
	print(licenseNotice)
	print("Initialize ocCraft " .. version)
	local conf = dofile("conf.lua")
	if conf.debug.isDev then
		print(loadfile("data/core/global.lua"))
	end
	local global = loadfile("data/core/global.lua")(conf)
	global.version = version
	global.licenseNotice = licenseNotice
	do
		local f = io.open("COPYING")
		global.license = f:read("*all")
		f:close()
	end
	
	if conf.debug.isDev then
		print(loadfile("data/core/init.lua"))
	end
	local initSuccsess, err = loadfile("data/core/init.lua")(global, ...)
	
	if initSuccsess then
		local core, err = loadfile("data/core/occCore.lua")
		if global.isDev then
			print(core, err)
		end
		local success, returnValues = core(global)
		core = nil
		
		global = nil
		return success, returnValues
	else
		global = nil
		return false, "init failed", err
	end
end

--===== prog end =====--