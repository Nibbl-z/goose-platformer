local win = {}

win.enabled = false

local sprites = {
    Winner = "winner.png",
    Menu = "menu.png"
}

local sounds = {
    Select = {"select.wav", "static"}
}

local collision = require("modules.collision")
local menu
local mapLoader = require("modules.mapLoader")

local buttons = {
    {
        Sprite = "Menu",
        Transform = {10, 220, 300, 150},
        Callback = function ()
            mapLoader:Unload()
            menu:Reset()
            menu:RefreshLevels()
            menu.enabled = true
            win.enabled = false
        end
    }
}

function win:Init()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
    
    for name, sound in pairs(sounds) do
        sounds[name] = love.audio.newSource("/audio/"..sound[1], sound[2])
    end

    menu = require("modules.menu")
end


function win:mousepressed(x, y, button)
    if self.enabled == false then return end
    if button ~= 1 then return end
    
    for _, b in ipairs(buttons) do
        if collision:CheckCollision(x, y, 1, 1, b.Transform[1], b.Transform[2], b.Transform[3], b.Transform[4]) then
            sounds.Select:play()
            b.Callback()
        
            
        end
    end
end

function win:Draw()
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1,1,1,1)
    
    love.graphics.draw(sprites.Winner, 0, 0)
    
    for _, b in ipairs(buttons) do
        love.graphics.draw(sprites[b.Sprite], b.Transform[1], b.Transform[2])
    end
end


return win