-- objects/campfire.lua - Definition of the campfire object

local Campfire = {}

function Campfire:new(activeAnimals, debugMode)
    local obj = {
        x = 240,
        y = 300,
        width = 75,
        height = 100,
        type = "campfire",
        campfirePool = {
            { 
                name = "Firefly", 
                type = "bug",
                rarity = 0.5, 
                speed = 30, 
                color = {1, 1, 0},
                sellPrice = 2,
                size = 4
            },
            { 
                name = "Snow Moth", 
                type = "bug",
                rarity = 0.1, 
                speed = 15, 
                color = {1, 1, 1},
                sellPrice = 15,
                size = 3
            },
            { 
                name = "Frostbottle", 
                type = "bug",
                rarity = 0.2, 
                speed = 15, 
                color = {0, 0, 1},
                sellPrice = 15,
                size = 3
            },
            { 
                name = "Ice Fly", 
                type = "bug",
                rarity = 0.1, 
                speed = 15, 
                color = {0, 0, 0},
                sellPrice = 15,
                size = 3
            },
            { 
                name = "White Butterfly", 
                type = "bug",
                rarity = 0.1, 
                speed = 15, 
                color = {1, 0, 1},
                sellPrice = 15,
                size = 3
            }
        },
        spawnRate = 0.1,
        spawnLimit = 10,
        spawnedCount = 0,
        timer = 0,
        level = 1,
        activeAnimals = activeAnimals, -- Reference to active animals list
        fireSprite = love.graphics.newImage("assets/objects/fire2.png"), -- Load the fire sprite
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
                size = animal.size,
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
    love.graphics.draw(self.fireSprite, 270, 388)

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