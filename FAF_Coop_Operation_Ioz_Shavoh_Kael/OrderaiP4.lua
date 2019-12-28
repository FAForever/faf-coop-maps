local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local Player1 = 1
local Kael = 2

local P4KBase1 = BaseManager.CreateBaseManager()
local P4KBase2 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P4Kaelbase1AI()
    P4KBase1:InitializeDifficultyTables(ArmyBrains[Kael], 'P4KaelBase1', 'P4KB1MK', 80, {P4KBase1 = 100})
    P4KBase1:StartNonZeroBase({{14, 18, 22}, {10, 14, 18}})

    P4KB1Airattacks()
	P4KB1Landattacks()
	P4KB1EXPattacks1()
	P4KB1EXPattacks2()
    
    
end

function P4Kaelbase2AI()
    P4KBase2:InitializeDifficultyTables(ArmyBrains[Kael], 'P4KaelBase2', 'P4KB2MK', 80, {P4KBase2 = 100})
    P4KBase2:StartNonZeroBase({{12, 16, 18}, {8, 11, 14}})

   P4KB2Navalattacks()
   P4KB2Airattacks()
   P4KB2EXPattacks1()
   
end

function P4KB1Airattacks()

    local Temp = {
       'P4KB1AAttackTemp0',
       'NoPlan',
       { 'uaa0203', 1, 15, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'P4K1B1AAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB1Airattack1','P4KB1Airattack2', 'P4KB1Airattack3', 'P4KB1Airattack4'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB1AAttackTemp1',
       'NoPlan',
       { 'uaa0303', 1, 10, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P4K1B1AAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB1Airattack1','P4KB1Airattack2', 'P4KB1Airattack3', 'P4KB1Airattack4'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB1AAttackTemp2',
       'NoPlan',
       { 'uaa0304', 1, 6, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P4K1B1AAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB1Airattack1','P4KB1Airattack2', 'P4KB1Airattack3', 'P4KB1Airattack4'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB1AAttackTemp3',
       'NoPlan',
       { 'xaa0305', 1, 6, 'Attack', 'GrowthFormation' },
       { 'uaa0203', 1, 12, 'Attack', 'GrowthFormation' },  	   
    }
    Builder = {
       BuilderName = 'P4K1B1AAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB1Airattack1','P4KB1Airattack2', 'P4KB1Airattack3', 'P4KB1Airattack4'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	
	
end

function P4KB1Landattacks()

    local Temp = {
       'P4KB1LandAttackTemp0',
       'NoPlan',
       { 'xal0203', 1, 8, 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
       { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' }, 	   
    }
    local Builder = {
       BuilderName = 'P4KB1LandAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB1LandAttackTemp1',
       'NoPlan',
       { 'dal0310', 1, 6, 'Attack', 'GrowthFormation' },
       { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
       { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P4KB1LandAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB1LandAttackTemp2',
       'NoPlan',
       { 'xal0203', 1, 21, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P4KB1LandAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )

end

function P4KB2Navalattacks()

    local Temp = {
       'P4KB2NavalAttackTemp0',
       'NoPlan',
       { 'uas0201', 1, 4, 'Attack', 'GrowthFormation' },
       { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },
       { 'xas0204', 1, 2, 'Attack', 'GrowthFormation' }, 	   
    }
    local Builder = {
       BuilderName = 'P4KB2NavalAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 120,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase2',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB2NavalAttackTemp1',
       'NoPlan',
       { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },
       { 'xas0204', 1, 6, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P4KB2NavalAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase2',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB2NavalAttackTemp2',
       'NoPlan',
       { 'uas0203', 1, 4, 'Attack', 'GrowthFormation' },
       { 'xas0204', 1, 6, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P4KB2NavalAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase2',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB2NavalAttackTemp3',
       'NoPlan',
       { 'uas0302', 1, 2, 'Attack', 'GrowthFormation' },
       { 'uas0202', 1, 6, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P4KB2NavalAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 110,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase2',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
end

function P4KB2Airattacks()

    local Temp = {
       'P4KB2AAttackTemp0',
       'NoPlan',
       { 'uaa0204', 1, 8, 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
       BuilderName = 'P4K1B2AAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Airattack1','P4KB2Airattack2', 'P4KB2Airattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB2AAttackTemp1',
       'NoPlan',
       { 'xaa0306', 1, 4, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P4K1B2AAttackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Airattack1','P4KB2Airattack2', 'P4KB2Airattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P4KB2AAttackTemp2',
       'NoPlan',
       { 'xaa0306', 1, 2, 'Attack', 'GrowthFormation' },
       { 'uaa0204', 1, 6, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P4K1B2AAttackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P4KaelBase2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Airattack1','P4KB2Airattack2', 'P4KB2Airattack3'}
       },
    }
    ArmyBrains[Kael]:PBMAddPlatoon( Builder )

end

function P4KB1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = P4KBase1:AddOpAI('P4KBot',
        {
            Amount = 2,
            KeepAlive = true,
          PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
       },
            MaxAssist = 4,
            Retry = true,
        }
    )

end

function P4KB1EXPattacks2()
    local opai = nil
    local quantity = {}
    
    opai = P4KBase1:AddOpAI('P4KBot2',
        {
            Amount = 2,
            KeepAlive = true,
          PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
       },
            MaxAssist = 4,
            Retry = true,
        }
    )
	
end

function P4KB2EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = P4KBase2:AddOpAI('P4KSub',
        {
            Amount = 2,
            KeepAlive = true,
         PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
       },
            MaxAssist = 4,
            Retry = true,
        }
    )

end

function P4KB2engupgrade()

    P4KBase2:StartNonZeroBase({{24, 28, 30}, {8, 11, 14}})
    
	P4KB2Sp1()
	P4KB2Sp2()
	P4KB2Sp3()
	P4KB2Sp4()
	
end

function P4KB2Sp1()
    local opai = nil
    local quantity = {}
    
    opai = P4KBase2:AddOpAI('Sp1',
        {
            Amount = 2,
            KeepAlive = true,
         PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Navalattack1','P4KB2Navalattack2', 'P4KB2Navalattack3'}
       },
            MaxAssist = 3,
            Retry = true,
        }
    )

end

function P4KB2Sp2()
    local opai = nil
    local quantity = {}
    
    opai = P4KBase2:AddOpAI('Sp2',
        {
            Amount = 2,
            KeepAlive = true,
         PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P4KB2Airattack1','P4KB2Airattack2', 'P4KB2Airattack3'}
       },
            MaxAssist = 3,
            Retry = true,
        }
    )

end

function P4KB2Sp3()
    local opai = nil
    local quantity = {}
    
    opai = P4KBase2:AddOpAI('Sp3',
        {
            Amount = 2,
            KeepAlive = true,
         PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
       },
            MaxAssist = 3,
            Retry = true,
        }
    )

end

function P4KB2Sp4()
    local opai = nil
    local quantity = {}
    
    opai = P4KBase2:AddOpAI('Sp4',
        {
            Amount = 2,
            KeepAlive = true,
         PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
       PlatoonData = {
           MoveChains = {'P4KB1Landattack1','P4KB1Landattack2', 'P4KB1Landattack3'}
       },
            MaxAssist = 3,
            Retry = true,
        }
    )

end
