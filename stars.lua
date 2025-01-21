local Stars = {}

function Stars:new(numStars, minY)
    local stars = {}
    minY = minY or 0 -- Default to 0 if minY is not provided
    local maxY = love.graphics.getHeight() / 1 -- Limit stars to the upper half

    for i = 1, numStars do
        local y
        repeat
            y = math.random(minY, maxY)
        until y >= minY
        local densityFactor = 1 - (y / maxY) -- Adjust density factor for upper half only
        table.insert(stars, {
            x = math.random(love.graphics.getWidth()),
            y = y,
            size = math.random(1, 1),
            alpha = math.random(50, 255),
            flickerSpeed = math.random(1, 3) * densityFactor
        })
    end
    self.__index = self
    return setmetatable({stars = stars}, self)
end

function Stars:update(dt)
    for _, star in ipairs(self.stars) do
        star.alpha = star.alpha + star.flickerSpeed * dt * 50
        if star.alpha > 255 then
            star.alpha = 255
            star.flickerSpeed = -star.flickerSpeed
        elseif star.alpha < 50 then
            star.alpha = 50
            star.flickerSpeed = -star.flickerSpeed
        end
    end
end

function Stars:draw()
    for _, star in ipairs(self.stars) do
        love.graphics.setColor(1, 1, 1, star.alpha / 255)
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
    love.graphics.setColor(1, 1, 1, 1) -- Reset color
end

return Stars
