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
    Online = "onlinebutton.png",
    Offline = "localbutton.png",
    Upload = "upload.png"
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
local onlineMode = false

local levelList = {}
local levelButtons = {}

local utf8 = require("utf8")

local tab = ""

local currentLevel = 1

local url = require("socket.url")

function urlencode(list)
	local result = {}
	for k, v in pairs(list) do
		result[#result + 1] = url.escape(k).."="..url.escape(v)
	end
	return table.concat(result, "&")
end

local buttons = {
    {
        Sprite = "Play",
        Transform = {60, 370, 300, 225},
        Callback = function ()
            
            if levelList[currentLevel] == nil then return end

            love.filesystem.setIdentity("goose-platformer")
            sounds.Select:play()
            
            if onlineMode then
                print(levelList[currentLevel])
                local _, body = https.request(string.format("http://localhost:%s/data/", tostring(require("settings").PORT))..levelList[currentLevel], {method = "GET"})
                print(body)
                mapLoader:Load(body, true)
            else
                mapLoader:Load(levelList[currentLevel], false)
            end
            
           
            player:ResetCheckpoint()
            player:Respawn()
            menu.enabled = false
        end,
        Visible = function ()
            return true
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
        end,
        Visible = function ()
            return not onlineMode
        end
    },
    
    {
        Sprite = "NewLevel",
        Transform = {70, 250, 50, 50},
        Callback = function ()
            sounds.Select:play()
            menu.settingLevelName = true
        end,
        Visible = function ()
            return not onlineMode
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
        end,
        Visible = function ()
            return not onlineMode
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
        end,
        Visible = function ()
            return not onlineMode
        end
    },

    {
        Sprite = "Upload",
        Transform = {250, 250, 50, 50},
        Callback = function ()
            if levelList[currentLevel] == nil then return end
            love.filesystem.setIdentity("goose-platformer")
            local _, body = https.request(string.format("http://localhost:%s/upload/", tostring(require("settings").PORT)), 
                {method = "POST", data = urlencode{["name"] = string.sub(levelList[currentLevel], 1, -7), ["data"] = love.filesystem.read(levelList[currentLevel])}}
            )
            print(body)

            sounds.Select:play()
        end,
        Visible = function ()
            return not onlineMode
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
        end,
        Visible = function ()
            return true
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
        end,
        Visible = function ()
            return true
        end
    },
     
    {
        Sprite = "Online",
        Transform = {love.graphics.getWidth() - 55, 5, 50, 50},
        Callback = function ()
            onlineMode = not onlineMode
            sounds.Select:play()
            
            menu:RefreshLevels()      
        end,
        Visible = function ()
            return true
        end
    }
}

local font

function menu:RefreshLevels()
    levelList = {}

    if onlineMode then
        local _, body = https.request(string.format("http://localhost:%s/levels/", tostring(require("settings").PORT)), {method = "GET"})

        body = string.sub(body, 2, -2)
        for _, v in ipairs(str:split(body, ",")) do
            print(v)
            table.insert(levelList, string.sub(v, 2, -2))
        end
    else
        love.filesystem.setIdentity("goose-platformer")
    
        for _, v in ipairs(love.filesystem.getDirectoryItems("")) do
            if v:match("^.+(%..+)$") == ".goose" then
                table.insert(levelList, v)
            end
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
            if not onlineMode then
                love.graphics.printf(string.sub(levelList[currentLevel], 1, -7), 70, 120, love.graphics.getWidth() - 120)
            else
                love.graphics.printf(levelList[currentLevel], 70, 120, love.graphics.getWidth() - 120)
            end
            
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
            if b.Visible() then
                b.Callback()
            end
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
        if b.Visible() then
            if b.Sprite == "Online" then
                if onlineMode then
                    love.graphics.draw(sprites.Offline, b.Transform[1], b.Transform[2])
                else
                    love.graphics.draw(sprites.Online, b.Transform[1], b.Transform[2])
                end
            else
                love.graphics.draw(sprites[b.Sprite], b.Transform[1], b.Transform[2])
            end
            
        end
        
    end

    self:DrawLevelList()
end

return menu