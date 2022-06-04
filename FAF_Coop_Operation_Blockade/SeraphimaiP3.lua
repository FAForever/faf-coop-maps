local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Blockade/FAF_Coop_Operation_Blockade_CustomFunctions.lua'

local Player1 = 1
local Seraphim2 = 3
local Difficulty = ScenarioInfo.Options.Difficulty

local Seraphimbase1P3 = BaseManager.CreateBaseManager()
local Seraphimbase2P3 = BaseManager.CreateBaseManager()
local Seraphimbase3P3 = BaseManager.CreateBaseManager()
local Seraphimbase4P3 = BaseManager.CreateBaseManager()

function Seraphimbase1P3AI()
    
    Seraphimbase1P3:InitializeDifficultyTables(ArmyBrains[Seraphim2], 'SeraphimB1P3', 'P3B1MK', 140, {P3base1 = 700})
    Seraphimbase1P3:StartNonZeroBase({{19, 24, 30}, {11, 16, 22}})
    Seraphimbase1P3:SetActive('AirScouting', true)
    
    P3B1seraLand()
    P3B1seraAir() 
    P3B1seraNaval()
    P3B1Exp() 
end

function P3B1seraLand()

    local quantity = {}

    quantity = {6, 8, 12}
    local Temp = {
       'SeralandP3B1AttackTemp0',
       'NoPlan',
       { 'xsl0307', 1, 4, 'Attack', 'GrowthFormation' },   
       { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'dslk004', 1, 4, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'SeraAttackP3B1Builder0',
       PlatoonTemplate = Temp,
       InstanceCount = 8,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'SeraphimB1P3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3B1Landattack1'
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 8, 10}
    Temp = {
        'SeralandP3B1AttackTemp1',
        'NoPlan',
        { 'xsl0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'SeraAttackP3B1Builder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'SeraphimB1P3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3B1Landattack1'
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 7}
    Temp = {
        'SeralandP3B1AttackTemp2',
        'NoPlan',
        { 'xsl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dslk004', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'SeraAttackP3B1Builder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 106,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'SeraphimB1P3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3B1Landattack1'
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
end

function P3B1seraAir()

    local quantity = {}

    quantity = {12, 14, 16}
    local Temp = {
       'SeraAirP3B1DefenceTemp0',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'SeraAirDefenceP3B1Builder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'SeraphimB1P3',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3B1Airdefence1'
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {12, 15, 18}
    Temp = {
       'SeraAirP3B1AttackTemp0',
       'NoPlan',  
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'SeraAirAttackP3B1Builder0',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'SeraphimB1P3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3B1Airattack1','P3B1Airattack2','P3B1Airattack3','P3B1Airattack4'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 9, 12}
    Temp = {
        'SeraAirP3B1AttackTemp1',
        'NoPlan',
        { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'SeraAirAttackP3B1Builder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'SeraphimB1P3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3B1Airattack1','P3B1Airattack2','P3B1Airattack3','P3B1Airattack4'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {12, 15, 18}
    Temp = {
       'SeraAirP3B1AttackTemp2',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'SeraAirAttackP3B1Builder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 105,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'SeraphimB1P3',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3B1Airattack1','P3B1Airattack2','P3B1Airattack3','P3B1Airattack4'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {16, 20, 24}
    opai = Seraphimbase1P3:AddOpAI('AirAttacks', 'M3B1_Seraphim2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.xea0002 },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.xea0002, '>='})
            
    quantity = {12, 15, 18}
    opai = Seraphimbase1P3:AddOpAI('AirAttacks', 'M3B1_Seraphim2_Air_Attack_2',
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

    quantity = {16, 20, 24}
    opai = Seraphimbase1P3:AddOpAI('AirAttacks', 'M3B1_Seraphim2_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.NAVAL * categories.EXPERIMENTAL },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.NAVAL * categories.EXPERIMENTAL, '>='})

    quantity = {12, 15, 18}
    opai = Seraphimbase1P3:AddOpAI('AirAttacks', 'M3B1_Seraphim2_Air_Attack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.STRUCTURE * categories.EXPERIMENTAL },
            },
            Priority = 135,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.STRUCTURE * categories.EXPERIMENTAL, '>='})
end

function P3B1seraNaval()

    local quantity = {}

    quantity = {2, 2, 4}
    local Temp = {
        'SeraNavalP3B1AttackTemp0',
        'NoPlan',
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'SeraNavalP3B1Builder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'SeraphimB1P3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3B1Navalattack1','P3B1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    Temp = {
        'SeraNavalP3B1AttackTemp1',
        'NoPlan',  
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'SeraNavalP3B1Builder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'SeraphimB1P3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.NAVAL * categories.MOBILE - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3B1Navalattack1','P3B1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'SeraNavalP3B1AttackTemp2',
        'NoPlan',  
        { 'xss0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'SeraNavalP3B1Builder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 106,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'SeraphimB1P3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3B1Navalattack1','P3B1Navalattack2'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
end

function P3B1Exp()

    local opai = nil
    local quantity = {}
    
    quantity = {2, 4, 6}
    opai = Seraphimbase1P3:AddOpAI({'ExBomber1','Bot1'},
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3B1Airattack1','P3B1Airattack2','P3B1Airattack3','P3B1Airattack4'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function Seraphimbase2P3AI()
    
    Seraphimbase2P3:InitializeDifficultyTables(ArmyBrains[Seraphim2], 'Seraphimbase2P3', 'P3B2MK', 90, {P3base2 = 700})
    Seraphimbase2P3:StartNonZeroBase({{6, 8, 10}, {4, 6, 8}})

    P3B2seraNaval()
    P3B2Exp()
end

function P3B2seraNaval()

    local quantity = {}

    quantity = {3, 4, 5}
    local Temp = {
        'SeraNavalP3B2DefenceTemp0',
        'NoPlan',
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'SeraNavalP3B2Builder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase2P3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3B2Navalattack1','P3B2Navalattack2'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {5, 8, 12}
    Temp = {
        'SeraNavalP3B2DefenceTemp1',
        'NoPlan',  
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'SeraNavalP3B2Builder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase2P3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.NAVAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3B2Navalattack1','P3B2Navalattack2'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
       'SeraNavalP3B2DefenceTemp2',
       'NoPlan',
       { 'xss0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'SeraNavalP3B2Builder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 104,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase2P3',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3B2Navalattack1','P3B2Navalattack2'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
end

function P3B2Exp()

    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = Seraphimbase2P3:AddOpAI('Bot4',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P3B2Navalattack1','P3B2Navalattack2'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end
    
function Seraphimbase3P3AI()
    
    Seraphimbase3P3:InitializeDifficultyTables(ArmyBrains[Seraphim2], 'Seraphimbase3P3', 'P3B3MK', 90, {P3base3 = 700})
    Seraphimbase3P3:StartNonZeroBase({{6, 8, 10}, {4, 6, 8}})

    P3B3seraAir()
    P3B3Exp()
end

function P3B3seraAir()

    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
       'SeraAirP3B3DefenceTemp0',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'SeraAirDefenceP3B3Builder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase3P3',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3B3Airdefence1'
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 8, 12}
    Temp = {
       'SeraAirP3B3AttackTemp0',
       'NoPlan',  
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'SeraAirAttackP3B3Builder0',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase3P3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3B3Airattack1','P3B3Airattack2','P3B3Airattack3'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    Temp = {
        'SeraAirP3B3AttackTemp1',
        'NoPlan',
        { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'SeraAirAttackP3B3Builder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase3P3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3B3Airattack1','P3B3Airattack2','P3B3Airattack3'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {12, 15, 18}
    Temp = {
       'SeraAirP3B3AttackTemp2',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'SeraAirAttackP3B3Builder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 105,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase1P3',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3B3Airattack1','P3B3Airattack2','P3B3Airattack3'}
       },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 8, 12}
    opai = Seraphimbase3P3:AddOpAI('AirAttacks', 'M3B3_Seraphim2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = {{ (categories.EXPERIMENTAL * categories.AIR) - categories.xea0002 }},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.xea0002, '>='})
            
    quantity = {4, 8, 12}
    opai = Seraphimbase3P3:AddOpAI('AirAttacks', 'M3B3_Seraphim2_Air_Attack_2',
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

    quantity = {8, 12, 16}
    opai = Seraphimbase3P3:AddOpAI('AirAttacks', 'M3B3_Seraphim2_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.NAVAL * categories.EXPERIMENTAL },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.NAVAL * categories.EXPERIMENTAL, '>='})

    quantity = {4, 8, 12}
    opai = Seraphimbase3P3:AddOpAI('AirAttacks', 'M3B3_Seraphim2_Air_Attack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.STRUCTURE * categories.EXPERIMENTAL },
            },
            Priority = 135,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.STRUCTURE * categories.EXPERIMENTAL, '>='})
end

function P3B3Exp()

    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = Seraphimbase3P3:AddOpAI('Bot3',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P3B3Airattack1','P3B3Airattack2','P3B3Airattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function Seraphimbase4P3AI()
    
    Seraphimbase4P3:InitializeDifficultyTables(ArmyBrains[Seraphim2], 'SeraphimB4P3', 'P3B4MK', 90, {P3base4 = 700})
    Seraphimbase4P3:StartNonZeroBase({{6, 8, 10}, {4, 6, 8}})

    P3B4seraLand()
    P3B4Exp()
end

function P3B4seraLand()

    local quantity = {}

    quantity = {5, 7, 10}
    local Temp = {
        'SeralandP3B4AttackTemp0',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
  
    }
    local Builder = {
        BuilderName = 'SeraAttackP3B4Builder0',
        PlatoonTemplate = Temp,
        InstanceCount = 10,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'SeraphimB4P3',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains =  {'P3B4Landattack1','P3B4Landattack2'}
        },
    }
    ArmyBrains[Seraphim2]:PBMAddPlatoon( Builder )
end

function P3B4Exp()

    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = Seraphimbase4P3:AddOpAI('Bot2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains =  {'P3B4Landattack1','P3B4Landattack2'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end