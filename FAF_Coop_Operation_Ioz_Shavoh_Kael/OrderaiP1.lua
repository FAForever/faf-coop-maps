local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local KOrder = 4
local Order = 3

local P1KO1base1 = BaseManager.CreateBaseManager()
local P1KO1base2 = BaseManager.CreateBaseManager()
local P1O1base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P1KO1Base1AI()

    P1KO1base1:InitializeDifficultyTables(ArmyBrains[KOrder], 'P1KOrder1Base1', 'P1KO1base1MK', 80, {P1KO1Base1 = 100})
    P1KO1base1:StartNonZeroBase({{14,18,22}, {12,16,20}})
    P1KO1base1:SetActive('AirScouting', true)

    P1KO1B1Airattacks1()
    P1KO1B1Navalattacks1()
    P1KO1B1Landattacks1()
    
    ForkThread(
        function()
            WaitSeconds(13*60)
            P1KO1B1Airattacks2()
        end
    )
    ForkThread(
        function()
            WaitSeconds(15*60)
            P1KO1B1Navalattacks2()
        end
    )
    
    ForkThread(
        function()
            WaitSeconds(11*60)
            P1KO1B1Landattacks2()
        end
    ) 
end

function P1O1Base1AI()

    P1O1base1:InitializeDifficultyTables(ArmyBrains[Order], 'P1Order1Base1', 'P1O1base1MK', 70, {P1O1Base1 = 100})
    P1O1base1:StartNonZeroBase({{11,9,7}, {10,8,6}})
    
    P1O1B1Navalattacks1()
    P1O1B1Airattacks1()
    P1O1B1Landattacks1()
end

function P1KO1B1Airattacks1()

    local Temp = {
        'P1KO1B1AttackTemp0',
        'NoPlan',
        { 'uaa0102', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1airattack1','P1KO1Base1airattack2', 'P1KO1Base1airattack3','P1KO1Base1airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B1AttackTemp1',
        'NoPlan',
        { 'uaa0103', 1, 7, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1airattack1','P1KO1Base1airattack2', 'P1KO1Base1airattack3','P1KO1Base1airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B1AttackTemp2',
        'NoPlan',
        { 'uaa0203', 1, 10, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, 6, 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KO1base1airDefence1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B1AttackTemp4',
        'NoPlan',
        { 'uaa0203', 1, 10, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, 5, 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xaa0306', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KO1base1airDefence2'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1KO1B1Airattacks2()

    local Temp = {
        'P1KO1B1AttackTemp5',
        'NoPlan',
        { 'xaa0202', 1, 7, 'Attack', 'GrowthFormation' },     
    }
    local Builder = {
        BuilderName = 'P1KO1B1AttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1airattack1','P1KO1Base1airattack2', 'P1KO1Base1airattack3', 'P1KO1Base1airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B1AttackTemp6',
        'NoPlan',
        { 'uaa0203', 1, 10, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1KO1B1AttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1airattack1','P1KO1Base1airattack2', 'P1KO1Base1airattack3', 'P1KO1Base1airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1C1B1AttackTemp7',
        'NoPlan',
        { 'uaa0203', 1, 6, 'Attack', 'GrowthFormation' },
        { 'xaa0305', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1C1B1AttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1airattack1','P1KO1Base1airattack2', 'P1KO1Base1airattack3', 'P1KO1Base1airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1KO1B1Landattacks1()

    local Temp = {
        'P1KO1B2LAttackTemp0',
        'NoPlan',
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'ual0201', 1, 8, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base2landattack1'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B2LAttackTemp1',
        'NoPlan',
        { 'ual0103', 1, 5, 'Attack', 'GrowthFormation' }, 
        { 'ual0202', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base2landattack1'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B2LAttackTemp2',
        'NoPlan',
        { 'ual0201', 1, 5, 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 3, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base2landattack1'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B2LAttackTemp3',
        'NoPlan',
        { 'xal0203', 1, 4, 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 2, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base2landattack1'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1KO1B1Landattacks2()

    local Temp = {
        'P1KO1B2LAttackTemp4',
        'NoPlan',
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'ual0202', 1, 6, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base2landattack1'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B2LAttackTemp5',
        'NoPlan',
        { 'ual0111', 1, 4, 'Attack', 'GrowthFormation' }, 
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base2landattack1'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B2LAttackTemp6',
        'NoPlan',
        { 'ual0303', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'ual0202', 1, 4, 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1KO1B2LAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'MoveToThread'}, 
        PlatoonAddFunctions = {
            {
            '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_script.lua', 'RemoveCommandCapFromPlatoon',
            },
        },
        PlatoonData = {
            MoveChain = 'P1KO1Base2landattack1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1KO1B1Navalattacks1()

    local Temp = {
        'P1KO1B1NAttackTemp0',
        'NoPlan',
        { 'uas0203', 1, 8, 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, 6, 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, 3, 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1KO1Base1navaldefence1'
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B1NAttackTemp1',
        'NoPlan',
        { 'uas0103', 1, 5, 'Attack', 'GrowthFormation' },   
        { 'uas0203', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1navalattack1', 'P1KO1Base1navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B1NAttackTemp2',
        'NoPlan',
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, 3, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1navalattack1', 'P1KO1Base1navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1KO1B1NAttackTemp3',
        'NoPlan',
        { 'uas0103', 1, 5, 'Attack', 'GrowthFormation' },   
        { 'uas0203', 1, 4, 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1navalattack1', 'P1KO1Base1navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1KO1B1Navalattacks2()

    local Temp = {
        'P1KO1B1NAttackTemp4',
        'NoPlan',
        { 'uas0203', 1, 2, 'Attack', 'GrowthFormation' },   
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, 3, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1KO1B1NAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1KO1Base1navalattack1', 'P1KO1Base1navalattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P1O1B1Airattacks1()

    local Temp = {
        'P1O1B1AttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, 8, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, 6, 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1O1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1O1Base1airDefence1'
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1O1B1AttackTemp1',
        'NoPlan',
        { 'uaa0203', 1, 6, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, 4, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1O1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1O1Base1airattack1','P1O1Base1airattack2','P1O1Base1airattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P1O1B1Navalattacks1()

    local Temp = {
        'P1O1B1NAttackTemp0',
        'NoPlan',
        { 'uas0102', 1, 6, 'Attack', 'GrowthFormation' },   
        { 'uas0103', 1, 4, 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, 6, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1O1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P1O1Base1NavalDefence1'
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    Temp = {
        'P1O1B1NAttackTemp1',
        'NoPlan',  
        { 'uas0103', 1, 3, 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, 1, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P1O1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1O1Base1navalattack1', 'P1O1Base1navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P1O1B1Landattacks1()

    local Temp = {
        'P1O1B1LAttackTemp0',
        'NoPlan',
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'ual0201', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xal0203', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P1O1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P1O1Base1navalattack1', 'P1O1Base1navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )  
end
