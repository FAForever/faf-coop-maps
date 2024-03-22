--------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_E06/SCCA_Coop_E06_AeonAI.lua
--  Author(s): Dhomie42
--
--  Summary  : Aeon army AI for UEF Mission 6 - SCCA_Coop_E06
--------------------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')

-- ------
-- Locals
-- ------
local Aeon = 3
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local CustomFunctions = '/maps/scca_coop_e06/scca_coop_e06_customfunctions.lua'
local AIAttackUtils = '/maps/scca_coop_e06/scca_coop_e06_aiattackutilities.lua'
local AIBehaviors = '/maps/scca_coop_e06/scca_coop_e06_aibehaviors.lua'

-- Used for CategoryHunterPlatoonAI
local ConditionCategories = {
	MassedAir = (categories.TECH3 + categories.EXPERIMENTAL) * categories.AIR * categories.MOBILE,
    ExperimentalLand = categories.uel0401 + (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    ExperimentalNaval = categories.EXPERIMENTAL * categories.NAVAL,
	GameEnderStructure = categories.ueb2401 + (categories.STRATEGIC * categories.TECH3) + (categories.EXPERIMENTAL * categories.STRUCTURE) + categories.NUKE, -- Merged Nukes and HLRAs
}
-- -------------
-- Base Managers
-- -------------
local M2AeonSEBase = BaseManager.CreateBaseManager()
local M3AeonSWBase = BaseManager.CreateBaseManager()
local M3AeonArnoldBase = BaseManager.CreateBaseManager()

-- -----------------
-- Utility functions
-- -----------------
function M2AddHLRA()
	M2AeonSEBase:AddBuildGroup('M2_Aeon_SE_HLRA', 50)
end

function M3AddHLRA()
	M3AeonArnoldBase:AddBuildGroup('M3_Arnold_HLRA', 50)
	M3AeonSWBase:AddBuildGroup('M3_SW_HLRA', 50)
end

function M3AddNukePlatoon()
	local Builder = {
        BuilderName = 'Aeon_NukePlatoon_Builder',
        PlatoonTemplate = {
            'Aeon_NukeTemplate',
            'NoPlan',
            { 'uab2305', 1, 1, 'Attack', 'None' },
        },
        Priority = 100,
        PlatoonType = 'Any',
        RequiresConstruction = false,
        PlatoonAIFunction = {CustomFunctions, 'NukePlatoon'},
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
end

function M3EnableSWTMLs()
	M3AeonSWBase:SetActive('TML', true)
end

-- -----------------
-- M3 SE Base AI
-- -----------------
function M2AeonSEBaseAI()

	-- -----------
    -- Aeon Base
    -- -----------
    M2AeonSEBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M2_Aeon_SE_Base', 'M2_Aeon_SE_Base_Marker', 210,
		{
			M2_Aeon_SE_Base = 100,
		}
	)
	
	M2AeonSEBase:StartNonZeroBase({4, 8, 12})
	M2AeonSEBase:SetMaximumConstructionEngineers(8)
	M2AeonSEBase:SetConstructionAlwaysAssist(true)
	
	M2AeonSEBase:SetActive('AirScouting', true)
    M2AeonSEBase:SetActive('LandScouting', true)
	-- Enable nukes
	--M2AeonSEBase:SetActive('Nuke', true)
	ArmyBrains[Aeon]:PBMSetCheckInterval(5)
	
	M2AeonSEBaseNavalAttacks()
	M2AeonSEBaseTransportAttacks()
	M2AeonSEBaseAirAttacks()
	M2AeonSEBaseAirDefense()
	M2AeonSEBaseExperimentalAttacks()
end

function M2AeonSEBaseNavalAttacks()
	local opai = nil
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {2, 3, 4}
	local T1Quantity = {5, 4, 3}
	
	-- M1 Aeon Fleet for blocking easy access to the Black Sun Component
	local quantity = {{2, 1}, {4, 2}, {6, 3}}
    opai = M2AeonSEBase:AddOpAI('NavalAttacks', 'M1_Aeon_Component_Blockade_Fleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'Aeon_M1_Navy_Patrol_Chain',
                },
            },
            Priority = 100,
        }
    )
	opai:SetChildQuantity({'Destroyers', 'Cruisers'}, quantity[Difficulty])
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	
	
	-- M2 Main Aeon Fleet for Phase 2
	local Temp = {
        'M2_Aeon_SouthEastern_Naval_Fleet',
        'NoPlan',
        { 'uas0302', 1, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
        { 'uas0201', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'uas0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'uas0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'uas0203', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	local Builder = {
        BuilderName = 'M2_Aeon_SouthEastern_Naval_Fleet_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Aeon_SE_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
		},
        PlatoonAIFunction = {CustomFunctions, 'NavalHuntAI'},
		PlatoonData = {
			UseFormation = 'AttackFormation',
        },     
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	-- M1 Aeon Fleet for probe attacks
	Temp = {
        'M2_Aeon_SouthEastern_Naval_Probe_Attack',
        'NoPlan',
        { 'uas0201', 1, 1, 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'uas0202', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'uas0103', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'uas0203', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	Builder = {
        BuilderName = 'M2_Aeon_SouthEastern_Naval_Probe_Attack_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Aeon_SE_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {1}},
		},
        PlatoonAIFunction = {AIAttackUtils, 'NavalForceAI'},
        PlatoonData = {
			UseFormation = 'AttackFormation',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function M2AeonSEBaseTransportAttacks()
	local opai = nil
	local quantity = {2, 4, 6}
	local T3Quantity = {1, 2, 3}
	local T2Quantity = {2, 3, 4}
	local poolName = 'M2_Aeon_SE_Base_TransportPool'
	
	-- T2 Transport Platoon
	local Temp = {
        'M2_Aeon_SouthEastern_Transport_Platoon',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
	local Builder = {
        BuilderName = 'M2_Aeon_SouthEastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Aeon_SE_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveLessThanUnitsInTransportPool', {12, poolName}},
		},
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
		PlatoonData = {
			BaseName = 'M2_Aeon_SE_Base',
		},
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Builder = {
        BuilderName = 'M2_Aeon_Southern_Land_Assault',
        PlatoonTemplate = {
            'M2_Aeon_Southern_Land_Assault_Template',
            'NoPlan',
            {'ual0303', 1, T3Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Siege Bot
            {'ual0304', 1, T3Quantity[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Artillery
            {'ual0202', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Heavy Tank
            {'ual0205', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile AA
            {'ual0307', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_Aeon_SE_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {6, poolName}},
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
		},
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'Player_Attack_Locations_Chain',
            LandingChain = 'Aeon_M2_Land_Assault_Landing_Chain',
            TransportReturn = 'M2_Aeon_SE_Base_Marker',
			BaseName = 'M2_Aeon_SE_Base',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
end

function M2AeonSEBaseAirAttacks()
    local opai = nil
	local quantity = {6, 12, 18}
	local trigger = {30, 25, 20}
		
	-- Sends [6, 12, 18] Air Superiority Fighters to players if they have >= 30, 25, 20 air units
	opai = M2AeonSEBase:AddOpAI('AirAttacks', 'M2_AeonSouthEastern_AirSuperiority_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	
	-- Sends [6, 12, 18] Torpedo Bombers to players if they have >= 15, 10, 5 naval units
	trigger = {15, 10, 5}
	opai = M2AeonSEBase:AddOpAI('AirAttacks', 'M2_AeonSouthEastern_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
	
	-- Sends [6, 12, 18] Strategic Bombers to players
	opai = M2AeonSEBase:AddOpAI('AirAttacks', 'M2_AeonSouthEastern_StratBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	
	-- Sends [6, 12, 18] Gunships to players
	opai = M2AeonSEBase:AddOpAI('AirAttacks', 'M2_AeonSouthEastern_Gunships_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	
	-- Aeon general air template
	quantity = {4, 5, 6}
	local Builder = {
        BuilderName = 'M2_Aeon_Main_AirForce_Builder',
        PlatoonTemplate = {
			'M2_Aeon_Main_AirForce_Template',
			'NoPlan',
			{ 'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Strat Bomber
			{ 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 ASF
			{ 'uaa0203', 1, quantity[Difficulty] * 2, 'Attack', 'AttackFormation' }, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Aeon_SE_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'}
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
end

function M2AeonSEBaseAirDefense()
    local opai = nil
	local quantity = {6, 12, 18}	-- Air Factories = [2, 4, 6] depending on the Difficulty
	local ChildType = {'AirSuperiority', 'StratBombers', 'Gunships', 'TorpedoBombers'}
	
	-- Maintains [6, 12, 18] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = M2AeonSEBase:AddOpAI('AirAttacks', 'M2_Aeon_SouthEastern_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'Aeon_M2_SouthEastern_Base_Patrol_Chain',
				},
				Priority = 200 - k,	-- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M2AeonSEBaseExperimentalAttacks()
	local opai = nil
	local platoonUnitCount = {1, 2, 3}
	
	-- Tempest with advanced behaviour
	opai = M2AeonSEBase:AddOpAI('M2_Aeon_SE_Tempest',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {AIBehaviors, 'TempestBehavior'},
            PlatoonData = {
				BuildTable = {
					'uas0103',	--T1 Frigate
					'uas0201',	--T2 Destroyer
					'uas0202',	--T2 Cruiser
				},
				Formation = 'NoFormation',
				UnitCount = platoonUnitCount[Difficulty],
				},
			BuildCondition = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}}
			},
            MaxAssist = Difficulty,
            Retry = true,
        }
    )
end

-- -----------------
-- M3 Arnold Base AI
-- -----------------
function M3AeonArnoldBaseAI()
	-- -----------
    -- Aeon Base
    -- -----------
    M3AeonArnoldBase:Initialize(ArmyBrains[Aeon], 'M3_Arnold_Base', 'M3_Arnold_Base_Marker', 250,
		{
			M3_Arnold_Base_Essentials = 100,
		}
	)
	M3AeonArnoldBase:StartNonZeroBase({9, 15, 21})
	M3AeonArnoldBase:SetMaximumConstructionEngineers(15)
	M3AeonArnoldBase:SetConstructionAlwaysAssist(true)
	ArmyBrains[Aeon]:PBMSetCheckInterval(7)
	
	M3AeonArnoldBase:SetSupportACUCount(1)
	M3AeonArnoldBase:SetSACUUpgrades({'SystemIntegrityCompensator', 'ResourceAllocation', 'EngineeringFocusingModule'}, false)
	
	M3AeonArnoldBase:SetActive('AirScouting', true)
	
	-- Additional stuff if players chose full map access in the lobby
	if ScenarioInfo.Options.FullMapAccess == 2 then
		M3AeonArnoldBase:AddBuildGroup('M3_Arnold_Base_D' .. Difficulty, 90)
		M3AeonArnoldBaseAirDefense()
		M3AeonArnoldBaseExperimentalAttacks()
	end
	M3AeonArnoldBaseAirAttacks()
	M3AeonArnoldBaseNavalAttacks()
	M3AeonArnoldBaseTransportAttacks()
end

function M3AeonArnoldBaseAirDefense()
    local opai = nil
	local quantity = {4, 6, 8}
	local ChildType = {'AirSuperiority', 'StratBombers', 'Gunships', 'TorpedoBombers'}
		
	-- Maintains [4, 6, 8] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = M3AeonArnoldBase:AddOpAI('AirAttacks', 'M3_Arnold_AirDefense_' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'M3_Arnold_Base_Air_Patrol_Chain',
				},
				Priority = 250 - k, -- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M3AeonArnoldBaseAirAttacks()
    local opai = nil
	local quantity = {}
	local trigger = {}
		
	-- Probe attacks
	opai = M3AeonArnoldBase:AddOpAI('AirAttacks', 'M3_Arnold_AntiGround_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'Aeon_M3_Attack_Final_Czar_Escorts_Chain',
					'Aeon_M3_Attack_Two_Air_G1_Chain',
				},
			},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'StratBombers', 'Gunships', 'Bombers'}, {4, 8, 12})

    opai = M3AeonArnoldBase:AddOpAI('AirAttacks', 'M3_Arnold_AntiAir_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'Aeon_M3_Attack_Final_Czar_Escorts_Chain',
					'Aeon_M3_Attack_Two_Air_G1_Chain',
				},
			},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Interceptors'}, {4, 8, 12})
	
	-- Sends [4, 10, 18] Torpedo Bombers to players if they have >= 15, 10, 5 naval units
	quantity = {4, 8, 12}
	trigger = {15, 10, 5}
	opai = M3AeonArnoldBase:AddOpAI('AirAttacks', 'M3_Arnold_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
			Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
		
	-- Aeon general air template
	quantity = {2, 3, 4}
	local Builder = {
        BuilderName = 'M3_Arnold_AirForce_Builder',
        PlatoonTemplate = {
			'M3_Arnold_AirForce_Template',
			'NoPlan',
			{ 'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Strat Bomber
			{ 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 ASF
			{ 'uaa0203', 1, quantity[Difficulty] * 2, 'Attack', 'AttackFormation' }, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Arnold_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'}    
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	-- Builds [4, 8, 12] Strategic Bombers if players have >= 3, 2, 1 active SMLs, T3 Artillery, etc., and attacks said structures.
	quantity = {4, 8, 12}
	trigger = {3, 2, 1}
	opai = M3AeonArnoldBase:AddOpAI('AirAttacks', 'M3_Arnold_GameEnderStructure_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.GameEnderStructure},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.GameEnderStructure, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})

	-- Builds [4, 8, 12] Strategic Bombers if players have >= 3, 2, 1 active Land Experimental units, and attacks said Experimentals.
	quantity = {4, 8, 12}
	trigger = {3, 2, 1}
	opai = M3AeonArnoldBase:AddOpAI('AirAttacks', 'M3_Arnold_LandExperimental_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalLand},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalLand, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	
	-- Builds, [8, 16, 24] Air Superiority Fighters if players have >= 150, 125, 75 active T3/Experimental Air units, and attacks said units
	quantity = {8, 16, 24}
	trigger = {150, 125, 75}
	opai = M3AeonArnoldBase:AddOpAI('AirAttacks', 'M3_Arnold_MassedAir_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.MassedAir},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.MassedAir, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
end

function M3AeonArnoldBaseNavalAttacks()
	local opai = nil
	local PatrolDestroyerQuantity = {1, 2, 4}
	local PatrolCruiserQuantity = {1, 1, 2}
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {1, 2, 4}
	local T1Quantity = {2, 4, 6}
	local Temp
	local Builder
	
	-- Probing Aeon Fleet to let the players know of the off-map Aeon base
	opai = M3AeonArnoldBase:AddOpAI('NavalAttacks', 'M3_Arnold_Probe_Fleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'Aeon_M3_Attack_Final_Naval_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, {12, 6})
	
	-- Large Naval Fleet only enabled for full map access
	if ScenarioInfo.Options.FullMapAccess == 2 then
		Temp = {
			'M3_Arnold_Naval_Fleet_Template',
			'NoPlan',
			{ 'uas0302', 1, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
			{ 'uas0201', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
			{ 'uas0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
			{ 'uas0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
			{ 'uas0203', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
		}
		Builder = {
			BuilderName = 'M3_Arnold_Naval_Fleet_Builder',
			PlatoonTemplate = Temp,
			InstanceCount = Difficulty + 1,
			Priority = 100,
			PlatoonType = 'Sea',
			RequiresConstruction = true,
			LocationType = 'M3_Arnold_Base',
			BuildConditions = {
				{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {4}},
			},
			PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'Aeon_M3_Attack_Three_Navy_G1_Chain',
				},
			},
		}
		ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	end
	
	-- Small Naval Fleet, with an added Battleship, to counter Cybran Naval forces better
	Temp = {
        'M3_Arnold_Naval_Attack_Template',
        'NoPlan',
		{ 'uas0302', 1, 1, 'Attack', 'AttackFormation' }, -- T3 Battleship
        { 'uas0201', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'uas0202', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'uas0103', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'uas0203', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	
	Builder = {
        BuilderName = 'M3_Arnold_Naval_Attack_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_Arnold_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
				PatrolChains = {
					'Aeon_M3_Attack_Three_Navy_G1_Chain',
				},
            },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	-- Not exactly a 'Naval' attack, but it's going to come from the sea
	opai = M3AeonArnoldBase:AddOpAI('M3_Arnold_GC_Extra',
        {
        Amount = T3Quantity[Difficulty],
		KeepAlive = true,
		PlatoonAIFunction = {CustomFunctions, 'AdvancedPatrolThread'},
		PlatoonData = {
			PatrolChain = 'Player_Attack_Locations_Chain',
		},
		BuildCondition = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}}
		},
        MaxAssist = Difficulty * 2,
        Retry = true,
        }
    )
end

function M3AeonArnoldBaseTransportAttacks()
	local opai = nil
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {1, 2, 3}
	local poolName = 'M3_Arnold_Base_TransportPool'
	
	-- Transport Builder
	local Builder = {
        BuilderName = 'M3_Arnold_Transport_Platoon_Builder',
        PlatoonTemplate = {
			'M3_Arnold_Transport_Platoon_Template',
			'NoPlan',
			{ 'uaa0104', 1, 4, 'Attack', 'None' }, -- T2 Transport
		},
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Arnold_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveLessThanUnitsInTransportPool', {8, poolName}},
		},
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
		PlatoonData = {
			BaseName = 'M3_Arnold_Base',
		},
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Builder = {
        BuilderName = 'M3_Arnold_Land_Assault',
        PlatoonTemplate = {
            'M3_Arnold_Land_Assault_Template',
            'NoPlan',
            {'ual0303', 1, T3Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Siege Bot
            {'ual0304', 1, T3Quantity[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Artillery
            {'ual0202', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Heavy Tank
            {'ual0205', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile AA
            {'ual0307', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M3_Arnold_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {4, poolName}},
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
			AttackChain = 'Player_Attack_Locations_Chain',
            LandingChain = 'Aeon_M3_SW_Landing_Chain',
            TransportReturn = 'M3_Arnold_Base_Marker',
			BaseName = 'M3_Arnold_Base',
			GenerateSafePath = true,
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

-- Arnold Experimentals for Phase 3
function M3AeonArnoldBaseExperimentalAttacks()
	local opai = nil
	local quantity = {1, 1, 2}
	local platoonUnitCount = {1, 2, 3}
	
	-- Sends [1, 2, 3] Galactic Collosuses to the players
	for i = 1, Difficulty do
        opai = M3AeonArnoldBase:AddOpAI('M3_Arnold_GC_' .. i,
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M3_Arnold_Galatic_Colossus_Platoon',
                    NumRequired = Difficulty,
                    PatrolChains = {
						'Player_Attack_Locations_Chain',
					},
                },
				BuildCondition = {
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {4}}
				},
                MaxAssist = Difficulty * 2,
                Retry = true,
            }
        )
    end
	
	opai = M3AeonArnoldBase:AddOpAI('M3_Arnold_Tempest',
        {
        Amount = 1,
		KeepAlive = true,
		PlatoonAIFunction = {AIBehaviors, 'TempestBehavior'},
		PlatoonData = {
			BuildTable = {
				'uas0103',	--T1 Frigate
				'uas0201',	--T2 Destroyer
				'uas0202',	--T2 Cruiser
			},
			Formation = 'NoFormation',
			UnitCount = platoonUnitCount[Difficulty],
		},
		BuildCondition = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {4}}
		},
        MaxAssist = Difficulty * 2,
        Retry = true,
        }
    )
end

-- -------------
-- M3 SW Base AI
-- -------------

function M3AeonSWBaseAI()
	-- -----------
    -- Aeon Base
    -- -----------
    M3AeonSWBase:Initialize(ArmyBrains[Aeon], 'M3_SW_Base', 'M3_SW_Base_Marker', 210,
		{
			M3_SW_Base_Essentials = 100,
		}
	)
	M3AeonSWBase:StartNonZeroBase({6, 12, 18})
	M3AeonSWBase:SetMaximumConstructionEngineers(12)
	M3AeonSWBase:SetConstructionAlwaysAssist(true)
	
	M3AeonSWBase:SetSupportACUCount(1)
	M3AeonSWBase:SetSACUUpgrades({'SystemIntegrityCompensator', 'ResourceAllocation', 'EngineeringFocusingModule'}, false)
	
	M3AeonSWBase:SetActive('AirScouting', true)
	
	-- Additional stuff if players chose full map access in the lobby
	if ScenarioInfo.Options.FullMapAccess == 2 then
		-- Disable TMLs until the map expands, otherwise they'll snipe stuff from off-map
		M3AeonSWBase:SetActive('TML', false)
		M3AeonSWBase:AddBuildGroup('M3_SW_Base_D' .. Difficulty, 90)
		M3AeonSWBaseAirDefense()
		M3AeonSWBaseExperimentalAttacks()
	end
	M3AeonSWBaseAirAttacks()
	M3AeonSWBaseNavalAttacks()
	M3AeonSWBaseTransportAttacks()
end

function M3AeonSWBaseAirDefense()
    local opai = nil
	local quantity = {4, 6, 8}
	local ChildType = {'AirSuperiority', 'StratBombers', 'Gunships', 'TorpedoBombers'}

	-- Maintains [4, 6, 8] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = M3AeonSWBase:AddOpAI('AirAttacks', 'M3_SW_AirDefense_' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'M3_SW_Base_Air_Patrol_Chain',
				},
				Priority = 250 - k, -- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M3AeonSWBaseAirAttacks()
    local opai = nil
	local quantity = {}
	local trigger = {}

	-- Probe attacks
	opai = M3AeonSWBase:AddOpAI('AirAttacks', 'M3_SW_AntiGround_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'StratBombers', 'Gunships', 'Bombers'}, {4, 8, 12})

    opai = M3AeonSWBase:AddOpAI('AirAttacks', 'M3_SW_AntiAir_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Interceptors'}, {4, 8, 12})
		
	-- Aeon general air template
	quantity = {2, 3, 4}
	local Builder = {
        BuilderName = 'M3_SW_AirForce_Builder',
        PlatoonTemplate = {
			'M3_SW_AirForce_Template',
			'NoPlan',
			{ 'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Strat Bomber
			{ 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 ASF
			{ 'uaa0203', 1, quantity[Difficulty] * 2, 'Attack', 'AttackFormation' }, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_SW_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'}    
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	-- Builds [4, 8, 12] Torpedo Bombers if players have >= 15, 10, 5 naval units
	quantity = {4, 8, 12}
	trigger = {15, 10, 5}
	opai = M3AeonSWBase:AddOpAI('AirAttacks', 'M3_SW_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
			Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	
	-- Builds [4, 8, 12] Strategic Bombers if players have >= 3, 2, 1 active SMLs, T3 Artillery, etc., and attacks said structures.
	quantity = {4, 8, 12}
	trigger = {3, 2, 1}
	opai = M3AeonSWBase:AddOpAI('AirAttacks', 'M3_Aeon_SW_GameEnderStructure_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.GameEnderStructure},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.GameEnderStructure, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})

	-- Builds [4, 8, 12] Strategic Bombers if players have >= 3, 2, 1 active Land Experimental units, and attacks said Experimentals.
	quantity = {4, 8, 12}
	trigger = {3, 2, 1}
	opai = M3AeonSWBase:AddOpAI('AirAttacks', 'M3_Aeon_SW_LandExperimental_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalLand},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalLand, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	
	-- Builds, [8, 16, 24] Air Superiority Fighters if players have >= 150, 125, 75 active T3/Experimental Air units, and attacks said units
	quantity = {8, 16, 24}
	trigger = {150, 125, 75}
	opai = M3AeonSWBase:AddOpAI('AirAttacks', 'M3_Aeon_SW_AirExperimental_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.MassedAir},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.MassedAir, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
end

function M3AeonSWBaseNavalAttacks()
	local opai = nil
	local PatrolDestroyerQuantity = {1, 2, 4}
	local PatrolCruiserQuantity = {1, 1, 2}
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {2, 3, 4}
	local T1Quantity = {5, 4, 3}
	local Temp
	local Builder
	
	-- Probing Aeon Fleet to let the players know of the off-map Aeon base
	opai = M3AeonSWBase:AddOpAI('NavalAttacks', 'M3_SW_Probe_Fleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'Aeon_M3_SW_Naval_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, {8, 4})
	
	-- Large Naval Fleet, only enabled for full map access
	if ScenarioInfo.Options.FullMapAccess == 2 then
		Temp = {
			'M3_SW_Naval_Fleet_Template',
			'NoPlan',
			{ 'uas0302', 1, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
			{ 'uas0201', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
			{ 'uas0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
			{ 'uas0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
			{ 'uas0203', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
		}
		Builder = {
			BuilderName = 'M3_SW_Naval_Fleet_Builder',
			PlatoonTemplate = Temp,
			InstanceCount = Difficulty + 1,
			Priority = 100,
			PlatoonType = 'Sea',
			RequiresConstruction = true,
			LocationType = 'M3_SW_Base',
			BuildConditions = {
				{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {4}},
			},
			PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'Aeon_M3_SW_Naval_Chain',
				},
			},
		}
		ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	end
	
	-- Smaller Naval Fleet
	Temp = {
        'M3_SW_Naval_Attack_Template',
        'NoPlan',
        { 'uas0201', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'uas0202', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'uas0103', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'uas0203', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	
	Builder = {
        BuilderName = 'M3_SW__Naval_Attack_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_SW_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {
				'Aeon_M3_SW_Naval_Chain',
			},
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function M3AeonSWBaseTransportAttacks()
	local opai = nil
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {1, 2, 3}
	local poolName = 'M3_SW_Base_TransportPool'
	
	-- Transport Builder
	local Builder = {
        BuilderName = 'M3_SW_Transport_Platoon_Builder',
        PlatoonTemplate = {
			'M3_SW_Transport_Platoon_Template',
			'NoPlan',
			{ 'uaa0104', 1, 4, 'Attack', 'None' }, -- T2 Transport
		},
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_SW_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveLessThanUnitsInTransportPool', {8, poolName}},
		},
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
		PlatoonData = {
			BaseName = 'M3_SW_Base',
		},
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Builder = {
        BuilderName = 'M3_SW_Land_Assault',
        PlatoonTemplate = {
            'M3_SW_Land_Assault_Template',
            'NoPlan',
            {'ual0303', 1, T3Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Siege Bot
            {'ual0304', 1, T3Quantity[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Artillery
            {'ual0202', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Heavy Tank
            {'ual0205', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile AA
            {'ual0307', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M3_SW_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {4, poolName}},
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
			AttackChain = 'Player_Attack_Locations_Chain',
            LandingChain = 'Aeon_M3_SW_Landing_Chain',
            TransportReturn = 'M3_SW_Base_Marker',
			BaseName = 'M3_SW_Base',
			GenerateSafePath = true,
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

-- SW Experimentals for Phase 3
function M3AeonSWBaseExperimentalAttacks()
	local opai = nil
	local quantity = {1, 1, 2}
	local platoonUnitCount = {1, 2, 3}
	
	-- Send [1, 1, 2] Tempests at the Players
    opai = M3AeonSWBase:AddOpAI('M3_SW_Tempest',
        {
            Amount = 1,
			KeepAlive = true,
			PlatoonAIFunction = {AIBehaviors, 'TempestBehavior'},
			PlatoonData = {
				BuildTable = {
					'uas0103',	--T1 Frigate
					'uas0201',	--T2 Destroyer
					'uas0202',	--T2 Cruiser
				},
				Formation = 'NoFormation',
				UnitCount = platoonUnitCount[Difficulty],
			},
			BuildCondition = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {4}}
			},
       MaxAssist = Difficulty,
        Retry = true,
        }
    )
    
	
	-- Sends [1, 1, 2] Galactic Collosuses to the players
	for i = 1, quantity[Difficulty] do
        opai = M3AeonSWBase:AddOpAI('M3_SW_GC_' .. i,
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M3_SW_Galatic_Colossus_Platoon',
                    NumRequired = quantity[Difficulty],
                    PatrolChains = {
						'Player_Attack_Locations_Chain',
					},
                },
				BuildCondition = {
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {4}}
				},
                MaxAssist = 3,
                Retry = true,
            }
        )
    end
end