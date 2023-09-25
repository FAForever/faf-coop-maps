local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Rebel\'s_Rest/FAF_Coop_Operation_Rebel\'s_Rest_CustomFunctions.lua'

local Player1 = 1
local UEF1 = 2
local UEF2 = 3

local P3U1Base1 = BaseManager.CreateBaseManager()
local P3U1Base2 = BaseManager.CreateBaseManager()
local P3U1Base3 = BaseManager.CreateBaseManager()
local P3U1Base4 = BaseManager.CreateBaseManager()
local P3U2Base1 = BaseManager.CreateBaseManager()
local P3U2Base2 = BaseManager.CreateBaseManager()
local P3U2Base3 = BaseManager.CreateBaseManager()
local P3U2Base4 = BaseManager.CreateBaseManager()

local P3U1Mav = BaseManager.CreateBaseManager()
local P3U2Mav1 = BaseManager.CreateBaseManager()
local P3U2Mav2 = BaseManager.CreateBaseManager()
local P3U2Nov = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P3U1MavAI()

    P3U1Mav:InitializeDifficultyTables(ArmyBrains[UEF1], 'P3UEF1Mav', 'P3U1Mav1MK', 30, {P3U1MavorBase = 100})
    P3U1Mav:StartNonZeroBase({3, 5, 7})
    P3U1Mav:AddBuildGroup('P3U1Mavor', 90)  
end

function P3U2Mav1AI()

    P3U2Mav1:InitializeDifficultyTables(ArmyBrains[UEF2], 'P3UEF2Mav1', 'P3U2Mav1MK', 30, {P3U2MavorBase1 = 100})
    P3U2Mav1:StartNonZeroBase({1, 2, 3})
    P3U2Mav1:AddBuildGroup('U2Mavor1', 90)
end

function P3U2Mav2AI()

    P3U2Mav2:InitializeDifficultyTables(ArmyBrains[UEF2], 'P3UEF2Mav2', 'P3U2Mav2MK', 30, {P3U2MavorBase2 = 100})
    P3U2Mav2:StartNonZeroBase({3, 4, 5})
    P3U2Mav2:AddBuildGroup('U2Mavor2', 90) 
end

function P3U2NovaxAI()

    P3U2Nov:InitializeDifficultyTables(ArmyBrains[UEF2], 'P3UEF2Novax', 'P3U2NovMK', 30, {P3Random1 = 100})
    P3U2Nov:StartNonZeroBase({2, 4, 6})
    P3U2Nov:AddBuildGroup('P3Random1EXD', 90) 
end

-- UEF1 bases

function P3U1Base1AI()

    P3U1Base1:InitializeDifficultyTables(ArmyBrains[UEF1], 'P3UEF1Base1', 'P3U1B1MK', 120, {P3U1Base1 = 100})
    P3U1Base1:StartNonZeroBase({{13, 16, 22}, {9, 14, 18}})
    P3U1Base1:SetActive('AirScouting', true)
    
    P3U1B1Airattacks()
    P3U1B1Landattacks()
    P3U1B1Navalattacks() 
    P3U1B1EXPattacks() 
end

function P3U1B1Airattacks()
    
    local quantity = {}
    local trigger = {}
    
    quantity = {4, 5, 6}
    local Temp = {
        'P3U1B1AttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3U1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3U1B1AirPatrol1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    trigger = {25, 20, 15}
    Temp = {
        'P3U1B1AttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B1Airattack1','P3U1B1Airattack2', 'P3U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P3U1B1AttackTemp2',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1', 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B1Airattack1','P3U1B1Airattack2', 'P3U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {20, 16, 12}
    Temp = {
        'P3U1B1AttackTemp3',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B1Airattack1','P3U1B1Airattack2', 'P3U1B1Airattack3'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder ) 
end

function P3U1B1Landattacks()

    local opai = nil
    local quantity = {}

    quantity = {5, 7, 9}
    local Temp = {
        'P3U1B1LAttackTemp0',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3U1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P3U1B1Landattack1', 'P3U1B1Landattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    local opai = nil
    local trigger = {}
    local poolName = 'P3UEF1Base1_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M3_UEF1_B1_Transport_Platoon',
        'NoPlan',
        { 'xea0306', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M3_UEF1_B1_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P3UEF1Base1',
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {1, 2, 3}
    local Quantity2 = {3, 4, 6}
    Builder = {
        BuilderName = 'M3_UEF1B1_Land_Assault',
        PlatoonTemplate = {
            'M3_UEF1B1_Land_Assault_Template',
            'NoPlan',
            {'xel0305', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'uel0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 Arty
            {'uel0205', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 AA
        },
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEF2Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P3DropAttack1',
            LandingChain = 'P3Drop2',
            TransportReturn = 'P3U1B1MK',
            BaseName = 'P3UEF1Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end

function P3U1B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3U1B1NAttackTemp0',
        'NoPlan',
        { 'xes0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P3U1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3U1B1Navalattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {5, 4, 3}
    Temp = {
        'P3U1B1NAttackTemp1',
        'NoPlan',
        { 'ues0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3U1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3U1B1Navalattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {30, 25, 20}
    Temp = {
        'P3U1B1NAttackTemp2',
        'NoPlan',
        { 'xes0307', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3U1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3U1B1Navalattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )  
end

function P3U1B1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = P3U1Base1:AddOpAI('P3U1Fatboy1',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
                MoveChains = {'P3U1B1Landattack1', 'P3U1B1Landattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P3U1Base2AI()

    P3U1Base2:InitializeDifficultyTables(ArmyBrains[UEF1], 'P3UEF1Base2', 'P3U1B2MK', 50, {P3U1Base2 = 100})
    P3U1Base2:StartNonZeroBase({{6, 8, 10}, {4, 6, 8}})
    P3U1Base2:SetActive('AirScouting', true)

    P3U1Base2:AddExpansionBase('P2UEF1Base2', 3)
    
    P3U1B2Airattacks()
    P3U1B2Landattacks()
    P3U1B2EXPattacks() 
end

function P3U1B2Airattacks()
    
    local quantity = {}
    local trigger = {}
    
    quantity = {4, 5, 6}
    local Temp = {
        'P3U1B2AttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3U1B2AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3U1B2AirPatrol1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    trigger = {25, 20, 15}
    Temp = {
        'P3U1B2AttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B2AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B2Airattack1','P3U1B2Airattack2', 'P3U1B2Airattack3', 'P3U1B2Airattack4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    Temp = {
        'P3U1B2AttackTemp2',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B2AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base2', 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B2Airattack1','P3U1B2Airattack2', 'P3U1B2Airattack3', 'P3U1B2Airattack4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {25, 20, 15}
    Temp = {
        'P3U1B2AttackTemp3',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B2AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B2Airattack1','P3U1B2Airattack2', 'P3U1B2Airattack3', 'P3U1B2Airattack4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder ) 

    quantity = {6, 12, 18}
    opai = P3U1Base2:AddOpAI('AirAttacks', 'M3_UEF1B2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {6, 12, 18}
    opai = P3U1Base2:AddOpAI('AirAttacks', 'M3_UEF1B2_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR - categories.SATELLITE },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.AIR - categories.SATELLITE, '>='})

    quantity = {6, 12, 18}
    opai = P3U1Base2:AddOpAI('AirAttacks', 'M3_UEF1B2_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.NAVAL},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.NAVAL, '>='})
end

function P3U1B2Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {5, 7, 9}
    
    local Temp = {
        'P3U1B2GAttackTemp1',
        'NoPlan',
        { 'uel0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P3U1B2GAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base2',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P3U1B2Landattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end

function P3U1B2EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = P3U1Base2:AddOpAI('P3U1Fatboy2',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P3U1B2Landattack1'
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P3U1Base3AI()

    P3U1Base3:InitializeDifficultyTables(ArmyBrains[UEF1], 'P3UEF1Base3', 'P3U1B3MK', 120, {P3U1Base3 = 100})
    P3U1Base3:StartNonZeroBase({{11, 14, 18}, {7, 10, 14}})
    P3U1Base3:SetActive('AirScouting', true)
    
    P3U1Base3:AddExpansionBase('P2UEF1Base1', 3)

    P3U1B3Airattacks()
    P3U1B3Landattacks()
    P3U1B3EXPattacks()
    P3U1B3Navalattacks()
    P3U1B3BuildNukeSubs()
end

function P3U1B3Airattacks()
    
    local quantity = {}
    local trigger = {}
    
    quantity = {4, 5, 6}
    local Temp = {
        'P3U1B3AttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3U1B3AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3U1B3AirPatrol1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    trigger = {25, 20, 15}
    Temp = {
        'P3U1B3AttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B3AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B3Navalattack1','P3U1B3Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    Temp = {
        'P3U1B3AttackTemp2',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B3AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B3Navalattack1','P3U1B3Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end

function P3U1B3Landattacks()

    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    
    local Temp = {
        'P3U1B3GAttackTemp1',
        'NoPlan',
        { 'uel0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P3U1B3GAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P3U1B3Landattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 9}
    Temp = {
        'P3U1B3LAttackTemp0',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B3LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P3U1B3Landattack1'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P3UEF1Base3_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M3_UEF1_B3_Transport_Platoon',
        'NoPlan',
        { 'xea0306', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M3_UEF1_B3_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P3UEF1Base3',
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {1, 2, 3}
    local Quantity2 = {3, 4, 6}
    Builder = {
        BuilderName = 'M3_UEF1B3_Land_Assault',
        PlatoonTemplate = {
            'M3_UEF1B3_Land_Assault_Template',
            'NoPlan',
            {'xel0305', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'uel0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 Arty
            {'uel0205', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 AA
        },
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P3DropAttack1',
            LandingChain = 'P3Drop1',
            TransportReturn = 'P3U1B3MK',
            BaseName = 'P3UEF1Base3',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end

function P3U1B3Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3U1B3NAttackTemp0',
        'NoPlan',
        { 'xes0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P3U1B3NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B3Navalattack1','P3U1B3Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    Temp = {
        'P3U1B3NAttackTemp1',
        'NoPlan',
        { 'ues0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3U1B3NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.NAVAL * categories.MOBILE * categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B3Navalattack1','P3U1B3Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'P3U1B3NAttackTemp2',
        'NoPlan',
        { 'xes0307', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3U1B3NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 4, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U1B3Navalattack1','P3U1B3Navalattack2'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )  
end

function P3U1B3BuildNukeSubs()
    local quantity = {1, 2, 2}
    local opai = P3U1Base3:AddOpAI('NavalAttacks', 'M3_UEF1_NukeSub_Attack_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'M3UEF2NukeSubmarinesHandle'},
            PlatoonData = {
                TargetChain = 'NukePlayers',
                MoveChain = 'P3U1Nukewait1',
                NukeDelay = {12 * 60, 10 * 60, 8 * 60},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('NukeSubmarines', quantity[Difficulty])
    opai:SetFormation('NoFormation')
end

function P3U1B3EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = P3U1Base3:AddOpAI('P3U1Sub1',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M3_At_Platoon1',
                NumRequired = 2,
                PatrolChain = 'P3U1B3Navalattack' .. Random(1, 2),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P3U1Base4AI()

    P3U1Base4:Initialize(ArmyBrains[UEF1], 'P3UEF1Base4', 'P3U1B4MK', 40, {
    P3U1Base4 = 100, 
    P3U1Base4Fac = 120,
    P3U1Base4Eco1 = 110,
    P3U1Base4Eco2 = 105,})
    P3U1Base4:StartEmptyBase({{5, 7, 8}, {4, 5, 6}})

    P3U1B4Airattacks()
    P3U1B4Landattacks()
end

function P3U1B4Airattacks()

    local quantity = {}

    quantity = {6, 7, 9}
    local Temp = {
        'P3U1B4AttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3U1B4AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B1Airattack1','P3U2B1Airattack2', 'P3U2B1Airattack3', 'P3U2B1Airattack4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P3U1B4AttackTemp2',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B4AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base4', 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B1Airattack1','P3U2B1Airattack2', 'P3U2B1Airattack3', 'P3U2B1Airattack4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
end

function P3U1B4Landattacks()

    local opai = nil
    local quantity = {}

    quantity = {4, 6, 8}
    Temp = {
        'P3U1B4LAttackTemp0',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U1B4LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEF1Base4',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3U2B1Landattack1','P3U2B1Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )   
end

--UEF 2 bases

function P3U2Base1AI()

    P3U2Base1:InitializeDifficultyTables(ArmyBrains[UEF2], 'P3UEF2Base1', 'P3U2B1MK', 130, {P3U2Base1 = 100})
    P3U2Base1:StartNonZeroBase({{13, 16, 22}, {9, 14, 18}})
    P3U2Base1:SetActive('AirScouting', true)
    
    P3U2B1Airattacks()
    P3U2B1Landattacks()
    P3U2B1EXPattacks()
    P3U2B1Navalattacks()
end

function P3U2B1Airattacks()
    
    local quantity = {}
    
    quantity = {4, 6, 8}
    local Temp = {
        'P3U2B1AttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3U2B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3U2B1AirPatrol1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    Temp = {
        'P3U2B1AttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B1Airattack1','P3U2B1Airattack2', 'P3U2B1Airattack3', 'P3U2B1Airattack4'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    Temp = {
        'P3U2B1AttackTemp2',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B1Airattack1','P3U2B1Airattack2', 'P3U2B1Airattack3', 'P3U2B1Airattack4'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
        'P3U2B1AttackTemp3',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B1Airattack1','P3U2B1Airattack2', 'P3U2B1Airattack3', 'P3U2B1Airattack4'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
end

function P3U2B1Landattacks()

    local opai = nil
    local quantity = {}

    quantity = {4, 6, 8}
    
    local Temp = {
        'P3U2B1GAttackTemp1',
        'NoPlan',
        { 'uel0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P3U1B1GAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P3U2B1Landattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    Temp = {
        'P3U2B1LAttackTemp0',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3U2B1Landattack1','P3U2B1Landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P3UEF2Base1_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M3_UEF2_B1_Transport_Platoon',
        'NoPlan',
        { 'xea0306', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M3_UEF2_B1_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P3UEF2Base1',
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {1, 2, 3}
    local Quantity2 = {3, 4, 9}
    Builder = {
        BuilderName = 'M3_UEF2B1_Land_Assault',
        PlatoonTemplate = {
            'M3_UEF2B1_Land_Assault_Template',
            'NoPlan',
            {'xel0305', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Tank
            {'uel0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Arty
            {'uel0205', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 AA
            {'uel0307', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 sheild
        },
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {3, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P3DropAttack1',
            LandingChain = 'P3Drop1',
            TransportReturn = 'P3U2B1MK',
            BaseName = 'P3UEF2Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

   quantity = {{4, 0}, {5, 0}, {6, 0}}
    opai = P3U2Base1:AddOpAI('EngineerAttack', 'M3_UEF2B1_Assist_Engineers_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'P3UEF2Base4',
                Factories = categories.TECH3 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('T3Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.TECH3 * categories.NAVAL * categories.FACTORY})
end

function P3U2B1Navalattacks()

    local quantity = {}

    quantity = {3, 4, 6}
    local Temp = {
        'P3U2B1NAttackTemp0',
        'NoPlan',
        { 'xes0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P3U2B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B1Navalattack1','P3U2B1Navalattack2','P3U2B1Navalattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P3U2B1NAttackTemp1',
        'NoPlan',
        { 'ues0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3U2B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 4, categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B1Navalattack1','P3U2B1Navalattack2','P3U2B1Navalattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P3U2B1NAttackTemp2',
        'NoPlan',
        { 'xes0307', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3U2B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.NAVAL - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B1Navalattack1','P3U2B1Navalattack2','P3U2B1Navalattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )  
end

function P3U2B1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = P3U2Base1:AddOpAI('P3U2Sub1',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P3U2B1Navalattack1','P3U2B1Navalattack2','P3U2B1Navalattack3'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            
        }
    )

    quantity = {2, 3, 4}
    opai = P3U2Base1:AddOpAI('P3U2Fatboy1',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P3U2B1Landattack1','P3U2B1Landattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P3U2Base2AI()

    P3U2Base2:InitializeDifficultyTables(ArmyBrains[UEF2], 'P3UEF2Base2', 'P3U2B2MK', 110, {P3U2Base2 = 100})
    P3U2Base2:StartNonZeroBase({{13, 16, 22}, {9, 14, 18}})
    P3U2Base2:SetActive('AirScouting', true)
    
    P3U2B2Airattacks()
    P3U2B2EXPattacks()
    P3U2B2Navalattacks()
end

function P3U2B2Airattacks()
    
    local quantity = {}
    
    quantity = {4, 6, 8}
    local Temp = {
        'P3U2B2AAttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3U2B2AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3U2B2AirPatrol1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    Temp = {
        'P3U2B2AttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B2AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B2Navalattack1','P3U2B2Navalattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    Temp = {
        'P3U2B2AAttackTemp2',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B2AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B2Navalattack1','P3U2B2Navalattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
end

function P3U2B2Navalattacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3U2B2NAttackTemp0',
        'NoPlan',
        { 'xes0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P3U2B2NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B2Navalattack1','P3U2B2Navalattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    Temp = {
        'P3U2B2NAttackTemp1',
        'NoPlan',
        { 'ues0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3U2B2NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.NAVAL * categories.MOBILE * categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B2Navalattack1','P3U2B2Navalattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'P3U2B2NAttackTemp2',
        'NoPlan',
        { 'xes0307', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3U2B2NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B2Navalattack1','P3U2B2Navalattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )  
end

function P3U2B2EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = P3U2Base2:AddOpAI('P3U2Sub2',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
                PatrolChains = {'P3U2B2Navalattack1','P3U2B1Navalattack2'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P3U2Base3AI()

    P3U2Base3:InitializeDifficultyTables(ArmyBrains[UEF2], 'P3UEF2Base3', 'P3U2B3MK', 100, {P3U2Base3 = 100})
    P3U2Base3:StartNonZeroBase({{11, 14, 18}, {7, 10, 14}})
    P3U2Base3:SetActive('AirScouting', true)
    
    P3U2B3Airattacks()
    P3U2B3EXPattacks()
end

function P3U2B3Airattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {4, 6, 8}
    local Temp = {
        'P3U2B3AAttackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3U2B3AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base3',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3U2B3AirPatrol1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 9, 12}
    Temp = {
        'P3U2B3AAttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B3AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B3Airattack1','P3U2B3Airattack2','P3U2B3Airattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    Temp = {
        'P3U2B3AAttackTemp2',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B3AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B3Airattack1','P3U2B3Airattack2','P3U2B3Airattack3'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {6, 12, 18}
    opai = P3U2Base3:AddOpAI('AirAttacks', 'M3_UEF2B3_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {6, 12, 18}
    opai = P3U2Base3:AddOpAI('AirAttacks', 'M3_UEF2B3_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR - categories.SATELLITE },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.AIR - categories.SATELLITE, '>='})

    quantity = {6, 12, 18}
    opai = P3U2Base3:AddOpAI('AirAttacks', 'M3_UEF2B3_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.NAVAL},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.NAVAL, '>='})
end

function P3U2B3EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = P3U2Base3:AddOpAI('P3U2Fatboy2',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P3U2B3Landattack1'
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )

    local quantity = {}

    quantity = {1, 2, 3}
    
    local Temp = {
        'P3U2B3GAttackTemp1',
        'NoPlan',
        { 'uel0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P3U2B3GAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base3',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P3U2B3Landattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
end

function P3U2Base4AI()

    P3U2Base4:InitializeDifficultyTables(ArmyBrains[UEF2], 'P3UEF2Base4', 'P3U2B4MK', 120, {P3U2Base4 = 100})
    P3U2Base4:StartNonZeroBase({{11, 14, 18}, {7, 10, 14}})
    P3U2Base4:SetActive('AirScouting', true)
    
    P3U2B4Airattacks()
    P3U2B4EXPattacks()
    P3U2B4Navalattacks()
    P3U2B4Landattacks()
    P3U2B4BuildNukeSubs()
end

function P3U2B4Airattacks()

    local opai = nil
    local quantity = {}
    
    quantity = {3, 4, 5}
    local Temp = {
        'P3U2B4AAttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3U2B4AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B4landattack1','P3U2B4landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 7}
    Temp = {
        'P3U2B4AAttackTemp2',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B4AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3U2B4landattack1','P3U2B4landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
end

function P3U2B4Navalattacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3U2B4NAttackTemp0',
        'NoPlan',
        { 'xes0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P3U2B4NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3U2B4Navalattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
end

function P3U2B4Landattacks()

    local opai = nil
    local quantity = {}

    quantity = {2, 3, 4}
    
    local Temp = {
        'P3U2B4GAttackTemp1',
        'NoPlan',
        { 'uel0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P3U2B4GAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base4',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P3U2B1Landattack1'
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    Temp = {
        'P3U2B4LAttackTemp0',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3U2B4LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base4',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3U2B4landattack1','P3U2B4landattack2'}
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    local opai = nil
    local trigger = {}
    local poolName = 'P3UEF2Base4_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M3_UEF2_B3_Transport_Platoon',
        'NoPlan',
        { 'xea0306', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M3_UEF2_B3_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base4',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P3UEF2Base4',
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {1, 2, 4}
    local Quantity2 = {3, 4, 12}
    Builder = {
        BuilderName = 'M3_UEF2B3_Land_Assault',
        PlatoonTemplate = {
            'M3_UEF2B3_Land_Assault_Template',
            'NoPlan',
            {'xel0305', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Tank
            {'uel0307', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 sheild
        },
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEF2Base4',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {3, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P3DropAttack2',
            LandingChain = 'P3Drop2',
            TransportReturn = 'P3U2B4MK',
            BaseName = 'P3UEF2Base4',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[UEF2]:PBMAddPlatoon( Builder )

    -- Extra engineers assisting T2 naval factories, all T2 factories has to be built
    -- Count is {X, 0} since the platoon contains shields/stealth as well and we want just the engineers. And too lazy to make a new platoon rn.
    quantity = {{6, 0}, {7, 0}, {9, 0}}
    opai = P3U2Base4:AddOpAI('EngineerAttack', 'M3_UEF2B4_Assist_Engineers_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'P3UEF2Base4',
                Factories = categories.TECH3 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('T3Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.TECH3 * categories.NAVAL * categories.FACTORY})
end

function P3U2B4BuildNukeSubs()
    local quantity = {1, 1, 2}
    local opai = P3U2Base4:AddOpAI('NavalAttacks', 'M3_UEF2_NukeSub_Attack_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'M3UEF2NukeSubmarinesHandle'},
            PlatoonData = {
                TargetChain = 'NukePlayers',
                MoveChain = 'P3U2Nukewait1',
                NukeDelay = {9 * 60, 7 * 60, 5 * 60},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('NukeSubmarines', quantity[Difficulty])
    opai:SetFormation('NoFormation')
end

function P3U2B4EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = P3U2Base4:AddOpAI('P3U2Sub2',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
            PlatoonData = {
            PatrolChains = 'P3U2B4Navalattack1'
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end
