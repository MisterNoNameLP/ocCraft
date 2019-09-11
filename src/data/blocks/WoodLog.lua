local global = ...

WoodLog = {}
WoodLog.__index = WoodLog

function WoodLog.new(args)
	args.texture = global.textures["woodLog"]
	local this = global.Block.new(args)
	this = setmetatable(this, WoodLog)
	
	
	
	return this
end

return WoodLog