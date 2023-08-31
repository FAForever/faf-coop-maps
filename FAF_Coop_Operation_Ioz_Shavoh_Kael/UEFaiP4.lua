local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'

local Player1 = 1
local UEF = 5

local P4UBase1 = BaseManager.CreateBaseManager()
local P4UBase2 = BaseManager.CreateBaseManager()
local P4UBaseS = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P4UEFbase1AI()
    P4UBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFBase1', 'P4UB1MK', 70, {P4UBase1 = 100})
    P4UBase1:StartNonZeroBase({{10, 15, 20}, {8, 12, 16}})

    P4UB1Airattacks()
    P4UB1Landattacks()
    P4UB1EXPattacks()   
end

function P4UB1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P4U1B1AttackTemp0',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P4U1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Airattack1','P4UB1Airattack2', 'P4UB1Airattack3', 'P4UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 8, 12}
    trigger = {25, 20, 15}
    Temp = {
        'P4U1B1AttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4U1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Airattack1','P4UB1Airattack2', 'P4UB1Airattack3', 'P4UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {25, 20, 15}
    Temp = {
        'P4U1B1AttackTemp2',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4U1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Airattack1','P4UB1Airattack2', 'P4UB1Airattack3', 'P4UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {8, 10, 12}
    opai = P4UBase1:AddOpAI('AirAttacks', 'M4_UEF_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2,  categories.EXPERIMENTAL * categories.LAND * categories.MOBILE, '>='})
end

function P4UB1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {5, 7, 8}
    local Temp = {
        'P4U1B1LandAttackTemp0',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P4U1B1LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Landattack1','P4UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {25, 20, 15}
    Temp = {
        'P4U1B1LandAttackTemp1',
        'NoPlan',
        { 'uel0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4U1B1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Landattack1','P4UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {4, 3, 2}
    Temp = {
        'P4U1B1LandAttackTemp2',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4U1B1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Landattack1','P4UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    local opai = nil
    local trigger = {}
    local poolName = 'P4UEFBase1_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M4_UEF_Northern_Transport_Platoon',
        'NoPlan',
        { 'xea0306', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M4_UEF_Northern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P4UEFBase1',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 2, 3}
    local Quantity2 = {3, 4, 6}
    Builder = {
        BuilderName = 'M4_UEF_Land_Assault',
        PlatoonTemplate = {
            'M4_UEF_Land_Assault_Template',
            'NoPlan',
            {'uel0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'uel0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 Arty
            {'delk002', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 AA
        },
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P4KDropAChain'.. Random(1, 3),
            LandingChain = 'P4KDropChain'.. Random(1, 3),
            TransportReturn = 'P4UB1MK',
            BaseName = 'P4UEFBase1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P4UEFbase2AI()
    P4UBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFBase2', 'P4UB2MK', 90, {P4UBase2 = 100})
    P4UBase2:StartNonZeroBase({{6, 9, 13}, {5, 7, 10}})

    P4UB2Navalattacks()
    P4UB2Airattacks()
    P4UB2EXPattacks()
end

function P4UB2Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    quantity2 = {1, 2, 3}
    local Temp = {
        'P3UB2NavalAttackTemp0',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0205', 1, 1, 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3UB2NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB2Navalattack1','P4UB2Navalattack2', 'P4UB2Navalattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {35, 25, 20}
    Temp = {
        'P3UB2NavalAttackTemp1',
        'NoPlan',
        { 'xes0307', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0205', 1, 1, 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3UB2NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB2Navalattack1','P4UB2Navalattack2', 'P4UB2Navalattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {3, 2, 1}
    Temp = {
        'P3UB2NavalAttackTemp2',
        'NoPlan',
        { 'ues0202', 1, 2, 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3UB2NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase2', 
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB2Navalattack1','P4UB2Navalattack2', 'P4UB2Navalattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {4, 3, 2}
    Temp = {
        'P3UB2NavalAttackTemp3',
        'NoPlan',
        { 'ues0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3UB2NavalAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase2', 
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB2Navalattack1','P4UB2Navalattack2', 'P4UB2Navalattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P4UB2Airattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P4U1B2AirAttackTemp0',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P4U1B2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB2Navalattack1','P4UB2Navalattack2', 'P4UB2Navalattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 10}
    opai = P4UBase2:AddOpAI('AirAttacks', 'M4_UEF_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'HeavyGunships', 'TorpedoBombers'}, quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE, '>='})
end

function P4UB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 5}
    opai = P4UBase1:AddOpAI('P4UBot',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
                PatrolChains = {'P4UB1Landattack1','P4UB1Landattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P4UB2EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {1, 2, 3}

    opai = P4UBase2:AddOpAI('P4USub',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P4UB2Navalattack1','P4UB2Navalattack2', 'P4UB2Navalattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function M4UEFSBase1AI()
    P4UBaseS:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFSBase', 'P4UBSMK', 50, {P4USpecial1 = 100})
    P4UBaseS:StartNonZeroBase({2, 4, 6})
    P4UBaseS:AddBuildGroup('P4USpecial1EXD', 90)
end

function M4UEFSBase2AI()
    P4UBaseS:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFSBase', 'P4UBSMK', 60, {P4USpecial2 = 100})
    P4UBaseS:StartNonZeroBase({{6, 8, 10}, {4, 6, 8}})

    P4UBSAirattacks()
end

function P4UBSAirattacks()

    local quantity = {}

    local opai = nil

    quantity = {12, 18, 24}
    opai = P4UBaseS:AddOpAI('AirAttacks', 'M4BS_UEF_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.NAVAL},
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.NAVAL, '>='})

    quantity = {8, 12, 16}
    opai = P4UBaseS:AddOpAI('AirAttacks', 'M4BS_UEF_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND * categories.MOBILE, '>='})


    quantity = {8, 12, 16}
    opai = P4UBaseS:AddOpAI('AirAttacks', 'M4BS_UEF_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR * categories.MOBILE},
            },
            Priority = 175,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.AIR * categories.MOBILE, '>='})


    quantity = {8, 12, 16}
    opai = P4UBaseS:AddOpAI('AirAttacks', 'M4BS_UEF_Air_Attack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.COMMAND + categories.SUBCOMMANDER},
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end
