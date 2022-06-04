local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local Player1 = 1
local QAI = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local QAIbase1 = BaseManager.CreateBaseManager()
local QAIbase2 = BaseManager.CreateBaseManager()

function QAIbase1AI()

    QAIbase1:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP1base1', 'QAIP1base1MK', 60, {P1Qbase1 = 600})
    QAIbase1:StartNonZeroBase({{7, 10, 12}, {5, 8, 10}})
    QAIbase1:SetActive('AirScouting', true)

    QP1B1landattacks()
    QP1B1Airattacks()
end

function QP1B1Airattacks()

    local quantity = {}

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

    quantity = {1, 2, 3}
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
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
        {'default_brain',  {'HumanPlayers'}, 6, categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
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
        {'default_brain',  {'HumanPlayers'}, 55, categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
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
        {'default_brain',  {'HumanPlayers'}, 4, categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'Q1B1AirAttackTemp5',
        'NoPlan',   
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ura0102', 1, 4, 'Attack', 'GrowthFormation' },
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
        {'default_brain',  {'HumanPlayers'}, 4, categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2airattack1','P1QB2airattack2','P1QB2airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'Q1B1AirAttackTemp6',
        'NoPlan',   
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ura0102', 1, 4, 'Attack', 'GrowthFormation' },
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
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
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

    local Temp = {
       'QP1B1landAttackTemp0',
       'NoPlan',
       { 'url0107', 1, 6, 'Attack', 'GrowthFormation' },
       { 'url0202', 1, 4, 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
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
        {'default_brain',  {'HumanPlayers'}, 35, categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
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
        {'default_brain',  {'HumanPlayers'}, 6, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
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
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
       'QP1B1landAttackTemp5',
       'NoPlan',
       { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0107', 1, 4, 'Attack', 'GrowthFormation' },
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
        {'default_brain',  {'HumanPlayers'}, 6, categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
       'QP1B1landAttackTemp6',
       'NoPlan',
       { 'drl0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B1AttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 8, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
       'QP1B1landAttackTemp7',
       'NoPlan',
       { 'url0107', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0205', 1, 2, 'Attack', 'GrowthFormation' },
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
        {'default_brain',  {'HumanPlayers'}, 5, categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB2landattack1', 'P1QB2landattack2', 'P1QB2landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
       'QP1B1landAttackTemp8',
       'NoPlan',
       { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0306', 1, 1, 'Attack', 'GrowthFormation' },
       { 'url0103', 1, 5, 'Attack', 'GrowthFormation' },
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
        {'default_brain',  {'HumanPlayers'}, 2, categories.TECH3}},
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

    QAIbase2:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP1base2', 'QAIP1base2MK', 60, {P1Qbase2 = 600})
    QAIbase2:StartNonZeroBase({{7, 10, 12}, {5, 8, 10}})
    QAIbase2:SetActive('AirScouting', true)
    
    QP1B2landattacks()
    QP1B2Airattacks() 
end

function QP1B2landattacks()
    
    local quantity = {}

    local Temp = {
       'QP1B2landAttackTemp0',
       'NoPlan',
       { 'url0107', 1, 6, 'Attack', 'GrowthFormation' },
       { 'url0103', 1, 4, 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP1B2landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {2, 5, 6}
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
        {'default_brain',  {'HumanPlayers'}, 25, categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
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
        {'default_brain',  {'HumanPlayers'}, 5, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1landattack1','P1QB1landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
       'QP1B2landAttackTemp4',
       'NoPlan',
       { 'url0107', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0104', 1, 4, 'Attack', 'GrowthFormation' },
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
        {'default_brain',  {'HumanPlayers'}, 5, categories.ALLUNITS - categories.TECH1}},
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 7}
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
        {'default_brain',  {'HumanPlayers'}, 45, categories.ALLUNITS - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 7}
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
        {'default_brain',  {'HumanPlayers'}, 6, categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    Temp = {
       'QP1B2AirAttackTemp4',
       'NoPlan',
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xra0105', 1, 3, 'Attack', 'GrowthFormation' },
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
        {'default_brain',  {'HumanPlayers'}, 15, categories.ALLUNITS - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
       'QP1B2AirAttackTemp5',
       'NoPlan',
       { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0102', 1, 4, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP1B2AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1QB1airattack1','P1QB1airattack2', 'P1QB1airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end
