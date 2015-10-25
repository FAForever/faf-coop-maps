-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Loyalist army AI for Mission 1 - X1CA_Coop_002
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

--------
-- Locals
--------
local Loyalist = 4

---------------
-- Base Managers
---------------
local LoyalistM1MainBase = BaseManager.CreateBaseManager()

function LoyalistM1MainBaseAI()

    -----------------------
    -- Loyalist M1 Main Base
    -----------------------
    ScenarioUtils.CreateArmyGroup('Loyalist', 'Starting_Units')
    LoyalistM1MainBase:InitializeDifficultyTables(ArmyBrains[Loyalist], 'M1_Loy_StartBase', 'Loyalist_M1_Pinned_Base', 40, {M1_Loy_StartBase = 100})
    LoyalistM1MainBase:StartNonZeroBase(1, true) -- true makes the base uncapturable
    LoyalistM1MainBase:SetActive('AirScouting', true)
    LoyalistM1MainBase:SetActive('LandScouting', true)

    LoyalistM1MainBaseLandAttacks()
end

function LoyalistM1MainBaseLandAttacks()
    local opai = nil

    -------------------------------------------
    -- Loyalist M1 Main Base Op AI, Land Attacks
    -------------------------------------------

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
        }
    )
    opai:RemoveChildren({'SiegeBots', 'MobileHeavyArtillery'})
    opai:SetLockingStyle('DeathRatio', {Ratio = .5})
end

function LoyalistM1MainLandAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then
            if(ScenarioInfo.MissionNumber == 1) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'Guerrillas_M1_Attack_Chain')
            elseif(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'Guerrillas_M2_Attack_Chain')
            elseif(ScenarioInfo.MissionNumber == 4) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M4_LoyalistMain_LandAttack_Chain')
            end
        end
        WaitSeconds(11)
    end
end

function M1P1Response()
    LoyalistM1MainBase:AddBuildGroup('M1_Loy_WreckedBase', 90)
    LoyalistM1MainBase:AddBuildGroup('M1_Canyon_Defenses_Land', 80)
    LoyalistM1MainBase:AddBuildGroup('M1_Canyon_Defenses_Air', 70)
end