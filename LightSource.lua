local LightSource = {}

function LightSource:new(x, y, radius, intensity)
    local obj = {
        x = x or 0,
        y = y or 0,
        radius = radius or 50,
        intensity = intensity or 0.5
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function LightSource:getLightData()
    return {
        x = self.x,
        y = self.y,
        radius = self.radius,
        intensity = self.intensity
    }
end

return LightSource
