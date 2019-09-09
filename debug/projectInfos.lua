--[[A very simple project info collector.
	Written by:
		MisterNoNameLP.
]]

local args = {...}

local fs = require("filesystem")
local shell = require("shell")

local dirs = 0
local files = 0
local linesOfCode = 0

local function parse(path, selfCall)
	if not selfCall then
		path = path or ""
		path = shell.getWorkingDirectory() .. "/" .. path .. "/"
	end
	print(path)
	for file in fs.list(path) do
		if string.sub(file, #file) == "/" then
			parse(path .. file, true)
			dirs = dirs +1
		else
			local tmpPath = "/" .. path .. file
			files = files +1
			for f in io.lines(tmpPath) do
				linesOfCode = linesOfCode +1
			end
		end
	end
end

parse(args[1])

print("--===== Results =====--")
print("folders: " .. tostring(dirs) .. " | files: " .. tostring(files) .. " | lines: " .. tostring(linesOfCode))