local Inventory = {}

function Inventory:new()
    local obj = {
        animals = {},
        isInventoryOpen = false
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Inventory:addAnimal(animal)
    if self.animals[animal.name] then
        self.animals[animal.name].count = self.animals[animal.name].count + 1
    else
        self.animals[animal.name] = { count = 1, color = animal.color }
    end
end

function Inventory:draw()
    if self.isInventoryOpen then
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle("fill", 10, 10, 200, 200)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Inventory:", 20, 20)
        local y = 40
        for name, animal in pairs(self.animals) do
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(name .. ": " .. animal.count, 20, y)
            y = y + 20
        end
    end
end

function Inventory:toggle()
    self.isInventoryOpen = not self.isInventoryOpen
end

return Inventory