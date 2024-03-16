--------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R06/SCCA_Coop_R06_M3AeonAI.lua
--  Author(s): Dhomie42
--
--  Summary  : Aeon army AI for Mission 3 - SCCA_Coop_R06
--------------------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')

-- ------
-- Locals
-- ------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local CustomFunctions = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_CustomFunctions.lua'
local AIBehaviors = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_AIBehaviors.lua'
-- -------------
-- Base Managers
-- -------------
local M3AeonSouthEasternBase = BaseManager.CreateBaseManager()

function M3AeonSouthEasternBaseAI()

	-- -----------
    -- Aeon Base
    -- -----------
    M3AeonSouthEasternBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_SouthEastern_Base', 'M3_Aeon_SouthEastern_Base_Marker', 210,
		{
		M3_Aeon_Southern_Base = 450,
		}
	)
	
	M3AeonSouthEasternBase:StartNonZeroBase({3, 6, 10})
	M3AeonSouthEasternBase:SetMaximumConstructionEngineers(10)
	
	M3AeonSouthEasternBase:SetSupportACUCount(1)
	
	M3AeonSouthEasternBase:SetActive('AirScouting', true)
    M3AeonSouthEasternBase:SetActive('LandScouting', true)
	-- Enable nukes
	M3AeonSouthEasternBase:SetActive('Nuke', true)
	ArmyBrains[Aeon]:PBMSetCheckInterval(7)
	
	M3AeonSouthEasternNavalAttacks()
	M3AeonSouthEasternTransportAttacks()
	M3AeonSouthEasternAirAttacks()
	M3AeonSouthEasternAirDefense()
	M3AeonSouthEasternExperimentalAttacks()
end

function M3AeonSouthEasternNavalAttacks()
	local opai = nil
	local T3Quantity = {1, 1, 2}
	local T2Quantity = {2, 3, 4}
	local T1Quantity = {5, 4, 3}
	
	-- Medium Aeon Fleet for attacking the players
	local Temp = {
        'M3_Aeon_SouthEastern_Naval_Fleet',
        'NoPlan',
        {'uas0302', 0, T3Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Battleship
        {'uas0201', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'uas0202', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'uas0103', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Frigate
		{'uas0203', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Submarine
    }
	local Builder = {
        BuilderName = 'M3_Aeon_SouthEastern_Naval_Fleet_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {
			'M3_AeonSouthEast_To_Player_Naval_Chain1',
			--'M3_AeonSouthEast_To_Player_Naval_Chain2',	-- This one is too close to the UEF Main Base
			},
        },     
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	-- Smaller Aeon Fleet for attacking Aiko
	Temp = {
        'M3_Aeon_SouthEastern_Naval_Attack_To_UEF',
        'NoPlan',
        {'uas0201', 0, 2, 'Attack', 'AttackFormation'}, -- T2 Destroyer
        {'uas0202', 0, 2, 'Attack', 'AttackFormation'}, -- T2 Cruiser
		{'uas0103', 0, 3, 'Attack', 'AttackFormation'}, -- T1 Frigate
		{'uas0203', 0, 3, 'Attack', 'AttackFormation'}, -- T1 Submarine
    }
	
	Builder = {
        BuilderName = 'M3_Aeon_SouthEastern_Naval_Attack_To_UEF_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M3_AeonSouthEast_To_UEFMain_Naval_Chain1',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function M3AeonSouthEasternTransportAttacks()
	local opai = nil
	local quantity = {2, 4, 6}
	local T3Quantity = {1, 2, 3}
	local T2Quantity = {2, 3, 4}
	local poolName = 'M3_Aeon_SouthEastern_Base_TransportPool'
	
	-- T2 Transport Platoon
	local Temp = {
        'M3_Aeon_SouthEastern_Transport_Platoon',
        'NoPlan',
        {'uaa0104', 1, quantity[Difficulty], 'Attack', 'None'}, -- T2 Transport
    }
	local Builder = {
        BuilderName = 'M3_Aeon_SouthEastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveLessThanUnitsInTransportPool', {12, poolName}},
		},
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},
		PlatoonData = {
			BaseName = 'M3_Aeon_SouthEastern_Base',
		},
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Builder = {
        BuilderName = 'M3_Aeon_Southern_Land_Assault',
        PlatoonTemplate = {
            'M3_Aeon_Southern_Land_Assault_Template',
            'NoPlan',
            {'ual0303', 1, T3Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Siege Bot
            {'ual0304', 1, T3Quantity[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Artillery
            {'ual0202', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Heavy Tank
            {'ual0205', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile AA
            {'ual0307', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {6, poolName}},
		},
        PlatoonAIFunction = {SPAIFileName, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'Aeon_AttackChain',
            LandingChain = 'M2_Aeon_Landing_Chain',
            TransportReturn = 'M3_Aeon_SouthEastern_Base_Marker',
			BaseName = 'M3_Aeon_SouthEastern_Base',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Builder = {
        BuilderName = 'M3_Aeon_Southern_Land_Sweepers',
        PlatoonTemplate = {
            'M3_Aeon_Southern_Land_Sweepers_Template',
            'NoPlan',
            {'ual0303', 1, T3Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Siege Bot
            {'ual0304', 1, T3Quantity[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Artillery
            {'ual0202', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Heavy Tank
            {'ual0205', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile AA
            {'ual0307', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {6, poolName}},
		},
        PlatoonAIFunction = {SPAIFileName, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'ControlCenterBig_Chain',
            LandingChain = 'M2_Aeon_Landing_Chain',
            TransportReturn = 'M3_Aeon_SouthEastern_Base_Marker',
			BaseName = 'M3_Aeon_SouthEastern_Base',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function M3AeonSouthEasternAirAttacks()
    local opai = nil
	local quantity = {6, 12, 18}
	local trigger = {30, 25, 20}
		
	-- Sends [12, 24, 36] Air Superiority Fighters to players if they have >= 30, 25, 20 air units
	for i = 1, 2 do
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_AeonSouthEastern_AirSuperiority_Attack' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_AeonSouthEast_To_Player_Naval_Chain1',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
	end
	
	-- Sends [6, 12, 18] Torpedo Bombers to players if they have >= 15, 10, 5 naval units
	trigger = {15, 10, 5}
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_AeonSouthEastern_Gunships_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_AeonSouthEast_To_Player_Naval_Chain1',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
	
	-- Sends [6, 12, 18] Strategic Bombers to players
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_AeonSouthEastern_StratBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_AeonSouthEast_To_Player_Naval_Chain1',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	
	-- Sends [6, 12, 18] Gunships to players
	opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_AeonSouthEastern_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_AeonSouthEast_To_Player_Naval_Chain1',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	
	-- Aeon general air template
	quantity = {4, 5, 6}
	local Builder = {
        BuilderName = 'M3_Aeon_Main_AirForce_Builder',
        PlatoonTemplate = {
			'M3_Aeon_Main_AirForce_Template',
			'NoPlan',
			{'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Strat Bomber
			{'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 ASF
			{'uaa0203', 1, quantity[Difficulty] * 2, 'Attack', 'AttackFormation'}, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Aeon_SouthEastern_Base',
		BuildConditions = {
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'}    
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function M3AeonSouthEasternAirDefense()
    local opai = nil
	local quantity = {2, 4, 6}	-- Air Factories = [2, 4, 6] depending on the Difficulty
	local ChildType = {'AirSuperiority', 'StratBombers', 'Gunships'}
	
	-- Maintains [2, 4, 6] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = M3AeonSouthEasternBase:AddOpAI('AirAttacks', 'M3_Aeon_SouthEastern_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'M3_Aeon_SouthEastern_Base_Patrol_Chain',
				},
				Priority = 200 - k,	-- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M3AeonSouthEasternExperimentalAttacks()
	local opai = nil
	local quantity = {2, 3, 4}
	
	-- Tempest with advanced behaviour
	opai = M3AeonSouthEasternBase:AddOpAI('M3_Aeon_South_Eastern_Tempest',
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
				UnitCount = quantity[Difficulty],
			},
            MaxAssist = Difficulty,
            Retry = true,
        }
    )
	
	-- GCs to guard the base
	quantity = {1, 1, 2}
    opai = M3AeonSouthEasternBase:AddOpAI('M3_Aeon_South_Western_GC',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Aeon_SouthEastern_Base_Patrol_Chain',
            },
            MaxAssist = Difficulty,
            Retry = true,
        }
    )
end