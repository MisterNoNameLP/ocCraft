local args = {...}
local global = args[1]

--===== dev =====--
local orgRequire = require
local require = require
if global.isDev then
	require = function(s)
		if io.open(s .. ".lua", "r") == nil then
			return orgRequire(s)
		else
			return dofile(s .. ".lua")
		end
	end
end

--===== global vars =====--
--global.tl = require("libs/tl") --debug/testing
global.fs = require("filesystem")
global.shell = require("shell")
global.event = require("event")
global.term = require("term")
global.ut = require("libs/UT")
global.ocl = require("libs/ocl")
global.computer = require("computer")
global.keyboard = require("keyboard")
global.serialization = require("serialization")
global.component = require("component")
global.gpu = global.component.gpu
global.ocgl = require("libs/ocgl").initiate(global.gpu)
global.ocui = require("libs/ocui").initiate(global.ocgl)
global.ocgf = require("libs/ocgf")
--print(loadfile("data/worldGen.lua"))
global.wg = loadfile("data/core/wg.lua")(global)
--print(loadfile("data/core/wre.lua"))
global.wre = loadfile("data/core/wre.lua")(global)

global.resX, global.resY = global.gpu.getResolution()

--=== debug ===--
global.ocl.open()
global.tbConsole = global.ocui.TextBox.new(global.ocui, {x=1, y=0, sx=0, sy=0, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333, managed = {draw = false}})
global.setConsoleSize()

--=== load data ===--
if global.isDev then
	print(loadfile("data/core/dataLoading.lua"))
end
global.load({
	states = true,
}, global.orgPrint)

--====== init end ======--
return true