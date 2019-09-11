local global = ...

--===== shared vars =====--
local mm = {

}

--===== local vars =====--

--===== local functions =====--

--===== shared functions =====--
function mm.init()
	--[[
	global.load({textures = true})
	mm.ocui = global.ocui.initiate(global.ocgl)
	
	mm.bTexturePackTest = mm.ocui.Button.new(mm.ocui, 2, 1, 40, 3, {texture0 = global.textures.buttons.bTextureTest, texture1 = global.textures.buttons.bTextureTest, listedFunction = function()
		global.state = "game"
		global.clear() 
	end})
	]]
end

function mm.start()
	--global.log("MM")
end


function mm.update()
	
end

function mm.draw()
	mm.ocui:draw()
end

function mm.touch(x, y, b, p)
	mm.ocui:update(x, y)
end

return mm