local fs = require("filesystem")
local gpu = require("component").gpu
local ocgl = require("libs/ocgl").initiate(gpu)
local term = require("term")
local keyboard = require("keyboard")
local event = require("event")
local computer = require("computer")
local serialize = require("serialization").serialize

--term.clear()


--[[
cprint = print

local t1 = dofile("debug/testClass1.lua").new()
local t2 = dofile("debug/testClass2.lua").new()

t1.test()
t1.test2()

t2.test()
t2.test2()
]]
--[[
local texture = dofile("texturePacks/default/testTexture.lua")

local lt, dt = computer.uptime(), 0

while true do
	--gpu.setBackground(0x000000)
	--gpu.fill(1, 1, 1000, 1000, " ")
	
	for c = 0, 10 do
		ocgl:draw(10, 10, texture)
	end
	
	
	dt = computer.uptime() -lt
	lt = computer.uptime()
	
	os.sleep()
	gpu.set(1, 1, tostring(dt) .. "                        ")
	if dt > 0.05 then
		--print(">")
	end
end
]]