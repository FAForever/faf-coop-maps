local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Golden_Crystals/FAF_Coop_Operation_Golden_Crystals_CustomFunctions.lua'

local Player1 = 1
local QAI = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local QAIbase1 = BaseManager.CreateBaseManager()
local QAIbase2 = BaseManager.CreateBaseManager()

function QAIbase1AI()

    QAIbase1:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP1base1', 'QAIP1base1MK', 40, {P1Qbase1 = 600})
    QAIbase1:StartNonZeroBase({{7, 10, 12}, {5, 8, 10}})

    QP1B1landattacks()
    QP1B1Airattacks()
end

function QP1B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
       'Q1B1AirAttackTemp0',
       'NoPlan',   
       { 'ura0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'Q1B1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1QB2Airdefence'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 4}
    trigger = {10, 5, 1}
    Temp = {
       'Q1B1AirAttackTemp1',
       'NoPlan',   
       { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'Q1B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    trigger = {6, 4, 4}
    Temp = {
        'Q1B1AirAttackTemp2',
        'NoPlan',   
        { 'ura0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'Q1B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {40, 35, 30}
    Temp = {
        'Q1B1AirAttackTemp3',
        'NoPlan',   
        { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'Q1B1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 107,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {10, 7, 4}
    Temp = {
        'Q1B1AirAttackTemp4',
        'NoPlan',   
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xra0105', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'Q1B1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {6, 5, 4}
    Temp = {
        'Q1B1AirAttackTemp5',
        'NoPlan',   
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'Q1B1AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {25, 20, 15}
    Temp = {
        'Q1B1AirAttackTemp6',
        'NoPlan',   
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'Q1B1AirAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function QP1B1landattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    local Temp = {
       'QP1B1landAttackTemp0',
       'NoPlan',
       { 'url0107', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0202', 1, 4, 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 190,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1QB2OutPatrol1'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {10, 1, 1}
    Temp = {
       'QP1B1landAttackTemp1',
       'NoPlan',
       { 'url0106', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {35, 25, 15}
    Temp = {
       'QP1B1landAttackTemp2',
       'NoPlan',
       { 'url0107', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {18, 13, 8}
    Temp = {
       'QP1B1landAttackTemp3',
       'NoPlan',
       { 'url0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {20, 15, 10}
    Temp = {
       'QP1B1landAttackTemp4',
       'NoPlan',
       { 'url0104', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 108,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    trigger = {18, 12, 7}
    Temp = {
       'QP1B1landAttackTemp5',
       'NoPlan',
       { 'drl0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {15, 10, 6}
    Temp = {
       'QP1B1landAttackTemp6',
       'NoPlan',
       { 'url0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {16, 12, 8}
    Temp = {
       'QP1B1landAttackTemp7',
       'NoPlan',
       { 'url0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 204,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    trigger = {15, 10, 3}
    Temp = {
       'QP1B1landAttackTemp8',
       'NoPlan',
       { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder8',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    opai = QAIbase1:AddOpAI('EngineerAttack', 'M1B1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

function QAIbase2AI()

    QAIbase2:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP1base2', 'QAIP1base2MK', 40, {P1Qbase2 = 600})
    QAIbase2:StartNonZeroBase({{7, 10, 12}, {5, 8, 10}})

    
    QP1B2landattacks()
    QP1B2Airattacks() 
end

function QP1B2landattacks()
    
    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
       'QP1B2landAttackTemp0',
       'NoPlan',
       { 'url0107', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0202', 1, 4, 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP1B2landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 190,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1QB1OutPatrol1'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {10, 1, 1}
    Temp = {
       'QP1B2landAttackTemp1',
       'NoPlan',
       { 'url0106', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2landAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {2, 5, 6}
    trigger = {38, 28, 18}
    Temp = {
       'QP1B2landAttackTemp2',
       'NoPlan',
       { 'url0107', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2landAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {18, 13, 8}
    Temp = {
       'QP1B2landAttackTemp3',
       'NoPlan',
       { 'url0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0104', 1, 2, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2landAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {18, 12, 7}
    Temp = {
       'QP1B2landAttackTemp4',
       'NoPlan',
       { 'drl0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2landAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {17, 12, 8}
    Temp = {
       'QP1B2landAttackTemp5',
       'NoPlan',
       { 'url0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2landAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 7}
    trigger = {15, 10, 3}
    Temp = {
       'QP1B2landAttackTemp6',
       'NoPlan',
       { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0306', 1, 1, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2landAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )     

    opai = QAIbase2:AddOpAI('EngineerAttack', 'M1B2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1QB1landattack1','P1QB1landattack2'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

function QP1B2Airattacks()

    local quantity = {}

    quantity = {2, 3, 4}
    trigger = {15, 9, 1}
    local Temp = {
       'QP1B2AirAttackTemp1',
       'NoPlan',
       { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP1B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = quantity[Difficulty],
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 7}
    trigger = {70, 55, 45}
    Temp = {
       'QP1B2AirAttackTemp2',
       'NoPlan',
       { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {8, 5, 1}
    Temp = {
       'QP1B2AirAttackTemp3',
       'NoPlan',
       { 'xra0105', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    trigger = {12, 9, 6}
    Temp = {
       'QP1B2AirAttackTemp4',
       'NoPlan',
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {6, 5, 4}
    Temp = {
        'Q1B2AirAttackTemp5',
        'NoPlan',   
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'Q1B2AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2','P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    trigger = {28, 23, 18}
    Temp = {
       'QP1B2AirAttackTemp6',
       'NoPlan',
       { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2AirAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end
