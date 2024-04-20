------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_E06/SCCA_Coop_E06_CybranAI.lua
--  Author(s): Dhomie42
--
--  Summary  : Cybran army AI for Mission 1 - SCCA_Coop_E06
------------------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')

-- ------
-- Locals
-- ------
local Cybran = 4
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local CustomFunctions = '/maps/scca_coop_e06/scca_coop_e06_customfunctions.lua'

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
local M3CybranBase = BaseManager.CreateBaseManager()
-- We need an Eastern naval base as well, so we can attack players from both sides of the main island
local M3CybranNavalBase = BaseManager.CreateBaseManager()

function M3AddHLRA()
	M3CybranBase:AddBuildGroup('M3_Cybran_HLRA', 50)
end

function M3AddNukePlatoon()
	local Builder = {
        BuilderName = 'Cybran_NukePlatoon_Builder',
        PlatoonTemplate = {
            'Cybran_NukeTemplate',
            'NoPlan',
            { 'urb2305', 1, 1, 'Attack', 'None' },
        },
        Priority = 100,
        PlatoonType = 'Any',
        RequiresConstruction = false,
        PlatoonAIFunction = {CustomFunctions, 'NukePlatoon'},
    }
    ArmyBrains[Cybran]:PBMAddPlatoon(Builder)
end

-- Original mission layout had these bases as off-map ones, with only factories, intel and eco structures, and other misc, so the bare essentials
-- For performance reasons, we use the essentials as the foundation of the base
-- If the players want full access of the map via a lobby option, we add the defenses and other misc
function M3CybranBaseAI()
	-- -----------------
    -- M3 Cybran Base AI
    -- -----------------
	
    M3CybranBase:Initialize(ArmyBrains[Cybran], 'M3_Cybran_Base', 'M3_Cybran_Base_Marker', 130,
		{
			M3_Cybran_Base_Essentials = 100,
		}
	)
	M3CybranBase:SetSupportACUCount(1)
	M3CybranBase:SetSACUUpgrades({'NaniteMissileSystem', 'ResourceAllocation', 'Switchback'}, false)
	M3CybranBase:SetConstructionAlwaysAssist(true)
	
	M3CybranBase:StartNonZeroBase({9, 15, 21})
	M3CybranBase:SetMaximumConstructionEngineers(15)
	M3CybranBase:SetDefaultEngineerPatrolChain('M3_Cybran_Base_Engineer_Patrol_Chain')
	ArmyBrains[Cybran]:PBMSetCheckInterval(7)
	
    M3CybranBase:SetActive('AirScouting', true)
	
	-- Additional stuff if players chose full map access in the lobby
	if ScenarioInfo.Options.FullMapAccess == 2 then
		M3CybranBase:AddBuildGroup('M3_Cybran_Base_D' .. Difficulty, 90)
		M3CybranBaseAirDefense()
	end
	M3CybranBaseLandAttacks()
	M3CybranBaseAirAttacks()
	M3CybranBaseNavalAttacks()
	M3CybranBaseExperimentals()
end

function M3CybranNavalBaseAI()
	-- --------------------
    -- M3 Cybran Naval Base
    -- --------------------
	
	M3CybranNavalBase:Initialize(ArmyBrains[Cybran], 'M3_Cybran_Eastern_Naval_Base', 'M3_Cybran_Eastern_Naval_Base_Marker', 75,
		{
			M3_Cybran_Eastern_Naval_Base = 100,
		}
	)
	
	M3CybranNavalBase:StartNonZeroBase({2, 4, 6})
	M3CybranNavalBase:SetMaximumConstructionEngineers(4)
	
	M3CybranEasternBaseNavalAttacks()
end

function M3CybranBaseLandAttacks()
	local opai = nil
	local DirectQuantity = {2, 4, 6}
	local ArtilleryQuantity = {1, 2, 3}
	local SupportQuantity = {1, 1, 2}
		
	-- Random compositions
	for i = 1, Difficulty + 2 do
		opai = M3CybranBase:AddOpAI('BasicLandAttack', 'M3_Cybran_T2_RandomLandAttack_' .. i,
        {
			MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'Cybran_M3_Attack_Two_Land_G1_Chain',
					'Cybran_M3_Attack_Two_Land_G2_Chain',
					'Cybran_M3_Attack_Two_Spider1_Chain',
					'Cybran_M3_Attack_Two_Spider2_Chain',
					'Cybran_M3_Attack_Two_Spider3_Chain',
				},
			},
            Priority = 100 + i,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'MobileFlak', 'MobileMissiles', 'HeavyTanks', 'AmphibiousTanks'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
		
		opai = M3CybranBase:AddOpAI('BasicLandAttack', 'M3_Cybran_T3_RandomLandAttack_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'Cybran_M3_Attack_Two_Land_G1_Chain',
					'Cybran_M3_Attack_Two_Land_G2_Chain',
					'Cybran_M3_Attack_Two_Spider1_Chain',
					'Cybran_M3_Attack_Two_Spider2_Chain',
					'Cybran_M3_Attack_Two_Spider3_Chain',
				},
			},
            Priority = 100 + i,
        }
		)
		opai:SetChildActive('All', false)
		opai:SetChildrenActive({'SiegeBots', 'MobileHeavyArtillery'})
		opai:SetChildCount(Difficulty)
		opai:SetFormation('AttackFormation')
		opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	end
	
	-- Generic platoon of mixed composition
	local Builder = {
        BuilderName = 'M3_Cybran_Main_Land_Assault_Builder',
        PlatoonTemplate = {
            'M3_Cybran_Main_Land_Assault_Platoon',
            'NoPlan',
            {'url0303', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation'},    	-- T3 Siege Bot
            {'url0304', 1, ArtilleryQuantity[Difficulty], 'Artillery', 'AttackFormation'}, 	-- T3 Mobile Heavy Artillery
            {'url0202', 1, DirectQuantity[Difficulty], 'Attack', 'AttackFormation'},    	-- T2 Heavy Tank
			{'url0111', 1, ArtilleryQuantity[Difficulty], 'Artillery', 'AttackFormation'},    	-- T2 Mobile Missile Launcher
			{'url0205', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'},   	-- T2 Mobile AA
            {'url0306', 1, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'},    	-- T2 Stealth
        },
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M3_Cybran_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
			PatrolChains = {
				'Cybran_M3_Attack_Two_Land_G1_Chain',
				'Cybran_M3_Attack_Two_Land_G2_Chain',
				'Cybran_M3_Attack_Two_Spider1_Chain',
				'Cybran_M3_Attack_Two_Spider2_Chain',
				'Cybran_M3_Attack_Two_Spider3_Chain',
			},
		},     
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

end

function M3CybranBaseAirAttacks()
	local quantity = {6, 12, 18}
	local trigger = {30, 25, 20}

	-- Sends [6, 12, 18] Air Superiority Fighters to players if they have >= 30, 25, 20 air units
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_AirSuperiority_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')

	-- Sends [6, 12, 18] Torpedo Bombers to players if they have >= 15, 10, 5 naval units
	trigger = {15, 10, 5}
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_TorpedoBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
	
	-- Sends [6, 12, 18] Strategic Bombers to players
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_StratBombers_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3})
	opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')

	-- Sends [6, 12, 18] Gunships to players
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_Gunships_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

	-- Sends [6, 12, 18] Bombers to players
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_Bomber_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

	-- Sends [6, 12, 18] Bombers to players
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_Interceptor_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

	-- Builds [6, 9, 12] Strategic Bombers if players have >= 3, 2, 1 active SMLs, T3 Artillery, etc., and attacks said structures.
	quantity = {6, 9, 12}
	trigger = {3, 2, 1}
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_GameEnderStructure_Hunters',
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

	-- Builds [6, 9, 12] Strategic Bombers if players have >= 3, 2, 1 active Land Experimental units, and attacks said Experimentals.
	quantity = {6, 9, 12}
	trigger = {3, 2, 1}
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_LandExperimental_Hunters',
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
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_MassedAir_Hunters',
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

	-- Cybran generic filler Air platoon
	local Builder = {
        BuilderName = 'M3_Cybran_AirForce_Builder',
        PlatoonTemplate = {
			'M3_Cybran_AirForce_Template',
			'NoPlan',
			{ 'ura0304', 1, 6, 'Attack', 'AttackFormation' }, -- T3 Strat Bomber
			{ 'ura0303', 1, 6, 'Attack', 'AttackFormation' }, -- T3 ASF
			{ 'ura0203', 1, 12, 'Attack', 'AttackFormation' }, -- T2 Gunship
		},
        InstanceCount = Difficulty * 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Cybran_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
		PlatoonAddFunctions = {
			{SPAIFileName, 'PlatoonEnableStealth'},
		},
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function M3CybranBaseNavalAttacks()
	local T3Quantity = {1, 2, 3}
	local T2Quantity = {2, 4, 6}
	local T1Quantity = {3, 6, 9}
	local Temp
	local Builder
	
	-- Probing Cybran Fleet to let the players know of the off-map Cybran base
	opai = M3CybranBase:AddOpAI('NavalAttacks', 'M3_Cybran_Probe_Fleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'Aeon_M3_Attack_Three_Navy_G1_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, {6, 3})
	
	-- Large Naval Fleet only enabled for full map access
	if ScenarioInfo.Options.FullMapAccess == 2 then
		-- Large Naval Fleet
		Temp = {
			'M3_Cybran_Western_Naval_Fleet',
			'NoPlan',
			{ 'urs0302', 1, T3Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T3 Battleship
			{ 'urs0201', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Destroyer
			{ 'urs0202', 1, T2Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Cruiser
			{ 'urs0103', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Frigate
			{ 'urs0203', 1, T1Quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T1 Submarine
		}
		Builder = {
			BuilderName = 'M3_Cybran_Western_Naval_Fleet_Builder',
			PlatoonTemplate = Temp,
			InstanceCount = Difficulty,
			Priority = 110,
			PlatoonType = 'Sea',
			RequiresConstruction = true,
			LocationType = 'M3_Cybran_Base',
			BuildConditions = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {4}},
			},
			PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'Aeon_M3_Attack_Three_Navy_G1_Chain',
				},
			},     
		}
		ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	end
	
	-- Small Naval Fleet
	Temp = {
        'M3_Cybran_Western_Naval_Attack_Force_Template',
        'NoPlan',
        { 'urs0201', 1, 2, 'Attack', 'AttackFormation' }, -- T2 Destroyer
        { 'urs0202', 1, 1, 'Attack', 'AttackFormation' }, -- T2 Cruiser
		{ 'urs0103', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Frigate
		{ 'urs0203', 1, 3, 'Attack', 'AttackFormation' }, -- T1 Submarine
    }
	Builder = {
        BuilderName = 'M3_Cybran_Western_Naval_Attack_Force_Builder',
        PlatoonTemplate = Temp,
        InstanceCount = Difficulty,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M3_Cybran_Base',
		BuildConditions = {
			{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
		},
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
		PlatoonData = {
            PatrolChains = {
				'Aeon_M3_Attack_Three_Navy_G1_Chain',
			},
        },     
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function M3CybranBaseAirDefense()
    local opai = nil
	local quantity = {6, 12, 18}
	local ChildType = {'AirSuperiority', 'StratBombers', 'Gunships'}
	
	-- Maintains [6, 12, 18] units defined in ChildType
	for k = 1, table.getn(ChildType) do
		opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_AirDefense_' .. ChildType[k],
			{
				MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
				PlatoonData = {
					PatrolChain = 'Cybran_BasePatrolChain',
				},
				Priority = 200 - k,	-- ASFs are first
			}
		)
		opai:SetChildQuantity(ChildType[k], quantity[Difficulty])
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
		opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')
	end
	
	-- Extra ASF defense platoon to counter player Aerial assaults
	opai = M3CybranBase:AddOpAI('AirAttacks', 'M3_Cybran_Extra_AirDefense_AirSuperiority' ,
		{
			MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
			PlatoonData = {
				PatrolChain = 'Cybran_BasePatrolChain',
			},
			Priority = 200,
		}
	)
	opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
	opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
	opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')
	
	-- Maintains [2, 3, 4] Soul Rippers for defense
	opai = M3CybranBase:AddOpAI('M3_Cybran_Soul_Ripper_Defense',
		{
			Amount = Difficulty + 1,
			KeepAlive = true,
			FormCallbacks = {
				{SPAIFileName, 'PlatoonEnableStealth'},
			},
			PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
			PlatoonData = {
				PatrolChain = 'Cybran_BasePatrolChain',
			},
			BuildCondition = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}}
			},
			MaxAssist = Difficulty * 2,
			Retry = true,
		}
	)
end

function M3CybranBaseExperimentals()
	local opai = nil
	local quantity = {1, 1, 2}
	
	-- Sends [1, 1, 2] Soul Rippers to Black Sun
	for i = 1, quantity[Difficulty] do
		opai = M3CybranBase:AddOpAI('M3_Cybran_Soul_Ripper_' .. i,
			{
				Amount = 1,
				KeepAlive = true,
				FormCallbacks = {
					{SPAIFileName, 'PlatoonEnableStealth'},
				},
				PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
				PlatoonData = {
					Name = 'M3_Cybran_Soul_Ripper_Platoon',
					NumRequired = quantity[Difficulty],
					PatrolChains = {
						'Cybran_M3_Attack_Two_Land_G1_Chain',
						'Cybran_M3_Attack_One_Dest_Chain',
						'Cybran_M2_Spider_Air_Chain',
						'Cybran_M3_Attack_Two_Air_Chain',
						'Cybran_M3_Attack_Three_Air_G2_Chain',
					},
				},
				BuildCondition = {
					{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}}
				},
				MaxAssist = Difficulty * 2,
				Retry = true,
			}
		)
	end
	
	-- Engineer platoons that will build additional Soul Rippers, and Monkeylords for attacking
	-- Each engie platoon maintains 1 instance, then patrols the defined chain
	-- They can build an experimental platoon of more than 1 units, however if 1 or more dies, they won't be rebuilt until the entire experimental platoon has been killed
	-- Whatever units remain from the experimental platoon will be formed, and call their AI function
	
	--- NOTE: EngineerAttack_save.lua lacks a T3 Engineer platoon template, it only has one that also has Mobile Shields with it, so I'm using a manual PBM Builder instead for now
	--[[for i = 1, quantity[Difficulty] do
		opai = M3CybranBase:AddOpAI('EngineerAttack', 'M3_Cybran_Base_Soul_Ripper_Builders_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'EngineersBuildPlatoon'},
				PlatoonData = {
					PlatoonsTable = {
						ExperimentalAirTable = {
							PlatoonName = 'M3_Cybran_Soul_Ripper_Extra_' .. i,				-- Group name defined in the save.lua file, not a platoon-unique name, can include multiple units
							PlatoonAIFunction = {CustomFunctions, 'AdvancedPatrolThread'},	-- AI thread for the built platoon
							PlatoonAddFunctions = {
								{SPAIFileName, 'PlatoonEnableStealth'},						-- Fork an additional function that enables Stealth on the Soul Rippers
							},
							PlatoonData = {
								PatrolChain = 'Cybran_AttackChain',
							},
						},
						ExperimentalLandTable = {
							PlatoonName = 'M3_Cybran_Spiderbot_Extra_' .. i,				-- Group name defined in the save.lua file, not a platoon-unique name, can include multiple units
							PlatoonAIFunction = {CustomFunctions, 'AdvancedPatrolThread'},	-- AI thread for the built platoon
							PlatoonData = {
								PatrolChain = 'Cybran_AttackChain',
							},
						},
					},
					PatrolChain = 'M3_Cybran_Base_Engineer_Patrol_Chain', -- Engineer platoon will patrol this chain if they have no platoons to build
				},
				Priority = 250,
			}
		)
		opai:SetChildQuantity('T3Engineers', Difficulty)
		--opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})
	end]]
	
	for i = 1, quantity[Difficulty] do
		local Builder = {
			BuilderName = 'M3_Cybran_Soul_Ripper_Extra_Engineers_Builder_' .. i ,
			PlatoonTemplate = {
				'M3_Cybran_Soul_Ripper_Extra_Engineers_Builder_Template',
				'NoPlan',
				{ 'url0309', 2, 2, 'Attack', 'NoFormation' },	-- T3 Engineers
			},
			InstanceCount = 1,
			Priority = 250,
			PlatoonType = 'Any',
			RequiresConstruction = true,
			LocationType = 'M3_Cybran_Base',
			BuildConditions = {
				{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}}
			},
			PlatoonAIFunction = {CustomFunctions, 'EngineersBuildPlatoon'},
			PlatoonData = {
				PlatoonsTable = {
					ExperimentalAirTable = {
						PlatoonName = 'M3_Cybran_Soul_Ripper_Extra_' .. i,				-- Group name defined in the save.lua file, not a platoon-unique name, can include multiple units
						PlatoonAIFunction = {CustomFunctions, 'AdvancedPatrolThread'},	-- AI thread for the built platoon
						PlatoonAddFunctions = {
							{SPAIFileName, 'PlatoonEnableStealth'},						-- Fork an additional function that enables Stealth on the Soul Rippers
						},
						PlatoonData = {
							PatrolChain = 'Cybran_AttackChain',
						},
					},
					ExperimentalLandTable = {
						PlatoonName = 'M3_Cybran_Spiderbot_Extra_' .. i,				-- Group name defined in the save.lua file, not a platoon-unique name, can include multiple units
						PlatoonAIFunction = {CustomFunctions, 'AdvancedPatrolThread'},	-- AI thread for the built platoon
						PlatoonData = {
							PatrolChain = 'Cybran_AttackChain',
						},
					},
				},
				PatrolChain = 'M3_Cybran_Base_Engineer_Patrol_Chain', -- Engineer platoon will patrol this chain if they have no platoons to build
			},
		}
		ArmyBrains[Cybran]:PBMAddPlatoon(Builder)
	end
	
	-- Sends [1, 2-2, 3-3-3] Spiderbots to Black Sun
	for i = 1, Difficulty do
		for k = 1, Difficulty do
			opai = M3CybranBase:AddOpAI('M3_Cybran_Monkeylord_' .. k,
				{
					Amount = 1,
					KeepAlive = true,
					PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
					PlatoonData = {
						Name = 'M3_Cybran_Spiderbot_Platoon_' .. i,
						NumRequired = Difficulty,
						PatrolChains = {
							'Cybran_M3_Attack_Two_Land_G1_Chain',
							'Cybran_M3_Attack_Two_Land_G2_Chain',
							'Cybran_M3_Attack_Two_Spider1_Chain',
							'Cybran_M3_Attack_Two_Spider2_Chain',
							'Cybran_M3_Attack_Two_Spider3_Chain',
						},
					},
					BuildCondition = {
						{'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}}
					},
					MaxAssist = Difficulty * 2,
					Retry = true,
				}
			)
		end
    end
end

function M3CybranEasternBaseNavalAttacks()
	local opai = nil
    local quantity = {}
	
	quantity = {{4, 2}, {6, 3}, {12, 6}}
    opai = M3CybranNavalBase:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Cybran_Eastern_Naval_Attack_Chain',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})

	quantity = {{1, 2}, {2, 4}, {3, 6}}
    opai = M3CybranNavalBase:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Cybran_Eastern_Naval_Attack_Chain',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})

    quantity = {3, 6, 9}
    opai = M3CybranNavalBase:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Cybran_Eastern_Naval_Attack_Chain',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Destroyers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3})

    quantity = {{2, 1}, {4, 2, 4}, {6, 3, 6}}
    opai = M3CybranNavalBase:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Cybran_Eastern_Naval_Attack_Chain',
                },
            },
            Priority = 150,
        }
    )
    if Difficulty >= 2 then
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Submarines'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers'}, quantity[Difficulty])
    end
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2})

	quantity = {{1, 2}, {1, 4}, {2, 6}}
    opai = M3CybranNavalBase:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Cybran_Eastern_Naval_Attack_Chain',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3})

    opai = M3CybranNavalBase:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Cybran_Eastern_Naval_Attack_Chain',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Battleships', 3)
	opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3})
end