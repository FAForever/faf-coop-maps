local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local UEF = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local UEFMbase1 = BaseManager.CreateBaseManager()
local UEFMbase2 = BaseManager.CreateBaseManager()
local UEFMbase3 = BaseManager.CreateBaseManager()

function UEFmain1AI()
    UEFMbase1:InitializeDifficultyTables(ArmyBrains[UEF], 'UEFmmainbase1', 'P3UB1MK', 80, {P3UBase1 = 300})
    UEFMbase1:StartNonZeroBase({{12,16,20}, {9,13,17}})

	AirAttacks1()
	LandAttacks1()
	EXpattacks1()
end

function UEFmain2AI()
    UEFMbase2:InitializeDifficultyTables(ArmyBrains[UEF], 'UEFmmainbase2', 'P3UB2MK', 80, {P3UBase2 = 300})
    UEFMbase2:StartNonZeroBase({{14,18,22}, {12,16,20}})

	AirAttacks2()
	LandAttacks2()
end

function UEFmain3AI()
    UEFMbase3:InitializeDifficultyTables(ArmyBrains[UEF], 'UEFmmainbase3', 'P3UB3MK', 80, {P3UBase3 = 300})
    UEFMbase3:StartNonZeroBase({{7,10,13}, {6,9,12}})

	NavalAttacks1()
end

function AirAttacks2()

     local Temp = {
        'P3UB2AirattackTemp0',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P3UB2AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3UB2AirattackTemp1',
        'NoPlan',
        { 'uea0203', 1, 18, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB2AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3UB2AirattackTemp2',
        'NoPlan',
        { 'uea0303', 1, 6, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB2AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3UB2AirattackTemp3',
        'NoPlan',
        { 'uea0304', 1, 6, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB2AirattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1Airattack1', 'P3UB1Airattack2', 'P3UB1Airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
end

function LandAttacks2()

    local Temp = {
        'P3UB2LandattackTemp1',
        'NoPlan',
        { 'xel0305', 1, 6, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P3UB2LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1landattack1', 'P3UB1landattack2', 'P3UB1landattack3', 'P3UB1landattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	 Temp = {
        'P3UB2LandattackTemp2',
        'NoPlan',
	    { 'uel0303', 1, 12, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB2LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1landattack1', 'P3UB1landattack2', 'P3UB1landattack3', 'P3UB1landattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P3UB2LandattackTemp3',
        'NoPlan',
	    { 'uel0304', 1, 3, 'Attack', 'GrowthFormation' },
		{ 'uel0303', 1, 6, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB2LandattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1landattack1', 'P3UB1landattack2', 'P3UB1landattack3', 'P3UB1landattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P3UB2LandattackTemp4',
        'NoPlan',
        { 'uel0303', 1, 9, 'Attack', 'GrowthFormation' },
		{ 'xel0305', 1, 3, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB2LandattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1landattack1', 'P3UB1landattack2', 'P3UB1landattack3', 'P3UB1landattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3UB2LandattackTemp5',
        'NoPlan',
        { 'uel0205', 1, 9, 'Attack', 'GrowthFormation' },
		{ 'uel0307', 1, 3, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB2LandattackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1landattack1', 'P3UB1landattack2', 'P3UB1landattack3', 'P3UB1landattack4'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
end

function AirAttacks1()

    local Temp = {
        'P3UB1airattackTemp1',
        'NoPlan',
        { 'uea0304', 1, 4, 'Attack', 'AttackFormation' },  --Strat bomders
	    { 'uea0303', 1, 8, 'Attack', 'AttackFormation' },  --ASFs
	}
	local Builder = {
        BuilderName = 'P3UB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Airattack1', 'P3UB2Airattack2', 'P3UB2Airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P3UB1airattackTemp2',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'AttackFormation' },  --Heavy Gunships
	    { 'uea0203', 1, 12, 'Attack', 'AttackFormation' },  --ASFs
	}
	Builder = {
        BuilderName = 'P3UB1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Airattack1', 'P3UB2Airattack2', 'P3UB2Airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P3UB1airattackTemp3',
        'NoPlan',
        { 'uea0305', 1, 12, 'Attack', 'AttackFormation' },  --Heavy Gunships
	}
	Builder = {
        BuilderName = 'P3UB1airattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2Airattack1', 'P3UB2Airattack2', 'P3UB2Airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function LandAttacks1()

     local Temp = {
        'P3UB1LandattackTemp1',
        'NoPlan',
        { 'xel0305', 1, 10, 'Attack', 'GrowthFormation' },
	    { 'delk002', 1, 2, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P3UB1LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2landattack1', 'P3UB2landattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P3UB1LandattackTemp2',
        'NoPlan',
        { 'uel0307', 1, 4, 'Attack', 'GrowthFormation' },
	    { 'uel0303', 1, 11, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB1LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2landattack1', 'P3UB2landattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P3UB1LandattackTemp3',
        'NoPlan',
	    { 'uel0303', 1, 15, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB1LandattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2landattack1', 'P3UB2landattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P3UB1LandattackTemp4',
        'NoPlan',
        { 'uel0202', 1, 15, 'Attack', 'GrowthFormation' },
	    { 'uel0307', 1, 5, 'Attack', 'GrowthFormation' },
	    { 'uel0205', 1, 5, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB1LandattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2landattack1', 'P3UB2landattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function NavalAttacks1()

    local Temp = {
        'P3UB3LandattackTemp1',
        'NoPlan',
        { 'ues0201', 1, 2, 'Attack', 'GrowthFormation' },
	    { 'ues0202', 1, 2, 'Attack', 'GrowthFormation' },
		{ 'ues0302', 1, 1, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P3UB3LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB3Navalattack1', 'P3UB3Navalattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3UB3LandattackTemp2',
        'NoPlan',
        { 'ues0201', 1, 3, 'Attack', 'GrowthFormation' },
	    { 'ues0202', 1, 5, 'Attack', 'GrowthFormation' },
		{ 'ues0203', 1, 5, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3UB3LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'UEFmmainbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB3Navalattack1', 'P3UB3Navalattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
end

function EXpattacks1()
    local opai = nil
    local quantity = {}
    
    opai = UEFMbase1:AddOpAI('Fatboy',
        {
            Amount = 2,
            KeepAlive = true,
           PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB2landattack1', 'P3UB2landattack2'}
        },
            MaxAssist = 4,
            Retry = true,
        }
    )

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