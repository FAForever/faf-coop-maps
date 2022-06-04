local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local KOrder = 4
local Order = 3

local P1KO1base1 = BaseManager.CreateBaseManager()
local P1KO1base2 = BaseManager.CreateBaseManager()
local P1O1base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P1KO1Base1AI()

    P1KO1base1:InitializeDifficultyTables(ArmyBrains[KOrder], 'P1KOrder1Base1', 'P1KO1base1MK', 80, {P1KO1Base1 = 100})
    P1KO1base1:StartNonZeroBase({{14, 18, 22}, {12, 16, 20}})
    P1KO1base1:SetActive('AirScouting', true)

    P1KO1B1Airattacks()
    P1KO1B1Navalattacks()
    P1KO1B1Landattacks() 
end

function P1KO1B1Airattacks()

    local quantity = {}

    quantity = {3, 4, 5}
    local Temp = {
        'P1KO1B1AttackTemp0',
        'NoPlan',
        { 'uaa0102', 1, 5, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 8}
    Temp = {
        'P1KO1B1AttackTemp1',
        'NoPlan',
        { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    Temp = {
        'P1KO1B1AttackTemp2',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Airdefense1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P1KO1B1AttackTemp4',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Airdefense2'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
        'P1KO1B1AttackTemp5',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 12, (categories.STRUCTURE + categories.LAND) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    Temp = {
        'P1KO1B1AttackTemp6',
        'NoPlan',
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1KO1B1AttackTemp7',
        'NoPlan',
        { 'uaa0203', 1, 6, 'Attack', 'GrowthFormation' },
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P1KO1B1AttackTemp8',
        'NoPlan',
        { 'xaa0202', 1, 5, 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder8',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 310,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 12, categories.TECH3 * categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'P1KO1B1AttackTemp9',
        'NoPlan',
        { 'uaa0204', 1, 5, 'Attack', 'GrowthFormation' },
        { 'xaa0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder9',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 305,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.TECH3 * categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1KO1B1Landattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P1KO1B2LAttackTemp0',
        'NoPlan',
        { 'ual0104', 1, 4, 'Attack', 'GrowthFormation' }, 
        { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Landattack1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P1KO1B2LAttackTemp1',
        'NoPlan',
        { 'ual0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0104', 1, 4, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 6, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Landattack1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P1KO1B2LAttackTemp2',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 2, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, (categories.STRUCTURE + categories.LAND) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Landattack1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P1KO1B2LAttackTemp3',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 2, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Landattack1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P1KO1B2LAttackTemp4',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 2, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P1KOB1Landattack1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1KO1B2LAttackTemp5',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dalk003', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 310,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 12, categories.TECH3 * categories.AIR}},
        },
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P1KOB1Landattack1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1KO1B1Navalattacks()

    local quantity = {}

    quantity = {1, 2, 3}
    local Temp = {
        'P1KO1B1NAttackTemp0',
        'NoPlan',
        { 'uas0203', 1, 5, 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, 5, 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Navaldefense1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    Temp = {
        'P1KO1B1NAttackTemp1',
        'NoPlan',
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
     
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    Temp = {
        'P1KO1B1NAttackTemp2',
        'NoPlan',
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 6, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 2, 3}
    Temp = {
        'P1KO1B1NAttackTemp3',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0203', 1, 3, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 4, categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    Temp = {
        'P1KO1B1NAttackTemp4',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P1KO1B1NAttackTemp5',
        'NoPlan',
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.TECH3 * categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1O1Base1AI()

    P1O1base1:InitializeDifficultyTables(ArmyBrains[Order], 'P1Order1Base1', 'P1O1base1MK', 70, {P1O1Base1 = 100})
    P1O1base1:StartNonZeroBase({{11, 9, 7}, {10, 8, 6}})
    
    P1O1B1Navalattacks()
    P1O1B1Airattacks()
    P1O1B1Landattacks()
end

function P1O1B1Airattacks()

    local Temp = {
        'P1O1B1AttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, 5, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, 5, 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1O1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1OB1Airdefense1'
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1O1B1AttackTemp1',
        'NoPlan',
        { 'uaa0203', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1O1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1OB1Airattack1','P1OB1Airattack2','P1OB1Airattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P1O1B1Navalattacks()

    local Temp = {
        'P1O1B1NAttackTemp0',
        'NoPlan',
        { 'uas0102', 1, 3, 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, 1, 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1O1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1OB1Navaldefense1'
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1O1B1NAttackTemp1',
        'NoPlan',  
        { 'uas0103', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, 1, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1O1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1OB1Navalattack1', 'P1OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P1O1B1Landattacks()

    local Temp = {
        'P1O1B1LAttackTemp0',
        'NoPlan',
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'ual0201', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xal0203', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1O1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1OB1Navalattack1', 'P1OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )  
end
