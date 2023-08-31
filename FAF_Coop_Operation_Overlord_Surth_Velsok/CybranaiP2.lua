local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_CustomFunctions.lua'

local Player1 = 1
local Cybran = 3

local P2CBase1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P2C1Base1AI()

    P2CBase1:InitializeDifficultyTables(ArmyBrains[Cybran], 'P2CybranBase1', 'P2CB1MK', 80, {P2Cbase1 = 100})
    P2CBase1:StartNonZeroBase({{8, 11, 14}, {6, 9, 12}})
    P2CBase1:SetActive('AirScouting', true)

	P2CB1Airattacks()
	P2CB1Landattacks()
    P2CB1Navalattacks()	
    P2C1B1EXPattacks()
end

function P2CB1Airattacks()
    
    local quantity = {}

    quantity = {6, 7, 9}
    local Temp = {
       'P2CB1AttackTemp0',
       'NoPlan',
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P2CB1AttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2CybranBase1',
      PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2CB1AirPatrol'
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
    quantity = {6, 7, 9}
	Temp = {
       'P2CB1AttackTemp1',
       'NoPlan',
       { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P2CB1AttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 110,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2CybranBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2CB1Airattack1','P2CB1Airattack2', 'P2CB1Airattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
    quantity = {3, 4, 6}
	Temp = {
       'P2CB1AttackTemp2',
       'NoPlan',
       { 'ura0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P2CB1AttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 105,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2CybranBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2CB1Airattack1','P2CB1Airattack2', 'P2CB1Airattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P2CB1Landattacks()
	
    local quantity = {}

    quantity = {4, 5, 7}
	local Temp = {
       'P2CB1LAttackTemp0',
       'NoPlan',
       { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P2CB1LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2CybranBase1',
       PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P2CB1Landattack1', 'P2CB1Landattack2'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P2CybranBase1_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M2_Cybran_Eastern_Transport_Platoon',
        'NoPlan',
        { 'ura0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M2_Cybran_Eastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2CybranBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P2CybranBase1',
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    local Quantity2 = {2, 3, 4}
    Builder = {
        BuilderName = 'M2_Cybran_Land_Assault',
        PlatoonTemplate = {
            'M2_Cybran__Land_Assault_Template',
            'NoPlan',
            {'url0202', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'url0111', 1, Quantity2[Difficulty], 'Artillery', 'GrowthFormation'},    -- T2 Arty
        },
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2CybranBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1SB1Dropattack1',
            LandingChain = 'P1SB1Drop1',
            TransportReturn = 'P2CB1MK',
            BaseName = 'P2CybranBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P2CB1Navalattacks()

    local quantity = {}

    quantity = {2, 3, 4}
	local Temp = {
       'P2CB1NAttackTemp0',
       'NoPlan',
       { 'urs0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P2CB1NAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2CybranBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2CB1Navalattack1', 'P2CB1Navalattack2'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
    quantity = {2, 3, 4}
	Temp = {
       'P2CB1NAttackTemp1',
       'NoPlan',
       { 'urs0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'urs0201', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P2CB1NAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2CybranBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2CB1Navalattack1', 'P2CB1Navalattack2'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
    quantity = {2, 3, 4}
	Temp = {
       'P2CB1NAttackTemp2',
       'NoPlan',
       { 'urs0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'xrs0204', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P2CB1NAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2CybranBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2CB1Navalattack1', 'P2CB1Navalattack2'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P2C1B1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    trigger = {60, 50, 45}
    opai = P2CBase1:AddOpAI('P2Cbot',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P2CB1Landattack1', 'P2CB1Landattack2'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='},
                },
            }
        }
    )
end
