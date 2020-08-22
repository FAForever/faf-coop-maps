local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua'

local Player1 = 1
local Cybran1 = 2
local Cybran2 = 5

local C1P2Base1 = BaseManager.CreateBaseManager()
local C1P2Base2 = BaseManager.CreateBaseManager()
local C1P2Base3 = BaseManager.CreateBaseManager()
local C2P2Base1 = BaseManager.CreateBaseManager()
local C2P2Base2 = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty

--Cybran 1 Airbase

function P2C1base1AI()

    C1P2Base1:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P2Cybran1Base1', 'P2C1B1MK', 70, {P2C1base1 = 100})
    C1P2Base1:StartNonZeroBase({{13,17,19}, {10,14,16}})
    C1P2Base1:SetActive('AirScouting', true)

    
    P2C1B1Airattacks1()
    P2C1B1EXPattacks1()
    
end

function P2C1B1Airattacks1()

    local Temp = {
        'P2C1B1AttackTemp0',
        'NoPlan',
        { 'ura0203', 1, 12, 'Attack', 'GrowthFormation' },        
    }
    local Builder = {
        BuilderName = 'P2C1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B1AttackTemp1',
        'NoPlan',
        { 'xra0305', 1, 6, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B1AttackTemp2',
        'NoPlan',
        { 'ura0303', 1, 6, 'Attack', 'GrowthFormation' },
        { 'dra0202', 1, 12, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B1AttackTemp3',
        'NoPlan',
        { 'ura0304', 1, 6, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B1AttackTemp5',
        'NoPlan',
        { 'ura0303', 1, 9, 'Attack', 'GrowthFormation' },
        { 'xra0305', 1, 6, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2C1B1Airdefence1'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

function P2C1B1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = C1P2Base1:AddOpAI('C1Bug1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P2C1B1Airattack1', 'P2C1B1Airattack2', 'P2C1B1Airattack3', 'P2C1B1Airattack4', 'P2C1B1Airattack5'}
        },
            MaxAssist = 4,
            Retry = true,
        }
    )
end

--Cybran 1 Mainbase

function P2C1base2AI()

    C1P2Base2:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P2Cybran1Base2', 'P2C1B2MK', 80, {P2C1base2 = 100})
    C1P2Base2:StartNonZeroBase({{12,16,18}, {8,12,14}})
    C1P2Base2:SetActive('AirScouting', true)

    
    P2C1B2Navalattacks1()
    P2C1B2Airattacks1()
    P2C1B2EXPattacks1()
end

function P2C1B2Navalattacks1()

    local Temp = {
        'P2C1B2NAttackTemp0',
        'NoPlan',
        { 'urs0201', 1, 3, 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2C1B2NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2NavalAttack1', 'P2C1B2NavalAttack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B2NAttackTemp1',
        'NoPlan',
        { 'urs0201', 1, 3, 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'xrs0204', 1, 6, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B2NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2C1B2NavalAttack3'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B2NAttackTemp2',
        'NoPlan',
        { 'urs0302', 1, 1, 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' },
        { 'xrs0204', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B2NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2C1B2NavalAttack3'
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

function P2C1B2Airattacks1()

    local Temp = {
        'P2C1B2AAttackTemp0',
        'NoPlan',
        { 'dra0202', 1, 8, 'Attack', 'GrowthFormation' },   
        { 'ura0303', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C1B2AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2Airattack1', 'P2C1B2Airattack2', 'P2C1B2Airattack3', 'P2C1B2Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B2AAttackTemp1',
        'NoPlan',
        { 'ura0304', 1, 4, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2C1B2AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2Airattack1', 'P2C1B2Airattack2', 'P2C1B2Airattack3', 'P2C1B2Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B2AAttackTemp2',
        'NoPlan',
        { 'ura0203', 1, 16, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2C1B2AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2Airattack1', 'P2C1B2Airattack2', 'P2C1B2Airattack3', 'P2C1B2Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B2AAttackTemp3',
        'NoPlan',
        { 'ura0203', 1, 8, 'Attack', 'GrowthFormation' },
        { 'xra0305', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C1B2AAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B2Airattack1', 'P2C1B2Airattack2', 'P2C1B2Airattack3', 'P2C1B2Airattack4'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

function P2C1B2EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = C1P2Base2:AddOpAI('C1Bot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P2C1B2Expattack1', 'P2C1B2Expattack2', 'P2C1B2Expattack3'}
        },
            MaxAssist = 2,
            Retry = true,
        }
    )
end

-- Cybran 1 Land/Arty base

function P2C1base3AI()

    C1P2Base3:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P2Cybran1Base3', 'P2C1B3MK', 65, {P2C1base3 = 100})
    C1P2Base3:StartNonZeroBase({{8,11,14}, {3,5,6}})
    C1P2Base3.MaximumConstructionEngineers = 9
    
    P2C1B3Landattacks1()
    
     ForkThread(
        function()
            WaitSeconds(1)
            C1P2Base3:AddBuildGroup('P2C1base3EX_D' .. Difficulty, 200, false)
        end
     )
end

function P2C1B3Landattacks1()

    local Temp = {
        'P2C1B3LAttackTemp0',
        'NoPlan',
        { 'xrl0305', 1, 3, 'Attack', 'GrowthFormation' },   
        { 'url0203', 1, 7, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C1B3LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base3',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C1B3Landattack1', 'P2C1B3Landattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B3LAttackTemp1',
        'NoPlan',
        { 'xrl0305', 1, 6, 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P2C1B3LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base3',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C1B3Landattack1', 'P2C1B3Landattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B3LAttackTemp2',
        'NoPlan',
        { 'url0304', 1, 4, 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P2C1B3LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C1B3Landattack1', 'P2C1B3Landattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C1B3LAttackTemp3',
        'NoPlan', 
        { 'url0203', 1, 16, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C1B3LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran1Base3',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C1B3Landattack1', 'P2C1B3Landattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end

-- Cybran 2 offmap base

function P2C2base1AI()

    C2P2Base1:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P2Cybran2Base1', 'P2C2B1MK', 80, {P2C2base1 = 100})
    C2P2Base1:StartNonZeroBase({{12,16,18}, {8,12,14}})
    C2P2Base1:SetActive('AirScouting', true)
    
    P2C2B1Landattacks1()
    P2C2B1Airattacks1()
end

function P2C2B1Landattacks1()

    local Temp = {
        'P2C2B1LAttackTemp0',
        'NoPlan',
        { 'xrl0305', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'url0202', 1, 8, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C2B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1LAttackTemp1',
        'NoPlan',
        { 'drlk001', 1, 2, 'Attack', 'GrowthFormation' },   
        { 'url0303', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1LAttackTemp2',
        'NoPlan',
        { 'drl0204', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'url0202', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 102,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1LAttackTemp3',
        'NoPlan',
        { 'url0202', 1, 12, 'Attack', 'GrowthFormation' },   
        { 'url0205', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 101,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1LAttackTemp4',
        'NoPlan',
        { 'url0202', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'url0303', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1LAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 101,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
end

function P2C2B1Airattacks1()

    local Temp = {
        'P2C2B1AAttackTemp0',
        'NoPlan',
        { 'xra0305', 1, 2, 'Attack', 'GrowthFormation' },   
        { 'ura0203', 1, 8, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C2B1AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 104,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1AAttackTemp1',
        'NoPlan',
        { 'ura0303', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'dra0202', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1AAttackTemp2',
        'NoPlan',
        { 'ura0203', 1, 10, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2C2B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 103,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
end

-- Offmap base Part 3 attacks

function P2C2B1base1EXD()

    C2P2Base1:AddBuildGroup('P2C2base1EXD_D' .. Difficulty, 800, false)
    C2P2Base1.MaximumConstructionEngineers = 4
    
    P2C2B1Landattacks2()
    P2C2B1Navalattacks1()  
end

function P2C2B1Landattacks2()

    local Temp = {
        'P2C2B1LAttackTemp5',
        'NoPlan',
        { 'xrl0305', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'url0202', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C2B1LAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1LAttackTemp6',
        'NoPlan',
        { 'url0304', 1, 3, 'Attack', 'GrowthFormation' },   
        { 'url0111', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1LAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1LAttackTemp7',
        'NoPlan',
        { 'url0303', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'drl0204', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B1LAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Landattack1', 'P2C2B1Landattack2', 'P2C2B1Landattack3'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder ) 
end

function P2C2B1Navalattacks1()

    local Temp = {
        'P2C2B1NAttackTemp0',
        'NoPlan',
        { 'urs0201', 1, 3, 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, 3, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2C2B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Navalattack1', 'P2C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1NAttackTemp1',
        'NoPlan',
        { 'xrs0204', 1, 3, 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, 3, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2C2B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Navalattack1', 'P2C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1NAttackTemp2',
        'NoPlan',
        { 'xrs0204', 1, 6, 'Attack', 'GrowthFormation' },
        { 'urs0103', 1, 6, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2C2B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Navalattack1', 'P2C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B1NAttackTemp3',
        'NoPlan',
        { 'xrs0204', 1, 9, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2C2B1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B1Navalattack1', 'P2C2B1Navalattack2'}
        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
end
    
-- Cybran 2 Minor landbase

function P2C2base2AI()

    C2P2Base2:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P2Cybran2Base2', 'P2C2B2MK', 70, {P2C2base2 = 100})
    C2P2Base2:StartNonZeroBase({{8,10,13}, {5,7,10}})
    C2P2Base2.MaximumConstructionEngineers = 5
    
    P2C2B2Landattacks1()
    
    ForkThread(
        function()
            WaitSeconds(1)
            C2P2Base2:AddBuildGroup('P2C2base2EXD_D' .. Difficulty, 900, false)
        end
     )    
end

function P2C2B2Landattacks1()

    local Temp = {
        'P2C2B2LAttackTemp0',
        'NoPlan',
        { 'url0205', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'url0202', 1, 8, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2C2B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B2Landattack1', 'P2C2B2Landattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B2LAttackTemp1',
        'NoPlan',
        { 'url0111', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'url0202', 1, 8, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B2Landattack1', 'P2C2B2Landattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2C2B2LAttackTemp2',
        'NoPlan',
        { 'xrl0305', 1, 3, 'Attack', 'GrowthFormation' },   
        { 'url0203', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2C2B2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Cybran2Base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2C2B2Landattack3', 'P2C2B2Landattack2'}
        },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder ) 
end
