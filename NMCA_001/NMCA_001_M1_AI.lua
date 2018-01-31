local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local UEF = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local UEFOutpost = BaseManager.CreateBaseManager()

function UEFOutpostAI()
	UEFOutpost:Initialize(ArmyBrains[UEF], 'M1_Outpost', 'M1_UEF_Outpost_Marker', 60, {Outpost = 100})
	UEFOutpost:StartNonZeroBase({7, 5})
end

function M1LandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

	-- Send Engineers
    opai = UEFOutpost:AddOpAI('EngineerAttack', 'M1_Outpost_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M2_OutpostAttack_1',
                            'M2_OutpostAttack_2',
                            'M2_OutpostAttack_3'},
        },
        Priority = 100,
    }
    )
    opai:SetChildQuantity('T1Engineers', 4)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

	-- Builds platoon of 4/6/8 Tanks
	quantity = {4, 6, 8}
	opai = UEFOutpost:AddOpAI('BasicLandAttack', 'M1_OutpostLandAttack1',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M2_OutpostAttack_2'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('LightTanks', quantity[Difficulty])

    quantity = {3, 4, 5}
    opai = UEFOutpost:AddOpAI('BasicLandAttack', 'M1_OutpostLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_OutpostAttack_1', 
                                'M2_OutpostAttack_2',
                                'M2_OutpostAttack_3'},
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])

	quantity = {6, 8, 10}
	opai = UEFOutpost:AddOpAI('BasicLandAttack', 'M1_OutpostLandAttack3',
	    {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_OutpostAttack_1', 
                				'M2_OutpostAttack_2',
                				'M2_OutpostAttack_3'},
            },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity({'LightTanks','MobileAntiAir'}, quantity[Difficulty])

	-- Builds platoon of 3/4/5 Artillery
	quantity = {3, 4, 5}
	opai = UEFOutpost:AddOpAI('BasicLandAttack', 'M1_OutpostLandAttack4',
	    {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_OutpostAttack_1', 
                				'M2_OutpostAttack_2',
                				'M2_OutpostAttack_3'},
            },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('LightArtillery', quantity[Difficulty])

    quantity = {12, 16, 20}
    trigger = {40, 32, 24}
    opai = UEFOutpost:AddOpAI('BasicLandAttack', 'M1_OutpostLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_OutpostAttack_2',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
    {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})

    -- Builds platoon of 3/3/4 T1 Tanks and 3/3/4 T1 Arties
    quantity = {6, 6, 8}
    trigger = {48, 40, 32}
    opai = UEFOutpost:AddOpAI('BasicLandAttack', 'M1_OutpostLandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_OutpostAttack_1', 
                				'M2_OutpostAttack_2',
                				'M2_OutpostAttack_3'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE, '>='})

    -- Build LABS
	quantity = {2, 3, 4}
	opai = UEFOutpost:AddOpAI('BasicLandAttack', 'M1_OutpostLandAttack7',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	        PlatoonData = {
	            PatrolChains = {'M2_OutpostAttack_1',
	            				'M2_OutpostAttack_2',
	            				'M2_OutpostAttack_3'},
	        },
	        Priority = 150,
	    }
	)
	opai:SetChildQuantity('LightBots', quantity[Difficulty])

    -- Send a squad of units
    quantity = {6, 8, 10}
    opai = UEFOutpost:AddOpAI('BasicLandAttack', 'M1_OutpostLandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_OutpostAttack_1', 
				                'M2_OutpostAttack_2', 
				                'M2_OutpostAttack_3'},
            },
            Priority = 125,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'MobileAntiAir'}, quantity[Difficulty])
end


function M1AirAttacks()
   local opai = nil
   local quantity = {}

	-- Builds platoon of 3/4/5 Bombers
	quantity = {3, 4, 5}
	opai = UEFOutpost:AddOpAI('AirAttacks', 'M1_OutpostAirAttack1',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M2_OutpostAttack_1'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])

	-- Builds platoon of 4/5/6 Interceptors
	quantity = {4, 5, 6}
	opai = UEFOutpost:AddOpAI('AirAttacks', 'M1_OutpostAirAttack2',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M2_OutpostAttack_1'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Interceptors', quantity[Difficulty])

	quantity = {8, 12, 16}
    trigger = {20, 15, 10}
    opai = UEFOutpost:AddOpAI('AirAttacks', 'M1_EastAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_OutpostAttack_1', 
				                'M2_OutpostAttack_2', 
				                'M2_OutpostAttack_3'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Construct Bomber Patrols
    quantity = {2, 3, 4}
	opai = UEFOutpost:AddOpAI('AirAttacks', 'M1_OutpostAirAttack4',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M2_Outpost_Patrol'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

function DisableBase()
    if(UEFOutpost) then
        UEFOutpost:BaseActive(false)
    end
end
