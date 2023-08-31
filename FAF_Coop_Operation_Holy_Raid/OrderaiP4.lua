local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Holy_Raid/FAF_Coop_Operation_Holy_Raid_CustomFunctions.lua'

local Player1 = 1
local Order2 = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local Order1base1P4 = BaseManager.CreateBaseManager()
local Order1base2P4 = BaseManager.CreateBaseManager()
local Order1base3P4 = BaseManager.CreateBaseManager()
local Order1base4P4 = BaseManager.CreateBaseManager()

local Order1EXP1P4 = BaseManager.CreateBaseManager()
local Order1EXP2P4 = BaseManager.CreateBaseManager()


function Order2base1P4AI()

    Order1base1P4:InitializeDifficultyTables(ArmyBrains[Order2], 'P4Order1base1', 'P4A2B1MK', 70, {P4A2Base1 = 500})
    Order1base1P4:StartNonZeroBase({{11, 14, 18}, {7, 10, 14}})
    Order1base1P4:SetActive('AirScouting', true)

    O2P4B1Airattacks()
    O2P4B1landattacks()
    Exp1O2P4B1()
end

function O2P4B1Airattacks()

    local quantity = {}
    quantity = {4, 5, 6}
    local Temp = {
        'O2P4B1AirDefenceTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'O2P4B1AirDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'O2P4B1AirDefence1'
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {6, 9, 12}
    Temp = {
        'O2P4B1AirAttackTemp1',
        'NoPlan',  
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B1Airattack1','O2P4B1Airattack2','O2P4B1Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
    
    quantity = {5, 6, 9}
    Temp = {
        'O2P4B1AirAttackTemp2',
        'NoPlan',   
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 106,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B1Airattack1','O2P4B1Airattack2','O2P4B1Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 9}
    Temp = {
        'O2P4B1AirAttackTemp3',
        'NoPlan',   
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B1Airattack1','O2P4B1Airattack2','O2P4B1Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )  
end

function O2P4B1landattacks()

    local quantity = {}

    quantity = {6, 8, 12}
    local Temp = {
        'O2P4B1landAttackTemp1',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
        }
    local Builder = {
        BuilderName = 'O2P4B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'}, 
        PlatoonData = {
           MoveChains = {'O2P4B1Landattack1','O2P4B1Landattack2'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    Temp = {
        'O2P4B1landAttackTemp2',
        'NoPlan',  
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },  
        { 'dalk003', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'O2P4B1Landattack1','O2P4B1Landattack2'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'O2P4B1landAttackTemp3',
        'NoPlan',
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'O2P4B1Landattack1','O2P4B1Landattack2'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
        'O2P4B1landAttackTemp4',
        'NoPlan',
        { 'xal0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dal0310', 1, 4, 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B1Landattack1','O2P4B1Landattack2'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )    

    quantity = {1, 2, 3}
    Temp = {
        'O2P4B1landAttackTemp5',
        'NoPlan',
        { 'ual0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'O2P4B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P4Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B1Landattack1','O2P4B1Landattack2'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
end

function Exp1O2P4B1()

    local opai = nil
    local quantity = {}
    quantity = {2, 4, 6}
    opai = Order1base1P4:AddOpAI('Gbot4',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_GB_Platoon1',
                NumRequired = 2,
                PatrolChain = 'O2P4B1Landattack' .. Random(1, 2),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function Order2base2P4AI()

    Order1base2P4:InitializeDifficultyTables(ArmyBrains[Order2], 'P4Order1base2', 'P4A2B2MK', 70, {P4A2Base2 = 500})
    Order1base2P4:StartNonZeroBase({{14, 18, 24}, {9, 14, 18}})
    Order1base2P4:SetActive('AirScouting', true)

    O2P4B2Airattacks()
    O2P4B2landattacks()
    Exp1O2P4B2()
end

function O2P4B2landattacks()

    local quantity = {}

    quantity = {10, 12, 15}
    local Temp = {
        'O2P4B2landAttackTemp1',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },    
        }
    local Builder = {
        BuilderName = 'O2P4B2AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'}, 
        PlatoonData = {
           MoveChains = {'O2P4B2Landattack1', 'O2P4B2Landattack2', 'O2P4B2Landattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
    
    quantity = {5, 8, 10}
    Temp = {
        'O2P4B2landAttackTemp2',
        'NoPlan',
        { 'xal0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P4B2AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B2Landattack1','O2P4B2Landattack2', 'O2P4B2Landattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    Temp = {
        'O2P4B2landAttackTemp3',
        'NoPlan',
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
        }
    Builder = {
        BuilderName = 'O2P4B2AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 140,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B2Landattack1','O2P4B2Landattack2', 'O2P4B2Landattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    Temp = {
        'O2P4B2landAttackTemp4',
        'NoPlan',
        { 'dalk003', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
        }
    Builder = {
        BuilderName = 'O2P4B2AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 130,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B2Landattack1','O2P4B2Landattack2', 'O2P4B2Landattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )  

    quantity = {1, 2, 3}
    Temp = {
        'O2P4B2landAttackTemp5',
        'NoPlan',
        { 'ual0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'O2P4B2AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P4Order1base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B2Landattack1','O2P4B2Landattack2', 'O2P4B2Landattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )  
end

function O2P4B2Airattacks()

    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'O2P4B2AirDefenceTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'O2P4B2AirDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'O2P4B2AirDefence1'
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
        'O2P4B2AirAttackTemp1',
        'NoPlan',  
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B2Airattack1','O2P4B2Airattack2','O2P4B2Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 8, 12}
    Temp = {
        'O2P4B2AirAttackTemp2',
        'NoPlan',  
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B2Airattack1','O2P4B2Airattack2','O2P4B2Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    -- Hunter group for Air EXPs
    quantity = {6, 8, 12}
    opai = Order1base2P4:AddOpAI('AirAttacks', 'M4_Order2B2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE, '>='})
    
    -- Hunter group for Structure EXPs
    quantity = {4, 6, 8}
    opai = Order1base2P4:AddOpAI('AirAttacks', 'M4_Order2B2_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.STRUCTURE },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.STRUCTURE, '>='})

    -- Hunter group for Land EXPs
    quantity = {4, 6, 8}
    opai = Order1base2P4:AddOpAI('AirAttacks', 'M4_Order2B2_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND, '>='}) 
end

function Exp1O2P4B2()

    local opai = nil
    local quantity = {}
    quantity = {3, 4, 5}
    opai = Order1base2P4:AddOpAI({'Gbot5','Saucer1'},
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O2P4B2Landattack1','O2P4B2Landattack2', 'O2P4B2Landattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function Order2base3P4AI()

    Order1base3P4:InitializeDifficultyTables(ArmyBrains[Order2], 'P4Order1base3', 'P4A2B3MK', 70, {P4A2Base3 = 100})
    Order1base3P4:StartNonZeroBase({{6, 9, 12}, {4, 6, 8}})
    Order1base3P4:SetActive('AirScouting', true)   

    O2P4B3Airattacks()
    O2P4B3landattacks()

    Order1base3P4:AddBuildGroupDifficulty('P4Arty', 90)    
end

function O2P4B3landattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
       'O2P4B3landAttackTemp1',
       'NoPlan',
       { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
       }
    local Builder = {
        BuilderName = 'O2P4B3AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base3',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'}, 
        PlatoonData = {
           MoveChains = {'O2P4B3Landattack1','O2P4B3Landattack2', 'O2P4B3Landattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
       'O2P4B3landAttackTemp2',
       'NoPlan',  
       { 'dalk003', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },  
       }
    Builder = {
        BuilderName = 'O2P4B3AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'O2P4B3Landattack1','O2P4B3Landattack2', 'O2P4B3Landattack3'}
       },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
       'O2P4B3landAttackTemp3',
       'NoPlan',
       { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
       }
    Builder = {
        BuilderName = 'O2P4B3AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O2P4B3Landattack1','O2P4B3Landattack2', 'O2P4B3Landattack3'}
       },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder ) 

    quantity = {2, 3, 4}
    Temp = {
       'O2P4B3landAttackTemp4',
       'NoPlan',
       { 'dal0310', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
       }
    Builder = {
        BuilderName = 'O2P4B3AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O2P4B3Landattack1','O2P4B3Landattack2', 'O2P4B3Landattack3'}
       },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )     
end

function O2P4B3Airattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
       'O2P4B3AirDefenceTemp1',
       'NoPlan',
       { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'O2P4B3AirDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base3',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'O2P4B3AirDefence1'
       },
   }
   ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
       'O2P4B3AirAttackTemp1',
       'NoPlan',  
       { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
       }
    Builder = {
        BuilderName = 'O2P4B3AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O2P4B3Airattack1','O2P4B3Airattack2','O2P4B3Airattack3'}
       },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
       'O2P4B3AirAttackTemp2',
       'NoPlan',  
       { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
       }
    Builder = {
        BuilderName = 'O2P4B3AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 8, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'O2P4B3Airattack1','O2P4B3Airattack2','O2P4B3Airattack3'}
       },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
end

function Order2base4P4AI()

    Order1base4P4:InitializeDifficultyTables(ArmyBrains[Order2], 'P4Order1base4', 'P4A2B4MK', 70, {P4A2Base4 = 500})
    Order1base4P4:StartNonZeroBase({{14, 18, 22}, {12, 16, 20}})
    Order1base4P4:SetActive('AirScouting', true)

    O2P4B4Airattacks()
    O2P4B4landattacks()
    Exp1O2P4B4()
end

function O2P4B4landattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'O2P4B4landAttackTemp1',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },      
        }
    local Builder = {
        BuilderName = 'O2P4B4AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'}, 
        PlatoonData = {
           PatrolChain = 'O2P4B4Landattack1'
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'O2P4B4landAttackTemp2',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xal0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dalk003', 1, 2, 'Attack', 'GrowthFormation' },  
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B4AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Order1base4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.EXPERIMENTAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
        PlatoonData = {
           MoveChain = 'O2P4B4Landattack1'
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    Temp = {
        'O2P4B4landAttackTemp3',
        'NoPlan',
        { 'ual0301_Rambo', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'O2P4B4AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'P4Order1base4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'}, 
        PlatoonData = {
           PatrolChain = 'O2P4B4Landattack1'
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
end

function O2P4B4Airattacks()

    local quantity = {}
    quantity = {5, 8, 10}
    local Temp = {
        'O2P4B4AirDefenceTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    local Builder = {
        BuilderName = 'O2P4B4AirDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base4',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'O2P4B4AirDefence1'
        },
   }
   ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
        'O2P4B4AirAttackTemp1',
        'NoPlan',  
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B4AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B4Airattack1','O2P4B4Airattack2','O2P4B4Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 15}
    Temp = {
        'O2P4B4AirAttackTemp2',
        'NoPlan',  
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    Builder = {
        BuilderName = 'O2P4B4AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Order1base4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 8, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P4B4Airattack1','O2P4B4Airattack2','O2P4B4Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    -- Hunter group for Air EXPs
    quantity = {5, 10, 15}
    opai = Order1base4P4:AddOpAI('AirAttacks', 'M4_Order2B4_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE, '>='})
    
    -- Hunter group for Structure EXPs   
    quantity = {5, 8, 10}
    opai = Order1base4P4:AddOpAI('AirAttacks', 'M4_Order2B4_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.STRUCTURE },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.STRUCTURE, '>='})

    -- Hunter group for land EXPs
    quantity = {5, 8, 10}
    opai = Order1base4P4:AddOpAI('AirAttacks', 'M4_Order2B4_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND, '>='}) 
end

function Exp1O2P4B4()

    local opai = nil
    local quantity = {}
    quantity = {2, 4, 6}
    opai = Order1base4P4:AddOpAI('Gbot7',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_GB_Platoon2',
                NumRequired = 2,
                PatrolChain = 'O2P4B1Landattack' .. Random(1, 2),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function Order2EXP1P4AI()

    Order1EXP1P4:InitializeDifficultyTables(ArmyBrains[Order2], 'P4Order1EXP1', 'P4A2X1MK', 30, {P4A2ExpBase1 = 100})
    Order1EXP1P4:StartNonZeroBase({2, 4, 6})

    Order1base3P4:AddExpansionBase('P4Order1EXP1', 1)
    Exp1O2P4X1()  
end

function Exp1O2P4X1()

    local opai = nil
    local quantity = {}
    quantity = {4, 6, 8}
    opai = Order1EXP1P4:AddOpAI('Gbot6',
        {
            Amount = 6,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_GB_Platoon3',
                NumRequired = 3,
                PatrolChain = 'O2P4B3Landattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function Order2EXP2P4AI()

    Order1EXP2P4:InitializeDifficultyTables(ArmyBrains[Order2], 'P4Order1EXP2', 'P4A2X2MK', 30, {P4A2ExpBase2 = 100})
    Order1EXP2P4:StartNonZeroBase({2, 4, 6})

    Order1base3P4:AddExpansionBase('P4Order1EXP2', 1)
    Exp1O2P4X2() 
end

function Exp1O2P4X2()

    local opai = nil
    local quantity = {}
    quantity = {4, 6, 8}
    opai = Order1EXP2P4:AddOpAI('Saucer2',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M4_CZAR_Platoon1',
                NumRequired = 2,
                PatrolChain = 'O2P4B4Airattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end
