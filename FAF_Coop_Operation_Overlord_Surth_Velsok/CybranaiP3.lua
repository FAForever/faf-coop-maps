local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_CustomFunctions.lua'

local Player1 = 1
local Cybran = 3

local P3CBase1 = BaseManager.CreateBaseManager()
local P3CBase2 = BaseManager.CreateBaseManager()
local P4CBase1 = BaseManager.CreateBaseManager()
local P4CBase3 = BaseManager.CreateBaseManager()
local P4CBase4 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P3C1Base1AI()

    P3CBase1:Initialize(ArmyBrains[Cybran], 'P3CybranArty2', 'P3CB2MK', 40, {P3CArtyBase2 = 100})
    P3CBase1:StartNonZeroBase({1, 2, 3})
    P3CBase1:AddBuildGroup('P3CArtyBase2EXD', 100)
end

function P3C1Base2AI()

    P3CBase2:Initialize(ArmyBrains[Cybran], 'P3CybranArty3', 'P3CB3MK', 40, {P3CArtyBase3 = 100})
    P3CBase2:StartNonZeroBase({1, 2, 3})
    P3CBase2:AddBuildGroup('P3CArtyBase3EXD', 100)
end

function P4C1Base1AI()

    P4CBase1:InitializeDifficultyTables(ArmyBrains[Cybran], 'P4CybranBase1', 'P4CB1MK', 140, {P4Cbase1 = 100})
    P4CBase1:StartNonZeroBase({{14, 20, 27}, {11, 16, 22}})
    P4CBase1:SetActive('AirScouting', true)

    P4CB1Airattacks()
    P4CB1Landattacks()
    P4CB1Navalattacks()
    P4CB1EXPattacks()
end

function P4CB1Airattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}

    local Temp = {
        'P4CB1AttackTempPatrol',
        'NoPlan',
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P4CB1AttackBuilderPatrol',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P4CB1AirPatrol1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'P4CB1AttackTemp0',
       'NoPlan',
       { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P4CB1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4CB1Airattack1', 'P4CB1Airattack2', 'P4CB1Airattack3', 'P4CB1Airattack4'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder ) 

    quantity = {5, 8, 10}
    trigger = {30, 25, 20}
    Temp = {
        'P4CB1AttackTemp2',
        'NoPlan',
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P4CB1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 120,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4CB1Airattack1', 'P4CB1Airattack2', 'P4CB1Airattack3', 'P4CB1Airattack4'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder ) 

    quantity = {5, 10, 15}
    trigger = {30, 25, 20}
    Temp = {
        'P4CB1AttackTemp3',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P4CB1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4CB1Airattack1', 'P4CB1Airattack2', 'P4CB1Airattack3', 'P4CB1Airattack4'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder ) 

    quantity = {10, 15, 20}
    opai = P4CBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR},
            },
            Priority = 250,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.AIR, '>='})

    quantity = {5, 10, 15}
    opai = P4CBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P4CB1Landattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6}
    local Temp = {
       'P4CB1LAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P4CB1LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 8,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4CybranBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4CB1Landattack1', 'P4CB1Landattack2', 'P4CB1Landattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P4CybranBase1_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M4_Cybran_Eastern_Transport_Platoon',
        'NoPlan',
        { 'ura0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M4_Cybran_Eastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P4CybranBase1',
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    local Quantity2 = {2, 4, 6}
    Builder = {
        BuilderName = 'M4_Cybran_Land_Assault',
        PlatoonTemplate = {
            'M4_Cybran_Land_Assault_Template',
            'NoPlan',
            {'xrl0305', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'url0304', 1, Quantity2[Difficulty], 'Artillery', 'GrowthFormation'},    -- T2 Arty
        },
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {3, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P3U1Intlandingattack1',
            LandingChain = 'P3Slandingchain' .. Random(1, 3),
            TransportReturn = 'P4CB1MK',
            BaseName = 'P4CybranBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P4CB1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 5, 6}
    local Temp = {
        'P4C1B1NAttackTemp0',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P4CB1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P4CB1NavalattackSD',
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P4C1B1NAttackTemp1',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P4CB1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4CB1Navalattack1', 'P4CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'P4C1B1NAttackTemp2',
        'NoPlan',
        { 'urs0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P4CB1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 140,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4CybranBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.NAVAL * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4CB1Navalattack1', 'P4CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P4CB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {3, 4, 5}
    opai = P4CBase1:AddOpAI('Mega1',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P4CB1Landattack1', 'P4CB1Landattack2', 'P4CB1Landattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P4C1Base3AI()

    P4CBase3:InitializeDifficultyTables(ArmyBrains[Cybran], 'P4CybranBase3', 'P4CB3MK', 50, {P4Cbase3 = 100})
    P4CBase3:StartNonZeroBase({{5, 8, 10}, {4, 6, 8}})

    P4CB3Landattacks()
end

function P4CB3Landattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
       'P4CB3LAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P4CB3LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 8,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4CybranBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C1IntLandattack1', 'P3C1IntLandattack2', 'P3C1IntLandattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {15, 10, 5}
    Temp = {
       'P4CB3LAttackTemp1',
       'NoPlan',
       { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P4CB3LAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 110,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4CybranBase3',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C1IntLandattack1', 'P3C1IntLandattack2', 'P3C1IntLandattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {15, 10, 5}
    Temp = {
       'P4CB3LAttackTemp2',
       'NoPlan',
       { 'drlk001', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P4CB3LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 115,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4CybranBase3',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C1IntLandattack1', 'P3C1IntLandattack2', 'P3C1IntLandattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P4C1Base4AI()

    P4CBase4:InitializeDifficultyTables(ArmyBrains[Cybran], 'P4CybranBase4', 'P4CB4MK', 50, {P4Cbase4 = 100})
    P4CBase4:StartNonZeroBase({{5, 8, 10}, {4, 6, 8}})

    P4CB4Landattacks()
end

function P4CB4Landattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
       'P4CB4LAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation'}, 
    }
    local Builder = {
       BuilderName = 'P4CB4LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 8,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4CybranBase4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C1IntLandattack1', 'P3C1IntLandattack2', 'P3C1IntLandattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

        quantity = {4, 6, 8}
    trigger = {15, 10, 5}
    Temp = {
       'P4CB4LAttackTemp1',
       'NoPlan',
       { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P4CB4LAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 110,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4CybranBase4',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C1IntLandattack1', 'P3C1IntLandattack2', 'P3C1IntLandattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {15, 10, 5}
    Temp = {
       'P4CB4LAttackTemp2',
       'NoPlan',
       { 'drlk001', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P4CB4LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 115,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4CybranBase4',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C1IntLandattack1', 'P3C1IntLandattack2', 'P3C1IntLandattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end


