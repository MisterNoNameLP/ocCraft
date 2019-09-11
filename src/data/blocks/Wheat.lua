local global = ...

Wheat = {}
Wheat.__index = Wheat

function Wheat.new(args)
	args.texture = global.textures["wheat"]
	local this = global.Block.new(args)
	this = setmetatable(this, Wheat)
	
	
	
	return this
end

return Wheat