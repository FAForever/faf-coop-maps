local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local Player1 = 1
local UEF = 5

local P4UBase1 = BaseManager.CreateBaseManager()
local P4UBase2 = BaseManager.CreateBaseManager()

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

    quantity = {6, 8, 12}

    local Temp = {
        'P4U1B1AttackTemp0',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
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
    
    quantity = {6, 7, 8}

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
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Airattack1','P4UB1Airattack2', 'P4UB1Airattack3', 'P4UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}

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
        {'default_brain',  {'HumanPlayers'}, 40, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
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
    
    quantity = {4, 5, 6}

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
        {'default_brain',  {'HumanPlayers'}, 45, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Landattack1','P4UB1Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    local opai = nil
     
    opai = P4UBase1:AddOpAI('EngineerAttack', 'M4_UEF_TransportBuilder2',
     {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P4UB1MK',
        },
        Priority = 2000,
     }
    )
    opai:SetChildQuantity('T3Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 1, categories.xea0306})

        
        opai = P4UBase1:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack_1',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P4KDropAChain1', 
                    LandingChain = 'P4KDropChain1',
                    TransportReturn = 'P4UB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity('HeavyBots', 6)
        opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
        
        opai = P4UBase1:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack_2',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P4KDropAChain2', 
                    LandingChain = 'P4KDropChain2',
                    TransportReturn = 'P4UB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity('HeavyBots', 6)
        opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
        
        opai = P4UBase1:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack_3',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P4KDropAChain3', 
                    LandingChain = 'P4KDropChain3',
                    TransportReturn = 'P4UB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity('HeavyBots', 6)
        opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
end

function P4UEFbase2AI()
    P4UBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFBase2', 'P4UB2MK', 70, {P4UBase2 = 100})
    P4UBase2:StartNonZeroBase({{6, 9, 13}, {5, 7, 10}})

    P4UB2Navalattacks()
    P4UB2Airattacks()
    P4UB2EXPattacks()
end


function P4UB2Navalattacks()

    local quantity = {}

    quantity = {3, 4, 5}

    local Temp = {
        'P3UB2NavalAttackTemp0',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0205', 1, 1, 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, 2, 'Attack', 'GrowthFormation' },
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

    Temp = {
        'P3UB2NavalAttackTemp1',
        'NoPlan',
        { 'ues0307', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
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
        {'default_brain',  {'HumanPlayers'}, 30, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB2Navalattack1','P4UB2Navalattack2', 'P4UB2Navalattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}

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
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE}},
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
        LocationType = 'P4UEFBase1',
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
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE, '>='})
end

function P4UB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = P4UBase1:AddOpAI('P4UBot',
        {
            Amount = 2,
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
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P4UBase2Navalattack1','P4UBase2Navalattack2', 'P4UBase2Navalattack3'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end
