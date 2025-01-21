-- Main.lua - Base template for Love2D game

-- Screen settings
local screenWidth, screenHeight = 852, 480
local canvas
local groundImage
local isFullscreen = false
local debugMode = false -- Debug mode toggle

-- Active animals in the scene
local activeAnimals = {}

-- Require the modules
local WorldObjects = require("world_objects")
local Inventory = require("inventory")
local Campfire = require("objects.campfire")
local Time = require("time")
local Stars = require("stars")

-- Initialize instances
local inventory = Inventory:new()
local campfire = Campfire:new(activeAnimals, debugMode)
local time = Time:new(60)
local worldObjects = WorldObjects:new()
local stars

-- Scene containers
local containers = { campfire }

local LightSource = require("LightSource")
local lightSources = {
    LightSource:new(175, 190, 40, 0.7),
    LightSource:new(393, 37, 70, 0.4),
}

-- Box position and size (global scope)
local boxX, boxY = 800, 430
local boxWidth, boxHeight = 40, 40

-- Function to convert hex color to Love2D color table
local function hexToColor(hex)
    hex = hex:gsub("#", "")
    return {
        tonumber("0x" .. hex:sub(1, 2)) / 255,
        tonumber("0x" .. hex:sub(3, 4)) / 255,
        tonumber("0x" .. hex:sub(5, 6)) / 255
    }
end

function love.load()
    -- Create canvas
    canvas = love.graphics.newCanvas(screenWidth, screenHeight)
    canvas:setFilter("nearest", "nearest") -- Disable smoothing for the canvas

    -- Set default filter to avoid blurring when scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Load ground image
    groundImage = love.graphics.newImage("assets/world/ground2.png")

    -- Load custom font
    local fontSize = 16
    customFont = love.graphics.newFont("assets/ui/font.otf", fontSize)
    love.graphics.setFont(customFont)

    -- Load the backpack image for the inventory UI button
    backpackImage = love.graphics.newImage("assets/ui/backpack.png")

    -- Load the darkness shader
    darknessShader = love.graphics.newShader("darkness_shader.glsl")

    -- Set initial shader uniforms to avoid incorrect initial display
    local initialLight = lightSources[1]:getLightData() -- Access the first light source
    darknessShader:send("lightPosition", {initialLight.x, initialLight.y})
    darknessShader:send("lightRadius", initialLight.radius)
    darknessShader:send("lightIntensity", initialLight.intensity)
    darknessShader:send("timeOfDay", time:getDayProgress())

    -- Add world objects
    worldObjects:addObject("assets/objects/tent2.png", 30, 372, screenWidth, screenHeight, 1)

    worldObjects:addObject("assets/objects/smallTree.png", 360, 320, screenWidth, screenHeight, 1)
    worldObjects:addObject("assets/objects/bigTree.png", 700, 238, screenWidth, screenHeight, 1)
    worldObjects:addObject("assets/objects/medTree2.png", 380, 280, screenWidth, screenHeight, 1)
    worldObjects:addObject("assets/objects/medTree2.png", 600, 280, screenWidth, screenHeight, 1)
    worldObjects:addObject("assets/objects/smallTree.png", 570, 320, screenWidth, screenHeight, 1)
    worldObjects:addObject("assets/objects/bigTree.png", -40, 238, screenWidth, screenHeight, 1)
    worldObjects:addObject("assets/objects/smallTree.png", 785, 320, screenWidth, screenHeight, 1)

    -- Window setup
    love.window.setMode(screenWidth, screenHeight, {
        resizable = false,
        vsync = true
    })

    love.window.setTitle("Arctic Collecting Game")

    local numStars = 200 -- Change this value to set the number of stars
    local minY = 0 -- Minimum Y level for stars (upper half of the canvas)
    stars = Stars:new(numStars, minY) -- Initialize stars with the specified number of stars and minimum Y level
end

local isHoveringBackpack = false -- Flag for hover effect

function love.update(dt)
    -- Update containers and spawn animals
    for _, container in pairs(containers) do
        container:update(dt)
    end

    -- Update animal positions
    for _, animal in ipairs(activeAnimals) do
        -- Update random movement
        animal.x = animal.x + animal.vx * dt
        animal.y = animal.y + animal.vy * dt

        -- Check for collisions with container boundaries and reverse direction if needed
        if animal.x <= animal.container.x or animal.x + animal.size >= animal.container.x + animal.container.width then
            animal.vx = -animal.vx
        end
        if animal.y <= animal.container.y or animal.y + animal.size >= animal.container.y + animal.container.height then
            animal.vy = -animal.vy
        end
    end

    -- Check if mouse is hovering over the box
    local mouseX, mouseY = love.mouse.getPosition()
    if mouseX >= boxX and mouseX <= boxX + boxWidth and
       mouseY >= boxY and mouseY <= boxY + boxHeight then
        isHoveringBackpack = true
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        isHoveringBackpack = false
        love.mouse.setCursor() -- Reset to default cursor
    end

    -- Catch animals when hovering over them
    for i, animal in ipairs(activeAnimals) do
        if mouseX >= animal.x and mouseX <= animal.x + animal.size and
           mouseY >= animal.y and mouseY <= animal.y + animal.size then
            inventory:addAnimal(animal)
            table.remove(activeAnimals, i)
            animal.container.spawnedCount = animal.container.spawnedCount - 1
            break
        end
    end

    -- Print mouse coordinates for debugging
    if debugMode then
        print("Mouse X: " .. mouseX .. ", Mouse Y: " .. mouseY)
    end

    -- Update time
    time:update(dt)
    stars:update(dt)
end

function love.keypressed(key)
    if key == "d" then
        -- Toggle debug mode
        debugMode = not debugMode
        campfire.debugMode = debugMode
        worldObjects:toggleDebug()
    elseif key == "t" then
        -- Toggle day and night for debugging
        time:toggleDayNight()
    end
end

function love.draw()
    -- Draw the scene to the canvas
    love.graphics.setCanvas(canvas)

    if time:isDay() then
        love.graphics.clear(hexToColor("#98d8ff"))
    else
        love.graphics.clear(hexToColor("#151c35"))
    end

    if not time:isDay() then
        stars:draw()
    end

    -- Draw the game world (scaled elements)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(groundImage, 0, screenHeight - groundImage:getHeight())

    -- Draw containers (campfire, etc.)
    for _, container in pairs(containers) do
        container:draw()
    end

    -- Draw world objects
    worldObjects:draw(1, screenWidth, screenHeight)

    -- Draw the moon or sun
    if not time:isDay() then
        local moonImage = love.graphics.newImage("assets/objects/moon2.png")
        love.graphics.draw(moonImage, 760, 22, 0, 1, 1)
    else
        local sunImage = love.graphics.newImage("assets/objects/sun2.png")
        love.graphics.draw(sunImage, 745, 8, 0, 1, 1)
    end

    love.graphics.setCanvas()

    -- Draw the canvas to the screen
    love.graphics.draw(canvas, 0, 0)

    -- Draw the debug box (unscaled size)
    love.graphics.setColor(0, 1, 0, 0.5) -- Green with transparency
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)

    -- Reset color
    love.graphics.setColor(1, 1, 1)

    inventory:draw()

    -- Draw the clock at its relative position on the canvas
    local clockX = 350
    local clockY = 10
    if time:isDay() then
        love.graphics.setColor(hexToColor("#000000"))
    else
        love.graphics.setColor(hexToColor("#FFFFFF"))
    end
    love.graphics.print("Time: " .. time:getFormattedTime(), clockX, clockY)

    -- Debug info (if enabled)
    if debugMode then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Debug Mode ON", 10, 10)
        love.graphics.print(string.format("Canvas Size: %dx%d", screenWidth, screenHeight), 10, 30)
        love.graphics.print(string.format("Window Size: %dx%d", screenWidth, screenHeight), 10, 50)
        love.graphics.print(string.format("Active Animals: %d", #activeAnimals), 10, 70)
        love.graphics.print(string.format("Time of Day: %.2f", time:getTimeOfDay()), 10, 90)
        love.graphics.print(string.format("Mouse X: %d, Mouse Y: %d", love.mouse.getX(), love.mouse.getY()), 10, 110)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        -- Check if the click is within the box
        if x >= boxX and x <= boxX + boxWidth and
           y >= boxY and y <= boxY + boxHeight then
            print("Box clicked!") -- Debugging message
            inventory:toggle()
        end
    end
end

function love.wheelmoved(x, y)
    if inventory.isInventoryOpen then
        inventory:scroll(y) -- Scroll inventory when the wheel is moved
    end
end
