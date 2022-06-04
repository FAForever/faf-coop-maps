local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local QAI = 3

local Q1P2Base1 = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty

function P2Q1base1AI()

    Q1P2Base1:InitializeDifficultyTables(ArmyBrains[QAI], 'P2QAIBase1', 'P2Q1B1MK', 80, {P2Qbase1 = 500})
    Q1P2Base1:StartNonZeroBase({{1104, 8, 7}, {9, 7, 6}})
    
    P2QlandDefenses1()
    P2QAirDefenses1()
end

function P2QAirDefenses1()

    local quantity = {}

    quantity = {3, 2, 1} 
    local Temp = {
        'P2QB1DefenseTemp0',
        'NoPlan',      
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2QB1DefenseBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2QAIBase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2QAirD1'
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 4, 3} 
    Temp = {
        'P2QB1DefenseTemp1',
        'NoPlan',
        { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2QB1DefenseBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2QAIBase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2QAirD1'
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {5, 4, 3} 
    Temp = {
        'P2QB1DefenseTemp2',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2QB1DefenseBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2QAIBase1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2QAirD1'
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P2QlandDefenses1()

    local quantity = {}

    quantity = {4, 3, 2} 
    local Temp = {
        'P2QB1DefenseTemp0',
        'NoPlan',
        { 'url0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
        { 'url0202', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P2QB1DefenseBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2QAIBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2QlandD1'
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    opai = Q1P2Base1:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P2QlandD1', 'P2QAirD1'},
        },
        Priority = 115,
    })
    opai:SetChildQuantity('T1Engineers', 6)
end
