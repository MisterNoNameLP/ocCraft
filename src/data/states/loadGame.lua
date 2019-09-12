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
local loadGame = {
	
}

--===== local vars =====--

--===== local functions =====--

--===== shared functions =====--
function loadGame.init()
	
end

function loadGame.start()
	global.gpu.setBackground(global.backgroundColor)
	global.gpu.setForeground(0xffffff)
	global.term.clear()
	
	local s1 = "ocCraft " .. global.version
	local s2 = "Loading..."
	
	local noticeLines = 0
	for s in string.gmatch(tostring(global.licenseNotice), "[^\r\n]+") do
		noticeLines = noticeLines +1
	end
	
	global.gpu.set((global.resX /2) - (#s1 /2), (global.resY /2) -1 - (noticeLines /2), s1)
	global.gpu.set((global.resX /2) - (#s2 /2), global.resY /2  - (noticeLines /2), s2)
	
	local count = 3
	for s in string.gmatch(tostring(global.licenseNotice), "[^\r\n]+") do
		global.gpu.set((global.resX /2) - (#s /2), (global.resY /2) + count - (noticeLines /2), s)
		global.log(s)
		count = count +1
	end
	
	global.states["game"].init()
	global.states["game"].isInitialized = true
	
	global.state = "game"
end

function loadGame.update()
	
end

function loadGame.draw()
	
end

return loadGame