local global = ...

Leaves = {}
Leaves.__index = Leaves

function Leaves.new(args)
	args.texture = global.textures["leaves"]
	local this = global.Block.new(args)
	this = setmetatable(this, Leaves)
	
	this.update = function(this)
		
		
	end
	
	return this
end

return Leaves