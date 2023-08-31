local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Rebel\'s_Rest/FAF_Coop_Operation_Rebel\'s_Rest_CustomFunctions.lua'

local Player1 = 1
local UEF1 = 2
local UEF2 = 3

local P2U1Base1 = BaseManager.CreateBaseManager()
local P2U1Base2 = BaseManager.CreateBaseManager()
local P2U2Base1 = BaseManager.CreateBaseManager()
local P2U2Base2 = BaseManager.CreateBaseManager()
local P2U2Base3 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P2U1Base1AI()

    P2U1Base1:InitializeDifficultyTables(ArmyBrains[UEF1], 'P2UEF1Base1', 'P2U1B1MK', 100, {P2U1Base1 = 100})
    P2U1Base1:StartNonZeroBase({{8, 11, 14}, {6, 9, 12}})
    P2U1Base1:SetActive('AirScouting', true)

    P2U1Base1:AddExpansionBase('P1UEF1Base2', 3)
    
    P2U1B1Airattacks()
    P2U1B1Landattacks()
    P2U1B1Navalattacks()  
    P2U1B1EXPattacks()
end

function P2U1B1Airattacks()
    
    local quantity = {}
    
    quantity = {3, 4, 5}
    local Temp = {
        'P2U1B1AttackTemp0',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2U1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2U1B1Airpatrol1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    Temp = {
        'P2U1B1AttackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2U1B1Airattack1','P2U1B1Airattack2', 'P2U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P2U1B1AttackTemp2',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.NAVAL * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2U1B1Airattack1','P2U1B1Airattack2', 'P2U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P2U1B1AttackTemp3',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U1B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2U1B1Airattack1','P2U1B1Airattack2', 'P2U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P2U1B1AttackTemp4',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U1B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 120,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.TECH3 * categories.ALLUNITS}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2U1B1Airattack1','P2U1B1Airattack2', 'P2U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder ) 
end

function P2U1B1Landattacks()

    local quantity = {}

    quantity = {6, 8, 10}
    local Temp = {
        'P2U1B1LAttackTemp0',
        'NoPlan',
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P2U1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2U1B1Landattack1', 'P2U1B1Landattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    opai = P2U1Base1:AddOpAI('EngineerAttack', 'M2B1_UEF1_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2U1B1MK',
        },
        Priority = 1100,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.uea0104})
    
    quantity = {6, 8, 12}
    opai = P2U1Base1:AddOpAI('BasicLandAttack', 'M2B1_UEF1_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3IntDropattack1', 
                LandingChain = 'P3IntDrop1',
                TransportReturn = 'P2U1B1MK',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
end

function P2U1B1Navalattacks()

    local quantity = {}

    quantity = {3, 5, 6}
    local Temp = {
        'P2U1B1NAttackTemp0',
        'NoPlan',
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2U1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2U1B1Navalattack1','P2U1B1Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P2U11B1NAttackTemp1',
        'NoPlan',
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2U1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2U1B1Navalattack1','P2U1B1Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P2U11B1NAttackTemp2',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2U1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 6, categories.NAVAL - categories.TECH1}},
        },    
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2U1B1Navalattack1','P2U1B1Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end

function P2U1B1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {1, 2, 3}
    trigger = {40, 30, 20}
    opai = P2U1Base1:AddOpAI('P2U1Sub',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
                PatrolChains = {'P2U1B1Navalattack1','P2U1B1Navalattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL, '>='},
                },
            }
        }
    )
end

function P2U1Base2AI()

    P2U1Base2:InitializeDifficultyTables(ArmyBrains[UEF1], 'P2UEF1Base2', 'P2U1B2MK', 90, {P2U1Base2 = 100})
    P2U1Base2:StartNonZeroBase({{9, 12, 16}, {7, 10, 14}})
    P2U1Base2:SetActive('AirScouting', true)
    
    P2U1B2Airattacks()
    P2U1B2Landattacks()
    P2U1B2Navalattacks() 
end

function P2U1B2Airattacks()
    
    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P2U1B2AttackTemp0',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       
    }
    local Builder = {
        BuilderName = 'P2U1B2AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2U1B2Airpatrol1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    Temp = {
        'P2U1B2AttackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U1B2AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2', 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U1B2Airattack1','P2U1B2Airattack2', 'P2U1B2Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    Temp = {
        'P2U1B2AttackTemp2',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U1B2AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U1B2Airattack1','P2U1B2Airattack2', 'P2U1B2Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    Temp = {
        'P2U1B2AttackTemp3',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U1B2AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U1B2Airattack1','P2U1B2Airattack2', 'P2U1B2Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
         
    quantity = {6, 7, 9}
    opai = P2U1Base2:AddOpAI('AirAttacks', 'M2_U1B2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.NAVAL * categories.TECH3 },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.NAVAL * categories.TECH3, '>='})
end

function P2U1B2Landattacks()

    local quantity = {}

    quantity = {3, 4, 5}
    local Temp = {
        'P2U1B2LAttackTemp0',
        'NoPlan',
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P2U1B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},
        PlatoonData = {
           MoveChains = {'P2U1B2Landattack1', 'P2U1B2Landattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    Temp = {
        'P2U1B2LAttackTemp1',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2U1B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2U1B2Landattack1', 'P2U1B2Landattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )    

    -- Extra engineers assisting T2 naval factories, all T2 factories has to be built
    -- Count is {X, 0} since the platoon contains shields/stealth as well and we want just the engineers. And too lazy to make a new platoon rn.
    quantity = {{4, 0}, {5, 0}, {6, 0}}
    opai = P2U1Base2:AddOpAI('EngineerAttack', 'M2_UEF1_Assist_Engineers_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'P2UEF1Base2',
                Factories = categories.TECH3 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 300,
        }
    )
    opai:SetChildQuantity('T3Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 3, categories.TECH3 * categories.NAVAL * categories.FACTORY})
end

function P2U1B2Navalattacks()

    local quantity = {}

    quantity = {2, 2, 3}
    local Temp = {
        'P2U1B2NAttackTemp0',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2U1B2NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U1B2Navalattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    Temp = {
        'P2U11B2NAttackTemp1',
        'NoPlan',
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2U1B2NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U1B2Navalattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P2U11B2NAttackTemp2',
        'NoPlan',
        { 'ues0302', 1, 1, 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2U1B2NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 120,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U1B2Navalattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end

function P2U2Base1AI()

    P2U2Base1:InitializeDifficultyTables(ArmyBrains[UEF2], 'P2UEF2Base1', 'P2U2B1MK', 100, {P2U2Base1 = 100})
    P2U2Base1:StartNonZeroBase({{14, 18, 22}, {8, 12, 16}})
    P2U2Base1:SetActive('AirScouting', true)

    P2U2B1Airattacks()
    P2U2B1Landattacks()
    P2U2B1Navalattacks() 
    P2U2B1EXPattacks()
end

function P2U2B1Airattacks()
    
    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P2U2B1AttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       
    }
    local Builder = {
        BuilderName = 'P2U2B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2U2B1Airpatrol1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    Temp = {
        'P2U2B1AttackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U2B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1', 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U2B1Airattack1','P2U2B1Airattack2', 'P2U2B1Airattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    Temp = {
        'P2U2B1AttackTemp2',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U2B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U2B1Airattack1','P2U2B1Airattack2', 'P2U2B1Airattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    Temp = {
        'P2U2B1AttackTemp3',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U2B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U2B1Airattack1','P2U2B1Airattack2', 'P2U2B1Airattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

         
    quantity = {6, 7, 9}
    opai = P2U2Base1:AddOpAI('AirAttacks', 'M2_U2B1_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = {categories.NAVAL * categories.TECH3},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.NAVAL * categories.TECH3, '>='})

    quantity = {6, 7, 9}
    opai = P2U2Base1:AddOpAI('AirAttacks', 'M2_U2B1_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {6, 7, 9}
    opai = P2U2Base1:AddOpAI('AirAttacks', 'M2_U2B1_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = {categories.EXPERIMENTAL * categories.AIR},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.AIR, '>='})
end

function P2U2B1Landattacks()

    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P2U2B1LAttackTemp0',
        'NoPlan',
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P1U2B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},
        PlatoonData = {
           MoveChains = {'P2U2B1Landattack1', 'P2U2B1Landattack2', 'P2U2B1Landattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2U2B1LAttackTemp1',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2U2B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2U2B1Landattack1', 'P2U2B1Landattack2', 'P2U2B1Landattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder ) 

    opai = P2U2Base1:AddOpAI('EngineerAttack', 'M2B1_UEF2_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2U2B1MK',
        },
        Priority = 1100,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.uea0104})
    
    quantity = {4, 5, 6}
    opai = P2U2Base1:AddOpAI('BasicLandAttack', 'M2B1_UEF2_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3DropAttack2', 
                LandingChain = 'P3Drop2',
                TransportReturn = 'P2U2B1MK',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    quantity = {4, 5, 6}
    opai = P2U2Base1:AddOpAI('BasicLandAttack', 'M2B1_UEF2_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3DropAttack2', 
                LandingChain = 'P3Drop2',
                TransportReturn = 'P2U2B1MK',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 150})

    -- Extra engineers assisting T2 naval factories, all T2 factories has to be built
    -- Count is {X, 0} since the platoon contains shields/stealth as well and we want just the engineers. And too lazy to make a new platoon rn.
    quantity = {{1, 0}, {2, 0}, {3, 0}}
    opai = P2U2Base1:AddOpAI('EngineerAttack', 'M2_UEF2_Assist_Engineers_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'P2UEF2Base1',
                Factories = categories.TECH3 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 500,
        }
    )
    opai:SetChildQuantity('T3Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 3, categories.TECH3 * categories.NAVAL * categories.FACTORY})
end

function P2U2B1Navalattacks()

    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P2U2B1NAttackTemp0',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2U2B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U2B1Navalattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    Temp = {
        'P2U2B1NAttackTemp1',
        'NoPlan',
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2U2B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 4, categories.NAVAL - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U2B1Navalattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 5}
    Temp = {
        'P2U2B1NAttackTemp2',
        'NoPlan',
        { 'ues0302', 1, 1, 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2U2B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U2B1Navalattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 5}
    Temp = {
        'P2U2B1NAttackTemp3',
        'NoPlan',
        { 'ues0302', 1, 1, 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2U2B1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 12, categories.NAVAL - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U2B1Navalattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
end

function P2U2B1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {1, 2, 3}
    trigger = {50, 45, 40}
    opai = P2U2Base1:AddOpAI('P2U2Fatboy1',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},
            PlatoonData = {
                MoveChains = {'P2U2B1Landattack1', 'P2U2B1Landattack2', 'P2U2B1Landattack3'}
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

function P2U2Base2AI()

    P2U2Base2:InitializeDifficultyTables(ArmyBrains[UEF2], 'P2UEF2Base2', 'P2U2B2MK', 30, {P2U2Base2 = 100})
    P2U2Base2:StartEmptyBase({{3, 4, 5}, {2, 3, 4}})
    P2U2Base2:SetActive('AirScouting', true)

    P2U2Base3:AddExpansionBase('P2UEF2Base2', 3)

    P2U2B2Landattacks() 
end

function P2U2B2Landattacks()

    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P2U2B2LAttackTemp0',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P1U2B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
           PatrolChains = {'P2U2B2Landattack1', 'P2U2B2Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2U2B2LAttackTemp1',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2U2B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U2B2Landattack1', 'P2U2B2Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder ) 

    quantity = {4, 5, 6}
    Temp = {
        'P2U2B2LAttackTemp2',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2U2B2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.DEFENSE * categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U2B2Landattack1', 'P2U2B2Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P2U2B2LAttackTemp3',
        'NoPlan',
        { 'xel0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2U2B2LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.DEFENSE * categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U2B2Landattack1', 'P2U2B2Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )  
end

function P2U2Base3AI()

    P2U2Base3:InitializeDifficultyTables(ArmyBrains[UEF2], 'P2UEF2Base3', 'P2U2B3MK', 40, {P2U2Base3 = 100})
    P2U2Base3:StartNonZeroBase({{9, 10, 11}, {3, 4, 6}})
    P2U2Base3:SetActive('AirScouting', true)
    P2U2Base3:AddBuildGroup('P2U2Base3EXD', 90)


    P2U2B3Landattacks() 
    P2U2B3Airattacks()
    P2U2B3EXPattacks()
    P2U2B3Navalattacks()
end

function P2U2B3Landattacks()

    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P2U2B3LAttackTemp0',
        'NoPlan',
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P1U2B3LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base3',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},
        PlatoonData = {
           MoveChains = {'P2U2B3Landattack1', 'P2U2B3Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2U2B3LAttackTemp1',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2U2B3LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2U2B3Landattack1', 'P2U2B3Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder ) 
end

function P2U2B3Airattacks()
    
    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2U2B3AttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       
    }
    local Builder = {
        BuilderName = 'P2U2B3AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base3',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2U2B3Airpatrol1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'P2U2B3AttackTemp1',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2U2B3AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base3', 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2U2B2Landattack1','P2U2B3Landattack1', 'P2U2B3Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
end

function P2U2B3EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {3, 4, 5}
    trigger = {3, 2, 1}
    opai = P2U2Base3:AddOpAI('P2U2Fatboy2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M2_FAT_Platoon1',
                NumRequired = 2,
                PatrolChain = 'P2U2B2Landattack' .. Random(1, 2),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL, '>='},
                },
            }
        }
    )
end

function P2U2B3Navalattacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2U2B3NAttackTemp0',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2U2B3NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U2B3Navalattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 2}
    Temp = {
        'P2U2B3NAttackTemp1',
        'NoPlan',
        { 'xes0307', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2U2B3NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.NAVAL * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2U2B3Navalattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
end