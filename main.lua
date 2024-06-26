local sprites = {
    Player = "player.png"
}

local world = love.physics.newWorld(0, 196 * 3, true)
local player = require("modules.player")

function love.load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end

    player:Init(world)
end

function love.update(dt)
    world:update(dt)

    player:HandleMovement(dt)
end

function love.draw()
    love.graphics.draw(sprites.Player, player.body:getX(), player.body:getY(), 0, player.direction, 1, 25, 25)
end