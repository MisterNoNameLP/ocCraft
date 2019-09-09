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