local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local SeraphimAlly = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local Serabase = BaseManager.CreateBaseManager()

function SeraphimBaseAI()
    Serabase:InitializeDifficultyTables(ArmyBrains[SeraphimAlly], 'Seraphimbase', 'SeraphimBaseMK', 80, {Serabase1 = 400})
    Serabase:StartNonZeroBase({{14, 11, 8}, {12, 9, 6}})
    
    Serabase:AddBuildGroup('SeraDefenses', 50)

    SeraAirPatrols()
    SeraLandPatrols()   
end

function SeraAirPatrols()

    local quantity = {}

    quantity = {4, 3, 2}
    local Temp = {
        'Sera1AirDefenceTemp1',
        'NoPlan',
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'Sera1AirDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 103,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2S1B1defence1'
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )

    quantity = {4, 3, 2}
    Temp = {
        'Sera1AirDefenceTemp2',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'Sera1AirDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 101,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2S1B1defence2'
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )

    quantity = {4, 3, 2}
    Temp = {
        'Sera1AirDefenceTemp3',
        'NoPlan',
        { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'Sera1AirDefenceBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 102,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2S1B1defence1'
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )

    quantity = {6, 5, 4}
    Temp = {
        'Sera1AirDefenceTemp4',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'Sera1AirDefenceBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2S1B1Attack1', 'P2S1B1Attack2'}
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )
end

function SeraLandPatrols()

    local quantity = {}

    quantity = {5, 4, 2}
    local Temp = {
        'SA1landDefenceTemp1',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --assault bots
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --Seige Tanks
    }
    local Builder = {
        BuilderName = 'SA1landDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2S1B1defence2'
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )

    quantity = {6, 5, 4}
    local Temp = {
        'SA1landDefenceTemp2',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --assault bots
    }
    local Builder = {
        BuilderName = 'SA1landDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2S1B1defence2'
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )

    quantity = {5, 4, 3}
    Temp = {
        'SA1landDefenceTemp3',
        'NoPlan',
        { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --flak
    }
    Builder = {
        BuilderName = 'SA1landDefenceBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 103,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2S1B1defence2'
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )
    
    opai = Serabase:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P2S1B1defence1', 'P2S1B1defence2'},
        },
        Priority = 115,
    })
    opai:SetChildQuantity('T1Engineers', 6)

    opai = Serabase:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers2',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P2S1B1defence1', 'P2S1B1defence2'},
        },
        Priority = 110,
    })
    opai:SetChildQuantity('T1Engineers', 6)

    quantity = {8, 6, 4}
    Temp = {
        'SA1landAttackTemp0',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --Assaultbots
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --tanks
    }
    Builder = {
        BuilderName = 'SA1landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2S1B1Attack1', 'P2S1B1Attack2'}
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )

    quantity = {6, 5, 3}
    Temp = {
        'SA1landAttackTemp1',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --SeigeTanks
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  --Assaultbots
    }
    Builder = {
        BuilderName = 'SA1landAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 101,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'Aeon'}, 3, categories.LAND * categories.MOBILE * categories.ARTILLERY}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2S1B1Attack1', 'P2S1B1Attack2'}
        },
    }
    ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )
end
