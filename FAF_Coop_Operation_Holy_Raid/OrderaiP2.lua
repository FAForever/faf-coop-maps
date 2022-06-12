local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Holy_Raid/FAF_Coop_Operation_Holy_Raid_CustomFunctions.lua'

local Player1 = 1
local Order1 = 2
local Order2 = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local Order1base1 = BaseManager.CreateBaseManager()
local Order2base1 = BaseManager.CreateBaseManager()
local Order1base2 = BaseManager.CreateBaseManager()

function Order1base1AI()

    Order1base1:InitializeDifficultyTables(ArmyBrains[Order1], 'Order1base1', 'Order1base1MK', 80, {P1A1base1 = 100})
    Order1base1:StartNonZeroBase({{7, 12, 17}, {5, 10, 15}})
    
            
    ForkThread(
        function()
            WaitSeconds(5)
            Order1base1:AddBuildGroup('P1A1base1EXD_D' .. Difficulty, 800, false)
        end
    )
    O1P2B1landDrops()
    O1P2B1AirDefense()
    O1P2B1landattacks()
    O1P2B1Airattacks()
end

function O1P2B1AirDefense()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'O1P2B1lAirDefenceTemp1',
        'NoPlan',  
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'O1P2B1AirDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'O1P2B1AirDefence1'
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
end

function O1P2B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'O1P2B1lAirAttackTemp1',
        'NoPlan',  
        { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'O1P2B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B1Airattack1','O1P2B1Airattack2','O1P2B1Airattack3','O1P2B1Airattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {10, 8, 6}
    Temp = {
        'O1P2B1lAirAttackTemp2',
        'NoPlan',
        { 'uaa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O1P2B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B1Airattack1','O1P2B1Airattack2','O1P2B1Airattack3','O1P2B1Airattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {15, 14, 12}
    Temp = {
        'O1P2B1lAirAttackTemp3',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O1P2B1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B1Airattack1','O1P2B1Airattack2','O1P2B1Airattack3','O1P2B1Airattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {15, 14, 10}
    Temp = {
        'O1P2B1lAirAttackTemp4',
        'NoPlan',
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O1P2B1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 201,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B1Airattack1','O1P2B1Airattack2','O1P2B1Airattack3','O1P2B1Airattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    trigger = {28, 26, 24}
    Temp = {
        'O1P2B1lAirAttackTemp5',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O1P2B1AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B1Airattack1','O1P2B1Airattack2','O1P2B1Airattack3','O1P2B1Airattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
end

function O1P2B1landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 9}
    local Temp = {
        'O1P2B1landAttackTemp0',
        'NoPlan',
        { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'O1P2B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
    
    quantity = {6, 9, 12}
    trigger = {35, 30, 25}
    Temp = {
        'O1P2B1landAttackTemp1',
        'NoPlan',
        { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O1P2B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 9}
    trigger = {14, 12, 10}
    Temp = {
        'O1P2B1landAttackTemp2',
        'NoPlan',
        { 'ual0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O1P2B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {8, 5, 4}
    Temp = {
        'O1P2B1AttackTemp3',
        'NoPlan',   
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        }
    Builder = {
        BuilderName = 'O1P2B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.ECONOMIC) - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {18, 16, 14}
    Temp = {
       'O1P2B1AttackTemp4',
       'NoPlan',
       { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
       }
    Builder = {
        BuilderName = 'O1P2B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )  

    quantity = {2, 3, 4}
    trigger = {30, 25, 20}
    Temp = {
       'O1P2B1AttackTemp5',
       'NoPlan',   
       { 'ual0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       }
    Builder = {
        BuilderName = 'O1P2B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 201,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    Temp = {
       'O1P2B1AttackTemp6',
       'NoPlan',   
       { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       }
    Builder = {
        BuilderName = 'O1P2B1AttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {45, 40, 35}
    Temp = {
       'O1P2B1AttackTemp7',
       'NoPlan',
       { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
       }
    Builder = {
        BuilderName = 'O1P2B1AttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )   

    opai = Order1base1:AddOpAI('EngineerAttack', 'M1B1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'O1P2B1Landattack1','O1P2B1Landattack2','O1P2B1Landattack3','O1P2B1Landattack4'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

function O1P2B1landDrops()
    
    opai = Order1base1:AddOpAI('EngineerAttack', 'M2B1_Order1_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'Order1base1MK',
        },
        Priority = 1100,
    })
    opai:SetChildQuantity('T2Transports', 2)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 2, categories.uaa0104})
    
    quantity = {6, 9, 12}
    opai = Order1base1:AddOpAI('BasicLandAttack', 'M2B1_Order_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'O1P2B1Dropattack1', 
                LandingChain = 'O1P2B1Drop1',
                TransportReturn = 'Order1base1MK',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    
    quantity = {6, 9, 12}
    opai = Order1base1:AddOpAI('BasicLandAttack', 'M2B1_Order_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'O1P2B1Dropattack1', 
                LandingChain = 'O1P2B1Drop1',
                TransportReturn = 'Order1base1MK',
            },
            Priority = 205,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 160})

    quantity = {4, 5, 6}
    opai = Order1base1:AddOpAI('BasicLandAttack', 'M2B1_Order_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'O1P2B1Dropattack1', 
                LandingChain = 'O1P2B1Drop1',
                TransportReturn = 'Order1base1MK',
            },
            Priority = 310,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 160})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 30, categories.ALLUNITS - categories.TECH1, '>='})
end

function Order1base2AI()

    Order1base2:InitializeDifficultyTables(ArmyBrains[Order1], 'Order1base2', 'Order1base2MK', 80, {P1A1base2 = 100})
    Order1base2:StartNonZeroBase({{7, 10, 12}, {5, 8, 10}})
    Order1base2:SetActive('AirScouting', true)

    O1P2B2landDrops()
    O1P2B2AirDefense()
    O1P2B2landattacks()
    O1P2B2Airattacks()   
end

function O1P2B2landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 9}
    local Temp = {
       'O1P2B2landAttackTemp0',
       'NoPlan',
       { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'O1P2B2AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B2Landattack1','O1P2B2Landattack2','O1P2B2Landattack3'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    trigger = {40, 35, 30}
    Temp = {
       'O1P2B2landAttackTemp1',
       'NoPlan',
       { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'O1P2B2AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B2Landattack1','O1P2B2Landattack2','O1P2B2Landattack3'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {12, 10, 8}
    Temp = {
       'O1P2B2landAttackTemp2',
       'NoPlan',
       { 'ual0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'O1P2B2AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B2Landattack1','O1P2B2Landattack2','O1P2B2Landattack3'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {16, 14, 10}
    Temp = {
       'O1P2B2landAttackTemp3',
       'NoPlan',
       { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'O1P2B2AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B2Landattack1','O1P2B2Landattack2','O1P2B2Landattack3'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {10, 9, 8}
    Temp = {
       'O1P2B2landAttackTemp4',
       'NoPlan',
       { 'ual0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'O1P2B2AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 201,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B2Landattack1','O1P2B2Landattack2','O1P2B2Landattack3'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {40, 35, 30}
    Temp = {
       'O1P2B2landAttackTemp5',
       'NoPlan',
       { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
       { 'ual0103', 1, 4, 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'O1P2B2AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P2B2Landattack1','O1P2B2Landattack2','O1P2B2Landattack3'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder ) 

    opai = Order1base2:AddOpAI('EngineerAttack', 'M1B2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'O1P2B2Landattack1','O1P2B2Landattack2','O1P2B2Landattack3'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

function O1P2B2landDrops()

    local quantity = {}

    quantity = {2, 3, 4}
    opai = Order1base2:AddOpAI('EngineerAttack', 'M2B2_Order1_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'Order1base2MK',
        },
        Priority = 1100,
    })
    opai:SetChildQuantity('T1Transports', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 30})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', quantity[Difficulty], categories.uaa0104})

    quantity = {6, 8, 12}
    opai = Order1base2:AddOpAI('BasicLandAttack', 'M2B2_Order_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'O1P2B2Dropattack1', 
                LandingChain = 'O1P2B2Drop1',
                TransportReturn = 'Order1base2MK',
            },
            Priority = 213,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 90})
    
    quantity = {6, 8, 12}
    opai = Order1base2:AddOpAI('BasicLandAttack', 'M2B2_Order_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'O1P2B2Dropattack2', 
                LandingChain = 'O1P2B2Drop2',
                TransportReturn = 'Order1base2MK',
            },
            Priority = 212,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    
    quantity = {6, 8, 12}
    opai = Order1base2:AddOpAI('BasicLandAttack', 'M2B2_Order_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'O1P2B2Dropattack1', 
                LandingChain = 'O1P2B2Drop1',
                TransportReturn = 'Order1base2MK',
            },
            Priority = 211,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 160})

    quantity = {8, 12, 18}
    opai = Order1base2:AddOpAI('BasicLandAttack', 'M2B2_Order_TransportAttack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'O1P2B2Dropattack1', 
                LandingChain = 'O1P2B2Drop1',
                TransportReturn = 'Order1base2MK',
            },
            Priority = 220,
        }
    )
    opai:SetChildQuantity({'LightArtillery','LightTanks'}, quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 35, categories.ALLUNITS - categories.TECH1, '>='})
end

function O1P2B2AirDefense()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
       'O1P2B2lAirDefenseTemp1',
       'NoPlan',
       { 'uaa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       }
    local Builder = {
        BuilderName = 'O1P2B2AirDefenseBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'O1P2B2AirDefence1'
       },
   }
   ArmyBrains[Order1]:PBMAddPlatoon( Builder )
end

function O1P2B2Airattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
       'O1P2B2lAirAttackTemp1',
       'NoPlan',
       { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'O1P2B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O1P2B2Airattack1','O1P2B2Airattack2','O1P2B2Airattack3','O1P2B2Airattack4'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
   
    quantity = {5, 7, 10}
    trigger = {12, 11, 10}
    Temp = {
       'O1P2B2lAirAttackTemp2',
       'NoPlan',
       { 'uaa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'O1P2B2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O1P2B2Airattack1','O1P2B2Airattack2','O1P2B2Airattack3','O1P2B2Airattack4'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {8, 6, 5}
    Temp = {
       'O1P2B2lAirAttackTemp3',
       'NoPlan',
       { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'O1P2B2AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O1P2B2Airattack1','O1P2B2Airattack2','O1P2B2Airattack3','O1P2B2Airattack4'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {7, 9, 14}
    trigger = {4, 3, 2}
    Temp = {
       'O1P2B2lAirAttackTemp4',
       'NoPlan',
       { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    Builder = {
        BuilderName = 'O1P2B2AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 109,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O1P2B2Airattack1','O1P2B2Airattack2','O1P2B2Airattack3','O1P2B2Airattack4'}
       },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
end

function Order2base1AI()

    Order2base1:InitializeDifficultyTables(ArmyBrains[Order2], 'Order2base1', 'Order2base1MK', 70, {P1A2base1 = 100})
    Order2base1:StartNonZeroBase({{9, 12, 14}, {5, 8, 10}})
   
    O2P2B1AirAttack()
    O2P2B1AirDefense()
    O2P2B1landattacks()
    Exp1O2P2()
end

function O2P2B1AirDefense()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
       'O2P2B1lAirDefenceTemp1',
       'NoPlan',
       { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
       { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'O2P2B1AirDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'O2P2B1AirDefence1'
       },
   }
   ArmyBrains[Order2]:PBMAddPlatoon( Builder ) 
end

function O2P2B1AirAttack()

    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 7}
    trigger = {50, 45, 35}
    local Temp = {
        'O2P2B1lAirAttackTemp0',
        'NoPlan',
        { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'O2P2B1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B2Airattack1','O2P2B2Airattack2', 'O2P2B2Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    trigger = {10, 9, 8}
    Temp = {
        'O2P2B1lAirAttackTemp1',
        'NoPlan',
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P2B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 103,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B2Airattack1','O2P2B2Airattack2', 'O2P2B2Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    trigger = {24, 20, 16}
    Temp = {
        'O2P2B1lAirAttackTemp2',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P2B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B2Airattack1','O2P2B2Airattack2', 'O2P2B2Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {20, 15, 10}
    Temp = {
        'O2P2B1lAirAttackTemp3',
        'NoPlan',
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P2B1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B2Airattack1','O2P2B2Airattack2', 'O2P2B2Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {8, 7, 6}
    Temp = {
        'O2P2B1lAirAttackTemp4',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P2B1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 302,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.AIR * categories.MOBILE) * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B2Airattack1','O2P2B2Airattack2', 'O2P2B2Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 9}
    opai = Order2base1:AddOpAI('AirAttacks', 'M2_Order2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 500,
        }
    )
    opai:SetChildQuantity('GuidedMissiles', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {4, 5, 8}
    opai = Order2base1:AddOpAI('AirAttacks', 'M2_Order2_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.COMMAND},
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity({'GuidedMissiles', 'Gunships'}, quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2, categories.TECH3, '>='})
end

function Exp1O2P2()

    local opai = nil
    local quantity = {}
    quantity = {2, 3, 4}
    opai = Order2base1:AddOpAI('Gbot1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O2P2B1LandDefence1'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )

    quantity = {2, 3, 4}
    opai = Order2base1:AddOpAI('Gbot2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'O2P2B1LandAttack1', 'O2P2B1LandAttack2', 'O2P2B1LandAttack3'}
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

function O2P2B1landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {5, 6, 10}
    trigger = {32, 30, 26}
    local Temp = {
        'O2P2B1landAttackTemp0',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'O2P2B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B1LandAttack1', 'O2P2B1LandAttack2', 'O2P2B1LandAttack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {30, 25, 20}
    Temp = {
        'O2P2B1landAttackTemp1',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P2B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B1LandAttack1', 'O2P2B1LandAttack2', 'O2P2B1LandAttack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 6}
    trigger = {7, 6, 5}
    Temp = {
        'O2P2B1landAttackTemp2',
        'NoPlan',
        { 'ual0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P2B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B1LandAttack1', 'O2P2B1LandAttack2', 'O2P2B1LandAttack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 8}
    trigger = {10, 9, 8}
    Temp = {
        'O2P2B1landAttackTemp3',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P2B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'O2P2B1LandAttack1', 'O2P2B1LandAttack2', 'O2P2B1LandAttack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 8}
    trigger = {2, 1, 1}
    Temp = {
        'O2P2B1landAttackTemp4',
        'NoPlan',
        { 'xal0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P2B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P2B1LandAttack1', 'O2P2B1LandAttack2', 'O2P2B1LandAttack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    opai = Order2base1:AddOpAI('EngineerAttack', 'M1B3_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'O2P2B1LandAttack1', 'O2P2B1LandAttack2', 'O2P2B1LandAttack3'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T2Engineers', 4)
end
