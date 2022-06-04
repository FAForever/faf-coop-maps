local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local CustomFunctions = '/maps/FAF_Coop_Operation_Golden_Crystals/FAF_Coop_Operation_Golden_Crystals_CustomFunctions.lua'

local Player1 = 1
local QAI = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local QAIP3base1 = BaseManager.CreateBaseManager()
local QAIP3base2 = BaseManager.CreateBaseManager()
local QAIP3base3 = BaseManager.CreateBaseManager()


function QAIP3base1AI()

    QAIP3base1:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP3base1', 'QAIP3base1MK', 80, {P3Qbase1 = 100})
    QAIP3base1:StartNonZeroBase({{12, 16, 20}, {8, 12, 16}})
    QAIP3base1:SetActive('AirScouting', true)

    QP3B1landattacks()
    QP3B1Airattacks()
    P3QB1Exp()
end

function QP3B1Airattacks()
    
    local quantity = {}

    quantity = {5, 8, 10}
    local Temp = {
       'QP3B1AirAttackTemp0',
       'NoPlan',   
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP3B1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP3base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1Airattack1', 'P3QB1Airattack2', 'P3QB1Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'QP3B1AirAttackTemp1',
       'NoPlan',   
       { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1Airattack1', 'P3QB1Airattack2', 'P3QB1Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'QP3B1AirAttackTemp2',
       'NoPlan',   
       { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1Airattack1', 'P3QB1Airattack2', 'P3QB1Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 15}
    opai = QAIP3base1:AddOpAI('AirAttacks', 'M3_QAI1B1_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.AIR + categories.EXPERIMENTAL },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.AIR + categories.EXPERIMENTAL, '>='})
end

function QP3B1landattacks()
    
    local quantity = {}

    quantity = {6, 7, 9}
    local Temp = {
       'QP3B1landAttackTemp0',
       'NoPlan',
       { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP3B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1landattack1', 'P3QB1landattack2', 'P3QB1landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
       'QP3B1landAttackTemp1',
       'NoPlan',
       { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1landattack1', 'P3QB1landattack2', 'P3QB1landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
       'QP3B1landAttackTemp2',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'drlk001', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1landattack1', 'P3QB1landattack2', 'P3QB1landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {7, 8, 9}
    Temp = {
       'QP3B1landAttackTemp3',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },
       { 'url0205', 1, 3, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1landattack1', 'P3QB1landattack2', 'P3QB1landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P3QB1Exp()

    local opai = nil
    local quantity = {}   

    opai = QAIP3base1:AddOpAI({'P3B1Bot2','P3B1Bug1','P3B1Bot1'},
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
                PatrolChains = {'P3QB1landattack1','P3QB1landattack2', 'P3QB1landattack3'}
            },
            MaxAssist = 4,
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 1, categories.EXPERIMENTAL, '>='},
                },
            }
        }
    )
end

function QAIP3base2AI()

    QAIP3base2:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP3base2', 'QAIP3base2MK', 80, {P3Qbase2 = 100})
    QAIP3base2:StartNonZeroBase({{13, 16, 20}, {7, 10, 14}})
    QAIP3base2:SetActive('AirScouting', true)
    
    QP3B2Airattacks()
    QP3B2landattacks()
    P3QB2Exp()  
end

function QP3B2Airattacks()
    
    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
       'QP3B2AirAttackTemp0',
       'NoPlan',   
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP3B2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP3base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3QB2Airattack1','P3QB2Airattack2', 'P3QB2Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
       'QP3B2AirAttackTemp1',
       'NoPlan',   
       { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 6, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3QB2Airattack1','P3QB2Airattack2', 'P3QB2Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    opai = QAIP3base2:AddOpAI('AirAttacks', 'M3_QAI1B2_Air_Attack_1',
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
end

function QP3B2landattacks()
    
    local quantity = {}

    quantity = {5, 8, 10}
    local Temp = {
       'QP3B2landAttackTemp0',
       'NoPlan',
       { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP3B2AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB2landattack1', 'P3QB2landattack2', 'P3QB2landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
       'QP3B2landAttackTemp1',
       'NoPlan',
       { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0205', 1, 4, 'Attack', 'GrowthFormation' },
       { 'drlk001', 1, 2, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B2AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3QB2landattack1', 'P3QB2landattack2', 'P3QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'QP3B2landAttackTemp2',
       'NoPlan',
       { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0111', 1, 4, 'Attack', 'GrowthFormation' },
       { 'url0304', 1, 2, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B2AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3QB2landattack1', 'P3QB2landattack2', 'P3QB2landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'QP3B2landAttackTemp3',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },
       { 'url0205', 1, 2, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B2AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 40, categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB2landattack1', 'P3QB2landattack2', 'P3QB2landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P3QB2Exp()

    local opai = nil
    local quantity = {}
    
    quantity = {0, 1, 2}
        opai = QAIP3base2:AddOpAI('P3B2Bot1',
            {
                Amount = quantity[Difficulty],
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M3_ML_Platoon',
                    NumRequired = quantity[Difficulty],
                    PatrolChain = 'P3QB2landattack' .. Random(1, 3),
                },
                MaxAssist = 3,
                Retry = true,
                BuildCondition = {
                    {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                        {{'HumanPlayers'}, 1, categories.EXPERIMENTAL, '>='},
                    },
                }
            }
        )
end

function QAIP3base3AI()

    QAIP3base3:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP3base3', 'QAIP3base3MK', 80, {P3Qbase3 = 100})
    QAIP3base3:StartNonZeroBase({{15, 20, 25}, {10, 15, 20}})
    QAIP3base3:SetActive('AirScouting', true)

    QP3B3landattacks()
    QP3B3Airattacks()
    P3QB3Exp()
end

function QP3B3Airattacks()
    
    local quantity = {}

    quantity = {5, 10, 15}
    local Temp = {
       'QP3B3AirAttackTemp0',
       'NoPlan',   
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP3B3AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP3base3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB3Airattack1','P3QB3Airattack2', 'P3QB3Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'QP3B3AirAttackTemp1',
       'NoPlan',   
       { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B3AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP3base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3QB3Airattack1','P3QB3Airattack2', 'P3QB3Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'QP3B3AirAttackTemp2',
       'NoPlan',   
       { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B3AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 106,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP3base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 60, categories.LAND * categories.MOBILE}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB3Airattack1','P3QB3Airattack2', 'P3QB3Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {6, 10, 15}
    opai = QAIP3base3:AddOpAI('AirAttacks', 'M3_QAIB3_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.STRUCTURE },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.STRUCTURE, '>='})

    quantity = {6, 10, 15}
    opai = QAIP3base3:AddOpAI('AirAttacks', 'M3_QAIB3_Air_Attack_2',
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
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.AIR, '>='})

    quantity = {6, 10, 15}
    opai = QAIP3base3:AddOpAI('AirAttacks', 'M3_QAIB3_Air_Attack_3',
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
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function QP3B3landattacks()
    
    local quantity = {}

    quantity = {5, 8, 10}
    local Temp = {
       'QP3B3landAttackTemp0',
       'NoPlan',
       { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP3B3AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB3landattack1', 'P3QB3landattack2', 'P3QB3landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    Temp = {
       'QP3B3landAttackTemp1',
       'NoPlan',
       { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'drlk001', 1, 5, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B3AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB3landattack1', 'P3QB3landattack2', 'P3QB3landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    Temp = {
       'QP3B3landAttackTemp2',
       'NoPlan',
       { 'url0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B3AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 35, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB3landattack1', 'P3QB3landattack2', 'P3QB3landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'QP3B3landAttackTemp3',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP3B3AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP3base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB3landattack1', 'P3QB3landattack2', 'P3QB3landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P3QB3Exp()

    local opai = nil
    local quantity = {}
    
    opai = QAIP3base3:AddOpAI({'P3B3Bot1','P3B3Bug1'},
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB3landattack1', 'P3QB3landattack2', 'P3QB3landattack3'}
       },
            MaxAssist = 5,
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 1, categories.EXPERIMENTAL, '>='},
                },
            }
        }
    )
end

