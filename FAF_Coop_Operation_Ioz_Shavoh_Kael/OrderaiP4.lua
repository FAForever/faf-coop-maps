local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'


local Player1 = 1
local Kael = 2

local P4KBase1 = BaseManager.CreateBaseManager()
local P4KBase2 = BaseManager.CreateBaseManager()
local P4KBase3 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P4Kaelbase1AI()
    P4KBase1:InitializeDifficultyTables(ArmyBrains[Kael], 'P4KaelBase1', 'P4KB1MK', 80, {P4KBase1 = 100})
    P4KBase1:StartNonZeroBase({{12, 18, 26}, {10, 14, 18}})

    P4KB1Airattacks()
    P4KB1Landattacks()
    P4KB1EXPattacks()
end

function P4KB1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {10, 13, 15}
    local Temp = {
        'P4KB1AAttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P4K1B1AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB1Airattack1','P4KB1Airattack2', 'P4KB1Airattack3', 'P4KB1Airattack4'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {5, 8, 10}
    trigger = {35, 25, 20}
    Temp = {
        'P4KB1AAttackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4K1B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB1Airattack1','P4KB1Airattack2', 'P4KB1Airattack3', 'P4KB1Airattack4'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {5, 8, 10}
    trigger = {35, 25, 20}
    Temp = {
        'P4KB1AAttackTemp2',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4K1B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB1Airattack1','P4KB1Airattack2', 'P4KB1Airattack3', 'P4KB1Airattack4'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {10, 13, 15}
    opai = P4KBase1:AddOpAI('AirAttacks', 'M4_Kael_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.AIR * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.AIR * categories.MOBILE, '>='})
end

function P4KB1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 8, 10}

    local Temp = {
        'P4KB1LandAttackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P4KB1LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )  

    quantity = {4, 5, 6}
    trigger = {20, 15, 10}
    Temp = {
        'P4KB1LandAttackTemp1',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dal0310', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P4KB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.SHIELD}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )  
end

function P4KB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 4, 8}
    opai = P4KBase1:AddOpAI('P4KBot',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P4Kaelbase2AI()
    P4KBase2:InitializeDifficultyTables(ArmyBrains[Kael], 'P4KaelBase2', 'P4KB2MK', 80, {P4KBase2 = 100})
    P4KBase2:StartNonZeroBase({{10, 17, 22}, {8, 11, 14}})

    P4KB2Navalattacks()
    P4KB2Airattacks()
    P4KB2EXPattacks()
end

function P4KB2Navalattacks()

    local quantity = {}
    local trigger = {}
    local opai = nil

    -- Extra engineers assisting T2 naval factories, all T2 factories has to be built
    -- Count is {X, 0} since the platoon contains shields/stealth as well and we want just the engineers. And too lazy to make a new platoon rn.
    quantity = {{3, 0}, {6, 0}, {9, 0}}
    opai = P4KBase2:AddOpAI('EngineerAttack', 'M2_Aeon_Assist_Engineers_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'P4KaelBase2',
                Factories = categories.TECH3 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('T2Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 2, categories.TECH3 * categories.NAVAL * categories.FACTORY})

    quantity = {2, 2, 3}
    local Temp = {
        'P4KB2NavalAttackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P4KB2NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {4, 3, 2}
    Temp = {
        'P4KB2NavalAttackTemp1',
        'NoPlan',
        { 'uas0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, 6, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P4KB2NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}
    trigger = {30, 25, 20}
    Temp = {
        'P4KB2NavalAttackTemp2',
        'NoPlan',
        { 'xas0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P4KB2NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
end

function P4KB2Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 8}
    local Temp = {
        'P4KB2AAttackTemp0',
        'NoPlan',
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P4K1B2AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {35, 25, 20}
    Temp = {
        'P4KB2AAttackTemp1',
        'NoPlan',
        { 'xaa0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4K1B2AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )   

    quantity = {5, 6, 8}
    opai = P4KBase2:AddOpAI('AirAttacks', 'M4_Kael_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE, '>='})
end

function P4KB2EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 4, 8}

    opai = P4KBase2:AddOpAI('P4KSub',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function P4Kaelbase3AI()
    P4KBase3:InitializeDifficultyTables(ArmyBrains[Kael], 'P4KaelBase3', 'P4KB3MK', 80, {P4KBase3 = 100})
    P4KBase3:StartNonZeroBase({{7, 12, 18}, {5, 8, 10}})

    P4KB3Navalattacks()
    P4KB3Airattacks()
    P4KB3Landattacks()
    P4KB3EXPattacks()
end

function P4KB3Airattacks()

    local quantity = {}

    quantity = {5, 7, 9}

    local Temp = {
        'P4KB3AAttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P4K1B3AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB3Airattack1','P4KB3Airattack2', 'P4KB3Airattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}

    Temp = {
        'P4KB3AAttackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4KB3AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB3Airattack1','P4KB3Airattack2', 'P4KB3Airattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}

    Temp = {
        'P4KB3AAttackTemp2',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4KB3AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB3Airattack1','P4KB3Airattack2', 'P4KB3Airattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    opai = P4KBase3:AddOpAI('AirAttacks', 'M4_Kael_Air_Attack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND * categories.MOBILE, '>='})
end

function P4KB3Landattacks()

    local quantity = {}

    quantity = {4, 5, 6}

    local Temp = {
        'P4KB3LandAttackTemp0',
        'NoPlan',
        { 'dal0310', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'ual0205', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P4KB3LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB3Landattack1','P4KB3Landattack2'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )   

    local opai = nil
    local trigger = {}
    local poolName = 'P4KaelBase3_TransportPool'
    
    local quantity = {3, 4, 6}
    -- T2 Transport Platoon
    local Temp = {
        'M4_Kael_Western_Transport_Platoon',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M4_Kael_Western_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase3',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P4KaelBase3',
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 3, 4}
    local Quantity2 = {3, 4, 6}
    Builder = {
        BuilderName = 'M4_Kael_Land_Assault',
        PlatoonTemplate = {
            'M4_Kael_Land_Assault_Template',
            'NoPlan',
            {'ual0303', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T3 Tank
            {'ual0304', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T3 Arty
            {'ual0205', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 AA
        },
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase3',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {4, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P4KDropAChain'.. Random(1, 3),
            LandingChain = 'P4KDropChain'.. Random(1, 3),
            TransportReturn = 'P4KB3MK',
            BaseName = 'P2Order1Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
end

function P4KB3Navalattacks()

    local quantity = {}
    local opai = nil

    -- Extra engineers assisting T2 naval factories, all T2 factories has to be built
    -- Count is {X, 0} since the platoon contains shields/stealth as well and we want just the engineers. And too lazy to make a new platoon rn.
    quantity = {{3, 0}, {6, 0}, {9, 0}}
    opai = P4KBase3:AddOpAI('EngineerAttack', 'M2_Aeon_Assist_Engineers_2',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'P4KaelBase3',
                Factories = categories.TECH3 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('T2Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 2, categories.TECH3 * categories.NAVAL * categories.FACTORY})

    quantity = {2, 3, 4}

    local Temp = {
        'P4KB3NavalAttackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P4KB3NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB3Navalattack1','P4KB3Navalattack2'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
end

function P4KB3EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 4, 8}

    opai = P4KBase3:AddOpAI('P4KSaucer',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P4KB3Airattack1','P4KB3Airattack2', 'P4KB3Airattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end
