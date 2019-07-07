local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 2
local UEF = 1

local Difficulty = ScenarioInfo.Options.Difficulty

local UEFnavalbase = BaseManager.CreateBaseManager()
local UEFmainbase = BaseManager.CreateBaseManager()

function UEFnavalbaseAI()

     UEFnavalbase:InitializeDifficultyTables(ArmyBrains[UEF], 'P2UEFBase2', 'Mainnaval', 80, {P2Ubase2 = 100})
     UEFnavalbase:StartNonZeroBase({{10,14,18}, {8,12,16}})

     P2UB2Navalattacks1()
	 P2UB2landattacks1()
	 P2UEXPattacks1()
end

function UEFmainbaseAI()

     UEFmainbase:InitializeDifficultyTables(ArmyBrains[UEF], 'P2UEFBase1', 'UEF', 80, {P2Ubase1 = 100})
     UEFmainbase:StartNonZeroBase({{18,22,26}, {16,20,24}})
     UEFmainbase:SetActive('AirScouting', true)

     P2UB1Airattacks1()
     P2UB1landattacks1()
end

function P2UB2Navalattacks1()

    local Temp = {
       'P1UB2NavalattackTemp0',
       'NoPlan',
       { 'ues0103', 1, 6, 'Attack', 'GrowthFormation' },
       { 'ues0202', 1, 2, 'Attack', 'GrowthFormation' },
       { 'xes0102', 1, 2, 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
       BuilderName = 'P1UB2NavalattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2UB2navalattack1'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
    Temp = {
       'P1UB2NavalattackTemp1',
       'NoPlan',
       { 'ues0201', 1, 4, 'Attack', 'GrowthFormation' }, 
       { 'ues0202', 1, 2, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
       BuilderName = 'P1UB2NavalattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2UB2navalattack1'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1UB2NavalattackTemp2',
       'NoPlan',
       { 'ues0201', 1, 4, 'Attack', 'GrowthFormation' }, 
       { 'ues0302', 1, 1, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
       BuilderName = 'P1UB2NavalattackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2UB2navalattack1'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

end
 
function P2UB2landattacks1()

    local Temp = {
       'P2UB2LandattackTemp0',
       'NoPlan',     
       { 'uel0203', 1, 8, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'P2UB2LandattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase2',       
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2UB2LandattackTemp1',
       'NoPlan',     
       { 'xel0305', 1, 3, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P2UB2LandattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase2',       
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2UB2landattack1', 'P2UB2landattack2'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

end
 
function P2UEXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = UEFnavalbase:AddOpAI('P2Uexp1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'P2UB2navalattack1',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )

end
 
function P2UB1Airattacks1()
   
    local Temp = {
       'P2UB1AirattackTemp0',
       'NoPlan',
       { 'uea0303', 1, 6, 'Attack', 'GrowthFormation' },
       { 'uea0203', 1, 12, 'Attack', 'GrowthFormation' }, 
       { 'uea0305', 1, 6, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'P2UB1AirattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 600,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'UEFMBdefense'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
    Temp = {
       'P2UB1AirattackTemp1',
       'NoPlan',
       { 'uea0305', 1, 3, 'Attack', 'GrowthFormation' },
       { 'uea0203', 1, 12, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P2UB1AirattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase1',       
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2Uairattack1', 'P2Uairattack2', 'P2Uairattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
    Temp = {
       'P2UB1AirattackTemp2',
       'NoPlan',
       { 'uea0303', 1, 6, 'Attack', 'GrowthFormation' },
       { 'dea0202', 1, 6, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P2UB1AirattackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2Uairattack1', 'P2Uairattack2', 'P2Uairattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2UB1AirattackTemp3',
       'NoPlan',
       { 'uea0305', 1, 9, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P2UB1AirattackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2Uairattack1', 'P2Uairattack2', 'P2Uairattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

end
   
function P2UB1landattacks1()
  
    local Temp = {
       'P2UB1LandattackTemp0',
       'NoPlan',     
       { 'uel0205', 1, 4, 'Attack', 'GrowthFormation' },  
       { 'uel0303', 1, 8, 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
       BuilderName = 'P2UB1LandattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase1',       
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
    Temp = {
       'P2UB1LandattackTemp1',
       'NoPlan',
       { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' }, 
       { 'xel0305', 1, 6, 'Attack', 'GrowthFormation' },  
   }
    Builder = {
       BuilderName = 'P2UB1LandattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase1',      
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
       },
   }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
    Temp = {
       'P2UB1LandattackTemp2',
       'NoPlan',
       { 'uel0303', 1, 8, 'Attack', 'GrowthFormation' }, 
       { 'xel0305', 1, 2, 'Attack', 'GrowthFormation' },  
   }
    Builder = {
       BuilderName = 'P2UB1LandattackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2UB1landattack1', 'P2UB1landattack2'}
       },
   }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
end
  
 