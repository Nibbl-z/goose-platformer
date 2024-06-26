local mapLoader = {}

local data = {
    {
        X = 0,
        Y = 200,
        W = 200,
        H = 50
    },

    {
        X = 300,
        Y = 200,
        W = 200,
        H = 50
    }
}

mapLoader.map = {}

function mapLoader:Load(world)
    for _, platform in ipairs(data) do
        local p = {}
        
        p.body = love.physics.newBody(world, platform.X + (platform.W / 2), platform.Y + (platform.H / 2), "static")
        p.shape = love.physics.newRectangleShape(platform.W, platform.H)
        p.fixture = love.physics.newFixture(p.body, p.shape)
        
        p.fixture:setRestitution(0)

        table.insert(self.map, p)
    end
end

return mapLoader