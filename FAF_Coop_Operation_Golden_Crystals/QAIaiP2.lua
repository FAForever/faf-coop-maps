local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local Player1 = 1
local QAI = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local QAIP2base1 = BaseManager.CreateBaseManager()
local QAIP2base2 = BaseManager.CreateBaseManager()

function QAIP2base1AI()

    QAIP2base1:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP2base1', 'QAIP2base1MK', 50, {P2Qbase1 = 100})
    QAIP2base1:StartNonZeroBase({{11, 16, 20}, {9, 14, 18}})
    QAIP2base1:SetActive('AirScouting', true)

    QP2B1landattacks()
    QP2B1Airattacks()  
    QP2B1Exp1()
end

function QP2B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
       'QP 2B1AirAttackTemp0',
       'NoPlan',   
       { 'ura0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP2B1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2QB1Airdefense1'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
       'QP2B1AirAttackTemp1',
       'NoPlan',   
       { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2QB1Airdefense2'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
       'QP2B1AirAttackTemp2',
       'NoPlan',   
       { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2QB1Airdefense3'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8} 
    Temp = {
       'QP2B1AirAttackTemp3',
       'NoPlan',   
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB1Airattacks1', 'P2QB1Airattacks2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )  
end

function QP2B1landattacks()
    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6} 
    local Temp = {
       'QP2B1landAttackTemp0',
       'NoPlan',
       { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP2B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP2base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2QB1Landattack1', 'P2QB1Landattack2', 'P2QB1Landattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    trigger = {}
    Temp = {
       'QP2B1landAttackTemp1',
       'NoPlan',
       { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3 - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB1Landattack1', 'P2QB1Landattack2', 'P2QB1Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6} 
    trigger = {45, 38, 30}
    Temp = {
       'QP2B1landAttackTemp2',
       'NoPlan',
       { 'drlk001', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 103,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB1Landattack1', 'P2QB1Landattack2', 'P2QB1Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {65, 50, 35}
    Temp = {
       'QP2B1landAttackTemp3',
       'NoPlan',
       { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 7,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'QAIP2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB1Landattack1', 'P2QB1Landattack2', 'P2QB1Landattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder ) 
end

function QP2B1Exp1()

    local opai = nil
    local quantity = {}
    
    quantity = {1, 2, 4}
    opai = QAIP2base1:AddOpAI('SBot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P2QB1Landattack1', 'P2QB1Landattack2', 'P2QB1Landattack3'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 25, categories.TECH3, '>='},
                },
            }
        }
    )
end

function QAIP2base2AI()

    QAIP2base2:InitializeDifficultyTables(ArmyBrains[QAI], 'QAIP2base2', 'QAIP2base2MK', 50, {P2Qbase2 = 100})
    QAIP2base2:StartNonZeroBase({{10, 13, 15}, {6, 9, 12}})
    QAIP2base2:SetActive('AirScouting', true)
    
    QP2B2Airattacks()
    QP2B2landattacks()
    QP2B2Exp1()  
end

function QP2B2Airattacks()
    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}

    local Temp = {
       'QP2B2AirAttackTemp0',
       'NoPlan',   
       { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'QP2B2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2QB2Airdefense2'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
       'QP2B2AirAttackTemp1',
       'NoPlan',
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB2Airattack1','P2QB2Airattack2', 'P2QB2Airattack3', 'P2QB2Airattack4'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {5, 6, 7}
    trigger = {20, 10, 4}
    Temp = {
       'QP2B2AirAttackTemp2',
       'NoPlan',
       { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB2Airattack1','P2QB2Airattack2', 'P2QB2Airattack3', 'P2QB2Airattack4'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    trigger = {10, 8, 6}
    Temp = {
       'QP2B2AirAttackTemp3',
       'NoPlan',
       { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B2AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB2Airattack1','P2QB2Airattack2', 'P2QB2Airattack3', 'P2QB2Airattack4'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )  

    quantity = {3, 4, 5}
    trigger = {30, 25, 20}
    Temp = {
       'QP2B2AirAttackTemp4',
       'NoPlan',
       { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'QP2B2AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'QAIP2base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB2Airattack1','P2QB2Airattack2', 'P2QB2Airattack3', 'P2QB2Airattack4'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )  
end

function QP2B2landattacks()
    local quantity = {}

    quantity = {2, 3, 4} 
    opai = QAIP2base2:AddOpAI('EngineerAttack', 'M2_QAI_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2AB1MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 2, categories.ura0104})
    
    quantity = {4, 6, 8}
    opai = QAIP2base2:AddOpAI('BasicLandAttack', 'M2_QAI_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2QTransportdropattack', 
                LandingChain = 'P2QTransportdrop',
                TransportReturn = 'QAIP2base2MK',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    quantity = {8, 12, 16}
    opai = QAIP2base2:AddOpAI('BasicLandAttack', 'M2_QAI_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2QTransportdropattack', 
                LandingChain = 'P2QTransportdrop',
                TransportReturn = 'QAIP2base2MK',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 90})
end

function QP2B2Exp1()

    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {1, 2, 4}
    trigger = {50, 40, 30}
    opai = QAIP2base2:AddOpAI('Bug1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2QB2Airattack1','P2QB2Airattack2', 'P2QB2Airattack3', 'P2QB2Airattack4'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='},
                },
            }
        }
    )
end

