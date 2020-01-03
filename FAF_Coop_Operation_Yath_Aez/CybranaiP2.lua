local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local Cybran = 3
local Difficulty = ScenarioInfo.Options.Difficulty

local Cybranbase1 = BaseManager.CreateBaseManager()
local Cybranbase2 = BaseManager.CreateBaseManager()

function Cybranbase1AI()

    Cybranbase1:InitializeDifficultyTables(ArmyBrains[Cybran], 'Cybranbase1', 'P2CB1MK', 90, {P2CBase1 = 100})
    Cybranbase1:StartNonZeroBase({{16,20,24}, {11,15,19}})
    
    ForkThread(
        function()
            WaitSeconds(4)
            Cybranbase1:AddBuildGroup('P2CBase1EXD', 200, false)
        end
    )
    
    P2CB1landattacks1()
    P2CB1NavalAttacks1()
    P2CB1Airattacks1()
    P2CB1EXPattacks1() 
end

function P2CB1landattacks1()
 
    local Temp = {
        'P2CB1landAttackTemp0',
        'NoPlan',
        { 'url0202', 1, 6, 'Attack', 'GrowthFormation' }, 
        { 'url0205', 1, 5, 'Attack', 'GrowthFormation' },  
        { 'url0303', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P2CB1landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2CB1Landattack1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
   
    Temp = {
        'P2CB1landAttackTemp1',
        'NoPlan',
        { 'url0203', 1, 6, 'Attack', 'GrowthFormation' }, 
        { 'xrl0305', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2CB1landAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2CB1Landattack2'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
   
    Temp = {
        'P2CB1landAttackTemp2',
        'NoPlan',
        { 'url0202', 1, 10, 'Attack', 'GrowthFormation' }, 
        { 'url0205', 1, 4, 'Attack', 'GrowthFormation' },  
        { 'url0306', 1, 2, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2CB1landAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2CB1Landattack1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P2CB1NavalAttacks1()

    local  Temp = {
        'P2CB1NavalAttackTemp0',
        'NoPlan',
        { 'urs0201', 1, 3, 'Attack', 'GrowthFormation' },   
        { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' },   
        { 'urs0203', 1, 3, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P2CB1NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB1Navalattack1', 'P2CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    Temp = {
        'P2CB1NavalAttackTemp1',
        'NoPlan',
        { 'urs0203', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'xrs0204', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2CB1NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB1Navalattack1', 'P2CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2CB1NavalAttackTemp2',
        'NoPlan',
        { 'urs0103', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2CB1NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB1Navalattack1', 'P2CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2CB1NavalAttackTemp3',
        'NoPlan',
        { 'urs0201', 1, 5, 'Attack', 'GrowthFormation' },   
        { 'xrs0205', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P2CB1NavalAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB1Navalattack1', 'P2CB1Navalattack2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P2CB1Airattacks1()
 
    local Temp = {
        'P2CB1AirAttackTemp0',
        'NoPlan',
        { 'ura0203', 1, 4, 'Attack', 'GrowthFormation' }, 
        { 'ura0204', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P2CB1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB1Airattacks1', 'P2CB1Airattacks2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2CB1AirAttackTemp1',
        'NoPlan',
        { 'ura0204', 1, 8, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2CB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB1Airattacks1', 'P2CB1Airattacks2'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P2CB1AirAttackTemp2',
        'NoPlan',
        { 'ura0203', 1, 10, 'Attack', 'GrowthFormation' },  
        { 'dra0202', 1, 6, 'Attack', 'GrowthFormation' },
        { 'ura0102', 1, 12, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2CB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2CB1Airdefense1'
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

function P2CB1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = Cybranbase1:AddOpAI('M3_Cybran_Spider_2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'P2CB1Landattack1',
            },
            MaxAssist = 2,
            Retry = true,
        }
    )
end

function Cybranbase2AI()

    Cybranbase2:InitializeDifficultyTables(ArmyBrains[Cybran], 'Cybranbase2', 'P2CB2MK', 60, {P2CBase2 = 300})
    Cybranbase2:StartEmptyBase({{10,13,16}, {5,8,11}})
    
    Cybranbase1:AddExpansionBase('Cybranbase2', 3)
    
    P2CB2Airattacks1()
end

function P2CB2Airattacks1()
 
    local Temp = {
        'P2CB2AirAttackTemp0',
        'NoPlan',
        { 'ura0203', 1, 15, 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2CB2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB2Airattacks1', 'P2CB2Airattacks2', 'P2CB2Airattacks3', 'P2CB2Airattacks4'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    local Temp = {
        'P2CB2AirAttackTemp1',
        'NoPlan',
        { 'dra0202', 1, 10, 'Attack', 'GrowthFormation' },      
    }
    local Builder = {
        BuilderName = 'P2CB2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Cybranbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2CB2Airattacks1', 'P2CB2Airattacks2', 'P2CB2Airattacks3', 'P2CB2Airattacks4'}
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )  
end
