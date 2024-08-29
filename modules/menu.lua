local menu = {}

local sprites = {
    Logo = "logo.png",
    Play = "play.png",
    Editor = "editor.png",
    NewLevel = "newlevel.png",
    DeleteLevel = "deletelevel.png",
    Left = "left.png",
    Right = "right.png",
    Rename = "rename.png",
    Online = "onlinebutton.png"
}

local sounds = {
    Select = {"select.wav", "static"},
    Delete = {"delete.wav", "static"}
}

menu.enabled = true
menu.settingLevelName = false

local levelToRename

local name = ""

local collision = require("modules.collision")
local mapLoader = require("modules.mapLoader")
local player = require("modules.player")
local editor = require("modules.editor")
local https = require("https")
local str = require("modules.str")

local levelList = {}
local levelButtons = {}

local utf8 = require("utf8")

local tab = ""

local currentLevel = 1

local buttons = {
    {
        Sprite = "Play",
        Transform = {60, 370, 300, 225},
        Callback = function ()

            if levelList[currentLevel] == nil then return end

            love.filesystem.setIdentity("goose-platformer")
            sounds.Select:play()
            mapLoader:Load(levelList[currentLevel])
            player:ResetCheckpoint()
            player:Respawn()
            menu.enabled = false
        end
    },
    
    {
        Sprite = "Editor",
        Transform = {love.graphics.getWidth() - 360, 370, 300, 225},
        Callback = function ()
            if levelList[currentLevel] == nil then return end

            tab = "editor"
            sounds.Select:play()
            love.filesystem.setIdentity("goose-platformer")
            
            --mapLoader:Load(levelList[currentLevel])
            editor.enabled = true
            editor:Load(levelList[currentLevel])
            menu.enabled = false
        end
    },
    
    {
        Sprite = "NewLevel",
        Transform = {70, 250, 50, 50},
        Callback = function ()
            sounds.Select:play()
            menu.settingLevelName = true
        end
    },
    
    {
        Sprite = "DeleteLevel",
        Transform = {130, 250, 50, 50},
        Callback = function ()
            if levelList[currentLevel] == nil then return end
            
            local result = love.window.showMessageBox(
                "Confirm Delete", 
                "Are you sure you want to delete "..string.sub(levelList[currentLevel], 1, -7).."?",
                {"Cancel", "Delete"},
                "info",
                true
            )
            
            if result == 2 then
                sounds.Delete:play()

                local result = love.filesystem.remove(levelList[currentLevel])

                for i, v in ipairs(levelList) do
                    if v == levelList[currentLevel] then 
                        table.remove(levelList, i)
                    end
                end

                if currentLevel > #levelList then
                    currentLevel = 1
                end
            end
        end
    },

    {
        Sprite = "Rename",
        Transform = {190, 250, 50, 50},
        Callback = function ()
            if levelList[currentLevel] == nil then return end
            levelToRename = levelList[currentLevel]
            menu.settingLevelName = true
            sounds.Select:play()
            
        end
    },

    {
        Sprite = "Left",
        Transform = {5, 110, 50, 200},
        Callback = function ()
            sounds.Select:play()
            currentLevel = currentLevel - 1

            if currentLevel <= 0 then
                currentLevel = #levelList
            end
        end
    },
    
    {
        Sprite = "Right",
        Transform = {love.graphics.getWidth() - 55, 110, 50, 200},
        Callback = function ()
            sounds.Select:play()
            currentLevel = currentLevel + 1

            if currentLevel > #levelList then
                currentLevel = 1
            end
        end
    },
     
    {
        Sprite = "Online",
        Transform = {love.graphics.getWidth() - 55, 5, 50, 50},
        Callback = function ()
            sounds.Select:play()
            levelList = {}
            local code, body = https.request("http://localhost:3500/levels/", {method = "GET"})
            body = string.sub(body, 2, -2)
            for _, v in ipairs(str:split(body, ",")) do
                print(v)
                table.insert(levelList, string.sub(v, 2, -2))
            end
        end
    }
}



local font

function menu:RefreshLevels()
    love.filesystem.setIdentity("goose-platformer")
            
    levelList = {}

    for _, v in ipairs(love.filesystem.getDirectoryItems("")) do
        if v:match("^.+(%..+)$") == ".goose" then
            table.insert(levelList, v)
        end
    end
end

function menu:DrawLevelList()
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line", 60, 110, love.graphics.getWidth() - 120, 200)
    
    
    love.graphics.setFont(font)
    
    if self.settingLevelName then
        love.graphics.printf(name.."|", 70, 120, love.graphics.getWidth() - 120)
    else
        if #levelList > 0 then
            love.graphics.printf(string.sub(levelList[currentLevel], 1, -7), 70, 120, love.graphics.getWidth() - 120)
        else
            love.graphics.printf("Press the + button to create your first level!", 70, 120, love.graphics.getWidth() - 120)
        end
    end
    
    if #levelList > 0 then
        love.graphics.printf(tostring(currentLevel).."/"..tostring(#levelList), love.graphics.getWidth() - 370, 250, 300, "right")
    end
    
end

function menu:Load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end

    for name, sound in pairs(sounds) do
        sounds[name] = love.audio.newSource("/audio/"..sound[1], sound[2])
    end

    font = love.graphics.newFont(50)
    
    self:RefreshLevels()
end

function menu:Reset()
    levelList = {}
    levelButtons = {}
end

local rejectedCharacters = {
    "\\", "/", ":", "*", "?", "\"", "<", ">", "|"
}

function menu:HandleTypingName(t)
    for _, v in pairs(rejectedCharacters) do
        if v == t then
            return
        end
    end

    name = name..t
end

function menu:HandleTypingKey(key, scancode, rep)
    if scancode == "backspace" then
        local byteoffset = utf8.offset(name, -1)
        
        if byteoffset then
            name = string.sub(name, 1, byteoffset - 1)
        end
    end
    
    if scancode == "return" then
        love.filesystem.setIdentity("goose-platformer")

        if levelToRename == nil then
            local newFile = love.filesystem.newFile(name..".goose")
            
            newFile:open("w")
            newFile:write("")
            newFile:close()
        else
            local oldFile = love.filesystem.newFile(levelToRename)
            oldFile:open("r")
            print(levelToRename)
            local levelData = oldFile:read()
            print(levelData)
            oldFile:close()
            
            love.filesystem.remove(levelToRename)
            
            local newFile = love.filesystem.newFile(name..".goose")
            
            newFile:open("w")
            newFile:write(levelData)
            newFile:close()
        end
        
        self.settingLevelName = false
        self:RefreshLevels()

        for i, v in ipairs(levelList) do
            if v == name..".goose" then
                currentLevel = i
            end
        end
        
        name = ""
        levelToRename = nil
    end
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