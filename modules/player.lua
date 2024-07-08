local player = {}
local movementDirections = {a = {-1,0}, d = {1,0}, space = {0,-1}}

local camDirections = {
    up = {0,-1}, down = {0,1}, left = {-1, 0}, right = {1,0}
}

local sounds = {
    Death = {"death.wav", "static"},
    Checkpoint = {"checkpoint.wav", "static"},
    Finish = {"finish.wav", "static"}
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

player.checkpointX = 200
player.checkpointY = 0

player.disableMovement = false

local collision = require("modules.collision")
local win = require("modules.win")

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

    for name, sound in pairs(sounds) do
        sounds[name] = love.audio.newSource("/audio/"..sound[1], sound[2])
    end
end

function player:Update(dt, map)
    -- Movement
    
    

    if love.keyboard.isDown("r") then
        self:Respawn()
    end
    if not love.keyboard.isDown("space") then
        jumped = false
    end
    
    self.onGround = false
    
    for _, p in ipairs(map) do
        if p.T == 3 then
            if collision:CheckCollision(
                self.body:getX(), self.body:getY(), 52, 56,
                p.X, p.Y, p.W, p.H
            ) then
                if self.checkpointX ~= p.X and self.checkpointY ~= p.Y then
                    sounds.Checkpoint:play()
                end
                self.checkpointX = p.X
                self.checkpointY = p.Y
                break
            end
        end

        if p.T == 4 then
            if collision:CheckCollision(
                self.body:getX(), self.body:getY(), 52, 56,
                p.X, p.Y, p.W, p.H
            ) then
                if not win.enabled then
                    sounds.Finish:play()
                end

                win.enabled = true
                self.disableMovement = true
                break
            end
        end
    end
    
    if #self.body:getContacts() >= 1 then
        self.onGround = true
    end
    
    for key, mult in pairs(movementDirections) do
        if love.keyboard.isDown(key) then
            local impulseX = 0
            local impulseY = 0
            
            if key == "space" and self.onGround and not jumped then        
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
            
            if not self.disableMovement then 
                self.body:applyLinearImpulse(impulseX, impulseY)
            end
        end
    end

    local velX, velY = self.body:getLinearVelocity()
    
    if velX > self.maxSpeed then velX = self.maxSpeed 
    elseif velX < -self.maxSpeed then velX = -self.maxSpeed end
    
    if not self.disableMovement then 
        self.body:setLinearVelocity(velX, velY)
    end
    
    cX = lerp(cX, self.body:getX(), 0.1)
    cY = lerp(cY, self.body:getY(), 0.1)
    
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

function player:Death()
    sounds.Death:play()
end


function player:ResetCheckpoint()
    self.checkpointX = 200
    self.checkpointY = 0

    self.disableMovement = false
end

function player:Respawn()
    self.body:setLinearVelocity(0,0)
    
    self.body:setX(self.checkpointX)
    self.body:setY(self.checkpointY)
end

return player