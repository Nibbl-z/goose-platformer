local player = {}
local movementDirections = {a = {-1,0}, d = {1,0}, space = {0,-1}}

player.speed = 100
player.direction = 1
player.jumpHeight = 3000
player.onGround = false
 

local jumped = false

function player:Init(world)
    self.body = love.physics.newBody(world, 0, 0, "dynamic")
    self.body:setLinearDamping(5)
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    
    self.fixture:setRestitution(0)
end

function player:Update(dt, map)
    -- Grounded
    self.onGround = false
    for _, p in ipairs(map) do
        for i = -20, 70 do
            if p.fixture:testPoint(self.body:getX() + i, self.body:getY() + 40) then
                self.onGround = true
                
                break
            end
        end
    end
    
    print(self.onGround)

    -- Movement
    for key, mult in pairs(movementDirections) do
        if love.keyboard.isDown(key) then
            if key == "space" and self.onGround and not jumped then
                local lX = self.body:getLinearVelocity()
                
                self.body:setLinearVelocity(lX, 0)
                self.body:applyLinearImpulse(self.jumpHeight * mult[1], self.jumpHeight * mult[2])
                jumped = true
            else
                self.body:applyLinearImpulse(self.speed * mult[1], self.speed * mult[2])
                
                if key == "a" then
                    self.direction = 1
                elseif key == "d" then
                    self.direction = -1
                end
            end
        end
    end

    if not love.keyboard.isDown("space") then
        jumped = false
    end

    
end

return player