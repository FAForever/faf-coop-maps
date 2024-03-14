local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'

local Player1 = 1
local KOrder = 4
local Order = 3

local P1KO1base1 = BaseManager.CreateBaseManager()
local P1KO1base2 = BaseManager.CreateBaseManager()
local P1O1base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P1KO1Base1AI()

    P1KO1base1:InitializeDifficultyTables(ArmyBrains[KOrder], 'P1KOrder1Base1', 'P1KO1base1MK', 80, {P1KO1Base1 = 100})
    P1KO1base1:StartNonZeroBase({{11, 16, 20}, {9, 14, 18}})
    P1KO1base1:SetActive('AirScouting', true)

    if Difficulty == 3 then
        ArmyBrains[KOrder]:PBMSetCheckInterval(6)
    end

    P1KO1B1Airattacks()
    P1KO1B1Navalattacks()
    P1KO1B1Landattacks() 
end

function P1KO1B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    trigger = {20, 15, 10}
    local Temp = {
        'P1KO1B1AttackTemp0',
        'NoPlan',
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 8}
    Temp = {
        'P1KO1B1AttackTemp1',
        'NoPlan',
        { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    Temp = {
        'P1KO1B1AttackTemp2',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE + categories.LAND) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {22, 18, 14}
    Temp = {
        'P1KO1B1AttackTemp3',
        'NoPlan',
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    quantity2 = {2, 3, 4}
    trigger = {14, 12, 8}
    Temp = {
        'P1KO1B1AttackTemp4',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0305', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {14, 12, 8}
    Temp = {
        'P1KO1B1AttackTemp5',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 310,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {5, 4, 3}
    Temp = {
        'P1KO1B1AttackTemp9',
        'NoPlan',
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder9',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 305,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Airattack1','P1KOB1Airattack2', 'P1KOB1Airattack3','P1KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    quantity2 = {1, 2, 3}
    Temp = {
        'P1KO1CAttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1CAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = quantity2[Difficulty],
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Airdefense1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    quantity2 = {1, 2, 3}
    Temp = {
        'P1KO1CAttackTemp1',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1CAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = quantity2[Difficulty],
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Airdefense2'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1KO1B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6}
    local Temp = {
        'P1KO1B2LAttackTemp0',
        'NoPlan',
        { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 5}
    trigger = {8, 7, 5}
    Temp = {
        'P1KO1B2LAttackTemp1',
        'NoPlan',
        { 'ual0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 4, 6}
    trigger = {12, 10, 8}
    Temp = {
        'P1KO1B2LAttackTemp3',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE + categories.LAND) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 4, 6}
    trigger = {12, 10, 8}
    Temp = {
        'P1KO1B2LAttackTemp4',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    trigger = {18, 15, 12}
    Temp = {
        'P1KO1B2LAttackTemp5',
        'NoPlan',
        { 'ual0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 212,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {10, 8, 5}
    Temp = {
        'P1KO1B2LAttackTemp6',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    trigger = {8, 6, 4}
    Temp = {
        'P1KO1B2LAttackTemp7',
        'NoPlan',
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 310,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    trigger = {20, 15, 10}
    Temp = {
        'P1KO1B2LAttackTemp8',
        'NoPlan',
        { 'dalk003', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder8',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 312,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    quantity2 = {1, 2, 2}
    trigger = {30, 25, 20}
    Temp = {
        'P1KO1B2LAttackTemp9',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dalk003', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder9',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 350,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P1KOB1Landattack1','P1KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    opai = P1KO1base1:AddOpAI('EngineerAttack', 'M1B1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2', 'P1KOB1Landattack1'}
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T1Engineers', 5)
end

function P1KO1B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P1KO1B1NAttackTemp0',
        'NoPlan',
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KOB1Navaldefense1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P1KO1B1NAttackTemp1',
        'NoPlan',
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {7, 5, 3}
    Temp = {
        'P1KO1B1NAttackTemp2',
        'NoPlan',
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 2, 3}
    trigger = {6, 5, 3}
    Temp = {
        'P1KO1B1NAttackTemp3',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    trigger = {20, 15, 10}
    Temp = {
        'P1KO1B1NAttackTemp4',
        'NoPlan',
        { 'uas0201', 1, 2, 'Attack', 'GrowthFormation' },   
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {5, 4, 4}
    Temp = {
        'P1KO1B1NAttackTemp5',
        'NoPlan',
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.T2SUBMARINE + categories.xss0304}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    trigger = {14, 12, 10}
    Temp = {
        'P1KO1B1NAttackTemp6',
        'NoPlan',
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - (categories.TECH1 + categories.ENGINEER)}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {2, 2, 1}
    Temp = {
        'P1KO1B1NAttackTemp7',
        'NoPlan',
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 310,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KOB1Navalattack1', 'P1KOB1Navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

-- Allied Base

function P1O1Base1AI()

    P1O1base1:InitializeDifficultyTables(ArmyBrains[Order], 'P1Order1Base1', 'P1O1base1MK', 70, {P1O1Base1 = 100})
    P1O1base1:StartNonZeroBase({{11, 9, 7}, {10, 8, 6}})
    
    P1O1B1Navalattacks()
    P1O1B1Airattacks()
    P1O1B1Landattacks()
end

function P1O1B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 5, 4}
    local Temp = {
        'P1O1B1AttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1O1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1OB1Airdefense1'
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {6, 5, 4}
    Temp = {
        'P1O1B1AttackTemp1',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1O1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1OB1Airattack1','P1OB1Airattack2','P1OB1Airattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P1O1B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {5, 4, 3}
    quantity2 = {3, 2, 1}
    local Temp = {
        'P1O1B1NAttackTemp0',
        'NoPlan',
        { 'uas0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1O1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1OB1Navaldefense1'
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {4, 3, 2}
    Temp = {
        'P1O1B1NAttackTemp1',
        'NoPlan',  
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, 1, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1O1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1OB1Navalattack1', 'P1OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P1O1B1Landattacks()

    local Temp = {
        'P1O1B1LAttackTemp0',
        'NoPlan',
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'ual0201', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xal0203', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1O1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1OB1Navalattack1', 'P1OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )  

    opai = P1O1base1:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1OB1Navalattack1', 'P1OB1Navalattack2'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 6)
end
