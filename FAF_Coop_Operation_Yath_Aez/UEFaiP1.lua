    local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local UEF = 2

local UEFM1WestBase = BaseManager.CreateBaseManager()
local P1EastBase = BaseManager.CreateBaseManager()
local P1TACBase = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

local T2airandlandattacks = {14*60, 13*60, 12*60}
local T2Navalattacks = {18*60, 17*60, 16*60}
local T3airandlandattacks = {20*60, 19*60, 18*60}

function UEFM1WestBaseAI()

    UEFM1WestBase:InitializeDifficultyTables(ArmyBrains[UEF], 'WestNavelBaseP1', 'P1UB2MK', 80, {P1Ubase1 = 700})
    UEFM1WestBase:StartNonZeroBase({{13,16,19}, {10,13,16}})
    UEFM1WestBase:SetActive('AirScouting', true)
    
    ForkThread(
        function()
            WaitSeconds(4)
            UEFM1WestBase:AddBuildGroup('ExWnavel_D' .. Difficulty, 800, false)
        end
    )

    P1UB1AirAttack1()
    P1UB1NavalAttack1()
    
    ForkThread(
        function()
            WaitSeconds(T2Navalattacks[Difficulty])
            P1UB1NavalAttack2()
        end
    )   
    ForkThread(
        function()
            WaitSeconds(T2airandlandattacks[Difficulty])
            P1UB1AirAttack2()
            P1UB1landAttack1()
        end
    )   
    ForkThread(
        function()
            WaitSeconds(T3airandlandattacks[Difficulty])
            P1UB1AirAttack3()
        end
    )    
end

function P1UB1AirAttack1()
   
    local Temp = {
       'P1UB1Defence0',
       'NoPlan',
       { 'uea0103', 1, 5, 'Attack', 'GrowthFormation' },   --Bombers
       { 'uea0203', 1, 5, 'Attack', 'GrowthFormation' },   --Gunships
       { 'uea0102', 1, 6, 'Attack', 'GrowthFormation' },  --Intercepters
    }
    local Builder = {
       BuilderName = 'P1UB1DefenceBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 600,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1Airdefence1'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
       'P1UB1Defence1',
       'NoPlan',
       { 'uea0303', 1, 6, 'Attack', 'GrowthFormation' },   --ASFs
       { 'uea0305', 1, 4, 'Attack', 'GrowthFormation' },   --Heavy Gunships
      
    }
    Builder = {
       BuilderName = 'P1UB1DefenceBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 600,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1Airdefence1'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
       'P1UB1Airattack0',
       'NoPlan',
       { 'uea0102', 1, 6, 'Attack', 'GrowthFormation' },  --Intercepters
    }
    Builder = {
       BuilderName = 'P1UB1AirattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
       'P1UB1Airattack1',
       'NoPlan',
       { 'uea0103', 1, 5, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P1UB1AirattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
       'P1UB1Airattack2',
       'NoPlan',
       { 'uea0102', 1, 4, 'Attack', 'GrowthFormation' },
       { 'uea0103', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
       BuilderName = 'P1UB1AirattackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1UB1AirAttack2()
   
    local Temp = {
       'P1UB1Air2attack0',
       'NoPlan',
       { 'uea0102', 1, 8, 'Attack', 'GrowthFormation' },   
       { 'uea0203', 1, 5, 'Attack', 'GrowthFormation' },  

    }
    local Builder = {
       BuilderName = 'P1UB1Air2attackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
       'P1UB1Air2attack1',
       'NoPlan', 
       { 'uea0203', 1, 12, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
       BuilderName = 'P1UB1Air2attackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
       'P1UB1Air2attack3',
       'NoPlan',
       { 'dea0202', 1, 4, 'Attack', 'GrowthFormation' },   
       { 'uea0203', 1, 8, 'Attack', 'GrowthFormation' },  

    }
    Builder = {
       BuilderName = 'P1UB1Air2attackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1UB1AirAttack3()

    local Temp = {
       'P1UB1Airattack4',
       'NoPlan',
       { 'uea0203', 1, 7, 'Attack', 'GrowthFormation' },   
       { 'uea0305', 1, 3, 'Attack', 'GrowthFormation' },  

    }
    local Builder = {
       BuilderName = 'P1UB1AirattackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 300,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB1Airattack1', 'P1UB1Airattack2', 'P1UB1Airattack3', 'P1UB1Airattack4'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )    
end

function P1UB1NavalAttack1()

    local Temp = {
       'P1UB1NavalDefenceTemp0',
       'NoPlan',
       { 'ues0203', 1, 3, 'Attack', 'GrowthFormation' },
       { 'ues0103', 1, 3, 'Attack', 'GrowthFormation' },
       { 'ues0201', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P1UB1NavalDefenceBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 500,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1Navaldefence1'
       },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
   Temp = {
       'P1UB1NavalAttackTemp0',
       'NoPlan',
       { 'ues0103', 1, 4, 'Attack', 'GrowthFormation' },
       { 'ues0203', 1, 3, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P1UB1NavalBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1Navalattack1'
       },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1UB1NavalAttack2()

    local Temp = {
       'P1UB1NavalAttackTemp1',
       'NoPlan',
       { 'ues0201', 1, 2, 'Attack', 'GrowthFormation' },
       { 'ues0203', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P1UB1NavalBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 200,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1Navalattack1'
       },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder )
      
    Temp = {
       'P1UB1NavalAttackTemp2',
       'NoPlan',
       { 'ues0202', 1, 2, 'Attack', 'GrowthFormation' },
       { 'ues0103', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P1UB1NavalBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 200,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB1Navalattack1'
       },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1UB1landAttack1()
   
    local Temp = {
       'P1UB1Landattack0',
       'NoPlan',
       { 'uel0203', 1, 12, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P1UB1LandattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 200,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'WestNavelBaseP1',
      PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB1Landattack1', 'P1UB1Landattack2'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    opai = UEFM1WestBase:AddOpAI('EngineerAttack', 'M2_UEF_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1UB2MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uea0104})
   
   
    opai = UEFM1WestBase:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1UB2landingchainA1', 
                LandingChain = 'P1UB2landingchain1',
                TransportReturn = 'P1UB2MK',
            },
            Priority = 550,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 18)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 160})
    
    opai = UEFM1WestBase:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P1UB2landingchainA2', 
                LandingChain = 'P1UB2landingchain2',
                TransportReturn = 'P1UB2MK',
            },
            Priority = 550,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 18)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 210}) 
end 

function P1EastBaseAI()

    P1EastBase:InitializeDifficultyTables(ArmyBrains[UEF], 'P1UB2base2', 'P1UB1MK', 70, {P1Ubase2 = 100})
    P1EastBase:StartNonZeroBase({{6,9,12}, {4,7,10}})

    P1UB2AirAttack1()
    P1UB2LandAttack1()
    
    ForkThread(
        function()
            WaitSeconds(T2airandlandattacks[Difficulty])
            P1UB2LandAttack2()
            P1UB2AirAttack2()
        end
    )
        
    ForkThread(
        function()
            WaitSeconds(T3airandlandattacks[Difficulty])
            P1UB2LandAttack3()
        end
    )
end

function P1UB2LandAttack1()

    local Temp = {
        'P1B2Basedefense0',
        'NoPlan',
        { 'uel0303', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'uel0205', 1, 4, 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1B2BasedefenseBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 600,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UB2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1B2Defence1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
        
    Temp = {
        'P1UB2landAttacks0',
        'NoPlan',
        { 'uel0103', 1, 4, 'Attack', 'GrowthFormation' },
        { 'uel0201', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UB2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder ) 
   
    Temp = {
        'P1UB2landAttacks1',
        'NoPlan',
        { 'uel0106', 1, 8, 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P1UB2landattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 101,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UB2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1UB2LandAttack2()

    local Temp = {
        'P1UB2land2Attacks1',
        'NoPlan',
        { 'uel0202', 1, 8, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB2land2attackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UB2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    Temp = {
        'P1UB2land2Attacks2',
        'NoPlan',
        { 'uel0202', 1, 4, 'Attack', 'GrowthFormation' },
        { 'uel0205', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' }
    }
    Builder = {
        BuilderName = 'P1UB2land2attackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UB2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )   
   
    local Temp = {
        'P1UB2land2Attacks3',
        'NoPlan',
        { 'uel0303', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uel0111', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB2land2attackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UB2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1UB2LandAttack3()

    local Temp = {
       'P1UB2land3Attacks1',
       'NoPlan',
       { 'uel0303', 1, 3, 'Attack', 'GrowthFormation' },
       { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },
       { 'del0204', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P1UB2land3attackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 300,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1UB2base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
       },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
   Temp = {
       'P1UB2land3Attacks2',
       'NoPlan',
       { 'uel0303', 1, 2, 'Attack', 'GrowthFormation' },
       { 'uel0111', 1, 4, 'Attack', 'GrowthFormation' },
    }
   Builder = {
       BuilderName = 'P1UB2land3attackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 300,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1UB2base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
       },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
   Temp = {
       'P1UB2land3Attacks3',
       'NoPlan',
       { 'uel0303', 1, 4, 'Attack', 'GrowthFormation' },
       { 'uel0202', 1, 4, 'Attack', 'GrowthFormation' },
    }
   Builder = {
       BuilderName = 'P1UB2land3attackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 300,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1UB2base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
       },
   }
   ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
   
function P1UB2AirAttack1()

    local Temp = {
        'P1UB2AirAttacks0',
        'NoPlan',
        { 'uea0101', 1, 1, 'Attack', 'GrowthFormation' },
        { 'uea0102', 1, 3, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB2AirattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UB2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
   Temp = {
       'P1UB2AirAttacks1',
       'NoPlan',
       { 'uea0103', 1, 3, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P1UB2AirattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1UB2base2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2', 'P1UB2Landattack3'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
   
   Temp = {
       'P1UB2AirDefences0',
       'NoPlan',
       { 'uea0102', 1, 9, 'Attack', 'GrowthFormation' },
       { 'uea0103', 1, 6, 'Attack', 'GrowthFormation' },
       { 'uea0203', 1, 9, 'Attack', 'GrowthFormation' },
    }
    Builder = {
       BuilderName = 'P1UB2AirDefenceBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 400,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1UB2base2',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1UB2airdefence'
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
        
function P1UB2AirAttack2()

    local Temp = {
        'P1UB2AirAttacks2',
        'NoPlan',
        { 'uea0203', 1, 3, 'Attack', 'GrowthFormation' },
        { 'dea0202', 1, 3, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB2AirattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1UB2base2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB2Landattack1', 'P1UB2Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end     
        
function P1TACBaseAI()
    
    P1TACBase:InitializeDifficultyTables(ArmyBrains[UEF], 'P1UEFbase3', 'P1UB3MK', 50, { P1Ubase3 = 100})
    P1TACBase:StartNonZeroBase({{4,5,6}, {2,3,4}})
    P1TACBase:SetActive('LandScouting', true)
    
    P1UB3landDefence1()
    P1UB3landattack1()
    
    ForkThread(
        function()
            WaitSeconds(T2airandlandattacks[Difficulty])
            P1UB3landattack2()
        end
    )
end
    
function P1UB3landDefence1()

    local Temp = {
        'P1UB3landDefence0',
        'NoPlan',
        { 'uel0202', 1, 6, 'Attack', 'GrowthFormation' },      
        { 'uel0201', 1, 4, 'Attack', 'GrowthFormation' },  
        { 'uel0104', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1UB3landDefenceBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 600,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3LandDefence1'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function P1UB3landattack1()

    local Temp = {
        'P1UB3landattack0',
        'NoPlan',
        { 'uel0106', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'uel0201', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB3landattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1UB3landattack1',
        'NoPlan',
        { 'uel0104', 1, 2, 'Attack', 'GrowthFormation' },   
        { 'uel0201', 1, 6, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1UB3landattack2',
        'NoPlan',
        { 'uel0103', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'uel0201', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3landattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )  
end

function P1UB3landattack2()

    local Temp = {
        'P1UB3land2attack0',
        'NoPlan',
        { 'uel0201', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'uel0202', 1, 4, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1UB3land2attackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1UB3land2attack1',
        'NoPlan',
        { 'uel0103', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'del0204', 1, 2, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3land2attackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1UB3land2attack2',
        'NoPlan',
        { 'uel0201', 1, 4, 'Attack', 'GrowthFormation' },   
        { 'uel0111', 1, 4, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1UB3land2attackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1UEFbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1UB3Landattack1', 'P1UB3Landattack2'}
       },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

