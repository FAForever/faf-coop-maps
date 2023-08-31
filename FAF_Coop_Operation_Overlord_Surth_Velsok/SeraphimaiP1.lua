local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_CustomFunctions.lua'

local Player1 = 1
local Seraphim = 2

local P1SBase1 = BaseManager.CreateBaseManager()
local P1SBase2 = BaseManager.CreateBaseManager()
local P1SBase3 = BaseManager.CreateBaseManager()
local P1SBase4 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P1S1Base1AI()

    P1SBase1:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P1SeraphimBase1', 'P1SB1MK', 100, {P1SBase1 = 100})
    P1SBase1:StartNonZeroBase({{10, 14, 18}, {8, 12, 16}})
    P1SBase1:SetActive('AirScouting', true)
    P1SBase1:AddBuildGroupDifficulty('P1SBase1EXD', 90)

    P1S1B1Airattacks()
    P1S1B1Landattacks()
    P1S1B1Navalattacks()  
end

function P1S1B1Airattacks()
    
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 2, 3}

    local Temp = {
        'P1SB1AttackTemp0',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1SB1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1SB1Airpatrol1'
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    trigger = {7, 6, 5}
    Temp = {
        'P1SB1AttackTemp1',
        'NoPlan',
        { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2', 'P1SB1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    
    quantity = {2, 3, 4}
    trigger = {30, 25, 20}
    Temp = {
        'P1SB1AttackTemp2',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2', 'P1SB1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {3, 3, 4}
    trigger = {8, 7, 6}
    Temp = {
        'P1SB1AttackTemp3',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2', 'P1SB1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {7, 6, 6}
    Temp = {
        'P1SB1AttackTemp4',
        'NoPlan',
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2', 'P1SB1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 

    quantity = {5, 6, 8}
    trigger = {30, 25, 20}
    Temp = {
        'P1SB1AttackTemp5',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2', 'P1SB1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )        
end

function P1S1B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P1SB1LAttackTemp0',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1SB1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1SB1landpatrol1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    Temp = {
        'P1SB1LAttackTemp1',
        'NoPlan',
        { 'xsl0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {7, 6, 5}
    Temp = {
        'P1SB1LAttackTemp2',
        'NoPlan',
        { 'xsl0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB1LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {8, 7, 6}
    Temp = {
       'P1SB1LAttackTemp3',
       'NoPlan',
       { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB1LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {3, 5, 6}
    trigger = {18, 16, 14}
    Temp = {
       'P1SB1LAttackTemp4',
       'NoPlan',
       { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1SB1LAttackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 6,
       Priority = 200,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {7, 6, 5}
    Temp = {
       'P1SB1LAttackTemp5',
       'NoPlan', 
       { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1SB1LAttackBuilder5',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 205,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {10, 9, 7}
    Temp = {
       'P1SB1LAttackTemp6',
       'NoPlan',
       { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1SB1LAttackBuilder6',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 210,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {6, 5, 4}
    Temp = {
        'P1SB1LAttackTemp7',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }       
    }
    Builder = {
        BuilderName = 'P1SB1LAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {7, 6, 5}
    Temp = {
       'P1SB1LAttackTemp8',
       'NoPlan',
       { 'xsl0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }       
    }
    Builder = {
       BuilderName = 'P1SB1LAttackBuilder8',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 305,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P1SeraphimBase1_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M1_Sera_SouthWestern_Transport_Platoon',
        'NoPlan',
        { 'xsa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M1_Sera_SouthWestern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P1SeraphimBase1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 3, 4}
    local Quantity2 = {4, 6, 8}
    trigger = {55, 50, 40}
    Builder = {
        BuilderName = 'M1_SeraB1_Land_Assault',
        PlatoonTemplate = {
            'M1_Sera_LandB1_Assault_Template',
            'NoPlan',
            {'xsl0201', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Tank
            {'xsl0103', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'},    -- T1 Arty
        },
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {1, poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1SB1Dropattack1',
            LandingChain = 'P1SB1Drop1',
            TransportReturn = 'P1SB1MK',
            BaseName = 'P1SeraphimBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    local Quantity1 = {2, 3, 4}
    local Quantity2 = {4, 6, 8}
    trigger = {20, 15, 10}
    Builder = {
        BuilderName = 'M1_SeraB1_Land_Assault1',
        PlatoonTemplate = {
            'M1_Sera_LandB1_Assault_Template1',
            'NoPlan',
            {'xsl0202', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Tank
            {'xsl0111', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'},    -- T1 Arty
            {'xsl0205', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'},    -- T1 Arty
        },
        InstanceCount = 2,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1SB1Dropattack1',
            LandingChain = 'P1SB1Drop1',
            TransportReturn = 'P1SB1MK',
            BaseName = 'P1SeraphimBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    opai = P1SBase1:AddOpAI('EngineerAttack', 'M1B1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1SB1Landattack1', 'P1SB1Landattack2'}
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

function P1S1B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 1, 2}
    trigger = {2, 2, 1}
    local Temp = {
       'P1S1B1NAttackTemp0',
       'NoPlan',
       { 'xss0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
       BuilderName = 'P1SB1NAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P1SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.NAVAL}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1SB1Navalattack1', 'P1SB1Navalattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {7, 7, 6}
    Temp = {
       'P1S1B1NAttackTemp1',
       'NoPlan',
       { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xss0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P1SB1NAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 105,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P1SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1SB1Navalattack1', 'P1SB1Navalattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    trigger = {6, 5, 4}
    Temp = {
        'P1S1B1NAttackTemp2',
        'NoPlan',
        { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Navalattack1', 'P1SB1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {8, 7, 6}
    Temp = {
        'P1S1B1NAttackTemp3',
        'NoPlan',
        { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase1',
         BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Navalattack1', 'P1SB1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P1S1Base2AI()

    P1SBase2:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P1SeraphimBase2', 'P1SB2MK', 90, {P1SBase2 = 100})
    P1SBase2:StartEmptyBase({{4, 5, 7}, {3, 4, 6}})
    P1SBase2:SetActive('AirScouting', true)
    P1SBase2:SetMaximumConstructionEngineers(4)
    
    P1S1B2Airattacks()
    P1S1B2Landattacks()   
end

function P1S1B2Airattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {2, 2, 4}
    trigger = {7, 6, 5}
    local Temp = {
        'P1SB2AttackTemp0',
        'NoPlan',
        { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1SB2AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2Airattack1','P1SB2Airattack2', 'P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {40, 35, 30}
    Temp = {
       'P1SB2AttackTemp1',
       'NoPlan',
       { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1SB2AttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1SeraphimBase2',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1SB2Airattack1','P1SB2Airattack2', 'P1SB2Airattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {6, 5, 4}
    Temp = {
        'P1SB2AttackTemp2',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1SB2AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2Airattack1','P1SB2Airattack2', 'P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )  

    quantity = {2, 3, 4}
    trigger = {14, 14, 10}
    Temp = {
        'P1SB2AttackTemp3',
        'NoPlan',
        { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1SB2AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2Airattack1','P1SB2Airattack2', 'P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {30, 25, 20}
    Temp = {
        'P1SB2AttackTemp4',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1SB2AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2Airattack1','P1SB2Airattack2', 'P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 
end

function P1S1B2Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P1SB2LAttackTemp0',
        'NoPlan',
        { 'xsl0101', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P1SB2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2Landattack1', 'P1SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {30, 25, 20}
    Temp = {
        'P1SB2LAttackTemp1',
        'NoPlan',
        { 'xsl0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1SB2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2Landattack1', 'P1SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {7, 6, 5}
    Temp = {
        'P1SB2LAttackTemp2',
        'NoPlan',
        { 'xsl0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1SB2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2Landattack1', 'P1SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )  

    quantity = {4, 6, 8}
    trigger = {7, 5, 3}
    Temp = {
        'P1SB2LAttackTemp3',
        'NoPlan',
        { 'xsl0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1SB2LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2Landattack1', 'P1SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    opai = P1SBase2:AddOpAI('EngineerAttack', 'M1B2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1SB2Landattack1', 'P1SB2Landattack2'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

function P1S1Base3AI()

    P1SBase3:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P1SeraphimBase3', 'P1SB3MK', 90, {P1SBase3 = 100})
    P1SBase3:StartEmptyBase({{3, 4, 5}, {2, 3, 4}})
    P1SBase3:SetActive('AirScouting', true)
    P1SBase3:SetMaximumConstructionEngineers(4)

    P1S1B3Airattacks()
    P1S1B3Landattacks()   
end

function P1S1B3Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 1, 2}
    local Temp = {
        'P1SB3AttackTemp0',
        'NoPlan',
        { 'xsa0101', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1SB3AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB3Airattack1','P1SB3Airattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )  

    quantity = {1, 1, 2}
    trigger = {10, 5, 1}
    Temp = {
        'P1SB3AttackTemp1',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB3AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB3Airattack1','P1SB3Airattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {12, 10, 8}
    Temp = {
        'P1SB3AttackTemp2',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB3AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB3Airattack1','P1SB3Airattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 7}
    trigger = {8, 7, 5}
    Temp = {
        'P1SB3AttackTemp3',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB3AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 115,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB3Airattack1','P1SB3Airattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )      
end

function P1S1B3Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 2, 3}
    local Temp = {
       'P1SB3LAttackTemp0',
       'NoPlan',
       { 'xsl0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P1SB3LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1SeraphimBase3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1SB3Landattack1', 'P1SB3Landattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 9}
    trigger = {6, 5, 4}
    Temp = {
        'P1SB3LAttackTemp1',
        'NoPlan',
        { 'xsl0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1SB3LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB3Landattack1', 'P1SB3Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    local opai = nil
    local trigger = {}
    local poolName = 'P1SeraphimBase3_TransportPool'
    
    local quantity = {1, 2, 2}
    -- T2 Transport Platoon
    local Temp = {
        'M1_Sera_SouthEastern_Transport_Platoon',
        'NoPlan',
        { 'xsa0107', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M1_Sera_SouthEastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase3',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P1SeraphimBase3',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 2, 3}
    local Quantity2 = {3, 4, 5}
    trigger = {35, 30, 25}
    Builder = {
        BuilderName = 'M1_Sera_Land_Assault',
        PlatoonTemplate = {
            'M1_Sera_Land_Assault_Template',
            'NoPlan',
            {'xsl0201', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Tank
            {'xsl0103', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'},    -- T1 Ary
        },
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase3',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {1, poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1SB3Dropattack1',
            LandingChain = 'P1SB3Drop1',
            TransportReturn = 'P1SB3MK',
            BaseName = 'P1SeraphimBase3',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    local Quantity1 = {2, 3, 4}
    local Quantity2 = {5, 6, 8}
    trigger = {75, 65, 55}
    Builder = {
        BuilderName = 'M1_Sera_Land_Assault2',
        PlatoonTemplate = {
            'M1_Sera_Land_Assault_Template2',
            'NoPlan',
            {'xsl0201', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T1 Tank
            {'xsl0103', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'},    -- T1 Arty
            {'xsl0104', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'},    -- T1 AAA
        },
        InstanceCount = 1,
        Priority = 160,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase3',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P1SB3Dropattack1',
            LandingChain = 'P1SB3Drop1',
            TransportReturn = 'P1SB3MK',
            BaseName = 'P1SeraphimBase3',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    opai = P1SBase3:AddOpAI('EngineerAttack', 'M1B3_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1SB2Landattack1', 'P1SB2Landattack2'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

function P1S1Base4AI()

    P1SBase4:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P1SeraphimBase4', 'P1SB4MK', 60, {P1SBase4 = 100})
    P1SBase4:StartEmptyBase({{4, 5, 7}, {3, 4, 6}})

    P1SBase1:AddExpansionBase('P1SeraphimBase4', 2)

    P1S1B4Airattacks()   
end

function P1S1B4Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 2, 3}
    local Temp = {
        'P1SB4AttackTemp0',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1SB4AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB2Airattack1','P1SB2Airattack2','P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 

    quantity = {3, 4, 6}
    trigger = {10, 9, 8}
    Temp = {
        'P1SB4AttackTemp1',
        'NoPlan',
        { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB4AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB2Airattack1','P1SB2Airattack2','P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )  

    quantity = {3, 4, 9}
    trigger = {10, 9, 8}
    Temp = {
        'P1SB4AttackTemp2',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB4AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 130,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB2Airattack1','P1SB2Airattack2','P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 

    quantity = {3, 4, 6}
    trigger = {10, 8, 7}
    Temp = {
        'P1SB4AttackTemp3',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB4AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB2Airattack1','P1SB2Airattack2','P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 

    quantity = {3, 4, 6}
    trigger = {10, 8, 7}
    Temp = {
        'P1SB4AttackTemp4',
        'NoPlan',
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB4AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB2Airattack1','P1SB2Airattack2','P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 

    quantity = {6, 9, 12}
    trigger = {6, 5, 3}
    Temp = {
        'P1SB4AttackTemp5',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1SB4AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 230,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1SeraphimBase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB2Airattack1','P1SB2Airattack2','P1SB2Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 
end