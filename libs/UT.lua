--[[UsefullThings libary
	Written by:
		MisterNoNameLP
]]
local UT = {version = "v0.6"}

function UT.parseArgs(...) --returns the first non nil value.
	for _, a in pairs({...}) do
		if a ~= nil then
			return a
		end
	end
end

function UT.seperatePath(path) --seperates a data path ["./DIR/FILE.ENDING"] into the dir path ["./DIR/"], the file name ["FILE"], and the file ending [".ENDING" or nil]
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

function UT.getChars(s) --returns a array with the chars of the string.
	local chars = {}
	for c = 1, #s do
		chars[c] = string.sub(s, c, c)
	end
	return chars
end

function UT.makeString(c) --genetares a string from and array of chars/strings.
	local s = ""
	for c, v in ipairs(c) do
		s = s ..v
	end
	return s
end

function UT.inputCheck(m, c) --checks if a array (m) contains a value (c).
	for _, v in pairs(m) do
		if v == c then
			return true
		end
	end
	return false
end

function UT.fillString(s, amout, c) --fills a string (s) up with a (amout) of chars/strings (c).
	local s2 = s
	for c2 = 1, amout, 1 do
		s2 = s2 .. c
	end
	return s2
end

return UT