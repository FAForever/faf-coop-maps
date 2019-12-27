local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 2
local Aeon = 4

local Difficulty = ScenarioInfo.Options.Difficulty

local Aeonbase1P3 = BaseManager.CreateBaseManager()
local Aeonbase2P3 = BaseManager.CreateBaseManager()


function AeonP3base1AI()

    Aeonbase1P3:InitializeDifficultyTables(ArmyBrains[Aeon], 'P3Aeonbase1', 'P3AB1MK', 80, {P3Abase1 = 100})
    Aeonbase1P3:StartNonZeroBase({{12,16,20}, {7,11,15}})

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
    
    opai = Aeonbase1P3:AddOpAI('P3AExp1',
        {
            Amount = 2,
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

function AeonP3base2AI()

    Aeonbase2P3:InitializeDifficultyTables(ArmyBrains[Aeon], 'P3Aeonbase2', 'P3AB2MK', 80, {P3Abase2 = 100})
    Aeonbase2P3:StartNonZeroBase({{12,16,20}, {8,12,16}})

	P3AB2Airattacks1()
	P3AB2LandAttacks1()
	P3AB2NavalAttacks1()
end

function P3AB2Airattacks1()
  
    opai = Aeonbase2P3:AddOpAI('EngineerAttack', 'M3_Aeon_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P3AB2MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uaa0104})
  
    local Temp = {
       'P3AB2AirattackTemp1',
       'NoPlan',
       { 'uaa0204', 1, 5, 'Attack', 'GrowthFormation' },
       { 'xaa0306', 1, 2, 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P3AB2AirattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase2',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3AB2Airattack1', 'P3AB2Airattack2'}
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3AB2AirattackTemp2',
       'NoPlan',
       { 'uaa0303', 1, 4, 'Attack', 'GrowthFormation' },
       { 'xaa0305', 1, 2, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P3AB2AirattackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase2',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3AB2Airattack1', 'P3AB2Airattack2'}
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
end

function P3AB2LandAttacks1()

    local Temp = {
       'P3AB2LandattackTemp1',
       'NoPlan',
       { 'xal0203', 1, 7, 'Attack', 'GrowthFormation' },
       { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
	   { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P3AB2LandattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase2',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3AB2Landattack1', 'P3AB2Landattack2', 'P3AB2Landattack3'}
		   },
		 }
         ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

     opai = Aeonbase2P3:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB2Landingchain1', 
                LandingChain = 'P3AB2LandingchainA1',
                --TransportReturn = 'P3AB2MK',
            },
            Priority = 510,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 18)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 60})
	
	opai = Aeonbase2P3:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB2Landingchain2', 
                LandingChain = 'P3AB2LandingchainA2',
                --TransportReturn = 'P3AB2MK',
            },
            Priority = 500,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 18)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 120})

end

function P3AB2NavalAttacks1()

    local Temp = {
       'P3AB2NavalattackTemp0',
       'NoPlan',
       { 'uas0201', 1, 4, 'Attack', 'GrowthFormation' },
	   { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P3AB2NavalattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase2',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3AB2Navalattack1'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3AB2NavalattackTemp1',
       'NoPlan',
       { 'uas0203', 1, 6, 'Attack', 'GrowthFormation' },
	   { 'xas0204', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P3AB2NavalattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Aeonbase2',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3AB2Navalattack1'
       },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

end


