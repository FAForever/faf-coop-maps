local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local UEF = 3
local Player1 = 1
local Difficulty = ScenarioInfo.Options.Difficulty

local UEFbase1 = BaseManager.CreateBaseManager()
local UEFbase2 = BaseManager.CreateBaseManager()
local UEFbase3 = BaseManager.CreateBaseManager()

function UEFNbaseAI()
	UEFbase1:InitializeDifficultyTables(ArmyBrains[UEF], 'NorthUEFbase', 'P2UB1MK', 60, {P2UBase1 = 100})
    UEFbase1:StartNonZeroBase({{7,12,17}, {5,10,15}})
    UEFbase1:SetActive('AirScouting', true)
    UEFbase1:SetActive('LandScouting', true)
 
	P1UB1landAttacks()
	P1UB1Airattacks()
end
 
function UEFSbaseAI()
	UEFbase2:InitializeDifficultyTables(ArmyBrains[UEF], 'SouthUEFbase1', 'P2UB2MK', 60, {P2UBase2 = 100})
    UEFbase2:StartNonZeroBase({{8,14,20}, {6,12,18}})
    UEFbase2:SetActive('AirScouting', true)
 
	P1UB2landattacks()
end
 
function UEFS2baseAI()
	UEFbase3:InitializeDifficultyTables(ArmyBrains[UEF], 'SouthUEFbase2', 'P2UB3MK', 60, {P2UBase3 = 100})
    UEFbase3:StartNonZeroBase({{8,12,16}, {6,10,14}})
    UEFbase3:SetActive('AirScouting', true)
 
	P1UB3Airattacks()
end
 
function P1UB1landAttacks()

	local Temp = {
        'P2UB1LandAttackTemp1',
        'NoPlan',
        { 'xel0305', 1, 5, 'Attack', 'GrowthFormation' },  
        { 'uel0205', 1, 3, 'Attack', 'GrowthFormation' },    
	}
	local Builder = {
        BuilderName = 'P2UB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'NorthUEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2UB1LandAttackTemp2',
        'NoPlan',
        { 'uel0303', 1, 6, 'Attack', 'GrowthFormation' },  
        { 'uel0202', 1, 9, 'Attack', 'GrowthFormation' },  
	}
    Builder = {
        BuilderName = 'P2UB1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'NorthUEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2UB1LandAttackTemp3',
        'NoPlan',
        { 'uel0304', 1, 2, 'Attack', 'GrowthFormation' },  --heavy bots
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },  --Moblesheild
	}
    Builder = {
        BuilderName = 'P2UB1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'NorthUEFbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
 end
 
function P1UB1Airattacks()
	local Temp = {
        'P2UB1AirAttackTemp1',
        'NoPlan',
        { 'uea0203', 1, 12, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P2UB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'NorthUEFbase',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1airattack1', 'P2UB1airattack2', 'P2UB1airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2UB1AirAttackTemp2',
        'NoPlan',
        { 'dea0202', 1, 6, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P2UB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'NorthUEFbase',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1airattack1', 'P2UB1airattack2', 'P2UB1airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2UB1AirAttackTemp3',
        'NoPlan',
        { 'dea0202', 1, 4, 'Attack', 'GrowthFormation' },
		{ 'uea0203', 1, 6, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P2UB1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'NorthUEFbase',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2UB1airattack1', 'P2UB1airattack2', 'P2UB1airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P2UB1AirAttackTemp0',
        'NoPlan',
        { 'dea0202', 1, 5, 'Attack', 'GrowthFormation' },  --Fighter/Bombers
        { 'uea0203', 1, 6, 'Attack', 'GrowthFormation' },  --Gunships
	}
	Builder = {
        BuilderName = 'P2UB1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'NorthUEFbase',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2UB1Defence1'
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
 end
 
function P1UB2landattacks()

	local Temp = {
        'P1UB2LandAttackTemp1',
        'NoPlan',
        { 'uel0202', 1, 8, 'Attack', 'GrowthFormation' }, 
        { 'uel0111', 1, 4, 'Attack', 'GrowthFormation' }, 
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P1UB2LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'SouthUEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P1UB2LandAttackTemp2',
        'NoPlan',
        { 'uel0303', 1, 9, 'Attack', 'GrowthFormation' }, 
        { 'uel0307', 1, 3, 'Attack', 'GrowthFormation' }, 
	}
	Builder = {
        BuilderName = 'P1UB2LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'SouthUEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2'}
        },
    }
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P1UB2LandAttackTemp3',
        'NoPlan',
        { 'uel0303', 1, 6, 'Attack', 'GrowthFormation' },
        { 'uel0304', 1, 2, 'Attack', 'GrowthFormation' }, 
	}
	Builder = {
        BuilderName = 'P1UB2LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'SouthUEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2'}
        },
    }
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
 end
 
function P1UB3Airattacks()
 
	local Temp = {
        'P2UB3AirAttackTemp1',
        'NoPlan',
        { 'uea0203', 1, 12, 'Attack', 'GrowthFormation' }, 
	    { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },  
	}
	local Builder = {
        BuilderName = 'P2UB3AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'SouthUEFbase2',
         PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB3airattack1', 'P2UB3airattack2', 'P2UB3airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2UB3AirAttackTemp2',
        'NoPlan',
        { 'dea0202', 1, 8, 'Attack', 'GrowthFormation' },
	    { 'uea0303', 1, 6, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P2UB3AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'SouthUEFbase2',
         PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2UB3airattack1', 'P2UB3airattack2', 'P2UB3airattack3'}
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

	Temp = {
        'P2UB3AirAttackTemp3',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },  --ASFs
        { 'uea0203', 1, 12, 'Attack', 'GrowthFormation' },  --Gunships
	    { 'uea0303', 1, 9, 'Attack', 'GrowthFormation' },  --Hev Gunships
	}
	Builder = {
        BuilderName = 'P2UB3AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'SouthUEFbase2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2UB2Defence1'
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    Temp = {
        'P2UB3AirAttackTemp4',
        'NoPlan',
        { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },  --ASFs
        { 'uea0203', 1, 9, 'Attack', 'GrowthFormation' },  --Gunships
	    { 'uea0303', 1, 6, 'Attack', 'GrowthFormation' },  --Hev Gunships
	}
	Builder = {
        BuilderName = 'P2UB3AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'SouthUEFbase2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P2UB3Defence1'
        },
	}
	ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end