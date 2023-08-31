local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local Order = 2
local Seraphim = 3
local UEF = 5
local Player2 = 6
local Player3 = 7
local Player3 = 8
local Difficulty = ScenarioInfo.Options.Difficulty

local UEFbase1 = BaseManager.CreateBaseManager()

function UEFbase1AI()
    	
    UEFbase1:Initialize(ArmyBrains[UEF], 'P1UEFbase1', 'P1OB2MK', 90, 
        {
            P1UBase1ECO = 140,
            P1UBase1FAC = 150,
            P1UBase1ECO2 = 120,
            P1UBase1FAC2 = 130,
            P1UBase1Defense = 100,
        }
    )
    UEFbase1:StartEmptyBase({{20, 16, 12}, {16, 12, 8}})
    UEFbase1:SetActive('AirScouting', true)
    UEFbase1:SetMaximumConstructionEngineers(8)

    P1B1ULandattack()
    P1B1UAirattack()
    P1B1UNavalattack()
end

function P1B1ULandattack()

    local quantity = {}
    local trigger = {}
	
    quantity = {5, 4, 3}
	local Temp = {
        'P1UB1LandAttackTemp1',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	     
    }
    local Builder = {
        BuilderName = 'P1UB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Landattack1','P1UB1Landattack2','P1UB1Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {5, 4, 3}
    Temp = {
        'P1UB1LandAttackTemp2',
        'NoPlan',
        { 'del0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },            
    }
    Builder = {
        BuilderName = 'P1UB1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Landattack1','P1UB1Landattack2','P1UB1Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {8, 6, 5}
    trigger = {10, 8, 6}
    Temp = {
        'P1UB1LandAttackTemp3',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1UB1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'UEF'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Landattack1','P1UB1Landattack2','P1UB1Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    opai = UEFbase1:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1UB1Landattack1','P1UB1Landattack2'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end	

function P1B1UAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {7, 6, 5}
    local Temp = {
       'P1UB1AirAttackTemp0',
       'NoPlan',         
       { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P1UB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1UEFbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1AirDefense'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {5, 4, 3}
    Temp = {
       'P1UB1AirAttackTemp1',
       'NoPlan',
       { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
       BuilderName = 'P1UB1AirAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 490,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1UEFbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1AirDefense'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 3, 2}
    Temp = {
       'P1UB1AirAttackTemp2',
       'NoPlan',
       { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P1UB1AirAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 480,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1UEFbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1AirDefense'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {7, 5, 3}
    Temp = {
        'P1UB1AirAttackTemp3',
        'NoPlan',
        { 'uea0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1UB1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1','P1UB1Airattack2','P1UB1Airattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {7, 5, 3}
    Temp = {
        'P1UB1AirAttackTemp4',
        'NoPlan',
        { 'uea0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1UB1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1','P1UB1Airattack2','P1UB1Airattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1B1UNavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {5, 4, 3}
    local Temp = {
        'P1UB1NavalAttackTemp0',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB1NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Navalattack1',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 5, 4}
    Temp = {
        'P1UB1NavalAttackTemp1',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1UB1NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Navalattack1',
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {4, 3, 2}
    Temp = {
        'P1UB1NavalAttackTemp2',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1UB1NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Navalattack1',
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function ExpandBase()

    UEFbase1:AddBuildGroup('P2Def1', 90, false)
    UEFbase1:AddBuildGroup('P2Def2', 80, false)
end

function P2B1ULandattack()

    local quantity = {}
    local trigger = {}
    
    quantity = {8, 7, 6}
    local Temp = {
        'P2UB1LandAttackTemp1',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    local Builder = {
        BuilderName = 'P2UB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Landattack1','P1UB1Landattack2','P1UB1Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 5, 4}
    trigger = {10, 8, 6}
    Temp = {
        'P2UB1LandAttackTemp2',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2UB1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'UEF'}, trigger[Difficulty], categories.DEFENSE * categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Landattack1','P1UB1Landattack2','P1UB1Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end 

function P2B1UAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {8, 6, 4}
    local Temp = {
        'P2UB1AirAttackTemp0',
        'NoPlan',
        { 'dea0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0303', 1, 2, 'Attack', 'GrowthFormation' },         
    }
    local Builder = {
        BuilderName = 'P2UB1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1','P1UB1Airattack2','P1UB1Airattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {8, 6, 4}
    Temp = {
        'P2UB1AirAttackTemp1',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0305', 1, 2, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2UB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1','P1UB1Airattack2','P1UB1Airattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P2B1UNavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {4, 3, 2}
    local Temp = {
        'P2UB1NavalAttackTemp0',
        'NoPlan',
        { 'ues0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
        { 'ues0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ues0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2UB1NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Navalattack1',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {6, 4, 3}
    Temp = {
        'P2UB1NavalAttackTemp1',
        'NoPlan',
        { 'ues0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xes0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2UB1NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 205,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1UB1Navalattack1',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function ExpandBase2()

    UEFbase1:AddBuildGroup('P3UBase1', 250, false)

    P3B1ULandattack()
    P3B1UAirattack()
    P3UEXPattacks()
end

function P3B1ULandattack()

    local quantity = {}
    local trigger = {}
    
    quantity = {6, 5, 4}
    local Temp = {
        'P3UB1LandAttackTemp1',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    local Builder = {
        BuilderName = 'P3UB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Landattack1','P1UB1Landattack2','P1UB1Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end 

function P3B1UAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {7, 6, 5}
    local Temp = {
       'P3UB1AirAttackTemp0',
       'NoPlan',         
       { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uea0305', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P3UB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 510,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1UEFbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1AirDefense'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {8, 6, 4}
    quantity2 = {16, 12, 8}
    Temp = {
        'P3UB1AirAttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },            
    }
    Builder = {
        BuilderName = 'P3UB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 305,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1','P1UB1Airattack2','P1UB1Airattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {8, 6, 4}
    quantity2 = {16, 12, 8}
    Temp = {
        'P3UB1AirAttackTemp2',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uea0203', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },           
    }
    Builder = {
        BuilderName = 'P3UB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1UB1Airattack1','P1UB1Airattack2','P1UB1Airattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P3UEXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {4, 3, 2}
    opai = UEFbase1:AddOpAI('Fatboy',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P1UB1Landattack1','P1UB1Landattack2','P1UB1Landattack3'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    ) 
end