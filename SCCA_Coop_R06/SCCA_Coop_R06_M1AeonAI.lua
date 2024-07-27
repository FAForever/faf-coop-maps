--------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R06/SCCA_Coop_R06_M1AeonAI
--  Author(s): Dhomie42
--
--  Summary  : Aeon army AI for Mission 1 - SCCA_Coop_R06
--------------------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')

-- ------
-- Locals
-- ------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local MainScript = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_script.lua'
local CustomFunctions = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_CustomFunctions.lua'

-- Used for CategoryHunterPlatoonAI
local ConditionCategories = {
    ExperimentalAir = categories.EXPERIMENTAL * categories.AIR,
    ExperimentalLand = categories.uel0401 + (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    ExperimentalNaval = categories.EXPERIMENTAL * categories.NAVAL,
	GameEnderStructure = categories.ueb2401 + (categories.STRATEGIC * categories.TECH3) + (categories.EXPERIMENTAL * categories.STRUCTURE) + categories.NUKE, --Merged Nukes and HLRAs
}
----------------
-- Base Managers
----------------
local AeonMainBase = BaseManager.CreateBaseManager()


-- Update engineer counts
function UpdateEngineerQuantity()
	AeonMainBase:SetEngineerCount({4, 8, 12})
end

function AeonMainBaseAI()
	------------
    -- Aeon Base
    ------------
    AeonMainBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M1_Aeon_Main_Base', 'AeonBase', 250,
		{
		MainBaseStructuresPreBuilt = 300,
		}
	)
	AeonMainBase:StartNonZeroBase({1, 2, 12})
	AeonMainBase:SetMaximumConstructionEngineers(12)
	ArmyBrains[Aeon]:PBMSetCheckInterval(5)
	
	-- Spawn what's meant to be built instead, otherwise the Czar takes too long to finish
	AeonMainBase:AddBuildGroup('MainBaseStructuresPostBuilt_D' .. Difficulty, 200, true)
	
	-- Add HLRA to be built on hard
	-- They, and the Czar should finish around the 20 minute mark
	if Difficulty == 3 then
		AeonMainBase:AddBuildGroup('MainBaseStructuresHLRA', 150)
	-- Update engineer numbers after 7.5 minutes for easy/normal, otherwise the Czar finishes in less than 10 mins
	else
		import('/lua/scenarioframework.lua').CreateTimerTrigger(UpdateEngineerQuantity, 450)
	end
	
	AeonMainBase:SetConstructionAlwaysAssist(true)
	
	AeonMainBase:SetActive('AirScouting', true)
    AeonMainBase:SetActive('LandScouting', true)
	
	AeonMainAirDefense()
	AeonMainAirAttacks()
	AeonMainNavalAttacks()
	AeonMainTransportAttacks()
	AeonMainExperimentalNavalAttacks()
	AeonMainExperimentalAttacks()
end

function AeonMainAirDefense()
    local opai = nil
	local quantity = {4, 6, 8}
	local ChildType = {'AirSuperiority', 'StratBombers', 'Gunships', 'TorpedoBombers'}
		
	-- Maintains [4, 6, 8] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = AeonMainBase:AddOpAI('AirAttacks', 'M1_Aeon_AirDefense_' .. ChildType[k],	-- Example: 'M1_Aeon_AirDefense_AirSuperiority'
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'M1_Aeon_Base_Air_Patrol_Chain',
				},
				Priority = 260 - k, -- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function AeonMainAirAttacks()
    local opai = nil
	local quantity = {}
	local trigger = {}
		
	-- Phase 1 air attacks
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M1_Aeon_AntiGround_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'StratBombers', 'Gunships', 'Bombers'}, {4, 8, 12})

    opai = AeonMainBase:AddOpAI('AirAttacks', 'M1_Aeon_AntiAir_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Interceptors'}, {4, 8, 12})
	
	-- Sends [4, 10, 18] Torpedo Bombers to players if they have >= 15, 10, 5 naval units
	quantity = {4, 8, 12}
	trigger = {15, 10, 5}
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M1_Aeon_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'PlayerNavalAttack_Chain',
            },
			Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
		
	-- Aeon general air template
	quantity = {2, 3, 4}
	local Builder = {
        BuilderName = 'M2_Aeon_Main_AirForce_Builder',
        PlatoonTemplate = {
			'M2_Aeon_Main_AirForce_Template',
			'NoPlan',
			{'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Strat Bomber
			{'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 ASF
			{'uaa0203', 1, quantity[Difficulty] * 2, 'Attack', 'AttackFormation'}, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'}    
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
	
	-- Builds [4, 8, 12] Strategic Bombers if players have >= 3, 2, 1 active SMLs, T3 Artillery, etc., and attacks said structures.
	quantity = {4, 8, 12}
	trigger = {3, 2, 1}
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_GameEnderStructure_Hunters',
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
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_LandExperimental_Hunters',
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
	
	-- Builds, [8, 16, 24] Air Superiority Fighters if players have >= 3, 2, 1 active Air Experimental units, and attacks said Experimentals
	quantity = {8, 16, 24}
	trigger = {3, 2, 1}
	opai = AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirExperimental_Hunters',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalAir},
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalAir, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
end

function AeonMainNavalAttacks()
	local opai = nil
	local PatrolDestroyerQuantity = {1, 2, 4}
	local PatrolCruiserQuantity = {1, 1, 2}
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {1, 2, 4}
	local T1Quantity = {2, 4, 6}
	
	-- Phase 1 Aeon fleets to keep the players busy
	opai = AeonMainBase:AddOpAI('NavalAttacks', 'M1_Aeon_Main_Naval_Fleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'PlayerNavalAttack_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers', 'Cruisers', 'Frigates', 'Submarines'}, {1, 2, 2, 4, 15})
	
	opai = AeonMainBase:AddOpAI('NavalAttacks', 'M1_Aeon_Secondary_Naval_Fleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'PlayerNavalAttack_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates', 'Submarines'}, {T2Quantity[Difficulty], T2Quantity[Difficulty], T1Quantity[Difficulty], T1Quantity[Difficulty]})
	
	-- Large Aeon Naval Fleet for attacking the players from Phase 2
	local Temp = {
        'M2_Aeon_Main_Naval_Fleet',
        'NoPlan',
        {'uas0302', 0, T3Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Battleship
        {'uas0201', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'uas0202', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'uas0103', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Frigate
		{'uas0203', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Submarine
    }
	local Builder = {
        BuilderName = 'M2_Aeon_Main_Naval_Fleet_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty + 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
		PlatoonData = {
            PatrolChain = 'PlayerNavalAttack_Chain',
        },     
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
	
	-- Small Naval Fleet for attacking Aiko at Phase 3
	Temp = {
        'M3_Aeon_Main_Naval_Attack_To_UEF',
        'NoPlan',
        {'uas0201', 0, 2, 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'uas0202', 0, 2, 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'uas0103', 0, 3, 'Attack', 'AttackFormation'}, -- T1 Frigate
		{'uas0203', 0, 3, 'Attack', 'AttackFormation'}, -- T1 Submarine
    }
	
	Builder = {
        BuilderName = 'M3_Aeon_Main_Naval_Attack_To_UEF_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
			PatrolChains = {
				'M3_AeonToUEF_Naval_Chain',
				'M3_AeonNorthWest_To_UEFSouthWest_Naval_Chain',
			},
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
	
	-- Maintains [2/2, 4/2, 8/4] Destroyers/Cruisers respectively
	for i = 1, 2 do
	opai = AeonMainBase:AddOpAI('NavalAttacks', 'M1_Aeon_Defense_Fleet_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'AeonNaval_Chain',
            },
            Priority = 150,
        }
    )
	opai:SetChildQuantity({'Destroyers', 'Cruisers'}, {PatrolDestroyerQuantity[Difficulty], PatrolCruiserQuantity[Difficulty]})
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
	-- Maintains [2/2, 4/2, 8/4] Destroyers/Cruisers respectively North of Arnold's base
	for i = 1, 2 do
	opai = AeonMainBase:AddOpAI('NavalAttacks', 'M1_Aeon_Northen_Defense_Fleet_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'AeonNaval_North_Chain',
            },
            Priority = 150,
        }
    )
	opai:SetChildQuantity({'Destroyers', 'Cruisers'}, {PatrolDestroyerQuantity[Difficulty], PatrolCruiserQuantity[Difficulty]})
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function AeonMainTransportAttacks()
	local opai = nil
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {2, 3, 4}
	local poolName = 'M1_Aeon_Main_Base_TransportPool'
	
	-- Transport Builder
	local Builder = {
        BuilderName = 'M1_Aeon_Main_Transport_Builder',
        PlatoonTemplate = {
			'M1_Aeon_Main_Transport_Platoon',
			'NoPlan',
			{'uaa0104', 1, 4, 'Attack', 'None'}, -- T2 Transport
		},
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveLessThanUnitsInTransportPool', {12, poolName}},
		},
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},
		PlatoonData = {
			BaseName = 'M1_Aeon_Main_Base',
		},
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
	
	Builder = {
        BuilderName = 'M1_Aeon_Main_Land_Assault',
        PlatoonTemplate = {
            'M1_Aeon_Main_Land_Assault_Template',
            'NoPlan',
            {'ual0303', 0, T3Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Siege Bot
            {'ual0304', 0, T3Quantity[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Artillery
            {'ual0202', 0, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Heavy Tank
            {'ual0205', 0, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile AA
            {'ual0307', 0, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {6, poolName}},
		},
        PlatoonAIFunction = {SPAIFileName, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'Aeon_AttackChain',
            LandingChain = 'M2_Aeon_Landing_Chain',
            TransportReturn = 'AeonBase',
			BaseName = 'M1_Aeon_Main_Base',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
	
	Builder = {
        BuilderName = 'M2_Aeon_Main_Land_Sweepers',
        PlatoonTemplate = {
            'M2_Aeon_Main_Land_Sweepers_Template',
            'NoPlan',
            {'ual0303', 0, T3Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Siege Bot
            {'ual0304', 0, T3Quantity[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Artillery
            {'ual0202', 0, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Heavy Tank
            {'ual0205', 0, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile AA
            {'ual0307', 0, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M1_Aeon_Main_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {6, poolName}},
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'ControlCenterBig_Chain',
            LandingChain = 'M2_Aeon_Landing_Chain',
            TransportReturn = 'AeonBase',
			BaseName = 'M1_Aeon_Main_Base',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
end

-- Tempest platoon, for Phase 3
function AeonMainExperimentalNavalAttacks()
	local opai = nil
	local number = {1, 1, 2}
	
	--Send [1, 1, 2] Tempests at the Players
	for i = 1, number[Difficulty] do
        opai = AeonMainBase:AddOpAI('M3_Tempest_' .. i,
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M3_Tempest_Platoon',
                    NumRequired = number[Difficulty],
					PatrolChains = {
						'PlayerNavalAttack_Chain',
					},
                },
				BuildCondition = {
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}}
				},
                MaxAssist = 3,
                Retry = true,
            }
        )
    end
	
end

-- Czar builder once Phase 2 starts
function AeonMainCzarBuilder()
	local opai = nil

	opai = AeonMainBase:AddOpAI('Czar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = Difficulty,
            Retry = true,
        }
    )
end

-- Galactic Colossus defense
function AeonMainColossusDefense()
	local opai = nil
	local quantity = {1, 1, 2}
	-- GCs to guard the base
    opai = AeonMainBase:AddOpAI('M2_GC_1',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'AeonBase_Chain',
            },
            MaxAssist = Difficulty,
            Retry = true,
        }
    )
end

-- Galactic Collosus platoon, for Phase 3
function AeonMainExperimentalAttacks()
	local opai = nil
	
	--Sends [1, 2, 3] Galactic Collosuses to the players
	for i = 1, Difficulty do
        opai = AeonMainBase:AddOpAI('M3_GC_' .. i,
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M3_Galatic_Colossus_Platoon',
                    NumRequired = Difficulty,
                    PatrolChains = {
						'M3_Aeon_GC_Chain_1',
						'M3_Aeon_GC_Chain_2',
						'M3_Aeon_GC_Chain_3',
					},
                },
				BuildCondition = {
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}}
				},
                MaxAssist = 3,
                Retry = true,
            }
        )
    end
end

function EnableAeonMainNukes()
	-- Enable nukes
	AeonMainBase:SetActive('Nuke', true)
end