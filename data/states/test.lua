local global = ...

--===== shared vars =====--
local test = {

}

--===== local vars =====--

--===== local functions =====--

--===== shared functions =====--
function test.start()
	--test.block = global.blocks["Grass"].new({posX = 1, posY = 1})
	--test.block = global.Block.new({posX = 1, posY = 1})
end

function test.update()
	
end

function test.draw()
	test.block:draw()
	--global.log(test.block.draw)
end

return test