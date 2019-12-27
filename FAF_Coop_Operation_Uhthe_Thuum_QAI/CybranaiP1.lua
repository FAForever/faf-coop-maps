local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua'

local Player1 = 1
local Cybran1 = 2

local C1P1Base1 = BaseManager.CreateBaseManager()
local C1P1Base2 = BaseManager.CreateBaseManager()
local Difficulty = ScenarioInfo.Options.Difficulty

--Cybran Base 1

function P1C1base1AI()

    C1P1Base1:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P1Cybran1Base1', 'P1C1B1MK', 70, {P1C1base1 = 500})
    C1P1Base1:StartNonZeroBase({{12,16,18}, {10,14,16}})
    C1P1Base1:SetActive('AirScouting', true)


	P1C1B1Airattacks1()
	
	ForkThread(
	 function()
	WaitSeconds(5*60)
	P1C1B1Landattacks1()
	end
	)
	
	ForkThread(
	 function()
	WaitSeconds(14*60)
	P1C1B1Airattacks2()
	P1C1B1Landattacks2()
	end
	)
	
	ForkThread(
	 function()
	WaitSeconds(21*60)
	P1C1B1Airattacks3()
	end
	)
	
end

function P1C1B1Airattacks1()

    local Temp = {
       'P1C1B1AAttackTemp0',
       'NoPlan',  
       { 'ura0102', 1, 3, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P1C1B1AAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B1AAttackTemp1',
       'NoPlan',
       { 'ura0103', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1C1B1AAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B1AAttackTemp2',
       'NoPlan',
       { 'xra0105', 1, 3, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
       BuilderName = 'P1C1B1AAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B1AAttackTemp3',
       'NoPlan',
       { 'ura0203', 1, 18, 'Attack', 'GrowthFormation' },
       { 'dra0202', 1, 10, 'Attack', 'GrowthFormation' },
       { 'ura0303', 1, 8, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1C1B1AAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 400,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1C1B1Airpatrol1'
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
end

function P1C1B1Airattacks2()

   local Temp = {
       'P1C1B1AAttackTemp4',
       'NoPlan',
       { 'dra0202', 1, 5, 'Attack', 'GrowthFormation' },   
       { 'ura0203', 1, 10, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P1C1B1AAttackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B1AAttackTemp5',
       'NoPlan',
       { 'ura0203', 1, 15, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P1C1B1AAttackBuilder5',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B1AAttackTemp6',
       'NoPlan',
       { 'dra0202', 1, 10, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P1C1B1AAttackBuilder6',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

end

function P1C1B1Airattacks3()

   local Temp = {
       'P1C1B1AAttackTemp7',
       'NoPlan',
       { 'dra0202', 1, 6, 'Attack', 'GrowthFormation' },   
       { 'ura0304', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
       BuilderName = 'P1C1B1AAttackBuilder7',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 300,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
		        },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B1AAttackTemp8',
       'NoPlan',
       { 'ura0303', 1, 4, 'Attack', 'GrowthFormation' },
       { 'dra0202', 1, 6, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P1C1B1AAttackBuilder8',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 300,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
		      },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B1AAttackTemp9',
       'NoPlan',
       { 'xra0305', 1, 4, 'Attack', 'GrowthFormation' },
       { 'ura0203', 1, 16, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P1C1B1AAttackBuilder9',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 300,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B1Airattack1','P1C1B1Airattack2', 'P1C1B1Airattack3', 'P1C1B1Airattack4'}
	     },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

end

function P1C1B1Landattacks1()

    opai = C1P1Base1:AddOpAI('EngineerAttack', 'M1_Cybran_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1C1B1MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.ura0104})
   
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack1', 
                LandingChain = 'P1C1B1drop1',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', 10)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 60})
	
	opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_5',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack2', 
                LandingChain = 'P1C1B1drop2',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', 10)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 120})
	
	opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack1', 
                LandingChain = 'P1C1B1drop1',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', 10)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 180})
	
	opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack2', 
                LandingChain = 'P1C1B1drop2',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', 10)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 240})

end

function P1C1B1Landattacks2()

    local Temp = {
       'P1C1B1LAttackTemp0',
       'NoPlan',
       { 'url0203', 1, 15, 'Attack', 'GrowthFormation' },    
    }
    local Builder = {
       BuilderName = 'P1C1B1LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 120,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base1',
       PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P1C1B1Landattack1', 'P1C1B1Landattack2'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	opai = C1P1Base1:AddOpAI('EngineerAttack', 'M1_Cybran_TransportBuilder2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1C1B1MK',
        },
        Priority = 1100,
    })
    opai:SetChildQuantity('T2Transports', 5)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 5, categories.ura0104})
   
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_7',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack1', 
                LandingChain = 'P1C1B1drop1',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 20)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
	
	opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_6',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack2', 
                LandingChain = 'P1C1B1drop2',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 20)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 90})
   
    opai = C1P1Base1:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B1dropattack1', 
                LandingChain = 'P1C1B1drop1',
                TransportReturn = 'P1C1B1MK',
            },
            Priority = 555,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 12)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

end

-- Cybran Base 2, Objective

function P1C1base2AI()

    C1P1Base2:InitializeDifficultyTables(ArmyBrains[Cybran1], 'P1Cybran1Base2', 'P1C1B2MK', 80, {P1C1base2 = 500})
    C1P1Base2:StartNonZeroBase({{16,20,22}, {14,18,20}})
    C1P1Base2:SetActive('AirScouting', true)


    P1C1B2Airattacks1()
	P1C1B2Navalattacks1()
	P1C1B2Landattacks1()
	
	ForkThread(
	 function()
	WaitSeconds(16*60)
	P1C1B2Navalattacks2()
	end
	)
	
	ForkThread(
	 function()
	WaitSeconds(14*60)
	P1C1B2Airattacks2()
	P1C1B2Landattacks2()
	end
	)
	
end

function P1C1B2Landattacks1()

    local Temp = {
       'P1C1B2LAttackTemp0',
       'NoPlan',
       { 'url0107', 1, 6, 'Attack', 'GrowthFormation' },
       { 'url0103', 1, 2, 'Attack', 'GrowthFormation' },
       { 'url0104', 1, 2, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P1C1B2LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 120,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Landattack1'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2LAttackTemp1',
       'NoPlan',
       { 'url0203', 1, 4, 'Attack', 'GrowthFormation' },    
    }
    Builder = {
       BuilderName = 'P1C1B2LAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P1C1B2Landattack2', 'P1C1B2Landattack3'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2LAttackTemp2',
       'NoPlan',
       { 'url0202', 1, 8, 'Attack', 'GrowthFormation' },
       { 'url0205', 1, 4, 'Attack', 'GrowthFormation' },
       { 'drl0204', 1, 4, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P1C1B2LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 200,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1C1B2Landpatrol'
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	opai = C1P1Base2:AddOpAI('EngineerAttack', 'M1_CybranB2_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1C1B2MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 2, categories.ura0104})
   
    opai = C1P1Base2:AddOpAI('BasicLandAttack', 'M1_CybranB2_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B2dropattack1', 
                LandingChain = 'P1C1B2drop1',
                TransportReturn = 'P1C1B2MK',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', 10)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 60})
	
	opai = C1P1Base2:AddOpAI('BasicLandAttack', 'M1_CybranB2_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B2dropattack1', 
                LandingChain = 'P1C1B2drop1',
                TransportReturn = 'P1C1B2MK',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', 10)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 120})

end

function P1C1B2Landattacks2()

    local Temp = {
       'P1C1B2LAttackTemp3',
       'NoPlan',
       { 'url0202', 1, 4, 'Attack', 'GrowthFormation' },
       { 'url0205', 1, 2, 'Attack', 'GrowthFormation' },
       { 'url0111', 1, 2, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P1C1B2LAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 150,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Landattack1'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2LAttackTemp4',
       'NoPlan',
       { 'url0203', 1, 10, 'Attack', 'GrowthFormation' },    
    }
    Builder = {
       BuilderName = 'P1C1B2LAttackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 150,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P1C1B2Landattack2', 'P1C1B2Landattack3'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	opai = C1P1Base2:AddOpAI('BasicLandAttack', 'M1_CybranB2_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B2dropattack1', 
                LandingChain = 'P1C1B2drop1',
                TransportReturn = 'P1C1B2MK',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 12)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 60})
	
	opai = C1P1Base2:AddOpAI('BasicLandAttack', 'M1_CybranB2_TransportAttack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1C1B2dropattack1', 
                LandingChain = 'P1C1B2drop1',
                TransportReturn = 'P1C1B2MK',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 12)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 120})

end

function P1C1B2Airattacks1()

    local Temp = {
       'P1C1B2AAttackTemp0',
       'NoPlan',
       { 'ura0103', 1, 3, 'Attack', 'GrowthFormation' },
	   { 'ura0102', 1, 3, 'Attack', 'GrowthFormation' }
    }
    local Builder = {
       BuilderName = 'P1C1B2AAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2AAttackTemp1',
       'NoPlan',
       { 'xra0105', 1, 6, 'Attack', 'GrowthFormation' },    
    }
    Builder = {
       BuilderName = 'P1C1B2AAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2AAttackTemp2',
       'NoPlan',
       { 'dra0202', 1, 15, 'Attack', 'GrowthFormation' },
	   { 'ura0203', 1, 9, 'Attack', 'GrowthFormation' },
	   { 'xra0105', 1, 9, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P1C1B2AAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 400,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1C1B2Airpatrol1'
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

end

function P1C1B2Airattacks2()

    local Temp = {
       'P1C1B2AAttackTemp3',
       'NoPlan',
       { 'ura0203', 1, 9, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P1C1B2AAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 150,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2AAttackTemp4',
       'NoPlan',
       { 'ura0204', 1, 4, 'Attack', 'GrowthFormation' },
	   { 'ura0102', 1, 5, 'Attack', 'GrowthFormation' }
    }
    Builder = {
       BuilderName = 'P1C1B2AAttackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 150,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Airattack1', 'P1C1B2Airattack2', 'P1C1B2Airattack3'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
end

function P1C1B2Navalattacks1()

   local Temp = {
       'P1C1B2NAttackTemp0',
       'NoPlan',
       { 'xrs0204', 1, 5, 'Attack', 'GrowthFormation' },   
       { 'urs0201', 1, 3, 'Attack', 'GrowthFormation' },
       { 'urs0103', 1, 4, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P1C1B2NAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 400,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Navalpatrol1'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2NAttackTemp1',
       'NoPlan',
       { 'urs0103', 1, 4, 'Attack', 'GrowthFormation' },   
       { 'urs0203', 1, 2, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
       BuilderName = 'P1C1B2NAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )


end

function P1C1B2Navalattacks2()

   local Temp = {
       'P1C1B2NAttackTemp2',
       'NoPlan',
       { 'xrs0204', 1, 4, 'Attack', 'GrowthFormation' },   
       { 'urs0202', 1, 2, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P1C1B2NAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 200,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2NAttackTemp3',
       'NoPlan',  
       { 'urs0201', 1, 4, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P1C1B2NAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 200,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P1C1B2NAttackTemp4',
       'NoPlan',  
       { 'urs0201', 1, 2, 'Attack', 'GrowthFormation' },
       { 'urs0103', 1, 4, 'Attack', 'GrowthFormation' },		   
    }
    Builder = {
       BuilderName = 'P1C1B2NAttackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 200,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P1Cybran1Base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1C1B2Navalattack1', 'P1C1B2Navalattack2'}
       },
    }
    ArmyBrains[Cybran1]:PBMAddPlatoon( Builder )

end

