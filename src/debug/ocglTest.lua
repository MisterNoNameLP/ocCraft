--[PROG_NAME] (NNSPT_v1.2)
local version = "v0.0"

--===== Requires =====--
local component = require("component")
local computer = require("computer")
local event = require("event")
local term = require("term")
local serialization = require("serialization")
local gpu = component.gpu
local mainOcgl = dofile("libs/ocgl.lua").initiate(gpu)
local ocui = dofile("libs/ocui.lua").initiate(mainOcgl)
local ocgl = dofile("libs/ocgl.lua").initiate(gpu)

--===== Variables =====--
local consoleSizeY = 30

local orgPrint = print
local texture = dofile("debug/testTexture.lua")
local animation = dofile("debug/testAnimation.lua")
local background = dofile("texturePacks/default/textures/grass.lua")

local tbConsole = ocui.TextBox.new(ocui, {x=1, y=10, sx=0, sy=0, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333})

local anim = ocgl.Animation.new(ocgl, animation, {})

--===== Functions =====--
local function print(...)
	tbConsole:add(...)
end
function cprint(...)
	tbConsole:add(...)
end
function sprint(...)
	tbConsole:add(serialization.serialize(...))
	ocui:draw()
end

local function start()
	term.clear()
	local resX, resY = gpu.getResolution()
	tbConsole.sizeX = resX
	tbConsole.sizeY = resY - (resY - consoleSizeY)
	tbConsole.posY = resY - consoleSizeY
	
end

local function update()
	texture = dofile("debug/testTexture.lua")
	
end

local function draw()
	gpu.setBackground(0x000000)
	--term.clear()
	--cgl:draw(40, 1, texture)
	anim:stop(nil, true)
	anim:play(-1)
	anim:draw(40, 1, .1)
	
	
	gpu.set(1, 1, tostring(anim.currentFrame))
	gpu.set(1, 2, tostring(anim.lastFrame))
	
	ocui:draw()
end

local function touch(_, _, x, y, _, _)
	
end

local function progamEnd()
	event.ignore("touch", touch)
end

--===== Event listening =====--
event.listen("touch", touch)

--===== std program structure / main while =====--
--local std_sleepTime = 2^32
local std_sleepTime = .1
local std_programIsRunning = true
local std_previousScreenResolution = {gpu.getResolution()}
local function std_onError(f, ...)
	print = orgPrint
	std_programIsRunning = false
	gpu.setForeground(0xff0000)
	gpu.setBackground(0x000000)
	print("[ERROR] in func: " .. f)
	print(...)
	gpu.setForeground(0xffffff)
end

local s, m = xpcall(start, debug.traceback)
if s == false then
	std_onError("start()", m, debug.traceback())
end

while std_programIsRunning do
	local s, m = xpcall(update, debug.traceback)
	if s == false then
		std_onError("update()", m, debug.traceback())
		break
	end
	
	local s, m = xpcall(draw, debug.traceback)
	if s == false then
		std_onError("draw()", m, debug.traceback())
		break
	end
	
	local _, _, key = event.pull(std_sleepTime, "key_down")
	if key == 3 then --ctrl+c
		std_programIsRunning = false
		break
	end
end

progamEnd()
gpu.setForeground(0xffffff)
gpu.setBackground(0x000000)
gpu.setResolution(std_previousScreenResolution[1], std_previousScreenResolution[2])
