local global = ...

local Entity = {}
Entity.__index = Entity

function Entity.init()

end

function Entity.new(args)
	local this = setmetatable({}, Entity)
	
	this.posX = args.posX or 0 --pos in world (in blocks).
	this.posY = args.posY or 0 --pos in world (in blocks).
	this.index = args.index or -1 --index in world table.
	
	this.sizeX = ((args.sizeX or 1) * (global.texturePack.size *2))
	this.sizeY = (args.sizeY or 1) * global.texturePack.size
	
	if args.texture == nil then
		args.texture = global.ocgl.generateTexture({})
	elseif type(args.texture) == "string" then
		args.texture = global.textures[args.texture]
	end
	this.texture = args.texture 
	this.looksToLeft = false
	
	local tmpTexture = global.ocgl.generateTexture({})
	if this.texture.right ~= nil then
		tmpTexture = this.texture.right
	else
		tmpTexture = this.texture
	end
	
	this.gameObject = global.ocgf.GameObject.new(global.ocgf, {
		dc = global.conf.debug.drawCollider,
		dt = global.conf.debug.drawTrigger,
		logFunc = global.log;
		
	})
	this.gameObject:addBoxCollider({
		sx = this.sizeX,
		sy = this.sizeY,
	})
	this.gameObject:addRigidBody({
		g = 10,
		stiffness = .5,
	})
	this.gameObject:addSprite({
		texture = tmpTexture
	})
	
	
	this.turn = function(this, toLeft)
		local tmpTexture = nil
		if toLeft then
			this.looksToLeft = true
			tmpTexture = this.texture.left
		else
			this.looksToLeft = false
			tmpTexture = this.texture.right
		end
		if tmpTexture ~= nil then
			for _, s in pairs(this.gameObject:getSprites()) do
				s:clear(global.backgroundColor)
				s:changeTexture(tmpTexture)
			end
		end
	end
	this.move = function(this, x, y)
		this.gameObject:move(x, y)
	end
	this.moveTo = function(this, x, y)
		this.gameObject:moveTo(x, y)
	end
	this.addForce = function(this, x, y, maxSpeed)
		this.gameObject:addForce(x * (global.texturePack.size *2), y * global.texturePack.size, maxSpeed)
	end
	this.setSpeed = function(this, x, y)
		this.gameObject:setSpeed(x, y)
	end
	
	this.pStart = function(this) --parent func 
		global.run(this.start, this)
	end
	this.pUpdate = function(this) --parent func
		global.run(this.update, this)
	end
	this.pActivate = function(this) --parent func
		global.run(this.activate, this)
	end
	this.pDraw = function(this) --parent func
		for _, s in pairs(this.gameObject:getSprites()) do
			s.background = global.backgroundColor
		end
		global.run(this.draw, this)
	end
	this.pClear = function(this) --parent func
		global.run(this.clear, this)
	end
	this.pStop = function(this)
		this.gameObject:stop()
		global.run(this.stop, this)
	end
	this.pSpawn = function(this) --parent func
		global.run(this.spawn, this)
	end
	this.pDespawn = function(this) --parent func
		global.run(this.despawn, this)
	end
	
	return this
end

return Entity