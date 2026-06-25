-- Our fox object
local foxEntity = {}
foxEntity["distance"] = 0
foxEntity["state"] = sleeping
foxEntity["subState"] = sleeping
foxEntity["timer"] = 0
foxEntity["huntTimer"] = 0
foxEntity["stalkTimer"] = 0
foxEntity["lungeTimer"] = 0
foxEntity["pounceTimer"] = 0

-- All possible states for the fox states
local sleepyFox = 31
local hungryFox = 127
local aggressiveFox = 191
local desperateFox = 255 

-- All timers for the hunt state
local huntTimes = {}
huntTimes["sleepy"] = 10

-- All substates for the fox
require("entities.fox.huntingSubstates")


-- Inverse percentage changes for actions during different states
local sleepyHunt = 0.75

local hungryHunt = 0.5
local hungryStalk = 0.65

local aggressiveHunt = 0.125
local aggressiveStalk = 0.5
local aggressiveLunge = 0.85

local desperateLunge = 0.10
local desperateHunt = 0.85


--====================================================================
-- Update Fox
--====================================================================
function updateFox(irradiating, nuclearPower)
    -- Run a random check based on Nuclear Frog's irradiation level to determine next action
        local foxAction = math.random(1)

    -- Determine how agressive the fox will be based off of the frog's radioactivity
    if foxEntity["state"] == sleeping then

        -- The fox is still sleepy
        if nuclearPower < sleepyFox and foxAction > sleepyHunt then
            -- The fox hunts
            foxEntity["state"] = hunting
            foxEntity["subState"] = huntSubstate0
            foxEntity["huntTimer"] = huntTimes["sleepy"]
        
        -- The fox is hungry now
        elseif nuclearPower < hungryFox then
            -- The fox stalks the frog
            if foxAction > hungryStalk then
            -- The fox hunts the frog
            elseif foxAction > hungryHunt then

            end

        else 
            -- Will return a state for the fox
            foxEntity["state"] = sleeping
            foxEntity["subState"] = sleeping

        end

    else 
        -- Will return a state for the fox
        foxEntity["state"] = sleeping
        foxEntity["subState"] = sleeping
    end
    
    local goFox = foxEntity["state"]
    foxEntity["distance"] = goFox()

    return foxEntity["distance"]
end


--====================================================================
-- Sleeping state
--====================================================================
-- Fox isn't doing anything, red subpixel is off
function sleeping()
    return 0
end


--====================================================================
-- Hunting state
--====================================================================
-- Fox is going for a methodical slow attack
-- Blips of light, like foot steps. 
-- Dim -> Off
-- Brighter -> Dim -> Off
-- Bright -> Duller -> Dim -> Off
-- Perhaps 1...2...1..2..3.4.5->POUNCE 
function hunting()

    -- Determine current brightness
    local huntingFox = foxEntity["subState"]
    local huntingBrightness = huntingFox()
    debug = "hunting"

    -- Set state to pounce

    return huntingBrightness
end


--====================================================================
-- Stalking State
--====================================================================
-- Fox is waiting for its chance to pounce
-- Dependent on Nuclear Frog. Fox will slowly build up while the Nuclear Frog is Irradiating
-- It'll be a slow build up, but faster than Nuclear Frog. Once it hits about 75% brightness the pounce begins
function stalking(irradiating)
    -- Check current brightness, and Nuclear Forg's Irradiation to determine next move
    return 0
end


--====================================================================
-- Lunging State
--====================================================================
-- Fox is going for a direct attack
-- Harsh steps 1..2.3.4.5.6.7->POUNCE
function lunging()
    -- Check current brightness
    return 0
end


--====================================================================
-- Pounce state
--====================================================================
-- This is always the end phase of the fox's attack
-- It's brightness will increase at a constant speed from maybe 75%-85%
function pounce()
    return 0
end


--====================================================================
-- Initialize the fox
--====================================================================
function initFox()
    foxEntity = {}
    foxEntity["distance"] = 0
    foxEntity["state"] = sleeping
    foxEntity["subState"] = sleeping
    foxEntity["timer"] = 0
    foxEntity["huntTimer"] = 0
    foxEntity["stalkTimer"] = 0
    foxEntity["lungeTimer"] = 0
    foxEntity["pounceTimer"] = 0
end