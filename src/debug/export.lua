--[[A very simple project exporter.
	Written by:
		MisterNoNameLP.
]]
local version = "v1.0.3"

local installScript = [[
--===== local functions =====--
function seperatePath(path) --Ripped from UT_v0.6.1
--seperates a data path ["./DIR/FILE.ENDING"] into the dir path ["./DIR/"], the file name ["FILE"], and the file ending [".ENDING" or nil]
	if string.sub(path, #path) == "/" then
		return path
	end
	
	local dir, fileName, fileEnd = "", "", nil
	local tmpLatest = ""
	for s in string.gmatch(tostring(path), "[^/]+") do
		tmpLatest = s
	end
	dir = string.sub(path, 0, #path -#tmpLatest)
	for s in string.gmatch(tostring(tmpLatest), "[^.]+") do
		fileName = fileName .. s
		tmpLatest = s
	end
	if fileName == tmpLatest then
		fileName = tmpLatest
	else
		fileEnd = "." .. tmpLatest
		fileName = string.sub(fileName, 0, #fileName - #fileEnd +1)
	end
	
	return dir, fileName, fileEnd
end

--===== prog start =====--
local fs = require("filesystem")
local shell = require("shell")
local serialization = require("serialization")

local args, opts = shell.parse(...)
local emptyBufferSpace = 10

if opts.h or #args == 0 then
	
	print("Usage: SETUP [OPTIONS]... [TARGET_DIR]...")
	print("  -h			Shows this text.")
	print("  -o 			Overwrite the EXPORT_DIR.")
	
	return true
end

if not opts.o then
	if string.sub(args[1], 0, 1) == "/" and fs.exists(args[1]) then
		return false, "Folder exists already."
	elseif fs.exists(shell.getWorkingDirectory() .. args[1]) then
		return false, "Folder exists already."
	end
end

for i, s in pairs(data) do
	local path, file, ending = seperatePath(i)
	file = (file or "") .. (ending or "")
	if string.sub(args[1], 0, 1) == "/" then
		path = "/" .. args[1] .. "/" .. (path or "")
	else
		path = shell.getWorkingDirectory() .. "/" .. args[1] .. "/" .. (path or "")
	end
	
	print("Create file: " .. path .. file)
	
	fs.makeDirectory(path)
	if s ~= 0 then
		local f = io.open(path .. file, "w")
		for c = 1, #s, (f.bufferSize - emptyBufferSpace) +1 do
			f:write(string.sub(s, c, c + f.bufferSize - emptyBufferSpace))
			f:flush()
		end
		f:close()
	end
end
]]

local fs = require("filesystem")
local shell = require("shell")
local serialization = require("serialization")

local args, opts = shell.parse(...)

local dirs = 0
local files = 0
local linesOfCode = 0
local exportFile = nil
local relativePath = ""

local function parseFiles(path, countLines, export)
	if string.sub(path, 0, 1) ~= "/"  then
		path = path or ""
		path = shell.getWorkingDirectory() .. "/" .. path .. "/"
		relativePath = shell.getWorkingDirectory()
	end
	print(path)
	for file in fs.list(path) do
		if string.sub(file, #file) == "/" then
			parseFiles(path .. file, countLines, export)
			dirs = dirs +1
			if export then
				exportFile:write("[\"" .. string.sub(path .. file, #relativePath + #args[1] +1) .. "\"] = 0,")
				exportFile:flush()
			end
		else
			local tmpPath = "/" .. path .. file
			
			if export then
				
				local emptyBufferSpace = #tmpPath +20
				local f = io.open(tmpPath, "r")
				local s = serialization.serialize(f:read("*all"))
				f:close()
				
				exportFile:write("[\"" .. string.sub(path .. file, #relativePath + #args[1] +1) .. "\"] = ")
				exportFile:flush()
				
				for c = 1, #s, (exportFile.bufferSize - emptyBufferSpace) +1 do
					exportFile:write(string.sub(s, c, c + exportFile.bufferSize - emptyBufferSpace))
					exportFile:flush()
				end
				
				exportFile:write(",")
			end
			
			if countLines then
				files = files +1
				for l in io.lines(tmpPath) do
					linesOfCode = linesOfCode +1
				end
			end
		end
	end
end

if opts.v then
	print("exporter " .. version)
	if not opts.h then
		return true
	end
end

if opts.h or #args == 0 then
	print([[
Usage: export [OPTIONS]... [DIR]... [EXPORT_FILE]...
  -e			Exports the DIR with all sub dirs/files as installer script to EXPORT_FILE.
  -h			Shows this text.
  -i 			Collects some infos (dirs, files, lines of text) about DIR with all sub dirs/files (can take a while on big projects).
  -o 			Overwrite the EXPORT_FILE.
	]])
	return true
end

if opts.e then
	if args[2] == nil then
		return false, "No export file name given."
	end
	
	if io.open(args[2], "r") == nil or opts.o then
		exportFile = io.open(args[2], "w")
		exportFile:write("-- This is a installation script createt by MisterNoNameLPs OC project exporter " .. version .. ".\n\n")
		exportFile:write("local data = {")
		exportFile:flush()
	else
		return false, "File are existing already."
	end
end

parseFiles(args[1], opts.i, opts.e)

if opts.e then
	exportFile:write("} \n")
	exportFile:flush()
	
	local emptyBufferSpace = 10
	for c = 1, #installScript, (exportFile.bufferSize - emptyBufferSpace) +1 do
		exportFile:write(string.sub(installScript, c, c + exportFile.bufferSize - emptyBufferSpace))
		exportFile:flush()
	end
	
	exportFile:close()
end

if opts.i then
	print("--===== Project infos =====--")
	print("folders: " .. tostring(dirs) .. " | files: " .. tostring(files) .. " | lines: " .. tostring(linesOfCode))
end
