local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player = 5
local QAI = 2

local Q1P2Base1 = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty

function P2Q1base1AI()

    Q1P2Base1:InitializeDifficultyTables(ArmyBrains[QAI], 'P2QAIBase1', 'P2Q1B1MK', 75, {P2Qbase1 = 500})
    Q1P2Base1:StartNonZeroBase({{16,14,12}, {12,10,8}})
	
	P2QlandDefenses1()
	P2QAirDefenses1()
	
end

function P3Q1base1EXD()

    Q1P2Base1:AddBuildGroup('P3QbaseEXD_D' .. Difficulty, 800, false)
	
	P3QlandAttack1()
	P3QAirAttack1()
	
end

function P2QAirDefenses1()

    local Temp = {
       'P2QB1DefenseTemp0',
       'NoPlan',
       { 'ura0203', 1, 8, 'Attack', 'GrowthFormation' },
       { 'dra0202', 1, 3, 'Attack', 'GrowthFormation' },	   
       { 'ura0303', 1, 3, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P2QB1DefenseBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2QAIBase1',
      PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2QAirD1'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

end

function P2QlandDefenses1()

    local Temp = {
       'P2QB1DefenseTemp0',
       'NoPlan',
       { 'xrl0305', 1, 2, 'Attack', 'GrowthFormation' },   
       { 'url0202', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P2QB1DefenseBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2QAIBase1',
      PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2QlandD1'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

end

function P3QlandAttack1()

    local Temp = {
       'P3QB1LandAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, 2, 'Attack', 'GrowthFormation' },   
       { 'url0202', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P3QB1LandAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 300,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2QAIBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1Landattack1', 'P3QB1Landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3QB1LandAttackTemp1',
       'NoPlan',
       { 'url0303', 1, 6, 'Attack', 'GrowthFormation' },   
       { 'drl0203', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P3QB1LandAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 300,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2QAIBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1Landattack1', 'P3QB1Landattack2'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

end

function P3QAirAttack1()

    local Temp = {
       'P3QB1AirAttackTemp0',
       'NoPlan',
       { 'xra0305', 1, 2, 'Attack', 'GrowthFormation' },   
       { 'ura0202', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P3QB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2QAIBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1Airattack1', 'P3QB1Airattack2', 'P3QB1Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3QB1AirAttackTemp1',
       'NoPlan',
       { 'ura0304', 1, 2, 'Attack', 'GrowthFormation' },   
       { 'dra0202', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P3QB1AirAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2QAIBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3QB1Airattack1', 'P3QB1Airattack2', 'P3QB1Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
	
end



