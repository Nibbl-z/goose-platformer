local player = {}
local movementDirections = {a = {-1,0}, d = {1,0}, space = {0,-1}}

local camDirections = {
    up = {0,-1}, down = {0,1}, left = {-1, 0}, right = {1,0}
}

player.speed = 5000
player.maxSpeed = 400
player.direction = 1
player.jumpHeight = 1500
player.onGround = false

player.cameraX = 0
player.cameraY = 0

local cX, cY = 0, 0

player.camOffsetX = 400
player.camOffsetY = 200
player.camSpeed = 500

local collision = require("modules.collision")

local jumped = false

local function lerp(a, b, t)
    return t < 0.5 and a + (b - a) * t or b + (a - b) * (1 - t)
end

function player:Init(world)
    self.body = love.physics.newBody(world, 200, 0, "dynamic")
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

    local velX, velY = self.body:getLinearVelocity()
    self.body:setLinearVelocity(math.min(velX, self.maxSpeed), math.min(velY, self.maxSpeed))
    
    cX = lerp(cX, self.body:getX(), 0.05)
    cY = lerp(cY, self.body:getY(), 0.05)

    self.cameraX = cX - self.camOffsetX
    self.cameraY = cY - self.camOffsetY
    
    --[[for key, mult in pairs(camDirections) do
        if love.keyboard.isDown(key) then
            self.cameraX = self.cameraX + mult[1] * dt * self.camSpeed
            self.cameraY = self.cameraY + mult[2] * dt * self.camSpeed
        end
    end]]
    
    if self.body:getY() > 1000 then
        self:Respawn()
    end
end

function player:Respawn()
    self.body:setX(200)
    self.body:setY(0)
end

return player