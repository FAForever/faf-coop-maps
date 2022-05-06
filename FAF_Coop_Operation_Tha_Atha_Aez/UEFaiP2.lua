local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local UEF = 3
local Player1 = 1
local Difficulty = ScenarioInfo.Options.Difficulty

local UEFbase1 = BaseManager.CreateBaseManager()
local UEFbase2 = BaseManager.CreateBaseManager()
local UEFbase3 = BaseManager.CreateBaseManager()
local UEFbase4 = BaseManager.CreateBaseManager()


function P2UEFbase1AI()
    UEFbase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P2UEFbase1', 'P2UB1MK', 50, {P2UBase1 = 100})
    UEFbase1:StartNonZeroBase({{8, 11, 13}, {5, 8, 10}})
 
    P1UB1landAttacks()
    P1UB1Airattacks()
end

function P1UB1landAttacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P2UB1LandAttackTemp1',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
        BuilderName = 'P2UB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2', 'P2UB1landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {24, 22, 20}
    Temp = {
        'P2UB1LandAttackTemp2',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2', 'P2UB1landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    Temp = {
        'P2UB1LandAttackTemp3',
        'NoPlan',
        { 'uel0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2', 'P2UB1landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {6, 5, 4}
    Temp = {
        'P2UB1LandAttackTemp4',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB1LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2', 'P2UB1landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    trigger = {40, 37, 35}
    Temp = {
        'P2UB1LandAttackTemp5',
        'NoPlan',
        { 'xel0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB1LandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2', 'P2UB1landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {28, 26, 24}
    Temp = {
        'P2UB1LandAttackTemp6',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },
        { 'del0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB1LandAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2', 'P2UB1landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
 
function P1UB1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2UB1AirAttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --ASFs
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --Gunships
        { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --fighters
    }
    local Builder = {
        BuilderName = 'P2UB1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2UB1Defence1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P2UB1AirAttackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1airattack1', 'P2UB1airattack2', 'P2UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {9, 8, 6}
    Temp = {
        'P2UB1AirAttackTemp2',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1airattack1', 'P2UB1airattack2', 'P2UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {15, 14, 10}
    Temp = {
        'P2UB1AirAttackTemp3',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, 6, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1airattack1', 'P2UB1airattack2', 'P2UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    Temp = {
        'P2UB1AirAttackTemp4',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, 6, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * (categories.TECH3 + categories.TECH2)}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1airattack1', 'P2UB1airattack2', 'P2UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P2UEFbase2AI()
    UEFbase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P2UEFbase2', 'P2UB2MK', 50, {P2UBase2 = 100})
    UEFbase2:StartNonZeroBase({{8, 11, 13}, {5, 8, 10}})

    P1UB2landattacks()
    P1UB2Airattacks()
end
 
function P1UB2landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 8}
    local Temp = {
        'P2UB2LandAttackTemp1',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
        BuilderName = 'P2UB2LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2', 'P2UB2landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {29, 27, 25}
    Temp = {
        'P2UB2LandAttackTemp2',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB2LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2', 'P2UB2landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {19, 17, 15}
    Temp = {
        'P2UB2LandAttackTemp3',
        'NoPlan',
        { 'uel0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB2LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2', 'P2UB2landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {8, 7, 6}
    Temp = {
        'P2UB2LandAttackTemp4',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB2LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2', 'P2UB2landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    trigger = {45, 42, 40}
    Temp = {
        'P2UB2LandAttackTemp5',
        'NoPlan',
        { 'xel0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB2LandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2', 'P2UB2landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {18, 16, 14}
    Temp = {
        'P2UB2LandAttackTemp6',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },
        { 'del0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB2LandAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2', 'P2UB2landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
 
function P1UB2Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2UB2AirAttackTemp0',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --fighter/bombers
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --Gunships
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --fighters
    }
    local Builder = {
        BuilderName = 'P2UB2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2UB2Defence1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P2UB2AirAttackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2airattack1', 'P2UB2airattack2', 'P2UB2airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {11, 10, 8}
    Temp = {
        'P2UB2AirAttackTemp2',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2airattack1', 'P2UB2airattack2', 'P2UB2airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    trigger = {25, 22, 20}
    Temp = {
        'P2UB2AirAttackTemp3',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, 5, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB2AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.MOBILE * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2airattack1', 'P2UB2airattack2', 'P2UB2airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {8, 6, 4}
    Temp = {
        'P2UB2AirAttackTemp4',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, 5, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB2AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB2airattack1', 'P2UB2airattack2', 'P2UB2airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P2UEFbase3AI()
    UEFbase3:InitializeDifficultyTables(ArmyBrains[UEF], 'P2UEFbase3', 'P2UB3MK', 50, {P2UBase3 = 300})
    UEFbase3:StartEmptyBase({{3, 4, 5}, {2, 3, 4}})
    
    UEFbase2:AddExpansionBase('P2UEFbase3', 2)
    
    P1UB3landattacks()
end
 
function P1UB3landattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P2UB3LandAttackTemp1',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
        BuilderName = 'P2UB3LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P2UB3LandAttackTemp2',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB3LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    Temp = {
        'P2UB3LandAttackTemp3',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uel0205', 1, 2, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB3LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P2UEFbase4AI()
    UEFbase4:InitializeDifficultyTables(ArmyBrains[UEF], 'P2UEFbase4', 'P2UB4MK', 50, {P2UBase4 = 300})
    UEFbase4:StartEmptyBase({{3, 4, 5}, {2, 3, 4}})
    
    UEFbase1:AddExpansionBase('P2UEFbase4', 2)
    
    P1UB4Airattacks()
end

function P1UB4Airattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P2UB4AirAttackTemp0',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --Gunships
    }
    local Builder = {
        BuilderName = 'P2UB4AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P1UB4Airattack1', 'P1UB4Airattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    Temp = {
        'P2UB4AirAttackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB4AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P1UB4Airattack1', 'P1UB4Airattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P2UB4AirAttackTemp2',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB4AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFbase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P1UB4Airattack1', 'P1UB4Airattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
