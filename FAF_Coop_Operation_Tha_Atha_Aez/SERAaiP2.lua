local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local SeraphimAlly = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local Serabase = BaseManager.CreateBaseManager()

function SeraphimBaseAI()
	Serabase:InitializeDifficultyTables(ArmyBrains[SeraphimAlly], 'Seraphimbase', 'SeraphimBaseMK', 80, {Serabase1 = 400})
    Serabase:StartNonZeroBase({{15,12,9}, {12,10,7}})
	
	SeraAirPatrols()
	SeraLandPatrols()
	
end

function SeraAirPatrols()

	local Temp = {
       'Sera1AirDefenceTemp1',
       'NoPlan',
       { 'xsa0202', 1, 6, 'Attack', 'GrowthFormation' },
       { 'xsa0203', 1, 9, 'Attack', 'GrowthFormation' },
	   { 'xsa0303', 1, 3, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
       BuilderName = 'Sera1AirDefenceBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2S1B1defence1'
       },
	}
	ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )
	
	Temp = {
       'Sera1AirDefenceTemp2',
       'NoPlan',
	   { 'xsa0303', 1, 5, 'Attack', 'GrowthFormation' },
	}
	Builder = {
       BuilderName = 'Sera1AirDefenceBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2S1B1defence1'
       },
	}
	ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )
	
end

function SeraLandPatrols()

	local Temp = {
        'SA1landDefenceTemp1',
        'NoPlan',
        { 'xsl0202', 1, 6, 'Attack', 'GrowthFormation' },  --Assault bots
	    { 'xsl0303', 1, 2, 'Attack', 'GrowthFormation' },  --Seige Tanks
	}
	local Builder = {
        BuilderName = 'SA1landDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2S1B1defence2'
        },
	}
	ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )
	
	Temp = {
        'SA1landDefenceTemp2',
        'NoPlan',
        { 'xsl0202', 1, 2, 'Attack', 'GrowthFormation' },  --Assault bots
	    { 'xsl0203', 1, 6, 'Attack', 'GrowthFormation' },  --Hover Tanks
	}
	Builder = {
        BuilderName = 'SA1landDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 130,
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
        Priority = 100,
    })
    opai:SetChildQuantity('T2Engineers', 4)
	
end

