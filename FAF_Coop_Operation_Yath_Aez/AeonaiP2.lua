local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local Aeon = 4

local Difficulty = ScenarioInfo.Options.Difficulty

local Aeonbase1 = BaseManager.CreateBaseManager()
local Aeonbase2 = BaseManager.CreateBaseManager()

function Aeonbase1AI()

    Aeonbase1:InitializeDifficultyTables(ArmyBrains[Aeon], 'Aeonbase1', 'P2AB1MK', 70, {P2Abase1 = 100})
    Aeonbase1:StartNonZeroBase({{13,17,21}, {8,12,16}})
    Aeonbase1:SetActive('AirScouting', true)

	P2AB1landattacks1()
	P2AB1Airattacks1()
	P2AB1EXPattacks1()
	
end

function P2AB1landattacks1()

  local Temp = {
       'A_landAttackTemp1',
       'NoPlan',
       { 'ual0304', 1, 4, 'Attack', 'GrowthFormation' },   
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
	   { 'ual0205', 1, 2, 'Attack', 'GrowthFormation' },
	   }
  local Builder = {
        BuilderName = 'A_landAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2AB1landattack1'
       },
   }
   ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	 Temp = {
       'A_landAttackTemp2',
       'NoPlan',
       { 'ual0202', 1, 12, 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },   
	   }
      Builder = {
        BuilderName = 'A_landAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2AB1landattack1'
       },
   }
   ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
   
   Temp = {
       'A_landAttackTemp3',
       'NoPlan',
       { 'ual0111', 1, 6, 'Attack', 'GrowthFormation' },
       { 'Dal0310', 1, 4, 'Attack', 'GrowthFormation' },
	   }
      Builder = {
        BuilderName = 'A_landAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2AB1landattack1'
       },
   }
   ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
end

function P2AB1Airattacks1()
  
  local Temp = {
       'A_AirAttackTemp1',
       'NoPlan',
       { 'uaa0203', 1, 9, 'Attack', 'GrowthFormation' },
       { 'xaa0202', 1, 5, 'Attack', 'GrowthFormation' }, 
   }
  local Builder = {
       BuilderName = 'A_AirAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Aeonbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
       },
   }
   ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
   
   local Temp = {
       'A_AirAttackTemp2',
       'NoPlan',
       { 'xaa0202', 1, 3, 'Attack', 'GrowthFormation' },
       { 'uaa0304', 1, 4, 'Attack', 'GrowthFormation' }, 
   }
  local Builder = {
       BuilderName = 'A_AirAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Aeonbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
       },
   }
   ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
   
    Temp = {
       'A_AirAttackTemp3',
       'NoPlan',
       { 'uaa0203', 1, 16, 'Attack', 'GrowthFormation' },  
       { 'xaa0202', 1, 10, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
       BuilderName = 'A_AirAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 210,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Aeonbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2AB1airdefence1'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	 Temp = {
       'A_AirAttackTemp4',
       'NoPlan',
       { 'uaa0203', 1, 10, 'Attack', 'GrowthFormation' },  
       { 'xaa0202', 1, 6, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
       BuilderName = 'A_AirAttackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 210,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'Aeonbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2Adefence1'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )


end

function P2AB1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = Aeonbase1:AddOpAI('P2AExp1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'P2AB1landattack1',
            },
            MaxAssist = 2,
            Retry = true,
        }
    )

end

function Aeonbase2AI()

    Aeonbase2:InitializeDifficultyTables(ArmyBrains[Aeon], 'Aeonbase2', 'P2AB2MK', 50, {P2Abase2 = 100})
    Aeonbase2:StartEmptyBase({{10,13,16}, {5,8,11}})
	
    Aeonbase1:AddExpansionBase('Aeonbase2', 3)

	P2AB2landattacks1()
end

function P2AB2landattacks1()

    local Temp = {
       'P2AB2landAttackTemp0',
       'NoPlan',
       { 'xal0203', 1, 10, 'Attack', 'GrowthFormation' },   
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
	   { 'ual0205', 1, 3, 'Attack', 'GrowthFormation' },
	   }
    local Builder = {
        BuilderName = 'P2AB2landAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2AB2landattack2'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2AB2landAttackTemp1',
       'NoPlan',
       { 'ual0202', 1, 10, 'Attack', 'GrowthFormation' },   
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
	   { 'ual0205', 1, 3, 'Attack', 'GrowthFormation' },
	   }
    Builder = {
        BuilderName = 'P2AB2landAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2AB2landattack1'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2AB2landAttackTemp2',
       'NoPlan',
       { 'ual0202', 1, 10, 'Attack', 'GrowthFormation' },   
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
	   { 'ual0111', 1, 5, 'Attack', 'GrowthFormation' },
	   }
    Builder = {
        BuilderName = 'P2AB2landAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeonbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2AB2landattack1'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
   
end


