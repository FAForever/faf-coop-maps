-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Loyalist army AI for Mission 2 - X1CA_Coop_002
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

--------
-- Locals
--------
local Loyalist = 4

---------------
-- Base Managers
---------------
local LoyalistM2EastBase = BaseManager.CreateBaseManager()
local LoyalistM2WestBase = BaseManager.CreateBaseManager()

function LoyalistM2EastBaseAI()

    -----------------------
    -- Loyalist M2 East Base
    -----------------------
    LoyalistM2EastBase:Initialize(ArmyBrains[Loyalist], 'M2_Loyalist_Base_East', 'M2_Loyalist_Base_East_Marker', 30, {M2_Loyalist_Base_East = 100})
    LoyalistM2EastBase:StartNonZeroBase(1)
    LoyalistM2EastBase:SetActive('AirScouting', true)
    LoyalistM2EastBase:SetActive('LandScouting', true)

    -- disable omni
    local omni = ScenarioFramework.GetCatUnitsInArea(categories.uab3104, ScenarioUtils.AreaToRect('M2_Playable_Area'), ArmyBrains[Loyalist])
    local num = table.getn(omni)
    if(num > 0) then
        for i = 1, num do
            omni[i]:DisableIntel('Omni')
        end
    end

    LoyalistM2EastBaseAirAttacks()
    LoyalistM2EastBaseLandAttacks()
end

function LoyalistM2EastBaseAirAttacks()
    local opai = nil

    ------------------------------------------
    -- Loyalist M2 East Base Op AI, Air Attacks
    ------------------------------------------

    -- Air Attack
    opai = LoyalistM2EastBase:AddOpAI('AirAttacks', 'M2_AirAttacks',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2EastAirAttacksAI'},
        }
    )
    opai:SetChildActive('TorpedoBombers', false)
    opai:SetChildActive('HeavyTorpedoBombers', false)
end

function LoyalistM2EastAirAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then
            if(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M2_LoyEast_Attack_Air_Chain')
            elseif(ScenarioInfo.MissionNumber == 4) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M4_Loy_East_Attack_Chain')
            end
        end
        WaitSeconds(11)
    end
end

function LoyalistM2EastBaseLandAttacks()
    local opai = nil

    -------------------------------------------
    -- Loyalist M2 East Base Op AI, Land Attacks
    -------------------------------------------

    -- Land Attack
    opai = LoyalistM2EastBase:AddOpAI('BasicLandAttack', 'M2_LandAttackEast',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2EastLandAttacksAI'},
        }
    )
    opai:SetChildActive('MobileShields', false)
end

function LoyalistM2EastLandAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then
            if(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M2_LoyEast_Attack_' .. Random(1, 2) .. '_Chain')
            elseif(ScenarioInfo.MissionNumber == 4) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M4_Loy_East_Attack_Chain')
            end
        end
        WaitSeconds(11)
    end
end

function LoyalistM2WestBaseAI()

    -----------------------
    -- Loyalist M2 West Base
    -----------------------
    LoyalistM2WestBase:Initialize(ArmyBrains[Loyalist], 'M2_Loyalist_Base_West', 'M2_Loyalist_Base_West_Marker', 25, {M2_Loyalist_Base_West = 100})
    LoyalistM2WestBase:StartNonZeroBase(1)
    LoyalistM2WestBase:SetActive('LandScouting', true)

    LoyalistM2WestBaseLandAttacks()
end

function LoyalistM2WestBaseLandAttacks()
    local opai = nil

    -------------------------------------------
    -- Loyalist M2 West Base Op AI, Land Attacks
    -------------------------------------------

    -- Land Attack
    opai = LoyalistM2WestBase:AddOpAI('BasicLandAttack', 'M2_LandAttackWest',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2WestLandAttacksAI'},
        }
    )
    opai:SetChildActive('MobileShields', false)
end

function LoyalistM2WestLandAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then
            if(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M2_LoyWest_Attack_' .. Random(1, 2) .. '_Chain')
            elseif(ScenarioInfo.MissionNumber == 4) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M4_Loy_West_Attack_Chain')
            end
        end
        WaitSeconds(11)
    end
end