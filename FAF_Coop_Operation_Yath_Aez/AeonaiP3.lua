local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 2
local Aeon = 4

local Difficulty = ScenarioInfo.Options.Difficulty

local AeonbaseP3 = BaseManager.CreateBaseManager()


function AeonP3base1AI()

    AeonbaseP3:InitializeDifficultyTables(ArmyBrains[Aeon], 'P3Aeonbase1', 'P3AB1MK', 80, {P3Abase1 = 100})
    AeonbaseP3:StartNonZeroBase({{12,16,20}, {7,11,15}})

	P3AB1Airattacks1()
	P3AB1EXPattacks1()
end

function P3AB1Airattacks1()
  
    local Temp = {
       'P3AB1AirattackTemp0',
       'NoPlan',
       { 'uaa0203', 1, 15, 'Attack', 'GrowthFormation' },
       { 'xaa0305', 1, 5, 'Attack', 'GrowthFormation' },
       { 'uaa0303', 1, 10, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P3AB1AirattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 400,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase1',   
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3AAirdefence1'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
  
    Temp = {
       'P3AB1AirattackTemp1',
       'NoPlan',
       { 'uaa0203', 1, 15, 'Attack', 'GrowthFormation' },
       { 'xaa0305', 1, 5, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P3AB1AirattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3AAirattack1', 'P3AAirattack2', 'P3AAirattack3', 'P3AAirattack4', 'P3AAirattack5'}
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3AB1AirattackTemp2',
       'NoPlan',
       { 'uaa0303', 1, 5, 'Attack', 'GrowthFormation' },
       { 'xaa0202', 1, 10, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P3AB1AirattackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3AAirattack1', 'P3AAirattack2', 'P3AAirattack3', 'P3AAirattack4', 'P3AAirattack5'}
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3AB1AirattackTemp3',
       'NoPlan',
       { 'uaa0304', 1, 5, 'Attack', 'GrowthFormation' },
       { 'xaa0202', 1, 10, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P3AB1AirattackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3AAirattack1', 'P3AAirattack2', 'P3AAirattack3', 'P3AAirattack4', 'P3AAirattack5'}
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )


end

function P3AB1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = AeonbaseP3:AddOpAI('P3AExp1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'P3AAirattack1',
            },
            MaxAssist = 3,
            Retry = true,
        }
    )

end




