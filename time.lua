local Time = {}

function Time:new(dayLength)
    local obj = {
        dayLength = dayLength or 60, -- Length of a full day in seconds
        currentTime = 30, -- Current time in seconds
        isDaytime = true -- Flag to indicate if it's daytime
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Time:update(dt)
    self.currentTime = self.currentTime + dt
    if self.currentTime >= self.dayLength then
        self.currentTime = self.currentTime - self.dayLength
    end

    -- Determine if it's daytime or nighttime
    local dayProgress = self.currentTime / self.dayLength
    self.isDaytime = dayProgress < 0.5
end

function Time:getTimeOfDay()
    return self.currentTime
end

function Time:isDay()
    return self.isDaytime
end

function Time:getDayProgress()
    return self.currentTime / self.dayLength
end

return Time
