local editor = {}

local map = {}

editor.enabled = false

local camDirections = {
    up = {0,-1}, down = {0,1}, left = {-1, 0}, right = {1,0}
}
editor.cameraX = 0
editor.cameraY = 0
editor.camSpeed = 500

local currentPlatform
local mapLoader = require("modules.mapLoader")
local collision = require("modules.collision")

local mode = "place"
local platformType = 1

local f

local buttons = {
    {
        Sprite = "PlaceMode",
        Transform = {2, 2, 50, 50},
        IsEnabled = function ()
            if mode == "place" and platformType == 1 then return true else return false end
        end,
        Callback = function ()
            mode = "place"
            platformType = 1
        end
    },
    {
        Sprite = "LavaMode",
        Transform = {56, 2, 50, 50},
        IsEnabled = function ()
            if mode == "place" and platformType == 2 then return true else return false end
        end,
        Callback = function ()
            mode = "place"
            platformType = 2
        end
    },
    {
        Sprite = "DeleteMode",
        Transform = {108, 2, 50, 50},
        IsEnabled = function ()
            if mode == "delete" then return true else return false end
        end,
        Callback = function ()
            mode = "delete"
        end
    },
    {
        Sprite = "Save",
        Transform = {160, 2, 50, 50},
        IsEnabled = function ()
            return false
        end,
        Callback = function ()
            f:open("w")
            
            f:write(mapLoader:TableToGoose(map))
            f:close()
        end
    }
}


local sprites = {
    SpawnPoint = "player.png",
    PlaceMode = "place_mode.png",
    DeleteMode = "delete_mode.png",
    LavaMode = "lava_mode.png",
    Lava = "lava.png",
    Save = "save.png"
}

function editor:Load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
end

function love.mousepressed(x, y, button)
    if editor.enabled == false then return end
    if button ~= 1 then return end
    
    for _, b in ipairs(buttons) do
        if collision:CheckCollision(x, y, 1, 1, b.Transform[1], b.Transform[2], b.Transform[3], b.Transform[4]) then
            b.Callback()

            return
        end
    end
    
    if mode == "place" then
        print(x, y, button)
        currentPlatform = {}
        currentPlatform.X = x + editor.cameraX
        currentPlatform.Y = y + editor.cameraY
        currentPlatform.W = 1
        currentPlatform.H = 1
        currentPlatform.T = platformType
    elseif mode == "delete" then
        for i, v in ipairs(map) do
            if collision:CheckCollision(x + editor.cameraX, y + editor.cameraY, 5, 5, v.X, v.Y, v.W, v.H) then
                table.remove(map, i)
                
                break
            end
        end
    end
    

    
end

function love.mousemoved(x, y)
    if editor.enabled == false then return end
    if currentPlatform == nil then return end
    print(x, y)
    
    currentPlatform.W = x + editor.cameraX - currentPlatform.X 
    currentPlatform.H = y + editor.cameraY - currentPlatform.Y
end

function love.mousereleased(x, y, button)
    
    if editor.enabled == false then return end
    if button ~= 1 then return end
    if currentPlatform == nil then return end
    print(x, y, button)
    
    if currentPlatform.W < 0 then
        currentPlatform.W = -(x + editor.cameraX - currentPlatform.X)
        currentPlatform.X = currentPlatform.X - currentPlatform.W
    else
        currentPlatform.W = x + editor.cameraX - currentPlatform.X
    end

    if currentPlatform.H < 0 then
        currentPlatform.H = -(y + editor.cameraY - currentPlatform.Y)
        currentPlatform.Y = currentPlatform.Y - currentPlatform.H
    else
        currentPlatform.H = y + editor.cameraY - currentPlatform.Y
    end
    
    
    table.insert(map, currentPlatform)
    
    currentPlatform = nil

    print(mapLoader:TableToGoose(map))
end

function editor:Update(dt)
    for key, mult in pairs(camDirections) do
        if love.keyboard.isDown(key) then
            self.cameraX = self.cameraX + mult[1] * dt * self.camSpeed
            self.cameraY = self.cameraY + mult[2] * dt * self.camSpeed
        end
    end
end

function editor:Draw()
    love.graphics.setBackgroundColor(1,1,1,1)
    
    for _, p in ipairs(map) do
        if p.T == 1 then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", p.X - self.cameraX, p.Y - self.cameraY, p.W, p.H, 10, 10)
        else
            love.graphics.setColor(1,1,1, 1)
            love.graphics.draw(sprites.Lava, p.X - self.cameraX, p.Y - self.cameraY, 0, p.W/ 100, p.H / 100)
        end
        
    end
    if currentPlatform ~= nil then
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("fill", currentPlatform.X - self.cameraX, currentPlatform.Y - self.cameraY, currentPlatform.W, currentPlatform.H)
    end

    love.graphics.setColor(1,1,1, 0.5)
    love.graphics.draw(sprites.SpawnPoint, 200 - self.cameraX, 0 - self.cameraY)
    
    for _, b in ipairs(buttons) do
        if b.IsEnabled() then
            love.graphics.setColor(1,1,1,0.5) 
        else
            love.graphics.setColor(1,1,1,1)
        end
        
        love.graphics.draw(sprites[b.Sprite], b.Transform[1], b.Transform[2])
    end
end

function love.filedropped(file)
    file:open("r")
    f = file
    local mapString = file:read("string")
    map = mapLoader:GooseToTable(mapString)
    f:close()
end

return editor