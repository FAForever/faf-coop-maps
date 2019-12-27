local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua'

local Player1 = 1
local Cybran2 = 5

local C2P3Base1 = BaseManager.CreateBaseManager()
local C2P3Base2 = BaseManager.CreateBaseManager()
local C2P3Base3 = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty

-- Main Cybran Base

function C2P3Base1AI()

    C2P3Base1:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P3Cybran2Base1', 'P3C2B1MK', 80, {P3C2base1 = 100})
    C2P3Base1:StartNonZeroBase({{10,20,26}, {8,14,20}})
    C2P3Base1:SetActive('AirScouting', true)

	P3C2B1Airattacks1()
	P3C2B1Navalattacks1()
	P3C2B1Landattacks1()
	P3C2B1EXPattacks1()
	P3C2B1EXPattacks2()

end

function P3C2B1Airattacks1()

    local Temp = {
       'P3C2B1AttackTemp0',
       'NoPlan',
       { 'ura0203', 1, 15, 'Attack', 'AttackFormation' },   
       { 'ura0303', 1, 5, 'Attack', 'AttackFormation' },     
    }
    local Builder = {
       BuilderName = 'P3C2B1AttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B2Airattack1', 'P3C2B2Airattack2', 'P3C2B2Airattack3', 'P3C2B2Airattack4'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B1AttackTemp1',
       'NoPlan',
       { 'xra0305', 1, 5, 'Attack', 'AttackFormation' },       
    }
    Builder = {
       BuilderName = 'P3C2B1AttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B2Airattack1', 'P3C2B2Airattack2', 'P3C2B2Airattack3', 'P3C2B2Airattack4'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B1AttackTemp2',
       'NoPlan',
       { 'ura0304', 1, 5, 'Attack', 'AttackFormation' },
       { 'ura0303', 1, 5, 'Attack', 'AttackFormation' },       
    }
    Builder = {
       BuilderName = 'P3C2B1AttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B2Airattack1', 'P3C2B2Airattack2', 'P3C2B2Airattack3', 'P3C2B2Airattack4'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B1AttackTemp3',
       'NoPlan',
       { 'ura0304', 1, 4, 'Attack', 'GrowthFormation' },
       { 'ura0303', 1, 10, 'Attack', 'GrowthFormation' },
       { 'ura0203', 1, 12, 'Attack', 'GrowthFormation' },
	   { 'xra0305', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P3C2B1AttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3C2B1Airdef1'
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
end

function P3C2B1Navalattacks1()

    local Temp = {
       'P3C2B1NAttackTemp0',
       'NoPlan',
       { 'urs0201', 1, 4, 'Attack', 'GrowthFormation' },
       { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P3C2B1NAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B2Navalattack1', 'P3C2B2Navalattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B1NAttackTemp1',
       'NoPlan',
       { 'urs0201', 1, 2, 'Attack', 'GrowthFormation' },
       { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' }, 
       { 'xrs0204', 1, 4, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P3C2B1NAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B2Navalattack1', 'P3C2B2Navalattack2'}
		   },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B1NAttackTemp2',
       'NoPlan',
       { 'urs0302', 1, 2, 'Attack', 'GrowthFormation' },
       { 'xrs0204', 1, 4, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P3C2B1NAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B2Navalattack1', 'P3C2B2Navalattack2'}
		   },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
end

function P3C2B1Landattacks1()

    local Temp = {
       'P3C2B1LAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, 4, 'Attack', 'GrowthFormation' },   
       { 'url0203', 1, 6, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P3C2B1LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P3C2B2Landattack1', 'P3C2B2Landattack2', 'P3C2B2Landattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B1LAttackTemp1',
       'NoPlan',
       { 'xrl0305', 1, 6, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
       BuilderName = 'P3C2B1LAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P3C2B2Landattack1', 'P3C2B2Landattack2', 'P3C2B2Landattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B1LAttackTemp2',
       'NoPlan',
       { 'url0203', 1, 12, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
       BuilderName = 'P3C2B1LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P3C2B2Landattack1', 'P3C2B2Landattack2', 'P3C2B2Landattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B1GAttackTemp0',
       'NoPlan',
       { 'url0301', 1, 2, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
       BuilderName = 'P3C2B1GAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Gate',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base1',
       PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P3C2B2Landattack1', 'P3C2B2Landattack2', 'P3C2B2Landattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
end

function P3C2B1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = C2P3Base1:AddOpAI('P3C2EXPbug1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
           PlatoonData = {
           PatrolChains = { 'P3C2B2Airattack3', 'P3C2B2Airattack4'}
        },
            MaxAssist = 3,
            Retry = true,
        }
    )

end

function P3C2B1EXPattacks2()
    local opai = nil
    local quantity = {}
    
    opai = C2P3Base1:AddOpAI('P3C2EXPbug2',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
           PlatoonData = {
           PatrolChains = { 'P3C2B2Airattack3', 'P3C2B2Airattack4'}
        },
            MaxAssist = 3,
            Retry = true,
        }
    )

end


-- Second Cybran Base

function C2P3Base2AI()

    C2P3Base2:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P3Cybran2Base2', 'P3C2B2MK', 100, {P3C2base2 = 100})
    C2P3Base2:StartNonZeroBase({{14,19,24}, {10,15,20}})
    C2P3Base2:SetActive('AirScouting', true)
	
	P3C2B2Landattacks1()
	P3C2B2Airattacks1()
	P3C2B2Navalattacks1()
	P3C2B2EXPattacks1()
	
end

function P3C2B2Landattacks1()

    local Temp = {
       'P3C2B2LAttackTemp0',
       'NoPlan',
       { 'xrl0305', 1, 5, 'Attack', 'GrowthFormation' },   
       { 'url0203', 1, 9, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P3C2B2LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Landattack1', 'P3C2B1Landattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B2LAttackTemp1',
       'NoPlan',
       { 'url0303', 1, 10, 'Attack', 'GrowthFormation' },   
       { 'url0205', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P3C2B2LAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Landattack1', 'P3C2B1Landattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B2LAttackTemp2',
       'NoPlan',
       { 'url0303', 1, 8, 'Attack', 'GrowthFormation' },   
       { 'url0111', 1, 5, 'Attack', 'GrowthFormation' },
       { 'url0205', 1, 3, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P3C2B2LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Landattack1', 'P3C2B1Landattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
end

function P3C2B2Airattacks1()

    local Temp = {
       'P3C2B2AirAttackTemp0',
       'NoPlan',
       { 'ura0203', 1, 12, 'Attack', 'AttackFormation' },      
    }
    local Builder = {
       BuilderName = 'P3C2B2AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Airattack1', 'P3C2B1Airattack2', 'P3C2B1Airattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B2AirAttackTemp1',
       'NoPlan',
       { 'ura0304', 1, 8, 'Attack', 'AttackFormation' },      
    }
    Builder = {
       BuilderName = 'P3C2B2AirAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Airattack1', 'P3C2B1Airattack2', 'P3C2B1Airattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B2AirAttackTemp2',
       'NoPlan',
       { 'xra0305', 1, 8, 'Attack', 'AttackFormation' },      
    }
    Builder = {
       BuilderName = 'P3C2B2AirAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Airattack1', 'P3C2B1Airattack2', 'P3C2B1Airattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B2AirAttackTemp3',
       'NoPlan',
       { 'ura0303', 1, 8, 'Attack', 'AttackFormation' },      
    }
    Builder = {
       BuilderName = 'P3C2B2AirAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Airattack1', 'P3C2B1Airattack2', 'P3C2B1Airattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
end

function P3C2B2Navalattacks1()

    local Temp = {
       'P3C2B2NAttackTemp0',
       'NoPlan',
       { 'urs0201', 1, 2, 'Attack', 'GrowthFormation' },
       { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P3C2B2NAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Navalattack1', 'P3C2B1Navalattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B2NAttackTemp1',
       'NoPlan',
       { 'urs0201', 1, 2, 'Attack', 'GrowthFormation' },
       { 'xrs0204', 1, 4, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P3C2B2NAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Navalattack1', 'P3C2B1Navalattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B2NAttackTemp2',
       'NoPlan',
       { 'urs0302', 1, 2, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P3C2B2NAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Navalattack1', 'P3C2B1Navalattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B2NAttackTemp3',
       'NoPlan',
       { 'urs0201', 1, 4, 'Attack', 'GrowthFormation' },
       { 'urs0202', 1, 4, 'Attack', 'GrowthFormation' },		   
    }
    Builder = {
       BuilderName = 'P3C2B2NAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B1Navalattack1', 'P3C2B1Navalattack2'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
end

function P3C2B2EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = C2P3Base2:AddOpAI('P3C2EXPbot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
             PlatoonData = {
              MoveChains = {'P3C2B2Expattack1', 'P3C2B2Expattack2', 'P3C2B2Expattack3'}
            },
            MaxAssist = 4,
            Retry = true,
        }
    )

end


-- Minor Cybran Base

function C2P3Base3AI()

    C2P3Base3:InitializeDifficultyTables(ArmyBrains[Cybran2], 'P3Cybran2Base3', 'P3C2B3MK', 70, {P3C2base3 = 100})
    C2P3Base3:StartNonZeroBase({{11,13,14}, {3,5,6}})
    C2P3Base3:SetActive('AirScouting', true)
	
	P3C2B3EXPattacks1()
	P3C2B3Airattacks1()
	
end

function P3C2B3EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = C2P3Base3:AddOpAI('P3C2EXPbot2',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'P3C2B3Expattack1',
            },
            MaxAssist = 8,
            Retry = false,
        }
    )

end

function P3C2B3Airattacks1()

    local Temp = {
       'P3C2B3AirAttackTemp0',
       'NoPlan',
       { 'ura0303', 1, 6, 'Attack', 'AttackFormation' },      
    }
    local Builder = {
       BuilderName = 'P3C2B3AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B3Airattack1', 'P3C2B3Airattack2', 'P3C2B3Airattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B3AirAttackTemp1',
       'NoPlan',
       { 'ura0203', 1, 9, 'Attack', 'AttackFormation' },      
    }
    Builder = {
       BuilderName = 'P3C2B3AirAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B3Airattack1', 'P3C2B3Airattack2', 'P3C2B3Airattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B3AirAttackTemp2',
       'NoPlan',
       { 'ura0304', 1, 3, 'Attack', 'AttackFormation' },      
    }
    Builder = {
       BuilderName = 'P3C2B3AirAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B3Airattack1', 'P3C2B3Airattack2', 'P3C2B3Airattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3C2B3AirAttackTemp3',
       'NoPlan',
       { 'xra0305', 1, 3, 'Attack', 'AttackFormation' }, 
       { 'ura0303', 1, 6, 'Attack', 'AttackFormation' },	   
    }
    Builder = {
       BuilderName = 'P3C2B3AirAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybran2Base3',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3C2B3Airattack1', 'P3C2B3Airattack2', 'P3C2B3Airattack3'}
       },
    }
    ArmyBrains[Cybran2]:PBMAddPlatoon( Builder )
	
end





