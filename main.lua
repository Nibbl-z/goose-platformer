local sprites = {
    Player = "player.png",
    Lava = "lava.png",
    Checkpoint = "checkpoint.png",
    Finish = "finish.png"
}

local sounds = {
    Gameplay = {"goose.mp3", "stream"},
    Menu = {"menu.mp3", "stream"},
    Editor = {"editor.mp3", "stream"}
}

local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local mapLoader = require("modules.mapLoader")
local editor = require("modules.editor")
local menu = require("modules.menu")
local pause = require("modules.pause")
local win = require("modules.win")

local respawnDelay = false

function love.load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end

    for name, sound in pairs(sounds) do
        sounds[name] = love.audio.newSource("/audio/"..sound[1], sound[2])
    end
    
    world:setCallbacks(beginContact, endContact)
    
    menu:Load()
    editor:Init()
    
    player:Init(world)
    mapLoader:Init(world)
    pause:Init()
    win:Init()

    love.window.setTitle("Goose Platformer")
    love.window.setIcon(love.image.newImageData("/img/player.png"))
    --mapLoader:Load(world)
end

function love.textinput(t)
    if menu.settingLevelName then
        menu:HandleTypingName(t)
    end
end

function love.keypressed(key, scancode, rep)
    if menu.settingLevelName then
        menu:HandleTypingKey(key, scancode, rep)
    end
    
    if rep then return end

    if scancode == "escape" then
        if menu.enabled == false and win.enabled == false then
            pause.paused = not pause.paused
        end
    end
end

function love.mousepressed(x, y, button)
    menu:mousepressed(x, y, button)
    editor:mousepressed(x, y, button)
    pause:mousepressed(x, y, button)
    win:mousepressed(x,y,button)
end

function love.update(dt)
    if editor.enabled == true then
        if pause.paused then
            sounds.Editor:setVolume(0.3)
        else
            sounds.Editor:setVolume(0.5)
        end
        sounds.Editor:setLooping(true)
        sounds.Editor:play()
    else
        sounds.Editor:stop()
    end
    
    if editor.enabled == false and menu.enabled == false then
        if pause.paused then
            sounds.Gameplay:setVolume(0.3)
        else
            sounds.Gameplay:setVolume(0.5)
        end
        
        sounds.Gameplay:setLooping(true)
        sounds.Gameplay:play()
    else
        sounds.Gameplay:stop()
    end

    if menu.enabled == true then
        sounds.Menu:setVolume(0.5)
        sounds.Menu:setLooping(true)
        sounds.Menu:play()
    else
        sounds.Menu:stop()
    end

    if editor.enabled == false and menu.enabled == false and pause.paused == false then
        world:update(dt)
        player:Update(dt, mapLoader.data)
        
        if respawnDelay then
            player:Respawn()
            player:Death()
            respawnDelay = false
        end
    else
        editor:Update(dt)
    end
    
end

function love.draw()
    if menu.enabled then
        menu:Draw()
    end
    
    if editor.enabled == false and menu.enabled == false then
        love.graphics.setBackgroundColor(1,1,1,1)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sprites.Player, player.body:getX() - player.cameraX, player.body:getY() - player.cameraY, 0, player.direction, 1, 25, 25)

        love.graphics.setColor(0,0,0,1)
        for _, p in ipairs(mapLoader.data) do
            
            if p.T == 1 then
                love.graphics.setColor(p.R, p.G, p.B, 1)
                love.graphics.rectangle("fill", p.X - player.cameraX, p.Y - player.cameraY, p.W, p.H, 10, 10)
            elseif p.T == 2 then
                love.graphics.setColor(1,1,1, 1)
                love.graphics.draw(sprites.Lava, p.X - player.cameraX, p.Y - player.cameraY, 0, p.W/ 100, p.H / 100)
            elseif p.T == 3 then
                love.graphics.setColor(1,1,1, 1)
                love.graphics.draw(sprites.Checkpoint, p.X - player.cameraX, p.Y - player.cameraY, 0, 1, 1, 12.5, 25)
            elseif p.T == 4 then
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(sprites.Finish, p.X - player.cameraX, p.Y - player.cameraY)
            end
        end
    end

    if editor.enabled == true then
        editor:Draw()
    end
    
    if pause.paused == true then
        pause:Draw()
    end

    if win.enabled == true then
        win:Draw()
    end
end

function beginContact(a, b)
    if a:getUserData() == "player" and b:getUserData() == "lava" then
        print("death")
        respawnDelay = true
    end
end

function endContact(a, b)
    
end