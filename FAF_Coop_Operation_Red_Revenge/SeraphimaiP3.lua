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
local SeraphimbaseEXP1 = BaseManager.CreateBaseManager()
local SeraphimbaseEXP2 = BaseManager.CreateBaseManager()
local SeraphimbaseEXP3 = BaseManager.CreateBaseManager()

local Orderbase1 = BaseManager.CreateBaseManager()
local Orderbase2 = BaseManager.CreateBaseManager()
local OrderbaseEXP1 = BaseManager.CreateBaseManager()
local OrderbaseEXP2 = BaseManager.CreateBaseManager()

function P3Seraphimbase1AI()
    
    local quantity = {}
    quantity = {2, 3, 4}
    Seraphimbase1:InitializeDifficultyTables(ArmyBrains[Seraphim], 'P3Seraphimbase', 'P3SB1MK', 80, {P3SBase1 = 100})
    Seraphimbase1:StartNonZeroBase({{14, 27, 40}, {11, 22, 33}})
    Seraphimbase1:SetActive('AirScouting', true)
    Seraphimbase1:SetSupportACUCount(quantity[Difficulty])
    Seraphimbase1:SetSACUUpgrades({'Overcharge', 'Shield', 'EngineeringThroughput'}, true)
    Seraphimbase1:SetMaximumConstructionEngineers(4)

    Seraphimbase1:AddBuildGroupDifficulty('P3SBase1EXD', 110)
   
    P3B1SLandattack()
    P3B1SAirattack() 
    P3SB1EXPattacks()
end

function P3B1SLandattack()

    local quantity = {}
    local trigger = {}
	
    quantity = {5, 8, 10}
	local Temp = {
        'P3SB1LandAttackTemp1',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   	     
    }
    local Builder = {
        BuilderName = 'P3SB1LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3SB1Landattack1','P3SB1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 10, 15}
    Temp = {
        'P3SB1LandAttackTemp2',
        'NoPlan',
        { 'xsl0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P3SB1LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3SB1Landattack1','P3SB1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 10, 15}
    trigger = {4, 3, 2}
    Temp = {
        'P3SB1LandAttackTemp3',
        'NoPlan',
        { 'xsl0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xsl0307', 1, 4, 'Attack', 'GrowthFormation' },        
    }
    Builder = {
        BuilderName = 'P3SB1LandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3SB1Landattack1','P3SB1Landattack2'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end	

function P3B1SAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
       'P3SB1AirAttackTemp0',
       'NoPlan',
       { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
       { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P3SB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P2Seraphimbase',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3SAirPatrol'
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {10, 15, 20}
    Temp = {
        'P3SB1AirAttackTemp1',
        'NoPlan',
        { 'xsa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P3SB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3SB1Airattack1','P3SB1Airattack2','P3SB1Airattack3','P2SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 8, 10}
    Temp = {
        'P3SB1AirAttackTemp2',
        'NoPlan',
        { 'xsa0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P3SB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 115,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3SB1Airattack1','P3SB1Airattack2','P3SB1Airattack3','P2SB1Airattack4'}
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    
    quantity = {10, 15, 20}
    trigger = {25, 20, 15}
    Temp = {
        'P3SB1AirAttackTemp3',
        'NoPlan',       
        { 'xsa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P3SB1AirAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3SB1Airattack1','P3SB1Airattack2','P3SB1Airattack3','P2SB1Airattack4'}
       },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {10, 20, 30}
    opai = Seraphimbase1:AddOpAI('AirAttacks', 'M3B1_Seraphim_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.SATELLITE, '>='})
            
    quantity = {10, 15, 20}
    opai = Seraphimbase1:AddOpAI('AirAttacks', 'M3B1_Seraphim_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.LAND},
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 2, categories.EXPERIMENTAL * categories.LAND, '>='})
end

function P3SB1EXPattacks()
    local opai = nil
    local quantity = {}
    quantity = {4, 5, 6}
    opai = Seraphimbase1:AddOpAI({'P3SBot4','P3Sbomber1'},
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3SB1Landattack1','P3SB1Landattack2'}
       },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function P3Seraphimbase2AI()
        
    Seraphimbase2:Initialize(ArmyBrains[Seraphim], 'P3Seraphimbase2', 'P3SB2MK', 50, {P3SBase2 = 100})
    Seraphimbase2:StartNonZeroBase({{9, 10, 14}, {4, 6, 8}})
    
    Seraphimbase1:AddExpansionBase('P3Seraphimbase2', 1)
    P3B2SNavalattack()
    P3SB2EXPattacks()
end

function P3B2SNavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    local Temp = {
        'P3SB2NavalAttackTemp0',
        'NoPlan',         
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
        BuilderName = 'P3SB2NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3SB2Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {35, 30, 25}
    Temp = {
        'P3SB2NavalAttackTemp1',
        'NoPlan',         
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xss0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
        BuilderName = 'P3SB2NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3SB2Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {4, 6, 8}
    trigger = {25, 20, 15}
    Temp = {
        'P3SB2NavalAttackTemp2',
        'NoPlan',         
        { 'xss0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3SB2NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.NAVAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3SB2Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {2, 3, 4}
    trigger = {8, 6, 4}
    Temp = {
        'P3SB2NavalAttackTemp3',
        'NoPlan',         
        { 'xss0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3SB2NavalAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 210,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Seraphimbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.NAVAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3SB2Navalattack1',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder ) 
end 

function P3SB2EXPattacks()
    local opai = nil
    local quantity = {}
    
    quantity = {3, 4, 6}
    opai = Seraphimbase2:AddOpAI('P3Sbomber2',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
            PlatoonData = {
            PatrolChains = {'P3SB1Airattack1','P3SB1Airattack2','P3SB1Airattack3','P3SB1Airattack4'}
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    ) 
end

function P3SeraphimbaseEXP1AI()
        
    SeraphimbaseEXP1:Initialize(ArmyBrains[Seraphim], 'P3SeraphimbaseEXP1', 'P3SEXB1MK', 40, {P3SEXPB1 = 100})
    SeraphimbaseEXP1:StartNonZeroBase({2, 4, 6})
    
    Seraphimbase1:AddExpansionBase('P3SeraphimbaseEXP1', 4)
    P3SBEXP1attacks()
end

function P3SBEXP1attacks()

    local opai = nil
    local quantity = {}
    quantity = {2, 4, 6}
    opai = SeraphimbaseEXP1:AddOpAI('P3SBot3',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M3_Bot_Platoon1',
                NumRequired = 2,
                PatrolChain = 'P3SEXPattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function P3SeraphimbaseEXP2AI()
        
    SeraphimbaseEXP2:Initialize(ArmyBrains[Seraphim], 'P3SeraphimbaseEXP2', 'P3SEXB2MK', 40, {P3SEXPB2 = 100})
    SeraphimbaseEXP2:StartNonZeroBase({2, 4, 6})
   
    Seraphimbase1:AddExpansionBase('P3SeraphimbaseEXP2', 4)
    P3SBEXP2attacks()
end

function P3SBEXP2attacks()
    local opai = nil
    local quantity = {}
    quantity = {2, 4, 6}
    opai = SeraphimbaseEXP2:AddOpAI('P3SBot2',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M3_Bot_Platoon2',
                NumRequired = 2,
                PatrolChain = 'P3SEXPattack' .. Random(1, 3),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function P3SeraphimbaseEXP3AI()
        
    SeraphimbaseEXP3:Initialize(ArmyBrains[Seraphim], 'P3SeraphimbaseEXP3', 'P3SEXB3MK', 40, {P3SEXPB3 = 100})
    SeraphimbaseEXP3:StartNonZeroBase({2, 4, 6})
    
    Seraphimbase1:AddExpansionBase('P3SeraphimbaseEXP3', 4)
    P3SBEXP3attacks()
end

function P3SBEXP3attacks()
    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = SeraphimbaseEXP3:AddOpAI('P3SBot1',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
            PlatoonData = {
                MoveChains = {'P3SB1Landattack1','P3SB1Landattack2'}
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    ) 
end

-- Order Base

function P3Orderbase1AI()

    local quantity = {}
    quantity = {2, 3, 4}    
    Orderbase1:InitializeDifficultyTables(ArmyBrains[Order], 'P3Orderbase1', 'P3OB1MK', 80, {P3OBase1 = 100})
    Orderbase1:StartNonZeroBase({{18, 27, 34}, {14, 21, 28}})
    Orderbase1:SetActive('AirScouting', true)
    Orderbase1:SetSupportACUCount(quantity[Difficulty])
    Orderbase1:SetSACUUpgrades({'ResourceAllocation', 'Shield', 'EngineeringFocusingModule'}, true)
    Orderbase1:SetMaximumConstructionEngineers(4)

    Orderbase1:AddBuildGroupDifficulty('P3OBase1EXD', 110, false)
   
    P3B1OLandattack()
    P3B1OAirattack() 
    P3OB1EXPattacks()
end

function P3B1OLandattack()

    local quantity = {}
    local trigger = {}

    quantity = {6, 8, 12}
    local Temp = {
        'P3B1OLandAttackTemp0',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },           
    }
    local Builder = {
        BuilderName = 'P3B1OLandAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Orderbase1',
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P3OB1Landattack1','P3OB1Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    
    quantity = {3, 5, 6}
    trigger = {50, 45, 30}
    Temp = {
        'P3B1OLandAttackTemp1',
        'NoPlan',
        { 'ual0111', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },          
    }
    Builder = {
        BuilderName = 'P3B1OLandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3OB1Landattack1','P3OB1Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {6, 8, 12}
    quantity2 = {3, 4, 6}
    trigger = {3, 2, 1}
    Temp = {
        'P3B1OLandAttackTemp3',
        'NoPlan',
        { 'ual0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'xal0305', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },
        { 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },             
    }
    Builder = {
        BuilderName = 'P3B1OLandAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {CustomFunctions, 'MoveChainPickerThread'},     
        PlatoonData = {
           MoveChains = {'P3OB1Landattack1','P3OB1Landattack2'}
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end 

function P3B1OAirattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    local Temp = {
       'P3OB1AirAttackTemp0',
       'NoPlan',     
       { 'uaa0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
       { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P3OB1AirAttackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 500,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Orderbase1',
       PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3OAirPatrol'
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {7, 10, 14}
    Temp = {
        'P3OB1AirAttackTemp1',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P3OB1AirAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Orderbase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3OB1Airattack1','P3OB1Airattack2','P3OB1Airattack3','P3OB1Airattack4'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {7, 10, 14}
    trigger = {35, 35, 25}
    Temp = {
        'P3OB1AirAttackTemp2',
        'NoPlan',
        { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },         
    }
    Builder = {
        BuilderName = 'P3OB1AirAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3Orderbase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
           PatrolChains = {'P3OB1Airattack1','P3OB1Airattack2','P3OB1Airattack3','P3OB1Airattack4'}
       },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder ) 

    quantity = {7, 14, 21}
    opai = Orderbase1:AddOpAI('AirAttacks', 'M3B1_Order_Air_Attack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { (categories.EXPERIMENTAL * categories.AIR) - categories.xea0002},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, (categories.EXPERIMENTAL * categories.AIR) - categories.xea0002, '>='})
            
    quantity = {14, 21, 28}
    opai = Orderbase1:AddOpAI('AirAttacks', 'M3B1_Order_Air_Attack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
            PlatoonData = {
              CategoryList = { categories.EXPERIMENTAL * categories.STRUCTURE},
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 1, categories.EXPERIMENTAL * categories.STRUCTURE, '>='})
end

function P3OB1EXPattacks()

    local opai = nil
    local quantity = {}
    quantity = {2, 4, 6}
    opai = Orderbase1:AddOpAI('P3Obot1',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M3_GC_Platoon1',
                NumRequired = 3,
                PatrolChain = 'P3OB1Landattack' .. Random(1, 2),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function P3Orderbase2AI()
        
    Orderbase2:InitializeDifficultyTables(ArmyBrains[Order], 'P3Orderbase2', 'P3OB2MK', 50, {P3OBase2 = 100})
    Orderbase2:StartNonZeroBase({{8, 11, 14}, {6, 9, 12}})

    P3B1ONavalattack()
    P3OB2EXPattacks()
end

function P3B1ONavalattack()

    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 6}
    local Temp = {
        'P3OB2NavalAttackTemp0',
        'NoPlan',         
        { 'xas0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    local Builder = {
        BuilderName = 'P3OB2NavalAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Orderbase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3OB2Navalattack1',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {3, 4, 6}
    trigger = {40, 30, 25}
    Temp = {
        'P3OB2NavalAttackTemp1',
        'NoPlan',         
        { 'uas0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3OB2NavalAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3OB2Navalattack1',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {2, 2, 3}
    trigger = {30, 25, 20}
    Temp = {
        'P3OB2NavalAttackTemp2',
        'NoPlan',         
        { 'uas0302', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
    }
    Builder = {
        BuilderName = 'P3OB2NavalAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'P3Orderbase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
           PatrolChain = 'P3OB2Navalattack1',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end

function P3OB2EXPattacks()

    local opai = nil
    local quantity = {}
    
    quantity = {2, 3, 4}
    opai = Orderbase2:AddOpAI('P3OSub',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
            PlatoonData = {
            PatrolChain = 'P3OB2Navalattack1',
        },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    ) 
end

function P3OrderbaseEXP1AI()
        
    OrderbaseEXP1:Initialize(ArmyBrains[Order], 'P3OrderbaseEXP1', 'P3OEXB1MK', 30, {P3OEXPB1 = 100})
    OrderbaseEXP1:StartNonZeroBase({2, 4, 6})
    
    Orderbase1:AddExpansionBase('P3OrderbaseEXP1', 4)
    P3OBEXP1attacks()
end

function P3OBEXP1attacks()

    local opai = nil
    local quantity = {}
    quantity = {2, 4, 6}
    opai = OrderbaseEXP1:AddOpAI('P3Obot2',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M3_GC_Platoon2',
                NumRequired = 2,
                PatrolChain = 'P3OB1Landattack' .. Random(1, 2),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end

function P3OrderbaseEXP2AI()
        
    OrderbaseEXP2:Initialize(ArmyBrains[Order], 'P3OrderbaseEXP2', 'P3OEXB2MK', 30, {P3OEXPB2 = 100})
    OrderbaseEXP2:StartNonZeroBase({2, 4, 6})
   
    Orderbase1:AddExpansionBase('P3OrderbaseEXP2', 4)
    P3OBEXP2attacks()
end

function P3OBEXP2attacks()
    local opai = nil
    local quantity = {}
    quantity = {2, 4, 6}
    opai = OrderbaseEXP2:AddOpAI('P3OSaucer',
        {
            Amount = 4,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
            PlatoonData = {
                Name = 'M3_SC_Platoon1',
                NumRequired = 2,
                PatrolChain = 'P3OB1Airattack' .. Random(1, 4),
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )   
end