local sprites = {
    Player = "player.png",
    Lava = "lava.png",
}

local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local mapLoader = require("modules.mapLoader")
local editor = require("modules.editor")
local menu = require("modules.menu")
local pause = require("modules.pause")

local respawnDelay = false

function love.load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
    
    world:setCallbacks(beginContact, endContact)
    
    menu:Load()
    editor:Init()
    
    player:Init(world)
    mapLoader:Init(world)
    pause:Init()
    --mapLoader:Load(world)
end

function love.keypressed(key, scancode, rep)
    if rep then return end

    if scancode == "p" then
        editor.enabled = not editor.enabled
        mapLoader:Load(world)
    end

    if scancode == "escape" then
        if menu.enabled == false then
            pause.paused = not pause.paused
        end
    end
end

function love.mousepressed(x, y, button)
    menu:mousepressed(x, y, button)
    editor:mousepressed(x, y, button)
    pause:mousepressed(x, y, button)
end

function love.update(dt)
    if editor.enabled == false and menu.enabled == false and pause.paused == false then
        world:update(dt)
        player:Update(dt, mapLoader.data)
        
        if respawnDelay then
            player:Respawn()
            respawnDelay = false
        end
    else
        editor:Update(dt)
    end
    
end

function love.draw()
    if menu.enabled then
        menu:Draw()
    end
    
    if editor.enabled == false and menu.enabled == false then
        love.graphics.setBackgroundColor(1,1,1,1)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sprites.Player, player.body:getX() - player.cameraX, player.body:getY() - player.cameraY, 0, player.direction, 1, 25, 25)

        love.graphics.setColor(0,0,0,1)
        for _, p in ipairs(mapLoader.data) do
            
            if p.T == 1 then
                love.graphics.setColor(p.R, p.G, p.B, 1)
                love.graphics.rectangle("fill", p.X - player.cameraX, p.Y - player.cameraY, p.W, p.H, 10, 10)
            else
                love.graphics.setColor(1,1,1, 1)
                love.graphics.draw(sprites.Lava, p.X - player.cameraX, p.Y - player.cameraY, 0, p.W/ 100, p.H / 100)
            end
        end
    end

    if editor.enabled == true then
        editor:Draw()
    end
    
    if pause.paused == true then
        pause:Draw()
    end
end

function beginContact(a, b)
    if a:getUserData() == "player" and b:getUserData() == "lava" then
        print("death")
        respawnDelay = true
    end
end

function endContact(a, b)
    
end