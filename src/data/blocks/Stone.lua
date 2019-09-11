local global = ...

Stone = {}
Stone.__index = Stone

function Stone.new(args)
	args.texture = global.textures["stone"]
	local this = global.Block.new(args)
	this = setmetatable(this, Stone)
	
	
	
	return this
end

return Stone