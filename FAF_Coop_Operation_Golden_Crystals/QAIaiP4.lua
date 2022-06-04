local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local CustomFunctions = '/maps/FAF_Coop_Operation_Golden_Crystals/FAF_Coop_Operation_Golden_Crystals_CustomFunctions.lua'

local Player1 = 1
local QAI = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local QAIP4base1 = BaseManager.CreateBaseManager()
local QAIP4base2 = BaseManager.CreateBaseManager()
local QAIP4base3 = BaseManager.CreateBaseManager()
local QAIP4base4 = BaseManager.CreateBaseManager()
local QAIP4base5 = BaseManager.CreateBaseManager()
local QAIP4base6 = BaseManager.CreateBaseManager()

function QAIP4base1AI()

    QAIP4base1:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP4base1', 'QAIP4base1MK', 80, {P4Qbase1 = 100})
    QAIP4base1:StartNonZeroBase({{9, 12, 14}, {5, 8, 10}})
    QAIP4base1:SetActive('AirScouting', true)

    QP4B1landattacks()
    P4QB1Exp()
end

function QP4B1landattacks()
    
    local quantity = {}

    quantity = {6, 8, 10}
    local Temp = {
       'QP4B1landAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP4B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB1Landattack1', 'P4QB1Landattack2', 'P4QB1Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 10}
    Temp = {
       'QP4B1landAttackTemp1',
       'NoPlan',
       { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP4B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB1Landattack1', 'P4QB1Landattack2', 'P4QB1Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 10}
    Temp = {
       'QP4B1landAttackTemp2',
       'NoPlan',
       { 'drlk001', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP4B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB1Landattack1', 'P4QB1Landattack2', 'P4QB1Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P4QB1Exp()

    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = QAIP4base1:AddOpAI('P4Sbot1',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_ML_Platoon1',
                NumRequired = 2,
                PatrolChain = 'P4QB1Landattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function QAIP4base2AI()

    QAIP4base2:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP4base2', 'QAIP4base2MK', 80, {P4Qbase2 = 100})
    QAIP4base2:StartNonZeroBase({{9, 12, 14}, {5, 8, 10}})
    QAIP4base2:SetActive('AirScouting', true)
    
    QP4B2Airattacks()
    P4QB2Exp()  
end

function QP4B2Airattacks()
    
    local quantity = {}

    quantity = {5, 8, 10}
    local Temp = {
        'QP4B2AirAttackTemp0',
        'NoPlan',   
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'QP4B2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P4QAirdefense1'
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    Temp = {
        'QP4B2AirAttackTemp1',
        'NoPlan',   
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'QP4B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4QB2Airattack1','P4QB2Airattack2', 'P4QB2Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 15}
    Temp = {
        'QP4B2AirAttackTemp2',
        'NoPlan',   
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'QP4B2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4QB2Airattack1','P4QB2Airattack2', 'P4QB2Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 15}
    opai = QAIP4base2:AddOpAI('AirAttacks', 'M4_QAIB2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {8, 10, 15}
    opai = QAIP4base2:AddOpAI('AirAttacks', 'M4_QAIB2_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.AIR, '>='})
end

function P4QB2Exp()

    local opai = nil
    local quantity = {}

    quantity = {2, 3, 4}
    opai = QAIP4base2:AddOpAI('P4Gunship2',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_Gunship_Platoon1',
                NumRequired = 2,
                PatrolChain = 'P4QB2Airattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function QAIP4base3AI()

    QAIP4base3:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP4base3', 'QAIP4base3MK', 80, {P4Qbase3 = 100})
    QAIP4base3:StartNonZeroBase({{10, 12, 18}, {6, 8, 12}})
    QAIP4base3:SetActive('AirScouting', true)
    
    QP4B3Airattacks() 
    P4QB3Exp() 
end

function QP4B3Airattacks()
    
    local quantity = {}

    quantity = {5, 8, 10}
    local Temp = {
        'QP4B3AirAttackTemp0',
        'NoPlan',   
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'QP4B3AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base3',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P4QAirdefense2'
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
        'QP4B3AirAttackTemp1',
        'NoPlan',   
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'QP4B3AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4QB3Airattack1','P4QB3Airattack2', 'P4QB3Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    Temp = {
       'QP4B3AirAttackTemp2',
       'NoPlan',   
       { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP4B3AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4QB3Airattack1','P4QB3Airattack2', 'P4QB3Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {12, 14, 18}
    opai = QAIP4base3:AddOpAI('AirAttacks', 'M4_QAIB3_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.AIR, '>='})

    quantity = {12, 14, 18}
    opai = QAIP4base3:AddOpAI('AirAttacks', 'M4_QAIB3_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P4QB3Exp()

    local opai = nil
    local quantity = {}
    quantity = {2, 4, 6}
    opai = QAIP4base3:AddOpAI('P4End',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB4Landattack1', 'P4QB4Landattack2', 'P4QB4Landattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function QAIP4base4AI()

    QAIP4base4:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP4base4', 'QAIP4base4MK', 80, {P4Qbase4 = 100})
    QAIP4base4:StartNonZeroBase({{7, 8, 10}, {3, 4, 6}})
    QAIP4base4:SetActive('AirScouting', true)

    QP4B4landattacks()
    P4QB4Exp()
end

function QP4B4landattacks()
    
    local quantity = {}

    quantity = {6, 7, 9}
    local Temp = {
       'QP4B4landAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP4B4AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB4Landattack1', 'P4QB4Landattack2', 'P4QB4Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    Temp = {
       'QP4B4landAttackTemp1',
       'NoPlan',
       { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP4B4AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB4Landattack1', 'P4QB4Landattack2', 'P4QB4Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    Temp = {
       'QP4B4landAttackTemp2',
       'NoPlan',
       { 'drlk001', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP4B4AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB4Landattack1', 'P4QB4Landattack2', 'P4QB4Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P4QB4Exp()

    local opai = nil
    local quantity = {}
    
    quantity = {3, 4, 5}
    opai = QAIP4base4:AddOpAI('P4Mega1',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_MB_Platoon1',
                NumRequired = 2,
                PatrolChain = 'P4QB4Landattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 3, categories.EXPERIMENTAL, '>='},
                },
            }
        }
    )
end

function QAIP4base5AI()

    QAIP4base5:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP4base5', 'QAIP4base5MK', 80, {P4Qbase5 = 100})
    QAIP4base5:StartNonZeroBase({{8, 9, 10}, {3, 5, 6}})
    QAIP4base5:SetActive('AirScouting', true)

    QP4B5Airattacks()
    P4QB5Exp()
end

function QP4B5Airattacks()
    
    local quantity = {}

    quantity = {5, 8, 10}
    local Temp = {
        'QP4B5AirAttackTemp0',
        'NoPlan',   
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'QP4B5AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base5',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P4QAirdefense3'
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    Temp = {
        'QP4B5AirAttackTemp1',
        'NoPlan',   
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'QP4B5AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base5',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4QB5Airattack1','P4QB5Airattack2', 'P4QB5Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    Temp = {
        'QP4B5AirAttackTemp2',
        'NoPlan',   
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'QP4B5AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP4base5',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P4QB5Airattack1','P4QB5Airattack2', 'P4QB5Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 12, 15}
    opai = QAIP4base5:AddOpAI('AirAttacks', 'M4_QAIB5_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.STRUCTURE },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.STRUCTURE, '>='})
end

function P4QB5Exp()

    local opai = nil
    local quantity = {}

    quantity = {2, 3, 4}
    opai = QAIP4base5:AddOpAI('P4Gunship1',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_Gunship_Platoon2',
                NumRequired = 2,
                PatrolChain = 'P4QB5Airattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function QAIP4base6AI()

    QAIP4base6:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP4base6', 'QAIP4base6MK', 80, {P4Qbase6 = 100})
    QAIP4base6:StartNonZeroBase({{10, 13, 16}, {6, 9, 12}})
    QAIP4base6:SetActive('AirScouting', true)

    QP4B6landattacks()
    P4QB6Exp()
end

function QP4B6landattacks()
    
    local quantity = {}

    quantity = {6, 9, 12}
    local Temp = {
       'QP4B6landAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP4B6AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base6',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB6Landattack1', 'P4QB6Landattack2', 'P4QB6Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    Temp = {
       'QP4B6landAttackTemp1',
       'NoPlan',
       { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP4B6AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base6',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 50, categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB6Landattack1', 'P4QB6Landattack2', 'P4QB6Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    Temp = {
       'QP4B6landAttackTemp2',
       'NoPlan',
       { 'drlk001', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP4B6AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP4base6',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 50, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4QB6Landattack1', 'P4QB6Landattack2', 'P4QB6Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P4QB6Exp()

    local opai = nil
    local quantity = {}

    quantity = {2, 3, 4}
    opai = QAIP4base6:AddOpAI('P4Sbot2',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_Gunship_Platoon2',
                NumRequired = 2,
                PatrolChain = 'P4QB6Landattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end
