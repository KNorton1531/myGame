-- objects/campfire.lua - Definition of the campfire object

local Campfire = {}

function Campfire:new(activeAnimals, debugMode)
    local obj = {
        x = 145,
        y = 140,
        width = 60,
        height = 40,
        type = "campfire",
        campfirePool = {
            { 
                name = "Firefly", 
                type = "bug",
                rarity = 0.9, 
                speed = 20, 
                color = {1, 1, 0},
                sellPrice = 2
            },
            { 
                name = "Moth", 
                type = "bug",
                rarity = 0.1, 
                speed = 15, 
                color = {1, 1, 1},
                sellPrice = 15
            },
            { 
                name = "Butterfly", 
                type = "bug",
                rarity = 0.1, 
                speed = 15, 
                color = {1, 0, 1},
                sellPrice = 15
            }
        },
        spawnRate = 0.1,
        spawnLimit = 5,
        spawnedCount = 0,
        timer = 0,
        level = 1,
        activeAnimals = activeAnimals, -- Reference to active animals list
        fireSprite = love.graphics.newImage("assets/objects/fire.png"), -- Load the fire sprite
        debugMode = debugMode -- Debug mode flag
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Campfire:update(dt)
    self.timer = self.timer + dt
    while self.timer >= self.spawnRate do
        self.timer = self.timer - self.spawnRate
        if self.spawnedCount < self.spawnLimit then
            self:spawnAnimal()
        end
    end
end

function Campfire:getLightSource()
    return {
        x = self.x + self.width / 2,
        y = (self.y + 20) + self.height / 2,
        radius = 50, -- Light radius
        intensity = 0.3 -- Light intensity (adjust as needed)
    }
end


function Campfire:spawnAnimal()
    local totalRarity = 0
    for _, animal in ipairs(self.campfirePool) do
        totalRarity = totalRarity + animal.rarity
    end

    local randomValue = math.random() * totalRarity
    local cumulativeRarity = 0

    for _, animal in ipairs(self.campfirePool) do
        cumulativeRarity = cumulativeRarity + animal.rarity
        if randomValue <= cumulativeRarity then
            -- Spawn the selected animal
            local vx = math.random(-20, 20)
            local vy = math.random(-20, 20)
            table.insert(self.activeAnimals, {
                name = animal.name,
                x = self.x + math.random(self.width),
                y = self.y + math.random(self.height),
                size = 2,
                speed = animal.speed,
                vx = vx,
                vy = vy,
                color = animal.color, -- Assign color
                container = self
            })
            self.spawnedCount = self.spawnedCount + 1
            break
        end
    end
end

function Campfire:draw()
    -- Draw the fire sprite just below the container
    love.graphics.setColor(1, 1, 1) -- Reset color to white for the sprite
    love.graphics.draw(self.fireSprite, 105, -38 + self.height)

    -- Draw the campfire container
    if self.debugMode then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end

    -- Draw the animals within the campfire
    for _, animal in ipairs(self.activeAnimals) do
        love.graphics.setColor(animal.color) -- Use the animal's color
        love.graphics.rectangle("fill", animal.x, animal.y, animal.size, animal.size)
    end

    love.graphics.setColor(1, 1, 1) -- Reset color
end

return Campfire