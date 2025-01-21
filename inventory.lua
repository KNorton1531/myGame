local Inventory = {}

function Inventory:new()
    local obj = {
        animals = {}, -- Stores animals with name, count, and color
        isInventoryOpen = true, -- Controls inventory visibility
        scrollOffset = 0, -- Scroll offset for inventory
        maxScroll = 0, -- Maximum scroll limit
        scrollSpeed = 20 -- Speed of scrolling
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Inventory:addAnimal(animal)
    if self.animals[animal.name] then
        self.animals[animal.name].count = self.animals[animal.name].count + 1
    else
        self.animals[animal.name] = { count = 1, color = animal.color, image = animal.image }
    end
end

function Inventory:draw()
    if self.isInventoryOpen then
        -- Draw inventory background
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle("fill", 142, 57, 568, 320)

        -- Draw the inventory title with medium font
        love.graphics.setColor(0, 0, 0)
        local mediumFont = love.graphics.newFont(16) -- Medium font size for title
        love.graphics.setFont(mediumFont)
        love.graphics.print("Inventory", 370, 67)

        -- Enable scissor to lock drawing within the inventory UI
        love.graphics.setScissor(142, 94, 568, 280)

        -- Scrolling logic
        local cardWidth = 120
        local cardHeight = 160
        local padding = 10
        local startX = 162 -- X position for the first card
        local startY = 100 -- Y position for the first card
        local x, y = startX, startY - self.scrollOffset

        -- Create smaller font for cards
        local smallFont = love.graphics.newFont(10)
        love.graphics.setFont(smallFont)

        -- Draw each animal as a card
        for name, animal in pairs(self.animals) do
            -- Draw card background
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", x, y, cardWidth, cardHeight)

            -- Draw image window at the top of the card
            local imageWindowHeight = 80
            love.graphics.setColor(0.8, 0.8, 0.8) -- Light gray for the image window
            love.graphics.rectangle("fill", x + 10, y + 10, cardWidth - 20, imageWindowHeight)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", x + 10, y + 10, cardWidth - 20, imageWindowHeight)

            -- If an image is provided, draw it
            if animal.image then
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(animal.image, x + 15, y + 15, 0, (cardWidth - 30) / animal.image:getWidth(), imageWindowHeight / animal.image:getHeight())
            end

            -- Draw text for animal name and count below the image window
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(name, x + 10, y + 100)
            love.graphics.print("Count: " .. animal.count, x + 10, y + 120)

            -- Update positions for next card
            x = x + cardWidth + padding
            if x + cardWidth > 142 + 568 then -- Wrap to the next row if it exceeds the inventory width
                x = startX
                y = y + cardHeight + padding
            end
        end

        -- Reset to the default font (if needed for other UI elements)
        love.graphics.setFont(love.graphics.newFont())

        -- Disable the scissor to allow unrestricted drawing for other elements
        love.graphics.setScissor()

        -- Calculate maximum scroll based on content
        self.maxScroll = math.max(0, y + cardHeight - 320)
    end
end




function Inventory:scroll(delta)
    -- Update scroll offset based on input
    self.scrollOffset = math.max(0, math.min(self.scrollOffset - delta * self.scrollSpeed, self.maxScroll))
end

function Inventory:toggle()
    self.isInventoryOpen = not self.isInventoryOpen
end

return Inventory
