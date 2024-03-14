local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local UEF = 3
local Player1 = 1
local SeraphimAlly2 = 6

local Difficulty = ScenarioInfo.Options.Difficulty

local P3Ubase1 = BaseManager.CreateBaseManager()
local P3Ubase2 = BaseManager.CreateBaseManager()
local P3Ubase3 = BaseManager.CreateBaseManager()

function P3UEFbase1AI()
    P3Ubase1:InitializeDifficultyTables(ArmyBrains[UEF], 'UEFP3base1', 'P3UB1MK', 90, {P3UBase1 = 100})
    P3Ubase1:StartNonZeroBase({{13, 20, 26}, {11, 17, 22}})

    P3UB1AirAttacks()
    P3UB1LandAttacks()
    P3UB1NavalAttacks()
    P3UB1EXpattacks1()
end

function P3UB1AirAttacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P3UB1AirattackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3UB1AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3UB1AirDefense1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    Temp = {
        'P3UB1AirattackTemp1',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB1AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3', 'P3UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 8, 12}
    trigger = {20, 15, 10}
    Temp = {
        'P3UB1AirattackTemp2',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB1AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3', 'P3UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {45, 40, 35}
    Temp = {
        'P3UB1AirattackTemp3',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB1AirattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3', 'P3UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    trigger = {3, 2, 1}
    opai = P3Ubase1:AddOpAI('AirAttacks', 'M3_UEF_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty],  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P3UB1LandAttacks()

    local quantity = {}
    local trigger = {}

    quantity = {5, 7, 10}
    local Temp = {
        'P3UB1LandattackTemp0',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3UB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Landattack1', 'P3UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    Temp = {
        'P3UB1LandattackTemp1',
        'NoPlan',
        { 'uel0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB1LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 35, (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Landattack1', 'P3UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    Temp = {
        'P3UB1LandattackTemp2',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB1LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Landattack1', 'P3UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    Temp = {
        'P3UB1LandattackTemp3',
        'NoPlan',
        { 'delk002', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB1LandattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Landattack1', 'P3UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P3UB1NavalAttacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3UB1NavalattackTemp0',
        'NoPlan',
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3UB3NavalattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Navalattack1', 'P3UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {10, 8, 5}
    Temp = {
        'P3UB1NavalattackTemp1',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB3NavalattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Navalattack1', 'P3UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {10, 8, 4}
    Temp = {
        'P3UB1NavalattackTemp2',
        'NoPlan',
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB3NavalattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.T2SUBMARINE + categories.xss0304}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Navalattack1', 'P3UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    trigger = {4, 3, 2}
    Temp = {
        'P3UB1NavalattackTemp3',
        'NoPlan',
        { 'xes0307', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB3NavalattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEFP3base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3 - categories.xss0304}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Navalattack1', 'P3UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )   
end

function P3UB1EXpattacks1()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    trigger = {55, 45, 35}
    opai = P3Ubase1:AddOpAI('Fatboy1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Landattack1', 'P3UB1Landattack2'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3, '>='},
                },
            }
        }
    )
end

function P3UEFbase2AI()
    P3Ubase2:InitializeDifficultyTables(ArmyBrains[UEF], 'UEFP3base2', 'P3UB2MK', 80, {P3UBase2 = 100})
    P3Ubase2:StartNonZeroBase({{8, 11, 14}, {6, 9, 12}})

    P3UB2AirAttacks()
    P3UB2LandAttacks()
end

function P3UB2AirAttacks()

    local quantity = {}

    quantity = {2, 2, 3}
    local Temp = {
        'P3UB2AirattackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --ASF
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --Gunships
    }
    local Builder = {
        BuilderName = 'P3UB2AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3UB2AirDefense1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    Temp = {
        'P3UB2airattackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --Gunships
    }
    Builder = {
        BuilderName = 'P3UB2AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Landattack1', 'P3UB2Landattack2', 'P3UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {7, 8, 9}
    Temp = {
        'P3UB2airattackTemp2',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --ASFs
    }
    Builder = {
        BuilderName = 'P3UB2AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  'SeraphimAlly2', 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Landattack1', 'P3UB2Landattack2', 'P3UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P3UB2airattackTemp3',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --HeavyGunships
    }
    Builder = {
        BuilderName = 'P3UB2AirattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.xsb2305 + categories.uab2305}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Airattack1', 'P3UB2Airattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P3UB2airattackTemp4',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --HeavyGunships
    }
    Builder = {
        BuilderName = 'P3UB2AirattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Airattack1', 'P3UB2Airattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P3UB2LandAttacks()

    local quantity = {}

    quantity = {6, 8, 9}
    local Temp = {
        'P3UB2LandattackTemp0',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3UB2LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Landattack1', 'P3UB2Landattack2', 'P3UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P3UB2LandattackTemp1',
        'NoPlan',
        { 'delk002', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB2LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  'SeraphimAlly2', 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Landattack1', 'P3UB2Landattack2', 'P3UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P3UB2LandattackTemp2',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB2LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  'SeraphimAlly2', 10, categories.LAND * categories.MOBILE - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Landattack1', 'P3UB2Landattack2', 'P3UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P3UEFbase3AI()
    P3Ubase3:InitializeDifficultyTables(ArmyBrains[UEF], 'UEFP3base3', 'P3UB3MK', 80, {P3UBase3 = 100})
    P3Ubase3:StartNonZeroBase({{8, 11, 14}, {6, 9, 12}})

    P3UB3LandAttacks()
    P3UB3AirAttacks()
end

function P3UB3LandAttacks()

    local quantity = {}

    quantity = {3, 4, 5}
    local Temp = {
        'P3UB3LandattackTemp0',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3UB3LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB3Landattack1', 'P3UB3Landattack2', 'P3UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P3UB3LandattackTemp1',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB3LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFP3base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  'SeraphimAlly2', 12, categories.LAND * categories.MOBILE - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB3Landattack1', 'P3UB3Landattack2', 'P3UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P3UB3AirAttacks()

    local quantity = {}

    quantity = {2, 2, 3}
    local Temp = {
        'P3UB3AirattackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --ASF
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --Gunships
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --Gunships
    }
    local Builder = {
        BuilderName = 'P3UB3AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base3',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3UB3AirDefense1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    Temp = {
        'P3UB3AirattackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --Gunships
    }
    Builder = {
        BuilderName = 'P3UB3AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB3Landattack1', 'P3UB3Landattack2', 'P3UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    Temp = {
        'P3UB3AirattackTemp2',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },  --ASFs
    }
    Builder = {
        BuilderName = 'P3UB3AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFP3base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  'SeraphimAlly2', 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB3Landattack1', 'P3UB3Landattack2', 'P3UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
