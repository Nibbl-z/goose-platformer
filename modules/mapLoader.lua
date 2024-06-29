local mapLoader = {}

mapLoader.data = {
}

mapLoader.map = {}

local str = require("modules.str")
local world

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

function mapLoader:Init(w)
    world = w
end

function mapLoader:Load(filename)
    love.filesystem.setIdentity("goose-platformer")
    
    self.data = mapLoader:GooseToTable(love.filesystem.read(filename))
    
    for _, platform in ipairs(self.data) do
        local p = {}
        
        p.body = love.physics.newBody(world, platform.X + (platform.W / 2), platform.Y + (platform.H / 2), "static")
        p.shape = love.physics.newRectangleShape(platform.W, platform.H)
        p.fixture = love.physics.newFixture(p.body, p.shape)
        if platform.T == 1 then
            p.fixture:setUserData("platform")
        elseif platform.T == 2 then
            p.fixture:setUserData("lava")
        elseif platform.T == 3 then
            p.fixture:setUserData("checkpoint")
            p.fixture:setMask(1,2)
        elseif platform.T == 4 then
            p.fixture:setUserData("finish")
            p.fixture:setMask(1,2)
        end
        
        p.fixture:setRestitution(0)
        
        table.insert(self.map, p)
    end
end


function mapLoader:Unload()
    for _, v in ipairs(self.map) do
        if v.body:isDestroyed() == false then
            v.body:destroy()
        end
        
        v = nil
    end
end

return mapLoader