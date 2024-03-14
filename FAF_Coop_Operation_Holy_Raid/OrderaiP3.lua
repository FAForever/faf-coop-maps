local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Holy_Raid/FAF_Coop_Operation_Holy_Raid_CustomFunctions.lua'

local Player1 = 1
local Order1 = 2
local Order2 = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local Order1base1P3 = BaseManager.CreateBaseManager()
local Order1base2P3 = BaseManager.CreateBaseManager()
local Order1base3P3 = BaseManager.CreateBaseManager()
local Order1base4P3 = BaseManager.CreateBaseManager()
local Order2base1P3 = BaseManager.CreateBaseManager()

function Order1base1P3AI()

    Order1base1P3:InitializeDifficultyTables(ArmyBrains[Order1], 'P3Order1base1', 'Order1base1MK2', 90, {P2A1base1 = 100})
    Order1base1P3:StartNonZeroBase({{14, 19, 24}, {10, 15, 20}})
    Order1base1P3:SetActive('AirScouting', true)

    Order1base1P3:AddExpansionBase('P3Order1base2', 2)
    Order1base1P3:AddExpansionBase('P3Order1base3', 2)
    Order1base1P3:AddExpansionBase('P3Order1base4', 2)

    O1P3B1AirDefense()
    O1P3B1Airattacks()
    O1P3B1landattacks()
    Exp2O1P3()
end

function O1P3B1AirDefense()

    local quantity = {}

    quantity = {3, 4, 5}
    local Temp = {
       'O1P3B1lAirDefenseTemp1',
       'NoPlan',
       { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
       { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       }
    local Builder = {
        BuilderName = 'O1P3B1AirDefenseBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'O1P3B1AirDefence1'
       },
   }
   ArmyBrains[Order1]:PBMAddPlatoon( Builder )
end

function O1P3B1Airattacks()

    local quantity = {}

    quantity = {10, 12, 15}
    local Temp = {
        'O1P3B1lAirAttackTemp1',
        'NoPlan', 
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    local Builder = {
        BuilderName = 'O1P3B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P3B1Airattack1','O1P3B1Airattack2','O1P3B1Airattack3'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
        'O1P3B1lAirAttackTemp2',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O1P3B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P3B1Airattack1','O1P3B1Airattack2','O1P3B1Airattack3'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
   
    quantity = {5, 8, 10}
    Temp = {
        'O1P3B1lAirAttackTemp3',
        'NoPlan',
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O1P3B1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Air',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        RequiresConstruction = true,
        LocationType = 'P3Order1base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P3B1Airattack1','O1P3B1Airattack2','O1P3B1Airattack3'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
end

function O1P3B1landattacks()

    local quantity = {}

    quantity = {3, 4, 5}
    local Temp = {
        'O1P3B1landAttackTemp1',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, -- Siege Bots
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- Heavy Tanks
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, -- Mobile Shields
        }
    local Builder = {
        BuilderName = 'O1P3B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order1base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'O1P3B1Landattack1','O1P3B1Landattack2','O1P3B1Landattack3','O1P3B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 5}
    Temp = {
        'O1P3B1LandAttackTemp2',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
        { 'dalk003', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
        }
    Builder = {
        BuilderName = 'O1P3B1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, (categories.AIR * categories.MOBILE) * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'}, 
        PlatoonData = {
           MoveChains = {'O1P3B1Landattack1','O1P3B1Landattack2','O1P3B1Landattack3','O1P3B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
   
   quantity = {5, 7, 10}
   Temp = {
        'O1P3B1AttackTemp3',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },          
        }
     Builder = {
        BuilderName = 'O1P3B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},  
        PlatoonData = {
           MoveChains = {'O1P3B1Landattack1','O1P3B1Landattack2','O1P3B1Landattack3','O1P3B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
   Temp = {
        'O1P3B1AttackTemp4',
        'NoPlan',
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },          
        }
     Builder = {
        BuilderName = 'O1P3B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 106,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order1base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.DEFENSE * categories.STRUCTURE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P3B1Landattack1','O1P3B1Landattack2','O1P3B1Landattack3','O1P3B1Landattack4'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
end

function Exp2O1P3()

    local opai = nil
    local quantity = {}
    quantity = {2, 3, 4}
    opai = Order1base1P3:AddOpAI({'O1Gbot2','O1Abot1'},
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'O1P3B1Landattack1','O1P3B1Landattack2','O1P3B1Landattack3','O1P3B1Landattack4'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function Order1base2P3AI()

    Order1base2P3:InitializeDifficultyTables(ArmyBrains[Order1], 'P3Order1base2', 'Order1base2MK2', 50, {P2A1base2 = 100})
    Order1base2P3:StartNonZeroBase({{6, 7, 8}, {2, 3, 4}})
 
   
   O1P3B2Airattacks()
   Exp1O1P3() 
end

function Exp1O1P3()

    local opai = nil
    local quantity = {}
    quantity = {2, 3, 4}
    opai = Order1base2P3:AddOpAI('O1Gbot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},     
            PlatoonData = {
                MoveChain = 'O1P3B3Landattack1'
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function O1P3B2Airattacks()
    local quantity = {}
    local opai = nil
    
    quantity = {2, 3, 4}
    local Temp = {
        'O1P3B2AirAttackTemp1',
        'NoPlan',
        { 'uaa0203', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    local Builder = {
        BuilderName = 'O1P3B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Order1base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'O1P3B2Airattack1'
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    -- Hunter group for Air EXPs
    quantity = {6, 8, 10}
    opai = Order1base2P3:AddOpAI('AirAttacks', 'M3_Order1B2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE},
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
    opai = Order1base2P3:AddOpAI('AirAttacks', 'M3_Order1B2_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.STRUCTURE},
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
    opai = Order1base2P3:AddOpAI('AirAttacks', 'M3_Order1B2_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function Order1base3P3AI()

    Order1base3P3:InitializeDifficultyTables(ArmyBrains[Order1], 'P3Order1base3', 'Order1base3MK2', 50, {P2A1base3 = 100})
    Order1base3P3:StartNonZeroBase({{3, 5, 7}, {2, 4, 6}})
    Order1base3P3:AddExpansionBase('Order1base2', 2)
   
   O1P3B3landattacks()
end

function O1P3B3landattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'O1P3B3landAttackTemp1',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
        }
    local Builder = {
        BuilderName = 'O1P3B3AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order1base3',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},
        PlatoonData = {
           MoveChain = 'O1P3B3Landattack1'
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'O1P3B3landAttackTemp2',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'dalk003', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        }
    Builder = {
        BuilderName = 'O1P3B3AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order1base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},
        PlatoonData = {
           MoveChain = 'O1P3B3Landattack1'
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'O1P3B3landAttackTemp3',
        'NoPlan',  
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        }
    Builder = {
        BuilderName = 'O1P3B3AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order1base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
           PatrolChain = 'O1P3B3Landattack1'
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
        'O1P3B3landAttackTemp4',
        'NoPlan',
        { 'xal0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
        }
    Builder = {
        BuilderName = 'O1P3B3AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 106,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order1base3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
           PatrolChain = 'O1P3B3Landattack1'
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
end

function Order1base4P3AI()

    Order1base4P3:InitializeDifficultyTables(ArmyBrains[Order1], 'P3Order1base4', 'Order1base4MK2', 50, {P2NukeBase = 100})
    Order1base4P3:StartNonZeroBase({{3, 5, 7}, {2, 4, 6}})
   
    O1P3B4Airattacks() 
end

function O1P3B4Airattacks()
     
    local quantity = {}
    local opai = nil
    
    quantity = {2, 3, 4}
    local Temp = {
        'O1P3B4lAirAttackTemp1',
        'NoPlan',
        { 'uaa0203', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        }
    local Builder = {
        BuilderName = 'O1P3B4AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Order1base4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O1P3B4Airattack1', 'O1P3B4Airattack2', 'O1P3B4Airattack3'}
        },
    }
    ArmyBrains[Order1]:PBMAddPlatoon( Builder )
    
    -- Hunter group for Air EXPs
    quantity = {6, 9, 12}
    opai = Order1base4P3:AddOpAI('AirAttacks', 'M3_Order1_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE, '>='})

    -- Hunter group for Structure EXPs        
    quantity = {5, 7, 9}
    opai = Order1base4P3:AddOpAI('AirAttacks', 'M3_Order1_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND, '>='})

    -- Hunter group for land EXPs
    quantity = {4, 6, 8}
    opai = Order1base4P3:AddOpAI('AirAttacks', 'M3_Order1_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.STRUCTURE },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.STRUCTURE, '>='})  
end

function Order2base1P3AI()

    Order2base1P3:Initialize(ArmyBrains[Order2], 'P3Order2base1', 'Order2base1MK2', 70, {P2A2base1 = 100})
    Order2base1P3:StartNonZeroBase({{8, 12, 14}, {6, 10, 12}})
   
    Order2base1P3:AddExpansionBase('Order2base1', 2)

    O2P3B1landattacks()
    O2P3B1Airattacks()
    Exp1O2P3B1() 
end

function O2P3B1landattacks()

    local quantity = {}

    quantity = {4, 6, 8}
    local Temp = {
        'O2P3B1landAttackTemp1',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },   
        }
    local Builder = {
        BuilderName = 'O2P3B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order2base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},
        PlatoonData = {
           MoveChains = {'O2P3B1Landattack1', 'O2P3B1Landattack2'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 9}
    Temp = {
        'O2P3B1landAttackTemp2',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
    Builder = {
        BuilderName = 'O2P3B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},  
        PlatoonData = {
           PatrolChains = {'O2P3B1Landattack1', 'O2P3B1Landattack2'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    Temp = {
        'O2P3B1landAttackTemp3',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'dalk003', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        }
     Builder = {
        BuilderName = 'O2P3B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 104,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Order2base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'}, 
        PlatoonData = {
           MoveChains = {'O2P3B1Landattack1', 'O2P3B1Landattack2'}
        },
   }
   ArmyBrains[Order2]:PBMAddPlatoon( Builder )    
end

function O2P3B1Airattacks()

    local quantity = {}

    quantity = {6, 9, 12}
    local Temp = {
        'O2P3B1AirAttackTemp1',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
        }
    local Builder = {
        BuilderName = 'O2P3B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Order2base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P3B1Airattack1', 'O2P3B1Airattack2', 'O2P3B1Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )
    
    quantity = {3, 6, 9}
    Temp = {
        'O2P3B1AirAttackTemp2',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
        }
    Builder = {
        BuilderName = 'O2P3B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Order2base1',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 9, categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'O2P3B1Airattack1', 'O2P3B1Airattack2', 'O2P3B1Airattack3'}
        },
    }
    ArmyBrains[Order2]:PBMAddPlatoon( Builder )

    -- Mercy Snipe on Land EXPs
    quantity = {5, 7, 9}
    opai = Order2base1P3:AddOpAI('AirAttacks', 'M3_Order2_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('GuidedMissiles', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND, '>='})

    -- Mercy Snipe on ACUs
    quantity = {4, 5, 6}
    opai = Order2base1P3:AddOpAI('AirAttacks', 'M3_Order2_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.COMMAND},
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('GuidedMissiles', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})  
end

function Exp1O2P3B1()

    local opai = nil
    local quantity = {}
    quantity = {2, 3, 4}
    opai = Order2base1P3:AddOpAI('P3A2Bot1',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M3_GB_Platoon1',
                NumRequired = 2,
                PatrolChain = 'O2P3B1Landattack' .. Random(1, 2),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end


