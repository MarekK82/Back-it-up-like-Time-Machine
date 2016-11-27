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
