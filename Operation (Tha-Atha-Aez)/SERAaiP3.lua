local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player = 1
local SeraphimAlly2 = 6


local Serabase2 = BaseManager.CreateBaseManager()

function OrderBaseAI()
	Serabase2:Initialize(ArmyBrains[SeraphimAlly2], 'Orderbase', 'OrderBaseMK', 60, {AeonbaseAlly2 = 100})
    Serabase2:StartNonZeroBase({12,8})
    Serabase2:SetActive('AirScouting', true)
    Serabase2:SetActive('LandScouting', true)

	OrderlandAttacks()
	OrderAirAttacks()
end

function OrderAirAttacks()
    local Temp = {
        'AirDefenceTemp2',
        'NoPlan',
        { 'xaa0305', 1, 4, 'Attack', 'GrowthFormation' },  --AA gunships
        { 'uaa0203', 1, 12, 'Attack', 'GrowthFormation' },  --Gunships
	    { 'uaa0303', 1, 6, 'Attack', 'GrowthFormation' },  --ASFs
	}
	local Builder = {
        BuilderName = 'AirDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3seraDefendchain'
        },
	}
	ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )
end

function OrderlandAttacks()
    local Temp = {
        'LandDefenceTemp2',
        'NoPlan',
        { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },  --mobile Flak
        { 'ual0202', 1, 12, 'Attack', 'GrowthFormation' },  --Heavy Tanks
	    { 'ual0303', 1, 6, 'Attack', 'GrowthFormation' },  --Seige Bots
	}
	local Builder = {
        BuilderName = 'LandDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3seraDefendchain'
        },
	}
	ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )
end