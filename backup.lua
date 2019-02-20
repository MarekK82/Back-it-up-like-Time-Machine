-- Class representing a backup in the filesystem
require "lfs"
require "timeline"

Backup = {
	now		= os.date("*t"),
	file 	= nil,
	path	= nil
}

function Backup:new(t)
	t = t or {}
	self.__index = self
	setmetatable(t, self)
	return t
end

function Backup.getBackups(age)
	if age ~= nil and age ~= "all" and age ~= "month" and age ~= "day" and age ~= "rest" then
		error("Unknown backup age '" .. age .. "'")
	end

	loadConfig()

	local timeline = Timeline:new()
	for f in lfs.dir(cfg.timelinePath) do
		local b = Backup:new({
			path = cfg.timelinePath .. "/" .. f,
			file = f
		})

		if b:isBackup() then
			add = false
			if age == "day" and b:withinLast24Hours() then
				add = true
			elseif age == "month" and b:withinLastMonth() and not b:withinLast24Hours() then
				add = true
			elseif age == "rest" and not b:withinLastMonth() and not b:withinLast24Hours() then
				add = true
			elseif age == "all" or age == nil then
				add = true
			end

			if add then
				timeline:add(b)
			end
		end
	end

	timeline:sort()
	return timeline
end

function Backup:withinLast24Hours()
	local current = os.time(os.date("*t", self:getTimestamp()))
	local diff = os.difftime(os.time(self.now), current)
	local oneDayInSecs = 60^2 * 24	-- Seconds in an hour times hours in a day
	if diff / oneDayInSecs < 1 then
		return true
	end
	return false
end

function Backup:withinLastMonth()
	local current = os.date("*t", self:getTimestamp())
	if self.now.year == current.year and self.now.month == current.month then
		return true
	end
	return false
end

function Backup:isBackup()
	local pattern = "^" .. string.rep("%d", 8) .. "T" .. string.rep("%d", 6) .. "$"
	if not string.match(self.file, pattern) then
		return false
	end

	local mode = assert(lfs.attributes(self.path, "mode"))
	if mode ~= "directory" then
		return false
	end
	return true
end

function Backup:getTimestamp()
	pattern = "^(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)$"
	local ye, mo, da, ho, mi, se = self.file:match(pattern)
	return os.time({year = ye, month = mo, day = da, hour = ho, min = mi, sec = se})
end

function Backup:getDay()
	local pattern = "^%d%d%d%d%d%d(%d%d)T%d%d%d%d%d%d$"
	local day = string.match(self.file, pattern)
	assert(day, "unable to parse for day")
	return tonumber(day)
end
