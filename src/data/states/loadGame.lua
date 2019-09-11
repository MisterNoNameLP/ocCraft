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
	
	global.gpu.set((global.resX /2) - (#s1 /2), (global.resY /2) -1, s1)
	global.gpu.set((global.resX /2) - (#s2 /2), global.resY /2, s2)
	
	global.states["game"].init()
	global.states["game"].isInitialized = true
	
	global.state = "game"
end

function loadGame.update()
	
end

function loadGame.draw()
	
end

return loadGame