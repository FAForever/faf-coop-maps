local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Red_Revenge/FAF_Coop_Operation_Red_Revenge_CustomFunctions.lua'  

local Player1 = 1
local Order = 2
local Seraphim = 3
local Player2 = 6
local Player3 = 7
local Player4 = 8
local Difficulty = ScenarioInfo.Options.Difficulty

local Seraphimbase1 = BaseManager.CreateBaseManager()
local Seraphimbase2 = BaseManager.CreateBaseManager()

local Orderbase1 = BaseManager.CreateBaseManager()
local Orderbase2 = BaseManager.CreateBaseManager()
local Orderbase3 = BaseManager.CreateBaseManager()
local Orderbase4 = BaseManager.CreateBaseManager()

function Seraphimbase1AI()
    	
    Seraphimbase1:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P1Seraphimbase', 'P1SB1MK', 80, {P1SBase1 = 100})
    Seraphimbase1:StartNonZeroBase({{11, 15, 20}, {9, 13, 18}})
    Seraphimbase1:SetActive('AirScouting', true)
   
    P1B1SLandattack()
    P1B1SAirattack() 
end

function P1B1SLandattack()

    local quantity = {}
    local trigger = {}

    opai = Seraphimbase1:AddOpAI('EngineerAttack', 'P1SB1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
	
    quantity = {4, 6, 7}
	local Temp = {
        'P1SB1LandAttackTemp1',
        'NoPlan',
        { 'xsl0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	     
    }
    local Builder = {
        BuilderName = 'P1SB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 7}
    trigger = {25, 20, 15}
    Temp = {
        'P1SB1LandAttackTemp2',
        'NoPlan',
        { 'xsl0104', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1SB1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 7}
    trigger = {5, 4, 3}
    Temp = {
       'P1SB1LandAttackTemp3',
       'NoPlan',
       { 'xsl0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1SB1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {10, 9, 7}
    Temp = {
        'P1SB1LandAttackTemp4',
        'NoPlan',
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1SB1LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {18, 12, 10}
    Temp = {
        'P1SB1LandAttackTemp5',
        'NoPlan',
        { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1SB1LandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.GROUNDATTACK - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 5}
    trigger = {12, 9, 6}
    Temp = {
        'P1SB1LandAttackTemp6',
        'NoPlan',
        { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1SB1LandAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 215,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    trigger = {45, 35, 25}
    Temp = {
        'P1SB1LandAttackTemp7',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1SB1LandAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {65, 55, 50}
    Temp = {
        'P1SB1LandAttackTemp8',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1SB1LandAttackBuilder8',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 214,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    quantity2 = {4, 6, 8}
    trigger = {20, 15, 10}
    Temp = {
        'P1SB1LandAttackTemp9',
        'NoPlan',
        { 'xsl0202', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1SB1LandAttackBuilder9',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1landattack1','P1SB1landattack2','P1SB1landattack3','P1SB1landattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end	

function P1B1SAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
       'P1SB1AirAttackTemp0',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P1SB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1SB1ADefence1'
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    Temp = {
        'P1SB1AirAttackTemp1',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1SB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {25, 20, 15}
    Temp = {
        'P1SB1AirAttackTemp2',
        'NoPlan',       
        { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1SB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 101,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 7}
    quantity2 = {1, 2, 3}
    trigger = {25, 20, 15}
    Temp = {
        'P1SB1AirAttackTemp3',
        'NoPlan',       
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsa0203', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },      
    }
    Builder = {
        BuilderName = 'P1SB1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {40, 35, 30}
    Temp = {
        'P1SB1AirAttackTemp4',
        'NoPlan',       
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1SB1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {25, 20, 15}
    Temp = {
        'P1SB1AirAttackTemp5',
        'NoPlan',       
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1SB1AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 201,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {8, 10, 12}
    trigger = {70, 65, 60}
    Temp = {
        'P1SB1AirAttackTemp6',
        'NoPlan',       
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1SB1AirAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 7}
    trigger = {40, 30, 25}
    Temp = {
        'P1SB1AirAttackTemp7',
        'NoPlan',       
        { 'xsa0303', 1, 3, 'Attack', 'GrowthFormation' },
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1SB1AirAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 310,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function Orderbase1AI()
        
    Orderbase1:InitializeDifficultyTables(ArmyBrains[Order], 'P1Orderbase1', 'P1OB1MK', 80, {P1OBase1 = 100})
    Orderbase1:StartNonZeroBase({{7, 10, 12}, {5, 8, 10}})
    Orderbase1:SetActive('AirScouting', true)
   
    P1B1OLandattack()
    P1B1OAirattack() 
end

function P1B1OLandattack()

    local quantity = {}
    local trigger = {}

    opai = Orderbase1:AddOpAI('EngineerAttack', 'P1OB1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1OB1Landattack1','P1OB1Landattack2'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)

    quantity = {3, 4, 6}
    trigger = {12, 9, 6}
    local Temp = {
        'P1B1OLandAttackTemp0',
        'NoPlan',
        { 'ual0106', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    local Builder = {
        BuilderName = 'P1B1OLandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Landattack1','P1OB1Landattack2','P1OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    trigger = {35, 30, 25}
    Temp = {
        'P1B1OLandAttackTemp1',
        'NoPlan',
        { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1B1OLandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Landattack1','P1OB1Landattack2','P1OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {9, 7, 5}
    Temp = {
        'P1B1OLandAttackTemp2',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1B1OLandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Landattack1','P1OB1Landattack2','P1OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {20, 16, 14}
    Temp = {
        'P1B1OLandAttackTemp3',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1B1OLandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Landattack1','P1OB1Landattack2','P1OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 9}
    trigger = {36, 30, 25}
    Temp = {
        'P1B1OLandAttackTemp4',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1B1OLandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Landattack1','P1OB1Landattack2','P1OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {20, 15, 10}
    Temp = {
        'P1B1OLandAttackTemp5',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1B1OLandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Landattack1','P1OB1Landattack2','P1OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    quantity2 = {3, 4, 6}
    trigger = {70, 65, 60}
    Temp = {
        'P1B1OLandAttackTemp6',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0202', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P1B1OLandAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 300,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P1OB1Landattack1','P1OB1Landattack2','P1OB1Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end 

function P1B1OAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
       'P1OB1AirAttackTemp0',
       'NoPlan',     
       { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P1OB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Orderbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1OB1ADefence1'
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {25, 20, 15}
    Temp = {
        'P1OB1AirAttackTemp1',
        'NoPlan',
        { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1OB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Airattack1','P1OB1Airattack2','P1OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {2, 3, 4}
    trigger = {9, 7, 5}
    Temp = {
        'P1OB1AirAttackTemp2',
        'NoPlan',
        { 'uaa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1OB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Airattack1','P1OB1Airattack2','P1OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {4, 6, 8}
    trigger = {50, 45, 40}
    Temp = {
        'P1OB1AirAttackTemp3',
        'NoPlan',
        { 'uaa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1OB1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Airattack1','P1OB1Airattack2','P1OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    Temp = {
        'P1OB1AirAttackTemp4',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1OB1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Airattack1','P1OB1Airattack2','P1OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {4, 6, 8}
    trigger = {40, 35, 30}
    Temp = {
        'P1OB1AirAttackTemp5',
        'NoPlan',
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1OB1AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Airattack1','P1OB1Airattack2','P1OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {2, 4, 6}
    trigger = {30, 25, 20}
    Temp = {
        'P1OB1AirAttackTemp6',
        'NoPlan',
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1OB1AirAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 210,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB1Airattack1','P1OB1Airattack2','P1OB1Airattack3'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 
end

function Orderbase2AI()
        
    Orderbase2:InitializeDifficultyTables(ArmyBrains[Order], 'P1Orderbase2', 'P1OB2MK', 80, {P1OBase2 = 700})
    Orderbase2:StartNonZeroBase({{6, 8, 10}, {4, 6, 8}})
    Orderbase2:SetActive('AirScouting', true)
   
    P1B2OLandattack()
    P1B2ONavalattack() 
end

function P1B2OLandattack()

    local quantity = {}
    local trigger = {}

    opai = Orderbase2:AddOpAI('EngineerAttack', 'P1OB2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1OB2Landattack1','P1OB2Landattack2'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)

    quantity = {4, 5, 6}
    local Temp = {
        'P1OB2LandAttackTemp0',
        'NoPlan',
        { 'ual0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    local Builder = {
        BuilderName = 'P1OB2LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Landattack1','P1OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {6, 4, 2}
    Temp = {
        'P1OB2LandAttackTemp1',
        'NoPlan',
        { 'ual0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1OB2LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Landattack1','P1OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {25, 20, 15}
    Temp = {
        'P1OB2LandAttackTemp2',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1OB2LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.LAND - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Landattack1','P1OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {20, 15, 10}
    Temp = {
        'P1OB2LandAttackTemp3',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1OB2LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Landattack1','P1OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {35, 30, 25}
    Temp = {
        'P1OB2LandAttackTemp4',
        'NoPlan',
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1OB2LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.LAND - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Landattack1','P1OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {50, 45, 40}
    Temp = {
        'P1OB2LandAttackTemp5',
        'NoPlan',
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },  
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1OB2LandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 215,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.LAND - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Landattack1','P1OB2Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end 

function P1B2ONavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {2, 2, 3}
    local Temp = {
        'P1OB2AirAttackTemp0',
        'NoPlan',         
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P1OB2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Navalattack1','P1OB2Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {40, 35, 30}
    Temp = {
        'P1OB2AirAttackTemp1',
        'NoPlan',         
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1OB2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Navalattack1','P1OB2Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 2}
    trigger = {3, 2, 1}
    Temp = {
        'P1OB2AirAttackTemp2',
        'NoPlan',         
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1OB2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.STRUCTURE * categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB2Navalattack3','P1OB2Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

-- Part 1.5 bases

function Seraphimbase2AI()
        
    Seraphimbase2:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P1Seraphimbase2', 'P1SB2MK', 80, {P1SBase2 = 700})
    Seraphimbase2:StartNonZeroBase({{8, 12, 16}, {6, 9, 12}})
    Seraphimbase2:SetActive('AirScouting', true)
   
    P1B2SLandattack()
    P1B2SAirattack() 
end

function P1B2SLandattack()

    local quantity = {}
    local trigger = {}

    opai = Seraphimbase2:AddOpAI('EngineerAttack', 'P1SB2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)

    quantity = {3, 4, 6}
    local Temp = {
        'P1SB2LandAttackTemp0',
        'NoPlan',      
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    local Builder = {
        BuilderName = 'P1SB2LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 6}
    trigger = {30, 20, 15}
    Temp = {
        'P1SB2LandAttackTemp1',
        'NoPlan',
        { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1SB2LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {25, 20, 15}
    Temp = {
        'P1SB2LandAttackTemp2',
        'NoPlan',
        { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB2LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 6, 9}
    trigger = {50, 45, 35}
    Temp = {
        'P1SB2LandAttackTemp3',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB2LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 3}
    trigger = {70, 60, 55}
    Temp = {
        'P1SB2LandAttackTemp4',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB2LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {12, 8, 5}
    Temp = {
        'P1SB2LandAttackTemp5',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB2LandAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {40, 35, 25}
    Temp = {
        'P1SB2LandAttackTemp6',
        'NoPlan',
        { 'xsl0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB2LandAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 260,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {25, 20, 15}
    Temp = {
        'P1SB2LandAttackTemp7',
        'NoPlan',
        { 'xsl0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },     
    }
    Builder = {
        BuilderName = 'P1SB2LandAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 270,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB2landattack1','P1SB2landattack2','P1SB2landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end 

function P1B2SAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
       'P1SB2AirAttackTemp0',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P1SB2AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase2',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1SB2ADefence1'
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {25, 20, 15}
    Temp = {
        'P1SB2AirAttackTemp1',
        'NoPlan',       
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P1SB2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    Temp = {
        'P1SB2AirAttackTemp2',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1SB2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 

    quantity = {2, 3, 4}
    trigger = {30, 25, 20}
    Temp = {
        'P1SB2AirAttackTemp3',
        'NoPlan',
        { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1SB2AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 

    quantity = {6, 8, 12}
    trigger = {45, 40, 35}
    Temp = {
        'P1SB2AirAttackTemp4',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1SB2AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 140,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SB1Airattack1','P1SB1Airattack2','P1SB1Airattack3','P1SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 
end

function Orderbase3AI()
        
    Orderbase3:InitializeDifficultyTables(ArmyBrains[Order], 'P1Orderbase3', 'P1OB3MK', 80, {P1OBase3 = 700})
    Orderbase3:StartNonZeroBase({{6, 8, 12}, {5, 7, 10}})
    Orderbase3:SetActive('AirScouting', true)
   
    P1B3OLandattack()
    P1B3OAirattack() 
end

function P1B3OLandattack()

    local quantity = {}
    local trigger = {}

    opai = Orderbase3:AddOpAI('EngineerAttack', 'P1OB3_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1OB3Landattack1','P1OB3Landattack2','P1OB3Landattack3'}
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)

    quantity = {4, 5, 6}
    local Temp = {
        'P1OB3LandAttackTemp0',
        'NoPlan',   
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    local Builder = {
        BuilderName = 'P1OB3LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Landattack1','P1OB3Landattack2','P1OB3Landattack3'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {8, 7, 6}
    Temp = {
        'P1OB3LandAttackTemp1',
        'NoPlan',   
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'UEF'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Landattack1','P1OB3Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    Temp = {
        'P1OB3LandAttackTemp2',
        'NoPlan',   
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'UEF'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Landattack1','P1OB3Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {30, 25, 20}
    Temp = {
        'P1OB3LandAttackTemp3',
        'NoPlan',   
        { 'ual0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'UEF'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Landattack1','P1OB3Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {35, 30, 25}
    Temp = {
        'P1OB3LandAttackTemp4',
        'NoPlan',   
        { 'xal0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 160,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'UEF'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1OB3Landattack3'
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end 

function P1B3OAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
        'P1OB3AirAttackTemp0',
        'NoPlan',
        { 'uaa0303', 1, 3, 'Attack', 'GrowthFormation' },          
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P1OB3AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1OB3ADefence1'
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P1OB3AirAttackTemp1',
        'NoPlan',   
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Airattack1','P1OB3Airattack2','P1OB3Airattack3','P1OB3Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {7, 5, 3}
    Temp = {
        'P1OB3AirAttackTemp2',
        'NoPlan',   
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'UEF'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Airattack1','P1OB3Airattack2','P1OB3Airattack3','P1OB3Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 9}
    trigger = {30, 25, 20}
    Temp = {
        'P1OB3AirAttackTemp3',
        'NoPlan',   
        { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'UEF'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Airattack1','P1OB3Airattack2','P1OB3Airattack3','P1OB3Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {30, 25, 20}
    Temp = {
        'P1OB3AirAttackTemp4',
        'NoPlan',   
        { 'xaa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 210,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Airattack1','P1OB3Airattack2','P1OB3Airattack3','P1OB3Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {20, 15, 10}
    Temp = {
        'P1OB3AirAttackTemp5',
        'NoPlan',   
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB3AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 215,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase3',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB3Airattack1','P1OB3Airattack2','P1OB3Airattack3','P1OB3Airattack4'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function Orderbase4AI()
        
    Orderbase4:InitializeDifficultyTables(ArmyBrains[Order], 'P1Orderbase4', 'P1OB4MK', 50, {P1OBase4 = 100})
    Orderbase4:StartNonZeroBase({{7, 10, 13}, {3, 6, 12}})

    Orderbase1:AddExpansionBase('P1Orderbase4', 2)
   
    P1B4ONavalattack() 
end

function P1B4ONavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P1OB4LandAttackTemp0',
        'NoPlan',   
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    local Builder = {
        BuilderName = 'P1OB4LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase4',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB4Navalattack1','P1OB4Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    trigger = {10, 8, 6}
    Temp = {
        'P1OB4LandAttackTemp1',
        'NoPlan',   
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB4LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers', 'UEF'}, trigger[Difficulty], categories.NAVAL - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB4Navalattack1','P1OB4Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    Temp = {
        'P1OB4LandAttackTemp2',
        'NoPlan',   
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },    
    }
    Builder = {
        BuilderName = 'P1OB4LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Orderbase4',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers', 'UEF'}, trigger[Difficulty], categories.T1SUBMARINE + categories.T2SUBMARINE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1OB4Navalattack1','P1OB4Navalattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end 