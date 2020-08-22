local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/faf_coop_operation_tha_atha_aez.v0011/FAF_Coop_Operation_Tha_Atha_Aez_CustomFunctions.lua' 

local Aeon = 4
local Player1 = 1

local Difficulty = ScenarioInfo.Options.Difficulty

local Aeonbase3 = BaseManager.CreateBaseManager()
local Aeonbase1 = BaseManager.CreateBaseManager()
local Aeonbase2 = BaseManager.CreateBaseManager()

function AeonBase1AI()
    Aeonbase1:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase1', 'P2AB1MK', 80, {P2Abase1 = 100})
    Aeonbase1:StartNonZeroBase({{18,22,26}, {16,20,24}})
    Aeonbase1:SetActive('AirScouting', true)

    P2AB1landattacks1()
    P2AB1airattacks1()
end

function AeonBase2AI()
    Aeonbase2:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase2', 'P2AB0MK', 40, {AeonIntel = 100})
    Aeonbase2:StartNonZeroBase({{4,8,10}, {2,6,8}})
    
    AeonIntelattacks()
end

function AeonBase3AI()
    Aeonbase3:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase3', 'P3AB2MK', 60, {P3Abase2 = 100})
    Aeonbase3:StartNonZeroBase({{10,14,18}, {8,12,16}})
    Aeonbase3:SetActive('AirScouting', true)

    AeonNattack2()
    EXpattacks2()
end

function P3Aattacks()

    P3AB1landattacks2()
    P3AB1Airattacks2()
    EXpattacks1()
end

function AeonIntelattacks()
   
    local Temp = {
        'P2AB2LandattackTemp0',
        'NoPlan',
        { 'ual0303', 1, 6, 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2AB2LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB2landattack1', 'P2AB2landattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2AB2LandattackTemp1',
        'NoPlan',
        { 'ual0202', 1, 8, 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2AB2LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2AB2LandattackTemp2',
        'NoPlan',
        { 'ual0202', 1, 6, 'Attack', 'GrowthFormation' },
        { 'ual0303', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2AB2LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB2landattack1', 'P2AB2landattack2'}
        },  
    }
    
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function P2AB1landattacks1()
   
    local Temp = {
        'P2AB1LandattackTemp0',
        'NoPlan',
        { 'xal0203', 1, 6, 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2AB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB1landattack1', 'P2AB1landattack2', 'P2AB1landattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2AB1LandattackTemp1',
        'NoPlan',
        { 'xal0203', 1, 6, 'Attack', 'GrowthFormation' },
        { 'dal0310', 1, 4, 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB1landattack1', 'P2AB1landattack2', 'P2AB1landattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2AB1LandattackTemp2',
        'NoPlan',
        { 'xal0203', 1, 10, 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P2AB1landattack1', 'P2AB1landattack2', 'P2AB1landattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    opai = Aeonbase1:AddOpAI('EngineerAttack', 'M2_AEON_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2AB1MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uaa0104})
    
    opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M2_Aeon_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2Aintattack1', 
                LandingChain = 'AeonattackDrop',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('SiegeBots', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
end

function P2AB1airattacks1()
   
    local Temp = {
        'P2AB1airattackTemp1',
        'NoPlan',
        { 'uaa0203', 1, 16, 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P2AB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2AB1airattackTemp2',
        'NoPlan',
        { 'xaa0202', 1, 16, 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2AB1airattackTemp3',
        'NoPlan',
        { 'uaa0303', 1, 8, 'Attack', 'AttackFormation' },
        { 'xaa0202', 1, 8, 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1airattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2AB1airattackTemp4',
        'NoPlan',
        { 'xaa0305', 1, 4, 'Attack', 'AttackFormation' },
        { 'uaa0203', 1, 8, 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P2AB1airattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function AeonNattack2()

    local Temp = {
        'P3AB2airTemp1',
        'NoPlan',
        { 'xaa0305', 1, 5, 'Attack', 'GrowthFormation' },
        { 'uaa0203', 1, 15, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3AB2airBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3A1B2airattack1', 'P3A1B2airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P3AB2airTemp2',
        'NoPlan',
        { 'uaa0303', 1, 10, 'Attack', 'GrowthFormation' },
        { 'uaa0304', 1, 5, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3AB2airBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3A1B2airattack1', 'P3A1B2airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P3AB2airTemp3',
        'NoPlan',
        { 'uaa0303', 1, 15, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3AB2airBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3A1B2airattack1', 'P3A1B2airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    Temp = {
        'AeonNavalTemp1',
        'NoPlan',
        { 'xas0306', 1, 2, 'Attack', 'GrowthFormation' },  --Tac boats
        { 'uas0202', 1, 4, 'Attack', 'GrowthFormation' },  --Crusier
    }
    Builder = {
        BuilderName = 'AeonNavalBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3Anavalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'AeonNavalTemp2',
        'NoPlan',
        { 'uas0202', 1, 3, 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, 3, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'AeonNavalBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3Anavalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'AeonNavalTemp3',
        'NoPlan',
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, 8, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'AeonNavalBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3Anavalattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )   
end

function P3AB1landattacks2()
     
    opai = Aeonbase1:AddOpAI('EngineerAttack', 'M3_AEON_TransportBuilder2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2AB1MK',
        },
        Priority = 2000,
    }
    )
    opai:SetChildQuantity('T2Transports', 8)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.uaa0104})


    opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_1',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P3AB1dropattack1', 
                    LandingChain = 'P3AB1drop1',
                    MovePath = 'P3AB1movedrop1',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'MobileMissiles'}, {10, 6})
        opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    
    opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB1dropattack1', 
                LandingChain = 'P3AB1drop1',
                MovePath = 'P3AB1movedrop1',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('SiegeBots', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    
    opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},    
            PlatoonData = {
                AttackChain =  'P3AB1dropattack2', 
                LandingChain = 'P3AB1drop2',
                MovePath = 'P3AB1movedrop2',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('SiegeBots', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    
    opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB1dropattack2', 
                LandingChain = 'P3AB1drop2',
                MovePath = 'P3AB1movedrop2',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 16)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    
    opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_5',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB1dropattack3', 
                LandingChain = 'P3AB1drop3',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('SiegeBots', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
    
    opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_6',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB1dropattack3', 
                LandingChain = 'P3AB1drop3',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 16)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    
    local Temp = {
        'P3AB1LandattackTemp0',
        'NoPlan',
        { 'xal0203', 1, 8, 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3AB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB1landattack1', 'P2AB1landattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )   
end

function P3AB1Airattacks2()

    local Temp = {
        'P3AB1airattackTemp0',
        'NoPlan',
        { 'uaa0303', 1, 8, 'Attack', 'AttackFormation' },
    }
    local Builder = {
        BuilderName = 'P3AB1airattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P3AB1airattackTemp1',
        'NoPlan',
        { 'uaa0203', 1, 18, 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P3AB1airattackTemp2',
        'NoPlan',
        { 'uaa0304', 1, 4, 'Attack', 'AttackFormation' },
        { 'xaa0202', 1, 8, 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P3AB1airattackTemp3',
        'NoPlan',
        { 'uaa0203', 1, 12, 'Attack', 'AttackFormation' },
        { 'xaa0305', 1, 4, 'Attack', 'AttackFormation' },
    }
    Builder = {
        BuilderName = 'P3AB1airattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end

function EXpattacks1()
    local opai = nil
    local quantity = {}
    
    opai = Aeonbase1:AddOpAI('Abot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2AB1landattack1', 'P2AB1landattack2', 'P2AB1landattack3'}
        },
            MaxAssist = 4,
            Retry = true,
        }
    )
end

function EXpattacks2()
    local opai = nil
    local quantity = {}
    
    opai = Aeonbase3:AddOpAI('Abot2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3AExpattack1', 'P3AExpattack2', 'P3AExpattack3'}
        },
            MaxAssist = 4,
            Retry = true,
        }
    )
end
