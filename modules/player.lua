local player = {}
local movementDirections = {a = {-1,0}, d = {1,0}, space = {0,-1}}

player.speed = 1000
player.direction = 1

function player:Init(world)
    self.body = love.physics.newBody(world, 0, 0, "dynamic")
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setRestitution(0)
end

function player:HandleMovement(dt)
    for key, mult in pairs(movementDirections) do
        if love.keyboard.isDown(key) then
            self.body:applyForce(self.speed * mult[1], self.speed * mult[2])

            if key == "a" then
                self.direction = 1
            elseif key == "d" then
                self.direction = -1
            end
        
        end
    end
end

return player