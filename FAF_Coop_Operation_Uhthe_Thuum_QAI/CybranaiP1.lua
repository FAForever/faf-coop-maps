local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua'

local Player1 = 1
local Cybran1 = 2
local Cybran2 = 5

local C1P1Base1 = BaseManager.CreateBaseManager()
local C1P1Base2 = BaseManager.CreateBaseManager()
local C2P1Base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

--Cybran Base 1

function P1C1base1AI()

    C1P1Base1:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P1Cybran1Base1', 'P1C1B1MK', 80, {P1C1base1 = 500})
    C1P1Base1:StartNonZeroBase({{7, 9, 12}, {5, 7, 10}})

    P1C1B1Airattacks()
    P1C1B1Landattacks()    
end

function P1C1B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 2, 3} 
    trigger = {15, 20, 18}
    local Temp = {
        'P1C1B1AAttackTemp0',
        'NoPlan',  
        { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P1C1B1AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 6, 9}
    trigger = {10, 7, 6}
    Temp = {
        'P1C1B1AAttackTemp1',
        'NoPlan',
        { 'ura0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 5, 6}
    trigger = {10, 8, 6}
    Temp = {
        'P1C1B1AAttackTemp2',
        'NoPlan',
        { 'xra0105', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    Temp = {
        'P1C1B1AAttackTemp3',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C1B1Airpatrol1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder ) 

    quantity = {2, 4, 5}
    trigger = {11, 9, 7}
    Temp = {
        'P1C1B1AAttackTemp4',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 9}
    trigger = {30, 20, 15}
    Temp = {
        'P1C1B1AAttackTemp5',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {3, 6, 9}
    trigger = {10, 7, 6}
    Temp = {
        'P1C1B1AAttackTemp6',
        'NoPlan',
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

function P1C1B1Landattacks()

    local opai = nil
    local trigger = {}
    local poolName = 'P1Cybran1Base1_TransportPool'
    
    local Tquantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M1_UEF_SouthEastern_Transport_Platoon',
        'NoPlan',
        { 'ura0104', 1, Tquantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M1_UEFSouthEastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {Tquantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P1Cybran1Base1',
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    local Quantity = {4, 7, 10}
    trigger = {25, 20, 15}
    Builder = {
        BuilderName = 'M1_Cybran_TransportAttack_1',
        PlatoonTemplate = {
            'M1_Cybran_TransportAttack_1_Template',
            'NoPlan',
            {'url0106', 1, Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 bot
        },
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1C1B1dropattack1',
            LandingChain = 'P1C1B1drop1',
            TransportReturn = 'P1C1B1MK',
            BaseName = 'P1Cybran1Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    local Quantity = {4, 7, 10}
    trigger = {40, 35, 30}
    Builder = {
        BuilderName = 'M1_Cybran_TransportAttack_2',
        PlatoonTemplate = {
            'M1_Cybran_TransportAttack_2_Template',
            'NoPlan',
            {'url0107', 1, Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Tank
        },
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1C1B1dropattack1',
            LandingChain = 'P1C1B1drop1',
            TransportReturn = 'P1C1B1MK',
            BaseName = 'P1Cybran1Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    local Quantity = {4, 7, 10}
    trigger = {40, 35, 35}
    Builder = {
        BuilderName = 'M1_Cybran_TransportAttack_3',
        PlatoonTemplate = {
            'M1_Cybran_TransportAttack_3_Template',
            'NoPlan',
            {'url0107', 1, Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Tank
        },
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1C1B1dropattack2',
            LandingChain = 'P1C1B1drop2',
            TransportReturn = 'P1C1B1MK',
            BaseName = 'P1Cybran1Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    local T1Quantity = {4, 7, 10}
    local T2Quantity = {2, 3, 4}
    trigger = {20, 15, 10}
    Builder = {
        BuilderName = 'M1_Cybran_TransportAttack_Bomb',
        PlatoonTemplate = {
            'M1_Cybran_TransportAttack_Bomb_Template',
            'NoPlan',
            {'url0103', 1, T1Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Tank
            {'xrl0302', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 bomb
        },
        InstanceCount = 1,
        Priority = 160,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {Tquantity[Difficulty], poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1C1B1dropattack2',
            LandingChain = 'P1C1B1drop2',
            TransportReturn = 'P1C1B1MK',
            BaseName = 'P1Cybran1Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    local T1Quantity = {4, 7, 10}
    local T2Quantity = {2, 3, 4}
    trigger = {25, 20, 15}
    Builder = {
        BuilderName = 'M1_Cybran_TransportAttack_4',
        PlatoonTemplate = {
            'M1_Cybran_TransportAttack_4_Template',
            'NoPlan',
            {'url0107', 1, T1Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Tank
            {'url0202', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'url0205', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 AA
            {'url0111', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 AA
        },
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {Tquantity[Difficulty], poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1C1B1dropattack1',
            LandingChain = 'P1C1B1drop1',
            TransportReturn = 'P1C1B1MK',
            BaseName = 'P1Cybran1Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6} 
    trigger = {25, 20, 15}
    local Temp = {
        'P1C1B1LandattackTemp0',
        'NoPlan',
        { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    local Builder = {
        BuilderName = 'P1C1B1landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P1C1B1Landattack1', 'P1C1B1Landattack2', 'P1C1B1Landattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    opai = C1P1Base1:AddOpAI('EngineerAttack', 'M1B1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1C1B1Landattack1', 'P1C1B1Landattack2', 'P1C1B1Landattack3'}
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

-- Cybran Base 2, Objective

function P1C1base2AI()

    C1P1Base2:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P1Cybran1Base2', 'P1C1B2MK', 80, {P1C1base2 = 500})
    C1P1Base2:StartNonZeroBase({{7, 10, 13}, {6, 9, 12}})

    P1C1B2Airattacks()
    P1C1B2Navalattacks()
    P1C1B2Landattacks()  
end

function P1C1B2Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5} 
    local Temp = {
        'P1C1B2LAttackTemp0',
        'NoPlan',
        { 'url0107', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'url0202', 1, 3, 'Attack', 'GrowthFormation' },
        { 'url0104', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1C1B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C1B2Landattack1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {50, 45, 40}
    Temp = {
        'P1C1B2LAttackTemp1',
        'NoPlan',
        { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P1C1B2Landattack2', 'P1C1B2Landattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {35, 30, 25} 
    Temp = {
        'P1C1B2LAttackTemp2',
        'NoPlan',
        { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P1C1B2Landattack2', 'P1C1B2Landattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    local opai = nil
    local trigger = {}
    local poolName = 'P1Cybran1Base2_TransportPool'
    
    local Tquantity = {1, 2, 3}
    -- T2 Transport Platoon
    local Temp = {
        'M1_CybranB2_Transport_Platoon',
        'NoPlan',
        { 'ura0104', 1, Tquantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M1_CybranB2_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {Tquantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P1Cybran1Base2',
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    local Quantity = {2, 4, 6}
    trigger = {20, 15, 10}
    Builder = {
        BuilderName = 'M1_CybranB2_TransportAttack_1',
        PlatoonTemplate = {
            'M1_CybranB2_TransportAttack_1_Template',
            'NoPlan',
            {'url0106', 1, Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 bot
        },
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {Tquantity[Difficulty], poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1C1B2dropattack1',
            LandingChain = 'P1C1B2drop1',
            TransportReturn = 'P1C1B2MK',
            BaseName = 'P1Cybran1Base2',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    local Quantity = {2, 4, 5}
    trigger = {35, 30, 25}
    Builder = {
        BuilderName = 'M1_CybranB2_TransportAttack_2',
        PlatoonTemplate = {
            'M1_CybranB2_TransportAttack_2_Template',
            'NoPlan',
            {'url0107', 1, Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 bot
            {'url0103', 1, Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 bot
        },
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {Tquantity[Difficulty], poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1C1B2dropattack1',
            LandingChain = 'P1C1B2drop1',
            TransportReturn = 'P1C1B2MK',
            BaseName = 'P1Cybran1Base2',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    local T2Quantity = {2, 3, 4}
    local T1Quantity = {2, 4, 5}
    trigger = {16, 12, 8}
    Builder = {
        BuilderName = 'M1_CybranB2_TransportAttack_3',
        PlatoonTemplate = {
            'M1_CybranB2_TransportAttack_3_Template',
            'NoPlan',
            {'url0202', 1, T2Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 tank
            {'url0103', 1, T1Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Arty
            {'url0107', 1, T1Quantity[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 bot
        },
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {Tquantity[Difficulty], poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1C1B2dropattack1',
            LandingChain = 'P1C1B2drop1',
            TransportReturn = 'P1C1B2MK',
            BaseName = 'P1Cybran1Base2',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    opai = C1P1Base2:AddOpAI('EngineerAttack', 'M1B2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1C1B2Landattack2', 'P1C1B2Landattack3'}
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

function P1C1B2Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 2, 3} 
    trigger = {14, 12, 10}
    local Temp = {
        'P1C1B2AAttackTemp0',
        'NoPlan',
        { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1C1B2AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {10, 8, 6}
    Temp = {
        'P1C1B2AAttackTemp1',
        'NoPlan',
        { 'ura0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6} 
    Temp = {
        'P1C1B2AAttackTemp2',
        'NoPlan',
        { 'ura0102', 1, 5, 'Attack', 'GrowthFormation' },
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xra0105', 1, 5, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C1B2Airpatrol1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {14, 12, 10}
    Temp = {
        'P1C1B2AAttackTemp3',
        'NoPlan',
        { 'xra0105', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {16, 14, 10} 
    Temp = {
        'P1C1B2AAttackTemp4',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {30, 25, 20}
    Temp = {
        'P1C1B2AAttackTemp5',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {25, 20, 12} 
    Temp = {
        'P1C1B2AAttackTemp6',
        'NoPlan',
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

function P1C1B2Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5} 
    local Temp = {
        'P1C1B2NAttackTemp0',
        'NoPlan',
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'urs0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1C1B2NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C1B2Navalpatrol1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {1, 1, 2}
    trigger = {2, 1, 1}
    Temp = {
        'P1C1B2NAttackTemp1',
        'NoPlan',
        { 'urs0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.FACTORY}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {7, 5, 4} 
    Temp = {
        'P1C1B2NAttackTemp2',
        'NoPlan',
        { 'urs0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {10, 9, 6} 
    Temp = {
        'P1C1B2NAttackTemp3',
        'NoPlan',
        { 'urs0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.T1SUBMARINE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {6, 5, 4} 
    Temp = {
        'P1C1B2NAttackTemp4',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {30, 25, 20} 
    Temp = {
        'P1C1B2NAttackTemp5',
        'NoPlan',
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {4, 3, 2} 
    Temp = {
        'P1C1B2NAttackTemp6',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'urs0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

-- Cybran 2 base

function P1C2base1AI()

    C2P1Base1:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P1Cybran2Base1', 'P1C2B1MK', 60, {P1C2Base1 = 500})
    C2P1Base1:StartEmptyBase({{4, 5, 7}, {3, 4, 6}})
    C2P1Base1:SetMaximumConstructionEngineers(4)

    P1C2B1Landattacks()
end

function P1C2B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 5, 6} 
    local Temp = {
        'P1C2B1LAttackTemp0',
        'NoPlan',
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P1C2B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    trigger = {10, 8, 10}
    Temp = {
        'P1C2B1LAttackTemp1',
        'NoPlan',
        { 'url0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1C2B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    Temp = {
        'P1C2B1LAttackTemp2',
        'NoPlan',
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'url0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1C2B1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    trigger = {40, 35, 30}
    Temp = {
        'P1C2B1LAttackTemp3',
        'NoPlan',
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1C2B1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )  

    opai = C2P1Base1:AddOpAI('EngineerAttack', 'M1B2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

