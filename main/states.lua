-- Gameplay Variables
local foxDistance = 0
local nuclearPower = 1
local nuclearVisibility = nuclearPower
local pondBrightness = 0

local waitTime = 10
local timer = waitTime

local irradiating = false
local maxIrradiation = 255
local irradiationSpeed = 15      -- Constant
local coolOffSpeed = 30          -- Constant

local colorMaxBirghtness = 255

--====================================================================
-- Initialize the game
--====================================================================
-- Initialize everything
function initializeNuclearFrog(dt)
    debug = "init"
    foxDistance = 0
    nuclearPower = 1
    nuclearVisibility = nuclearPower
    pondBrightness = 255
    initFox()

    irradiating = false
    maxIrradiation = 255

    colorMaxBirghtness = 255
    colorValues = {}
    colorValues["red"] = 0/255
    colorValues["green"] = 1/255
    colorValues["blue"] = 0/255
    red = 0
    green = 0
    blue = 0
    alpha = 1

    gameState = startNuclearFrog
    waitTime = 10
    timer = waitTime

    return colorValues

end


--====================================================================
-- Start "screen"
--====================================================================
-- Beginning of the game. Just hold on this until player interracts
function startNuclearFrog(dt)
    debug = "start"
    -- Stay on this screen for a sec
    if timer > 0 then
        timer = timer - (30 * dt) 
    elseif timer == -1 then
        timer = waitTime
    else
        timer = -1
    end
    
    -- Check if we can start yet
    irradiating = checkIfIrradiating()
    if irradiating and timer <= 0 then
        gameState = updateGamePlay
    end

    -- Update Color values
    local colorValues = {}
    colorValues["red"] = foxDistance/colorMaxBirghtness
    colorValues["green"] = nuclearVisibility/colorMaxBirghtness
    colorValues["blue"] = pondBrightness/colorMaxBirghtness

    -- Return the brightness values in a format LOVE likes
    return colorValues
end

--====================================================================
-- Gameplay section
--====================================================================
-- Run through all game logic
function updateGamePlay(dt)
    debug = "update"
    -- Update the frog and pond's brightness
    irradiating = checkIfIrradiating()
    if irradiating and nuclearPower <= maxIrradiation then
        nuclearPower = nuclearPower + irradiationSpeed * dt
        nuclearVisibility = nuclearPower
        pondBrightness = 0
    elseif nuclearPower > 0 and nuclearPower < maxIrradiation then
        nuclearPower = nuclearPower - coolOffSpeed * dt
        nuclearVisibility = 0
        pondBrightness = nuclearPower
    end
    
    -- Update the fox's brightness
    foxDistance = updateFox(irradiating, nuclearPower)

    -- Check if the frog has fully irradiated
    if nuclearPower >= maxIrradiation then
        timer = -1
        gameState = winState
        nuclearVisibility = colorMaxBirghtness
    elseif nuclearPower <= 0 then
        timer = -1
        gameState = loseState
    end

    -- Update color values
    local colorValues = {}
    colorValues["red"] = foxDistance/colorMaxBirghtness
    colorValues["green"] = nuclearVisibility/colorMaxBirghtness
    colorValues["blue"] = pondBrightness/colorMaxBirghtness

    -- Return the brightness values in a format LOVE likes
    return colorValues
end


--====================================================================
-- Display score in binary
--====================================================================
-- Flashes the score in binary where G = 1 and B = 0
function displayScore(dt)
    -- Score will be some time divider and your overall radioactivity
    -- Something like R/T in seconds... but take the amount of time it takes to reach full radioactivity into account
    -- So maybe more like:  Radioactivity / (Time in ms - (Perfect Charge Time in ms + some give?))
end


--====================================================================
-- Display the win "screen"
--====================================================================
-- Win state
function winState(dt)
    debug = "win"
    -- We want to screen to be pure green
    foxDistance = 0
    nuclearVisibility = colorMaxBirghtness
    pondBrightness = 0

    -- Stay on this screen for a sec
    -- Keep G at max, pull R and B up from wherever they currently are
    -- Then drop R and B from max back to zero. 
    -- Display score
    if timer > 0 then
        timer = timer - (30 * dt) 
    elseif timer == -1 then
        timer = waitTime
    else
        timer = -1
    end
    
    -- Check if we can start yet
    irradiating = checkIfIrradiating()
    if irradiating and timer <= 0 then
        gameState = initializeNuclearFrog
    end 

    -- Update Color values
    local colorValues = {}
    colorValues["red"] = foxDistance/colorMaxBirghtness
    colorValues["green"] = nuclearVisibility/colorMaxBirghtness
    colorValues["blue"] = pondBrightness/colorMaxBirghtness

    -- Return the brightness values in a format LOVE likes
    return colorValues
end



--====================================================================
-- Display the lose "screen"
--====================================================================
-- Lose state
function loseState(dt)
    debug = "lose"
    -- We want to screen to be pure red
    foxDistance = colorMaxBirghtness
    nuclearVisibility = 0
    pondBrightness = 0

    -- Stay on this screen for a sec
    -- Pull everything up from current state
    -- Then drop G and B from max back to zero. 
    -- Display score
    if timer > 0 then
        timer = timer - (30 * dt) 
    elseif timer == -1 then
        timer = waitTime
    else
        timer = -1
    end
    
    -- Check if we can start yet
    irradiating = checkIfIrradiating()
    if irradiating and timer <= 0 then
        gameState = initializeNuclearFrog
    end

    -- Update Color values
    local colorValues = {}
    colorValues["red"] = foxDistance/colorMaxBirghtness
    colorValues["green"] = nuclearVisibility/colorMaxBirghtness
    colorValues["blue"] = pondBrightness/colorMaxBirghtness

    -- Return the brightness values in a format LOVE likes
    return colorValues
end