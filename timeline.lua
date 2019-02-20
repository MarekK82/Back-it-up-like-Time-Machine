-- Class representing the timeline of many backups

Timeline = {
  backups = {}
}

function Timeline:new(t)
  t = t or {}
  self.__index = self
  setmetatable(t, self)
  return t
end

function Timeline:add(b)
  self.backups[#self.backups + 1] = b
end

function Timeline:size()
  return #self.backups
end

function Timeline:sort()
  table.sort(self.backups, function (a, b)
    return a.file < b.file
  end)
end

function Timeline:purgeMonth()
  local lastMonthByDay = {}

  for _, b in pairs(self.backups) do
    local day = b:getDay()

    if not lastMonthByDay[day] then
      lastMonthByDay[day] = {}
    end

    lastMonthByDay[day][#lastMonthByDay[day] + 1] = b
  end

  for k, v in pairs(lastMonthByDay) do
    print(string.format("Purging last month by day %d:", k))
    -- Purging all but the oldest per day
    for i = 2, #v do
      print(string.format("  Purging backup %q ...", v[i].path))
    end
  end
end
