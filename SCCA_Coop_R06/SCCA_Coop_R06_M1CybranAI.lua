------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R06/SCCA_Coop_R06_M1CybranAI.lua
--  Author(s): Dhomie42
--
--  Summary  : Cybran Debug army AI for Mission 1 - SCCA_Coop_R06
------------------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')

-- ------
-- Locals
-- ------
local Cybran = 5
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local CustomFunctions = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_CustomFunctions.lua'
-- -------------
-- Base Managers
-- -------------
local M1CybranDebugBase = BaseManager.CreateBaseManager()

function M1CybranDebugBaseAI()
	-- -----------
    -- Player1 Base
    -- -----------
    M1CybranDebugBase:Initialize(ArmyBrains[Cybran], 'M1_Cybran_Debug_Base', 'PlayerBase', 210,
		{
			Allied_Debug_Base_D1 = 250,
		}
	)
	
	M1CybranDebugBase:SetACUUpgrades({'CoolingUpgrade', 'MicrowaveLaserGenerator', 'CloakingGenerator'}, false)
	
	M1CybranDebugBase:StartEmptyBase({15, 14, 13})
	M1CybranDebugBase:SetMaximumConstructionEngineers(15)
	
    M1CybranDebugBase:SetActive('AirScouting', true)
	
	M1CybranDebugBaseLandAttacks()
	M1CybranDebugBaseAirAttacks()
	M1CybranDebugBaseNavaAttacks()
	M1CybranDebugBaseAirDefense()
	M1CybranDebugBaseExperimentals()
end

function M1CybranDebugBaseLandAttacks()
	local opai = nil
		
	-- Random compositions
	for i = 1, Difficulty + 1 do
		opai = M1CybranDebugBase:AddOpAI('BasicLandAttack', 'Cybran_Debug_T2_RandomLandAttack_' .. i,
        {
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M3_Allied_Land_Chain_' .. Random(1, 3),
			},     
            Priority = 150 + i,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks', 'MobileStealth'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
		
		opai = M1CybranDebugBase:AddOpAI('BasicLandAttack', 'Cybran_Debug_T3_RandomLandAttack_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Allied_Land_Chain_' .. Random(1, 3),
                },
            Priority = 120 + i,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
	end

end

function M1CybranDebugBaseAirAttacks()
	--Custom template, builds faster than the BaseManager's random template method
	local Builder = {
        BuilderName = 'M1_Cybran_Debug_AirForce_Builder',
        PlatoonTemplate = {
			'M1_Cybran_Debug_AirForce_Template',
			'NoPlan',
			{ 'ura0304', 1, 5, 'Attack', 'AttackFormation' }, -- T3 Strat Bomber
			{ 'ura0303', 1, 5, 'Attack', 'AttackFormation' }, -- T3 ASF
			{ 'ura0203', 1, 10, 'Attack', 'AttackFormation' }, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M1_Cybran_Debug_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
		PlatoonAddFunctions = {
			{SPAIFileName, 'PlatoonEnableStealth'},
		},
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function M1CybranDebugBaseNavaAttacks()
	local T3Quantity = {1, 2, 3}
	local T2Quantity = {2, 4, 6}
	local T1Quantity = {3, 6, 9}
	
	--Cybran Debug Naval Fleet
	local Temp = {
        'Cybran_Debug_Naval_Attacks',
        'NoPlan',
        { 'urs0302', 0, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
        { 'urs0201', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'urs0202', 0, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'urs0103', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'urs0203', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
	
    }
	local Builder = {
        BuilderName = 'Cybran_Debug_Naval_Attacks',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M1_Cybran_Debug_Base',
		BuildConditions = {
			{ '/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {
				'M1_Cybran_Naval_Chain_1',
				'M1_Cybran_Naval_Chain_2',
			},
        },     
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function M1CybranDebugBaseAirDefense()
    local opai = nil
	local quantity = {5, 10, 15}	-- Air Factories = 5 at all times
	local ChildType = {'AirSuperiority', 'StratBombers', 'Gunships'}
	
	-- Maintains [5, 10, 15] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = M1CybranDebugBase:AddOpAI('AirAttacks', 'M1_Cybran_Debug_AirDefense' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'Player_Base_Patrol_Chain',
				},
				Priority = 200 - k,	-- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	end
end

function M1CybranDebugBaseExperimentals()
	local opai = nil

	-- Sends [1-1, 2-2, 3-3] Spiderbots to the UEF Main Base
	for i = 1, 2 do
		for k = 1, Difficulty do
			opai = M1CybranDebugBase:AddOpAI('Allied_M3_Spiderbot_' .. k,
				{
					Amount = 1,
					KeepAlive = true,
					PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
					PlatoonData = {
						Name = 'Allied_M3_Spiderbot_Platoon_' .. i,
						NumRequired = Difficulty,
						PatrolChains = {
							'M3_Allied_Land_Chain_1',
							'M3_Allied_Land_Chain_2',
							'M3_Allied_Land_Chain_3',
						},
					},
					BuildCondition = {
						{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}}
					},
					MaxAssist = 3,
					Retry = true,
				}
			)
		end
    end
end

function EnableCybranDebugNukes()
	-- Enable nukes
	M1CybranDebugBase:SetActive('Nuke', true)
end