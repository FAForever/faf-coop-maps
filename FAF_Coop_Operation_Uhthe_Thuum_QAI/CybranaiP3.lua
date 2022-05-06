local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua'

local Player1 = 1
local Cybran2 = 5

local C2P3Base1 = BaseManager.CreateBaseManager()
local C2P3Base2 = BaseManager.CreateBaseManager()
local C2P3Base3 = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty

-- Main Cybran Base

function C2P3Base1AI()

    C2P3Base1:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P3Cybran2Base1', 'P3C2B1MK', 80, {P3C2base1 = 100})
    C2P3Base1:StartNonZeroBase({{10, 17, 24}, {8, 14, 20}})
    C2P3Base1:SetActive('AirScouting', true)
    C2P3Base1:SetSupportACUCount(1)
    C2P3Base1:SetSACUUpgrades({'ResourceAllocation', 'Switchback', 'SelfRepairSystem'}, true)

    P3C2B1Airattacks()
    P3C2B1Navalattacks()
    P3C2B1Landattacks()
    P3C2B1EXPattacks()
end

function P3C2B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {9, 12, 15}
    local Temp = {
        'P3C2B1AttackTemp0',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },      
    }
    local Builder = {
        BuilderName = 'P3C2B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B1Airattack1', 'P3C2B1Airattack2', 'P3C2B1Airattack3', 'P3C2B1Airattack4'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 9, 12}
    trigger = {20, 15, 12}
    Temp = {
        'P3C2B1AttackTemp1',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },       
    }
    Builder = {
        BuilderName = 'P3C2B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B1Airattack1', 'P3C2B1Airattack2', 'P3C2B1Airattack3', 'P3C2B1Airattack4'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {20, 18, 15} 
    Temp = {
        'P3C2B1AttackTemp2',
        'NoPlan',
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },      
    }
    Builder = {
        BuilderName = 'P3C2B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B1Airattack1', 'P3C2B1Airattack2', 'P3C2B1Airattack3', 'P3C2B1Airattack4'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P3C2B1AttackTemp3',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3C2B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3C2B1Airdef1'
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )

    quantity = {7, 8, 9}
    opai = C2P3Base1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_1',
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

function P3C2B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 2, 3}
    local Temp = {
        'P3C2B1NAttackTemp0',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3C2B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Navalattack1', 'P3C2B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {20, 15, 12}
    Temp = {
        'P3C2B1NAttackTemp1',
        'NoPlan',
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3C2B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Navalattack1', 'P3C2B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 4}
    trigger = {14, 10, 6}
    Temp = {
        'P3C2B1NAttackTemp2',
        'NoPlan',
        { 'urs0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3C2B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Navalattack1', 'P3C2B2Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder ) 
end

function P3C2B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 10} 
    local Temp = {
        'P3C2B1LAttackTemp0',
        'NoPlan',
        { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3C2B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3C2B1Landattack1', 'P3C2B1Landattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    opai = C2P3Base1:AddOpAI('EngineerAttack', 'M3_Cybran_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P3C2B1MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', quantity[Difficulty], categories.ura0104})

    quantity = {6, 8, 10}

    opai = C2P3Base1:AddOpAI('BasicLandAttack', 'M3_Cybran_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3C2B1LandattackDropA', 
                LandingChain = 'P3C2B1LandattackDrop',
                TransportReturn = 'P3C2B1MK',
                MovePath = 'P3C2B1LandattackDropM',
            },
            Priority = 105,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})


    quantity = {1, 2, 3}
    Temp = {
        'P3C2B1GAttackTemp0',
        'NoPlan',
        { 'url0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P3C2B1GAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3C2B1Landattack1', 'P3C2B1Landattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
end

function P3C2B1EXPattacks()
    local opai = nil
    local quantity = {}

    quantity = {2, 3, 4} 
    opai = C2P3Base1:AddOpAI('P3C2EXPbug1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P3C2B1Airattack3', 'P3C2B1Airattack4'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

-- Second Cybran Base

function C2P3Base2AI()

    C2P3Base2:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P3Cybran2Base2', 'P3C2B2MK', 100, {P3C2base2 = 100})
    C2P3Base2:StartNonZeroBase({{12, 18, 24}, {10, 15, 21}})
    C2P3Base2:SetActive('AirScouting', true)
    
    P3C2B2Landattacks()
    P3C2B2Airattacks()
    P3C2B2Navalattacks()
    P3C2B2EXPattacks()  
end

function P3C2B2Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 9}
    local Temp = {
        'P3C2B2andLAttackTemp0',
        'NoPlan',
        { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3C2B2LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Landattack1', 'P3C2B2Landattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {30, 25, 20}
    Temp = {
        'P3C2B2LAttackTemp1',
        'NoPlan',
        { 'url0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3C2B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Landattack1', 'P3C2B2Landattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 9}
    Temp = {
        'P3C2B2LAttackTemp2',
        'NoPlan',
        { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P3C2B2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 130,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Landattack1', 'P3C2B2Landattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )  
end

function P3C2B2Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {9, 12, 15} 

    local Temp = {
        'P3C2B2AirAttackTemp0',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },      
    }
    local Builder = {
        BuilderName = 'P3C2B2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Airattack1', 'P3C2B2Airattack2', 'P3C2B2Airattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {7, 9, 12}
    trigger = {30, 25, 20}
    Temp = {
        'P3C2B2AirAttackTemp1',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },      
    }
    Builder = {
        BuilderName = 'P3C2B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Airattack1', 'P3C2B2Airattack2', 'P3C2B2Airattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {30, 25, 20}
    Temp = {
        'P3C2B2AirAttackTemp2',
        'NoPlan',
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },      
    }
    Builder = {
        BuilderName = 'P3C2B2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B2Airattack1', 'P3C2B2Airattack2', 'P3C2B2Airattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {7, 8, 9}
    opai = C2P3Base2:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_2',
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
            {'default_brain', {'HumanPlayers'}, 2,  categories.EXPERIMENTAL * categories.LAND * categories.MOBILE, '>='}) 
end

function P3C2B2Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {1, 2, 3}
    local Temp = {
        'P3C2B2NAttackTemp0',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3C2B2NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B1Navalattack1', 'P3C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    Temp = {
        'P3C2B2NAttackTemp1',
        'NoPlan',
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3C2B2NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B1Navalattack1', 'P3C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P3C2B2NAttackTemp2',
        'NoPlan',
        { 'urs0302', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3C2B2NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B1Navalattack1', 'P3C2B1Navalattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P3C2B2NAttackTemp3',
        'NoPlan',
        { 'urs0201', 1, 4, 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, 4, 'Attack', 'GrowthFormation' },           
    }
    Builder = {
        BuilderName = 'P3C2B2NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B1Navalattack1', 'P3C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
end

function P3C2B2EXPattacks()
    local opai = nil
    local quantity = {}
    
    opai = C2P3Base2:AddOpAI('P3C2EXPbot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P3C2B2Expattack1', 'P3C2B2Expattack2', 'P3C2B2Expattack3'}
        },
            MaxAssist = 4,
            Retry = true,
        }
    )
end

-- Minor Cybran Base

function C2P3Base3AI()

    C2P3Base3:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P3Cybran2Base3', 'P3C2B3MK', 70, {P3C2base3 = 100})
    C2P3Base3:StartNonZeroBase({{6, 9, 12}, {4, 6, 8}})
    C2P3Base3:SetActive('AirScouting', true)
    
    P3C2B3Airattacks()
    P3C2B3Landattacks()
end

function P3C2B3EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}

    opai = C2P3Base3:AddOpAI('P3C2EXPbot2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P3C2B3Landattack1', 'P3C2B3Landattack2', 'P3C2B3Landattack3'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P3C2B3Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P3C2B3AirAttackTemp0',
        'NoPlan',
        { 'xra0305', 1, 2, 'Attack', 'AttackFormation' },
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },      
    }
    local Builder = {
        BuilderName = 'P3C2B3AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B3Airattack1', 'P3C2B3Airattack2', 'P3C2B3Airattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {30, 25, 20}
    Temp = {
        'P3C2B3AirAttackTemp1',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },      
    }
    Builder = {
        BuilderName = 'P3C2B3AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B3Airattack1', 'P3C2B3Airattack2', 'P3C2B3Airattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {30, 25, 20}
    Temp = {
        'P3C2B3AirAttackTemp2',
        'NoPlan',
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },      
    }
    Builder = {
        BuilderName = 'P3C2B3AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3C2B3Airattack1', 'P3C2B3Airattack2', 'P3C2B3Airattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder ) 
end

function P3C2B3Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 7, 10}
    local Temp = {
        'P3C2B3andLAttackTemp0',
        'NoPlan',
        { 'Url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3C2B3LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 7,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base3',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3C2B3Landattack1', 'P3C2B3Landattack2', 'P3C2B3Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {40, 35, 30}
    Temp = {
        'P3C2B3andLAttackTemp1',
        'NoPlan',
        { 'xrl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3C2B3LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Cybran2Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3C2B3Landattack1', 'P3C2B3Landattack2', 'P3C2B3Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
end

