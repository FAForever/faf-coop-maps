local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')


local Player = 1
local Aeon = 4

local AeonNbase2 = BaseManager.CreateBaseManager()
local AeonNbase = BaseManager.CreateBaseManager()
local AeonIbase = BaseManager.CreateBaseManager()

function AeonNavalAI()
    AeonNbase:Initialize(ArmyBrains[Aeon], 'AeonNavalbase', 'AeonNavalMK', 70, {P3AnavalN = 100})
    AeonNbase:StartNonZeroBase({19,17})
    AeonNbase:SetActive('AirScouting', true)
    AeonNbase:SetActive('LandScouting', true)

    AeonNattacks()
end

function AeonIntelAI()
    AeonIbase:Initialize(ArmyBrains[Aeon], 'AeonIntelbase', 'Aeonintelbasemk', 50, {AeonIntel = 100})
    AeonIbase:StartNonZeroBase({4,2})
    AeonIbase:SetActive('AirScouting', true)
    
    AeonIntelattacks()
end

function AeonNaval2AI()
    AeonNbase2:Initialize(ArmyBrains[Aeon], 'AeonNavalbase2', 'AeonNavalbaseMK2', 70, {P3AnavalS = 100})
    AeonNbase2:StartNonZeroBase({19,17})
    AeonNbase2:SetActive('AirScouting', true)

	AeonNattack2()
end

function AeonIntelattacks()
    local Temp = {
        'AeonlandTemp4',
        'NoPlan',
        { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },   --Mobile sheilds
        { 'ual0202', 1, 12, 'Attack', 'GrowthFormation' },  --Heavy Tanks
        { 'ual0303', 1, 4, 'Attack', 'GrowthFormation' }, --Seige Bots
	}
	local Builder = {
        BuilderName = 'AeonlandBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonIntelbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2Aintattack1'
        },
   }
   ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

end

function AeonNattacks()
    local opai = nil
    local Temp = {}
    local Builder = {}

	Temp = {
        'AeonlandTemp1',
        'NoPlan',
        { 'xal0203', 1, 12, 'Attack', 'GrowthFormation' },   --Hover tanks
        { 'ual0205', 1, 5, 'Attack', 'GrowthFormation' },  --moble flak
	    { 'ual0307', 1, 5, 'Attack', 'GrowthFormation' },   --Moble shields
	}
	Builder = {
        BuilderName = 'AeonlandBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonNavalbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
                PatrolChain = 'P2Alandattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
   
    Temp = {
        'AeonlandTemp2',
        'NoPlan',
        { 'xal0203', 1, 12, 'Attack', 'GrowthFormation' },  --Hover tanks
        { 'ual0205', 1, 5, 'Attack', 'GrowthFormation' },  --moble flak
        { 'ual0307', 1, 5, 'Attack', 'GrowthFormation' },  --Moble shields
    }
    Builder = {
        BuilderName = 'AeonlandBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonNavalbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2Alandattack2'
        },
    }
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
   
    Temp = {
       'AeonlandTemp3',
       'NoPlan',
        { 'uaa0203', 1, 16, 'Attack', 'GrowthFormation' },  --Gunships
        { 'uaa0303', 1, 9, 'Attack', 'GrowthFormation' },  --ASFs
	    { 'uaa0304', 1, 3, 'Attack', 'GrowthFormation' },  --Stratbombers
	    { 'xaa0202', 1, 8, 'Attack', 'GrowthFormation' },  --Fighters
	}
    Builder = {
        BuilderName = 'AeonlandBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonNavalbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2Aairattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    opai = AeonNbase:AddOpAI('EngineerAttack', 'M2_AEON_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'AeonNavalMK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.uaa0104})
   
    opai = AeonNbase:AddOpAI('BasicLandAttack', 'M2_Aeon_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2Aintattack1', 
                --PatrolChain = 'M2_UEF_Support_Civ_Chain',
                LandingChain = 'AeonattackDrop',
                TransportReturn = 'AeonNavalMK',
            },
            Priority = 550,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 24)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 90})
end

function AeonNattack2()
    local opai = nil
    local Temp = {}
    local Builder = {}

    Temp = {
        'AeonairTemp2',
        'NoPlan',
        { 'xaa0305', 1, 12, 'Attack', 'GrowthFormation' },   --AA Gunships
        { 'uaa0303', 1, 5, 'Attack', 'GrowthFormation' },    --ASF
	    { 'uaa0304', 1, 5, 'Attack', 'GrowthFormation' },    --Moble shields
	}
	Builder = {
        BuilderName = 'AeonairBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonNavalbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3Aairattack1'
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    Temp = {
        'AeonlandTemp2',
        'NoPlan',
        { 'xas0306', 1, 2, 'Attack', 'GrowthFormation' },  --Hover tanks
        { 'uas0202', 1, 4, 'Attack', 'GrowthFormation' },  --moble flak
	}
    Builder = {
        BuilderName = 'AeonlandBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonNavalbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3AnavalAttack'
        },
    }
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
end