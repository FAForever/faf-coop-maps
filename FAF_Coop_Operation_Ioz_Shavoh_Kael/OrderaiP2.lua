local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'

local Player1 = 1
local KOrder = 4
local Order = 3

local P2KO1base1 = BaseManager.CreateBaseManager()
local P2O1base1 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function P2KO1Base1AI()

    P2KO1base1:InitializeDifficultyTables(ArmyBrains[KOrder], 'P2KOrder1Base1', 'P2KO1base1MK', 140, {P2KO1Base1 = 100})
    P2KO1base1:StartNonZeroBase({{12, 18, 24}, {10, 15, 20}})
    P2KO1base1:SetActive('AirScouting', true)

    if Difficulty == 3 then
        ArmyBrains[KOrder]:PBMSetCheckInterval(6)
    end

    P2KO1B1Airattacks()
    P2KO1B1Landattacks()
    P2KO1B1Navalattacks()
    P2KO1B1EXPattacks()
end

function P2KO1B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 9}
    local Temp = {
        'P2KO1B1AttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    local Builder = {
        BuilderName = 'P2KO1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Airattack1','P2KOB1Airattack2', 'P2KOB1Airattack3','P2KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {20, 15, 10}
    Temp = {
        'P2KO1B1AttackTemp1',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
    }
    Builder = {
        BuilderName = 'P2KO1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Airattack1','P2KOB1Airattack2', 'P2KOB1Airattack3','P2KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {9, 7, 5}
    Temp = {
        'P2KO1B1AttackTemp2',
        'NoPlan',
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2KO1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Airattack1','P2KOB1Airattack2', 'P2KOB1Airattack3','P2KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {30, 25, 20}
    Temp = {
        'P2KO1B1AttackTemp3',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2KO1B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Airattack1','P2KOB1Airattack2', 'P2KOB1Airattack3','P2KOB1Airattack4'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P2KO1B1Landattacks()

    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    local Temp = {
        'P2KO1B1LAttackTemp0',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P2KO1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Landattack1', 'P2KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {4, 6, 8}
    trigger = {25, 20, 14}
    Temp = {
        'P2KO1B1LAttackTemp1',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2KO1B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2KOB1Landattack1', 'P2KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon(Builder)
    
    quantity = {3, 4, 6}
    trigger = {8, 7, 6}
    Temp = {
        'P2KO1B1LAttackTemp2',
        'NoPlan',
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2KO1B1LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Landattack1', 'P2KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    trigger = {2, 2, 1}
    Temp = {
        'P2KO1B1LAttackTemp3',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },
        { 'dalk003', 1, 2, 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2KO1B1LAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2KOB1Landattack1', 'P2KOB1Landattack2'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P2KO1B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6}
    local Temp = {
        'P2KO1B1NAttackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P2KO1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Navalattack1','P2KOB1Navalattack2', 'P2KOB1Navalattack3'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 2, 3}
    trigger = {25, 20, 14}
    Temp = {
        'P2KO1B1NAttackTemp1',
        'NoPlan',
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P2KO1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Navalattack1','P2KOB1Navalattack2', 'P2KOB1Navalattack3'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
    
    quantity = {2, 2, 3}
    trigger = {3, 3, 2}
    Temp = {
        'P2KO1B1NAttackTemp2',
        'NoPlan',
        { 'xas0204', 1, 4, 'Attack', 'GrowthFormation' },
        { 'uas0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2KO1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Navalattack1','P2KOB1Navalattack2', 'P2KOB1Navalattack3'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )

    quantity = {4, 7, 9}
    trigger = {6, 5, 4}
    Temp = {
        'P2KO1B1NAttackTemp3',
        'NoPlan',
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P2KO1B1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2KOrder1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2KOB1Navalattack1','P2KOB1Navalattack2', 'P2KOB1Navalattack3'}
        },
    }
    ArmyBrains[KOrder]:PBMAddPlatoon( Builder )
end

function P2KO1B1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    trigger = {40, 30, 25}
    opai = P2KO1base1:AddOpAI('KObot1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
                PatrolChains = {'P2KOB1Landattack1', 'P2KOB1Landattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='},
                },
            }
        }
    )
end

function P2O1Base1AI()

    P2O1base1:InitializeDifficultyTables(ArmyBrains[Order], 'P2Order1Base1', 'P2Obase1MK', 140, {P2O1Base1 = 100})
    P2O1base1:StartNonZeroBase({{12, 15, 19}, {10, 12, 15}})
    P2O1base1:SetActive('AirScouting', true)

    if Difficulty == 3 then
        ArmyBrains[Order]:PBMSetCheckInterval(6)
    end

    P2O1B1Airattacks()
    P2O1B1Navalattacks()
    P2O1B1Landattacks()
    P2OB1EXPattacks()
end

function P2O1B1Airattacks()

    local quantity = {}
    local trigger = {}

    quantity = {6, 9, 12}
    local Temp = {
        'P2O1B1AAttackTemp0',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   
    }
    local Builder = {
        BuilderName = 'P2O1B1AAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2', 'P2OB1Airattack3','P2OB1Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {5, 6, 8}
    trigger = {20, 15, 10}
    Temp = {
        'P2O1B1AAttackTemp1',
        'NoPlan',
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   
    }
    Builder = {
        BuilderName = 'P2O1B1AAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2', 'P2OB1Airattack3','P2OB1Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {6, 8, 10}
    trigger = {20, 15, 10}
    Temp = {
        'P2O1B1AAttackTemp2',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   
    }
    Builder = {
        BuilderName = 'P2O1B1AAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2', 'P2OB1Airattack3','P2OB1Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    trigger = {9, 8, 7}
    Temp = {
        'P2O1B1AAttackTemp3',
        'NoPlan',
        { 'uaa0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   
    }
    Builder = {
        BuilderName = 'P2O1B1AAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2', 'P2OB1Airattack3','P2OB1Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P2O1B1Landattacks()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P2O1B1LAttackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P2O1B1LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Landattack1','P2OB1Landattack2','P2OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    trigger = {10, 7, 5}
    Temp = {
        'P2O1B1LAttackTemp1',
        'NoPlan',
        { 'dal0310', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2O1B1LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.STRUCTURE * categories.SHIELD}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Landattack1','P2OB1Landattack2','P2OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )   

    local opai = nil
    local trigger = {}
    local poolName = 'P2Order1Base1_TransportPool'
    
    local quantity = {2, 3, 4}
    -- T2 Transport Platoon
    local Temp = {
        'M2_Order_SouthEastern_Transport_Platoon',
        'NoPlan',
        { 'uaa0104', 1, quantity[Difficulty], 'Attack', 'None' }, -- T2 Transport
    }
    local Builder = {
        BuilderName = 'M2_OrderSouthEastern_Transport_Platoon',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveLessThanUnitsInTransportPool', {quantity[Difficulty], poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'TransportPool'},
        PlatoonData = {
            BaseName = 'P2Order1Base1',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    local Quantity1 = {2, 2, 3}
    local Quantity2 = {3, 4, 6}
    Builder = {
        BuilderName = 'M2_Order_Land_Assault',
        PlatoonTemplate = {
            'M2_Order_Land_Assault_Template',
            'NoPlan',
            {'ual0202', 1, Quantity2[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'ual0111', 1, Quantity1[Difficulty], 'Artillery', 'GrowthFormation'}, -- T2 Arty
            {'ual0205', 1, Quantity1[Difficulty], 'Attack', 'GrowthFormation'},    -- T2 AA
        },
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
            {CustomFunctions, 'HaveGreaterOrEqualThanUnitsInTransportPool', {2, poolName}},
        },
        PlatoonAIFunction = {CustomFunctions, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'P2OB1Dropattack',
            LandingChain = 'P2OB1Drop',
            TransportReturn = 'P2Obase1MK',
            BaseName = 'P2Order1Base1',
            GenerateSafePath = true,
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P2O1B1Navalattacks()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2O1B1NAttackTemp0',
        'NoPlan',
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }    
    }
    local Builder = {
        BuilderName = 'P2O1B1NAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {2, 2, 4}
    trigger = {20, 15, 10}
    Temp = {
        'P2O1B1NAttackTemp1',
        'NoPlan',
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2O1B1NAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {20, 15, 10}
    Temp = {
        'P2O1B1NAttackTemp2',
        'NoPlan',
        { 'uas0202', 1, 3, 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2O1B1NAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    trigger = {50, 40, 35}
    Temp = {
        'P2O1B1NAttackTemp3',
        'NoPlan',
        { 'xas0306', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P2O1B1NAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Order1Base1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P2OB1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    trigger = {7, 6, 4}
    opai = P2O1base1:AddOpAI('P2OSub',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
                PatrolChains = {'P2OB1Navalattack1', 'P2OB1Navalattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.TECH3, '>='},
                },
            }
        }
    )
end
