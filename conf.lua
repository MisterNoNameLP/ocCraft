local conf = {
	map = "test", --map name in "saves" dir.
	mapBackup = false, --generate a backup anytime the map become loaded.
	texturePack = "default", --can be any installed texturePack.
	worldGen = "flat", --can be any loaded biome.
	
	cameraSpeed = 10, --amout of pixels the camera is moving on keyPress.
	
	targetFramerate = 20, --default is "20". set to "-1" for unlimited framerate (can cause in graphical issures).
	maxTickTime = .2, --if a tick need more as the maxTickTime the engine will handle the ticke like it had needs exacly the maxTickTime.
	fpsCheckInterval = 10, --defines what amout of frames the engine use to calculate the avg. fps.
	
	showConsole = true, --can be changes ingame by pressing f1 by default.
	showDebug = true, --can be changes ingame by pressing f3 by default.
	consoleSizeY = 35,
	
	debug = { --these options are for developers.
		isDev = true, --activated debug outputs (strongly reconnement if you want to mod the game in any way or something goes wrong and you need a detailed log).
		
		wreDebug = false, --print worldRenderEngine debug (only if isDev).
		wgDebug = false, --print worldGenerator debug (only if isDev).
		dlDebug = false, --print dataLoading debug (only if isDev).
		
		showBlockId = true, --shows block id in inv marked with "#".
		drawCollider = false,
		drawTrigger = false,
		
		onReload = { --defined what data/libs are reloaded at state reload.
			conf = true, --should be always true.
			
			wre = true,
			wg = false,
			map = true,
			
			states = false,
			textures = false,
			blocks = true,
			entities = false,
			biomes = false,
			mods = true,
		},
	}
}

return conf