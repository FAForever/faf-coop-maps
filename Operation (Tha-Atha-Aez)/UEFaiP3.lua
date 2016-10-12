local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player = 1
local UEF = 3


local UEFMbase1 = BaseManager.CreateBaseManager()
local UEFMbase2 = BaseManager.CreateBaseManager()

function UEFmain1AI()
    UEFMbase1:Initialize(ArmyBrains[UEF], 'UEFmmainbase1', 'UEFMain1MK', 80, {UEFmain1 = 100})
    UEFMbase1:StartNonZeroBase({19,17})
    UEFMbase1:SetActive('AirScouting', true)
    UEFMbase1:SetActive('LandScouting', true)

	AirAttacks1()
	LandAttacks1()
end

function UEFmain2AI()
    UEFMbase2:Initialize(ArmyBrains[UEF], 'UEFmmainbase2', 'UEFMain2MK', 80, {UEFmain2 = 100})
    UEFMbase2:StartNonZeroBase({19,17})
    UEFMbase2:SetActive('AirScouting', true)
    UEFMbase2:SetActive('LandScouting', true)

	AirAttacks2()
	LandAttacks2()
end

function AirAttacks2()
   local Temp = {
        'UEFairattackTemp1',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },  --Heavy Gunships
	    { 'uea0303', 1, 8, 'Attack', 'GrowthFormation' },  --ASFs
	}
	local Builder = {
        BuilderName = 'UEFairattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFairattack1', 'P3UEFairattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'UEFairattackTemp5',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },  --Heavy Gunships
        { 'uea0203', 1, 12, 'Attack', 'GrowthFormation' },  --Gunships
	    { 'uea0303', 1, 6, 'Attack', 'GrowthFormation' },  --ASFs
	}
	Builder = {
        BuilderName = 'UEFairattackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFairattack1', 'P3UEFairattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFairattackTemp6',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },  --Heavy Gunships
	    { 'uea0303', 1, 12, 'Attack', 'GrowthFormation' },  --ASFs
	}
    Builder = {
        BuilderName = 'UEFairattackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFairattack1', 'P3UEFairattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFairattackTemp7',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },  --Heavy Gunships
	    { 'uea0304', 1, 6, 'Attack', 'GrowthFormation' },  --Stat Bomber
	}
    Builder = {
        BuilderName = 'UEFairattackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFairattack1', 'P3UEFairattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function LandAttacks2()
    local Temp = {
        'UEFLandattackTemp1',
        'NoPlan',
        { 'xel0305', 1, 6, 'Attack', 'GrowthFormation' },  --Heavy bot
        { 'uel0303', 1, 12, 'Attack', 'GrowthFormation' },  --Seige bots
        { 'delk002', 1, 3, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'UEFLandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFlandattack1', 'P3UEFlandattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	 Temp = {
        'UEFLandattackTemp3',
        'NoPlan',
        { 'uel0202', 1, 18, 'Attack', 'GrowthFormation' },  --Strat bomders
	    { 'uel0303', 1, 12, 'Attack', 'GrowthFormation' },  --ASFs
	}
	Builder = {
        BuilderName = 'UEFLandattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFlandattack1', 'P3UEFlandattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFLandattackTemp4',
        'NoPlan',
	    { 'uel0303', 1, 18, 'Attack', 'GrowthFormation' },  --Seige bots
	}
	Builder = {
        BuilderName = 'UEFLandattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFlandattack1', 'P3UEFlandattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFLandattackTemp5',
        'NoPlan',
        { 'uel0202', 1, 18, 'Attack', 'GrowthFormation' },  --Heavy Tanks
	    { 'uel0307', 1, 6, 'Attack', 'GrowthFormation' },  --mobile sheild
	    { 'uel0203', 1, 6, 'Attack', 'GrowthFormation' }, --Amphous unit
	}
	Builder = {
        BuilderName = 'UEFLandattackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFlandattack1', 'P3UEFlandattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function AirAttacks1()
    local Temp = {
        'UEFairattackTemp2',
        'NoPlan',
        { 'uea0305', 1, 8, 'Attack', 'GrowthFormation' },  --Heavy Gunships
        { 'uea0304', 1, 4, 'Attack', 'GrowthFormation' },  --Strat bomders
	    { 'uea0303', 1, 4, 'Attack', 'GrowthFormation' },  --ASFs
	}
	local Builder = {
        BuilderName = 'UEFairattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFairattack3', 'P3UEFairattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFairattackTemp3',
        'NoPlan',
        { 'uea0305', 1, 8, 'Attack', 'GrowthFormation' },  --Heavy Gunships
	    { 'uea0303', 1, 4, 'Attack', 'GrowthFormation' },  --ASFs
	}
	Builder = {
        BuilderName = 'UEFairattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFairattack3', 'P3UEFairattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFairattackTemp4',
        'NoPlan',
        { 'uea0305', 1, 12, 'Attack', 'GrowthFormation' },  --Heavy Gunships
	    { 'uea0203', 1, 16, 'Attack', 'GrowthFormation' },  --Gunships
	}
	Builder = {
        BuilderName = 'UEFairattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFairattack3', 'P3UEFairattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function LandAttacks1()
     local Temp = {
        'UEFLandattackTemp2',
        'NoPlan',
        { 'xel0305', 1, 6, 'Attack', 'GrowthFormation' },  --Heavy bot
	    { 'uel0303', 1, 12, 'Attack', 'GrowthFormation' },  --Seige bots
	    { 'delk002', 1, 3, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'UEFLandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFlandattack3', 'P3UEFlandattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFLandattackTemp6',
        'NoPlan',
        { 'uel0202', 1, 18, 'Attack', 'GrowthFormation' },  --Strat bomders
	    { 'uel0303', 1, 12, 'Attack', 'GrowthFormation' },  --ASFs
	}
	Builder = {
        BuilderName = 'UEFLandattackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFlandattack3', 'P3UEFlandattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFLandattackTemp7',
        'NoPlan',
	    { 'uel0303', 1, 18, 'Attack', 'GrowthFormation' },  --Seige bots
	}
	Builder = {
        BuilderName = 'UEFLandattackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFlandattack3', 'P3UEFlandattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'UEFLandattackTemp8',
        'NoPlan',
        { 'uel0202', 1, 18, 'Attack', 'GrowthFormation' },  --Heavy Tanks
	    { 'uel0307', 1, 6, 'Attack', 'GrowthFormation' },  --mobile sheild
	    { 'uel0203', 1, 6, 'Attack', 'GrowthFormation' }, --Amphous unit
	}
	Builder = {
        BuilderName = 'UEFLandattackBuilder8',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UEFlandattack3', 'P3UEFlandattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function DisableBase()
    if(UEFMbase1) then
        LOG('UEFMbase1 stopped')
        UEFMbase1:BaseActive(false)
    end
    for _, platoon in ArmyBrains[UEF]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[UEF]:DisbandPlatoon(platoon)
    end
    LOG('All Platoons of UEFMbase1 stopped')
end

function DisableBase2()
    if(UEFMbase2) then
        LOG('UEFMbase2 stopped')
        UEFMbase2:BaseActive(false)
    end
    for _, platoon in ArmyBrains[UEF]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[UEF]:DisbandPlatoon(platoon)
    end
    LOG('All Platoons of UEFMbase2 stopped')
end