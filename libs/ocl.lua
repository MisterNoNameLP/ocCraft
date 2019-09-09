--ToDo: make it object oriented.

local ocl = { version = "v1.0.5",
	conf = {
		logFile = "logs/occ.log",
	},
	
	logFile = {},
}

local filesystem = require("filesystem")
local shell = require("shell")
local ut = require("libs/UT")

function ocl.open(path)
	if path ~= nil then
		ocl.conf.logFile = path
	end
	local dir, fileName, fileEnd = ut.seperatePath(ocl.conf.logFile)
	fileEnd = fileEnd or ""
	if string.sub(ocl.conf.logFile, 0, 1) ~= "/" then
		dir = shell.getWorkingDirectory() .. "/" .. dir
	end
	filesystem.makeDirectory(dir)
	
	local file = io.open(dir .. fileName .. fileEnd, "r")
	if file == nil then
		ocl.logFile = io.open(dir .. fileName .. fileEnd, "w")
	else
		file:close()
		local count = 1
		while true do
			file = io.open(dir .. fileName .. "(" .. tostring(count) .. ")" .. fileEnd, "r")
			if file == nil then
				ocl.logFile = io.open(dir .. fileName .. "(" .. tostring(count) .. ")" .. fileEnd, "w")
				break
			end
			file:close()
			count = count +1
		end
	end
end

function ocl.add(...)
	local text = ""
	for _, s in ipairs({...}) do
		text = text .. tostring(s)
	end
	ocl.logFile:write(tostring(text))
	ocl.logFile:write("\n")
	ocl.logFile:flush()
end

function ocl.close()
	ocl.logFile:close()
end

return ocl