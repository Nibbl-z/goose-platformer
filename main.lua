local sprites = {
    Player = "player.png"
}

local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local mapLoader = require("modules.mapLoader")
local editor = require("modules.editor")

function love.load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
    

    --world:setCallbacks(beginContact, endContact)

    editor:Load()
    
    

    player:Init(world)
    mapLoader:GooseToTable()
    mapLoader:Load(world)
end

function love.update(dt)
    if editor.enabled == false then
        world:update(dt)
        player:Update(dt, mapLoader.data)
    else
        editor:Update(dt)
    end
end

function love.draw()
    if editor.enabled == false then
        love.graphics.setBackgroundColor(1,1,1,1)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sprites.Player, player.body:getX() - player.cameraX, player.body:getY() - player.cameraY, 0, player.direction, 1, 25, 25)

        love.graphics.setColor(0,0,0,1)
        for _, p in ipairs(mapLoader.data) do
            
            love.graphics.rectangle("fill", p.X - player.cameraX, p.Y - player.cameraY, p.W, p.H, 10, 10)
        end
    end

    if editor.enabled == true then
        editor:Draw()
    end
end

--[[function beginContact(a, b)
    if a:getUserData() == "player" and b:getUserData() == "platform" then
        print("yay")
        player.onGround = true
    end
end

function endContact(a, b)
    if a:getUserData() == "player" and b:getUserData() == "platform" then
        print("aw")
        player.onGround = false
    end
end]]