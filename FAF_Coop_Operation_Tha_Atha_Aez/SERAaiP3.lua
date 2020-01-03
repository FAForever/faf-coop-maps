local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/faf_coop_operation_tha_atha_aez.v0011/FAF_Coop_Operation_Tha_Atha_Aez_CustomFunctions.lua' 

local SeraphimAlly2 = 6

local Difficulty = ScenarioInfo.Options.Difficulty

local Serabase2 = BaseManager.CreateBaseManager()

function OrderBase1AI()
    Serabase2:InitializeDifficultyTables(ArmyBrains[SeraphimAlly2], 'Orderbase', 'OrderBaseMK', 70, {AeonbaseAlly2 = 100})
    Serabase2:StartNonZeroBase({{15,12,9}, {12,9,6}})

    OrderlandAttacks()
    OrderAirAttacks()   
end

function OrderAirAttacks()

    local Temp = {
        'AirDefenceTemp2',
        'NoPlan',
        { 'xaa0305', 1, 3, 'Attack', 'GrowthFormation' },  --AA gunships
        { 'uaa0203', 1, 9, 'Attack', 'GrowthFormation' },  --Gunships
        { 'uaa0303', 1, 6, 'Attack', 'GrowthFormation' },  --ASFs
    }
    local Builder = {
        BuilderName = 'AirDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1defence1'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder ) 
end

function OrderlandAttacks()

    local Temp = {
        'P3SA2LandDefenceTemp0',
        'NoPlan',
        { 'ual0202', 1, 7, 'Attack', 'GrowthFormation' },  --Heavy Tanks
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },   --Mobile-Sheilds
        { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },   --Anti-Air Flak
    }
    local Builder = {
        BuilderName = 'P3SA2LandDefenceBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1defence2'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )
     
    Temp = {
        'P3SA2LandDefenceTemp1',
        'NoPlan',
        { 'ual0202', 1, 6, 'Attack', 'GrowthFormation' },
        { 'xal0305', 1, 2, 'Attack', 'GrowthFormation' },
        { 'dalk003', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3SA2LandDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1defence2'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P3SA2LandDefenceTemp2',
        'NoPlan',
        { 'ual0303', 1, 3, 'Attack', 'GrowthFormation' },
        { 'ual0202', 1, 5, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3SA2LandDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3SA2landattack1', 'P3SA2landattack2'}
        },
    
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )    
end
