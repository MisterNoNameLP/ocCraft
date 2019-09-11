local global = ...

Player = {}
Player.__index = Player

function Player.new(args)
	args.sizeY = 2
	args.texture = global.textures["player"]
	local this = global.Entity.new(args)
	this = setmetatable(this, Player)
	
	this.ocui = global.ocui.initiate(global.ocgl)
	
	this.lInv = this.ocui.List.new(this.ocui, 0, 2, 30, 0, {}, {conf = {true}}) --regenerated on inv open.
	
	this.inv = {}
	this.showInv = false
	this.invKeyIsPressed = false
	this.selected = 1
	
	this.isCreative = false
	this.range = 1000
	this.acceleraion = 20
	this.maxSpeed = 30 --bug: cant be more than the texturepack size (ocgf rigidbody)
	this.jumpForce = 1
	this.breakDamage = 1
	
	
	this.gameObject:addBoxTrigger({
		x = 0, 
		y = 0, 
		sx = global.texturePack.size *2, 
		sy = (global.texturePack.size * 2) +1, 
		lf = function() 
			this.isJumping = false
		end,
	}) --ToDo: trigger y size texturepack bla.
	
	this.update = function(this) 
		this.gameObject:spriteStop(nil, true)
		if global.keyboard.isKeyDown(global.controls.left) then
			this:addForce(- (this.acceleraion * global.texturePack.size), 0, this.maxSpeed)
			this.gameObject:spritePlay(-1)
			this:turn(true)
		end
		if global.keyboard.isKeyDown(global.controls.right) then
			this:addForce(this.acceleraion * global.texturePack.size, 0, this.maxSpeed)
			this.gameObject:spritePlay()
			this:turn(false)
		end
		
		if global.keyboard.isKeyDown(global.controls.jump) then
			if this.isJumping == false then
				this:addForce(0, - (this.jumpForce * global.texturePack.size))
				this.isJumping = true
			end
			
		end
		if global.keyboard.isKeyDown(global.controls.sneak) then
			
		end
	end
	
	this.draw = function(this)
		if this.showInv then
			this.ocui:draw()
			
			global.gpu.setBackground(0x555555)
			global.gpu.setForeground(0xaaaaaa)
			global.gpu.set(1, 1, "  --===== Inventory =====--  ")
		end
	end
	
	this.keyDown = function(this, c, k, p)
		if k == global.controls.inv and this.invKeyIsPressed == false then
			this.showInv = not this.showInv
			this.invKeyIsPressed = true
			if this.showInv then
				this.lInv:stop()
				this.lInv = nil
				
				local inv = {}
				for i, c in pairs(this.inv) do
					local id = ""
					if global.conf.debug.showBlockId then
						id = " (#" .. i .. ")"
					end
					table.insert(inv, i .. c.name .. id .. " (" .. c.amout .. ")")
				end
				
				local sizeY  = 0
				if global.conf.showConsole then 
					sizeY = global.resY - global.conf.consoleSizeY -3
				else
					sizeY = global.resY -2
				end
				this.lInv = this.ocui.List.new(this.ocui, 0, 2, 30, sizeY, inv, {config = {true, -1}, listedFunction = function(_, content)
					this:select(string.sub(content, 1))
					this.showInv = false
					global.clear()
				end})
			else
				global.clear()
			end
		end
	end
	
	this.keyUp = function(this, c, k, p)
		if k == global.controls.inv then
			this.invKeyIsPressed = false
		end
	end
	
	this.touch = function(this, x, y, b, p, drag)
		local fromX = this.gameObject.posX - (this.range * (global.texturePack.size *2))
		local fromY = this.gameObject.posY - (this.range * (global.texturePack.size))
		local toX = this.gameObject.posX + ((this.range +1) * (global.texturePack.size *2))
		local toY = this.gameObject.posY + ((this.range +2) * (global.texturePack.size))
		
		if this.showInv == false and x > fromX and x < toX and y > fromY and y < toY then
			local bx, by = global.getBlockPos(x, y)
			
			if global.keyboard.isAltDown() and b == global.controls.place then
				b = global.controls.broke
			elseif global.keyboard.isAltDown() and b == global.controls.broke then
				b = global.controls.place
			end
			
			if b == global.controls.place and 
				this.inv[this.selected] ~= nil and
				this.inv[this.selected].amout > 0
			then
				if this.isCreative == false and this.inv[this.selected].amout <= 1 then
					this.inv[this.selected] = nil
				elseif this.isCreative == false then
					this.inv[this.selected].amout = this.inv[this.selected].amout -1
				end
				global.wre.addBlock(bx, by, this.selected)
			elseif b == global.controls.broke then --ToDo: add break damage check.
				local removed, block = global.wre.removeBlock(bx, by)
				if block ~= nil then
					this:addToInv(block, 1)
				end
			end
		end
	end
	
	this.drag = function(this, x, y, b, p)
		this:touch(x, y, b, p, true)
	end
	
	this.drop = function(this, x, y, b, p)
		this.ocui:update(x, y)
	end
	
	this.addToInv = function(this, block, amout)
		if type(block) == "string" then
			block = global.blocks.id[block]
		end
		
		if type(block) ~= "number" then
			global.warn("Tryed to add invalid block to player inv: " .. tostring(block))
			return false
		end
		
		if this.inv[block] == nil then
			this.inv[block] = {amout = amout, name = global.blocks.name[block]}
		else
			this.inv[block].amout = this.inv[block].amout +amout
		end
		return true
	end
	
	this.select = function(this, c)
		if type(c) == "string" then
			c = tonumber(string.sub(c, 0, 1))
		end
		this.selected = c
	end
	
	this.stop = function(this)
		this.ocui:stop()
	end
	
	return this
end

return Player