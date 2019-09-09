local texture = "pinkstone"

local global = ...

Teststone = {}
Teststone.__index = Teststone

function Teststone.init(this) --will calles when the block become loaded/reloaded.
	--global.log("TESTSTONE: init")
end

function Teststone.new(args)
	args.texture = texture
	local this = global.Block.new(args)
	this = setmetatable(this, Teststone)
	
	
	this.placed = function(this) --will called if block become placed.
		--global.log("TESTSTONE: placed")
	end
	
	this.removed = function(this) --will called if block become remove.
		--global.log("TESTSTONE: removed")
	end
	
	this.start = function(this) --will called everytime a new object of the block is created.
		--global.log("TESTSTONE: start")
	end
	
	this.stop = function(this) --will called when block object becomes removed (e.g. out of screen)
		--global.log("TESTSTONE: stop")
	end
	
	this.update = function(this) --will called on every game tick.
		--global.log("TESTSTONE: update")
	end
	
	this.draw = function(this) --will called every time the block will drawed.
		--global.log("TESTSTONE: draw")
	end
	
	this.clear = function(this, acctual) --will called when the block graphics are removed.
		--global.log("TESTSTONE: clear")
	end
	
	this.activate = function(this) --will called when the block get activated by player or signal (not implemented yet).
		global.log("TESTSTONE: activate")
	end
	
	return this
end

return Teststone