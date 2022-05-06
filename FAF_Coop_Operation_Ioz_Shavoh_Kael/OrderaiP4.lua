local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local Player1 = 1
local Kael = 2

local P4KBase1 = BaseManager.CreateBaseManager()
local P4KBase2 = BaseManager.CreateBaseManager()
local P4KBase3 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P4Kaelbase1AI()
    P4KBase1:InitializeDifficultyTables(ArmyBrains[Kael], 'P4KaelBase1', 'P4KB1MK', 80, {P4KBase1 = 100})
    P4KBase1:StartNonZeroBase({{14, 18, 22}, {10, 14, 18}})

    P4KB1Airattacks()
    P4KB1Landattacks()
    P4KB1EXPattacks()
end

function P4KB1Airattacks()

    local quantity = {}

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

    Temp = {
        'P4KB1AAttackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4K1B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB1Airattack1','P4KB1Airattack2', 'P4KB1Airattack3', 'P4KB1Airattack4'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {5, 8, 10}

    Temp = {
        'P4KB1AAttackTemp2',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4K1B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
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

    quantity = {6, 8, 10}

    local Temp = {
        'P4KB1LandAttackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'ual0205', 1, 2, 'Attack', 'GrowthFormation' },       
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
end

function P4KB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = P4KBase1:AddOpAI('P4KBot',
        {
            Amount = 2,
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
    P4KBase2:StartNonZeroBase({{12, 16, 18}, {8, 11, 14}})

    P4KB2Navalattacks()
    P4KB2Airattacks()
    P4KB2EXPattacks()
end

function P4KB2Navalattacks()

    local quantity = {}

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

    Temp = {
        'P4KB2NavalAttackTemp1',
        'NoPlan',
        { 'uas0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, 6, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P4KB2NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.TECH3 * categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
        },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
    
    quantity = {1, 2, 3}

    Temp = {
        'P4KB2NavalAttackTemp2',
        'NoPlan',
        { 'xas0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, 6, 'Attack', 'GrowthFormation' },       
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
        {'default_brain',  {'HumanPlayers'}, 25, categories.TECH3 * categories.STRUCTURE * categories.DEFENSE}},
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

    Temp = {
        'P4KB2AAttackTemp1',
        'NoPlan',
        { 'xaa0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P4K1B2AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4KaelBase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 35, categories.NAVAL * categories.MOBILE}},
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
    
    quantity = {2, 3, 4}

    opai = P4KBase2:AddOpAI('P4KSub',
        {
            Amount = 2,
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
    P4KBase3:StartNonZeroBase({{8, 11, 14}, {5, 8, 10}})

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
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.AIR * categories.MOBILE, '>='})
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
     
    quantity = {2, 2, 3}

    opai = P4KBase3:AddOpAI('EngineerAttack', 'M4_Kael_TransportBuilder2',
     {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P4UB1MK',
        },
        Priority = 2000,
     }
    )
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 1, categories.uaa0104})

    quantity = {6, 6, 12}
        
    opai = P4KBase3:AddOpAI('BasicLandAttack', 'M4_Kael_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P4KDropAChain1', 
                LandingChain = 'P4KDropChain1',
                TransportReturn = 'P4KB3MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    
    quantity = {6, 6, 12}

    opai = P4KBase3:AddOpAI('BasicLandAttack', 'M4_Kael_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P4KDropAChain2', 
                LandingChain = 'P4KDropChain2',
                TransportReturn = 'P4KB3MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
        
    quantity = {6, 6, 12}

    opai = P4KBase3:AddOpAI('BasicLandAttack', 'M4_Kael_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P4KDropAChain3', 
                LandingChain = 'P4KDropChain3',
                TransportReturn = 'P4KB3MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
end

function P4KB3Navalattacks()

    local quantity = {}

    quantity = {2, 3, 4}

    local Temp = {
        'P4KB3NavalAttackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
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
    
    quantity = {2, 3, 4}

    opai = P4KBase3:AddOpAI('P4KSaucer',
        {
            Amount = 2,
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
