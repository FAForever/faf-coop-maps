local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_CustomFunctions.lua' 

local Aeon = 4
local UEF = 3
local Player1 = 1

local Difficulty = ScenarioInfo.Options.Difficulty

local P4AeonBase1 = BaseManager.CreateBaseManager()
local P4UEFBase1 = BaseManager.CreateBaseManager()
local P4AeonBase2 = BaseManager.CreateBaseManager()
local P4UEFBase2 = BaseManager.CreateBaseManager()

function P4ABase1AI()
    P4AeonBase1:InitializeDifficultyTables(ArmyBrains[Aeon], 'P4Aeonbase', 'P4AB1MK', 60, {P4ABase1 = 100})
    P4AeonBase1:StartNonZeroBase({{7, 10, 12}, {5, 8, 10}})

    P4AB1landattacks()
    P4AB1Airattacks()
end

function P4AB1landattacks()

    local quantity = {}

    local opai = nil
    local trigger = {}
    local poolName = 'P4Aeonbase_TransportPool'
    
    local quantity = {4, 5, 6}
    -- T2 Transport Platoon
    local Temp = {
        'M4_Aeon_Southern_Transport_Platoon',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M4_Aeon_Southern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P4Aeonbase',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 3, 4}
    local Quantity2 = {3, 4, 6}
    Builder = {
        BuilderName = 'M4_Aeon_Land_Assault',
        PlatoonTemplate = {
            'M4_Aeon_Land_Assault_Template',
            'NoPlan',
            {'ual0202', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'ual0205', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
            {'ual0111', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 MML
            {'ual0307', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 Sheild
        },
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {4, poolName}},
            {'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P4AB1DropAttack1',
            LandingChain = 'P4AB1Drop',
            TransportReturn = 'P2AB1MK',
            BaseName = 'P4Aeonbase',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function P4AB1Airattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P4AB1airattackTemp0',
        'NoPlan',
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P4AB1airattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4AB1Airattack1', 'P4AB1Airattack2', 'P4AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {6, 8, 9}
    Temp = {
        'P4AB1airattackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P4AB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4AB1Airattack1', 'P4AB1Airattack2', 'P4AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    opai = P4AeonBase1:AddOpAI('AirAttacks', 'M4_Aeon_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2,  categories.EXPERIMENTAL * categories.LAND * categories.MOBILE, '>='})  
end

function P4UBase1AI()
    P4UEFBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFbase', 'P4UB1MK', 60, {P4UBase1 = 100})
    P4UEFBase1:StartNonZeroBase({{6, 8, 10}, {4, 6, 8}})
    
    P4UB1landattacks()
    P4UB1Airattacks()
end

function P4UB1landattacks()
    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P4UB1LandattackTemp0',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P4UB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Landattack1', 'P4UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P4UEFbase_TransportPool'
    
    local quantity = {1, 1, 2}
    -- T2 Transport Platoon
    local Temp = {
        'M4_UEF_Southern_Transport_Platoon',
        'NoPlan',
        { 'xea0306', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M4_UEF_Southern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P4UEFbase',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {1, 1, 3}
    local Quantity2 = {3, 4, 6}
    Builder = {
        BuilderName = 'M4_UEF_Land_Assault',
        PlatoonTemplate = {
            'M4_UEF_Land_Assault_Template',
            'NoPlan',
            {'uel0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Bot
            {'ual0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 A
            {'dalk003', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
        },
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {3, poolName}},
            {'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P4UB1DropAttack2',
            LandingChain = 'P4UB1Drop',
            TransportReturn = 'P4UB1MK',
            BaseName = 'P4UEFbase',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P4UB1Airattacks()
    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P4UB1AirattackTemp0',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P4UB1AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Landattack1', 'P4UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P4UB1AirattackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P4UB1AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Landattack1', 'P4UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P4UBase2AI()
    P4UEFBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFbase2', 'P4UB2MK', 60, {P4UBase2 = 300})
    P4UEFBase2:StartNonZeroBase({{9, 13, 17}, {8, 12, 16}})
    
    P4UB2landattacks()
    P4UB2Airattacks()
end

function P4UB2landattacks()
    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P4UB2LandattackTemp0',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P4UB2LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P4UB2Landattack1', 'P4UB2Landattack2', 'P4UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P4UEFbase_TransportPool'
    
    local quantity = {1, 2, 3}
    -- T2 Transport Platoon
    local Temp = {
        'M4_UEF_Southern_Transport_Platoon',
        'NoPlan',
        { 'xea0306', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M4_UEF_Southern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase2',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P4UEFbase2',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 3, 3}
    local Quantity2 = {2, 6, 12}
    Builder = {
        BuilderName = 'M4_UEF_Land_Assault2',
        PlatoonTemplate = {
            'M4_UEF_Land_Assault_Template2',
            'NoPlan',
            {'uel0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Bot
            {'ual0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 A
            {'dalk003', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
        },
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase2',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {3, poolName}},
            {'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P4UB2DropAttack' .. Random(1, 2),
            LandingChain = 'P4UB2Drop',
            TransportReturn = 'P4UB2MK',
            BaseName = 'P4UEFbase2',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P4UB2Airattacks()
    local quantity = {}

    quantity = {3, 4, 6}
    local Temp = {
        'P4UB2AirattackTemp0',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P4UB2AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB2Airattack1', 'P4UB2Airattack2', 'P4UB2Airattack3', 'P4UB2Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {6, 8, 12}
    Temp = {
        'P4UB2AirattackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P4UB2AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB2Airattack1', 'P4UB2Airattack2', 'P4UB2Airattack3', 'P4UB2Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    opai = P4UEFBase2:AddOpAI('AirAttacks', 'M4_UEF_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2,  categories.EXPERIMENTAL * categories.LAND, '>='})  
end

function P4ABase2AI()
    P4AeonBase2:InitializeDifficultyTables(ArmyBrains[Aeon], 'P4Aeonbase2', 'P4AB2MK', 60, {P4ABase2 = 300})
    P4AeonBase2:StartNonZeroBase({{8, 12, 15}, {7, 11, 14}})

    P4AB2landattacks()
    P4AB2Airattacks()
end

function P4AB2landattacks()

    local quantity = {}

    local opai = nil
    local trigger = {}
    local poolName = 'P4Aeonbase2_TransportPool'
    
    local quantity = {4, 5, 6}
    -- T2 Transport Platoon
    local Temp = {
        'M4_Aeon_Northern_Transport_Platoon',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M4_Aeon_Northern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase2',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P4Aeonbase2',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {1, 2, 2}
    local Quantity2 = {3, 4, 6}
    Builder = {
        BuilderName = 'M4_Aeon_Land_Assault2',
        PlatoonTemplate = {
            'M4_Aeon_Land_Assault_Template2',
            'NoPlan',
            {'ual0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 bot
            {'ual0205', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 AA
            {'ual0111', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 MML
            {'ual0307', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'}, -- T2 Sheild
        },
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase2',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {4, poolName}},
            {'/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P4AB2DropAttack1',
            LandingChain = 'P4AB2Drop',
            TransportReturn = 'P4AB2MK',
            BaseName = 'P4Aeonbase2',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function P4AB2Airattacks()

    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P4AB2airattackTemp0',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P4AB2airattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4AB2Airattack1', 'P4AB2Airattack2', 'P4AB2Airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {8, 10, 12}
    Temp = {
        'P4AB2airattackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P4AB2airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4AB2Airattack1', 'P4AB2Airattack2', 'P4AB2Airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end