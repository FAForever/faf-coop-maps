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
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

local Difficulty = ScenarioInfo.Options.Difficulty

-- ------
-- Locals
-- ------
local Loyalist = 4

-- -------------
-- Base Managers
-- -------------
local LoyalistM1MainBase = BaseManager.CreateBaseManager()

function LoyalistM1MainBaseAI()

    -- ---------------------
    -- Loyalist M1 Main Base
    -- ---------------------
    ScenarioUtils.CreateArmyGroup('Loyalist', 'Starting_Units')
    LoyalistM1MainBase:InitializeDifficultyTables(ArmyBrains[Loyalist], 'M1_Loy_StartBase', 'Loyalist_M1_Pinned_Base', 70, {M1_Loy_StartBase = 110})
    LoyalistM1MainBase:StartNonZeroBase({{16, 12, 9}, {14, 10, 7}})
	
	LoyalistM1MainBase:SetMaximumConstructionEngineers(1)
	LoyalistM1MainBase:SetConstructionAlwaysAssist(true)
	
    LoyalistM1MainBase:SetActive('AirScouting', true)
    LoyalistM1MainBase:SetActive('LandScouting', true)

    ArmyBrains[Loyalist]:PBMSetCheckInterval(7)

    LoyalistM1MainBaseLandAttacks()
	LoyalistM1BaseLandDefense()
    LoyalistM1MainBaseAirAttacks()
    -- LoyalistM4TransportAttacks()
end

function LoyalistNewEngCount()
    LoyalistM1MainBase:SetEngineerCount({{18, 13, 9}, {14, 10, 7}})	
	LoyalistM1MainBase:SetMaximumConstructionEngineers(4)
end

function LoyalistM1MainBaseAirAttacks()
    local opai = nil

    -- ----------------------------------------
    -- Loyalist M1 Main Base Op AI, Air Attacks
    -- ----------------------------------------

    for i = 1, 2 do
        opai = LoyalistM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack1_' .. i,
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainAirAttacksAI'},
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'Gunships', 'CombatFighters'}, 8)
	    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory',
	        {0, categories.uab1301, false})
    end
	
	local template = {
        'M1_AirAttack2',
        'NoPlan',
        { 'uaa0303', 1, 2, 'Attack', 'GrowthFormation' },	-- Air Superiority
        { 'uaa0203', 1, 3, 'Attack', 'GrowthFormation' },	-- Gunships
        { 'uaa0103', 1, 4, 'Attack', 'GrowthFormation' },	-- Bombers
    }
	local builder = {
        BuilderName = 'M1_AirAttack2',
        PlatoonTemplate = template,
		InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M1_Loy_StartBase',
		PlatoonAIFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainAirAttacksAI'},
		BuildCondition = {
		    {'/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {0, categories.uab1301, false}},
		},
    }
    ArmyBrains[Loyalist]:PBMAddPlatoon( builder )

    for i = 1, 2 do
        opai = LoyalistM1MainBase:AddOpAI('AirAttacks', 'M1_AirDef_1' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
		        PlatoonData = {
		            PatrolChain = 'M1_Loyalist_AirPatrol_Chain',
		        },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'CombatFighters'}, 4)

        opai = LoyalistM1MainBase:AddOpAI('AirAttacks', 'M1_AirDef_2' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
		        PlatoonData = {
		            PatrolChain = 'M1_Loyalist_AirPatrol_Chain',
		        },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'Gunships'}, 3)
    end

end

function LoyalistM1MainBaseLandAttacks()

    local opai = nil
    local platoons = {}

    -- -----------------------------------------
    -- Loyalist M1 Main Base Op AI, Land Attacks
    -- -----------------------------------------

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 110,
        }
    )
    opai:SetChildActive('HeavyBots', false)
    opai:SetChildActive('SiegeBots', false)
    opai:SetChildActive('MobileHeavyArtillery', false)
    opai:SetChildActive('T3', false)
    opai:SetChildActive('MobileShields', false)
    opai:SetChildCount(2)
	opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory',
	    {0, categories.uab1301, false})

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', 6)

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)
	opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory',
	    {0, categories.uab1301, false})

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack4',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 6)

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_BasicLandAttack5',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 115,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'MobileShields', 'HeavyTanks', 'LightBots'}, 4)
	opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory',
	    {0, categories.uab1301, false})

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M4_BasicLandAttack',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua', 'LoyalistM1MainLandAttacksAI'},
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'MobileShields', 'HeavyTanks', 'LightBots'}, 8)
	opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 4})
	opai:SetLockingStyle('None')

end

function LoyalistM1BaseLandDefense()
    local opai = nil
	local platoons = {}
	
	-- Land Defense
    platoons = {2, 2, 1}
    for i = 1, platoons[Difficulty] do
        opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandDef1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Loyalist_BaseDefense_Chain',
                },
                Priority = 1130,
            }
        )
        opai:SetChildQuantity({'LightTanks', 'LightBots'}, 4)
    end

    platoons = {2, 2, 1}
    for i = 1, platoons[Difficulty]  do
        opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandDef2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Loyalist_BaseDefense_Chain',
                    NoFormation = true,
                },
                Priority = 1120,
            }
        )
        opai:SetChildQuantity({'MobileFlak'}, 2)
    end

    platoons = {2, 1, 1}
    for i = 1, platoons[Difficulty]  do
        opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandDef3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Loyalist_BaseDefense_Chain',
                },
                Priority = 1120,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, 2)
	    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory',
	        {0, categories.uab1301, false})
    end
end

function LoyalistM1MainAirAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

-- ####################################################################
-- BIJ GEBRUIK VAN 'cmd' MOET JE EEN 'PLATOON' COMMANDO GEBRUIKEN !! #
-- ####################################################################

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then

            if(ScenarioInfo.MissionNumber == 1) then
                cmd = ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Guerrillas_M1_Attack_' .. Random(1, 2) .. '_Chain')))

            elseif(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonPatrolChain(platoon, 'Guerrillas_M2_Attack_Chain')

            elseif(ScenarioInfo.MissionNumber == 4) then
                cmd = ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Order_Air_Attack' .. Random(1, 2) .. '_Chain')
            end
        end
        WaitSeconds(11)
    end
end

function LoyalistM1MainLandAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then
            if(ScenarioInfo.MissionNumber == 1) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'Guerrillas_M1_Attack_' .. Random(1, 2) .. '_Chain')
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
    LoyalistM1MainBase:AddBuildGroup('T3PowerGen_AirStaging', 105)
    LoyalistM1MainBase:AddBuildGroup('M1_Loy_WreckedBase', 100)
    LoyalistM1MainBase:AddBuildGroup('MassExtractors', 90)
    LoyalistM1MainBase:AddBuildGroup('M1_Canyon_Defenses_Land', 80)
    LoyalistM1MainBase:AddBuildGroup('M1_Canyon_Defenses_Air', 70)
end

function LoyalistM4TransportAttacks()
    local opai = nil
	
    local template = {
        'AirTemplateTRANSPORTS',
        'NoPlan',
        { 'uaa0104', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local builder = {
        BuilderName = 'AirTRANSPORTS',
        PlatoonTemplate = template,
        Priority = 50000,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        BuildConditions = {
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 6, categories.uaa0104}},
        },
        LocationType = 'M1_Loy_StartBase',
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},
    }
    ArmyBrains[Loyalist]:PBMAddPlatoon( builder )

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_Loy_TransportAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
            TransportReturn = 'Loyalist_M1_Pinned_Base',
        },
        Priority = 200,
    })
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, 3)
	opai:SetLockingStyle('None')

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_Loy_TransportAttack2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
            TransportReturn = 'Loyalist_M1_Pinned_Base',
        },
        Priority = 200,
    })
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, 8)
	opai:SetLockingStyle('None')

    opai = LoyalistM1MainBase:AddOpAI('BasicLandAttack', 'M1_Loy_TransportAttack3',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_Order_Land_Attack1_Chain',
            LandingChain = 'Loyalist_M4_LandingChain',
            TransportReturn = 'Loyalist_M1_Pinned_Base',
        },
        Priority = 200,
    })
    opai:SetChildQuantity({'MobileFlak', 'MobileAntiAir'}, 8)
	opai:SetLockingStyle('None')

end
