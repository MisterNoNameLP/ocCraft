local global = ...

Grass = {}
Grass.__index = Grass

function Grass.new(args)
	args.texture = "grass" --can be any loaded texture.
	local this = global.Block.new(args)
	this = setmetatable(this, Grass)
	
	this.update = function(this)
		local posX, posY, blockId = this:getPos()
		
		--===== remove grass if block above it. =====--
		if global.getBlock(posX, posY -1) ~= nil then 
			global.wre.removeBlock(posX, posY)
			global.wre.addBlock(posX, posY, "Dirt")
			return
		end
		
		--===== convert neighbor dirt to grass. =====--
		for x = posX -1, posX +1 do
			for y = posY -1, posY +1 do
				if global.getBlock(x, y -1) == nil and select(2, global.getBlock(x, y)) == "Dirt" then
					global.wre.removeBlock(x, y)
					global.wre.addBlock(x, y, "Grass")
				end
			end
		end
	end
	
	return this
end

return Grass