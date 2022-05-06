local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local Aeon = 4
local UEF = 2
local Cybran = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local Aeonbase1P3 = BaseManager.CreateBaseManager()
local Cybranbase1P3 = BaseManager.CreateBaseManager()
local UEFbase1P3 = BaseManager.CreateBaseManager()


function AeonP3base1AI()

    Aeonbase1P3:InitializeDifficultyTables(ArmyBrains[Aeon], 'P3Aeonbase1', 'P3AB1MK', 80, {P3ABase1 = 100})
    Aeonbase1P3:StartNonZeroBase({{8, 11, 13}, {5, 8, 10}})

    P3AB1Airattacks()
    P3AB1LandAttacks()
    P3AB1NavalAttacks()
    P3AB1EXPattacks()
end

function P3AB1Airattacks()
    
    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P3AB1AirattackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P3AB1AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',   
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3AB1AirDefense1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 7}
    Temp = {
        'P3AB1AirattackTemp1',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3AB1AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',   
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P3AB1AirattackTemp2',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3AB1AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.AIR * categories.MOBILE}},
        },    
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    opai = Aeonbase1P3:AddOpAI('AirAttacks', 'M3_Aeon_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P3AB1LandAttacks()

    local quantity = {}

    quantity = {6, 7, 8}
    local Temp = {
        'P3AB1LandattackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3AB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},   
        PlatoonData = {
            PatrolChains = {'P3AB1Landattack1', 'P3AB1Landattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P3AB1LandattackTemp1',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE - categories.TECH1}},
        }, 
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},   
        PlatoonData = {
            PatrolChains = {'P3AB1Landattack1', 'P3AB1Landattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    Temp = {
        'P3AB1LandattackTemp2',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.LAND}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},   
        PlatoonData = {
            PatrolChains = {'P3AB1Landattack1', 'P3AB1Landattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function P3AB1NavalAttacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3AB1NavalattackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3AB1NavalattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},   
        PlatoonData = {
            PatrolChain = 'P3AB1Navalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P3AB1NavalattackTemp1',
        'NoPlan',
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1NavalattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},   
        PlatoonData = {
            PatrolChain = 'P3AB1Navalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    Temp = {
        'P3AB1NavalattackTemp2',
        'NoPlan',
        { 'uas0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1NavalattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Aeonbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},   
        PlatoonData = {
            PatrolChain = 'P3AB1Navalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function P3AB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = Aeonbase1P3:AddOpAI('P3AExp1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'P3AB1Landattack1', 'P3AB1Landattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function UEFP3base1AI()

    UEFbase1P3:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFbase1', 'P3UB1MK', 80, {P3UBase1 = 100})
    UEFbase1P3:StartNonZeroBase({{8, 11, 13}, {5, 8, 10}})

    P3UB1Airattacks()
    P3UB1LandAttacks()
    P3UB1NavalAttacks()
    P3UB1EXPattacks()
end

function P3UB1Airattacks()
    
    local quantity = {}

    quantity = {3, 4, 5}
    local Temp = {
        'P3UB1AirattackTemp0',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0303', 1, 4, 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P3UB1AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFbase1',   
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3UB1AirDefense1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P3UB1AirattackTemp1',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3UB1AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFbase1',   
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    Temp = {
        'P3UB1AirattackTemp2',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3UB1AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },    
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {7, 8, 9}
    opai = UEFbase1P3:AddOpAI('AirAttacks', 'M3_UEF_Air_Attack_1',
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
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P3UB1LandAttacks()

    local quantity = {}

    quantity = {6, 7, 8}
    local Temp = {
        'P3UB1LandattackTemp0',
        'NoPlan',
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3UB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},   
        PlatoonData = {
            PatrolChain = 'P3UB1Landattack1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    opai = UEFbase1P3:AddOpAI('EngineerAttack', 'M3_UEF_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P3UB1MK',
        },
        Priority = 1100,
    })
    opai:SetChildQuantity('T2Transports', 3)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uea0104})
  
    opai = UEFbase1P3:AddOpAI('BasicLandAttack', 'M3_UEF_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3UB1Dropattack1', 
                LandingChain = 'P3UB1Drop1',
                TransportReturn = 'P3UB1MK',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('SiegeBots', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    
    opai = UEFbase1P3:AddOpAI('BasicLandAttack', 'M3_UEF_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3UB1Dropattack1', 
                LandingChain = 'P3UB1Drop1',
                TransportReturn = 'P3UB1MK',
            },
            Priority = 205,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 150})

    opai = UEFbase1P3:AddOpAI('BasicLandAttack', 'M3_UEF_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3UB1Dropattack1', 
                LandingChain = 'P3UB1Drop1',
                TransportReturn = 'P3UB1MK',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 12)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
end

function P3UB1NavalAttacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3UB1NavalattackTemp0',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3UB1NavalattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},   
        PlatoonData = {
            PatrolChain = 'P3UB1Navalattack1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P3UB1NavalattackTemp1',
        'NoPlan',
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB1NavalattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},   
        PlatoonData = {
            PatrolChain = 'P3UB1Navalattack1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    Temp = {
        'P3UB1NavalattackTemp2',
        'NoPlan',
        { 'ues0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3UB1NavalattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},   
        PlatoonData = {
            PatrolChain = 'P3UB1Navalattack1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P3UB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = UEFbase1P3:AddOpAI('P3UExp1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'P3UB1Navalattack1'
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function CybranP3base1AI()

    Cybranbase1P3:InitializeDifficultyTables(ArmyBrains[Cybran], 'P3Cybranbase1', 'P3CB1MK', 80, {P3CBase1 = 100})
    Cybranbase1P3:StartNonZeroBase({{8, 11, 13}, {5, 8, 10}})

    P3CB1Airattacks()
    P3CB1LandAttacks()
    P3CB1NavalAttacks()
    P3CB1EXPattacks()
end

function P3CB1Airattacks()
    
    local quantity = {}

    quantity = {7, 8, 9}
    local Temp = {
        'P3CB1AirattackTemp0',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ura0303', 1, 4, 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P3CB1AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybranbase1',   
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3CB1AirDefense1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    Temp = {
        'P3CB1AirattackTemp1',
        'NoPlan',
        { 'ura0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3CB1AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybranbase1',   
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3CB1Airattack1', 'P3CB1Airattack2', 'P3CB1Airattack3'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 8}
    Temp = {
        'P3CB1AirattackTemp2',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P3CB1AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.AIR * categories.MOBILE}},
        },    
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3CB1Airattack1', 'P3CB1Airattack2', 'P3CB1Airattack3'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    opai = Cybranbase1P3:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1,  categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P3CB1LandAttacks()

    opai = Cybranbase1P3:AddOpAI('EngineerAttack', 'M3_Cybran_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P3CB1MK',
        },
        Priority = 1100,
    })
    opai:SetChildQuantity('T2Transports', 3)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.ura0104})
  
    opai = Cybranbase1P3:AddOpAI('BasicLandAttack', 'M3_Cybran_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3CB1Dropattack1', 
                LandingChain = 'P3CB1Drop1',
                TransportReturn = 'P3CB1MK',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('SiegeBots', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    
    opai = Cybranbase1P3:AddOpAI('BasicLandAttack', 'M3_Cybran_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3CB1Dropattack1', 
                LandingChain = 'P3CB1Drop1',
                TransportReturn = 'P3CB1MK',
            },
            Priority = 205,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 160})
end

function P3CB1NavalAttacks()

    local quantity = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3CB1NavalattackTemp0',
        'NoPlan',
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3CB1NavalattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},   
        PlatoonData = {
            PatrolChains = {'P3CB1Navalattack1', 'P3CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P3CB1NavalattackTemp1',
        'NoPlan',
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3CB1NavalattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 3, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},   
        PlatoonData = {
            PatrolChains = {'P3CB1Navalattack1', 'P3CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    Temp = {
        'P3CB1NavalattackTemp2',
        'NoPlan',
        { 'urs0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3CB1NavalattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Cybranbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 15, categories.NAVAL * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},   
        PlatoonData = {
            PatrolChains = {'P3CB1Navalattack1', 'P3CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P3CB1EXPattacks()
    local opai = nil
    local quantity = {}
    
    opai = Cybranbase1P3:AddOpAI('P3CExp1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3CB1Airattack1', 'P3CB1Airattack2', 'P3CB1Airattack3'}
        },
            MaxAssist = 3,
            Retry = true,
        }
    )
end
