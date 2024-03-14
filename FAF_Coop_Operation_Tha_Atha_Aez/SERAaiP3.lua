local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_CustomFunctions.lua' 

local SeraphimAlly2 = 6

local Difficulty = ScenarioInfo.Options.Difficulty

local Serabase2 = BaseManager.CreateBaseManager()

function OrderBase1AI()
    Serabase2:InitializeDifficultyTables(ArmyBrains[SeraphimAlly2], 'Orderbase', 'OrderBaseMK', 70, {AeonbaseAlly2 = 100})
    Serabase2:StartNonZeroBase({{15, 12, 9}, {12, 9, 6}})

    OrderlandAttacks()
    OrderAirAttacks()   
end

function OrderAirAttacks()

    local quantity = {}

    quantity = {5, 3, 2}
    local Temp = {
        'P3S2AirDefenceTemp0',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --AA gunships
    }
    local Builder = {
        BuilderName = 'P3S2AirDefenceBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1Defense3'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )

    quantity = {5, 3, 2}
    Temp = {
        'P3S2AirDefenceTemp1',
        'NoPlan',
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --T2 fighter
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --ASFs
    }
    Builder = {
        BuilderName = 'P3S2AirDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 208,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1Defense3'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )

    quantity = {8, 6, 5}
    Temp = {
        'P3S2AirDefenceTemp2',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --gunships
    }
    Builder = {
        BuilderName = 'P3S2AirDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 206,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1Defense1'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )

    quantity = {7, 6, 5}
    Temp = {
        'P3S2AirDefenceTemp3',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --gunships
    }
    Builder = {
        BuilderName = 'P3S2AirDefenceBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1Defense2'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )

    quantity = {8, 7, 6}
    Temp = {
        'P3S2AirAttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --gunships
    }
    Builder = {
        BuilderName = 'P3S2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3S2B1Landattack1', 'P3S2B1Landattack2', 'P3S2B1Landattack3'}
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder ) 
end

function OrderlandAttacks()

    local quantity = {}

    quantity = {8, 7, 6}
    local Temp = {
        'P3SA2LandDefenceTemp0',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --Heavy Tanks
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },   --Mobile-Shields
        { 'ual0205', 1, 2, 'Attack', 'GrowthFormation' },   --Anti-Air Flak
    }
    local Builder = {
        BuilderName = 'P3SA2LandDefenceBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1Defense1'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )
    
    quantity = {10, 9, 8}
    Temp = {
        'P3SA2LandDefenceTemp1',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dalk003', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3SA2LandDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1Defense2'
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )
    
    quantity = {6, 4, 3}
    Temp = {
        'P3SA2LandDefenceTemp2',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3SA2LandDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
            MoveChains = {'P3S2B1Landattack1', 'P3S2B1Landattack2', 'P3S2B1Landattack3'}
        },
    }
    ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )    

    opai = Serabase2:AddOpAI('EngineerAttack', 'M3_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P3S2B1Defense1', 'P3S2B1Defense2'},
        },
        Priority = 115,
    })
    opai:SetChildQuantity('T1Engineers', 5)

    opai = Serabase2:AddOpAI('EngineerAttack', 'M3_West_Reclaim_Engineers2',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P3S2B1Defense1', 'P3S2B1Defense2'},
        },
        Priority = 110,
    })
    opai:SetChildQuantity('T1Engineers', 5)
end
