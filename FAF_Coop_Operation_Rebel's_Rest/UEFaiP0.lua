local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local UEF1 = 2

local P0U1Base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P0U1Base1AI()

    local quantity = {}
    P0U1Base1:InitializeDifficultyTables(ArmyBrains[UEF1], 'P0UEF1Base1', 'P0U1B1MK', 70, {P1U1Bases0 = 110})
    P0U1Base1:StartNonZeroBase({{8, 11, 15}, {7, 10, 14}})
    P0U1Base1:SetActive('AirScouting', true)
    P0U1Base1:SetMaximumConstructionEngineers(5)

    ForkThread(
        function()
            WaitSeconds(5)
            P0U1Base1:AddBuildGroup('P1U1Bases0EXD_D' .. Difficulty, 100, false)
        end
    )

    P0U1B1Airattacks()
    P0U1B1Landattacks()
end

function P0U1B1Airattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {5, 7, 8}
    local Temp = {
        'P0U1B1AttackTempDefense',
        'NoPlan',
        { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P0U1B1AttackBuilderDefense',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P0U1B1AirDefense'
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {6, 5, 4}
    Temp = {
        'P0U1B1AAttackTemp0',
        'NoPlan',
        { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {6, 5, 4}
    Temp = {
        'P0U1B1AAttackTemp1',
        'NoPlan',
        { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {70, 50, 40}
    Temp = {
        'P0U1B1AAttackTemp2',
        'NoPlan',
        { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    quantity2 = {4, 5, 7}
    trigger = {8, 7, 6}
    Temp = {
        'P0U1B1AAttackTemp3',
        'NoPlan',
        { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1AAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 115,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )      
end

function P0U1B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P0U1B1LAttackTemp0',
        'NoPlan',
        { 'uel0106', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P0U1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {20, 16, 14}
    Temp = {
        'P0U1B1LAttackTemp1',
        'NoPlan',
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.STRUCTURE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {12, 10, 8}
    Temp = {
        'P0U1B1LAttackTemp2',
        'NoPlan',
        { 'uel0104', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 107,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {10, 6, 4}
    Temp = {
        'P0U1B1LAttackTemp3',
        'NoPlan',
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    quantity = {8, 9, 10}
    trigger = {55, 45, 35}
    Temp = {
        'P0U1B1LAttackTemp4',
        'NoPlan',
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0103', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1LAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )  

    quantity = {2, 3, 4}
    trigger = {9, 7, 5}
    Temp = {
        'P0U1B1LAttackTemp5',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1LAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder ) 

    quantity = {2, 3, 4}
    trigger = {9, 7, 5}
    Temp = {
        'P0U1B1LAttackTemp6',
        'NoPlan',
        { 'uel0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1LAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 160,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder ) 

    quantity = {2, 3, 7}
    trigger = {4, 2, 1}
    Temp = {
        'P0U1B1LAttackTemp7',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P0U1B1LAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 170,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P0UEF1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3 }},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
    }
    ArmyBrains[UEF1]:PBMAddPlatoon( Builder )

    opai = P0U1Base1:AddOpAI('EngineerAttack', 'M0B1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P0U1B1Patrol1', 'P0U1B1Patrol2', 'P0U1B1Patrol3', 'P0U1B1Patrol4'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 3)
end

function P0ADDTML()
    P0U1Base1:AddBuildGroupDifficulty('P1U1Bases0EXD2', 120)

    ForkThread(
        function()
            WaitSeconds(120)
            local TML = ArmyBrains[UEF1]:GetListOfUnits(categories.ueb2108, false)
            for _, v in TML do
                if v and not v:IsDead() and EntityCategoryContains(categories.TACTICALMISSILEPLATFORM, v) then
                    local plat = ArmyBrains[UEF1]:MakePlatoon('', '')
                    ArmyBrains[UEF1]:AssignUnitsToPlatoon(plat, {v}, 'Attack', 'NoFormation')
                    plat:ForkAIThread(plat.TacticalAI)
                    WaitSeconds(4)
                end
            end
        end
    )
end