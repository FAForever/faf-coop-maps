local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_CustomFunctions.lua' 

local Aeon = 4
local Player1 = 1
local SeraphimAlly = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local Aeonbase3 = BaseManager.CreateBaseManager()
local Aeonbase1 = BaseManager.CreateBaseManager()
local Aeonbase2 = BaseManager.CreateBaseManager()
local AeonbaseR1 = BaseManager.CreateBaseManager()
local AeonbaseR2 = BaseManager.CreateBaseManager()

function AeonBase1AI()
    Aeonbase1:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase1', 'P2AB1MK', 80, {P2Abase1 = 100})
    Aeonbase1:StartNonZeroBase({{14, 19, 24}, {10, 15, 20}})

    P2AB1Landattacks()
    P2AB1Airattacks()
end

function P2AB1Landattacks()
    
    local quantity = {}

    quantity = {8, 10, 12}
    local Temp = {
        'P2AB1LandattackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2AB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB1landattack1', 'P2AB1landattack2', 'P2AB1landattack3', 'P2AB1landattack4'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    local opai = nil
    local trigger = {}
    local poolName = 'AeonBase1_TransportPool'
    
    local quantity = {1, 2, 3}
    -- T2 Transport Platoon
    local Temp = {
        'M2_Aeon_Eastern_Transport_Platoon',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M2_Aeon_Eastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {6, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'AeonBase1',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 3, 4}
    local Quantity2 = {4, 6, 8}
    local Quantity3 = {0, 1, 2}
    Builder = {
        BuilderName = 'M2_Aeon_Land_Assault',
        PlatoonTemplate = {
            'M2_Aeon_Land_Assault_Template',
            'NoPlan',
            {'ual0202', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'ual0205', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
            {'ual0103', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T1 Arty
            {'ual0307', 1, Quantity3[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
        },
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {3, poolName}},
            {'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P2Aintattack1',
            LandingChain = 'P2AB1Drop',
            TransportReturn = 'P2AB1MK',
            BaseName = 'AeonBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    Quantity2 = {3, 4, 6}
    trigger = {25, 20, 15}
    Builder = {
        BuilderName = 'M2_Aeon_Land_Assault2',
        PlatoonTemplate = {
            'M2_Aeon_Land_Assault_Template2',
            'NoPlan',
            {'ual0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'ual0202', 1, Quantity2[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 AA
        },
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {3, poolName}},
            {'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {2}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P2Aintattack1',
            LandingChain = 'P2AB1Drop',
            TransportReturn = 'P2AB1MK',
            BaseName = 'AeonBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function P2AB1Airattacks()
    
    local quantity = {}

    quantity = {8, 10, 12}
    local Temp = {
        'P2AB1airattackTemp1',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P2AB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    Temp = {
        'P2AB1airattackTemp2',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'SeraphimAlly', 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    Temp = {
        'P2AB1airattackTemp3',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1airattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    Temp = {
        'P2AB1airattackTemp4',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1airattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
        'P2AB1airattackTemp5',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1airattackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 40, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function AeonBase2AI()
    Aeonbase2:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase2', 'P2AB2MK', 50, {P2Abase2 = 100})
    Aeonbase2:StartNonZeroBase({{4, 5, 7}, {3, 4, 6}})
    
    P2AB2landattacks()
end

function P2AB2landattacks()
    
    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2AB2LandattackTemp0',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2AB2LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB2landattack1', 'P2AB2landattack2', 'P2AB2landattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    Temp = {
        'P2AB2LandattackTemp1',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2AB2LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'HumanPlayers', 3, categories.ALLUNITS * categories.TECH3 - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2', 'P2AB2landattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    Temp = {
        'P2AB2LandattackTemp2',
        'NoPlan',
        { 'ual0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2AB2LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'SeraphimAlly', 6, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2', 'P2AB2landattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'P2AB2LandattackTemp3',
        'NoPlan',
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2AB2LandattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'HumanPlayers', 15, categories.ALLUNITS * categories.TECH3 - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2', 'P2AB2landattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function AeonBase3AI()
    Aeonbase3:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase3', 'P3AB3MK', 60, {P3Abase3 = 100})
    Aeonbase3:StartNonZeroBase({{8, 11, 13}, {7, 10, 12}})
    Aeonbase3:SetActive('AirScouting', true)

    P3AB2Airattacks()
    P3AB2Navalattacks()
    EXpattacks2()
end

function P3Aattacks()

    P3AB1landattacks2()
    P3AB1Airattacks2()
    EXpattacks1()
end

function P3AB2Airattacks()

    local quantity = {}

    quantity = {10, 13, 15}

    local Temp = {
        'P3AB2AirattackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3AB2AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB2Airattack1', 'P3AB2Airattack2', 'P3AB2Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
        'P3AB2AirattackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3AB2AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB2Airattack1', 'P3AB2Airattack2', 'P3AB2Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    Temp = {
        'P3AB2AirattackTemp2',
        'NoPlan',
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3AB2AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB2Airattack1', 'P3AB2Airattack2', 'P3AB2Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function P3AB2Navalattacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'AeonNavalAttackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --Crusier
    }
    local Builder = {
        BuilderName = 'AeonNavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3AB2Navalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {2, 2, 3}
    Temp = {
        'AeonNavalAttackTemp1',
        'NoPlan',
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'AeonNavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 35, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3AB2Navalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 2}
    Temp = {
        'AeonNavalAttackTemp2',
        'NoPlan',
        { 'uas0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'AeonNavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 10, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3AB2Navalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )   
end

function P3AB1landattacks2()

    local Droproutes = {
        'P3AB1drop1',
        'P3AB1drop2',
        'P3AB1drop3',
    }
    Droproutes.num = table.getn(Droproutes)

    local opai = nil
    local trigger = {}
    local quantity = {}
    local poolName = 'AeonBase1_TransportPool'
    
    local quantity = {3, 4, 6}
    -- T2 Transport Platoon
    local Temp = {
        'M2_Aeon_Eastern_Transport_Platoon2',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M2_Aeon_Eastern_Transport_Platoon2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {6, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'AeonBase1',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {1, 2, 2}
    local Quantity2 = {3, 4, 5}
    Builder = {
        BuilderName = 'M2_Aeon_Land_Assault3',
        PlatoonTemplate = {
            'M2_Aeon_Land_Assault_Template3',
            'NoPlan',
            {'ual0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'dalk003', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
            {'ual0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 AA
        },
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {4, poolName}},
            {'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1UDropattack',
            LandingChain = Droproutes[Random(1, Droproutes.num)],
            TransportReturn = 'P2AB1MK',
            BaseName = 'AeonBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    local Quantity1 = {2, 3, 4}
    local Quantity2 = {2, 3, 6}
    Builder = {
        BuilderName = 'M2_Aeon_Land_Assault4',
        PlatoonTemplate = {
            'M2_Aeon_Land_Assault_Template4',
            'NoPlan',
            {'ual0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'ual0202', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
            {'ual0307', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
        },
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {4, poolName}},
            {'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1UDropattack',
            LandingChain = Droproutes[Random(1, Droproutes.num)],
            TransportReturn = 'P2AB1MK',
            BaseName = 'AeonBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 11}
    local Temp = {
        'P3AB1LandattackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3AB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 10,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB1landattack1', 'P2AB1landattack2', 'P2AB1landattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )   
end

function P3AB1Airattacks2()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P3AB1airattackTemp0',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P3AB1airattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {4, 8, 12}
    Temp = {
        'P3AB1airattackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE * (categories.TECH2 + categories.TECH3)}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P3AB1airattackTemp2',
        'NoPlan',
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function EXpattacks1()
    local opai = nil
    local quantity = {}
    
    opai = Aeonbase1:AddOpAI('Abot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB1landattack1', 'P2AB1landattack2', 'P2AB1landattack3'}
        },
            MaxAssist = 4,
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 35, categories.ALLUNITS * categories.TECH3, '>='},
                },
            }
        }
    )
end

function EXpattacks2()
    local opai = nil
    local quantity = {}
    
    opai = Aeonbase3:AddOpAI('Abot2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3AB2Expattack1', 'P3AB2Expattack2', 'P3AB2Expattack3'}
        },
            MaxAssist = 4,
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 2, categories.EXPERIMENTAL, '>='},
                },
            }
        }
    )
end

function AeonBaseR1AI()
    AeonbaseR1:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBaseR1', 'P3ARMK', 80, {P3ARandom1 = 100})
    AeonbaseR1:StartEmptyBase({{6, 9, 12}, {4, 6, 8}})
    AeonbaseR1:SetActive('AirScouting', true)
    AeonbaseR1:SetMaximumConstructionEngineers(6)

    P3ARAirattacks()
    P3REXpattacks()
end

function P3REXpattacks()
    local opai = nil
    local quantity = {}
    
    opai = AeonbaseR1:AddOpAI('ACzar',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
            PlatoonData = {
            PatrolChains = {'P3ARairattack1', 'P3ARairattack2', 'P3ARairattack3'}
        },
            MaxAssist = 4,
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 2, categories.EXPERIMENTAL, '>='},
                },
            }
        }
    )
end

function P3ARAirattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P3AR1airattackTemp0',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P3AR1airattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBaseR1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3ARairattack1', 'P3ARairattack2', 'P3ARairattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {4, 8, 12}
    Temp = {
        'P3AR1airattackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P3AR1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBaseR1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE * (categories.TECH2 + categories.TECH3)}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3ARairattack1', 'P3ARairattack2', 'P3ARairattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P3AR1airattackTemp2',
        'NoPlan',
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P3AR1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBaseR1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3ARairattack1', 'P3ARairattack2', 'P3ARairattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function AeonBaseR2AI()
    AeonbaseR2:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBaseR2', 'P3ARMK', 80, {P3ARandom2 = 100})
    AeonbaseR2:StartEmptyBase({2, 4, 6})
    AeonbaseR2:SetMaximumConstructionEngineers(6)
end
