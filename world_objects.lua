local WorldObjects = {} -- Correctly initialize WorldObjects as a local table

function WorldObjects:new()
    local obj = {
        objects = {}, -- List to store world objects
        debugMode = true -- Enable/disable debug mode
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function WorldObjects:addObject(filePath, absX, absY, canvasWidth, canvasHeight, scale)
    local object = {
        sprite = love.graphics.newImage(filePath),
        relX = absX / canvasWidth, -- Store as percentage of canvas width
        relY = absY / canvasHeight, -- Store as percentage of canvas height
        scale = scale or 1
    }
    table.insert(self.objects, object)
end

-- Draw all objects
function WorldObjects:draw(scaleFactor, canvasWidth, canvasHeight)
    for _, obj in ipairs(self.objects) do
        local scaledX = obj.relX * canvasWidth * scaleFactor
        local scaledY = obj.relY * canvasHeight * scaleFactor
        local scaledScale = obj.scale * scaleFactor
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(obj.sprite, scaledX, scaledY, 0, scaledScale, scaledScale)

        if self.debugMode then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line", scaledX, scaledY, obj.sprite:getWidth() * scaledScale, obj.sprite:getHeight() * scaledScale)
        end
    end
    love.graphics.setColor(1, 1, 1)
end


-- Toggle debug mode
function WorldObjects:toggleDebug()
    self.debugMode = not self.debugMode
end

return WorldObjects
