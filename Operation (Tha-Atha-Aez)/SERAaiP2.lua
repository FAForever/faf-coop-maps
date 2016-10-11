local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player = 1
local SeraphimAlly = 2


local Serabase = BaseManager.CreateBaseManager()

function SeraphimBaseAI()
	Serabase:Initialize(ArmyBrains[SeraphimAlly], 'Seraphimbase', 'SeraphimBaseMK', 60, {Serabase1 = 100})
    Serabase:StartNonZeroBase({11,7})
	
	SeraAirPatrols()
	SeraLandPatrols()
end

function SeraAirPatrols()
	local Temp = {
       'AirDefenceTemp1',
       'NoPlan',
       { 'xsa0202', 1, 6, 'Attack', 'GrowthFormation' },  --Fighter/bombers
       { 'xsa0203', 1, 9, 'Attack', 'GrowthFormation' },  --Gunships
	   { 'xsa0303', 1, 3, 'Attack', 'GrowthFormation' },  --ASFs
	}
	local Builder = {
       BuilderName = 'AirDefenceBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 400,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Seraphimbase',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2SeraDchain1'
       },
	}
	ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )
end

function SeraLandPatrols()
	local Temp = {
        'landDefenceTemp1',
        'NoPlan',
        { 'xsl0202', 1, 8, 'Attack', 'GrowthFormation' },  --Assault bots
	    { 'xsl0303', 1, 2, 'Attack', 'GrowthFormation' },  --Seige Tanks
	}
	local Builder = {
        BuilderName = 'landDefenceBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2SeraDchain2'
        },
	}
	ArmyBrains[SeraphimAlly]:PBMAddPlatoon( Builder )
	
	opai = Serabase:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P2SeraDchain2'},
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T2Engineers', 4)
	
	opai = Serabase:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers1',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P2SeraDchain2'},
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T2Engineers', 4)
end