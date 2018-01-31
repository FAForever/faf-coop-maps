local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local UEF = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local UEFBase = BaseManager.CreateBaseManager()

function UEFBaseAI()
	UEFBase:Initialize(ArmyBrains[UEF], 'MainBase', 'M3_UEF_Base_Marker', 100, {MainBase = 100})
	UEFBase:StartNonZeroBase({7, 5})
	UEFBase:SetActive('AirScouting', true)
	UEFBase:SetActive('LandScouting', true)

	UEFBaseLandAttacks()
	UEFBaseAirAttacks()
	UEFBaseTransportAttacks()
end

function DisableShields()
	UEFBase:SetActive('Shields', false)
end

function UEFBaseLandAttacks()
	local opai = nil
	local quantity = {}

	quantity = {6, 8, 10}
	opai = UEFBase:AddOpAI('BasicLandAttack', 'M3_BaseLandAttack1',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_BaseLandAttack_1'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity({'LightTanks', 'MobileAntiAir'}, quantity[Difficulty])

	quantity = {4, 5, 6}
	opai = UEFBase:AddOpAI('BasicLandAttack', 'M3_BaseLandAttack2',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_BaseLandAttack_1'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity({'MobileAntiAir', 'LightArtillery'}, quantity[Difficulty])

	quantity = {6, 8, 10}
	opai = UEFBase:AddOpAI('BasicLandAttack', 'M3_BaseLandAttack3',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_BaseLandAttack_2'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity({'LightBots', 'MobileAntiAir'}, quantity[Difficulty])

	-- Builds platoon of 4/6/8 Artillery
	quantity = {4, 6, 8}
	opai = UEFBase:AddOpAI('BasicLandAttack', 'M3_BaseLandAttack4',
	    {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_BaseLandAttack_1', 
                				'M3_BaseLandAttack_2'},
            },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('LightArtillery', quantity[Difficulty])

	opai = UEFBase:AddOpAI('BasicLandAttack', 'M3_BaseLandAttack5',
	    {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_BaseLandAttack_1', 
                				'M3_BaseLandAttack_2'},
            },
	        Priority = 150,
	    }
	)
	opai:SetChildQuantity('LightBots', 6)
end


function UEFBaseAirAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}

	-- Maintain Patrols
	quantity = {8, 12, 16}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_MaintainPatrols_1',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_IntPatrol1_Chain'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Interceptors', quantity[Difficulty])

	-- Maintain Patrols
	quantity = {6, 8, 10}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_MaintainPatrols_2',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_IntPatrol2_Chain'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Interceptors', quantity[Difficulty])

	-- Maintain Patrols
	quantity = {8, 10, 12}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_MaintainPatrols_3',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_IntPatrol3_Chain'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Interceptors', quantity[Difficulty])

	-- Platoon of Ints
	quantity = {8, 10, 12}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_1',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_BaseAirAttack_1'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Interceptors', quantity[Difficulty])

	-- Platoon of Ints 2
	quantity = {8, 12, 16}
    trigger = {20, 15, 10}
    opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_BaseAirAttack_1', 
				                'M3_BaseAirAttack_2'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Construct Bomber Attack
    quantity = {4, 5, 6}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_3',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_BaseAirAttack_1'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])

	-- Construct Bomber Attack
    quantity = {6, 7, 8}
    trigger = {25, 20, 15}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_4',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M3_BaseAirAttack_2'
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
    {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})

    -- Construct Bomber Attack
    quantity = {6, 7, 8}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_5',
	    {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_BaseLandAttack_1', 
                				'M3_BaseLandAttack_2'},
            },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])

	-- Target enemy ship
	quantity = {5, 7, 9}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_6',
	  	{
		    MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
		    PlatoonData = {
		      CategoryList = { categories.inc0001 },
		    },
		    Priority = 250,
		}
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
	{'default_brain', 'Player', 1, categories.inc0001})

	-- Target Captured Factory
	quantity = {4, 5, 6}
	opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_7',
	  	{
		    MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
		    PlatoonData = {
		      CategoryList = { categories.ueb0101 },
		    },
		    Priority = 250,
		}
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
	{'default_brain', 'Player', 1, categories.ueb0101})

	if Difficulty == 3 then
		opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_8',
		  	{
			    MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
			    PlatoonData = {
			      CategoryList = { categories.inb1102 },
			    },
			    Priority = 300,
			}
		)
		opai:SetChildQuantity('Gunships', 2)
		opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
		{'default_brain', 'Player', 1, categories.inb1102})
	end

	if Difficulty == 3 then
		opai = UEFBase:AddOpAI('AirAttacks', 'M3_BaseAirAttack_9',
		  	{
			    MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI'},
			    PlatoonData = {
			      CategoryList = { categories.ueb0101 },
			    },
			    Priority = 300,
			}
		)
		opai:SetChildQuantity('Gunships', 2)
		opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
		{'default_brain', 'Player', 1, categories.ueb0101})
	end
end

function UEFBaseTransportAttacks()
	local opai = nil
	local quantity = {}

	-- Transport Builder
    opai = UEFBase:AddOpAI('EngineerAttack', 'M3_Base_TransportBuilder',
    {
        MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M3_BaseTransport_Attack_Route',
            LandingChain = 'M3_BaseTransport_Drop_Chain',
            TransportReturn = 'M3_UEF_Base_Marker',
        },
        Priority = 100,
    })
    opai:SetChildActive('All', false)
    opai:SetChildActive('T1Transports', true)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 5, categories.uea0107})

    -- Drops
    for i = 1, 3 do
        opai = UEFBase:AddOpAI('BasicLandAttack', 'M3_UEFTLandAttack1' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_BaseTransport_Attack_Route',
                LandingChain = 'M3_BaseTransport_Drop_Chain',
                TransportReturn = 'M3_UEF_Base_Marker',
            },
            Priority = 125,
        })
        opai:SetChildQuantity('LightTanks', 6)
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.uea0107})
    end

    for i = 1, 3 do
        opai = UEFBase:AddOpAI('BasicLandAttack', 'M3_UEFTLandAttack2' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_BaseTransport_Attack_Route',
                LandingChain = 'M3_BaseTransport_Drop_Chain',
                TransportReturn = 'M3_UEF_Base_Marker',
            },
            Priority = 125,
        })
        opai:SetChildQuantity('LightBots', 8)
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.uea0107})
    end

    for i = 1, 3 do
        opai = UEFBase:AddOpAI('BasicLandAttack', 'M3_UEFTLandAttack3' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_BaseTransport_Attack_Route',
                LandingChain = 'M3_BaseTransport_Drop_Chain',
                TransportReturn = 'M3_UEF_Base_Marker',
            },
            Priority = 125,
        })
        opai:SetChildQuantity('LightArtillery', 6)
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.uea0107})
    end
end

function DisableBase()
    if(UEFBase) then
        UEFBase:BaseActive(false)
    end
end
