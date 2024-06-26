local player = {}
local movementDirections = {a = {-1,0}, d = {1,0}, space = {0,-1}}

player.speed = 100
player.direction = 1
player.jumpHeight = 3000
 

local jumped = false

function player:Init(world)
    self.body = love.physics.newBody(world, 0, 0, "dynamic")
    self.body:setLinearDamping(5)
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    
    self.fixture:setRestitution(0)
end

function player:HandleMovement(dt)
    for key, mult in pairs(movementDirections) do
        if love.keyboard.isDown(key) then
            if key == "space" and jumped == false then
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