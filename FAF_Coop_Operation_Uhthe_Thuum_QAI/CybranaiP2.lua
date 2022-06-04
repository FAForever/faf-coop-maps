local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua'

local Player1 = 1
local Cybran1 = 2
local Cybran2 = 5
local QAI = 3

local C1P2Base1 = BaseManager.CreateBaseManager()
local C1P2Base2 = BaseManager.CreateBaseManager()
local C2P2Base1 = BaseManager.CreateBaseManager()
local C2P2Base2 = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty

--Cybran 1 Airbase

function P2C1base1AI()

    C1P2Base1:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P2Cybran1Base1', 'P2C1B1MK', 70, {P2C1base1 = 100})
    C1P2Base1:StartNonZeroBase({{8, 10, 12}, {4, 6, 8}})
    C1P2Base1:SetActive('AirScouting', true)

    
    P2C1B1Airattacks()
    P2C1B1EXPattacks()   
end

function P2C1B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {8, 10, 12} 
    local Temp = {
        'P2C1B1AttackTemp0',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P2C1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 4, 6}
    trigger = {14, 12, 10} 
    Temp = {
        'P2C1B1AttackTemp1',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {18, 15, 12}
    Temp = {
        'P2C1B1AttackTemp2',
        'NoPlan',
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dra0202', 1, 6, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P2C1B1AttackTemp5',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2C1B1Airdefence1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 8}
    trigger = {9, 6, 3}
    opai = C1P2Base1:AddOpAI('AirAttacks', 'M2_Cybran_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.TECH3 * categories.NAVAL * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty],  categories.TECH3 * categories.NAVAL * categories.MOBILE, '>='})
end

function P2C1B1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    trigger = {45, 40, 35}  
    opai = C1P2Base1:AddOpAI('C1Bug1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
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

--Cybran 1 Mainbase

function P2C1base2AI()

    C1P2Base2:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P2Cybran1Base2', 'P2C1B2MK', 90, {P2C1base2 = 100})
    C1P2Base2:StartNonZeroBase({{10, 14, 17}, {7, 11, 14}})
    C1P2Base2:SetActive('AirScouting', true)

    P2C1B2Landattacks()
    P2C1B2Navalattacks()
    P2C1B2Airattacks()
    P2C1B2EXPattacks()
end

function P2C1B2Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4} 
    local Temp = {
        'P2C1B2NAttackTemp0',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2C1B2NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2NavalAttack1', 'P2C1B2NavalAttack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {16, 13, 10}
    Temp = {
        'P2C1B2NAttackTemp1',
        'NoPlan',
        { 'urs0203', 1, 6, 'Attack', 'GrowthFormation' }, 
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B2NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2C1B2NavalAttack3'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {25, 20, 15} 
    Temp = {
        'P2C1B2NAttackTemp2',
        'NoPlan',
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2C1B2NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2C1B2NavalAttack3'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    Temp = {
        'P2C1B2NAttackTemp3',
        'NoPlan',
        { 'urs0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2C1B2NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 120,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2C1B2NavalAttack3'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

function P2C1B2Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 9} 
    local Temp = {
        'P2C1B2AAttackTemp0',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P2C1B2AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2Airattack1', 'P2C1B2Airattack2', 'P2C1B2Airattack3', 'P2C1B2Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    trigger = {25, 20, 15} 
    Temp = {
        'P2C1B2AAttackTemp1',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2C1B2AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2Airattack1', 'P2C1B2Airattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    trigger = {25, 20, 15}
    Temp = {
        'P2C1B2AAttackTemp2',
        'NoPlan',
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2C1B2AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2Airattack1', 'P2C1B2Airattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 8}
    opai = C1P2Base2:AddOpAI('AirAttacks', 'M2_Cybran_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND * categories.MOBILE, '>='})  
end

function P2C1B2EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {1, 2, 3}
    trigger = {35, 30, 25}
    opai = C1P2Base2:AddOpAI('C1Bot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P2C1B2Landattack1', 'P2C1B2Landattack2', 'P2C1B2Landattack3'}
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

function P2C1B2Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4} 
    local Temp = {
        'P2C1B2LandAttackTemp0',
        'NoPlan',
        { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C1B2LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C1B2Landattack1', 'P2C1B2Landattack2', 'P2C1B2Landattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

    quantity = {3, 6, 9}
    trigger = {35, 30, 25} 
    Temp = {
        'P2C1B2LandAttackTemp1',
        'NoPlan',
        { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B2LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.MOBILE}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C1B2Landattack1', 'P2C1B2Landattack2', 'P2C1B2Landattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )  

    quantity = {1, 2, 3} 
    opai = C1P2Base2:AddOpAI('EngineerAttack', 'M2_Cybran_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2C1B2MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', quantity[Difficulty], categories.ura0104})
   
    quantity = {2, 4, 6}
    opai = C1P2Base2:AddOpAI('BasicLandAttack', 'M2_Cybran_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2C1B2dropattack1', 
                LandingChain = 'P2C1B2drop1',
                TransportReturn = 'P2C1B2MK',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})

    quantity = {2, 4, 6}
    opai = C1P2Base2:AddOpAI('BasicLandAttack', 'M2_Cybran_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2C1B2dropattack1', 
                LandingChain = 'P2C1B2drop1',
                TransportReturn = 'P2C1B2MK',
            },
            Priority = 105,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
end

-- Cybran 2 offmap base

function P2C2base1AI()

    C2P2Base1:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P2Cybran2Base1', 'P2C2B1MK', 80, {P2C2base1 = 100})
    C2P2Base1:StartNonZeroBase({{12, 16, 18}, {8, 12, 14}})
    C2P2Base1:SetActive('AirScouting', true)
    
    P2C2B1Landattacks()
    P2C2B1Airattacks()
end

function P2C2B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 4, 6} 
    local Temp = {
        'P2C2B1LAttackTemp0',
        'NoPlan',
        { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C2B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3', 'P2C2B1Landattack4'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P2C2B1LAttackTemp1',
        'NoPlan',
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3', 'P2C2B1Landattack4'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )  
end

function P2C2B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 8} 
    local Temp = {
        'P2C2B1AAttackTemp0',
        'NoPlan',  
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C2B1AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3', 'P2C2B1Landattack4'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {18, 14, 10}
    Temp = {
        'P2C2B1AAttackTemp1',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  'QAI', trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3', 'P2C2B1Landattack4'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
end

-- Offmap base Part 3 attacks

function P2C2B1base1EXD()

    C2P2Base1:AddBuildGroup('P2C2base1EXD_D' .. Difficulty, 800, false)
    C2P2Base1.MaximumConstructionEngineers = 4
    
    P2C2B1Navalattacks()  
end

function P2C2B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4} 
    local Temp = {
        'P2C2B1NAttackTemp0',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2C2B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Navalattack1', 'P2C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {3, 5, 6}
    trigger = {6, 5, 3}
    Temp = {
        'P2C2B1NAttackTemp1',
        'NoPlan',
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2C2B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Navalattack1', 'P2C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {18, 14, 12}
    Temp = {
        'P2C2B1NAttackTemp2',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xrs0205', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2C2B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Navalattack1', 'P2C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder ) 
end
    