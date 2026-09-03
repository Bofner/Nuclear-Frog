-- Screen Variables
local width = 256
local height = 192

-- Entity Files
require("entities.nuclearFrog.nuclearFrog")
require("entities.fox.fox")

-- Game State files
require("states")

-- Game State
GameState = initializeNuclearFrog
debug = "init"
debugScore = 0
debugTime = 0
debugBinScore = 0
debugDigit = 0
Nuclear = 0

-- Pixel Location
local gameX = width/2
local gameY = height/2


-- Color Variables
ColorValues = {}
ColorValues["red"] = 0/255
ColorValues["green"] = 1/255
ColorValues["blue"] = 0/255
local red = 0
local green = 0
local blue = 0
local alpha = 1

-- Initialize everything we need
function love.load()
love.window.setMode( width, height )
love.window.setTitle( "" )
local ico = love.image.newImageData("ico/green.png")
love.window.setIcon(ico)
love.graphics.setPointSize(1)

end

function love.update(dt)

    -- Update the RGB based off of the current GameState
    ColorValues = GameState(dt)         

    -- Update the RGB values based on state
    red = ColorValues["red"]
    green = ColorValues["green"]
    blue = ColorValues["blue"]

end

function love.draw()
    -- Draw the entire game
    love.graphics.setColor( red, green, blue, alpha )
    love.graphics.points(gameX,gameY)

--[[     love.graphics.setColor( 0, 1, 0, alpha )
    love.graphics.print(ColorValues["green"], 30, 40)
    love.graphics.print("Radiation: " .. Nuclear .. "\n Play Time:" .. debugTime .. "\n Score: " .. debugScore .. "\n Binary Score: " .. debugBinScore .. "\n DisplayDigit : " .. debugDigit, 100, 160)
    love.graphics.setColor( 0, 0, 1, alpha )
    love.graphics.print(ColorValues["blue"], 30, 80)
    love.graphics.setColor( 1, 1, 1, alpha )
    love.graphics.print(debug, 30, 120) ]]
end


