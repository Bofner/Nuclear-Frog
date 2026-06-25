-- Screen Variables
local size = 256

-- Entity Files
require("entities.nuclearFrog.nuclearFrog")
require("entities.fox.fox")

-- Game State files
require("states")

-- Game State
gameState = initializeNuclearFrog
debug = "init"


-- Color Variables
colorValues = {}
colorValues["red"] = 0/255
colorValues["green"] = 1/255
colorValues["blue"] = 0/255
local red = 0
local green = 0
local blue = 0
local alpha = 1

-- Initialize everything we need
function love.load()
love.window.setMode( size, size )
love.window.setTitle( "" )
ico = love.image.newImageData("ico/green.png")
love.window.setIcon(ico)
love.graphics.setPointSize( 20 )

end

function love.update(dt)

    -- Update the RGB based off of the current gameState
    colorValues = gameState(dt)         

    -- Update the RGB values based on state
    red = colorValues["red"]
    green = colorValues["green"]
    blue = colorValues["blue"]

end

function love.draw()
    -- Draw the entire game
    love.graphics.setColor( red, green, blue, alpha )
    love.graphics.points(size/2,2)

    love.graphics.setColor( 0, 1, 0, alpha )
    love.graphics.print(colorValues["green"], 30, 40)
    love.graphics.setColor( 0, 0, 1, alpha )
    love.graphics.print(colorValues["blue"], 30, 80)
    love.graphics.setColor( 1, 1, 1, alpha )
    love.graphics.print(debug, 30, 120)
end