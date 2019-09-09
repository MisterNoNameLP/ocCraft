local global = ...

Bedrock = {}
Bedrock.__index = Bedrock

function Bedrock.new(args)
	args.texture = global.textures["bedrock"]
	args.hardness = -1
	local this = global.Block.new(args)
	this = setmetatable(this, Bedrock)
	
	
	
	return this
end

return Bedrock