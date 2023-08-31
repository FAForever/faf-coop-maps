local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Rebel\'s_Rest/FAF_Coop_Operation_Rebel\'s_Rest_CustomFunctions.lua'

local Player1 = 1
local UEF1 = 2

local P1U1Base1 = BaseManager.CreateBaseManager()
local P1U1Base2 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P1U1Base1AI()

    P1U1Base1:InitializeDifficultyTables(ArmyBrains[UEF1], 'P1UEF1Base1', 'P1U1B1MK', 100, {P1U1Base1 = 100})
    P1U1Base1:StartNonZeroBase({{10, 14, 18}, {8, 12, 16}})
    P1U1Base1:SetActive('AirScouting', true)
    ForkThread(
        function()
            WaitSeconds(5)
            P1U1Base1:AddBuildGroup('P1U1Base1EXD_D' .. Difficulty, 90)
            P1U1Base1:AddBuildGroup('P1U1Base1EXD2', 80)
            P1U1Base1:AddBuildGroup('P1U1Base1EXD3', 70)
        end
    )
    P1U1B1Airattacks()
    P1U1B1Landattacks()
    P1U1B1Navalattacks()  
end

function P1U1B1Airattacks()
    
    local quantity = {}
    
    quantity = {3, 4, 5}
    local Temp = {
        'P1U1B1AttackTemp0',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1U1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1U1B1Airpatrol1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    Temp = {
        'P1U1B1AttackTemp1',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1U1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1U1B1Airattack1','P1U1B1Airattack2', 'P1U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P1U1B1AttackTemp2',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1U1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B1Airattack1','P1U1B1Airattack2', 'P1U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P1U1B1AttackTemp3',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1U1B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.ALLUNITS * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B1Airattack1','P1U1B1Airattack2', 'P1U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P1U1B1AttackTemp4',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1U1B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B1Airattack1','P1U1B1Airattack2', 'P1U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder ) 

    quantity = {4, 6, 8}
    Temp = {
        'P1U1B1AttackTemp5',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1U1B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 12, categories.ALLUNITS * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B1Airattack1','P1U1B1Airattack2', 'P1U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )        
end

function P1U1B1Landattacks()

    local quantity = {}

    quantity = {3, 4, 6}
    local Temp = {
        'P1U1B1LAttackTemp0',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1U1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B1Landattack1', 'P1U1B1Landattack2', 'P1U1B1Landattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P1U1B1LAttackTemp1',
        'NoPlan',
        { 'del0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1U1B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B1Landattack1', 'P1U1B1Landattack2', 'P1U1B1Landattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
       'P1U1B1LAttackTemp2',
       'NoPlan',
       { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
       { 'uel0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1U1B1LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 110,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1UEF1Base1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.AIR - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1U1B1Landattack1', 'P1U1B1Landattack2', 'P1U1B1Landattack3'}
       },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    Temp = {
       'P1U1B1LAttackTemp3',
       'NoPlan',
       { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1U1B1LAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 115,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1UEF1Base1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 9, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1U1B1Landattack1', 'P1U1B1Landattack2', 'P1U1B1Landattack3'}
       },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    Temp = {
       'P1U1B1LAttackTemp4',
       'NoPlan',
       { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'del0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1U1B1LAttackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 6,
       Priority = 300,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1UEF1Base1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.ALLUNITS * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1U1B1Landattack1', 'P1U1B1Landattack2', 'P1U1B1Landattack3'}
       },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
       'P1U1B1LAttackTemp5',
       'NoPlan',
       { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uel0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1U1B1LAttackBuilder5',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 305,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1UEF1Base1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1U1B1Landattack1', 'P1U1B1Landattack2', 'P1U1B1Landattack3'}
       },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
       'P1U1B1LAttackTemp6',
       'NoPlan',
       { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uel0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1U1B1LAttackBuilder6',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 315,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1UEF1Base1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.ALLUNITS * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1U1B1Landattack1', 'P1U1B1Landattack2', 'P1U1B1Landattack3'}
       },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    opai = P1U1Base1:AddOpAI('EngineerAttack', 'M1B1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1U1B1Landattack1', 'P1U1B1Landattack2', 'P1U1B1Landattack3'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 3)
end

function P1U1B1Navalattacks()

    local quantity = {}
    local quantity2 = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P1U1B1NAttackTemp0',
        'NoPlan',
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, 2, 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P1U1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1BNavalattack1', 'P1U1BNavalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 7}
    Temp = {
        'P1U1B1NAttackTemp1',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1U1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1BNavalattack1', 'P1U1BNavalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    quantity2 = {2, 3, 4}
    Temp = {
        'P1U1B1NAttackTemp2',
        'NoPlan',
        { 'ues0103', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1U1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 40, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1BNavalattack1', 'P1U1BNavalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    Temp = {
        'P1U1B1NAttackTemp3',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1U1B1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 215,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1BNavalattack1', 'P1U1BNavalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    Temp = {
        'P1U11B1NAttackTemp5',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0103', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1U1B1NAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1U1BNavalPatrol1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end

function P1U1Base2AI()

    P1U1Base2:InitializeDifficultyTables(ArmyBrains[UEF1], 'P1UEF1Base2', 'P1U1B2MK', 90, {P1U1Base2 = 100})
    P1U1Base2:StartNonZeroBase({{5, 7, 9}, {4, 6, 8}})
    P1U1Base2:SetActive('AirScouting', true)
    
    P1U1B2Airattacks()
    P1U1B2Landattacks()
    P1U1B2Navalattacks() 

    P1U1Base2:AddBuildGroup('P1U1Base2N', 90)  
end

function P1U1B2Airattacks()
    
    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P1U1B2AttackTemp0',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1U1B2AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1U1B2Airpatrol1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    Temp = {
        'P1U1B2AttackTemp1',
        'NoPlan',
        { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1U1B2AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B2Airattack1','P1U1B2Airattack2', 'P1U1B2Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 9}
    Temp = {
       'P1U1B2AttackTemp2',
       'NoPlan',
       { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1U1B2AttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1UEF1Base2', 
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1U1B2Airattack1','P1U1B2Airattack2', 'P1U1B2Airattack3'}
       },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P1U1B2AttackTemp3',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1U1B2AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B2Airattack1','P1U1B2Airattack2', 'P1U1B2Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    Temp = {
        'P1U1B2AttackTemp4',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1U1B2AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 6, categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B2Airattack1','P1U1B2Airattack2', 'P1U1B2Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {7, 9, 12}
    Temp = {
        'P1U1B2AttackTemp5',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1U1B2AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.ALLUNITS * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B2Airattack1','P1U1B2Airattack2', 'P1U1B2Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )     

    quantity = {6, 7, 9}
    opai = P1U1Base2:AddOpAI('AirAttacks', 'M1_U1B2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = {categories.NAVAL * categories.MOBILE * categories.TECH3},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.NAVAL * categories.MOBILE * categories.TECH3, '>='})
end

function P1U1B2Landattacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P1U1B2LAttackTemp0',
        'NoPlan',
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P1U1B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},
        PlatoonData = {
           MoveChains = {'P1U1B2Landattack1', 'P1U1B2Landattack2', 'P1U1B2Landattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 8}
    Temp = {
        'P1U1B2LAttackTemp1',
        'NoPlan',
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1U1B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P1U1B2Landattack1', 'P1U1B2Landattack2', 'P1U1B2Landattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder ) 

    opai = P1U1Base2:AddOpAI('EngineerAttack', 'M1B2_UEF1_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1U1B2MK',
        },
        Priority = 1100,
    })
    opai:SetChildQuantity('T2Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 2, categories.uea0104})
    
    quantity = {6, 8, 12}
    opai = P1U1Base2:AddOpAI('BasicLandAttack', 'M1B2_UEF1_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1U1B2Dropattack1', 
                LandingChain = 'P1U1B2Drop',
                TransportReturn = 'P1U1B2MK',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    quantity = {6, 8, 12}
    opai = P1U1Base2:AddOpAI('BasicLandAttack', 'M1B2_UEF1_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1U1B2Dropattack1', 
                LandingChain = 'P1U1B2Drop',
                TransportReturn = 'P1U1B2MK',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    -- Extra engineers assisting T2 naval factories, all T2 factories has to be built
    -- Count is {X, 0} since the platoon contains shields/stealth as well and we want just the engineers. And too lazy to make a new platoon rn.
    quantity = {{4, 0}, {5, 0}, {6, 0}}
    opai = P1U1Base2:AddOpAI('EngineerAttack', 'M1_UEF1_Assist_Engineers_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'P2UEF2Base1',
                Factories = categories.TECH2 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 300,
        }
    )
    opai:SetChildQuantity('T2Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.TECH2 * categories.NAVAL * categories.FACTORY})

    opai = P1U1Base2:AddOpAI('EngineerAttack', 'M1B2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1U1B2Landattack1', 'P1U1B2Landattack2', 'P1U1B2Landattack3'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 3)
end

function P1U1B2Navalattacks()

    local quantity = {}

    quantity = {1, 2, 3}
    local Temp = {
        'P1U1B2NAttackTemp0',
        'NoPlan',
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P1U1B2NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B2Navalattack1', 'P1U1B2Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {1, 1, 2}
    Temp = {
        'P1U1B2NAttackTemp1',
        'NoPlan',
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1U1B2NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 40, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B2Navalattack1', 'P1U1B2Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'P1U1B2NAttackTemp2',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1U1B2NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1U1B2Navalattack1', 'P1U1B2Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end