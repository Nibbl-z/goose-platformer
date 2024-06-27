local sprites = {
    Player = "player.png"
}

local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local mapLoader = require("modules.mapLoader")

function love.load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
    

    --world:setCallbacks(beginContact, endContact)
    player:Init(world)
    mapLoader:Load(world)
end

function love.update(dt)
    world:update(dt)
    
    player:Update(dt, mapLoader.data)
end

function love.draw()
    love.graphics.draw(sprites.Player, player.body:getX() - player.cameraX, player.body:getY() - player.cameraY, 0, player.direction, 1, 25, 25)
    
    for _, p in ipairs(mapLoader.data) do
        love.graphics.rectangle("fill", p.X - player.cameraX, p.Y - player.cameraY, p.W, p.H)
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