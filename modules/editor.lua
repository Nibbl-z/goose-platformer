local editor = {}

local map = {}

editor.enabled = true

local camDirections = {
    up = {0,-1}, down = {0,1}, left = {-1, 0}, right = {1,0}
}
editor.cameraX = 0
editor.cameraY = 0
editor.camSpeed = 500

local currentPlatform
local mapLoader = require("modules.mapLoader")

function love.mousepressed(x, y, button)
    
    if editor.enabled == false then return end
    if button ~= 1 then return end
    print(x, y, button)
    currentPlatform = {}
    currentPlatform.X = x + editor.cameraX
    currentPlatform.Y = y + editor.cameraY
    currentPlatform.W = 1
    currentPlatform.H = 1
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
    love.graphics.setColor(0, 0, 0,1)
    for _, p in ipairs(map) do
        love.graphics.rectangle("fill", p.X - self.cameraX, p.Y - self.cameraY, p.W, p.H, 10, 10)
    end
    if currentPlatform ~= nil then
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("fill", currentPlatform.X - self.cameraX, currentPlatform.Y - self.cameraY, currentPlatform.W, currentPlatform.H)
    end
end

return editor