local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

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
        'LandDefenceTemp2',
        'NoPlan',
        { 'ual0202', 1, 10, 'Attack', 'GrowthFormation' },  --Heavy Tanks
	}
	local Builder = {
        BuilderName = 'LandDefenceBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
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
        'LandDefenceTemp3',
        'NoPlan',
        { 'ual0205', 1, 6, 'Attack', 'GrowthFormation' },  --Heavy Tanks
	}
	Builder = {
        BuilderName = 'LandDefenceBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Orderbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3S2B1defence2'
        },
	}
	ArmyBrains[SeraphimAlly2]:PBMAddPlatoon( Builder )
	
end

function DisableBase1()
    if(Serabase2) then
        LOG('Serabase2 stopped')
        Serabase2:BaseActive(false)
    end
    for _, platoon in ArmyBrains[SeraphimAlly2]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[SeraphimAlly2]:DisbandPlatoon(platoon)
    end
    LOG('All Platoons of Serabase2 stopped')
end