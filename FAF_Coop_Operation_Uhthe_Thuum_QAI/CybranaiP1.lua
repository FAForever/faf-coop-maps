local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua'

local Player1 = 1
local Cybran1 = 2
local Cybran2 = 5

local C1P1Base1 = BaseManager.CreateBaseManager()
local C1P1Base2 = BaseManager.CreateBaseManager()
local C2P1Base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

--Cybran Base 1

function P1C1base1AI()

    C1P1Base1:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P1Cybran1Base1', 'P1C1B1MK', 80, {P1C1base1 = 500})
    C1P1Base1:StartNonZeroBase({{7, 9, 12}, {5, 7, 10}})

    P1C1B1Airattacks()
    P1C1B1Landattacks()    
end

function P1C1B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 2, 4} 
    local Temp = {
        'P1C1B1AAttackTemp0',
        'NoPlan',  
        { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P1C1B1AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 9}
    trigger = {10, 7, 6}
    Temp = {
        'P1C1B1AAttackTemp1',
        'NoPlan',
        { 'ura0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 5, 6}
    trigger = {8, 7, 6}
    Temp = {
        'P1C1B1AAttackTemp2',
        'NoPlan',
        { 'xra0105', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P1C1B1AAttackTemp3',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C1B1Airpatrol1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder ) 

    quantity = {2, 3, 4}
    trigger = {8, 7, 6}
    Temp = {
        'P1C1B1AAttackTemp4',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 9}
    trigger = {25, 20, 15}
    Temp = {
        'P1C1B1AAttackTemp5',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {3, 6, 9}
    trigger = {10, 7, 6}
    Temp = {
        'P1C1B1AAttackTemp6',
        'NoPlan',
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

function P1C1B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 2, 3} 
    opai = C1P1Base1:AddOpAI('EngineerAttack', 'M1_Cybran_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1C1B1MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', quantity[Difficulty], categories.ura0104})
   
    quantity = {5, 10, 15}
    trigger = {20, 15, 10}
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack1', 
                LandingChain = 'P1C1B1drop1',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    
    quantity = {6, 10, 14}
    trigger = {35, 30, 25}
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack2', 
                LandingChain = 'P1C1B1drop2',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 8, 12}
    trigger = {10, 8, 7}
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_2_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack1', 
                LandingChain = 'P1C1B1drop1',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL, '>='})

    quantity = {4, 8, 12}
    trigger = {10, 9, 8}
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack1', 
                LandingChain = 'P1C1B1drop1',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1, '>='})

    quantity = {4, 8, 12}
    trigger = {10, 9, 8}
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack1', 
                LandingChain = 'P1C1B1drop1',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 205,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1, '>='})

    quantity = {4, 8, 12}
    trigger = {30, 25, 20}
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_5',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack2', 
                LandingChain = 'P1C1B1drop2',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('MobileBombs', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 160})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1, '>='})

    quantity = {2, 4, 6} 
    trigger = {25, 20, 15}
    local Temp = {
        'P1C1B1LandattackTemp0',
        'NoPlan',
        { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    local Builder = {
        BuilderName = 'P1C1B1landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P1C1B1Landattack1', 'P1C1B1Landattack2', 'P1C1B1Landattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

-- Cybran Base 2, Objective

function P1C1base2AI()

    C1P1Base2:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P1Cybran1Base2', 'P1C1B2MK', 80, {P1C1base2 = 500})
    C1P1Base2:StartNonZeroBase({{7, 10, 13}, {6, 9, 12}})

    P1C1B2Airattacks()
    P1C1B2Navalattacks()
    P1C1B2Landattacks()  
end

function P1C1B2Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5} 
    local Temp = {
        'P1C1B2LAttackTemp0',
        'NoPlan',
        { 'url0107', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'url0202', 1, 3, 'Attack', 'GrowthFormation' },
        { 'url0104', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1C1B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C1B2Landattack1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {50, 45, 40}
    Temp = {
        'P1C1B2LAttackTemp1',
        'NoPlan',
        { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P1C1B2Landattack2', 'P1C1B2Landattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {35, 30, 25} 
    Temp = {
        'P1C1B2LAttackTemp2',
        'NoPlan',
        { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P1C1B2Landattack2', 'P1C1B2Landattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 2}
    opai = C1P1Base2:AddOpAI('EngineerAttack', 'M1_CybranB2_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1C1B2MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', quantity[Difficulty], categories.ura0107})
   
    quantity = {2, 4, 6}
    opai = C1P1Base2:AddOpAI('BasicLandAttack', 'M1_CybranB2_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B2dropattack1', 
                LandingChain = 'P1C1B2drop1',
                TransportReturn = 'P1C1B2MK',
            },
            Priority = 105,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})

    quantity = {6, 12, 16}
    trigger = {50, 45, 40}
    opai = C1P1Base2:AddOpAI('BasicLandAttack', 'M1_CybranB2_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B2dropattack1', 
                LandingChain = 'P1C1B2drop1',
                TransportReturn = 'P1C1B2MK',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    
    quantity = {2, 4, 6}
    trigger = {12, 10, 8}
    opai = C1P1Base2:AddOpAI('BasicLandAttack', 'M1_CybranB2_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B2dropattack1', 
                LandingChain = 'P1C1B2drop1',
                TransportReturn = 'P1C1B2MK',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1, '>='})
end

function P1C1B2Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 2, 3} 
    local Temp = {
        'P1C1B2AAttackTemp0',
        'NoPlan',
        { 'ura0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1C1B2AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {10, 8, 6}
    Temp = {
        'P1C1B2AAttackTemp1',
        'NoPlan',
        { 'ura0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6} 
    Temp = {
        'P1C1B2AAttackTemp2',
        'NoPlan',
        { 'ura0102', 1, 5, 'Attack', 'GrowthFormation' },
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xra0105', 1, 5, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C1B2Airpatrol1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {14, 12, 10}
    Temp = {
        'P1C1B2AAttackTemp3',
        'NoPlan',
        { 'xra0105', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {16, 14, 10} 
    Temp = {
        'P1C1B2AAttackTemp4',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {30, 25, 20}
    Temp = {
        'P1C1B2AAttackTemp5',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {25, 20, 12} 
    Temp = {
        'P1C1B2AAttackTemp6',
        'NoPlan',
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1C1B2AAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

function P1C1B2Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5} 
    local Temp = {
        'P1C1B2NAttackTemp0',
        'NoPlan',
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'urs0103', 1, 5, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1C1B2NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C1B2Navalpatrol1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {1, 1, 2}
    trigger = {2, 1, 1}
    Temp = {
        'P1C1B2NAttackTemp1',
        'NoPlan',
        { 'urs0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.FACTORY * categories.NAVAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {20, 15, 10} 
    Temp = {
        'P1C1B2NAttackTemp2',
        'NoPlan',
        { 'urs0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 7, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {20, 15, 10} 
    Temp = {
        'P1C1B2NAttackTemp3',
        'NoPlan',
        { 'urs0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.NAVAL * categories.MOBILE * categories.T1SUBMARINE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {20, 15, 10} 
    Temp = {
        'P1C1B2NAttackTemp4',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {20, 15, 10} 
    Temp = {
        'P1C1B2NAttackTemp5',
        'NoPlan',
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1C1B2NAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

-- Cybran 2 base

function P1C2base1AI()

    C2P1Base1:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P1Cybran2Base1', 'P1C2B1MK', 60, {P1C2Base1 = 500})
    C2P1Base1:StartEmptyBase({{4, 5, 7}, {3, 4, 6}})
    C2P1Base1:SetMaximumConstructionEngineers(4)

    P1C2B1Landattacks()
end

function P1C2B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6} 
    local Temp = {
        'P1C2B1LAttackTemp0',
        'NoPlan',
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P1C2B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {10, 8, 10}
    Temp = {
        'P1C2B1LAttackTemp1',
        'NoPlan',
        { 'url0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1C2B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    Temp = {
        'P1C2B1LAttackTemp2',
        'NoPlan',
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'url0205', 1, 4, 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1C2B1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 9}
    trigger = {40, 35, 30}
    Temp = {
        'P1C2B1LAttackTemp3',
        'NoPlan',
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1C2B1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1C2B1Landattack1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )  
end

