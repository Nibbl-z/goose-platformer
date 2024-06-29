local editor = {}

local map = {}

editor.enabled = false

local camDirections = {
    w = {0,-1}, s = {0,1}, a = {-1, 0}, d = {1,0}
}
editor.cameraX = -100
editor.cameraY = -400
editor.camSpeed = 500

local dcX = 0
local dcY = 0

local currentPlatform
local mapLoader = require("modules.mapLoader")
local collision = require("modules.collision")

local mode = "place"
local platformType = 1

local f

local sliding = false
local hue = 0.0
local saturation = 1.0
local brightness = 1.0

local movingMouse = false

editor.placeDelay = 0

local buttons = {
    {
        Sprite = "PlaceMode",
        Transform = {2, 2, 50, 50},
        IsEnabled = function ()
            if mode == "place" and platformType == 1 then return true else return false end
        end,
        Callback = function ()
            mode = "place"
            platformType = 1
        end
    },
    {
        Sprite = "LavaMode",
        Transform = {56, 2, 50, 50},
        IsEnabled = function ()
            if mode == "place" and platformType == 2 then return true else return false end
        end,
        Callback = function ()
            mode = "place"
            platformType = 2
        end
    },
    {
        Sprite = "CheckpointMode",
        Transform = {110, 2, 50, 50},
        IsEnabled = function ()
            if mode == "checkpoint" then return true else return false end
        end,
        Callback = function ()
            mode = "checkpoint"
        end
    },
    {
        Sprite = "FinishMode",
        Transform = {164, 2, 50, 50},
        IsEnabled = function ()
            if mode == "finish" then return true else return false end
        end,
        Callback = function ()
            mode = "finish"
        end
    },
    {
        Sprite = "MoveMode",
        Transform = {218, 2, 50, 50},
        IsEnabled = function ()
            if mode == "move" then return true else return false end
        end,
        Callback = function ()
            mode = "move"
        end
    },
    {
        Sprite = "ScaleMode",
        Transform = {272, 2, 50, 50},
        IsEnabled = function ()
            if mode == "scale" then return true else return false end
        end,
        Callback = function ()
            mode = "scale"
        end
    },
    {
        Sprite = "PaintMode",
        Transform = {326, 2, 50, 50},
        IsEnabled = function ()
            if mode == "paint" then return true else return false end
        end,
        Callback = function ()
            mode = "paint"
        end
    },
    {
        Sprite = "ColorPickMode",
        Transform = {380, 2, 50, 50},
        IsEnabled = function ()
            if mode == "colorpick" then return true else return false end
        end,
        Callback = function ()
            mode = "colorpick"
        end
    },
    {
        Sprite = "DeleteMode",
        Transform = {434, 2, 50, 50},
        IsEnabled = function ()
            if mode == "delete" then return true else return false end
        end,
        Callback = function ()
            mode = "delete"
        end
    },
    {
        Sprite = "Save",
        Transform = {488, 2, 50, 50},
        IsEnabled = function ()
            return false
        end,
        Callback = function ()
            
            f:open("w")
            local s, m = f:write(mapLoader:TableToGoose(map))
            print(s, m)
            f:close()

            love.window.showMessageBox("Editor", "Level saved!", "info", false)
        end
    }
}

local rgbaSliders = {
    {
        Sprite = "Hue",
        Transform = {10, 56, 200, 25},
        SliderPos = function ()
            return (10 + (hue * 200))
        end,
        Callback = function (percentage)
            hue = percentage
            if hue > 1.0 then
                hue = 1.0
            end
            if hue < 0.0 then
                hue = 0.0
            end
        end
    },
    
    {
        Sprite = "Saturation",
        Transform = {10, 83, 200, 25},
        SliderPos = function ()
            return (10 + (saturation * 200))
        end,
        Callback = function (percentage)
            saturation = percentage
            if saturation > 1.0 then
                saturation = 1.0
            end
            if saturation < 0.0 then
                saturation = 0.0
            end
        end
    },

    {
        Sprite = "Brightness",
        Transform = {10, 110, 200, 25},
        SliderPos = function ()
            return (10 + (brightness * 200))
        end,
        Callback = function (percentage)
            brightness = percentage
            if brightness > 1.0 then
                brightness = 1.0
            end
            if brightness < 0.0 then
                brightness = 0.0
            end
        end
    }
}


local sprites = {
    SpawnPoint = "player.png",
    PlaceMode = "place_mode.png",
    CheckpointMode = "checkpointmode.png",
    FinishMode = "finishmode.png",
    MoveMode = "move_mode.png",
    ScaleMode = "scale_mode.png",
    DeleteMode = "delete_mode.png",
    PaintMode = "paint_mode.png",
    ColorPickMode = "colorpicker_mode.png",
    LavaMode = "lava_mode.png",
    Lava = "lava.png",
    Save = "save.png",
    Hue = "hue.png",
    Saturation = "saturation.png",
    Brightness = "brightness.png",
    Slider = "slider.png",
    Checkpoint = "checkpoint.png",
    Finish = "finish.png",
}

local sounds = {
    Select = {"select.wav", "static"},
    Placing = {"placing.wav", "static"},
    FinishPlace = {"finishPlace.wav", "static"},
    Delete = {"delete.wav", "static"},
    Paint = {"paint.wav", "static"},
    ColorPick = {"colorpick.wav", "static"}
}

function HSVtoRGB(h, s, v)
    if s <= 0 then return v,v,v end
    h = h*6
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return r+m, g+m, b+m
end

function RGBtoHSV(r,g,b)
    local M, m = math.max( r, g, b ), math.min( r, g, b )
	local C = M - m
	local K = 1.0/(6.0 * C)
	local h = 0.0
	if C ~= 0.0 then
		if M == r then     h = ((g - b) * K) % 1.0
		elseif M == g then h = (b - r) * K + 1.0/3.0
		else               h = (r - g) * K + 2.0/3.0
		end
	end
	return h, M == 0.0 and 0.0 or C / M, M
end

function editor:Init()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
    for name, sound in pairs(sounds) do
        sounds[name] = love.audio.newSource("/audio/"..sound[1], sound[2])
    end
end

function editor:Load(filename)
    self.placeDelay = love.timer.getTime() + 0.5
    self.cameraX = -100
    self.cameraY = -400
    currentPlatform = nil
    f = love.filesystem.newFile(filename, "r")
    local mapString = f:read("string")
    map = mapLoader:GooseToTable(mapString)
    f:close()
end

function editor:mousepressed(x, y, button)
    if self.placeDelay > love.timer.getTime() then return end

    if self.enabled == false then return end
    if button ~= 1 then return end
    
    for _, b in ipairs(buttons) do
        if collision:CheckCollision(x, y, 1, 1, b.Transform[1], b.Transform[2], b.Transform[3], b.Transform[4]) then
            b.Callback()
            sounds.Select:play()
            return
        end
    end

    for _, s in ipairs(rgbaSliders) do
        if collision:CheckCollision(x, y, 1, 1, s.Transform[1], s.Transform[2], s.Transform[3], s.Transform[4]) then
            local sliderPercent = (x - s.Transform[1]) / s.Transform[3]
            s.Callback(sliderPercent)
            sliding = true

            return
        end
    end
    

    if mode == "place" or mode == "scale" or mode == "move" then
        sounds.Placing:setLooping(true)
        sounds.Placing:play()
    end
    
    if mode == "place" then
        

        print(x, y, button)
        currentPlatform = {}
        currentPlatform.X = x + editor.cameraX
        currentPlatform.Y = y + editor.cameraY
        currentPlatform.W = 1
        currentPlatform.H = 1
        currentPlatform.T = platformType

        if platformType == 1 then
            local r,g,b = HSVtoRGB(hue, saturation, brightness)

            currentPlatform.R = r
            currentPlatform.G = g
            currentPlatform.B = b
        else
            currentPlatform.R = 1 
            currentPlatform.G = 1
            currentPlatform.B = 1
        end
    elseif mode == "delete" then
        for i, v in ipairs(map) do
            if collision:CheckCollision(x + editor.cameraX, y + editor.cameraY, 5, 5, v.X, v.Y, v.W, v.H) then
                table.remove(map, i)
                sounds.Delete:play()
                break
            end
        end
    elseif mode == "paint" then
        for i, v in ipairs(map) do
            if collision:CheckCollision(x + editor.cameraX, y + editor.cameraY, 5, 5, v.X, v.Y, v.W, v.H) then
                local r, g, b = HSVtoRGB(hue, saturation, brightness)
                
                v.R = r
                v.G = g
                v.B = b
                sounds.Paint:play()
                break
            end
        end
    elseif mode == "move" or mode == "scale" then
        for i, v in ipairs(map) do
            if collision:CheckCollision(x + editor.cameraX, y + editor.cameraY, 5, 5, v.X, v.Y, v.W, v.H) then
                currentPlatform = v
                table.remove(map, i)
                break
            end
        end
    elseif mode == "colorpick" then
        for i, v in ipairs(map) do
            if collision:CheckCollision(x + editor.cameraX, y + editor.cameraY, 5, 5, v.X, v.Y, v.W, v.H) then
                local h,s,v = RGBtoHSV(v.R, v.G, v.B)
                print(h,s,v)
                hue = h
                saturation = s
                brightness = v

                sounds.ColorPick:play()

                break
            end
        end
    elseif mode == "checkpoint" or mode == "finish" then
        currentPlatform = {}
        currentPlatform.X = x + editor.cameraX
        currentPlatform.Y = y + editor.cameraY
        
        if mode == "checkpoint" then 
            currentPlatform.T = 3
            currentPlatform.W = 25
            currentPlatform.H = 50
        elseif mode == "finish" then 
            currentPlatform.T = 4
            currentPlatform.W = 50
            currentPlatform.H = 100
        end

        table.insert(map, currentPlatform)

        currentPlatform = nil
    end
end

function love.mousemoved(x, y, dx, dy)
    if editor.placeDelay > love.timer.getTime() then return end
    if editor.enabled == false then return end
    
    movingMouse = true

    for _, s in ipairs(rgbaSliders) do
        if collision:CheckCollision(x, y, 1, 1, s.Transform[1], s.Transform[2], s.Transform[3], s.Transform[4]) and sliding then
            local sliderPercent = (x - s.Transform[1]) / s.Transform[3]
            s.Callback(sliderPercent)
            
            return
        end
    end

    if currentPlatform == nil then return end
    
    if mode == "place" or mode == "move" or mode == "scale" then
        if sounds.Placing:isPlaying() == false then
            sounds.Placing:play()
        end
    end

    if mode == "move" then
        currentPlatform.X = currentPlatform.X + dx + dcX
        currentPlatform.Y = currentPlatform.Y + dy + dcY

        return
    end

    print(x, y)
    
    currentPlatform.W = x + editor.cameraX - currentPlatform.X 
    currentPlatform.H = y + editor.cameraY - currentPlatform.Y
end

function love.mousereleased(x, y, button)
    if editor.placeDelay > love.timer.getTime() then return end
    if editor.enabled == false then return end
    if button ~= 1 then return end
    
    sliding = false
    
    
    if currentPlatform == nil then return end
    print(x, y, button)
    sounds.Placing:stop()
    sounds.FinishPlace:play()
    if mode == "place" or mode == "scale" then
        
        if currentPlatform.W < 0 then
            currentPlatform.W = -(x + editor.cameraX - currentPlatform.X)
            currentPlatform.X = currentPlatform.X - currentPlatform.W
        else
            currentPlatform.W = x + editor.cameraX - currentPlatform.X
        end
    
        if currentPlatform.H < 0 then
            currentPlatform.H = -(y + editor.cameraY - currentPlatform.Y)
            currentPlatform.Y = currentPlatform.Y - currentPlatform.H
        else
            currentPlatform.H = y + editor.cameraY - currentPlatform.Y
        end
    end
    
    table.insert(map, currentPlatform)
    
    currentPlatform = nil
    
    print(mapLoader:TableToGoose(map))
end

function editor:Update(dt)  
   
    dcX = 0
    dcY = 0

    for key, mult in pairs(camDirections) do
        if love.keyboard.isDown(key) then
            self.cameraX = self.cameraX + mult[1] * dt * self.camSpeed
            self.cameraY = self.cameraY + mult[2] * dt * self.camSpeed

            if mode == "move" and currentPlatform ~= nil then
                currentPlatform.X = currentPlatform.X + mult[1] * dt * self.camSpeed
                currentPlatform.Y = currentPlatform.Y + mult[2] * dt * self.camSpeed
            end
        end
    end
    
    if not movingMouse then
        sounds.Placing:stop()
    end
    
    movingMouse = false
end

function editor:Draw()
    love.graphics.setBackgroundColor(1,1,1,1)
    
    for _, p in ipairs(map) do
        if p.T == 1 then
            love.graphics.setColor(p.R, p.G, p.B, 1)
            love.graphics.rectangle("fill", p.X - self.cameraX, p.Y - self.cameraY, p.W, p.H, 10, 10)
        elseif p.T == 2 then
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(sprites.Lava, p.X - self.cameraX, p.Y - self.cameraY, 0, p.W/ 100, p.H / 100)
        elseif p.T == 3 then
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(sprites.Checkpoint, p.X - self.cameraX, p.Y - self.cameraY, 0, 1, 1, 12.5, 25)
        elseif p.T == 4 then
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(sprites.Finish, p.X - self.cameraX, p.Y - self.cameraY, 0, 1, 1, 0, 0)
        end
        
    end
    if currentPlatform ~= nil then
        if currentPlatform.T == 1 then
            love.graphics.setColor(currentPlatform.R, currentPlatform.G, currentPlatform.B, 0.5)
            love.graphics.rectangle("fill", currentPlatform.X - self.cameraX, currentPlatform.Y - self.cameraY, currentPlatform.W, currentPlatform.H)
        elseif currentPlatform.T == 2 then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(sprites.Lava, currentPlatform.X - self.cameraX, currentPlatform.Y - self.cameraY, 0, currentPlatform.W / 100, currentPlatform.H / 100)
        elseif currentPlatform.T == 3 then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(sprites.Checkpoint, currentPlatform.X - self.cameraX, currentPlatform.Y - self.cameraY,0, 1, 1, 12.5, 25)
        elseif currentPlatform.T == 4 then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(sprites.Finish, currentPlatform.X - self.cameraX, currentPlatform.Y - self.cameraY,0, 1, 1, 0, 0)
        end
    end
    
    love.graphics.setColor(1,1,1, 0.5)
    love.graphics.draw(sprites.SpawnPoint, 200 - self.cameraX, 0 - self.cameraY)
    
    for _, b in ipairs(buttons) do
        if b.IsEnabled() then
            love.graphics.setColor(1,1,1,0.5) 
        else
            love.graphics.setColor(1,1,1,1)
        end
        
        love.graphics.draw(sprites[b.Sprite], b.Transform[1], b.Transform[2])
    end
    
    if (mode == "place" and platformType == 1) or mode == "paint" or mode == "colorpick" then
        for _, s in ipairs(rgbaSliders) do
            if s.Sprite == "Saturation" then
                love.graphics.setColor(1,1,1,1)
                love.graphics.rectangle("fill", s.Transform[1], s.Transform[2], s.Transform[3], s.Transform[4])
    
                local r,g,b = HSVtoRGB(hue, 1, brightness)
                love.graphics.setColor(r,g,b,1)
            elseif s.Sprite == "Brightness" then
                local r,g,b = HSVtoRGB(hue, saturation, 1)
                love.graphics.setColor(r,g,b,1)
            end     
    
            love.graphics.draw(sprites[s.Sprite], s.Transform[1], s.Transform[2], 0)
    
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(sprites.Slider, s.SliderPos(), s.Transform[2], 0, 1, 1, 5)
        end

        local r,g,b = HSVtoRGB(hue, saturation, brightness)
        love.graphics.setColor(r,g,b,1)
        love.graphics.rectangle("fill", 10, 200, 20, 20)
    end
    
    
    
end

function love.filedropped(file)
    file:open("r")
    f = file
    local mapString = file:read("string")
    map = mapLoader:GooseToTable(mapString)
    print(f)
    f:close()
end

return editor