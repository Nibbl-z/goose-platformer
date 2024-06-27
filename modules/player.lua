local player = {}
local movementDirections = {a = {-1,0}, d = {1,0}, space = {0,-1}}

player.speed = 5000
player.direction = 1
player.jumpHeight = 1500
player.onGround = false

local collision = require("modules.collision")

local jumped = false

function player:Init(world)
    self.body = love.physics.newBody(world, 20, 0, "dynamic")
    self.body:setLinearDamping(1)
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData("player")
    self.fixture:setRestitution(0)
end

function player:Update(dt, map)
    -- Movement
    if not love.keyboard.isDown("space") then
        jumped = false
    end
    
    self.onGround = false

    --[[for _, p in ipairs(map) do
        if collision:CheckCollision(
            self.body:getX() - 2, self.body:getY(), 52, 56,
            p.X, p.Y, p.W, p.H
        ) then
            self.onGround = true
            break
        end
    end]]

    if #self.body:getContacts() >= 1 then
        self.onGround = true
    end
    
    for key, mult in pairs(movementDirections) do
        if love.keyboard.isDown(key) then
            local impulseX = 0
            local impulseY = 0
            
            if key == "space" and self.onGround and not jumped then
                print("jump")

                impulseY = self.jumpHeight * mult[2]

                jumped = true
            else
                impulseX = self.speed * mult[1] * dt
                
                if key == "a" then
                    self.direction = 1
                elseif key == "d" then
                    self.direction = -1
                end
            end

            self.body:applyLinearImpulse(impulseX, impulseY)
        end
    end
    
   
end

return player