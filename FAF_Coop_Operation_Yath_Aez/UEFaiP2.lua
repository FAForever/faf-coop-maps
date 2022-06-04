local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local UEF = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local P2UEFBase1 = BaseManager.CreateBaseManager()
local P2UEFBase2 = BaseManager.CreateBaseManager()

function UEFnavalbaseAI()

    P2UEFBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P2UEFBase2', 'Mainnaval', 80, {P2UBase2 = 100})
    P2UEFBase1:StartNonZeroBase({{7, 9, 11}, {4, 6, 8}})

    P2UB2Navalattacks()
    P2UB2landattacks()
    P2UEXPattacks()
end

function UEFmainbaseAI()

    P2UEFBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P2UEFBase1', 'UEF', 80, {P2UBase1 = 100})
    P2UEFBase2:StartNonZeroBase({{8, 11, 14}, {6, 9, 12}})
    P2UEFBase2:SetActive('AirScouting', true)

    P2UB1Airattacks()
    P2UB1landattacks()
    P2UB1EXPattacks()
end

function P2UB2Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
        'P1UB2NavalattackTemp0',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0103', 1, 3, 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
        BuilderName = 'P1UB2NavalattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2Navalattack1', 'P2UB2Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
    quantity = {2, 3, 4}
    trigger = {16, 14, 12}
    Temp = {
        'P1UB2NavalattackTemp1',
        'NoPlan',
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1UB2NavalattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.ANTINAVY}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2Navalattack1', 'P2UB2Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {8, 6, 3}
    Temp = {
        'P1UB2NavalattackTemp2',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0302', 1, 1, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1UB2NavalattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2Navalattack1', 'P2UB2Navalattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )  
end
 
function P2UB2landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6}
    local Temp = {
        'P2UB2LandattackTemp0',
        'NoPlan',     
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P2UB2LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase2',       
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 4}
    trigger = {18, 16, 14}
    Temp = {
        'P2UB2LandattackTemp1',
        'NoPlan',     
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2UB2LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },       
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P2UB2landattack1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 4}
    trigger = {18, 16, 14}
    Temp = {
        'P2UB2LandattackTemp2',
        'NoPlan',     
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2UB2LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },       
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
            MoveChain = 'P2UB2landattack2'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
 
function P2UEXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {1, 2, 3}
    trigger = {6, 5, 4}
    opai = P2UEFBase1:AddOpAI('P2Uexp1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'P2UB2Navalattack1', 'P2UB2Navalattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.NAVAL, '>='},
                },
            }
        }
    ) 
end
 
function P2UB1Airattacks()
    
    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P2UB1AirattackTemp0',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P2UB1AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2UB1Airdefense'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2UB1AirattackTemp1',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB1AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase1',       
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB1Airattack1', 'P2UB1Airattack2', 'P2UB1Airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    Temp = {
        'P2UB1AirattackTemp2',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2UB1AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB1Airattack1', 'P2UB1Airattack2', 'P2UB1Airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 6}
    Temp = {
        'P2UB1AirattackTemp3',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2UB1AirattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB1Airattack1', 'P2UB1Airattack2', 'P2UB1Airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
   
function P2UB1landattacks()
    
    local quantity = {}

    quantity = {4, 6, 9}
    local Temp = {
        'P2UB1LandattackTemp0',
        'NoPlan',     
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    local Builder = {
        BuilderName = 'P2UB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase1',       
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2UB1LandattackTemp1',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB1LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 35, categories.ALLUNITS * categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
        },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder ) 

   quantity = {4, 6, 9}
    Temp = {
        'P2UB1LandattackTemp2',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2UB1LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
        },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder ) 
end
  
function P2UB1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {1, 2, 3}
    trigger = {40, 35, 30}
    opai = P2UEFBase2:AddOpAI('P2Uexp2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.ALLUNITS, '>='},
                },
            }
        }
    ) 
end
 