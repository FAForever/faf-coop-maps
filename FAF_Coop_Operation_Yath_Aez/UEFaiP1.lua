local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local UEF = 2

local UEFBase1 = BaseManager.CreateBaseManager()
local UEFBase2 = BaseManager.CreateBaseManager()
local UEFBase3 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P1UEFBase1AI()

    UEFBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P1UEFBase1', 'P1UB1MK', 90, {P1UBase1 = 500})
    UEFBase1:StartNonZeroBase({{11, 14, 16}, {9, 12, 14}})
    UEFBase1:SetActive('AirScouting', true)
    
    UEFBase1.MaximumConstructionEngineers = 4
    ForkThread(
        function()
            WaitSeconds(4)
            UEFBase1:AddBuildGroup('P1UBase1EXD_D' .. Difficulty, 500, false)
        end
    )

    P1UB1AirAttack()
    P1UB1NavalAttack()
    P1UB1landAttack()
end

function P1UB1AirAttack()
    
    local quantity = {}
    local opai = nil
    local trigger = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P1UB1DefenseTemp0',
        'NoPlan',
        { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- Bombers
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- Gunships
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- ASFs
        { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  -- Intercepters
    }
    local Builder = {
        BuilderName = 'P1UB1DefenseBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Airdefence1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 5}
    Temp = {
        'P1UB1AirAttackTemp0',
        'NoPlan',
        { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  -- Bombers
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4', 'P1UB1Airattack5'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {3, 5, 8}
    trigger = {10, 9, 8}
    Temp = {
        'P1UB1AirAttackTemp1',
        'NoPlan',
        { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Intercepters
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 102,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4', 'P1UB1Airattack5'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 8}
    trigger = {80, 70, 60}
    Temp = {
        'P1UB1AirAttackTemp2',
        'NoPlan',
        { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- bombers
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 101,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4', 'P1UB1Airattack5'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 5}
    trigger = {10, 8, 6}
    Temp = {
        'P1UB1AirAttackTemp3',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Gunships
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 140,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4', 'P1UB1Airattack5'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {22, 18, 12}
    Temp = {
        'P1UB1AirAttackTemp4',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Bomber/fighters
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 155,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4', 'P1UB1Airattack5'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 9}
    trigger = {28, 24, 20}
    Temp = {
        'P1UB1AirAttackTemp5',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Gunships
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4', 'P1UB1Airattack5'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {7, 5, 3}
    Temp = {
        'P1UB1AirAttackTemp6',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- torpbombers
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 170,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Airattack5'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 5}
    trigger = {10, 9, 8}
    Temp = {
        'P1UB1AirAttackTemp7',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Gunships
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Gunships
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4', 'P1UB1Airattack5'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {10, 8, 6}
    Temp = {
        'P1UB1AirAttackTemp8',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Gunships
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder8',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4', 'P1UB1Airattack5'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 10}
    trigger = {10, 9, 8}
    Temp = {
        'P1UB1AirAttackTemp9',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Torpbombers
    }
    Builder = {
        BuilderName = 'P1UB1AirattackBuilder9',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 206,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 14, categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Airattack5'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    opai = UEFBase1:AddOpAI('AirAttacks', 'M1_UEF_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 250,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {1, 2, 3}
    opai = UEFBase1:AddOpAI('AirAttacks', 'M1_UEF_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.TECH3 * categories.MASSEXTRACTION },
            },
            Priority = 230,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 3, categories.TECH3 * categories.MASSEXTRACTION, '>='})
end

function P1UB1NavalAttack()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}

    local Temp = {
        'P1UB1NavalDefenceTemp0',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB1NavalDefenceBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Navaldefence1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
    quantity = {1, 2, 2}
    Temp = {
        'P1UB1NavalAttackTemp0',
        'NoPlan',
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1NavalBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Navalattack1', 'P1UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 3, 4}
    trigger = {7, 6, 5}
    Temp = {
        'P1UB1NavalAttackTemp1',
        'NoPlan',
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1NavalBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Navalattack1', 'P1UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {10, 8, 6}
    Temp = {
        'P1UB1NavalAttackTemp2',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1NavalBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.T1SUBMARINE + categories.T2SUBMARINE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Navalattack1', 'P1UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {16, 14, 12}
    Temp = {
        'P1UB1NavalAttackTemp3',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1NavalBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Navalattack1', 'P1UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {9, 7, 5}
    Temp = {
        'P1UB1NavalAttackTemp4',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1NavalBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Navalattack1', 'P1UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {20, 15, 10}
    Temp = {
        'P1UB1NavalAttackTemp5',
        'NoPlan',
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1NavalBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Navalattack1', 'P1UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    trigger = {10, 9, 8}
    Temp = {
        'P1UB1NavalAttackTemp6',
        'NoPlan',
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1NavalBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 215,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Navalattack1', 'P1UB1Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1UB1landAttack()
    
    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 8}
    trigger = {18, 16, 14}

    local Temp = {
        'P1UB1Landattack0',
        'NoPlan',
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Landattack1', 'P1UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 4}
    trigger = {18, 14, 10}
    Temp = {
        'P1UB1Landattack1',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P1UB1Landattack1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 4}
    trigger = {18, 14, 10}
    Temp = {
        'P1UB1Landattack2',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB1LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P1UB1Landattack2'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    opai = UEFBase1:AddOpAI('EngineerAttack', 'M2_UEF_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1UB1MK',
        },
        Priority = 400,
    })
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', quantity[Difficulty], categories.uea0104})
   
    quantity = {6, 12, 18}
    trigger = {40, 35, 30}
    opai = UEFBase1:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1UB1landingchainA1', 
                LandingChain = 'P1UB1landingchain1',
                TransportReturn = 'P1UB1MK',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH2, '>='})
    
    quantity = {6, 12, 18}
    trigger = {70, 65, 60}
    opai = UEFBase1:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1UB1landingchainA2', 
                LandingChain = 'P1UB1landingchain2',
                TransportReturn = 'P1UB1MK',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 12, 18}
    trigger = {70, 65, 60}
    opai = UEFBase1:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1UB1landingchainA1', 
                LandingChain = 'P1UB1landingchain1',
                TransportReturn = 'P1UB1MK',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 12, 18}
    trigger = {40, 35, 30}
    opai = UEFBase1:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1UB1landingchainA2', 
                LandingChain = 'P1UB1landingchain2',
                TransportReturn = 'P1UB1MK',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH2, '>='})

    quantity = {3, 6, 9}
    trigger = {10, 9, 8}
    opai = UEFBase1:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_5',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1UB1landingchainA1', 
                LandingChain = 'P1UB1landingchain1',
                TransportReturn = 'P1UB1MK',
            },
            Priority = 310,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    quantity = {3, 6, 9}
    trigger = {10, 9, 8}
    opai = UEFBase1:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_6',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1UB1landingchainA2', 
                LandingChain = 'P1UB1landingchain2',
                TransportReturn = 'P1UB1MK',
            },
            Priority = 305,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})
end 

function P1UEFBase2AI()

    UEFBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P1UEFBase2', 'P1UB2MK', 50, {P1UBase2 = 100})
    UEFBase2:StartNonZeroBase({{2, 3, 4}, {1, 2, 3}})

    P1UB2LandAttack() 
end

function P1UB2LandAttack()

    local quantity = {}

    quantity = {2, 3, 6}   
    local Temp = {
        'P1UB2landAttacks0',
        'NoPlan',
        { 'uel0106', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB2landattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    Temp = {
        'P1UB2landAttacks1',
        'NoPlan',
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 101,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    Temp = {
        'P1UB2landAttacks2',
        'NoPlan',
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 103,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 8, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1UB2landAttacks3',
        'NoPlan',
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0104', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 102,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 12, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1UB2landAttacks4',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1UB2landAttacks5',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 203,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 8, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P1UB2landAttacks6',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P1UB2landAttacks7',
        'NoPlan',
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uel0202', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1UB3Landdefense1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )             
end
   
function P1UEFBase3AI()
    
    UEFBase3:InitializeDifficultyTables(ArmyBrains[UEF], 'P1UEFBase3', 'P1UB3MK', 50, { P1UBase3 = 100})
    UEFBase3:StartNonZeroBase({{2, 3, 4}, {1, 2, 3}})
    
    P1UB3LandAttack()   
end

function P1UB3LandAttack()

    local quantity = {}

    quantity = {2, 3, 6}   
    local Temp = {
        'P1UB3landAttacks0',
        'NoPlan',
        { 'uel0106', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB3landattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2', 'P1UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    Temp = {
        'P1UB3landAttacks1',
        'NoPlan',
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 101,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2', 'P1UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    Temp = {
        'P1UB3landAttacks2',
        'NoPlan',
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 103,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 6, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2', 'P1UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1UB3landAttacks3',
        'NoPlan',
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0104', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 102,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 12, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2', 'P1UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1UB3landAttacks4',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2', 'P1UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1UB3landAttacks5',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 203,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2', 'P1UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P1UB3landAttacks6',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2', 'P1UB3Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )  

    quantity = {3, 4, 6}
    Temp = {
        'P1UB3landAttacks7',
        'NoPlan',
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uel0202', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1UB2Landdefense1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )         
end