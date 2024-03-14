local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_CustomFunctions.lua'

local Player1 = 1
local Seraphim = 2

local P2SBase1 = BaseManager.CreateBaseManager()
local P2SBase2 = BaseManager.CreateBaseManager()
local P2SBase3 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P2S1Base1AI()

    P2SBase1:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P2SeraphimBase1', 'P2SB1MK', 90, {P2SBase1 = 100})
    P2SBase1:StartNonZeroBase({{8, 12, 16}, {6, 9, 12}})
    P2SBase1:SetActive('AirScouting', true)
    P2SBase1:AddBuildGroupDifficulty('P2SBase1EXD', 90)

	P2S1B1Airattacks()
	P2S1B1Landattacks()
    P2S1B1EXPattacks()	
end

function P2S1B1Airattacks()
	
    local quantity = {}
    local trigger = {}

    quantity = {5, 7, 9}
	local Temp = {
       'P2SB1AttackTemp0',
       'NoPlan',
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
       BuilderName = 'P2SB1AttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2SeraphimBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2', 'P2SB1Airattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {4, 5, 6}
    trigger = {12, 10, 5}
	Temp = {
        'P2SB1AttackTemp1',
        'NoPlan',
        { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2SB1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2', 'P2SB1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    trigger = {20, 15, 10}
    Temp = {
        'P2SB1AttackTemp2',
        'NoPlan',
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2SB1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 125,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2', 'P2SB1Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {3, 4, 6}
    trigger = {35, 30, 25}
	Temp = {
       'P2SB1AttackTemp3',
       'NoPlan',
       { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P2SB1AttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 115,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        }, 
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2', 'P2SB1Airattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    opai = P2SBase1:AddOpAI('AirAttacks', 'M2B1_Sera_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR},
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.AIR, '>='})

    quantity = {6, 7, 9}
    opai = P2SBase1:AddOpAI('AirAttacks', 'M2B1_Sera_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P2S1B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 9}
    local Temp = {
        'P2SB1LAttackTemp0',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 	   
    }
    local Builder = {
        BuilderName = 'P2SB1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB1Landattack1', 'P2SB1Landattack2', 'P2SB1Landattack3', 'P2SB1Landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {3, 5, 6}
    trigger = {14, 12, 10}
	Temp = {
        'P2SB1LAttackTemp1',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
        BuilderName = 'P2SB1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB1Landattack1', 'P2SB1Landattack2', 'P2SB1Landattack3', 'P2SB1Landattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {2, 3, 4}
    trigger = {22, 20, 15}
	Temp = {
       'P2SB1LAttackTemp2',
       'NoPlan',
       { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
       { 'xsl0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P2SB1LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 110,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        }, 
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2SB1Landattack1', 'P2SB1Landattack2', 'P2SB1Landattack3', 'P2SB1Landattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {4, 6, 9}
    trigger = {35, 30, 25}
	Temp = {
       'P2SB1LAttackTemp3',
       'NoPlan',
       { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
       { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P2SB1LAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 115,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2SeraphimBase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        }, 
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2SB1Landattack1', 'P2SB1Landattack2', 'P2SB1Landattack3', 'P2SB1Landattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )	
end

function P2S1B1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    trigger = {3, 2, 1}
    opai = P2SBase1:AddOpAI('P2SBot',
        {
                Amount = 4,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M2Bots',
                    NumRequired = 2,
                    PatrolChain = 'P2SB1Landattack' .. Random(1, 4),
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

function P2S1Base2AI()

    P2SBase2:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P2SeraphimBase2', 'P2SB2MK', 90, {P2SBase2 = 100})
    P2SBase2:StartNonZeroBase({{5, 7, 9}, {4, 6, 8}})
    P2SBase2:SetActive('AirScouting', true)
    
	P2S1B2Airattacks()
	P2S1B2Landattacks()
end

function P2S1B2Airattacks()
	
    local quantity = {}

    quantity = {4, 5, 6}
	local Temp = {
        'P2SB2AttackTemp0',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2SB2AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Airattack1','P2SB2Airattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {4, 5, 6}
	Temp = {
        'P2SB2AttackTemp1',
        'NoPlan',
        { 'xsa0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2SB2AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 6, categories.NAVAL * categories.MOBILE}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Airattack1','P2SB2Airattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P2S1B2Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P2SB2LAttackTemp0',
        'NoPlan',
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P2SB2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Landattack1', 'P2SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {6, 7, 9}
    trigger = {20, 15, 10}
	Temp = {
        'P2SB2LAttackTemp1',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P2SB2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Landattack1', 'P2SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {4, 5, 6}
    trigger = {20, 15, 12}
	Temp = {
        'P2SB2LAttackTemp2',
        'NoPlan',
        { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P2SB2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Landattack1', 'P2SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P2S1Base3AI()

    P2SBase3:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P2SeraphimBase3', 'P2SB3MK', 70, {P2SBase3 = 100})
    P2SBase3:StartNonZeroBase({{6, 9, 12}, {4, 6, 8}})
    P2SBase3:SetActive('AirScouting', true)
    
	P2S1B3Airattacks()
	P2S1B3Landattacks()
    P2S1B3EXPattacks()
end

function P2S1B3Airattacks()
	
    local quantity = {}

    quantity = {4, 5, 6}
	local Temp = {
        'P2SB3AttackTemp0',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P2SB3AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB3Airattack1', 'P2SB3Airattack2', 'P2SB3Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {2, 3, 4}
	Temp = {
        'P2SB3AttackTemp1',
        'NoPlan',
        { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2SB3AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB3Airattack1', 'P2SB3Airattack2', 'P2SB3Airattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {6, 8, 10}
    opai = P2SBase3:AddOpAI('AirAttacks', 'M2B3_Sera_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR},
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.AIR, '>='})

    quantity = {7, 9, 12}
    opai = P2SBase3:AddOpAI('AirAttacks', 'M2B3_Sera_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P2S1B3Landattacks()

    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    local Temp = {
       'P2SB3LAttackTemp0',
       'NoPlan',
	   { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2SB3LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2SeraphimBase3',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2SB3Landattack1', 'P2SB3Landattack2', 'P2SB3Landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {35, 30, 25}
    Temp = {
       'P2SB3LAttackTemp1',
       'NoPlan',
       { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P2SB3LAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 115,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2SeraphimBase3',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
      PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P2SB3Landattack1', 'P2SB3Landattack2', 'P2SB3Landattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {4, 6, 8}
    trigger = {15, 10, 8}
	Temp = {
       'P2SB3LAttackTemp2',
       'NoPlan',
	   { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
	   { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P2SB3LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 105,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2SeraphimBase3',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
      PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P2SB3Landattack1', 'P2SB3Landattack2', 'P2SB3Landattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P2S1B3EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    trigger = {45, 40, 35}
    opai = P2SBase3:AddOpAI('P2SBot2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P2SB3Landattack1', 'P2SB3Landattack2', 'P2SB3Landattack3'}
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