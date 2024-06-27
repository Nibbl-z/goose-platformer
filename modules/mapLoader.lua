local mapLoader = {}

mapLoader.data = {
}

mapLoader.map = {}

local str = require("modules.str")

function mapLoader:GooseToTable(gooseFile)
    local contents = gooseFile
    local data = {}
    for _, platform in ipairs(str:split(contents, "|")) do
        local p = {}
        for _, property in ipairs(str:split(platform, ";")) do
            local kp = str:split(property, ":")
            print(kp[1], kp[2])
            p[kp[1]] = tonumber(kp[2])
        end
        table.insert(data, p)
    end

    return data
end

function mapLoader:TableToGoose(map)
    local goose = ""

    for _, platform in ipairs(map) do
        for k, p in pairs(platform) do
            goose = goose..k..":"..tostring(p)..";"
        end

        goose = goose.."|"
    end

    return goose
end

function mapLoader:Load(world)
    self.data = mapLoader:GooseToTable(love.filesystem.read("/maps/test.goose"))
    
    for _, platform in ipairs(self.data) do
        local p = {}
        
        p.body = love.physics.newBody(world, platform.X + (platform.W / 2), platform.Y + (platform.H / 2), "static")
        p.shape = love.physics.newRectangleShape(platform.W, platform.H)
        p.fixture = love.physics.newFixture(p.body, p.shape)
        p.fixture:setUserData("platform")
        p.fixture:setRestitution(0)

        table.insert(self.map, p)
    end
end

return mapLoader