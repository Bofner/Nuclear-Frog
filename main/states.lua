-- Gameplay Variables
local foxDistance = 0
local nuclearPower = 1
local nuclearVisibility = nuclearPower
local pondBrightness = 0
local blackTime = true

local waitTime = 10
local timer = waitTime
local scoreDisplayed = false

local playTime = 0
local score = 0
local currentDisplayDigit = 1

local irradiating = false
local maxIrradiation = 255       -- Constant
local irradiationSpeed = 15      -- Constant
local coolOffSpeed = 30          -- Constant
local pondConstant = 65

local colorMaxBrightness = 255

--====================================================================
-- Initialize the game
--====================================================================
-- Initialize everything
function initializeNuclearFrog(dt)
    
    -- Init Frog and pond
    nuclearPower = 1
    nuclearVisibility = nuclearPower
    pondBrightness = colorMaxBrightness
    irradiating = false

    -- Init Colors
    ColorValues = {}
    ColorValues["red"] = 0/colorMaxBrightness
    ColorValues["green"] = 1/colorMaxBrightness
    ColorValues["blue"] = 0/colorMaxBrightness
    Red = 0
    Green = 0
    Blue = 0
    Alpha = 1

    -- Start game
    GameState = startNuclearFrog
    waitTime = 10
    timer = waitTime
    playTime = 0
    score = 0
    scoreDisplayed = false
    currentDisplayDigit = 1
    blackTime = true

     -- Init Fox
    initFox()
    foxDistance = 0

    -- Debug
    debug = "init"
    debugScore = score
    debugTime = playTime
    binaryScore = 0
    debugDigit = 0
    Nuclear = nuclearPower

    return ColorValues

end


--====================================================================
-- Start "screen"
--====================================================================
-- Beginning of the game. Just hold on this until player interracts
function startNuclearFrog(dt)
    debug = "Start"
    nuclearPower = 1

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
        GameState = updateGamePlay
    end

    -- Update Color values
    local colorValues = {}
    colorValues["red"] = foxDistance/colorMaxBrightness
    colorValues["green"] = nuclearVisibility/colorMaxBrightness
    colorValues["blue"] = pondBrightness/colorMaxBrightness

    -- Return the brightness values in a format LOVE likes
    return colorValues
end

--====================================================================
-- Gameplay section
--====================================================================
-- Run through all game logic
function updateGamePlay(dt)
    -- Debug
    Nuclear = nuclearPower

    -- Time for the score
    playTime = playTime + dt
    debugTime = playTime
    score = ((nuclearPower) - (playTime))  + 20
    debugScore = score
    
    -- Update the frog and pond's brightness
    irradiating = checkIfIrradiating()
    if irradiating and nuclearPower <= maxIrradiation then
        nuclearPower = nuclearPower + irradiationSpeed * dt
        nuclearVisibility = nuclearPower
        pondBrightness = pondConstant
    elseif nuclearPower > 0 and nuclearPower < maxIrradiation then
        nuclearPower = nuclearPower - coolOffSpeed * dt
        nuclearVisibility = 0
        pondBrightness = nuclearPower
    end
    
    -- Update the fox's brightness
    foxDistance = updateFox(irradiating, nuclearPower, dt)

    -- Check if the frog has fully irradiated
    if nuclearPower >= maxIrradiation then
        GameState = winState
        blackTime = true            -- Give the player a moment before the score starts flashing
        timer = 40
        nuclearVisibility = colorMaxBrightness
        calculateScore()
    elseif nuclearPower <= 0 then
        GameState = loseState
        blackTime = true            -- Give the player a moment before the score starts flashing
        timer = 40
        score = math.floor(score - 30)
        calculateScore()
    end

        -- Check if the frog was eaten by the fox
    if irradiating and foxDistance >= colorMaxBrightness - 1 then
        GameState = loseState
        blackTime = true            -- Give the player a moment before the score starts flashing
        timer = 40
        nuclearVisibility = 0
        score = math.floor(score - 30)
        calculateScore()
        
    end

    -- Update color values
    local colorValues = {}
    colorValues["red"] = foxDistance/colorMaxBrightness
    colorValues["green"] = nuclearVisibility/colorMaxBrightness
    colorValues["blue"] = pondBrightness/colorMaxBrightness

    -- Return the brightness values in a format LOVE likes
    return colorValues
end

--====================================================================
-- Pre-score blanking
--====================================================================
-- Holds the screen black for a moment before displaying the score
function preScoreBlanking(dt, digit)

end

--====================================================================
-- Display score in binary
--====================================================================
-- Flashes the score in binary where G = 1 and B = 0
function displayScore(dt, digit)
    -- Score will be some time divider and your overall radioactivity
    -- Something like R/T in seconds... but take the amount of time it takes to reach full radioactivity into account
    -- So maybe more like:  Radioactivity / (Time in ms - (Perfect Charge Time in ms + some give?))
    if blackTime then
        nuclearVisibility = 0
        pondBrightness = 0
    elseif digit == "1" then
        nuclearVisibility = colorMaxBrightness
        pondBrightness = 0
    else
        nuclearVisibility = 0
        pondBrightness = colorMaxBrightness
    end
end

function screenTimer(dt)
    -- Stay on this screen for a sec
    -- Pull everything up from current state
    -- Then drop G and B from max back to zero. 
    -- Display score
    if timer > 0 then
        timer = timer - (20 * dt) 
    elseif timer <= 0 and currentDisplayDigit < 9 and blackTime then
        timer = waitTime
        blackTime = false
    elseif timer <= 0 and currentDisplayDigit < 9 and blackTime == false then
        timer = waitTime
        blackTime = true
        currentDisplayDigit = currentDisplayDigit + 1
    else
        timer = -1
    end

    -- The digit we want to be showing
    if currentDisplayDigit < 9 then
        debugDigit = string.sub(binaryScore, currentDisplayDigit, currentDisplayDigit)
        displayScore(dt, string.sub(binaryScore, currentDisplayDigit, currentDisplayDigit))
    else 
        scoreDisplayed = true
    end
end

function calculateScore()
    -- Convert Score from decimal to binary so we can flash it to the player
    score = math.ceil(score)
        if score < 0 then
            score = 0
        elseif score > 255 then
            score = 255
        end
        debugScore = score
        local binValue = score % 2
        local remainingValue = score
        if binValue == 1 then
            remainingValue = math.floor((remainingValue - 1) / 2)
        else
           remainingValue = math.floor(remainingValue / 2)
        end
        binaryScore = string.format("%d",binValue)

        for i = 1, 7, 1 do 
            binValue = remainingValue % 2
            if binValue == 1 then
                remainingValue = (remainingValue - 1) / 2
            else
                remainingValue = math.floor(remainingValue / 2)
            end
            binaryScore = string.format("%d",binValue) .. binaryScore
        end
end


--====================================================================
-- Display the win "screen"
--====================================================================
-- Win state
function winState(dt)

    debug = "Winner"
    
    -- We want to screen to start off black before showing the score
    foxDistance = 0
    nuclearVisibility = colorMaxBrightness
    pondBrightness = colorMaxBrightness

    screenTimer(dt)    
    
    -- Check if we can start yet
    irradiating = checkIfIrradiating()
    if irradiating and scoreDisplayed then
        GameState = initializeNuclearFrog
    end  

    -- Update Color values
    local colorValues = {}
    colorValues["red"] = foxDistance/colorMaxBrightness
    colorValues["green"] = nuclearVisibility/colorMaxBrightness
    colorValues["blue"] = pondBrightness/colorMaxBrightness

    -- Return the brightness values in a format LOVE likes
    return colorValues
end



--====================================================================
-- Display the lose "screen"
--====================================================================
-- Lose state
function loseState(dt)
    debug = "Loser"
    
    -- We want to screen to start off black, then be pure red
    foxDistance = colorMaxBrightness
    nuclearVisibility = 0
    pondBrightness = 0

    screenTimer(dt)    
    
    -- Check if we can start yet
    irradiating = checkIfIrradiating()
    if irradiating and scoreDisplayed then
        GameState = initializeNuclearFrog
    end  

    -- Update Color values
    local colorValues = {}
    colorValues["red"] = foxDistance/colorMaxBrightness
    colorValues["green"] = nuclearVisibility/colorMaxBrightness
    colorValues["blue"] = pondBrightness/colorMaxBrightness

    -- Return the brightness values in a format LOVE likes
    return colorValues
end
