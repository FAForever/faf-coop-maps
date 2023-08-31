local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Blockade/FAF_Coop_Operation_Blockade_CustomFunctions.lua'

local Player1 = 1
local Seraphim = 2
local Seraphim2 = 3
local Difficulty = ScenarioInfo.Options.Difficulty

local Seraphimbase1P2 = BaseManager.CreateBaseManager()
local Seraphimbase2P2 = BaseManager.CreateBaseManager()
local Seraphimbase3P2 = BaseManager.CreateBaseManager()
local Seraphimbase4P2 = BaseManager.CreateBaseManager()


function Seraphimbase1P2AI()
    
    Seraphimbase1P2:InitializeDifficultyTables(ArmyBrains[Seraphim], 'Seraphimbase1P2', 'P2Base1MK', 90, {P2base1 = 700})
    Seraphimbase1P2:StartNonZeroBase({{14, 18, 22}, {11, 15, 19}})
    Seraphimbase1P2:SetActive('AirScouting', true)
    Seraphimbase1P2:SetSupportACUCount(1)
    Seraphimbase1P2:SetSACUUpgrades({'Overcharge', 'Shield', 'EngineeringThroughput'}, true)
    
    P2B1seraLand()
    P2B1seraAir()
    P2B1seraNaval()
    Exp2P2()
end

function P2B1seraLand()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 10}
    local Temp = {
        'P2B1LandAttackTemp0',
        'NoPlan',          
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },      
     }
     local Builder = {
        BuilderName = 'P2B1LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase1P2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2B1Landattack1','P2B1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {40, 35, 30}
    Temp = {
        'P2B1LandAttackTemp1',
        'NoPlan',       
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2B1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase1P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3 - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2B1Landattack1','P2B1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )   

    quantity = {1, 2, 3}
    Temp = {
        'P2B1GAttackTemp1',
        'NoPlan',
        { 'xsl0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2B1GAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase1P2',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P2B1Landattack1'
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    opai = Seraphimbase1P2:AddOpAI('EngineerAttack', 'M2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P2B1Landattack1','P2B1Landattack2'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T3Engineers', 4)
end 

function P2B1seraAir()

    local quantity = {}
    local trigger = {}

    quantity = {8, 10, 12}
    local Temp = {
       'P2B1AirAttackTemp0',
       'NoPlan',
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },            
    }
    local Builder = {
       BuilderName = 'P2B1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase1P2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2B1Airattack1','P2B1Airattack2', 'P2B1Airattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {8, 10, 12}
    trigger = {18, 16, 12}
    Temp = {
        'P2B1AirAttackTemp1',
        'NoPlan',          
        { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase1P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2B1Airattack1','P2B1Airattack2', 'P2B1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 8}
    trigger = {20, 15, 10}
    Temp = {
        'P2B1AirAttackTemp2',
        'NoPlan',          
        { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 104,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase1P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2B1Airattack1','P2B1Airattack2', 'P2B1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    opai = Seraphimbase1P2:AddOpAI('AirAttacks', 'M2_Sera_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 240,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {6, 12, 18}
    opai = Seraphimbase1P2:AddOpAI('AirAttacks', 'M2_Sera_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE },
            },
            Priority = 250,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE, '>='})

    quantity = {6, 8, 12}
    opai = Seraphimbase1P2:AddOpAI('AirAttacks', 'M2_Sera_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.NAVAL },
            },
            Priority = 230,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.NAVAL, '>='})
end 

function P2B1seraNaval()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6}
    local Temp = {
       'P2B1NavalAttackTemp0',
       'NoPlan',       
       { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xss0202', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
       BuilderName = 'P2B1NavalAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase1P2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2B1Navalattack1', 'P2B1Navalattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {5, 4, 3}
    Temp = {
       'P2B1NavalAttackTemp1',
       'NoPlan',       
       { 'xss0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P2B1NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase1P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2B1Navalattack1', 'P2B1Navalattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {35, 30, 25}
    Temp = {
        'P2B1NavalAttackTemp2',
        'NoPlan',          
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2B1NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase1P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2B1Navalattack1', 'P2B1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end 

function Exp2P2()

    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {1, 2, 4}
    trigger = {2, 1, 1}
    opai = Seraphimbase1P2:AddOpAI('P2Bot2',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P2B1Landattack1','P2B1Landattack2'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL * categories.LAND, '>='},
                },
            }
        }
    )
end

function Seraphimbase2P2AI()
    
    Seraphimbase2P2:InitializeDifficultyTables(ArmyBrains[Seraphim], 'Seraphimbase2P2', 'P2Base2MK', 90, {P2base2 = 700})
    Seraphimbase2P2:StartNonZeroBase({{12, 16, 20}, {8, 12, 16}})
    Seraphimbase2P2:SetActive('AirScouting', true)
    Seraphimbase2P2:SetSupportACUCount(1)
    Seraphimbase2P2:SetSACUUpgrades({'Overcharge', 'Shield', 'EngineeringThroughput'}, true)
    
    P2B2seraLand()
    Exp1P2()    
end

function P2B2seraLand()

    local quantity = {}
    local trigger = {}

    quantity = {6, 9, 12}
    local Temp = {
       'P2B2LandAttackTemp0',
       'NoPlan',       
       { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'P2B2LandAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 6,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase2P2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2B2Landattack1','P2B2Landattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {30, 25, 20}
    Temp = {
       'P2B2LandAttackTemp1',
       'NoPlan',
       { 'dslk004', 1,  quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
       BuilderName = 'P2B2LandAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 110,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase2P2',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2B2Landattack1','P2B2Landattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 9}
    trigger = {30, 25, 20}
    Temp = {
        'P2B2LandAttackTemp2',
        'NoPlan',
        { 'xsl0304', 1,  quantity[Difficulty], 'Attack', 'GrowthFormation' },            
    }
    Builder = {
        BuilderName = 'P2B2LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase2P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2B2Landattack1','P2B2Landattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    Temp = {
        'P2B2LandAttackTemp3',
        'NoPlan',
        { 'xsl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P2B2LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase2P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2B2Landattack1','P2B2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )   

    quantity = {1, 2, 3}
    Temp = {
        'P2B2GAttackTemp1',
        'NoPlan',
        { 'xsl0301_AdvancedCombat', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2B2GAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase2P2',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P2B2Landattack1'
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    opai = Seraphimbase2P2:AddOpAI('EngineerAttack', 'M2_North_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P2B2Landattack1','P2B2Landattack2'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T3Engineers', 4)
end 

function Exp1P2()

    local opai = nil
    local quantity = {}

    quantity = {1, 2, 4}
    trigger = {40, 35, 30}
    opai = Seraphimbase2P2:AddOpAI('P2Bot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P2B2Landattack1','P2B2Landattack2'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3, '>='},
                },
            }
        }
        
    )
end

function Seraphimbase3P2AI()
    
    local quantity = {}
    quantity = {2, 3, 4}
    Seraphimbase3P2:InitializeDifficultyTables(ArmyBrains[Seraphim2], 'Seraphimbase3P2', 'P2Base3MK', 90, {P2base3 = 700})
    Seraphimbase3P2:StartNonZeroBase({{11, 14, 17}, {7, 10, 13}})
    Seraphimbase3P2:SetActive('AirScouting', true)
    Seraphimbase3P2:SetSupportACUCount(quantity[Difficulty])
    Seraphimbase3P2:SetSACUUpgrades({'Overcharge', 'Shield', 'EngineeringThroughput'}, true)
    
    P2B3seraAir()
    P2B3seraNaval()
   
    ForkThread(
        function()
            WaitSeconds(4)
            Seraphimbase3P2:AddBuildGroup('P2BaseEXD', 800, false)
            Seraphimbase3P2.MaximumConstructionEngineers = 3
        end
    ) 
end

function P2B3seraAir()

    local quantity = {}
    local trigger = {}

    quantity = {8, 10, 14}
    local Temp = {
       'P2B3AirAttackTemp0',
       'NoPlan',       
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P2B3AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase3P2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2B3Airattack1', 'P2B3Airattack2', 'P2B3Airattack3'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 8, 14}
    trigger = {25, 20, 15}
    Temp = {
        'P2B3AirAttackTemp1',
        'NoPlan',
        { 'xsa0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P2B3AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 102,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase3P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2B3Airattack1', 'P2B3Airattack2', 'P2B3Airattack3'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    trigger = {20, 15, 10}
    Temp = {
        'P2B3AirAttackTemp2',
        'NoPlan',
        { 'xsa0303', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },             
    }
    Builder = {
        BuilderName = 'P2B3AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 103,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase3P2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2B3Airattack1', 'P2B3Airattack2', 'P2B3Airattack3'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )  

    quantity = {8, 12, 15}
    opai = Seraphimbase3P2:AddOpAI('AirAttacks', 'M2_Seraphim2B1_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.NAVAL * categories.EXPERIMENTAL },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.NAVAL * categories.EXPERIMENTAL, '>='})
end

function P2B3seraNaval()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 6}
    local Temp = {
       'P2B3NavalAttackTemp0',
       'NoPlan',
       { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
       BuilderName = 'P2B3NavalAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase3P2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2B3Navalattack1', 'P2B3Navalattack2'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {2, 4, 6}
    trigger = {4, 3, 1}
    Temp = {
       'P2B3NavalAttackTemp1',
       'NoPlan',       
       { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P2B3NavalAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 105,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase3P2',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2B3Navalattack1', 'P2B3Navalattack2'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {20, 15, 10}
    Temp = {
       'P2B3NavalAttackTemp2',
       'NoPlan',       
       { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xss0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P2B3NavalAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 104,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase3P2',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2B3Navalattack1', 'P2B3Navalattack2'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
end

function Seraphimbase4P2AI()
    
    Seraphimbase4P2:InitializeDifficultyTables(ArmyBrains[Seraphim2], 'Seraphimebase4P2', 'P2S2B2MK', 90, {P2BaseSECFac = 900})
    Seraphimbase4P2:StartNonZeroBase({{12, 18, 22}, {9, 14, 18}})
    Seraphimbase4P2:SetActive('AirScouting', true)
    Seraphimbase4P2:SetMaximumConstructionEngineers(10)
    
   P2B4seraAir()
   P2B4LandAttacks()
   P2B4seraNaval()
   Exp1P2B4()
   
   ForkThread(
        function()
            WaitSeconds(4)
            Seraphimbase4P2:AddBuildGroup('P2BaseSEC_D'.. Difficulty, 1000, false)
        end
    ) 
end

function P2B4seraAir()

    local quantity = {}
    local trigger = {}

    quantity = {8, 10, 12}
    local Temp = {
       'P2B4AirAttackTemp0',
       'NoPlan',
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P2B4AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimebase4P2',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2S2B2Airdefense1'
           }
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {10, 13, 15}
    Temp = {
       'P2B4AirAttackTemp1',
       'NoPlan',
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P2B4AirAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimebase4P2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2S2B2Airattack1', 'P2S2B2Airattack2', 'P2S2B2Airattack3', 'P2S2B2Airattack4'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 10}
    trigger = {20, 15, 10}
    Temp = {
       'P2B4AirAttackTemp2',
       'NoPlan',
       { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P2B4AirAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 105,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimebase4P2',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2S2B2Airattack1', 'P2S2B2Airattack2', 'P2S2B2Airattack3', 'P2S2B2Airattack4'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 10}
    trigger = {20, 15, 10}
    Temp = {
       'P2B4AirAttackTemp3',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P2B4AirAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 110,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimebase4P2',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2S2B2Airattack1', 'P2S2B2Airattack2', 'P2S2B2Airattack3', 'P2S2B2Airattack4'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {5, 10, 15}
    opai = Seraphimbase4P2:AddOpAI('AirAttacks', 'M2_Seraphim2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE, '>='})
            
    quantity = {5, 7, 10}
    opai = Seraphimbase4P2:AddOpAI('AirAttacks', 'M2_Seraphim2_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.LAND * categories.EXPERIMENTAL },
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2, categories.LAND * categories.EXPERIMENTAL, '>='})

    quantity = {5, 7, 10}
    opai = Seraphimbase4P2:AddOpAI('AirAttacks', 'M2_Seraphim2_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.MASSEXTRACTION },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 8, categories.MASSEXTRACTION, '>='})
end

function P2B4LandAttacks()

    local opai = nil
    local trigger = {}
    local poolName = 'Seraphimebase4P2_TransportPool'
    
    local quantity = {2, 4, 6}
    -- T2 Transport Platoon
    local Temp = {
        'M1_Sera_Transport_Platoon',
        'NoPlan',
        { 'xsa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M1_Sera_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimebase4P2',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'Seraphimebase4P2',
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 3, 3}
    local Quantity2 = {4, 6, 6}
    trigger = {60, 55, 50}
    Builder = {
        BuilderName = 'M1_Sera_Land_Assault',
        PlatoonTemplate = {
            'M1_Sera_Land_Assault_Template',
            'NoPlan',
            {'xsl0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Tank
            {'xsl0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Arty
            {'dslk004', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 AA
        },
        InstanceCount = 5,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimebase4P2',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {4, poolName}},
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P2S2B2Dropattack'.. Random(1, 2),
            LandingChain = 'P2S2B2Drop'.. Random(1, 2),
            TransportReturn = 'P2S2B2MK',
            BaseName = 'Seraphimebase4P2',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )   
end

function Exp1P2B4()

    local opai = nil
    local quantity = {}

    quantity = {1, 2, 4}
    trigger = {5, 4, 3}
    opai = Seraphimbase4P2:AddOpAI('P2ExBomber1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2S2B2Airattack1', 'P2S2B2Airattack2', 'P2S2B2Airattack3', 'P2S2B2Airattack4'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL, '>='},
                },
            }
        }
        
    )
end

function P2B4seraNaval()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6}
    local Temp = {
       'P2B4NavalAttackTemp0',
       'NoPlan',       
       { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
       BuilderName = 'P2B4NavalAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'Seraphimebase4P2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2S2B2Navalattack1'
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
       'P2B4NavalAttackTemp1',
       'NoPlan',       
       { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
       BuilderName = 'P2B4NavalAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 104,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'Seraphimebase4P2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2S2B2Navalattack1'
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
end