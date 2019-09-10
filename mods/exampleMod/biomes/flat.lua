local global = ...

local flat = {
	height = 5,
}

function flat.generate() --will calles every game tick.
	local fromX, toX, fromY, toY = global.getFOV() --gives fov in blocks.
	
	for x = fromX, toX do
		for y = fromY, toY do
			if y >= flat.height then
				if y < flat.height +3 then
				
					--wg.addBlock() is for biome/worldGen usage only, 
					--cause its only adds the block one time at the pos at all.
					--for anything else you should use wre.addBlock().
					if global.wg.addBlock(x, y, "Grass") then
						--global.log("TT")
					end
					
				else
					global.wg.addBlock(x, y, "Stone")
				end
			end
		end
	end
end	

return flat