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