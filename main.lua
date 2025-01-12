-- Main.lua - Base template for Love2D game

-- Screen settings
local canvasWidth, canvasHeight = 426, 240
local scaleFactor = 1
local canvas
local groundImage
local isFullscreen = false
local debugMode = true -- Debug mode toggle

-- Active animals in the scene
local activeAnimals = {}

-- Import the inventory module
local Inventory = require("inventory")
local inventory = Inventory:new()

-- Import and initialize the campfire object
local Campfire = require("objects.campfire")
local campfire = Campfire:new(activeAnimals, debugMode)

-- Import and initialize the time module
local Time = require("time")
local time = Time:new(60)

-- Load the darkness shader
local darknessShader = love.graphics.newShader("darkness_shader.glsl")

-- Scene containers
local containers = {
    campfire
}

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
    canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
    canvas:setFilter("nearest", "nearest") -- Disable smoothing for the canvas

    -- Set default filter to avoid blurring when scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Load ground image
    groundImage = love.graphics.newImage("assets/world/ground.png")

    -- Load custom font
    local fontSize = 16
    customFont = love.graphics.newFont("assets/ui/font.otf", fontSize)
    love.graphics.setFont(customFont)

    -- Calculate initial window size to fit the screen with correct aspect ratio
    local initialScale = 2 -- Initial scale factor for the window
    local windowWidth, windowHeight = canvasWidth * initialScale, canvasHeight * initialScale

    -- Window setup
    love.window.setMode(windowWidth, windowHeight, {
        resizable = true,
        minwidth = canvasWidth,
        minheight = canvasHeight,
        vsync = true
    })

    -- Trigger resize manually to ensure correct scaling at startup
    love.resize(windowWidth, windowHeight)

    love.window.setTitle("Arctic Collecting Game")
end

function love.resize(w, h)
    -- Maintain aspect ratio by recalculating valid width and height
    local aspectRatio = canvasWidth / canvasHeight
    local newWidth = math.floor(h * aspectRatio + 0.5)
    local newHeight = math.floor(w / aspectRatio + 0.5)

    if w / h > aspectRatio then
        -- Width is too large, adjust it
        love.window.setMode(newWidth, h, { resizable = true, vsync = true })
    else
        -- Height is too large, adjust it
        love.window.setMode(w, newHeight, { resizable = true, vsync = true })
    end

    -- Recalculate scale factor after resizing
    local scaleX, scaleY = w / canvasWidth, h / canvasHeight
    scaleFactor = math.min(scaleX, scaleY)
end

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

    -- Update time
    time:update(dt)
end

function love.keypressed(key)
    if key == "f" then
        -- Toggle fullscreen mode
        isFullscreen = not isFullscreen
        love.window.setFullscreen(isFullscreen)
        if not isFullscreen then
            -- Restore windowed mode with correct aspect ratio
            local initialScale = 2
            local windowWidth, windowHeight = canvasWidth * initialScale, canvasHeight * initialScale
            love.window.setMode(windowWidth, windowHeight, {
                resizable = true,
                minwidth = canvasWidth,
                minheight = canvasHeight,
                vsync = true
            })
            love.resize(windowWidth, windowHeight)
        end
    elseif key == "d" then
        -- Toggle debug mode
        debugMode = not debugMode
        campfire.debugMode = debugMode -- Update the campfire debug mode
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

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(groundImage, 0, canvasHeight - groundImage:getHeight())

    -- Draw containers (campfire, etc.)
    for _, container in pairs(containers) do
        container:draw()
    end

    love.graphics.setCanvas()

    -- Draw the scaled canvas to the screen
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local drawX = (screenWidth - canvasWidth * scaleFactor) / 2
    local drawY = (screenHeight - canvasHeight * scaleFactor) / 2
    love.graphics.draw(canvas, drawX, drawY, 0, scaleFactor, scaleFactor)

    -- Apply darkness shader
    local light = campfire:getLightSource()
    love.graphics.setShader(darknessShader)
    darknessShader:send("timeOfDay", time:getDayProgress())
    darknessShader:send("lightPosition", {light.x * scaleFactor, light.y * scaleFactor})
    darknessShader:send("lightRadius", light.radius * scaleFactor)
    darknessShader:send("lightIntensity", light.intensity)

    if not time:isDay() then
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    end
    love.graphics.setShader()

    -- Draw UI elements and inventory
    love.graphics.setColor(hexToColor("#CCCCCC"))
    love.graphics.rectangle("fill", screenWidth - 100, screenHeight - 100, 40, 40)
    love.graphics.setColor(hexToColor("#000000"))
    love.graphics.print("Inv", screenWidth - 90, screenHeight - 85)

    inventory:draw()

    local formattedTime = time:getFormattedTime()
    love.graphics.print("Time: " .. formattedTime, 600, 10)

    -- Debug info (if enabled)
    if debugMode then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Debug Mode ON", 10, 10)
        love.graphics.print(string.format("Canvas Size: %dx%d", canvasWidth, canvasHeight), 10, 30)
        love.graphics.print(string.format("Window Size: %dx%d", screenWidth, screenHeight), 10, 50)
        love.graphics.print(string.format("Scale Factor: %.2f", scaleFactor), 10, 70)
        love.graphics.print(string.format("Active Animals: %d", #activeAnimals), 10, 90)
        love.graphics.print(string.format("Time of Day: %.2f", time:getTimeOfDay()), 10, 110)
    end
end


function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        -- Transform mouse coordinates to canvas coordinates
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local drawX = (screenWidth - canvasWidth * scaleFactor) / 2
        local drawY = (screenHeight - canvasHeight * scaleFactor) / 2
        local canvasX = (x - drawX) / scaleFactor
        local canvasY = (y - drawY) / scaleFactor

        -- Check if inventory button is clicked
        if canvasX >= canvasWidth - 50 and canvasY >= canvasHeight - 50 and canvasX <= canvasWidth - 10 and canvasY <= canvasHeight - 10 then
            inventory:toggle()
        end

        -- Check if an animal is clicked
        for i, animal in ipairs(activeAnimals) do
            if canvasX >= animal.x and canvasX <= animal.x + animal.size and canvasY >= animal.y and canvasY <= animal.y + animal.size then
                inventory:addAnimal(animal)
                table.remove(activeAnimals, i)
                animal.container.spawnedCount = animal.container.spawnedCount - 1
                break
            end
        end
    end
end