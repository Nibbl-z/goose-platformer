local menu = {}

local sprites = {
    Logo = "logo.png",
    Play = "play.png",
    Editor = "editor.png",
    NewLevel = "newlevel.png"
}

menu.enabled = true
local collision = require("modules.collision")
local mapLoader = require("modules.mapLoader")
local player = require("modules.player")
local editor = require("modules.editor")
local levelList = {}
local levelButtons = {}

local tab = ""

local buttons = {
    {
        Sprite = "Play",
        Transform = {10, 110, 300, 225},
        Visible = function ()
            return true
        end,
        Callback = function ()
            tab = "play"
            love.filesystem.setIdentity("goose-platformer")
            
            levelList = {}
            levelButtons = {}
            
            local index = 1

            for _, v in ipairs(love.filesystem.getDirectoryItems("")) do
                if v:match("^.+(%..+)$") == ".goose" then
                    
                    table.insert(levelList, v)
                    
                    table.insert(levelButtons, {
                        Transform = {360, 120 + ((index - 1) * 55), 380, 50},
                        Callback = function ()
                            print(v)
                            mapLoader:Load(v)
                            player:Respawn()
                            menu.enabled = false
                        end
                    })
                    
                   

                    index = index + 1
                end
            end
        end
    },
    
    {
        Sprite = "Editor",
        Transform = {10, 340, 300, 225},
        Visible = function ()
            return true
        end,
        Callback = function ()
            tab = "editor"
            love.filesystem.setIdentity("goose-platformer")
            
            levelList = {}
            levelButtons = {}
            
            local index = 1

            for _, v in ipairs(love.filesystem.getDirectoryItems("")) do
                if v:match("^.+(%..+)$") == ".goose" then
                    
                    table.insert(levelList, v)
                    
                    table.insert(levelButtons, {
                        Transform = {360, 120 + ((index - 1) * 55), 380, 50},
                        Callback = function ()
                            print(v)
                            mapLoader:Load(v)
                            editor:Load(v)
                            editor.enabled = true
                            menu.enabled = false
                        end
                    })

                    
                    index = index + 1
                end
            end
        end
    },
    
    {
        Sprite = "NewLevel",
        Transform = {350, 560, 400, 50},
        IsVisible = function ()
            if tab == "editor" then return true else return false end
        end,
        Callback = function ()
            love.filesystem.setIdentity("goose-platformer")
            local newFile = love.filesystem.newFile("helpme.goose")
            
            newFile:open("w")
            newFile:write("")
        end
    }
}



local font

function menu:DrawLevelList()
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line", 350, 110, 400, 450)
    
    for i, v in ipairs(levelList) do
        love.graphics.setFont(font)
        love.graphics.rectangle("line", 360, 120 + ((i - 1) * 55), 380, 50)
        love.graphics.print(v, 360, 120 + ((i - 1) * 55))
    end
end

function menu:Load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end

    font = love.graphics.newFont(40)
end

function menu:Reset()
    levelList = {}
    levelButtons = {}
end

function menu:mousepressed(x, y, button)
    if menu.enabled == false then return end
    if button ~= 1 then return end

    for _, b in ipairs(buttons) do
        if collision:CheckCollision(x, y, 1, 1, b.Transform[1], b.Transform[2], b.Transform[3], b.Transform[4]) then
            b.Callback()

            
        end
    end
    for _, b in ipairs(levelButtons) do
        print(b.Transform[2])
        if collision:CheckCollision(x, y, 1, 1, b.Transform[1], b.Transform[2], b.Transform[3], b.Transform[4]) then
            b.Callback()
        
            
        end
    end
end

function menu:Draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.setBackgroundColor(1,1,1,1)
    love.graphics.draw(sprites.Logo, 0, 0)
    
    for _, b in ipairs(buttons) do
        love.graphics.draw(sprites[b.Sprite], b.Transform[1], b.Transform[2])
    end

    self:DrawLevelList()
end

return menu