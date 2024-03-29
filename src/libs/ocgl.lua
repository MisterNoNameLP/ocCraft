--[[
    ocgf Copyright (C) 2019 MisterNoNameLP.
	
    This library is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this library.  If not, see <https://www.gnu.org/licenses/>.
]]

local OCGL = {version = "v1.3.2"} --OpenComputersGraphicLibary
OCGL.__index = OCGL


--===== local vars =====--
local tmpTexture = {
	textureFormat = "OCGLT",
	version = "v0.2",
	drawCalls = {},
}
local computer = require("computer")

--===== local functions =====--
local function addFrameTime(this, dt, backwards)
	this.lastFrame = this.currentFrame
	this.currentFrame = (this.currentFrame + (dt * this.speed))
end

local function parseArgs(...) --ripped from UT_v0.6
	for _, a in pairs({...}) do
		if a ~= nil then
			return a
		end
	end
end

local function parseLink(this, posX, posY, v, func, ...)
	if #v == 1 then
		tmpTexture.drawCalls = v[1]
		func(this, posX, posY, tmpTexture, ...)
	else
		tmpTexture.drawCalls = v[3]
		func(this, posX + v[1], posY + v[2], tmpTexture, ...)
	end
	tmpTexture.drawCalls = {}
end

--===== global functions =====--
function OCGL.initiate(gpu)
	local this = setmetatable({}, OCGL)
	
	this.gpu = gpu
	this.resX, this.resY = gpu.getResolution()
	this.pFColor, this.pBColor = gpu.getForeground(), gpu.getBackground()
	
	return this
end

function OCGL.draw(this, posX, posY, texture, checkColor)
	if checkColor == nil or checkColor == true then
		this.pFColor, this.pBColor = this.gpu.getForeground(), this.gpu.getBackground()
	end
	
	for c, v in ipairs(texture.drawCalls or texture) do 
		if #v == 1 or type(v[3]) == "table" then --link
			parseLink(this, posX, posY, v, OCGL.draw, checkColor)
		elseif #v == 3 or #v == 4 then --set
			if v[1] +posX <= this.resX and v[2] +posY <= this.resY then
				if v[4] and v[1] +posX >= 0 and v[2] +posY +#v[3] >= 0 then
					this.gpu.set(v[1] +posX, v[2] +posY, v[3], v[4])
				elseif v[2] +posY >= 0 and v[1] +posX +#v[3] >= 0 then
					this.gpu.set(v[1] +posX, v[2] +posY, v[3])
				end
			end
		elseif #v == 5 then --fill
			if v[1] +posX <= this.resX and v[2] +posY <= this.resY and v[1] +v[3] +posX >= 0 and v[2] +v[4] +posY >= 0 then
				this.gpu.fill(v[1] +posX, v[2] +posY, v[3], v[4], v[5])
			end
		else --color change
			if v[1] == "b" and v[2] ~= this.pBColor then
				this.gpu.setBackground(v[2])
			elseif v[1] == "f" and v[2] ~= this.pFColor then
				this.gpu.setForeground(v[2])
			end
		end
	end
	
end

function OCGL.clearBlack(this, posX, posY, texture, color)
	this.gpu.setBackground(color or 0x000000)
	this.gpu.setForeground(color or 0x000000)
	for c, v in ipairs(texture.drawCalls or texture) do
		if #v == 1 or type(v[3]) == "table" then --link
			parseLink(this, posX, posY, v, OCGL.clearBlack, color)
		elseif #v == 3 or #v == 4 then
			this.gpu.set(v[1] +posX, v[2] +posY, v[3])
		elseif #v == 5 then
			this.gpu.fill(v[1] +posX, v[2] +posY, v[3], v[4], " ")
		end
	end
end

function OCGL.generateTexture(...)
	local t = {}
	if type(...) ~= "table" then
		t = {...}
	else
		t = ...
	end
	if #t == 5 then
		return {textureFormat = "OCGLT", version = "v0.1", drawCalls = {{"f", t[1]}, {"b", t[2]}, {0, 0, t[3], t[4], t[5]}}}
	elseif #t == 3 or #t == 4 then
		return {textureFormat = "OCGLT", version = "v0.1", drawCalls = {{"f", t[1]}, {"b", t[2]}, {0, 0, t[3], t[4] or false}}}
	else
		return {textureFormat = "OCGLT", version = "v0.1", drawCalls = {}}
	end
end

function OCGL.getColors(t, n)
	local fColor, bColor = nil, nil
	for c = n, 1, -1 do
		if t.drawCalls[c][1] == "f" and fColor == nil then
			fColor = t.drawCalls[c][2]
		end
		if t.drawCalls[c][1] == "b" and bColor == nil then
			bColor = t.drawCalls[c][2]
		end
	end
	return {"f", fColor or 0x000000}, {"b", bColor or 0x000000}
end

function OCGL.clear(this, posX, posY, texture, backgroundTextures, checkOverlap) --ToDo: add "OCGLT_v0.2" support.
	if backgroundTextures == nil then
		this.clearBlack(this, posX, posY, texture)
		return
	end
	if checkOverlap == nil then
		checkOverlap = true
	end
	
	--local write = function(...) io.write(tostring(...)) end --Debug
	--local serialization = require("serialization") --Debug
	
	local toDraw = {drawCalls = {}}
	local toCheck = {}
	local isCheckt = {}
	local pFColor, pBColor = nil, nil
	local fColor, bColor = nil, nil
	
	for c = 1, #backgroundTextures do
		isCheckt[c] = {}
	end
	
	local function SetCall(btdc, bt, c, c2)
		if toDraw[c] == nil then
			toDraw[c] = {}
			
			for c2 = 1, #bt[3].drawCalls, 1 do
				toDraw[c][c2] = {}
			end
		end
		
		if #btdc == 3 or #btdc == 4 then
			toDraw[c][c2] = {btdc[1] +bt[1], btdc[2] +bt[2], btdc[3], btdc[4]}
		elseif #btdc == 5 then
			toDraw[c][c2] = {btdc[1] +bt[1], btdc[2] +bt[2], btdc[3], btdc[4], btdc[5]}
		end
		
		if checkOverlap then
			table.insert(toCheck, {btdc, bt[1], bt[2]})
		end
		
		isCheckt[c][c2] = true
	end
	
	if checkOverlap then
		local old = SetCall
		SetCall = function(btdc, bt, c, c2)
			old(btdc, bt, c, c2)
			toDraw[c][c2].bc = fColor
			toDraw[c][c2].fc = bColor
		end
	else
		local old = SetCall
		SetCall = function(btdc, bt, c, c2)
			old(btdc, bt, c, c2)
			if fColor ~= pFColor then
				toDraw[c][c2].bc = fColor
				pFColor = fColor
			end
			if bColor ~= pBColor then
				toDraw[c][c2].fc = bColor
				pBColor = bColor
			end
		end
	end
	
	local function CheckOverlab(dc, backgroundTextures, posX, posY)
		for c, bt in ipairs(backgroundTextures) do
			for c2, btdc in ipairs(bt[3].drawCalls or bt[3]) do
				if isCheckt[c][c2] ~= true then
					if #btdc == 3 or #btdc == 4 then
						if #dc == 3 or #dc == 4 then
							if dc[1] +posX < btdc[1] +bt[1] +#btdc[3] and dc[1] +posX +#dc[3] > btdc[1] +bt[1] and dc[2] +posY == btdc[2] +bt[2] then
								SetCall(btdc, bt, c, c2)
							end
						elseif #dc == 5 then
							if dc[1] +posX < btdc[1] +bt[1] +#btdc[3] and dc[1] +posX +dc[3] > btdc[1] +bt[1] and dc[2] +posY <= btdc[2] +bt[2] and dc[2] +posY +dc[4] > btdc[2] +bt[2] then
								SetCall(btdc, bt, c, c2)
							end	
						end
					elseif #btdc == 5 then
						if #dc == 3 or #dc == 4 then
							if dc[1] +posX < btdc[1] +bt[1] +btdc[3] and dc[1] +posX +#dc[3] > btdc[1] +bt[1] and dc[2] +posY < btdc[2] +bt[2] +btdc[4] and dc[2] +posY > btdc[2] +bt[2] then
								SetCall(btdc, bt, c, c2)
							end
						elseif #dc == 5 then
							if dc[1] +posX < btdc[1] +bt[1] +btdc[3] and dc[1] +posX +dc[3] > btdc[1] +bt[1] and dc[2] +posY < btdc[2] +bt[2] +btdc[4] and dc[2] +posY +dc[4] > btdc[2] +bt[2] then
								SetCall(btdc, bt, c, c2)
							end
						end
					else
						if btdc[1] == "f" then
							fColor = btdc
						end
						if btdc[1] == "b" then
							bColor = btdc
						end
					end
				end
			end
		end
	end
	
	for c, dc in ipairs(texture.drawCalls) do
		CheckOverlab(dc, backgroundTextures, posX, posY)
	end
	
	if checkOverlap then
		for c, tc in ipairs(toCheck) do
			CheckOverlab(tc[1], backgroundTextures, tc[2], tc[3])
		end
	end
	
	local graphic = {drawCalls = {}}
	for c, v in pairs(toDraw) do
		for c, v2 in pairs(v) do
			if #v2 ~= 0 then
				table.insert(graphic.drawCalls, v2.fc)
				table.insert(graphic.drawCalls, v2.bc)
				table.insert(graphic.drawCalls, v2)
			end
		end
	end
	
	this:draw(0, 0, graphic)
	this.gpu.setForeground(0xffffff)
	--write(#graphic.drawCalls .. " ")
	
end

function OCGL.convertToPixels(this, g, s) --WIP
	local newG = {}
	local oNewG = {}
	s = s or 1
	
	for c, v in ipairs(g.drawCalls) do
		if #v == 3 or #v == 4 then
			for c = 1, #v[3], s do
				newG[#newG +1] = {v[1] +c, v[2], string.sub(v[3], c, c +s -1), v[4]}
			end
		elseif #v == 5 then
			local fillString = ""
			for c = 1, s, 1 do
				fillString = fillString .. v[5]
			end
			
			for c = 1, v[4], 1 do
				for c2 = 1, v[3], s do
					local tm = c2 +#fillString - v[3]
					if tm < 0 then
						tm = 0
					end
					newG[#newG +1] = {v[1] +c2, v[2] +c -1, string.sub(fillString, tm)}
				end
			end
		else
			newG[#newG +1] = v
		end
	end
	
	local count = 0
	for c, v in ipairs(newG) do
		count = count +1
		if count > 1000 then
			os.sleep()
			count = 0
		end
		
		if #v ~= 2 then
			local set = true
			
			for c2 = c +1, #newG, 1 do
				if #newG[c2] ~= 2 and v[2] == newG[c2][2] then
					if v[1] == newG[c2][1] or v[1] > newG[c2][1] and v[1] +#v[3] < newG[c2][1] +#newG[c2][3] then
						set = false
						break
					end
				end
			end
			
			if set then
				oNewG[#oNewG +1] = v
			end
		else
			oNewG[#oNewG +1] = v
		end
	end 
	
	return {textureFormat = "OCGLT", version = "v0.1", drawCalls = oNewG}
end 



function OCGL.convertToRaster(this, g, s) --WIP
	local newG = {}
	s = s or 1
	
	for c, v in ipairs(g.drawCalls) do
		if #v == 3 or #v == 4 then
			
			
			
		elseif #v == 5 then
			
		else
			
		end
	end
	
	return {textureFormat = "OCGLTT", version = "v0.1", drawCalls = newG}
end


--===== animator =====-- --WIP
OCGL.Animation = {}
OCGL.Animation.__index = OCGL.Animation

function OCGL.Animation.new(ocgl, animation, args) --no ocgl...
	this = setmetatable({}, OCGL.Animation)
	
	args = args or {}
	this.ocgl = ocgl
	
	this.animation = animation
	this.speed = args.speed or 1
	this.useDt = parseArgs(args.dt, true)
	this.clear = parseArgs(args.clear, true)
	this.background = args.background
	this.halt = parseArgs(args.halt, false)
	this.tmpHalt = false
	
	this.currentFrame = args.frame or 1
	this.lastFrame = this.currentFrame
	this.lastCall = 0 --time in sec.
	
	return this
end

function OCGL.Animation.draw(this, posX, posY, dt, clear, background)
	if parseArgs(clear, this.clear) then
		background = parseArgs(background, this.background)
		if background == nil or type(background) == "number" then
			this:clearBlack(posX, posY, false, background)
		else
			this:clear(posX, posY, background, true, false)
		end
	end
	
	this.ocgl:draw(posX, posY, this.animation.frames[math.floor(this.currentFrame)])
	
	if parseArgs(dt, this.dt) == false then
		addFrameTime(this, 1, backwards)
		return
	end
	
	if dt == nil or dt == true then
		dt = computer.uptime() - this.lastCall
		this.lastCall = computer.uptime()
	end
	
	addFrameTime(this, (dt / this.animation.frameTime), backwards)
	
	if math.floor(this.currentFrame) > #this.animation.frames then
		this.currentFrame = 1
		if this.halt or this.tmpHalt then
			this.speed = 0
			this.tmpHalt = false
		end
	elseif math.floor(this.currentFrame) < 1 then
		this.currentFrame = #this.animation.frames +.9
		if this.halt or this.tmpHalt then
			this.speed = 0
			this.currentFrame = 1
			this.tmpHalt = false
		end
	end
end

function OCGL.Animation.clearBlack(this, posX, posY, current, color)
	if current == true then
		this.ocgl:clearBlack(posX, posY, this.animation.frames[math.floor(this.currentFrame)], color)
	elseif current == false then
		this.ocgl:clearBlack(posX, posY, this.animation.frames[math.floor(this.lastFrame)], color)
	else
		this.ocgl:clearBlack(posX, posY, this.animation.frames[math.floor(this.currentFrame)], color)
		this.ocgl:clearBlack(posX, posY, this.animation.frames[math.floor(this.lastFrame)], color)
	end
end

function OCGL.Animation.clear(this, posX, posY, textures, checkOverlap, current) --useless yet (not supporting "OCGLT_v0.2"/"OCGLA_v0.1".)
	if current then
		this.ocgl:clear(posX, posY, this.animation.frames[math.floor(this.currentFrame)], textures, checkOverlap)
	else
		this.ocgl:clear(posX, posY, this.animation.frames[math.floor(this.lastFrame)], textures, checkOverlap)
	end
end

function OCGL.Animation.start(this, speed, frame)
	this.speed = speed or 1
	this.currentFrame = frame or 1
	this.tmpHalt = false
end

function OCGL.Animation.stop(this, frame, playTilEnd)
	if playTilEnd then
		this.tmpHalt = true
	else
		this.speed = 0
		this.frame = frame or 1
	end
end

function OCGL.Animation.pause(this)
	this.speed = 0
end

function OCGL.Animation.play(this, speed)
	this.speed = speed or 1
	this.tmpHalt = false
end


return OCGL

--print(string.sub("1234567890", 0, #"1234567890" -3))
--print(string.sub("1234567890", #"1234567890" -3 +1))





