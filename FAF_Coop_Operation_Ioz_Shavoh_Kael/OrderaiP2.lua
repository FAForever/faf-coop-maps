local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local KOrder = 4
local Order = 3

local P2KO1base1 = BaseManager.CreateBaseManager()
local P2O1base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P2KO1Base1AI()

    P2KO1base1:InitializeDifficultyTables(ArmyBrains[KOrder], 'P2KOrder1Base1', 'P2KO1base1MK', 140, {P2KO1Base1 = 100})
    P2KO1base1:StartNonZeroBase({{11,15,19}, {9,13,17}})
    P2KO1base1:SetActive('AirScouting', true)

	P2KO1B1Airattacks1()
	P2KO1B1Landattacks1()
	P2KO1B1Navalattacks1()
	P2KO1B1EXPattacks1()
	
end

function P2O1Base1AI()

    P2O1base1:InitializeDifficultyTables(ArmyBrains[Order], 'P2Order1Base1', 'P2Obase1MK', 140, {P2O1Base1 = 100})
    P2O1base1:StartNonZeroBase({{12,16,20}, {9,13,17}})
    P2O1base1:SetActive('AirScouting', true)

	P2O1B1Airattacks1()
	P2O1B1Navalattacks1()
	P2O1B1Landattacks1()
	P2OB1EXPattacks1()
	
end

function P2KO1B1Airattacks1()

    local Temp = {
       'P2KO1B1AttackTemp0',
       'NoPlan',
       { 'uaa0204', 1, 6, 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
       BuilderName = 'P2KO1B1AttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2KOrder1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2KO1Base1airattack1','P2KO1Base1airattack2', 'P2KO1Base1airattack3','P2KO1Base1airattack4'}
       },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2KO1B1AttackTemp1',
       'NoPlan',
       { 'uaa0303', 1, 3, 'Attack', 'GrowthFormation' },
       { 'uaa0203', 1, 6, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P2KO1B1AttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2KOrder1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2KO1Base1airattack1','P2KO1Base1airattack2', 'P2KO1Base1airattack3','P2KO1Base1airattack4'}
       },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2KO1B1AttackTemp2',
       'NoPlan',
       { 'uaa0203', 1, 9, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P2KO1B1AttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2KOrder1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2KO1Base1airattack1','P2KO1Base1airattack2', 'P2KO1Base1airattack3','P2KO1Base1airattack4'}
       },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
	
end

function P2KO1B1Landattacks1()

    local Temp = {
       'P2KO1B1LAttackTemp0',
       'NoPlan',
       { 'ual0202', 1, 8, 'Attack', 'GrowthFormation' }, 
       { 'ual0304', 1, 4, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P2KO1B1LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2KOrder1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2KO1Base1landattack1'
       },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
	
	Temp = {
    'P2KO1B1LAttackTemp1',
    'NoPlan',
    { 'ual0303', 1, 8, 'Attack', 'GrowthFormation' },
          }
    Builder = {
    BuilderName = 'P2KO1B1LAttackBuilder1',
    PlatoonTemplate = Temp,
    InstanceCount = 2,
    Priority = 100,
    PlatoonType = 'Land',
    RequiresConstruction = true,
    LocationType = 'P2KOrder1Base1',
    PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},
    PlatoonAddFunctions = {
        {
            '/maps/Operation(Ioz-Shavoh-Kael)/Operation(Ioz-Shavoh-Kael)_script.lua', 'RemoveCommandCapFromPlatoon',
        },
    },
    PlatoonData = {
        MoveChain = 'P2KO1Base1landattack1'
    },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon(Builder)
	
	Temp = {
       'P2KO1B1LAttackTemp2',
       'NoPlan',
       { 'ual0303', 1, 4, 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
       { 'dalk003', 1, 2, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P2KO1B1LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2KOrder1Base1',
       PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},
       PlatoonAddFunctions = {
        {
            '/maps/Operation(Ioz-Shavoh-Kael)/Operation(Ioz-Shavoh-Kael)_script.lua', 'RemoveCommandCapFromPlatoon',
        },
    },	   
    PlatoonData = {
       MoveChain = 'P2KO1Base1landattack1'
    },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

end

function P2KO1B1Navalattacks1()

    local Temp = {
       'P2KO1B1NAttackTemp0',
       'NoPlan',
       { 'uas0201', 1, 3, 'Attack', 'GrowthFormation' },
       { 'uas0202', 1, 3, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'P2KO1B1NAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2KOrder1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2KO1Base1navalattack1','P2KO1Base1navalattack2', 'P2KO1Base1navalattack3'}
       },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2KO1B1NAttackTemp1',
       'NoPlan',
       { 'xas0204', 1, 6, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P2KO1B1NAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2KOrder1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2KO1Base1navalattack1','P2KO1Base1navalattack2', 'P2KO1Base1navalattack3'}
       },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2KO1B1NAttackTemp2',
       'NoPlan',
       { 'xas0204', 1, 7, 'Attack', 'GrowthFormation' },
       { 'uas0302', 1, 1, 'Attack', 'GrowthFormation' },  	   
    }
    Builder = {
       BuilderName = 'P2KO1B1NAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2KOrder1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2KO1Base1navalattack1','P2KO1Base1navalattack2', 'P2KO1Base1navalattack3'}
       },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
	
end

function P2KO1B1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = P2KO1base1:AddOpAI('KObot1',
        {
            Amount = 2,
            KeepAlive = true,
          PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2KO1Base1landattack1'
       },
            MaxAssist = 4,
            Retry = true,
        }
    )

end

function P2O1B1Airattacks1()

    local Temp = {
       'P2O1B1AAttackTemp0',
       'NoPlan',
       { 'xaa0305', 1, 5, 'Attack', 'AttackFormation' },   
    }
    local Builder = {
       BuilderName = 'P2O1B1AAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2OBase1Airattack1','P2OBase1Airattack2', 'P2OBase1Airattack3','P2OBase1Airattack4'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2O1B1AAttackTemp1',
       'NoPlan',
       { 'uaa0203', 1, 10, 'Attack', 'AttackFormation' },   
    }
    Builder = {
       BuilderName = 'P2O1B1AAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2OBase1Airattack1','P2OBase1Airattack2', 'P2OBase1Airattack3','P2OBase1Airattack4'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2O1B1AAttackTemp2',
       'NoPlan',
       { 'uaa0303', 1, 10, 'Attack', 'AttackFormation' },   
    }
    Builder = {
       BuilderName = 'P2O1B1AAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2OBase1Airattack1','P2OBase1Airattack2', 'P2OBase1Airattack3','P2OBase1Airattack4'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2O1B1AAttackTemp3',
       'NoPlan',
       { 'uaa0204', 1, 10, 'Attack', 'AttackFormation' },   
    }
    Builder = {
       BuilderName = 'P2O1B1AAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2OBase1Airattack1','P2OBase1Airattack2', 'P2OBase1Airattack3','P2OBase1Airattack4'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
end

function P2O1B1Landattacks1()

    local Temp = {
       'P2O1B1LAttackTemp0',
       'NoPlan',
       { 'xal0203', 1, 6, 'Attack', 'GrowthFormation' }, 
       { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },	   
    }
    local Builder = {
       BuilderName = 'P2O1B1LAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2O1Base1landattack1','P2O1Base1landattack2','P2O1Base1landattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2O1B1LAttackTemp1',
       'NoPlan',
       { 'dal0310', 1, 4, 'Attack', 'GrowthFormation' }, 
       { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P2O1B1LAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2O1Base1landattack1','P2O1Base1landattack2','P2O1Base1landattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2O1B1LAttackTemp2',
       'NoPlan',
       { 'xal0203', 1, 8, 'Attack', 'GrowthFormation' }, 
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P2O1B1LAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2O1Base1landattack1','P2O1Base1landattack2','P2O1Base1landattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
end

function P2O1B1Navalattacks1()

    local Temp = {
       'P2O1B1NAttackTemp0',
       'NoPlan',
       { 'uas0201', 1, 3, 'Attack', 'GrowthFormation' },
       { 'uas0103', 1, 5, 'Attack', 'GrowthFormation' }	   
    }
    local Builder = {
       BuilderName = 'P2O1B1NAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2O1Base1navalattack1', 'P2O1Base1navalattack2'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2O1B1NAttackTemp1',
       'NoPlan',
       { 'uas0201', 1, 3, 'Attack', 'GrowthFormation' },
       { 'xas0204', 1, 3, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P2O1B1NAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2O1Base1navalattack1', 'P2O1Base1navalattack2'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P2O1B1NAttackTemp2',
       'NoPlan',
       { 'uas0202', 1, 3, 'Attack', 'GrowthFormation' },
       { 'xas0204', 1, 6, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P2O1B1NAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P2Order1Base1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2O1Base1navalattack1', 'P2O1Base1navalattack2'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
	
end

function P2OB1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = P2O1base1:AddOpAI('P2OSub',
        {
            Amount = 2,
            KeepAlive = true,
         PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2O1Base1navalattack1', 'P2O1Base1navalattack2'}
       },
            MaxAssist = 2,
            Retry = true,
        }
    )

end
