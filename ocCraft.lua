--[[ocCraft:
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
local version = "v0.0.11.7"

--===== prog start =====--
do
	print("Initialize ocCraft " .. version)
	local conf = dofile("conf.lua")
	if conf.debug.isDev then
		print(loadfile("data/core/global.lua"))
	end
	local global = loadfile("data/core/global.lua")(conf)
	global.version = version
	
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