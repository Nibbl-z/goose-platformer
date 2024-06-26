local mapLoader = {}

local data = {
    {
        X = 10,
        Y = 60,
        W = 200,
        H = 50
    }
}

mapLoader.map = {}

function mapLoader:Load(world)
    for _, platform in ipairs(data) do
        local p = {}
        
        p.body = love.physics.newBody(world, platform.X, platform.Y, "static")
        p.shape = love.physics.newRectangleShape(platform.W, platform.H)
        p.fixture = love.physics.newFixture(p.body, p.shape)
        
        p.fixture:setRestitution(0)

        table.insert(self.map, p)
    end
end

return mapLoader