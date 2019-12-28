local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local Player1 = 1
local UEF = 5

local P4UBase1 = BaseManager.CreateBaseManager()
local P4UBase2 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P4UEFbase1AI()
    P4UBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFBase1', 'P4UB1MK', 70, {P4UBase1 = 100})
    P4UBase1:StartNonZeroBase({{12, 16, 18}, {7, 11, 14}})

    P4UB1Airattacks()
	P4UB1Landattacks()
	P4UB1EXPattacks1()
    
end

function P4UEFbase2AI()
    P4UBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P4UEFBase2', 'P4UB2MK', 70, {P4UBase2 = 100})
    P4UBase2:StartNonZeroBase({{10, 14, 16}, {6, 9, 12}})

   P4UB2Navalattacks()
   P4UB2EXPattacks1()
   
end

function P4UB1Airattacks()

    local Temp = {
       'P4U1B1AttackTemp0',
       'NoPlan',
       { 'uea0204', 1, 12, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'P4U1B1AttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase1Airattack1','P4UBase1Airattack2', 'P4UBase1Airattack3', 'P4UBase1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4U1B1AttackTemp1',
       'NoPlan',
       { 'uea0203', 1, 12, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P4U1B1AttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase1Airattack1','P4UBase1Airattack2', 'P4UBase1Airattack3', 'P4UBase1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4U1B1AttackTemp2',
       'NoPlan',
       { 'uea0303', 1, 8, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P4U1B1AttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase1Airattack1','P4UBase1Airattack2', 'P4UBase1Airattack3', 'P4UBase1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4U1B1AttackTemp3',
       'NoPlan',
       { 'uea0305', 1, 8, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P4U1B1AttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase1Airattack1','P4UBase1Airattack2', 'P4UBase1Airattack3', 'P4UBase1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	
end

function P4UB1Landattacks()

    local Temp = {
       'P4U1B1LandAttackTemp0',
       'NoPlan',
       { 'xel0305', 1, 4, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'P4U1B1LandAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase1Landattack1','P4UBase1Landattack2'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4U1B1LandAttackTemp1',
       'NoPlan',
       { 'uel0203', 1, 8, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P4U1B1LandAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase1Landattack1','P4UBase1Landattack2'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	local opai = nil
	 
    opai = P4UBase1:AddOpAI('EngineerAttack', 'M4_UEF_TransportBuilder2',
     {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P4UB1MK',
        },
        Priority = 2000,
     }
	)
    opai:SetChildQuantity('T3Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 1, categories.xea0306})


     opai = P4UBase1:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack_1',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P4UDropAChain1', 
                    LandingChain = 'P4UDropChain1',
		    		MovePath = 'P4UMoveDChain1',
                    TransportReturn = 'P4UB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'MobileMissiles'}, {12, 12})
        opai:SetLockingStyle('BuildTimer', {LockTimer = 120})
		
		opai = P4UBase1:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack_2',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P4UDropAChain1', 
                    LandingChain = 'P4UDropChain1',
		    		MovePath = 'P4UMoveDChain1',
                    TransportReturn = 'P4UB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity('HeavyBots', 6)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 60})
		
		opai = P4UBase1:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack_3',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P4UDropAChain2', 
                    LandingChain = 'P4UDropChain2',
		    		MovePath = 'P4UMoveDChain2',
                    TransportReturn = 'P4UB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'MobileMissiles'}, {12, 12})
        opai:SetLockingStyle('BuildTimer', {LockTimer = 180})
		
		opai = P4UBase1:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack_4',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P4UDropAChain2', 
                    LandingChain = 'P4UDropChain2',
		    		MovePath = 'P4UMoveDChain2',
                    TransportReturn = 'P4UB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity('HeavyBots', 6)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 120})
		
		opai = P4UBase1:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack_5',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P4UDropAChain3', 
                    LandingChain = 'P4UDropChain3',
		    		MovePath = 'P4UMoveDChain3',
                    TransportReturn = 'P4UB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity('HeavyBots', 6)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 180})

end

function P4UB2Navalattacks()

    local Temp = {
       'P3UB2NavalAttackTemp0',
       'NoPlan',
       { 'ues0201', 1, 4, 'Attack', 'GrowthFormation' },
       { 'xes0205', 1, 1, 'Attack', 'GrowthFormation' },
 	   { 'ues0203', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P3UB2NavalAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase2',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase2Navalattack1','P4UBase2Navalattack2', 'P4UBase2Navalattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3UB2NavalAttackTemp1',
       'NoPlan',
       { 'ues0202', 1, 4, 'Attack', 'GrowthFormation' },
       { 'xes0205', 1, 1, 'Attack', 'GrowthFormation' },
       { 'ues0203', 1, 4, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P3UB2NavalAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase2',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase2Navalattack1','P4UBase2Navalattack2', 'P4UBase2Navalattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3UB2NavalAttackTemp2',
       'NoPlan',
       { 'ues0203', 1, 8, 'Attack', 'GrowthFormation' },
       { 'xes0102', 1, 4, 'Attack', 'GrowthFormation' },  	   
    }
    Builder = {
       BuilderName = 'P3UB2NavalAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase2',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase2Navalattack1','P4UBase2Navalattack2', 'P4UBase2Navalattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3UB2NavalAttackTemp3',
       'NoPlan',
       { 'ues0103', 1, 6, 'Attack', 'GrowthFormation' },
       { 'xes0307', 1, 2, 'Attack', 'GrowthFormation' },  	   
    }
    Builder = {
       BuilderName = 'P3UB2NavalAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 110,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P4UEFBase2',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase2Navalattack1','P4UBase2Navalattack2', 'P4UBase2Navalattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
	
	
end

function P4UB1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = P4UBase1:AddOpAI('P4UBot',
        {
            Amount = 2,
            KeepAlive = true,
          PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4UBase1Landattack1','P4UBase1Landattack2'}
       },
            MaxAssist = 4,
            Retry = true,
        }
    )

end

function P4UB2EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = P4UBase2:AddOpAI('P4USub',
        {
            Amount = 2,
            KeepAlive = true,
         PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4UBase2Navalattack1','P4UBase2Navalattack2', 'P4UBase2Navalattack3'}
       },
            MaxAssist = 4,
            Retry = true,
        }
    )

end


