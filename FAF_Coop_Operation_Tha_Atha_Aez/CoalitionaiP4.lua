local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/faf_coop_operation_tha_atha_aez.v0011/FAF_Coop_Operation_Tha_Atha_Aez_CustomFunctions.lua' 

local Aeon = 4
local UEF = 3
local Player1 = 1

local Difficulty = ScenarioInfo.Options.Difficulty

local P4ABase1 = BaseManager.CreateBaseManager()
local P4UBase1 = BaseManager.CreateBaseManager()

function P4ABase1AI()
    P4ABase1:InitializeDifficultyTables(ArmyBrains[Aeon], 'P4Aeonbase', 'P4AB1MK', 60, {P4ABase = 300})
    P4ABase1:StartNonZeroBase({{11,13,15}, {8,11,13}})

    P4AB1landattacks()
	P4AB1Airattacks()
end

function P4UBase1AI()
    P4UBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFbase', 'P4UB1MK', 60, {P4UBase1 = 300})
    P4UBase1:StartNonZeroBase({{8,10,12}, {6,8,10}})
    
	P4UB1landattacks()
	P4UB1Airattacks()
end

function P4AB1landattacks()
   
    local Temp = {
        'P4AB1LandattackTemp0',
        'NoPlan',
        { 'xal0203', 1, 10, 'Attack', 'GrowthFormation' },
		{ 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P4AB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4AB1landattack1', 'P4AB1landattack2', 'P4AB1landattack3'}
        },
	}
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4AB1LandattackTemp1',
        'NoPlan',
        { 'xal0203', 1, 6, 'Attack', 'GrowthFormation' },
		{ 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
		{ 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P4AB1LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4AB1landattack1', 'P4AB1landattack2', 'P4AB1landattack3'}
        },
	}
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4AB1LandattackTemp2',
        'NoPlan',
        { 'xal0203', 1, 6, 'Attack', 'GrowthFormation' },
		{ 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
		{ 'dal0310', 1, 4, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P4AB1LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4AB1landattack1', 'P4AB1landattack2', 'P4AB1landattack3'}
        },
	}
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4AB1LandattackTemp3',
        'NoPlan',
        { 'xal0203', 1, 4, 'Attack', 'GrowthFormation' },
		{ 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
		{ 'dal0310', 1, 6, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P4AB1LandattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4AB1landattack1', 'P4AB1landattack2', 'P4AB1landattack3'}
        },
	}
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
end

function P4AB1Airattacks()

    local Temp = {
        'P4AB1airattackTemp0',
        'NoPlan',
        { 'uaa0303', 1, 9, 'Attack', 'AttackFormation' },
	}
	local Builder = {
        BuilderName = 'P4AB1airattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4AB1Airattack1', 'P4AB1Airattack2', 'P4AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4AB1airattackTemp1',
        'NoPlan',
        { 'uaa0304', 1, 9, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P4AB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4AB1Airattack1', 'P4AB1Airattack2', 'P4AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4AB1airattackTemp2',
        'NoPlan',
        { 'xaa0305', 1, 9, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P4AB1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4AB1Airattack1', 'P4AB1Airattack2', 'P4AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4AB1airattackTemp3',
        'NoPlan',
        { 'uaa0203', 1, 18, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P4AB1airattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4Aeonbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4AB1Airattack1', 'P4AB1Airattack2', 'P4AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

end

function P4UB1landattacks()
   
    local Temp = {
        'P4UB1LandattackTemp0',
        'NoPlan',
        { 'uel0203', 1, 12, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P4UB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4UB1Landattack1', 'P4UB1Landattack2', 'P4UB1Landattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4UB1LandattackTemp1',
        'NoPlan',
        { 'xel0305', 1, 8, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P4UB1LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4UB1Landattack1', 'P4UB1Landattack2', 'P4UB1Landattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

end

function P4UB1Airattacks()

    local Temp = {
        'P4UB1AirattackTemp0',
        'NoPlan',
        { 'uea0303', 1, 6, 'Attack', 'AttackFormation' },
	}
	local Builder = {
        BuilderName = 'P4UB1AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Airattack1', 'P4UB1Airattack2', 'P4UB1Airattack3', 'P4UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4UB1AirattackTemp1',
        'NoPlan',
        { 'uea0304', 1, 6, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P4UB1AirattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Airattack1', 'P4UB1Airattack2', 'P4UB1Airattack3', 'P4UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4UB1AirattackTemp2',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P4UB1AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Airattack1', 'P4UB1Airattack2', 'P4UB1Airattack3', 'P4UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P4UB1AirattackTemp3',
        'NoPlan',
        { 'uea0203', 1, 16, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P4UB1AirattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P4UEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P4UB1Airattack1', 'P4UB1Airattack2', 'P4UB1Airattack3', 'P4UB1Airattack4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
end






