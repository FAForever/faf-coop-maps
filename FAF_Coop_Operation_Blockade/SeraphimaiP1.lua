local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 1
local Seraphim = 2
local Difficulty = ScenarioInfo.Options.Difficulty

local Seraphimbase1 = BaseManager.CreateBaseManager()
local Seraphimbase2 = BaseManager.CreateBaseManager()

function Seraphimbase1AI()
    	
    Seraphimbase1:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P1Seraphimbase1', 'P1serabase1MK', 100, {P1base1 = 700})
    Seraphimbase1:StartNonZeroBase({{9, 16, 23}, {7, 14, 21}})
    Seraphimbase1:SetActive('AirScouting', true)
   
    P1B1seraLand()
    P1B1seraAir() 
end

function P1B1seraLand()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P1B1LandAttackTemp0',
        'NoPlan',
        { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	   
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
        { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },    
    }
    local Builder = {
        BuilderName = 'P1B1LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1Landdefence'
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {4, 5, 6}
	Temp = {
        'P1B1LandAttackTemp1',
        'NoPlan',
        { 'xsl0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	     
    }
    Builder = {
        BuilderName = 'P1B1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    trigger = {45, 40, 30}
    Temp = {
        'P1B1LandAttackTemp1.5',
        'NoPlan',
        { 'xsl0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1B1LandAttackBuilder1.5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.ALLUNITS * categories.MOBILE) - categories.ENGINEER}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {10, 8, 6}
    Temp = {
        'P1B1LandAttackTemp2',
        'NoPlan',
        { 'xsl0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1B1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {13, 11, 9}
    Temp = {
        'P1B1LandAttackTemp3',
        'NoPlan',
        { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1B1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    trigger = {12, 10, 8}
    Temp = {
        'P1B1LandAttackTemp4',
        'NoPlan',
        { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1B1LandAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 202,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.STRUCTURE * categories.DEFENSE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 7, 10}
    trigger = {35, 30, 25}
    Temp = {
       'P1B1LandAttackTemp5',
       'NoPlan',
       { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
       BuilderName = 'P1B1LandAttackBuilder5',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 203,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 3}
    quantity = {3, 4, 6}
    trigger = {12, 10, 8}
    Temp = {
       'P1B1LandAttackTemp6',
       'NoPlan',
       { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsl0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
       BuilderName = 'P1B1LandAttackBuilder6',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 300,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.ALLUNITS}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {10, 8, 5}
    Temp = {
       'P1B1LandAttackTemp7',
       'NoPlan',
       { 'xsl0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsl0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },           
    }
    Builder = {
       BuilderName = 'P1B1LandAttackBuilder7',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 302,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {35, 30, 25}
    Temp = {
       'P1B1LandAttackTemp8',
       'NoPlan',
       { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsl0205', 1, 4, 'Attack', 'GrowthFormation' },
       { 'xsl0307', 1, 2, 'Attack', 'GrowthFormation' },          
    }
    Builder = {
       BuilderName = 'P1B1LandAttackBuilder8',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 305,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.ALLUNITS}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    opai = Seraphimbase1:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P1B1SERlandattack1','P1B1SERlandattack2','P1B1SERlandattack3'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end	

function P1B1seraAir()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
       'P1B1AirAttackTemp0',
       'NoPlan',
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
       { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P1B1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1Airdefence'
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 4}
    Temp = {
        'P1B1AirAttackTemp1',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1B1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERairattack1','P1B1SERairattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {10, 8, 6}
    Temp = {
        'P1B1AirAttackTemp2',
        'NoPlan',       
        { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1B1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 101,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERairattack1','P1B1SERairattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {8, 6, 4}
    Temp = {
       'P1B1AirAttackTemp3',
       'NoPlan',       
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
       BuilderName = 'P1B1AirAttackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 4,
       Priority = 200,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase1',
       BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P1B1SERairattack1','P1B1SERairattack2'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {20, 16, 12}
    Temp = {
        'P1B1AirAttackTemp4',
        'NoPlan',       
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1B1AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 205,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERairattack1','P1B1SERairattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {12, 9, 6}
    Temp = {
        'P1B1AirAttackTemp5',
        'NoPlan',       
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1B1AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 206,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERairattack1','P1B1SERairattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {22, 18, 12}
    Temp = {
        'P1B1AirAttackTemp6',
        'NoPlan',       
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1B1AirAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 202,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERairattack1','P1B1SERairattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    trigger = {6, 5, 4}
    Temp = {
        'P1B1AirAttackTemp7',
        'NoPlan',       
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P1B1AirAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 203,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B1SERairattack1','P1B1SERairattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function Seraphimbase2AI()
    
    Seraphimbase2:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P1Seraphimbase2', 'P1serabase2MK', 110, {P1base2 = 700})
    Seraphimbase2:StartNonZeroBase({{12, 15, 20},{9, 12, 17}})
    Seraphimbase2:SetActive('AirScouting', true)
     
    ForkThread(
        function()
            WaitSeconds(5)
            Seraphimbase2:AddBuildGroup('P1base2EXD_D' .. Difficulty, 800, false)
        end
    )

    P1B2seraLand()
    P1B2seraNaval()
    P1B2seraAir()
end

function P1B2seraAir()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
        'P1B2AirAttackTemp0',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	   
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
	    { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P1B2AirAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P1Airdefence2'
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 3, 5}
    Temp = {
        'P1B2AirAttackTemp1',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	     
    }
    Builder = {
        BuilderName = 'P1B2AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2SERairattack1','P1B2SERairattack2', 'P1B2SERairattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 9}
    trigger = {70, 50, 45}
    Temp = {
        'P1B2AirAttackTemp1.5',
        'NoPlan',
        { 'xsa0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P1B2AirAttackBuilder1.5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - (categories.ENGINEER + categories.WALL)}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2SERairattack1','P1B2SERairattack2', 'P1B2SERairattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {10, 9, 8}
    Temp = {
        'P1B2AirAttackTemp2',
        'NoPlan',
        { 'xsa0102', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1B2AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
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
           PatrolChains = {'P1B2SERairattack1','P1B2SERairattack2', 'P1B2SERairattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 7}
    trigger = {16, 12, 10}
    Temp = {
        'P1B2AirAttackTemp3',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1B2AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2SERairattack1','P1B2SERairattack2', 'P1B2SERairattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 7}
    Temp = {
        'P1B2AirAttackTemp4',
        'NoPlan',
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1B2AirAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 201,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 7, (categories.AIR * categories.MOBILE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2SERairattack1','P1B2SERairattack2', 'P1B2SERairattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {16, 12, 10}
    Temp = {
        'P1B2AirAttackTemp5',
        'NoPlan',
        { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1B2AirAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.ALLUNITS}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2SERairattack1','P1B2SERairattack2', 'P1B2SERairattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 4, 6}
    trigger = {16, 14, 10}
    Temp = {
        'P1B2AirAttackTemp6',
        'NoPlan',
        { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsa0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P1B2AirAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 301,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * (categories.TECH2 + categories.TECH3)}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2SERairattack1','P1B2SERairattack2', 'P1B2SERairattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

function P1B2seraLand()

    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P1B2LandAttackTemp0',
        'NoPlan',
        { 'xsl0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	      
    }
    local Builder = {
        BuilderName = 'P1B2LandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2Landattack1','P1B2Landattack2', 'P1B2Landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {2, 3, 4}
    trigger = {15, 12, 10}
	Temp = {
        'P1B2LandAttackTemp1',
        'NoPlan',
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 	      
    }
    Builder = {
        BuilderName = 'P1B2LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 101,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2Landattack1','P1B2Landattack2', 'P1B2Landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {9, 7, 5}
    Temp = {
        'P1B2LandAttackTemp2',
        'NoPlan',
        { 'xsl0205', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },             
    }
    Builder = {
        BuilderName = 'P1B2LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 102,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.ANTINAVY}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2Landattack1','P1B2Landattack2', 'P1B2Landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    Temp = {
        'P1B2LandAttackTemp3',
        'NoPlan',
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0205', 1, 2, 'Attack', 'GrowthFormation' }, 
        { 'xsl0103', 1, 4, 'Attack', 'GrowthFormation' },            
    }
    Builder = {
        BuilderName = 'P1B2LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 103,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimebase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 10, categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1B2Landattack1','P1B2Landattack2', 'P1B2Landattack3'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    opai = Seraphimbase2:AddOpAI('EngineerAttack', 'M1_Sera_TransportBuilder1',
     {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P1serabase2MK',
        },
        Priority = 800,
     }
    )
    opai:SetChildQuantity('T2Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', quantity[Difficulty], categories.xsa0104})

    quantity = {8, 10, 16}
    trigger = {60, 55, 50}
    opai = Seraphimbase2:AddOpAI('BasicLandAttack', 'M1_Sera_TransportAttack_1',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P1B2Dropattack1', 
                    LandingChain = 'P1B2Drop1',
                    MovePath = 'P1B2Dropmove1',
                    TransportReturn = 'P1serabase2MK',
                },
                Priority = 500,
            }
        )
        opai:SetChildQuantity({'LightTanks'}, quantity[Difficulty])
        opai:SetLockingStyle('DeathTimer', {LockTimer = 50})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {8, 10, 16}
    trigger = {40, 35, 30}
    opai = Seraphimbase2:AddOpAI('BasicLandAttack', 'M1_Sera_TransportAttack_2',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P1B2Dropattack1', 
                    LandingChain = 'P1B2Drop1',
                    MovePath = 'P1B2Dropmove1',
                    TransportReturn = 'P1serabase2MK',
                },
                Priority = 550,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
        opai:SetLockingStyle('DeathTimer', {LockTimer = 90})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.TECH1, '>='})
end

function P1B2seraNaval()

    local quantity = {}
    local trigger = {}

    local Temp = {
       'P1B2SeaAttackTemp0',
       'NoPlan',
       { 'xss0201', 1, 2, 'Attack', 'GrowthFormation' },   	   
       { 'xss0202', 1, 2, 'Attack', 'GrowthFormation' }, 
	   { 'xss0203', 1, 6, 'Attack', 'GrowthFormation' },
    }
    local Builder = {
       BuilderName = 'P1B2SeaAttackTemp0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 300,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P1Seraphimbase2',
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P1B2NavalDefense'
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
	
    quantity = {2, 2, 3}
    trigger = {80, 75, 60}
	Temp = {
        'P1B2SeaAttackTemp1',
        'NoPlan',
        { 'xss0103', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	    
    }
    Builder = {
        BuilderName = 'P1B2SeaAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.ALLUNITS * categories.STRUCTURE) - categories.WALL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SERnavalattack1','P1SERnavalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {10, 9, 7}
    Temp = {
        'P1B2SeaAttackTemp2',
        'NoPlan',
        { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1B2SeaAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 101,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) + categories.T1SUBMARINE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SERnavalattack1','P1SERnavalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    trigger = {45, 35, 30}
    Temp = {
        'P1B2SeaAttackTemp3',
        'NoPlan',
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1B2SeaAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3 ,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.ALLUNITS * categories.STRUCTURE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SERnavalattack1','P1SERnavalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {1, 2, 3}
    trigger = {14, 12, 10}
    Temp = {
        'P1B2SeaAttackTemp4',
        'NoPlan',
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1B2SeaAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 201,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SERnavalattack1','P1SERnavalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 5, 6}
    trigger = {12, 9, 6}
    Temp = {
        'P1B2SeaAttackTemp5',
        'NoPlan',
        { 'xss0202', 1, 2, 'Attack', 'GrowthFormation' },
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1B2SeaAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 205,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SERnavalattack1','P1SERnavalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {45, 35, 25}
    Temp = {
        'P1B2SeaAttackTemp6',
        'NoPlan',
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P1B2SeaAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 204,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P1Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P1SERnavalattack1','P1SERnavalattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end
