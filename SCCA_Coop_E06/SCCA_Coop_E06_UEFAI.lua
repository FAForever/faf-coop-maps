-----------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_E06/SCCA_Coop_E06_UEFAI.lua
--  Author(s): Dhomie42
--
--  Summary  : UEF (BlackSun) army AI for UEF Mission 6 - SCCA_Coop_E06
-----------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')  

---------
-- Locals
---------
local BlackSun = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local CustomFunctions = '/maps/scca_coop_e06/scca_coop_e06_customfunctions.lua'
local AIAttackUtils = '/maps/scca_coop_e06/scca_coop_e06_aiattackutilities.lua'
local AIBehaviors = '/maps/scca_coop_e06/scca_coop_e06_aibehaviors.lua'

----------------
-- Base Managers
----------------
local M3AikoSEBase = BaseManager.CreateBaseManager()

function M3AikoSEBaseAI()

	-- -----------
    -- Aiko Base
    -- -----------
    M3AikoSEBase:Initialize(ArmyBrains[BlackSun], 'M3_Aiko_SE_Base', 'M2_Aeon_SE_Base_Marker', 210,
		{
			M3_Aiko_SE_Base_FirstStructure = 150,
		}
	)
	
	-- Create a T3 Air Factory first, so we can pump out Engineers
	M3AikoSEBase:AddBuildGroup('M3_Aiko_SE_Base_D1' , 100)
	M3AikoSEBase:SetSupportACUCount(1)
	M3AikoSEBase:SetSACUUpgrades({'Shield', 'AdvancedCoolingUpgrade', 'ResourceAllocation'}, false)
	
	M3AikoSEBase:StartEmptyBase({16, 12, 8})
	M3AikoSEBase:SetMaximumConstructionEngineers(12)
	
	M3AikoSEBase:SetActive('AirScouting', true)
	ArmyBrains[BlackSun]:PBMSetCheckInterval(7)
	
	M3AikoSEBaseNavalAttacks()
	M3AikoSEBaseTransportAttacks()
	M3AikoSEBaseAirAttacks()
	M3AikoSEBaseAirDefense()
	M3AikoSEBaseExperimentalAttacks()
	M3AikoAirStagingBase()
end

-- No need to add a BaseManager instance for just some air staging platforms, create a simple building template, and an engineer platoon that will maintain it
function M3AikoAirStagingBase()
	-- Create the base template
	AIBuildStructures.CreateBuildingTemplate(ArmyBrains[BlackSun], 'Black_Sun', 'M3_Aiko_AirStaging_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[BlackSun], 'Black_Sun', 'M3_Aiko_AirStaging_Base', 'M3_Aiko_AirStaging_Base')
	
	-- Add the platoon to maintain the base
	local Builder = {
        BuilderName = 'M3_Aiko_AirStaging_Base_Engineers_Builder',
        PlatoonTemplate = {
			'M3_Aiko_T3_Engineer_Template',
			'NoPlan',
			{ 'uel0309', 1, 1, 'Attack', 'NoFormation' },	-- T3 Engineers
		},
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Any',
        RequiresConstruction = true,
        LocationType = 'M3_Aiko_SE_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'StartBaseEngineerThread'},
		PlatoonData = {
			MaintainBaseTemplate = 'M3_Aiko_AirStaging_Base',
			PatrolChain = 'BlackSun_M3_AirStaging_Island_Patrol_Chain',
        },     
    }
    ArmyBrains[BlackSun]:PBMAddPlatoon(Builder)
end

function M3AikoSEBaseNavalAttacks()
	local opai = nil
	local T3Quantity = {2, 1, 1}
	local T2Quantity = {4, 3, 2}
	local T1Quantity = {6, 5, 3}
	
	-- M3 Main Aiko Fleet for Phase 2
	local Temp = {
        'M3_Aiko_SouthEastern_Naval_Fleet',
        'NoPlan',
        { 'ues0302', 0, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
        { 'ues0201', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'ues0202', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'ues0103', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'ues0203', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	local Builder = {
        BuilderName = 'M3_Aiko_SouthEastern_Naval_Fleet_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_Aiko_SE_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {0, categories.ueb0303}},
		},
        PlatoonAIFunction = {AIAttackUtils, 'NavalForceAI'},
        PlatoonData = {
			PatrolChains = {
				'BlackSun_M3_Eastern_Naval_Chain',
				'BlackSun_M3_Western_Naval_Chain',
			},
			UseFormation = 'AttackFormation',
        },
		BuildTimeOut = 300, 
    }
    ArmyBrains[BlackSun]:PBMAddPlatoon(Builder)
	
	-- M3 Aiko Fleet for probe attacks
	Temp = {
        'M3_Aiko_SouthEastern_Naval_Probe_Attack',
        'NoPlan',
        { 'ues0201', 0, 2, 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'ues0202', 0, 2, 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'ues0103', 0, 3, 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'ues0203', 0, 3, 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	
	Builder = {
        BuilderName = 'M3_Aiko_SouthEastern_Naval_Probe_Attack_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_Aiko_SE_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
			{'/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {0, categories.ueb0303}},
		},
        PlatoonAIFunction = {AIAttackUtils, 'NavalForceAI'},
        PlatoonData = {
			PatrolChains = {
				'BlackSun_M3_Eastern_Naval_Chain',
				'BlackSun_M3_Western_Naval_Chain',
			},
			UseFormation = 'AttackFormation',
        },
		BuildTimeOut = 150,
    }
    ArmyBrains[BlackSun]:PBMAddPlatoon(Builder)
	
	
	-- Reclaim platoon
	Builder = {
        BuilderName = 'M3_Aiko_Reclaim_Engineers_Builder',
        PlatoonTemplate = {
			'M3_Aiko_T3_Reclaim_Engineer_Template',
			'NoPlan',
			{ 'uel0309', 1, 1, 'Attack', 'NoFormation' }, -- T3 Engineer
		},
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Any',
        RequiresConstruction = true,
        LocationType = 'M3_Aiko_SE_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
			{CustomFunctions, 'LessMassStorageCurrent', {8500}},
		},
        PlatoonAIFunction = {CustomFunctions, 'EngineerPlatoonReclaim'},     
    }
    ArmyBrains[BlackSun]:PBMAddPlatoon(Builder)
end

function M3AikoSEBaseTransportAttacks()
	local opai = nil
	local T3Quantity = {4, 3, 2}
	local T2Quantity = {5, 4, 3}
	local poolName = 'M3_Aiko_SE_Base_TransportPool'
	
	-- T2 Transport Platoon
	local Temp = {
        'M3_Aiko_SouthEastern_Transport_Platoon',
        'NoPlan',
        { 'uea0104', 1, 6, 'Attack', 'None' }, -- T2 Transport
    }
	local Builder = {
        BuilderName = 'M3_Aiko_SouthEastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Aiko_SE_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveLessThanUnitsInTransportPool', {12, poolName}},
		},
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
		PlatoonData = {
			BaseName = 'M3_Aiko_SE_Base',
		},
    }
    ArmyBrains[BlackSun]:PBMAddPlatoon(Builder)
	
	Builder = {
        BuilderName = 'M3_Aiko_Southern_Land_Assault',
        PlatoonTemplate = {
            'M3_Aiko_Southern_Land_Assault_Template',
            'NoPlan',
            {'uel0303', 1, T3Quantity[Difficulty], 'Attack', 'AttackFormation'},    -- T3 Siege Bot
            {'uel0304', 1, T3Quantity[Difficulty], 'Artillery', 'AttackFormation'}, -- T3 Artillery
            {'uel0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation'},    -- T2 Heavy Tank
            {'uel0205', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation'},    -- T2 Mobile AA
            {'uel0307', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M3_Aiko_SE_Base',
		BuildConditions = {
			{CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {6, poolName}},
		},
        PlatoonAIFunction = {AIAttackUtils, 'AttackForceAI'},       
        PlatoonData = {
            AttackChain = 'BlackSun_M3_Control_Center_Defense_Chain',
            LandingChain = 'Aeon_M2_Land_Assault_Landing_Chain',
            TransportReturn = 'M2_Aeon_SE_Base_Marker',
			BaseName = 'M3_Aiko_SE_Base',
			UseFormation = 'AttackFormation',
        },
    }
    ArmyBrains[BlackSun]:PBMAddPlatoon(Builder)
end

function M3AikoSEBaseAirAttacks()
    local opai = nil
	local quantity = {18, 15, 12}
	local trigger = {20, 25, 30}
		
	-- Sends [18, 12, 6] Air Superiority Fighters to enemies if they have >= 20, 25, 30 air units
	opai = M3AikoSEBase:AddOpAI('AirAttacks', 'M3_AikoSouthEastern_AirSuperiority_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'Cybran', 'Aeon'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
	
	-- Sends [18, 12, 6] Torpedo Bombers to enemies if they have >= 15, 10, 5 naval units
	trigger = {5, 10, 15}
	opai = M3AikoSEBase:AddOpAI('AirAttacks', 'M3_AikoSouthEastern_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'Cybran', 'Aeon'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
	
	-- Sends [18, 12, 6] Strategic Bombers to enemies
	opai = M3AikoSEBase:AddOpAI('AirAttacks', 'M3_AikoSouthEastern_StratBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3})
	
	-- Sends [18, 12, 6] Gunships to enemies
	opai = M3AikoSEBase:AddOpAI('AirAttacks', 'M3_AikoSouthEastern_Gunships_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	
	-- Sends [18, 12, 6] Heavy Gunships to enemies
	opai = M3AikoSEBase:AddOpAI('AirAttacks', 'M3_AikoSouthEastern_HeavyGunships_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
	
	-- Aiko general air template
	quantity = {6, 5, 4}
	local Builder = {
        BuilderName = 'M3_Aiko_Main_AirForce_Builder',
        PlatoonTemplate = {
			'M3_Aiko_Main_AirForce_Template',
			'NoPlan',
			{ 'uea0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Heavy Gunship
			{ 'uea0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Strat Bomber
			{ 'uea0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 ASF
			{ 'uea0203', 1, quantity[Difficulty] * 2, 'Attack', 'AttackFormation' }, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Aiko_SE_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'}
    }
    ArmyBrains[BlackSun]:PBMAddPlatoon(Builder)
end

function M3AikoSEBaseAirDefense()
    local opai = nil
	local quantity = {18, 15, 12}
	local ChildType = {'AirSuperiority', 'StratBombers', 'HeavyGunships', 'Gunships', 'Bombers', 'Interceptors'}
	
	-- Maintains [18, 15, 12] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = M3AikoSEBase:AddOpAI('AirAttacks', 'M3_Aiko_SouthEastern_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'BlackSun_M3_Island_Defense_Chain',
				},
				Priority = 200 - k,	-- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M3AikoSEBaseExperimentalAttacks()
	local opai = nil
	
	-- Atlantis patrols
	opai = M3AikoSEBase:AddOpAI('M3_Aiko_SE_Atlantis',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
				PatrolChains = {
					'BlackSun_M3_Eastern_Naval_Chain',
					'BlackSun_M3_Western_Naval_Chain',
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