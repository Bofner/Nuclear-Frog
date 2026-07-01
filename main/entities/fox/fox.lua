-- Our fox object
local foxEntity = {}
foxEntity["distance"] = 0
foxEntity["state"] = hunting
foxEntity["subState"] = sleeping
foxEntity["timer"] = 0
foxEntity["huntStepBrightness"] = 0
foxEntity["huntTimer"] = 0
foxEntity["stalkBrightness"] = 0
foxEntity["stalkTimer"] = 0
foxEntity["lungeTimer"] = 0
foxEntity["pounceTimer"] = 0

-- All possible states for the fox states
local sleepyFox = 31
local hungryFox = 127
local aggressiveFox = 191
local desperateFox = 255 

-- Fox constants
local pounceBrightnessThreshold = 255*0.5
local pounceTime = 100
local huntTime = 200
local biteBrightness = 255
local foxWakeUpTimer = 2
local foxHuntStepSize = 45
local foxStalkSpeed = 35

-- All timers for the hunt state
local huntTimes = {}
huntTimes["sleepy"] = 10

-- All timers for the hunt state
local lungeTime = 0.25

-- All substates for the fox
require("entities.fox.huntingSubstates")
require("entities.fox.lungingSubstates")


-- Inverse percentage changes for actions during different states
local sleepyHunt = 75

local hungryHunt = 5
local hungryStalk = 50

local aggressiveHunt = 12.5
local aggressiveLunge = 50
local aggressiveStalk = 85

local desperateLunge = 5
local desperateHunt = 85

-- Debug
local currentFoxAction = "Sleeping"


--====================================================================
-- Update Fox
--====================================================================
function updateFox(irradiating, nuclearPower, dt)
    -- Determine if we should check if the fox will do anything
    local goFox = foxEntity["state"]
    foxEntity["timer"] = foxEntity["timer"] - (1*dt)
    if foxEntity["timer"] >= 0 then
        foxEntity["distance"] = goFox(dt, irradiating)
        return foxEntity["distance"]
    end
    
    -- Reset timer
    foxEntity["timer"] = foxWakeUpTimer

    -- Determine how agressive the fox will be based off of the frog's radioactivity
    if foxEntity["state"] == sleeping then
        -- Run a random check based on Nuclear Frog's irradiation level to determine next action
        local foxAction = math.random(0, 100)
        -- The fox is still sleepy
        if nuclearPower < sleepyFox then
            if foxAction > sleepyHunt then
                -- The fox hunts
                foxEntity["state"] = hunting               
                foxEntity["huntTimer"]  = 0
                foxEntity["huntStepBrightness"] = 0
                currentFoxAction = "Hunting"
            else
                -- Will return a state for the fox
                foxEntity["state"] = sleeping
                foxEntity["distance"] = 0
                currentFoxAction = "Sleeping"
            end
        
        -- The fox is hungry now
        elseif nuclearPower < hungryFox then

            -- The fox stalks the frog
            if foxAction > hungryStalk then
               foxEntity["state"] = stalking 
               foxEntity["stalkBrightness"] = 0
               foxEntity["stalkTimer"] = 0
                currentFoxAction = "Stalking"
            -- The fox hunts the frog
            elseif foxAction > hungryHunt then
                foxEntity["state"] = hunting               
                foxEntity["huntTimer"]  = 0
                foxEntity["huntStepBrightness"] = 0
                currentFoxAction = "Hunting"
            end

        -- The fox is aggressive now
        elseif nuclearPower < aggressiveFox then

            -- The fox stalks the frog
            if foxAction > aggressiveStalk then
                foxEntity["state"] = stalking  
                foxEntity["stalkBrightness"] = 0
                foxEntity["stalkTimer"] = 0
                currentFoxAction = "Stalking"
            -- The fox hunts the frog
            elseif foxAction > aggressiveHunt then
                -- The fox hunts
                foxEntity["state"] = hunting               
                foxEntity["huntTimer"]  = 0
                foxEntity["huntStepBrightness"] = 0
                currentFoxAction = "Hunting"

            -- The fox lunges at the frog
            elseif foxAction > aggressiveLunge then
                foxEntity["state"] = lunging          
                foxEntity["subState"] = lungeSubstate0        
                foxEntity["lungeTimer"]  = 0
            end


        -- The fox is desperate now
        elseif nuclearPower < desperateFox then
            -- The fox hunts the frog
            if foxAction > desperateHunt then
                -- The fox hunts
                foxEntity["state"] = hunting               
                foxEntity["huntTimer"]  = 0
                foxEntity["huntStepBrightness"] = 0
                currentFoxAction = "Hunting"

            -- The fox lunges
            elseif foxAction > desperateLunge then
                foxEntity["state"] = lunging       
                foxEntity["subState"] = lungeSubstate0        
                foxEntity["lungeTimer"]  = 0
            end

        else 
            -- Will return a state for the fox
            foxEntity["state"] = sleeping
            foxEntity["distance"] = 0
            currentFoxAction = "Sleeping"

        end
    
    end
    
    foxEntity["distance"] = goFox(dt, irradiating)

    debug = "Fox Brightness: " .. foxEntity["distance"] .. "\n Current Action: " .. currentFoxAction

    return foxEntity["distance"]
end


--====================================================================
-- Sleeping state
--====================================================================
-- Fox isn't doing anything, red subpixel is off
function sleeping(dt)

    foxEntity["distance"] = 0
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
function hunting(dt)

    -- Check if timer is at 0
    if foxEntity["huntTimer"] <= 0 then
        foxEntity["huntStepBrightness"] = foxEntity["huntStepBrightness"] + foxHuntStepSize
        foxEntity["huntTimer"] = foxEntity["huntStepBrightness"]
        if foxEntity["huntStepBrightness"] > pounceBrightnessThreshold then
            -- If 0, increase foxEntity["huntStepBrightness"] value and reset timer
            -- If we are at pounceTime, then change state
            foxEntity["state"] = pounce
            return pounceBrightnessThreshold
        end
    end
    
    -- Determine current brightness
    local huntingBrightness = fadeFoxStep(dt, foxEntity["huntTimer"])

    foxEntity["huntTimer"] = huntingBrightness

    return huntingBrightness
end


--====================================================================
-- Stalking State
--====================================================================
-- Fox is waiting for its chance to pounce
-- Dependent on Nuclear Frog. Fox will slowly build up while the Nuclear Frog is Irradiating
-- It'll be a slow build up, but faster than Nuclear Frog. Once it hits about 75% brightness the pounce begins
function stalking(dt, irradiating)

    local stalkBrightness = foxEntity["distance"]
    -- Check current brightness, and Nuclear Forg's Irradiation to determine next move
    if irradiating then
        stalkBrightness = fadeFoxStalk(dt, stalkBrightness)
    end
    
    if stalkBrightness >= pounceBrightnessThreshold then
        foxEntity["state"] = pounce
        return pounceBrightnessThreshold
    end


    return stalkBrightness
end


--====================================================================
-- Lunging State
--====================================================================
-- Fox is going for a direct attack
-- Harsh steps 1..2.3.4.5.6.7->POUNCE
function lunging(dt)
    
    currentFoxAction = "Lunging"

    -- Determine current brightness
    local lungingBrightness = 255
    
    -- Run our timer
    foxEntity["lungeTimer"] = foxEntity["lungeTimer"] - (1 * dt)
    -- If the timer resets, then we want to update the brightness
    if foxEntity["lungeTimer"] <= 0 then
        local lungingFox = foxEntity["subState"]
        lungingBrightness = lungingFox(foxEntity["distance"])
        foxEntity["lungeTimer"] = lungeTime
    -- If we reach the time to pounce, then do the pounce
    elseif foxEntity["distance"] >= pounceBrightnessThreshold then
        foxEntity["state"] = pounce
        lungingBrightness = foxEntity["distance"]
        return pounceBrightnessThreshold
    else
        lungingBrightness = foxEntity["distance"]
    end

    foxEntity["distance"] = lungingBrightness
    

    return lungingBrightness
end


--====================================================================
-- Pounce state
--====================================================================
-- This is always the end phase of the fox's attack
-- It's brightness will increase at a constant speed from maybe 75%-85%
function pounce(dt)
    currentFoxAction = "Pouncing"
    -- Quick, final  brightness jump
    local pouncingFox = foxEntity["subState"]
    local pounceBrightness = foxEntity["distance"] + (pounceTime * dt)

    if pounceBrightness > 256 then
        -- When all substates finished switch back to sleeping
        foxEntity["state"] = sleeping
        foxEntity["subState"] = sleeping
        foxEntity["distance"] = 0
        pounceBrightness = 0
    end

    return pounceBrightness
end


--====================================================================
-- Fade fox brightness down
--====================================================================
function fadeFoxStep(dt, foxBrightness)
    foxBrightness = foxBrightness - (pounceTime*dt)
    return foxBrightness
end
--====================================================================
-- Fade fox brightness up
--====================================================================
function fadeFoxStalk(dt, foxBrightness)
    foxBrightness = foxBrightness + (foxStalkSpeed*dt)
    return foxBrightness
end


--====================================================================
-- Initialize the fox
--====================================================================
function initFox()
    foxEntity["distance"] = 0
    foxEntity["state"] = hunting
    foxEntity["subState"] = sleeping
    foxEntity["timer"] = 0
    foxEntity["huntStepBrightness"] = 0
    foxEntity["huntTimer"] = 0
    foxEntity["stalkBrightness"] = 0
    foxEntity["stalkTimer"] = 0
    foxEntity["lungeTimer"] = 0
    foxEntity["pounceTimer"] = 0
end