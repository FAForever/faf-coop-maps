local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local KOrder = 4
local Order = 3

local P2KO1base1 = BaseManager.CreateBaseManager()
local P2O1base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P2KO1Base1AI()

    P2KO1base1:InitializeDifficultyTables(ArmyBrains[KOrder], 'P2KOrder1Base1', 'P2KO1base1MK', 140, {P2KO1Base1 = 100})
    P2KO1base1:StartNonZeroBase({{12, 15, 19}, {10, 12, 15}})
    P2KO1base1:SetActive('AirScouting', true)

    P2KO1B1Airattacks()
    P2KO1B1Landattacks()
    P2KO1B1Navalattacks()
    P2KO1B1EXPattacks()
end

function P2KO1B1Airattacks()

    local quantity = {}

    quantity = {6, 7, 9}
    local Temp = {
        'P2KO1B1AttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
        BuilderName = 'P2KO1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Airattack1','P2KOB1Airattack2', 'P2KOB1Airattack3','P2KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2KO1B1AttackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2KO1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Airattack1','P2KOB1Airattack2', 'P2KOB1Airattack3','P2KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2KO1B1AttackTemp2',
        'NoPlan',
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2KO1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Airattack1','P2KOB1Airattack2', 'P2KOB1Airattack3','P2KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P2KO1B1Landattacks()

    local quantity = {}

    quantity = {6, 7, 8}
    local Temp = {
        'P2KO1B1LAttackTemp0',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P2KO1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Landattack1', 'P2KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 8}
    Temp = {
        'P2KO1B1LAttackTemp1',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2KO1B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},
        PlatoonData = {
            MoveChain = 'P2KOB1Landattack1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon(Builder)
    
    quantity = {2, 3, 4}
    Temp = {
        'P2KO1B1LAttackTemp2',
        'NoPlan',
        { 'ual0111', 1, 4, 'Attack', 'GrowthFormation' },
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2KO1B1LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Landattack1', 'P2KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P2KO1B1Navalattacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2KO1B1NAttackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P2KO1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Navalattack1','P2KOB1Navalattack2', 'P2KOB1Navalattack3'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P2KO1B1NAttackTemp1',
        'NoPlan',
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2KO1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Navalattack1','P2KOB1Navalattack2', 'P2KOB1Navalattack3'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 2}
    Temp = {
        'P2KO1B1NAttackTemp2',
        'NoPlan',
        { 'xas0204', 1, 4, 'Attack', 'GrowthFormation' },
        { 'uas0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2KO1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 50, categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Navalattack1','P2KOB1Navalattack2', 'P2KOB1Navalattack3'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P2KO1B1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = P2KO1base1:AddOpAI('KObot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
                PatrolChains = {'P2KOB1Landattack1', 'P2KOB1Landattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 30, categories.TECH3, '>='},
                },
            }
        }
    )
end

function P2O1Base1AI()

    P2O1base1:InitializeDifficultyTables(ArmyBrains[Order], 'P2Order1Base1', 'P2Obase1MK', 140, {P2O1Base1 = 100})
    P2O1base1:StartNonZeroBase({{12, 15, 19}, {10, 12, 15}})
    P2O1base1:SetActive('AirScouting', true)

    P2O1B1Airattacks()
    P2O1B1Navalattacks()
    P2O1B1Landattacks()
    P2OB1EXPattacks()
end

function P2O1B1Airattacks()

    local quantity = {}

    quantity = {6, 9, 12}
    local Temp = {
        'P2O1B1AAttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   
    }
    local Builder = {
        BuilderName = 'P2O1B1AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2', 'P2OB1Airattack3','P2OB1Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {5, 6, 8}
    Temp = {
        'P2O1B1AAttackTemp1',
        'NoPlan',
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   
    }
    Builder = {
        BuilderName = 'P2O1B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2', 'P2OB1Airattack3','P2OB1Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {6, 8, 10}
    Temp = {
        'P2O1B1AAttackTemp2',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   
    }
    Builder = {
        BuilderName = 'P2O1B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2', 'P2OB1Airattack3','P2OB1Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    Temp = {
        'P2O1B1AAttackTemp3',
        'NoPlan',
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   
    }
    Builder = {
        BuilderName = 'P2O1B1AAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 109,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2', 'P2OB1Airattack3','P2OB1Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P2O1B1Landattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P2O1B1LAttackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P2O1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Landattack1','P2OB1Landattack2','P2OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P2O1B1LAttackTemp1',
        'NoPlan',
        { 'dal0310', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2O1B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 5, categories.TECH3 * categories.STRUCTURE * categories.SHIELD}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Landattack1','P2OB1Landattack2','P2OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )   
end

function P2O1B1Navalattacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2O1B1NAttackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0103', 1, 4, 'Attack', 'GrowthFormation' }    
    }
    local Builder = {
        BuilderName = 'P2O1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {2, 2, 3}
    Temp = {
        'P2O1B1NAttackTemp1',
        'NoPlan',
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2O1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P2O1B1NAttackTemp2',
        'NoPlan',
        { 'uas0202', 1, 3, 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2O1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.TECH3 * categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P2OB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = P2O1base1:AddOpAI('P2OSub',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
                PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 10, categories.TECH3 * categories.NAVAL, '>='},
                },
            }
        }
    )
end
