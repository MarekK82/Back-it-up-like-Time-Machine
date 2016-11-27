#!/usr/bin/env lua
require "backup"

-- Load configuration file
function loadConfig()
	if not cfg then
		cfg = {}
		chunk = assert(loadfile("config.lua", "t", cfg))
		chunk()
	end
end

-- Main
local function main()
	local timeline = Backup.getBackups("month")
	print(timeline:size())
end

main()
