local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Red_Revenge/FAF_Coop_Operation_Red_Revenge_CustomFunctions.lua'  

local Player1 = 1
local Order = 2
local Seraphim = 3
local QAI = 4
local UEF = 5
local Player2 = 6
local Player3 = 7
local Player3 = 8
local Difficulty = ScenarioInfo.Options.Difficulty

local Seraphimbase1 = BaseManager.CreateBaseManager()
local Seraphimbase2 = BaseManager.CreateBaseManager()
local Seraphimbase3 = BaseManager.CreateBaseManager()
local Seraphimbase4 = BaseManager.CreateBaseManager()

local Orderbase1 = BaseManager.CreateBaseManager()
local Orderbase2 = BaseManager.CreateBaseManager()
local QAIbase1 = BaseManager.CreateBaseManager()
local QAIbase2 = BaseManager.CreateBaseManager()
local QAIbase3 = BaseManager.CreateBaseManager()

function P2Seraphimbase1AI()
    	
    Seraphimbase1:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P2Seraphimbase', 'P2SB1MK', 80, {P2SBase1 = 100})
    Seraphimbase1:StartNonZeroBase({{10, 14, 18}, {8, 12, 16}})
    Seraphimbase1:SetActive('AirScouting', true)
   
    P2B1SLandattack()
    P2B1SAirattack() 
    P2SEXPattacks()
end

function P2B1SLandattack()

    local quantity = {}
    local trigger = {}
	
    quantity = {3, 4, 6}
	local Temp = {
        'P2SB1LandAttackTemp1',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	     
    }
    local Builder = {
        BuilderName = 'P2SB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB1Landattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 10}
    trigger = {60, 55, 50}
    Temp = {
        'P2SB1LandAttackTemp2',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB1Landattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {90, 85, 80}
    Temp = {
        'P2SB1LandAttackTemp3',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB1Landattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {45, 35, 25}
    Temp = {
        'P2SB1LandAttackTemp4',
        'NoPlan',
        { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB1LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB1Landattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    Temp = {
        'P2SB1LandAttackTemp5',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB1LandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB1Landattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end	

function P2B1SAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
       'P2SB1AirAttackTemp0',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P2SB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Seraphimbase',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2SB1ADefence1'
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P2SB1AirAttackTemp1',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2SB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2','P2SB1Airattack3','P2SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {6, 9, 12}
    trigger = {25, 20, 15}
    Temp = {
        'P2SB1AirAttackTemp2',
        'NoPlan',       
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P2SB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2','P2SB1Airattack3','P2SB1Airattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    trigger = {80, 70, 60}
    Temp = {
       'P2SB1AirAttackTemp3',
       'NoPlan',       
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P2SB1AirAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 125,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Seraphimbase',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2','P2SB1Airattack3','P2SB1Airattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    trigger = {20, 15, 10}
    Temp = {
       'P2SB1AirAttackTemp4',
       'NoPlan',       
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P2SB1AirAttackBuilder4',
       PlatoonTemplate = Temp,
       InstanceCount = 3,
       Priority = 250,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Seraphimbase',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2','P2SB1Airattack3','P2SB1Airattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    trigger = {20, 15, 10}
    Temp = {
       'P2SB1AirAttackTemp5',
       'NoPlan',       
       { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P2SB1AirAttackBuilder5',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Seraphimbase',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P2SB1Airattack1','P2SB1Airattack2','P2SB1Airattack3','P2SB1Airattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P2SEXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {1, 1, 2}
    trigger = {120, 100, 80}
    opai = Seraphimbase1:AddOpAI('P2SExp1',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
            PlatoonData = {
                PatrolChain = 'P2SB1Landattack1',
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1, '>='},
                },
            }
        }
    ) 
end

function P2Seraphimbase2AI()
        
    Seraphimbase2:Initialize(ArmyBrains[Seraphim], 'P2Seraphimbase2', 'P2SB2MK', 40, {P2SBase2 = 100})
    Seraphimbase2:StartNonZeroBase({{3, 4, 5}, {2, 3, 4}})
   
    Seraphimbase1:AddExpansionBase('P2Seraphimbase2', 2)
    P2B2SLandattack()
end

function P2B2SLandattack()

    local quantity = {}
    local trigger = {}
    
    quantity = {3, 4, 6}
    local Temp = {
        'P2SB2LandAttackTemp1',
        'NoPlan',
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    local Builder = {
        BuilderName = 'P2SB2LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Landattack1','P2SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {45, 40, 35}
    Temp = {
        'P2SB2LandAttackTemp2',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB2LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Landattack1','P2SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {80, 70, 60}
    Temp = {
        'P2SB2LandAttackTemp3',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB2LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Landattack1','P2SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {40, 35, 30}
    Temp = {
        'P2SB2LandAttackTemp4',
        'NoPlan',
        { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB2LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Landattack1','P2SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    Temp = {
        'P2SB2LandAttackTemp5',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2SB2LandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 225,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB2Landattack1','P2SB2Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end 

function P2Seraphimbase3AI()
        
    Seraphimbase3:Initialize(ArmyBrains[Seraphim], 'P2Seraphimbase3', 'P2SB3MK', 40, {P2SBase3 = 100})
    Seraphimbase3:StartNonZeroBase({{3, 4, 5}, {2, 3, 4}})
    
    Seraphimbase1:AddExpansionBase('P2Seraphimbase3', 2)
    P2B3SLandattack()
end

function P2B3SLandattack()

    local quantity = {}
    local trigger = {}
    
    quantity = {3, 4, 6}
    local Temp = {
        'P2SB3LandAttackTemp1',
        'NoPlan',
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    local Builder = {
        BuilderName = 'P2SB3LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB3Landattack1','P2SB3Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {45, 40, 35}
    Temp = {
        'P2SB3LandAttackTemp2',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB3LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB3Landattack1','P2SB3Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {90, 80, 70}
    Temp = {
        'P2SB3LandAttackTemp3',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB3LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB3Landattack1','P2SB3Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {30, 25, 20}
    Temp = {
        'P2SB3LandAttackTemp4',
        'NoPlan',
        { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P2SB3LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 215,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB3Landattack1','P2SB3Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    Temp = {
        'P2SB3LandAttackTemp5',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2SB3LandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 225,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2SB3Landattack1','P2SB3Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end 

function P2Seraphimbase4AI()
        
    Seraphimbase4:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P2Seraphimbase4', 'P2SB4MK', 60, {P2SBase4 = 100})
    Seraphimbase4:StartNonZeroBase({{3, 4, 5}, {2, 3, 4}})
    
    Seraphimbase1:AddExpansionBase('P2Seraphimbase4', 2)
    P2B4SNavalattack()
end

function P2B4SNavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P2SB4NavalAttackTemp0',
        'NoPlan',         
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P2SB4NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB4Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {35, 30, 25}
    Temp = {
        'P2SB4NavalAttackTemp1',
        'NoPlan',         
        { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P2SB4NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB4Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {35, 30, 25}
    Temp = {
        'P2SB4NavalAttackTemp2',
        'NoPlan',         
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2SB4NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB4Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    trigger = {45, 40, 35}
    Temp = {
        'P2SB4NavalAttackTemp3',
        'NoPlan',         
        { 'xss0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2SB4NavalAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 210,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB4Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {35, 25, 20}
    Temp = {
        'P2SB4NavalAttackTemp4',
        'NoPlan',         
        { 'xss0302', 1, 2, 'Attack', 'GrowthFormation' },
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2SB4NavalAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Seraphimbase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P2SB4Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

-- Order Base

function P2Orderbase1AI()
        
    Orderbase1:InitializeDifficultyTables(ArmyBrains[Order], 'P2Orderbase1', 'P2OB1MK', 80, {P2OBase1 = 100})
    Orderbase1:StartNonZeroBase({{11, 16, 20}, {9, 14, 18}})
    Orderbase1:SetActive('AirScouting', true)
   
    P2B1OLandattack()
    P2B1OAirattack() 
    P2B1ONavalattack()
end

function P2B1OLandattack()

    local quantity = {}
    local trigger = {}

    quantity = {6, 9, 12}
    local Temp = {
        'P2B1OLandAttackTemp0',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },           
    }
    local Builder = {
        BuilderName = 'P2B1OLandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Landattack1','P2OB1Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {6, 9, 12}
    trigger = {50, 45, 40}
    Temp = {
        'P2B1OLandAttackTemp1',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P2B1OLandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE- categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Landattack1','P2OB1Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {3, 5, 6}
    trigger = {100, 90, 80}
    Temp = {
        'P2B1OLandAttackTemp2',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P2B1OLandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2OB1Landattack1','P2OB1Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 9}
    trigger = {25, 20, 15}
    Temp = {
        'P2B1OLandAttackTemp3',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },             
    }
    Builder = {
        BuilderName = 'P2B1OLandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2OB1Landattack1','P2OB1Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {50, 45, 40}
    Temp = {
        'P2B1OLandAttackTemp4',
        'NoPlan',
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'dalk003', 1, 2, 'Attack', 'GrowthFormation' },             
    }
    Builder = {
        BuilderName = 'P2B1OLandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Landattack1','P2OB1Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end 

function P2B1OAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
       'P2OB1AirAttackTemp0',
       'NoPlan',     
       { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P2OB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Orderbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2OB1ADefence1'
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {6, 7, 9}
    Temp = {
        'P2OB1AirAttackTemp1',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2OB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2','P2OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {3, 6, 9}
    trigger = {35, 35, 25}
    Temp = {
        'P2OB1AirAttackTemp2',
        'NoPlan',
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2OB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2','P2OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {2, 4, 6}
    trigger = {20, 15, 10}
    Temp = {
        'P2OB1AirAttackTemp3',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2OB1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 250,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.AIR}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2','P2OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {3, 4, 6}
    trigger = {20, 15, 10}
    Temp = {
        'P2OB1AirAttackTemp4',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2OB1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Airattack1','P2OB1Airattack2','P2OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 
end

function P2B1ONavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6}
    local Temp = {
        'P2OB1NavalAttackTemp0',
        'NoPlan',         
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xas0204', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2OB1NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Navalattack1','P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {3, 3, 4}
    trigger = {80, 70, 60}
    Temp = {
        'P2OB1NavalAttackTemp1',
        'NoPlan',         
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P2OB1NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Navalattack1','P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {30, 25, 20}
    Temp = {
        'P2OB1NavalAttackTemp2',
        'NoPlan',         
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P2OB1NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Navalattack1','P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {25, 20, 15}
    Temp = {
        'P2OB1NavalAttackTemp3',
        'NoPlan',         
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P2OB1NavalAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB1Navalattack1','P2OB1Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P2Orderbase2AI()
        
    Orderbase2:InitializeDifficultyTables(ArmyBrains[Order], 'P2Orderbase2', 'P2OB2MK', 50, {P2OBase2 = 100})
    Orderbase2:StartNonZeroBase({{6, 8, 10}, {4, 6, 8}})
   
    P2B2OLandattack()
end

function P2B2OLandattack()

    local quantity = {}
    local trigger = {}

    quantity = {6, 9, 12}
    local Temp = {
        'P2B2OLandAttackTemp0',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },           
    }
    local Builder = {
        BuilderName = 'P2B2OLandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB2Landattack1','P2OB2Landattack2','P2OB2Landattack3','P2OB2Landattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
        
    quantity = {4, 6, 8}
    trigger = {50, 45, 40}
    Temp = {
        'P2B2OLandAttackTemp1',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },           
    }
    Builder = {
        BuilderName = 'P2B2OLandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB2Landattack1','P2OB2Landattack2','P2OB2Landattack3','P2OB2Landattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {30, 25, 20}
    Temp = {
        'P2B2OLandAttackTemp2',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P2B2OLandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2OB2Landattack1','P2OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {90, 80, 70}
    Temp = {
        'P2B2OLandAttackTemp3',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P2B2OLandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2OB2Landattack1','P2OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 10}
    trigger = {25, 20, 15}
    Temp = {
        'P2B2OLandAttackTemp4',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
        { 'dalk003', 1, 2, 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P2B2OLandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P2Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P2OB2Landattack1','P2OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end 

-- QAI Base

function P2QAIbase1AI()
        
    QAIbase1:InitializeDifficultyTables(ArmyBrains[QAI], 'P2QAIbase1', 'P2QB1MK', 80, {P2QBase1 = 100})
    QAIbase1:StartNonZeroBase({{9, 14, 16}, {6, 9, 12}})
    QAIbase1:SetActive('AirScouting', true)

    QAIbase1:AddBuildGroupDifficulty('P2QBaseEXD', 110, false)
   
    P2B1QLandattack()
    P2B1QAirattack() 
    P2B1QNavalattack()
    P2QEXPattacks()
end

function P2B1QLandattack()

    local quantity = {}
    local trigger = {}
    local opai = nil

    quantity = {3, 4, 5}
    opai = QAIbase1:AddOpAI('EngineerAttack', 'M2_AEON_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2QB1MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 30})
    
    quantity = {12, 16, 20}
    opai = QAIbase1:AddOpAI('BasicLandAttack', 'M2_QAI_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2CB1Dropattack1', 
                LandingChain = 'P2CB1Drop1',
                TransportReturn = 'P2QB1MK',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    quantity = {4, 8, 12}
    opai = QAIbase1:AddOpAI('BasicLandAttack', 'M2_QAI_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2CB1Dropattack1', 
                LandingChain = 'P2CB1Drop1',
                TransportReturn = 'P2QB1MK',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    quantity = {6, 8, 10}
    opai = QAIbase1:AddOpAI('BasicLandAttack', 'M2_QAI_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2CB1Dropattack1', 
                LandingChain = 'P2CB1Drop1',
                TransportReturn = 'P2QB1MK',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Siegebots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 40, categories.ALLUNITS - categories.TECH1, '>='})

    quantity = {6, 8, 10}
    opai = QAIbase1:AddOpAI('BasicLandAttack', 'M2_QAI_TransportAttack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2CB1Dropattack1', 
                LandingChain = 'P2CB1Drop1',
                TransportReturn = 'P2QB1MK',
            },
            Priority = 205,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 5, categories.TECH3, '>='})

    quantity = {6, 8, 10}
    opai = QAIbase1:AddOpAI('BasicLandAttack', 'M2_QAI_TransportAttack_5',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2CB1Dropattack1', 
                LandingChain = 'P2CB1Drop1',
                TransportReturn = 'P2QB1MK',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 15, categories.TECH3, '>='})
end 

function P2B1QAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
       'P2CB1AirAttackTemp0',
       'NoPlan',     
       { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'dra0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P2CB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2QAIbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P2CB1ADefence1'
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P2CB1AirAttackTemp1',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2CB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2QAIbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2CB1Airattack1','P2CB1Airattack2','P2CB1Airattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder ) 

    quantity = {2, 4, 6}
    trigger = {15, 10, 5}
    Temp = {
        'P2CB1AirAttackTemp2',
        'NoPlan',
        { 'ura0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2CB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2QAIbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.AIR}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2CB1Airattack1','P2CB1Airattack2','P2CB1Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder ) 

    quantity = {2, 3, 4}
    trigger = {80, 70, 60}
    Temp = {
        'P2CB1AirAttackTemp3',
        'NoPlan',
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2CB1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 115,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2QAIbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2CB1Airattack1','P2CB1Airattack2','P2CB1Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder ) 

    quantity = {3, 4, 5}
    trigger = {30, 20, 15}
    Temp = {
        'P2CB1AirAttackTemp4',
        'NoPlan',
        { 'xra0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P2CB1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P2QAIbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2CB1Airattack1','P2CB1Airattack2','P2CB1Airattack3'}
       },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P2B1QNavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {2, 2, 3}
    local Temp = {
        'P2QB1AirAttackTemp0',
        'NoPlan',         
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P2QB1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2QAIbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2CB1Navalattack1','P2CB1Navalattack2'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {18, 14, 10}
    Temp = {
        'P2QB1AirAttackTemp1',
        'NoPlan',         
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P2QB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P2QAIbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P2CB1Navalattack1','P2CB1Navalattack2'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P2QEXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    trigger = {50, 25, 10}
    opai = QAIbase1:AddOpAI('P2QBug',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M3_BuG_Platoon1',
                NumRequired = 2,
                PatrolChain = 'P2CB1Airattack' .. Random(1, 3),
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

-- Bases for QAI if he lives to Part 3

function P3QAIbase1AI()
        
    QAIbase2:InitializeDifficultyTables(ArmyBrains[QAI], 'P3QAIbase1', 'P3QB1MK', 40, {P3QBase1 = 100})
    QAIbase2:StartEmptyBase({{8, 11, 14}, {6, 9, 12}})

    QAIbase1:AddExpansionBase('P3QAIbase1', 4)
   
    P3B1QNavalattack()
    P3QB1EXPattacks()
end

function P3B1QNavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 6, 9}
    local Temp = {
        'P3QB1AirAttackTemp0',
        'NoPlan',         
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3QB1AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3QAIbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3CB1Navalattack1','P3CB1Navalattack2','P3CB1Navalattack3'}
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {25, 20, 15}
    Temp = {
        'P3QB1AirAttackTemp1',
        'NoPlan',         
        { 'urs0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'urs0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xrs0305', 1, 1, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3QB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3QAIbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3CB1Navalattack1',
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {25, 20, 15}
    Temp = {
        'P3QB1AirAttackTemp2',
        'NoPlan',         
        { 'urs0302', 1, 2, 'Attack', 'GrowthFormation' },
        { 'xrs0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xrs0305', 1, 1, 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3QB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3QAIbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3CB1Navalattack1',
        },
    }
    ArmyBrains[QAI]:PBMAddPlatoon( Builder )
end

function P3QB1EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = QAIbase2:AddOpAI('P3QBot2',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P3CB1Navalattack1','P3CB1Navalattack2','P3CB1Navalattack3'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    ) 
end

function P3QAIbase2AI()
        
    QAIbase3:Initialize(ArmyBrains[QAI], 'P3QAIbase2', 'P2QB1MK', 30, {P3QBase2 = 100})
    QAIbase3:StartNonZeroBase({2, 3, 4})

    QAIbase1:AddExpansionBase('P3QAIbase2', 3)
   
    P3QB2EXPattacks()
end

function P3QB2EXPattacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    quantity = {2, 3, 4}
    opai = QAIbase3:AddOpAI('P3QBot1',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
            MoveChains = {'P2CB1Navalattack1','P2CB1Navalattack2'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    ) 
end