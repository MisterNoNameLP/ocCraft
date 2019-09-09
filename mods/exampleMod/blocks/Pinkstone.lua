local texture = "pinkstone"

local global = ...

Pinkstone = {}
Pinkstone.__index = Pinkstone

function Pinkstone.new(args)
	args.texture = texture
	local this = global.Block.new(args)
	this = setmetatable(this, Pinkstone)
	
	return this
end

return Pinkstone