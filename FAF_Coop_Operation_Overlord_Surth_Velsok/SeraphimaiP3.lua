local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_CustomFunctions.lua'

local Player1 = 1
local Seraphim = 2

local P4SBase1 = BaseManager.CreateBaseManager()
local P4SRandom1 = BaseManager.CreateBaseManager()
local P4SRandom2 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P4S1Base1AI()

    P4SBase1:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P4SeraphimBase1', 'P4SB1MK', 120, {P4SBase1 = 100})
    P4SBase1:StartNonZeroBase({{24, 33, 45}, {19, 28, 38}})
    P4SBase1:SetActive('AirScouting', true)

    P4S1B1Airattacks()
    P4S1B1Landattacks()
    P4S1B1Navalattacks()
    P4S1B1EXPattacks()
end

function P4S1B1Airattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {12, 15, 18} 
    local Temp = {
        'P4SB1AttackTemp0',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P4SB1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Airattack1','P4SB1Airattack2', 'P4SB1Airattack3', 'P4SB1Airattack4', 'P4SB1Airattack5'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    trigger = {30, 25, 20}
    Temp = {
        'P4SB1AttackTemp1',
        'NoPlan',
        { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P4SB1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 130,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Airattack1','P4SB1Airattack2', 'P4SB1Airattack3', 'P4SB1Airattack4', 'P4SB1Airattack5'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 12, 18} 
    trigger = {30, 25, 20}
    Temp = {
        'P4SB1AttackTemp2',
        'NoPlan',
        { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P4SB1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Airattack1','P4SB1Airattack2', 'P4SB1Airattack3', 'P4SB1Airattack4', 'P4SB1Airattack5'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 

    quantity = {6, 12, 18}
    opai = P4SBase1:AddOpAI('AirAttacks', 'M3B1_Seraphim_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = {(categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE, '>='})
            
    quantity = {6, 9, 12}
    opai = P4SBase1:AddOpAI('AirAttacks', 'M4B1_Seraphim_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = {categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P4S1B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
       'P4SB1LAttackTemp0',
       'NoPlan',
       { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
       { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
       BuilderName = 'P4SB1LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 8,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4SeraphimBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4SB1Landattack1', 'P4SB1Landattack2', 'P4SB1Landattack3', 'P4SB1Landattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {30, 25, 20}
    Temp = {
        'P4SB1LAttackTemp1',
        'NoPlan',
        { 'xsl0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P4SB1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Landattack1', 'P4SB1Landattack2', 'P4SB1Landattack3', 'P4SB1Landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 8}
    trigger = {30, 25, 20}
    Temp = {
        'P4SB1LAttackTemp3',
        'NoPlan',
        { 'dslk004', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P4SB1LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Landattack1', 'P4SB1Landattack2', 'P4SB1Landattack3', 'P4SB1Landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    trigger = {2, 2, 1}
    Temp = {
       'P4SB1LAttackTemp4',
       'NoPlan',
       { 'xsl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P4SB1LAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Landattack1', 'P4SB1Landattack2', 'P4SB1Landattack3', 'P4SB1Landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    quantity2 = {2, 3, 4}
    trigger = {3, 3, 2}
    Temp = {
       'P4SB1LAttackTemp5',
       'NoPlan',
       { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsl0305', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
       { 'dslk004', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsl0307', 1, 4, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
       BuilderName = 'P4SB1LAttackBuilder5',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 200,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4SB1Landattack1', 'P4SB1Landattack2', 'P4SB1Landattack3', 'P4SB1Landattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P4SeraphimBase1_TransportPool'
    
    local quantity = {3, 4, 6}
    -- T2 Transport Platoon
    local Temp = {
        'M4_Sera_Eastern_Transport_Platoon',
        'NoPlan',
        { 'xsa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M4_Sera_Eastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P4SeraphimBase1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    local Quantity2 = {2, 4, 6}
    local Quantity1 = {1, 2, 3}
    Builder = {
        BuilderName = 'M4_Sera_Land_Assault',
        PlatoonTemplate = {
            'M4_Sera_Land_Assault_Template',
            'NoPlan',
            {'xsl0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Tank
            {'xsl0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'},    -- T3 Arty
            {'dslk004', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 AA
        },
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {3, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P3U1Intlandingattack1',
            LandingChain = 'P3Slandingchain' .. Random(1, 3),
            TransportReturn = 'P4SB1MK',
            BaseName = 'P4SeraphimBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P4S1B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
        'P4S1B1NAttackTemp0',
        'NoPlan',
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P4SB1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Navalattack1', 'P4SB1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    trigger = {35, 30, 25}
    Temp = {
        'P4S1B1NAttackTemp1',
        'NoPlan',
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P4SB1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Navalattack1', 'P4SB1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {3, 2, 2}
    Temp = {
        'P4S1B1NAttackTemp2',
        'NoPlan',
        { 'xss0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P4SB1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Navalattack1', 'P4SB1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 5}
    trigger = {3, 2, 2}
    Temp = {
        'P4S1B1NAttackTemp3',
        'NoPlan',
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P4SB1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL * categories.NAVAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB1Navalattack1', 'P4SB1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P4S1B1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {4, 5, 7}
    opai = P4SBase1:AddOpAI({'P3Sbot','P3Sbomber'},
        {
            Amount = 2,
            KeepAlive = true,
          PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4SB1Landattack1', 'P4SB1Landattack2', 'P4SB1Landattack3', 'P4SB1Landattack4'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P4S1Random1AI()

    P4SRandom1:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P4SeraphimRand1', 'P4SB2MK', 50, {P4SRandom1 = 100})
    P4SRandom1:StartNonZeroBase({{4, 5, 7}, {3, 4, 6}})

    P4S1R1Navalattacks()
end

function P4S1R1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 2, 3}
    local Temp = {
        'P4S1R1NAttackTemp0',
        'NoPlan',
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P4SR1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimRand1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB2Navalattack1', 'P4SB2Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {5, 4, 2}
    Temp = {
        'P4S1R1NAttackTemp1',
        'NoPlan',
        { 'xss0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P4SR1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4SeraphimRand1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4SB2Navalattack1', 'P4SB2Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P4S1Random2AI()

    P4SRandom2:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P4SeraphimRand2', 'P4SB2MK', 50, {P4SRandom2 = 100})
    P4SRandom2:StartNonZeroBase({4, 6, 8})

    P4S1R2EXPattacks()
end

function P4S1R2EXPattacks()
    local opai = nil
    local quantity = {}
    quantity = {4, 6, 8}
    opai = P4SRandom2:AddOpAI('P3Sbot2',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P4SB2Navalattack1', 'P4SB2Navalattack2'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

