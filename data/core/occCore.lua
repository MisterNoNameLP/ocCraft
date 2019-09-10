--===== Requires =====--
local global = ...

--===== Variables =====--
local orgPrint = print
local lastState = ""
local frameCount = 0
local lastFPSCheck = 0

--===== Functions =====--

local function print(...)
	global.log(...)
end

local function run(func, ...)
	if func ~= nil then
		local suc, err = xpcall(func, debug.traceback, ...)
		if not suc then
			print("[ERROR][OCCC]: Tryed to call " .. tostring(func) .. ":")
			print(tostring(err))
			print(debug.traceback())
		end
	end
end

local function updateState() 
	if global.states[global.state] == nil then
		print("[ERROR]: State not found: \"" .. global.state .. "\".")
		global.tbConsole:draw()
		global.isRunning = false
	else
		while global.state ~= lastState do
			if lastState ~= "" then
				run(global.states[lastState].stop)
			end
			lastState = global.state
			if not global.states[global.state].isInitialized then
				run(global.states[global.state].init)
				global.states[global.state].isInitialized = true
			end
			run(global.states[global.state].start)
		end
		if global.states[global.state].update ~= nil then --manual check to avoid log spamming on missing update func.
			run(global.states[global.state].update)
		end
	end
end

local function start()
	global.gpu.setBackground(0x000000)
	global.term.clear()
	
	if global.isDev then
		--global.state = "game"
		global.state = global.conf.debug.defaultState
	else
		--global.state = "game"
		--global.state = "loadGame"
		global.state = global.conf.debug.defaultState
	end
	
	global.lastUptime = global.computer.uptime()
end

local function update()
	global.lastCameraPosX = global.cameraPosX
	global.lastCameraPosY = global.cameraPosY
	
	if frameCount >= global.conf.fpsCheckInterval then
		global.fps = global.conf.fpsCheckInterval / (global.computer.uptime() - lastFPSCheck)
		lastFPSCheck = global.computer.uptime()
		frameCount = 0
	else
		frameCount = frameCount +1
	end
	
	updateState()
	
	
	
	--print(global.cameraPosX, global.cameraPosY)
end

local function draw()
	global.gpu.setBackground(0x000000)
	--global.gpu.fill(1, 1, global.resX, global.resY, " ")
	
	if global.states[global.state].draw ~= nil then	--manual check to avoid log spamming on missing draw func.
		run(global.states[global.state].draw)
	end
	
	global.ocui:draw()
	if global.conf.showConsole then
		global.tbConsole:draw()
	end
end

local function touch(_, _, x, y, b, p)
	global.ocui:update(x, y)
	run(global.states[global.state].touch, x, y, b, p)
end

local function drag(_, _, x, y, b, p)
	run(global.states[global.state].drag, x, y, b, p)
end

local function drop(_, _, x, y, b, p)
	run(global.states[global.state].drop, x, y, b, p)
end

local function keyDown(_, _, c, k, p)
	if c == 3 then --ctrl + c
		print("Program stopped by user.")
		global.isRunning = false
	end
	
	if k == global.controls.debug.showConsole then
		global.conf.showConsole = not global.conf.showConsole
		if not global.conf.showConsole then
			global.clear()
		end
	end
	
	run(global.states[global.state].keyDown, c, k, p)
	
	if k == global.controls.debug.showDebug then --f3
		global.conf.showDebug = not global.conf.showDebug
		if not global.conf.showDebug then
			global.clear()
		end
	end
	if k == global.controls.debug.reloadState and global.isDev then --f5
		global.log("========== RELOAD STAGE ==========")
		run(global.states[global.state].stop)
		global.states[global.state] = nil
		
		if global.conf.debug.onReload.conf then
			global.conf = dofile("conf.lua")
		end
		global.conf.debug.onReload.reload = true
		global.load(global.conf.debug.onReload)
		global.conf.debug.onReload.reload = nil
		
		global.states[global.state] = loadfile("data/states/" .. global.state .. ".lua")(global)
		run(global.states[global.state].init)
		run(global.states[global.state].start)
		
		global.clear()
	end
	if k == global.controls.debug.rerenderScreen then --f6
		global.clear()
	end
	
end

local function keyUp(_, _, c, k, p)
	run(global.states[global.state].keyUp, c, k, p)
end

local function progamEnd()
	global.event.ignore("touch", touch)
	global.event.ignore("drag", drag)
	global.event.ignore("drop", drop)
	global.event.ignore("key_down", keyDown)
	global.event.ignore("key_up", keyUp)
	
	for _, s in pairs(global.states) do
		run(s.stop)
	end
	
	global.tbConsole:draw()
	global.ocl.close()
end

--===== global.event listening =====--
global.event.listen("touch", touch)
global.event.listen("drop", drop)
global.event.listen("drag", drag)
global.event.listen("key_down", keyDown)
global.event.listen("key_up", keyUp)

--===== std program structure / main while =====--
local std_previousScreenResolution = {global.gpu.getResolution()}
local std_success = true
local function std_onError(f, ...)
	print = orgPrint
	global.isRunning = false
	std_success = false
	global.gpu.setForeground(0xff0000)
	global.gpu.setBackground(0x000000)
	print("[ERROR] in func: " .. f)
	print(...)
	global.gpu.setForeground(0xffffff)
	global.fatal("In func: " .. tostring(f))
	global.fatal(...)
end

local s, m = xpcall(start, debug.traceback)
if s == false then
	std_onError("start()", m, debug.traceback())
end

while global.isRunning do
	local s, m = xpcall(update, debug.traceback)
	if s == false then
		std_onError("update()", m, debug.traceback())
		break
	end
	
	if global.isRunning then
		local s, m = xpcall(draw, debug.traceback)
		if s == false then
			std_onError("draw()", m, debug.traceback())
			break
		end
	end
	
	global.dt = global.computer.uptime() - global.lastUptime
	global.lastUptime = global.computer.uptime()
	
	if global.conf.targetFramerate == -1 then
		os.sleep()
	else
		os.sleep((1 / global.conf.targetFramerate) - math.max(global.dt - (1 / global.conf.targetFramerate), 0))
	end
end

progamEnd()
global.gpu.setForeground(0xffffff)
global.gpu.setBackground(0x000000)
global.gpu.setResolution(std_previousScreenResolution[1], std_previousScreenResolution[2])

return std_success, "failed"