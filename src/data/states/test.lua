local global = ...

--===== shared vars =====--
local test = {

}

--===== local vars =====--

--===== local functions =====--

--===== shared functions =====--
function test.start()
	local thread = require("thread")
	
	local t = thread.create(function()
		while true do
			global.orgPrint(global.resX)
			os.sleep(.5)
		end
	end)
	--t:detach()
end

function test.update()
	
end

function test.draw()
	--test.block:draw()
	--global.log(test.block.draw)
end

return test