local global = ...

Dirt = {}
Dirt.__index = Dirt

function Dirt.new(args)
	args.texture = global.textures["dirt"]
	local this = global.Block.new(args)
	this = setmetatable(this, Dirt)
	
	return this
end

return Dirt