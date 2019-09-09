local global = ...

local flat = {
	height = 5,
}

function flat.generate()
	local fromX, toX, fromY, toY = global.getFOV() --gives fov in blocks.
	
	for x = fromX, toX do
		for y = fromY, toY do
			if y >= flat.height then
				if y < flat.height +3 then
					global.wg.addBlock(x, y, "Grass")
				else
					global.wg.addBlock(x, y, "Stone")
				end
			end
		end
	end
end	

return flat