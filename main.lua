local sprites = {
    Player = "player.png"
}

local world = love.physics.newWorld(0, 196, true)
local player = require("modules.player")
local mapLoader = require("modules.mapLoader")

function love.load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
    
    player:Init(world)
    mapLoader:Load(world)
end

function love.update(dt)
    world:update(dt)

    player:HandleMovement(dt)
end

function love.draw()
    love.graphics.draw(sprites.Player, player.body:getX(), player.body:getY(), 0, player.direction, 1, 25, 25)
    
    for _, p in ipairs(mapLoader.map) do
        
        love.graphics.polygon("fill", p.body:getWorldPoints(p.shape:getPoints()))
    end
end