local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local Cybran = 3
local Difficulty = ScenarioInfo.Options.Difficulty

local Cybranbase1 = BaseManager.CreateBaseManager()
local Cybranbase2 = BaseManager.CreateBaseManager()

function Cybranbase1AI()

    Cybranbase1:InitializeDifficultyTables(ArmyBrains[Cybran], 'Cybranbase1', 'P2CB1MK', 90, {P2CBase1 = 100})
    Cybranbase1:StartNonZeroBase({{11, 14, 17}, {7, 10, 12}})
    
    
    P2CB1landattacks()
    P2CB1NavalAttacks()
    P2CB1Airattacks()
    P2CB1EXPattacks() 
end

function P2CB1landattacks()
    
    local quantity = {}

    quantity = {4, 6, 9}
    local Temp = {
        'P2CB1landAttackTemp0',
        'NoPlan',
        { 'url0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
        BuilderName = 'P2CB1landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2CB1Landattack1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
   
    quantity = {4, 5, 6}
    Temp = {
        'P2CB1landAttackTemp1',
        'NoPlan',
        { 'url0304', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'Url0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2CB1landAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2CB1Landattack1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    Temp = {
        'P2CB1landAttackTemp2',
        'NoPlan',
        { 'url0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'xrl0305', 1, 2, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2CB1landAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P2CB1Landattack2'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    Temp = {
        'P2CB1landAttackTemp3',
        'NoPlan',
        { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },
        { 'url0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'url0111', 1, 2, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2CB1landAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2CB1Landattack1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P2CB1NavalAttacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local  Temp = {
        'P2CB1NavalAttackTemp0',
        'NoPlan',   
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2CB1NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2Navalattack1', 'P2UB2Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P2CB1NavalAttackTemp1',
        'NoPlan',
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2CB1NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE * categories.ANTINAVY}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2Navalattack1', 'P2UB2Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P2CB1NavalAttackTemp2',
        'NoPlan',  
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2CB1NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2Navalattack1', 'P2UB2Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder ) 
end

function P2CB1Airattacks()
    
    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P2CB1AirAttackTemp0',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P2CB1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB1Airattacks1', 'P2CB1Airattacks2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    Temp = {
        'P2CB1AirAttackTemp1',
        'NoPlan',
        { 'ura0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2CB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB1Airattacks1', 'P2CB1Airattacks2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    Temp = {
        'P2CB1AirAttackTemp2',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2CB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2CB1Airdefense1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    opai = Cybranbase1:AddOpAI('AirAttacks', 'M2_Cybran_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {6, 8, 12}
    opai = Cybranbase1:AddOpAI('AirAttacks', 'M2_Cybran_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.NAVAL },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.NAVAL, '>='})
end

function P2CB1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {1, 2, 3}
    trigger = {40, 35, 30}
    opai = Cybranbase1:AddOpAI('M3_Cybran_Spider_2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'P2CB1Landattack1',
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

function Cybranbase2AI()

    Cybranbase2:InitializeDifficultyTables(ArmyBrains[Cybran], 'Cybranbase2', 'P2CB2MK', 60, {P2CBase2 = 300})
    Cybranbase2:StartEmptyBase({{5, 7, 8}, {3, 5, 6}})
    
    Cybranbase1:AddExpansionBase('Cybranbase2', 3)
    
    P2CB2Airattacks()
end

function P2CB2Airattacks()
    
    local quantity = {}

    quantity = {5, 7, 9}
    local Temp = {
        'P2CB2AirAttackTemp0',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2CB2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB2Airattacks1', 'P2CB2Airattacks2', 'P2CB2Airattacks3', 'P2CB2Airattacks4'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 9}
    Temp = {
        'P2CB2AirAttackTemp1',
        'NoPlan',
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2CB2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB2Airattacks1', 'P2CB2Airattacks2', 'P2CB2Airattacks3', 'P2CB2Airattacks4'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )  
end
