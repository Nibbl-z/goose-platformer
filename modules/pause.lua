local pause = {}

pause.paused = false
local collision = require("modules.collision")
local menu = require("modules.menu")
local mapLoader = require("modules.mapLoader")
local editor = require("modules.editor")
local player = require("modules.player")


local buttons = {
    {
        Sprite = "Resume",
        Transform = {10, 60, 300, 150},
        Callback = function ()
            pause.paused = false
        end
    },

    {
        Sprite = "Restart",
        Transform = {10, 220, 300, 150},
        Callback = function ()
            player:ResetCheckpoint()
            player:Respawn()
            pause.paused = false
        end
    },
    
    {
        Sprite = "Menu",
        Transform = {10, 380, 300, 150},
        Callback = function ()
            mapLoader:Unload()
            pause.paused = false
            editor.enabled = false
            menu:Reset()
            menu:RefreshLevels()
            menu.enabled = true
        end
    },
    
}

local sprites = {
    Paused = "paused.png",
    Resume = "resume.png",
    Restart = "restart.png",
    Menu = "menu.png"
}

local sounds = {
    Select = {"select.wav", "static"}
}


function pause:Init()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
    
    for name, sound in pairs(sounds) do
        sounds[name] = love.audio.newSource("/audio/"..sound[1], sound[2])
    end
end

function pause:mousepressed(x, y, button)
    if self.paused == false then return end
    if button ~= 1 then return end
    
    for _, b in ipairs(buttons) do
        if collision:CheckCollision(x, y, 1, 1, b.Transform[1], b.Transform[2], b.Transform[3], b.Transform[4]) then
            sounds.Select:play()
            b.Callback()
        
            
        end
    end
end

function pause:Draw()
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1,1,1,1)
    
    love.graphics.draw(sprites.Paused, 0, 0)
    
    for _, b in ipairs(buttons) do
        love.graphics.draw(sprites[b.Sprite], b.Transform[1], b.Transform[2])
    end
end




return pause