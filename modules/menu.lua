local menu = {}

local sprites = {
    Logo = "logo.png",
    Play = "play.png",
    Editor = "editor.png"
}

menu.enabled = true

local button = {
    {
        Sprite = "Play",
        Transform = {10, 110, 300, 225},
        Callback = function ()
            print("gup")
        end
    },
    
    {
        Sprite = "Editor",
        Transform = {10, 340, 300, 225},
        Callback = function ()
            print("gup")
        end
    }
}

function menu:Load()
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
end

function menu:Draw()
    love.graphics.setBackgroundColor(1,1,1,1)
    love.graphics.draw(sprites.Logo, 0, 0)
    
    for _, b in ipairs(button) do
        love.graphics.draw(sprites[b.Sprite], b.Transform[1], b.Transform[2])
    end
end

return menu