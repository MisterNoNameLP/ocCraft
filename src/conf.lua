local conf = {
	map = "world", --map name in "saves" dir.
	mapBackup = true, --generate a backup anytime the map become loaded (can overflow the disk! (you can check how much space you have left with "df -h")).
	texturePack = "default", --can be any installed texturePack.
	worldGen = "flat", --can be any loaded biome.
	
	cameraSpeed = 10, --amout of pixels the camera is moving on keyPress.
	
	targetFramerate = 20, --default is "20". set to "-1" for unlimited framerate (can cause in graphical issures).
	maxTickTime = .2, --if a tick need more as the maxTickTime the engine will handle the ticke like it had needs exacly the maxTickTime.
	fpsCheckInterval = 10, --defines what amout of frames the engine use to calculate the avg. fps.
	
	showConsole = false, --can be changes ingame by pressing f1 by default.
	showDebug = false, --can be changes ingame by pressing f3 by default.
	consoleSizeY = 20, --the height of the console.
	
	preferModTextures = true, --if true mods can overwrite texturePack textures.
	
	debug = { --these options are for developers.
		isDev = false, --activates debug outputs (strongly reconnement if you want to mod the game in any way or something goes wrong and you need a detailed log).
		
		wreDebug = false, --print worldRenderEngine debug (only if isDev).
		wgDebug = false, --print worldGenerator debug (only if isDev).
		dlDebug = false, --print dataLoading debug (only if isDev).
		
		showBlockId = false, --shows block id in inv marked with "#".
		drawCollider = false,
		drawTrigger = false,
		
		defaultState = "loadGame",
		
		onReload = { --defined what data/libs are reloaded at state reload.
			conf = true, --should be always true.
			
			--=== core ===--
			wre = false, --should be true if you want to reload blocks.
			wg = false,
			map = false,
			
			--=== data groups ===--
			states = false,
			textures = false,
			blocks = false,
			entities = false,
			biomes = false,
			
			mods = true, --just reloads the activated data groups of the mods (if only onReload.blocks = true he only also reloads the blocks from mods). should be always true.
		},
	}
}

return conf