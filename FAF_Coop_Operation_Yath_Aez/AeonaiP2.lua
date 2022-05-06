local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local Aeon = 4

local Difficulty = ScenarioInfo.Options.Difficulty

local Aeonbase1 = BaseManager.CreateBaseManager()
local Aeonbase2 = BaseManager.CreateBaseManager()

function Aeonbase1AI()

    Aeonbase1:InitializeDifficultyTables(ArmyBrains[Aeon], 'Aeonbase1', 'P2AB1MK', 70, {P2ABase1 = 100})
    Aeonbase1:StartNonZeroBase({{8, 11, 13}, {5, 8, 10}})
    Aeonbase1:SetActive('AirScouting', true)

    P2AB1landattacks()
    P2AB1Airattacks()
end

function P2AB1landattacks()

    local quantity = {}

    quantity = {4, 6, 9}
    local Temp = {
        'A_landAttackTemp1',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
        }
    local Builder = {
        BuilderName = 'A_landAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2AB1landattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 2}
    Temp = {
        'A_landAttackTemp2',
        'NoPlan',
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0111', 1, 4, 'Attack', 'GrowthFormation' },   
        }
    Builder = {
        BuilderName = 'A_landAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2AB1landattack1'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'A_landAttackTemp3',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'A_landAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.ALLUNITS * categories.TECH3 }},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P2AB1landattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder ) 
end

function P2AB1Airattacks()
    
    local quantity = {}

    quantity = {4, 6, 10}
    local Temp = {
       'A_AirAttackTemp1',
       'NoPlan',
       { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
   local Builder = {
       BuilderName = 'A_AirAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Aeonbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    Temp = {
        'A_AirAttackTemp2',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'A_AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE - categories.TECH1}},
        },   
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
   
    Temp = {
        'A_AirAttackTemp3',
        'NoPlan',
        { 'uaa0203', 1, 6, 'Attack', 'GrowthFormation' },  
        { 'xaa0202', 1, 6, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'A_AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2AB1airdefense1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'A_AirAttackTemp4',
        'NoPlan',
        { 'uaa0203', 1, 5, 'Attack', 'GrowthFormation' },  
        { 'xaa0202', 1, 5, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'A_AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2AB2defense1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    opai = Aeonbase1:AddOpAI('AirAttacks', 'M2_Aeon_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function Aeonbase2AI()

    Aeonbase2:InitializeDifficultyTables(ArmyBrains[Aeon], 'Aeonbase2', 'P2AB2MK', 50, {P2ABase2 = 100})
    Aeonbase2:StartEmptyBase({{5, 7, 8}, {3, 5, 6}})
    
    Aeonbase1:AddExpansionBase('Aeonbase2', 3)

    P2AB2landattacks()
end

function P2AB2landattacks()

    local quantity = {}

    quantity = {6, 7, 9}
    local Temp = {
        'P2AB2landAttackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        }
    local Builder = {
        BuilderName = 'P2AB2landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2AB2landAttackTemp1',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'P2AB2landAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )   
end


