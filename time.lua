local Time = {}

function Time:new(dayLength, timeScale)
    local obj = {
        dayLength = dayLength or 60,     -- Length of a full day in seconds
        currentTime = 0,                -- Current time in seconds
        isDaytime = true,                -- Flag to indicate if it's daytime
        timeScale = timeScale or 0.5       -- Scale factor for time progression (default: normal speed)
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Time:update(dt)
    self.currentTime = self.currentTime + (dt * self.timeScale)
    if self.currentTime >= self.dayLength then
        self.currentTime = self.currentTime - self.dayLength
    end

    -- Determine if it's daytime or nighttime based on custom times
    local dayProgress = self.currentTime / self.dayLength
    local hourOfDay = dayProgress * 24 -- Convert day progress to hour (0-24)

    -- Nighttime starts at 8 PM (20:00) and ends at 6 AM (6:00)
    self.isDaytime = hourOfDay >= 6 and hourOfDay < 20
end

function Time:toggleDayNight()
    -- Calculate current hour based on day progress
    local currentHour = (self.currentTime / self.dayLength) * 24

    -- Toggle to nighttime if it's currently daytime, and vice versa
    if currentHour >= 6 and currentHour < 20 then
        -- Set time to 8 PM (start of nighttime)
        self.currentTime = (20 / 24) * self.dayLength
    else
        -- Set time to 6 AM (start of daytime)
        self.currentTime = (6 / 24) * self.dayLength
    end
end



function Time:getFormattedTime()
    -- Calculate total minutes in the current game time
    local totalMinutes = (self.currentTime / self.dayLength) * 24 * 60 -- Convert to real-world minutes
    
    -- Extract hours and minutes
    local hours = math.floor(totalMinutes / 60)
    local minutes = math.floor(totalMinutes % 60)
    
    -- Determine AM/PM and convert to 12-hour format
    local period = "AM"
    if hours >= 12 then
        period = "PM"
    end
    if hours == 0 then
        hours = 12 -- Midnight (0:00) is 12:00 AM
    elseif hours > 12 then
        hours = hours - 12 -- Convert 13:00-23:59 to 1:00-11:59 PM
    end

    -- Format hours and minutes with leading zeros if needed
    local formattedTime = string.format("%02d:%02d %s", hours, minutes, period)
    
    return formattedTime
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

-- New method to set time scale dynamically
function Time:setTimeScale(scale)
    self.timeScale = scale
end

return Time
