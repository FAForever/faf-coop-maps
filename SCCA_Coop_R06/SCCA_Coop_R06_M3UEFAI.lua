--------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R06/SCCA_Coop_R06_M3UEFAI.lua
--  Author(s): Dhomie42
--
--  Summary  : UEF army AI for Mission 3 - SCCA_Coop_R06
--------------------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')

---------
-- Locals
---------
local UEF = 3
local Difficulty = ScenarioInfo.Options.Difficulty
local BMBC = '/lua/editor/BaseManagerBuildConditions.lua'
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local CustomFunctions = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_CustomFunctions.lua'
local AIBehaviors = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_AIBehaviors.lua'

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
local UEFMainBase = BaseManager.CreateBaseManager()
local UEFNavalBase = BaseManager.CreateBaseManager()
local M3UEFSouthWesternBase = BaseManager.CreateBaseManager()

-- Builds additional buildings
function M3UEFMainExpansion()
	UEFMainBase:AddBuildGroup('BaseStructuresPostBuilt_D' .. Difficulty, 100)
end

-- Builds T3 Heavy Artillery only for hard difficulty
function M3UEFMainBuildHeavyArtillery ()
	if(Difficulty == 3) then
		UEFMainBase:AddBuildGroup('HLRA_D3', 90)
	end
end

-- Spawns in SMLs, rebuild them, and enable Nuke AI functionality for the UEF Main Base
function M3UEFBuildStrategicMissileLaunchers()
	UEFMainBase:AddBuildGroup('M3_UEF_SMLs', 90, true) 
	-- Activation function names are inconsistent with the actual functionality states in this case:
	-- 'Nuke', and 'TML' are the activation function names, 'Nukes' and 'TMLs' are the functionality state names.
	UEFMainBase:SetActive('Nuke', true)
end

function UEFMainBaseAI()
	-----------
    -- UEF Base
    -----------
    UEFMainBase:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Main_Base', 'UEFBase', 180,
		{
		BaseStructuresPreBuilt = 450,
		}
	)
	
	UEFMainBase:StartNonZeroBase({8, 10, 12})
	UEFMainBase:SetMaximumConstructionEngineers(12)
	ArmyBrains[UEF]:PBMSetCheckInterval(7)
	UEFMainBase:SetDefaultEngineerPatrolChain('UEFBase_Chain')
	UEFMainBase:SetConstructionAlwaysAssist(true)
	
	UEFMainBase:SetSupportACUCount(1)
	UEFMainBase:SetSACUUpgrades({'Shield', 'AdvancedCoolingUpgrade', 'ResourceAllocation'}, false)
	
	UEFMainBase:SetActive('AirScouting', true)
	
	UEFMainAirAttacks()
	UEFMainLandAttacks()
	UEFMainAirDefense()
	UEFMainExperimentalAttacks()
end

function UEFMainNavalBaseAI()
    ----------------------
    -- UEF Naval Expansion
    ----------------------
    UEFNavalBase:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Main_Naval_Base', 'UEF_Main_Naval_Base_Marker', 105,
        {
			Naval_Base = 150,
        }
    )
	UEFNavalBase:StartNonZeroBase({3, 6, 9})
	UEFNavalBase:SetMaximumConstructionEngineers(9)
	
	UEFMainNavalAttacks()
end

function UEFMainAirDefense()
    local opai = nil
	local quantity = {4, 10, 18}	-- Air Factories = [4, 5, 6] depending on the Difficulty
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers', 'Gunships'}
	
	-- Maintains [4, 10, 18] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = UEFMainBase:AddOpAI('AirAttacks', 'M3UEFMain_AirDefense_' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'M3_UEF_Base_Air_Patrol_Chain',
				},
				Priority = 260 - k, -- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	end
end

function UEFMainAirAttacks()
    local opai = nil
	local quantity = {}	-- Air Factories = [4, 5, 6] depending on the Difficulty
	local trigger = {}
	
	-- UEF general air template
	quantity = {4, 5, 6}
	local Builder = {
        BuilderName = 'M3_UEF_Main_AirForce_Builder',
        PlatoonTemplate = {
			'M3_UEF_Main_AirForce_Template',
			'NoPlan',
			{'uea0305', 0, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Heavy Gunship
			{'uea0304', 0, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Strat Bomber
			{'uea0303', 0, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 ASF
			{'uea0203', 0, quantity[Difficulty] * 2, 'Attack', 'AttackFormation'}, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 130,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEF_Main_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'}    
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
		
	-- Sends [8, 20, 36] Gunships if players have >= 50, 40, 30 Mobile Land units
	quantity = {4, 10, 18}
	trigger = {50, 40, 30}
	for i = 1, 2 do
	opai = UEFMainBase:AddOpAI('AirAttacks', 'M2_UEFMain_Gunships_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})
	end
	
	-- Builds [4, 10, 18] Strategic Bombers if players have >= 3, 2, 1 active SMLs, T3 Artillery, etc., and attacks said structures.
	quantity = {4, 10, 18}
	trigger = {3, 2, 1}
	opai = UEFMainBase:AddOpAI('AirAttacks', 'UEFMain_EndGameStructure_Hunters',
        {
			MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.GameEnderStructure,}
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.GameEnderStructure, '>='})
		
	-- Builds [4, 10, 18] Heavy Gunships if players have >= 3, 2, 1 active Land Experimental units, and attacks said Experimentals.
	quantity = {4, 10, 18}
	trigger = {3, 2, 1}
	opai = UEFMainBase:AddOpAI('AirAttacks', 'UEFMain_LandExperimental_Hunters',
        {
			MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalLand,}
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalLand, '>='})
		
	-- Builds, [8, 20, 36] Air Superiority Fighters if players have >= 3, 2, 1 active Air Experimental units, and attacks said Experimentals
	quantity = {8, 20, 36}
	trigger = {3, 2, 1}
	opai = UEFMainBase:AddOpAI('AirAttacks', 'UEFMain_AirExperimentals_Hunters',
        {
			MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalAir,}
			},
                Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalAir, '>='})
	
	-- Sends [4, 20, 54] Heavy Gunships if players have >= 100, 90, 80 active Land units.
	quantity = {4, 10, 18}
	trigger = {100, 90, 80}
	for i = 1, Difficulty do
	opai = UEFMainBase:AddOpAI('AirAttacks', 'M3_UEFMain_HeavyGunships_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},

                Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3})
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})
	end
end

function UEFMainLandAttacks()
    local opai = nil
	local quantity = {3, 6, 9}
	
	local EngineerPlatoonTemplate = {
		'UEF_Expansion_Engineer_Platoon_Template',
		'NoPlan',
		{'uel0309', 1, quantity[Difficulty], 'Support', 'AttackFormation'},	-- T3 Engineers
	}
	-- UEF Control Center Expansion Engineer platoon
	local Builder = {
        BuilderName = 'UEF_Black_Sun_Control_Center_Expansion_Engineers',
        PlatoonTemplate = EngineerPlatoonTemplate,
		InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
		LocationType = 'UEF_Main_Base',
		BuildConditions = {
            {BMBC, 'BaseActive', {'UEF_Control_Center_Base'}},
			{BMBC, 'NumUnitsLessNearBase', {'UEF_Control_Center_Base', (categories.FACTORY * categories.STRUCTURE), 1}},
        },
		PlatoonAIFunction = {CustomFunctions, 'EngineersMoveToThread'},
        PlatoonData = {
			MoveRoute = {'Control_Center_Rally'},
			DisbandAfterArrival = true,
		},
	}
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- UEF Main Naval Base Expansion Engineer platoon
	Builder = {
        BuilderName = 'UEF_Main_Base_Naval_Expansion_Engineers',
        PlatoonTemplate = EngineerPlatoonTemplate,
		InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
		LocationType = 'UEF_Main_Base',
		BuildConditions = {
            {BMBC, 'NumUnitsLessNearBase', {'UEF_Main_Naval_Base', (categories.FACTORY * categories.NAVAL * categories.STRUCTURE), 1}},
            {BMBC, 'BaseActive', {'UEF_Main_Naval_Base'}},
        },
		PlatoonAIFunction = {CustomFunctions, 'EngineersMoveToThread'},
        PlatoonData = {
			MoveRoute = {'UEF_Main_Naval_Base_Marker'},
			DisbandAfterArrival = true,
		},
	}
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- Sends random [T2] from Phase 2
	for i = 1, Difficulty do
		opai = UEFMainBase:AddOpAI('BasicLandAttack', 'M2_UEFMain_T2_LandAttack_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
				PlatoonData = {
					PatrolChain = 'M2LandAttack_Chain' .. Random(1, 5),
				},
				Priority = 140 + i, --Base gets cluttered with units too much if they all have the same priority.
			}
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileShields'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	end
	
	for i = 1, Difficulty * 3 do
		-- Sends random [T3] from Phase 3
		opai = UEFMainBase:AddOpAI('BasicLandAttack', 'M3_UEFMain_T3_LandAttack_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
				PlatoonData = {
					PatrolChain = 'M2LandAttack_Chain' .. Random(1, 5),
				},
				Priority = 150 + i, --Base gets cluttered with units too much if they all have the same priority.
			}
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3})
	end
end

function UEFMainNavalAttacks()
	local opai = nil
	local T3Quantity = {1, 2, 3}
	local T2Quantity = {2, 4, 6}
	local T1Quantity = {3, 6, 9}
	
	-- Massive UEF Naval Fleet for attacking the players
	local Temp = {
        'M3_UEF_Main_Naval_Attack_To_Player',
        'NoPlan',
        {'ues0302', 0, T3Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Battleship
        {'ues0201', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'ues0202', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'ues0103', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Frigate
		{'ues0203', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Submarine
    }
	local Builder = {
        BuilderName = 'M3_UEF_Main_Naval_Attack_To_Player',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEF_Main_Naval_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
		PlatoonData = {
            PatrolChain = 'M3_UEF_Main_Naval_Attack_Chain',
        },     
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- Smaller UEF Naval Fleet for attacking Arnold
	Temp = {
        'M3_UEF_Main_Naval_Attack_To_Aeon',
        'NoPlan',
        {'ues0201', 0, 2, 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'ues0202', 0, 2, 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'ues0103', 0, 3, 'Attack', 'AttackFormation'}, -- T1 Frigate
		{'ues0203', 0, 3, 'Attack', 'AttackFormation'}, -- T1 Submarine
    }
	
	Builder = {
        BuilderName = 'M3_UEF_Main_Naval_Attack_To_Aeon',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEF_Main_Naval_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {
				'M3_UEFToAeon_Naval_Chain',
				'M3_UEFMain_To_AeonSouthEast_Naval_Chain',
			},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- Small UEF Naval Fleet for attacking the players during, and after part 2
	Temp = {
        'M2_UEF_Main_Naval_Force',
        'NoPlan',
        {'ues0201', 0, Difficulty, 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'ues0202', 0, Difficulty, 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'ues0103', 0, Difficulty * 2, 'Attack', 'AttackFormation'}, -- T1 Frigate
    }
	
	Builder = {
        BuilderName = 'M2_UEF_Main_Naval_Force_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 90,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEF_Main_Naval_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {
				'M3_UEF_Main_Naval_Attack_Chain',
			},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- Atlantis attack for Phase 3
	opai = UEFNavalBase:AddOpAI('M3_UEFMain_Atlantis',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
				PatrolChain = 'M3_UEF_Main_Naval_Attack_Chain',
			},
			BuildCondition = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}}
			},
            MaxAssist = Difficulty,
            Retry = true,
        }
    )
end

-- Fatboy factory platoon 1 for Phase 2
function UEFMainFatboyFactory1()
	local opai = UEFMainBase:AddOpAI('M2_Fatboy_Factory',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddMobileFactory'},
            PlatoonData = {
				BaseName = 'MobileFactory1',
				BaseMarker = 'UEF_Mobile_Factory_Marker_1',
				BaseRadius = 20,
				FactoryType = 'Land',
				RallyPoint = 'UEF_Mobile_Factory_Rally_1',
				MoveRoute = {'MobileFactoryMove1'},
			},
			BuildCondition = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumber', {2}}
			},
            MaxAssist = 3,
            Retry = true,
        }
    )
end

-- Fatboy factory platoon 2 for Phase 2
function UEFMainFatboyFactory2()
	local opai = UEFMainBase:AddOpAI('M2_Fatboy_Factory',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddMobileFactory'},
            PlatoonData = {
				BaseName = 'MobileFactory2',
				BaseMarker = 'UEF_Mobile_Factory_Marker_2',
				BaseRadius = 20,
				FactoryType = 'Land',
				RallyPoint = 'UEF_Mobile_Factory_Rally_2',
				MoveRoute = {'MobileFactoryMove2'},
			},
			BuildCondition = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumber', {2}}
			},
            MaxAssist = 3,
            Retry = true,
        }
    )
end

-- General Experimental attacks
function UEFMainExperimentalAttacks()
    local opai = nil
	local quantity = {2, 4, 6}
	
	-- Single Fatboy with advanced behaviour
	opai = UEFMainBase:AddOpAI('M2_Fatboy_Factory',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {AIBehaviors, 'FatboyBehavior'},
            PlatoonData = {
				BuildTable = {
					'uel0202',	--T2 Heavy Tank
					'uel0205',	--T2 Mobile Flak
					'uel0111',	--T2 MML
					'uel0307', 	--T2 Mobile Shield
					'uel0303',	--T3 Siege Bot
					'uel0304', 	--T3 Mobile Heavy Artillery
				},
				Formation = 'AttackFormation',
				SitDistance = 300,
				UnitCount = quantity[Difficulty],
			},
			BuildCondition = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}}
			},
            MaxAssist = Difficulty,
            Retry = true,
        }
    )
	
	-- Send [1, 2, 3] Fatboys to the players
	for i = 1, Difficulty do
        opai = UEFMainBase:AddOpAI('M3_Fatboy_' .. i,
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'Fatboys',
                    NumRequired = Difficulty,
                    --PatrolChain = 'M3_UEF_Fatboy_Chain',
					PatrolChains = {
						'M2LandAttack_Chain1',
						'M2LandAttack_Chain2',
						'M2LandAttack_Chain3',
						'M2LandAttack_Chain4',
						'M2LandAttack_Chain5',
					},
				},
				BuildCondition = {
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}}
				},
                MaxAssist = Difficulty,
                Retry = true,
            }
        )
    end
end

function M3UEFSouthWesternBaseAI()
	---------------------------
    -- Southern UEF Island Base
    ---------------------------
    M3UEFSouthWesternBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_UEF_SouthWestern_Base', 'M3_UEF_SouthWestern_Base_Marker', 180,
		{
		M3_UEF_SouthWestern_Base = 450,
		}
	)
	
	M3UEFSouthWesternBase:StartNonZeroBase({4, 6, 8})
	M3UEFSouthWesternBase:SetMaximumConstructionEngineers(8)
	
	M3UEFSouthWesternBase:SetSupportACUCount(1)
	
	M3UEFSouthWesternBase:SetActive('AirScouting', true)
	-- Enable nukes
	M3UEFSouthWesternBase:SetActive('Nuke', true)
	
	M3UEFSouthWesternNavalAttacks()
	M3UEFSouthWesternLandAttacks()
	M3UEFSouthWesternTransportAttacks()
	M3UEFSouthWesternAirAttacks()
	M3UEFSouthWesternAirDefense()
	M3UEFSouthWesternExperimentalAttacks()
end

function M3UEFSouthWesternNavalAttacks()
	local opai = nil
	local T3Quantity = {1, 2, 3}
	local T2Quantity = {2, 4, 6}
	local T1Quantity = {3, 6, 9}
	
	-- Big UEF Naval Fleet for attacking the players
	local Temp = {
        'M3_UEF_SouthWestern_Naval_Attack_To_Player',
        'NoPlan',
        {'ues0302', 0, T3Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Battleship
        {'ues0201', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'ues0202', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'ues0103', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Frigate
		{'ues0203', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Submarine
	
    }
	local Builder = {
        BuilderName = 'M3_UEF_SouthWestern_Naval_Attack_To_Player',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_SouthWestern_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
		PlatoonData = {
            PatrolChain = 'M3_UEF_Southern_Naval_Attack_Chain',
        },     
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- Smaller UEF Naval Fleet for attacking Arnold
	Temp = {
        'M3_UEF_SouthWestern_Naval_Attack_To_Aeon',
        'NoPlan',
        {'ues0201', 0, 2, 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'ues0202', 0, 2, 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'ues0103', 0, 3, 'Attack', 'AttackFormation'}, -- T1 Frigate
		{'ues0203', 0, 3, 'Attack', 'AttackFormation'}, -- T1 Submarine
    }
	
	Builder = {
        BuilderName = 'M3_UEF_SouthWestern_Naval_Attack_To_Aeon',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_SouthWestern_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {
				'M3_UEFToAeon_Naval_Chain',
				'M3_UEFMain_To_AeonSouthEast_Naval_Chain'
			},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
end

function M3UEFSouthWesternLandAttacks()
	local opai = nil
	local quantity = {4, 8, 12}
	
	-- Sends [8, 16, 24] Amphibious Tanks to the highest threat
	for i = 1, 2  do
		opai = M3UEFSouthWesternBase:AddOpAI('BasicLandAttack', 'M3_UEFSouthWestern_Amphibious_Assault' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
				Priority = 140,
			}
		)
		opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
		opai:SetFormation('AttackFormation')
	end
end

function M3UEFSouthWesternTransportAttacks()
	local opai = nil
	local quantity = {2, 4, 6}
	
	-- T2 Transport Platoon
	-- The SW UEF base is the only one producing transport attacks, so we only need to check the amount of transports the army has
	local Builder = {
        BuilderName = 'M3_UEF_SouthWestern_Transport_Platoon',
        PlatoonTemplate = {
			'M3_UEF_SouthWestern_Transport_Platoon',
			'NoPlan',
			{'uea0104', 1, quantity[Difficulty], 'Attack', 'None'}, -- T2 Transport
		},
        InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_SouthWestern_Base',
		BuildConditions = {
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {12, categories.uea0104}},
		},
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- Sends random amounts of [T2]
	for i = 1, Difficulty + 1 do
		opai = M3UEFSouthWesternBase:AddOpAI('BasicLandAttack', 'M3_UEF_TransportAttacks_Northern_T2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M2LandAttack_Chain' .. Random(1, 5),
                    LandingChain = 'UEFBase_Landing_Chain',
                    TransportReturn = 'M3_UEF_SouthWestern_Base_Marker'
                },
                Priority = 150 + i,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'MobileShields'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {6, categories.uea0104})
	end
	
	-- Sends random amounts of [T3]
	for i = 1, Difficulty + 2 do	
		opai = M3UEFSouthWesternBase:AddOpAI('BasicLandAttack', 'M3_UEF_TransportAttacks_Northern_T3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M2LandAttack_Chain' .. Random(1, 5),
                    LandingChain = 'UEFBase_Landing_Chain',
                    TransportReturn = 'M3_UEF_SouthWestern_Base_Marker'
                },
                Priority = 160 + i,
            }
        )
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {6, categories.uea0104})
	end
end

function M3UEFSouthWesternAirAttacks()
    local opai = nil
	local quantity = {}
	local trigger = {}

	-- UEF general air template
	quantity = {2, 4, 6}
	local Builder = {
        BuilderName = 'M3_UEF_SouthWestern_AirForce_Builder',
        PlatoonTemplate = {
			'M3_UEF_SouthWestern_AirForce_Template',
			'NoPlan',
			{'uea0305', 0, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Heavy Gunship
			{'uea0304', 0, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Strat Bomber
			{'uea0303', 0, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 ASF
			{'uea0203', 0, quantity[Difficulty] * 2, 'Attack', 'AttackFormation'}, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_UEF_SouthWestern_Base',
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'}    
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
	
	-- Sends [6, 12, 18] Gunships to the players
	quantity = {6, 12, 18}
	opai = M3UEFSouthWesternBase:AddOpAI('AirAttacks', 'M3_UEFSouthWest_To_AeonNorth_Gunships_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Southern_Naval_Attack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	
	-- Sends [6, 12, 18] Torpedo Bombers to the players, if they have >= 15, 10, 5 naval units
	quantity = {6, 12, 18}
	trigger = {15, 10, 5}
	opai = M3UEFSouthWesternBase:AddOpAI('AirAttacks', 'M3_UEFSouthWest_To_AeonNorth_TorpedoBombers_Attack',
        {
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Southern_Naval_Attack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
		
	-- Builds, [8, 20, 36] Air Superiority Fighters if players have >= 3, 2, 1 active Air Experimental units, and attacks said Experimentals
	quantity = {8, 20, 36}
	trigger = {3, 2, 1}
	opai = M3UEFSouthWesternBase:AddOpAI('AirAttacks', 'M3_UEF_SouthEastern_AirExperimentals_Hunters',
        {
			MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalAir,}
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalAir, '>='})
		
	-- Builds [4, 10, 18] Heavy Gunships if players have >= 3, 2, 1 active Land Experimental units, and attacks said Experimentals.
	quantity = {4, 10, 18}
	trigger = {3, 2, 1}
	opai = M3UEFSouthWesternBase:AddOpAI('AirAttacks', 'M3_UEF_SouthEastern_LandExperimental_Hunters',
        {
			MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.ExperimentalLand,}
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.ExperimentalLand, '>='})
	
	-- Builds [4, 10, 18] Strategic Bombers if players have >= 3, 2, 1 active SMLs, T3 Artillery, etc., and attacks said structures.
	quantity = {4, 10, 18}
	trigger = {3, 2, 1}
	opai = M3UEFSouthWesternBase:AddOpAI('AirAttacks', 'M3_UEF_SouthEastern_EndGameStructure_Hunters',
        {
			MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
			PlatoonData = {
				CategoryList = {ConditionCategories.GameEnderStructure,}
			},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], ConditionCategories.GameEnderStructure, '>='})
end

function M3UEFSouthWesternAirDefense()
    local opai = nil
	local quantity = {2, 4, 6}	-- Air Factories = [2, 4, 6] depending on the Difficulty
	local ChildType = {'AirSuperiority', 'HeavyGunships', 'StratBombers'}
		
	-- Maintains [2, 4, 6] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = M3UEFSouthWesternBase:AddOpAI('AirAttacks', 'M3_UEF_SouthWestern_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'M3_UEF_SouthWestern_Base_Patrol_Chain',
				},
				Priority = 200 - k, -- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M3UEFSouthWesternExperimentalAttacks()
	local opai = nil
	local quantity = {1, 1, 2}
	
	-- Atlantis attack
	opai = M3UEFSouthWesternBase:AddOpAI('M3_UEF_SouthEastern_Atlantis',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
				PatrolChain = 'M3_UEF_Southern_Naval_Attack_Chain',
			},
			BuildCondition = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}}
			},
            MaxAssist = Difficulty,
            Retry = true,
        }
    )
end